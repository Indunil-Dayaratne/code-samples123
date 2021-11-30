
var Application = function (data) {
    var self = this;
    self.name = ko.observable();
    self.id =ko.observable();
    self.applicationAreas = [];
}

var ApplicationsViewModel = function (applicationsConfig, blade) {
    if(!blade)
        return;
    var self = this;

    self.applicationBladeManager = new BeasBladeManager(blade.path);

    self.applications = ko.observableArray([]);

    self.application = {
        id: ko.observable(),
        name: ko.observable(),
        applicationAreas: []
    }

    self.initialise = function () {
        blade.setLoading('Loading Applications');

        // close any open sub blades
        self.applicationBladeManager.closeBlade(self.applicationBladeManager.blades.applicationInfoBlade);
        self.applicationBladeManager.closeBlade(self.applicationBladeManager.blades.applicationAreaInfoBlade);

        blade.modifyButton("AddApplication", self.addApplication, "/Content/images/icons/Add.png", "Add Application");

        // load Applications
        self.getApplications();

        ko.applyBindings(applicationsVm, blade.content.find("#divApplicationsMain")[0]);

        self.bindApplicationsGrid();
    }

    self.promises = {
        $openApplicationInfoPromise: null
    }

    self.openApplicationInfo = function (focus) {
        self.promises.$openApplicationInfoPromise = $.Deferred();

        self.promises.$openApplicationInfoPromise.done(function () {
            self.applicationBladeManager.setUiFocus(focus);
            self.applicationBladeManager.setAndShowBlade(self.applicationBladeManager.blades.applicationInfoBlade,self.closeApplicationInfoBlade);
        });
    }

    self.openApplicationInfoBlade = function (focus) {
        // open blade for adding
        self.openApplicationInfo(focus);

        self.promises.$openApplicationInfoPromise.resolve("Done");
    }

    self.newApplicationCount =0;
    self.addApplication = function () {

        self.newApplicationCount++;
        self.application = new Application();
        self.application.id = self.newApplicationCount;

        // close existing info blade if open
        self.applicationBladeManager.closeBlade(self.applicationBladeManager.blades.applicationInfoBlade);

        self.openApplicationInfoBlade('add');
    }

    self.deleteApplication = async function () {
        self.applicationBladeManager.setUiFocus("delete");

        if (self.application) {
            try
            {
                if (self.application.applicationAreas)
                {
                    for(let i=0;i<self.application.applicationAreas.length;i++)
                    {
                        let area = await ajaxQuickAsync("DELETE",
                        null,
                        beasFunctionUrls.applicationAreas + "/" +self.application.applicationAreas[i].id);
                    }
                }

                let app = await ajaxQuickAsync("DELETE",
                null,
                beasFunctionUrls.application + "/" + ko.toJS(self.application).id);

                // reload grid
                await self.getApplications();
                
                self.applicationBladeManager.setUiFocus("search");
                self.applicationBladeManager.closeBlade(self.applicationBladeManager.blades.applicationInfoBlade);
            }
            catch(error) {
                blade.setLoading(false);
                blade.flashErrorMessage("Could not delete application.");
            }
        }
    }


    self.closeApplicationInfoBlade = async function () {
        var blade = self.applicationBladeManager.getBlade(self.applicationBladeManager.blades.applicationInfoBlade);

        if (blade) {
            if (self.applicationBladeManager.getUiFocus() === "add" && blade.hasChanged) {
                let data = JSON.stringify(ko.mapping.toJS(self.application), function (key, value) { if (key == "id" || key == "applicationAreas") return undefined; else return value; });

                try
                {
                    let app = await ajaxQuickAsync("POST",
                    data,
                    beasFunctionUrls.application);

                    // save app areas
                    if (self.application.applicationAreas)
                    {
                        await self.application.applicationAreas.forEach(async function (item) {
                            item.applicationId = app.id;
                            let area = await ajaxQuickAsync("POST",
                            JSON.stringify(item, function (key, value) { if (key == "id") return undefined; else return value; }),beasFunctionUrls.applicationAreas);

                        });
                    }

                    // refresh app
                    await self.getApplications();
                }
                catch(error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not save application.");
                }
            }
            else if (self.applicationBladeManager.getUiFocus() === "edit" && blade.hasChanged) {
                let data = JSON.stringify(ko.mapping.toJS(self.application), function (key, value) { if (key == "applicationAreas") return undefined; else return value; });
                try
                {
                    let app = await ajaxQuickAsync("PUT",
                    data,
                    beasFunctionUrls.application);

                    self.applications.replace(self.application, ko.toJS(app[0]));
                    bindGridData("BeasApplications", "#applicationsGrid", self.applications());
                }
                catch(error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not save application.");
                }
            }
            else if (self.applicationBladeManager.getUiFocus() === "edit") {
                try
                {
                    let result = await ajaxQuickAsync("GET",
                    null,
                    beasFunctionUrls.application + "/" + self.application.id);

                    self.applications.replace(self.application, ko.toJS(result[0]));
                    bindGridData("BeasApplications", "#applicationsGrid", self.applications());
                }
                catch(error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not refresh application.");
                }
            }


            self.applicationBladeManager.setUiFocus("search");
            self.applicationBladeManager.closeBlade(self.applicationBladeManager.blades.applicationInfoBlade);
        }

        clearGridSelection("#applicationsGrid");
    }

    self.selectedItemId = ko.observable(0);

    self.selectionChanged = function (evt, ui) {
        let rowData = ui.row;

        // find it in the array so we don't lose the observables
        var selectedItemInArray = ko.utils.arrayFirst(self.applications(), function (item) {
            return item.id === rowData.id;
        });

        if (selectedItemInArray != null) {

            self.application = selectedItemInArray;
            self.selectedItemId(parseInt(rowData.index));

            // if add already open close
            self.applicationBladeManager.closeBlade(self.applicationBladeManager.blades.applicationInfoBlade);

            // open blade for editing
            self.openApplicationInfo("edit");

            self.promises.$openApplicationInfoPromise.resolve("Done");
        }
        else {
            self.selectedItemId(0);
        }
    }

    self.getApplications = async function () {
        await retry(async function () {
            let result = await ajaxQuickAsync("GET",
                null,
                beasFunctionUrls.application);

            self.applications.removeAll();
            result.forEach(function (item) {
                self.applications.push(item);
            });

            bindGridData("BeasApplications", "#applicationsGrid", self.applications());

            blade.setLoading(false);
        }, 3, 4000, async function () {
            blade.setLoading(false);
            blade.flashErrorMessage("Could not load applications, if the problem persists please contact the Service Desk.");
        });
    }

    self.bindApplicationsGrid = function () {
        blade.content.find("#applicationsGrid")
            .igGrid({
                dataSource: self.applications(),
                width: 400,
                primaryKey: 'id',
                autoCommit: true,
                features: [
                    {
                        name: 'Filtering',
                        allowFiltering: true,
                        caseSensitive: false
                    },
                    {
                        name: 'Updating',
                        enableAddRow: false,
                        enableDeleteRow: false,
                        editMode: 'none',
                        columnSettings: [
                            {
                                columnKey: 'id',
                                readOnly: true
                            },
                            {
                                columnKey: 'name',
                                readOnly: true
                            }
                        ]
                    },
                    {
                        name: 'Selection',
                        mode: 'row',
                        multipleSelection: false,
                        activation: true,
                        rowSelectionChanged: applicationsVm.selectionChanged
                    },
                    {
                        name: 'Paging',
                        type: 'local',
                        pageSize: 15
                    },
                    {
                        name: 'Sorting',
                        columnSetting: [
                            {
                                columnIndex: 0,
                                allowSorting: true,
                                firstSortDirection: 'ascending',
                                currentSortDirection: 'descending'
                            }
                        ]
                    }
                ],
                autoGenerateColumns: false,
                columns: [
                    { headerText: 'ID', key: 'id', dataType: 'number', width: '80px', hidden: true },
                    { headerText: 'Name', key: 'name', dataType: 'string' }
                ]
            });
    }
}