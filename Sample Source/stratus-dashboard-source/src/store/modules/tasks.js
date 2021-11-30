import Vue from 'vue';
import azure from 'azure-storage';
import AzureStorageUtils from '@/shared/azure-storage-utils';
import moment from 'moment';
import api from '../../shared/api';

function modifyTask(rawTask, id) {
  var str = rawTask.PartitionKey._.split("-");
  var taskText;
  var programRef;
  var analysisId;

  if (str) {
    programRef = str[0];
    analysisId = str[1];
    taskText = str[0] + "/" + rawTask.Type._;
  }

  if (!rawTask.Progress) {
    rawTask.Progress = { "_": 0 };
  }

  return Object.assign(rawTask, { id: id, text: taskText, programRef: programRef, analysisId: analysisId});
}

function addTaskWithOptionalValidation(items, status, validateId, loadedTasks, task) {
  if(validateId) {
    if(loadedTasks.includes(`${task.PartitionKey._}_${task.RowKey._}`)){
      return;
    } 
  }
  items[status].push(task);
}

const state = {
    items: {
      pending: [],
      inProgress: [],
      complete: [],
      manualInput: [],
      failed: []
    },
    loadingItems: {
      pending: [],
      inProgress: [],
      complete: [],
      manualInput: [],
      failed: []
    },
    nextId: 1,
    taskHistory: [],
    showSpinner: false,
    nextContinuationToken: null,
    isLoading: false,
    dateFrom: new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 1),
    dateTo: new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate()),
    forceFullRefresh: true,
    taskLoadedUntilTime: new Date()
}

const getters = {
  clfRunInProgress(state) {
    return state.items.inProgress.some(t => t.Type._ === 'Run Catrader Analysis' || t.Type._ === 'Run TouchstoneRe Analysis');
  },
  cedeImportInProgress(state) {
    return state.items.inProgress.some(t => t.Type._ === 'Import CEDE Exposure');
  },
  cedeRunInProgress(state) {
    return state.items.inProgress.some(t => t.Type._ === 'CEDE Loss Analysis');
  },
  mapPerilsInProgress(state) {
    return state.items.inProgress.some(t => t.Type._ === 'Add Perils' || t.Type._ === 'Remove Peril');
  },
  analysisHasFailedTasks: (state) => (programRef, analysisId) => {
    return state.items.failed.filter(x => x.programRef === programRef && x.analysisId === analysisId).length > 0
      || state.items.inProgress.filter(x => x.programRef === programRef && x.analysisId === analysisId)
          .filter(x => moment(x.ModifiedOn._) < moment().subtract(2, 'd')).length > 0
      || state.items.pending.filter(x => x.programRef === programRef && x.analysisId === analysisId)
          .filter(x => moment(x.ModifiedOn._) < moment().subtract(2, 'd')).length > 0;
  },
  analysisHasTasksInProgress: (state) => (programRef, analysisId) => {
    return state.items.inProgress.filter(x => x.programRef === programRef && x.analysisId === analysisId)
          .filter(x => moment(x.ModifiedOn._) > moment().subtract(2, 'd')).length > 0;
  },
  dateToForRequest(state) {
    const output = new Date(state.dateTo);
    output.setDate(output.getDate() + 1);
    return output;
  },
  tasksLoaded(state) {
    return state.items.pending.length + state.items.inProgress.length + state.items.complete.length + state.items.manualInput.length + state.items.failed.length; 
  },
  loadedTaskIds(state) {
    return Object.keys(state.items).reduce((acc, x) => {
      for (let i = 0; i < state.items[x].length; i++) {
        const task = state.items[x][i];
        acc.push(`${task.PartitionKey._}_${task.RowKey._}`);
      }
      return acc;
    }, []);
  }
}

const mutations = {
  addTask(state, item) {
    state.items.pending.push(Object.assign(item, { id: state.nextId }));
    state.nextId += 1;
  },
  updateTasks(state, { items, id }) {
    state.items[id] = items;
  },
  setTasks:  (state, { list }) => {
    // eslint-disable-next-line
    if (!state.nextContinuationToken) {
      state.loadingItems.pending = [];
      state.loadingItems.complete = [];
      state.loadingItems.inProgress = [];
      state.loadingItems.manualInput = [];
      state.loadingItems.failed = [];
    }

    list.forEach((element) => {

      var task = modifyTask(element, state.nextId);

      switch (element.Status._) {
        case 'Pending':
          state.loadingItems.pending.push(task);
          state.nextId += 1;
          break;
        case 'In Progress':
          state.loadingItems.inProgress.push(task);
          state.nextId += 1;
          break;
        case 'Manual Input':
          state.loadingItems.manualInput.push(task);
          state.nextId += 1;
          break;
        case 'Failed':
          state.loadingItems.failed.push(task);
          state.nextId += 1;
          break;
        case 'Completed':
          state.loadingItems.complete.push(task);
          state.nextId += 1;
          break;
      }
    });
  },
  setTaskHistory: (state, { list } ) => {
    state.taskHistory = [];

    list.forEach((entity) => {
      state.taskHistory.push({
        PartitionKey: entity.PartitionKey._,
        RowKey: entity.RowKey._,
        Status: entity.Status._,
        Type: entity.Type._,
        Message: entity.Message ? entity.Message._ : '',
        BlobUri: entity.BlobUri ? entity.BlobUri._ : '',
        CreatedOn: entity.CreatedOn ? entity.CreatedOn._ : null,
        CreatedBy: entity.CreatedBy ? entity.CreatedBy._ : null,
        ModifiedOn: entity.ModifiedOn ? entity.ModifiedOn._ :  null,
        ModifiedBy: entity.ModifiedBy ? entity.ModifiedBy._ : null,
        Progress: entity.Progress._
      });    
    });
    
    state.taskHistory.sort((a, b) => a.CreatedOn - b.CreatedOn || a.ModifiedOn - b.ModifiedOn);
  },
  setShowSpinner(state, showSpinner) {
    state.showSpinner = showSpinner;
  },
  reset(state) {
    state.items.pending = [];
    state.items.complete = [];
    state.items.inProgress = [];
    state.items.manualInput = [];
    state.items.failed = [];
    state.taskHistory = [];

    state.loadingItems.pending = [];
    state.loadingItems.complete = [];
    state.loadingItems.inProgress = [];
    state.loadingItems.manualInput = [];
    state.loadingItems.failed = [];
  },
  completeLoad(state, keepExisting) {
    if(!keepExisting) {
      state.items.pending = [];
      state.items.complete = [];
      state.items.inProgress = [];
      state.items.manualInput = [];
      state.items.failed = [];
    }
    const loadedTaskIds = getters.loadedTaskIds(state);
    state.loadingItems.pending.forEach(x => addTaskWithOptionalValidation(state.items, 'pending', keepExisting, loadedTaskIds, x));
    state.loadingItems.complete.forEach(x => addTaskWithOptionalValidation(state.items, 'complete', keepExisting, loadedTaskIds, x));
    state.loadingItems.inProgress.forEach(x => addTaskWithOptionalValidation(state.items, 'inProgress', keepExisting, loadedTaskIds, x));
    state.loadingItems.manualInput.forEach(x => addTaskWithOptionalValidation(state.items, 'manualInput', keepExisting, loadedTaskIds, x));
    state.loadingItems.failed.forEach(x => addTaskWithOptionalValidation(state.items, 'failed', keepExisting, loadedTaskIds, x));

    state.loadingItems.pending = [];
    state.loadingItems.complete = [];
    state.loadingItems.inProgress = [];
    state.loadingItems.manualInput = [];
    state.loadingItems.failed = [];
  },
  updateContinuationToken(state, token) {
    state.nextContinuationToken = token;
  },
  switchIsLoading(state) {
    state.isLoading = !state.isLoading;
  },
  updateDates(state, {dateFrom, dateTo}) {
    state.dateFrom = dateFrom;
    state.dateTo = dateTo;
    state.forceFullRefresh = true;
  },
  updateTask(state, {entry, index, task}) {
    if(!state.items[entry]) return;
    Vue.set(state.items[entry], index, modifyTask(task, state.nextId));
    state.nextId += 1;
  },
  fullRefreshComplete(state) {
    state.forceFullRefresh = false;
    state.taskLoadedUntilTime = new Date();
  },
  interimRefreshComplete(state) {
    state.taskLoadedUntilTime = new Date();
  }
}

const actions = {
  async updateTasks(context, payload) {
    if(context.state.forceFullRefresh) {
      context.dispatch('loadTasks', payload);
    } else {
      context.dispatch('refreshRelevantTasks', payload);
    }
  },
  async loadTasks(context, { taskReference, showSpinner, topLevel }) {
    if (topLevel === null || topLevel === undefined) topLevel = true;
    if (context.state.isLoading && topLevel) {
      return;
    } else if (topLevel) {
      context.commit('switchIsLoading');
    }
    
    if (showSpinner) context.commit('setShowSpinner', true);
    let results = await api.getTasksAsync(context.state.dateFrom, context.getters['dateToForRequest'], taskReference);
    context.commit('setTasks', { list: results });
    context.commit('updateContinuationToken', null);
    if (context.state.nextContinuationToken) {         
      await context.dispatch('loadTasks', { taskReference: taskReference, showSpinner: showSpinner, topLevel: false  });
    }
    if (topLevel) {
      context.commit('completeLoad');
      context.commit('fullRefreshComplete');
      context.commit('switchIsLoading');
    }
    if (showSpinner) context.commit('setShowSpinner', false); 
  },
  async refreshRelevantTasks({commit, state, getters}, { taskReference }) {
    if(state.isLoading) return;
    commit('switchIsLoading');
    const taskPromise = api.getTasksAsync(state.taskLoadedUntilTime, getters['dateToForRequest'], taskReference);
    let tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
    let tableName = config.appPrefix + 'Task';

    for (let i = 0; i < state.items.inProgress.length; i++) {
      const task = state.items.inProgress[i];
      const timeToCheck = task.ModifiedOn ? moment(task.ModifiedOn._) : moment(task.Timestamp._);
      if(timeToCheck > moment().subtract(2, 'd')) {
        const ent = await AzureStorageUtils.retrieveEntityAsync(tableService, tableName, task.PartitionKey._, task.RowKey._);
        commit('updateTask', {
          entry: 'inProgress',
          index: i,
          task: ent
        })
      }
    }

    for (let i = 0; i < state.items.pending.length; i++) {
      const task = state.items.pending[i];
      const timeToCheck = task.ModifiedOn ? moment(task.ModifiedOn._) : moment(task.Timestamp._);
      if(timeToCheck > moment().subtract(5, 'd')) {
        const ent = await AzureStorageUtils.retrieveEntityAsync(tableService, tableName, task.PartitionKey._, task.RowKey._);
        commit('updateTask', {
          entry: 'pending',
          index: i,
          task: ent
        })
      }
    }

    const results = await taskPromise;
    commit('setTasks', {list: results});
    commit('completeLoad', true);
    commit('interimRefreshComplete');
    commit('switchIsLoading');
  },
  loadTaskHistory: ({commit}, { taskReference, taskId }) => {        
    var tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
    var tableName = config.appPrefix + 'TaskHistory';
    let tableQuery = new azure.TableQuery();

    tableQuery = tableQuery.where('PartitionKey eq ?', `${taskReference}-${taskId}`);

    tableService.queryEntities(tableName, tableQuery, null, (error, results, response) => {
      if (!error) {
        commit('setTaskHistory', { list: results.entries });         
      }
    });
  },
  updateDates({commit}, dates) {
    commit('updateDates', dates);
  }
}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
}