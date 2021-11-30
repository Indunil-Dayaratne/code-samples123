import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
import moment from 'moment';
import cloneDeep from 'lodash/cloneDeep';
import id from './idGenerator';

const networkTableName = config.appPrefix + 'PricingNetwork';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const pricingConstants = {
    mappings: {
        QS: {
            schema: 'QuotaShare_1.0',
            version: '1.0'
        },
        CatXL: {
            schema: 'CatXL_1.0',
            version: '1.0'
        },
        AggXL: {
            schema: 'AggXL_1.0',
            version: '1.0'
        },
        ILW: {
            schema: '',
            version: ''
        },
        MultiYear: {
            schema: 'MultiYear_1.0',
            version: '1.0'
        }
    },
    financialDefinition: {
        currency:                       { custom: true, type: 'text', isNumber: false, validFor: ['QS', 'CatXL', 'AggXL', 'ILW'], text: 'Currency' },
        raw_share:                      { custom: false, type: 'text', isNumber: true, validFor: ['QS', 'CatXL', 'AggXL'], text: 'Share (%)' },
        occurrence_limit_value:         { custom: false, type: 'text', isNumber: true, validFor: ['QS', 'CatXL', 'AggXL'], text:'Occurrence Limit' },
        occurrence_attachment_value:    { custom: false, type: 'text', isNumber: true, validFor: ['CatXL', 'AggXL'], text: 'Occurrence Attachment' },
        aggregate_limit_value:          { custom: false, type: 'text', isNumber: true, validFor: ['AggXL'], text:'Aggregate Limit' },
        aggregate_attachment_value:     { custom: false, type: 'text', isNumber: true, validFor: ['AggXL'], text: 'Aggregate Attachment' },
        trigger:                        { custom: false, type: 'text', isNumber: true, validFor: ['ILW'], text:'Trigger' },
        payout:                         { custom: false, type: 'text', isNumber: true, validFor: ['ILW'], text:'Payout' },
        placed:                         { custom: false, type: 'text', isNumber: true, validFor: ['QS', 'CatXL', 'AggXL', 'ILW'], text:'Placed (%)'},
        premium_value:                  { custom: false, type: 'text', isNumber: true, validFor: ['QS', 'CatXL', 'AggXL', 'ILW'], text:'Premium' },
        franchise_deductible_value:     { custom: false, type: 'text', isNumber: true, validFor: ['CatXL', 'AggXL'], text:'Franchise Deductible' },
        reinstatements:                 { custom: true, type: 'text', isNumber: true, validFor: ['CatXL'], text:'Reinstatements'  },
        nth:                            { custom: false, type: 'number', isNumber: true, validFor: ['CatXL'], text:'Nth'  },
        raw_inception_date:             { custom: true, type: 'date', isNumber: false, validFor: ['QS', 'CatXL', 'AggXL', 'ILW'], text:'Inception date'  },
        raw_expiry_date:                { custom: true, type: 'date', isNumber: false, validFor: ['QS', 'CatXL', 'AggXL', 'ILW'], text: 'Expiry date' }  
    },
    objectTypes: {
        INPUT: 'input',
        SUBJECT_LOSS: 'subjectLoss',
        LAYER: 'layer'
    },
    baseSubjectLossParams: {
        name: 'All Losses',
        description: 'Auto generated grouping of all inputs. \nAs inputs are added, the losses will be linked into this subject loss'
    }
}

let getId = id.getIdGenerator();

const getNetworks = async (groupIds) => {
    if(typeof(groupIds) !== 'string' && !Array.isArray(groupIds)) return [];
    const groups = typeof(groupIds) === 'string' ? [groupIds] : groupIds;
    const output = [];

    for (let i = 0; i < groups.length; i++) {
        const groupId = groups[i];
        var tableQuery = new azure.TableQuery();
        tableQuery = tableQuery.where('PartitionKey eq ?', groupId);

        var results = await AzureStorageUtils.queryEntitiesAsync(tableService, networkTableName, tableQuery);

        results.forEach(entity => {
            output.push({
                groupId: entity.PartitionKey._,
                networkId: Number.parseInt(entity.RowKey._),
                revision: entity.Revision ? entity.Revision._ : 0,
                yoa: entity.YOA._,
                name: entity.Name._,
                notes: entity.Notes ? entity.Notes._ : '',
                createdOn: entity.CreatedOn._,
                createdBy: entity.CreatedBy._,
                modifiedOn: entity.ModifiedOn._,
                modifiedBy: entity.ModifiedBy._,
                calculationUpToDate: entity.CalculationUpToDate._,
                isRunning: entity.IsRunning ? entity.IsRunning._ : false
            });
        });
    }

    return output;
}

const getNewLayer = (state) => {
    const id = getId()
    const cededLayer = {
        id,
        data: {
            _schema: pricingConstants.mappings.MultiYear.schema,
            //_schema_version: '1.0',
            layer_schema: '',
            name: 'Name',
            description: 'Description',
            type: '',
            raw_share: 100,
            occurrence_attachment_value: 0,
            occurrence_limit_value: 0,
            aggregate_limit_value: 0,
            aggregate_attachment_value: 0,
            placed: 100,
            currency: 'USD',
            premium_value: 0,
            franchise_deductible_value: 0,
            reinstatements: [],
            nth: 1,
            trigger: 0,
            payout: 0,
            raw_inception_date: moment().month(0).date(1).hours(0).minutes(0).seconds(0).millisecond(0).toDate(),
            raw_expiry_date: moment().month(11).date(31).hours(0).minutes(0).seconds(0).millisecond(0).toDate(),
            objType: 'layer',
            layer_group_id: id,
            layer_type: 'ceded'
        }
    };

    return cededLayer;
};

const getNewPerspectiveLayer = (baseLayer, perspective) => {
    const validPerspectives = ['gross', 'net'];
    if(!validPerspectives.includes(perspective.toLowerCase())) {
        console.error(`Perspective layer type has to be one of ${validPerspectives.join(", ")}`);
        return null;
    }

    if(!baseLayer.data.layer_group_id) {
        baseLayer.data.layer_group_id = getId();
        baseLayer.data.layer_type = 'ceded'
    }

    const layer = getNewLayer();
    layer.data.layer_type = perspective.toLowerCase();
    layer.data.layer_group_id = baseLayer.data.layer_group_id;
    layer.data.layer_schema = pricingConstants.mappings.QS.schema;
    //layer.data._schema_version = pricingConstants.mappings.QS.version;
    layer.data.name = baseLayer.data.name;
    layer.data.description = `${perspective} layer for ${baseLayer.data.name}`
    layer.data.type = 'QS';
    layer.data.occurrence_limit_value = Number.MAX_SAFE_INTEGER;
    layer.data.currency = baseLayer.data.currency;
    layer.data.raw_inception_date = baseLayer.data.raw_inception_date;
    layer.data.raw_expiry_date = baseLayer.data.raw_expiry_date;

    return layer;
}

const getNewGrossLayer = (cededLayer, state) => {
    if(!cededLayer.data.layer_group_id) {
        cededLayer.data.layer_group_id = getId();
        cededLayer.data.layer_type = 'ceded'
    }
    
    if(state) {
        const stateGrossLayer = state.layers.find(x => {
            return x.data.layer_group_id === cededLayer.data.layer_group_id
                && x.data.layer_type === 'gross'
        });
        // New layer not required as it exists already
        if(stateGrossLayer) return null;
    }    

    const grossLayer = getNewPerspectiveLayer(cededLayer, 'Gross');
    const relationship = getNewRelationship(cededLayer.id);
    relationship.source = grossLayer.id;
    return {
        layer: grossLayer,
        relationships: [relationship]
    }
};

const getNewNetLayer = (cededLayer, grossLayer, state) => {
    if(!cededLayer.data.layer_group_id) return null; 
    
    if(state) {
        const stateGrossLayer = state.layers.find(x => {
            return x.data.layer_group_id === cededLayer.data.layer_group_id
                && x.data.layer_type === 'net'
        });
        // New layer not required as it exists already
        if(stateGrossLayer) return null;
    }
    
    if(!grossLayer) return null;

    const netLayer = getNewPerspectiveLayer(cededLayer, 'Net');
    const grossRelationship = getNewRelationship(netLayer.id);
    grossRelationship.source = grossLayer.id;
    const cededRelationship = getNewRelationship(netLayer.id);
    cededRelationship.source = cededLayer.id;
    cededRelationship.data.factor = -100;
    return {
        layer: netLayer,
        relationships: [grossRelationship, cededRelationship]
    }
};

const getUpdatePerspectiveLayer = (baseLayer, perspLayer) => {
    const output = Object.assign({}, perspLayer);
    output.data = Object.assign({}, perspLayer.data);

    output.data.name = baseLayer.data.name;
    output.data.description = `${perspLayer.data.layer_type} layer for ${baseLayer.data.name}`;
    output.data._schema = pricingConstants.mappings.MultiYear.schema;
    output.data.layer_schema = pricingConstants.mappings.QS.schema;
    delete output.data._schema_version;
    output.data.currency = baseLayer.data.currency;
    output.data.raw_inception_date = baseLayer.data.raw_inception_date;
    output.data.raw_expiry_date = baseLayer.data.raw_expiry_date;

    return output;
};

const getNewInput = () => {
    return {
        id: getId(),
        data: {
            _schema: 'LossSet_1.1',
            name: 'Name',
            description: '',
            objType: 'input',
            paths: {},
            pathsObj: {},
            currency: ''
        }
    };
};

const getNewReinstatement = () => {
    return {
        id: getId(),
        raw_premium_value: 100,
        raw_brokerage: 100,
        _selectedToRemove: false,
        objType: 'reinstatement'
    };
};

const getNewRelationship = (to) => {
    return {
        id: getId(),
        source: null,
        _sourceObj: null,
        destination: to,
        data: {
            _schema: 'LinkFilter',
            _schema_version: '2.0',
            expression: '',
            factor: 100, 
            include_record_types: ["Loss", "ReinstatementBrokerageFee", "Tax", "Fee", "BrokerageFee"],
            item: '',
            lossFilter: {
                all: true,
                exclude: false,
                data: []
            },
            sourceType: '',
            objType: 'relationship'
        },
        _selectedToRemove: false,
    };
};

const getNewLossFilter = () => {
    return {
        id: getId(),
        filter: '',
        value: 0,
        _valueObj: {},
        not: false,
        objType: 'filter'
    };
};

const getNewSubjectLoss = (isBase = false) => {
    return {
        id: getId(),
        data: {
            name: isBase ? pricingConstants.baseSubjectLossParams.name : 'Name',
            description: isBase ? pricingConstants.baseSubjectLossParams.description : 'Description',
            objType: 'subjectLoss'
        }
    }
}

const copyNode = (node) => {
    const copy = cloneDeep(node);
    copy.id = getId();
    copy.data.name = 'Copy of ' + node.data.name;
    copy.data.description = `Copied from ${node.data.name}:
    ${node.data.description}    
    `;
    if(copy.data.layer_group_id) copy.data.layer_group_id = getId();
    return copy;
};

const copyDestinationRelationships = (relationships, newDestination) => {
    const output = [];
    for (let i = 0; i < relationships.length; i++) {
        const relationship = relationships[i];
        const copy = cloneDeep(relationship);
        copy.id = getId();
        copy.destination = newDestination;
        delete copy.revision;
        output.push(copy);
    }
    return output;
};

export default {
    getNetworks,
    getNewLayer,
    getNewGrossLayer,
    getNewNetLayer,
    getUpdatePerspectiveLayer,
    getNewInput,
    getNewReinstatement,
    getNewRelationship,
    getNewLossFilter,
    getNewSubjectLoss,
    copyNode,
    copyDestinationRelationships,
    pricingConstants
}