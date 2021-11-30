

var ApplicationArea = function (data) {
    var self = this;
    self.id = (data ? ko.observable(data.id) : ko.observable());
    self.name = (data ? ko.observable(data.name) : ko.observable());
    self.applicationId = (data ? ko.observable(data.applicationId) : ko.observable());
}

var Application = function (data) {
    var self = this;
    self.name = (data ? ko.observable(data.name) : ko.observable());
    self.id = (data ? ko.observable(data.name) : ko.observable());
    self.applicationAreas = (data ? data.applicationAreas :[]);
}

var ApplicationInfoViewModel = function (applicationInfoConfig, blade) {
    var self = this;

    self.areaInfoBeasBladeManager = new BeasBladeManager(blade.path);

    self.application = {
        name: ko.observable(),
        id: ko.observable(),
        applicationAreas: []
    };

    self.applicationArea = {
        id: ko.observable(),
        name: ko.observable(),
        applicationId: ko.observable()
    }

    self.promises = {
        $openApplicationAreaInfoPromise: null
    }

    self.initialise = async function () {
        if (blade != null) {
            // close subblade if left open
            self.areaInfoBeasBladeManager.closeBlade( self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade);

            blade.setLoading(false);

            self.focus = blade.params.focus;

            self.application = applicationsVm.application;

            // save button
            blade.modifyButton("SaveApplication",
               self.saveForm,
                "/Content/images/icons/Save.png",
                "Save",
                true);

            // save button
            blade.modifyButton("AddArea",
                self.addArea,
                "/Content/images/icons/Add.png",
                "Add Application Area",
                true);

            if (self.focus === "edit")
                blade.modifyButton("DeleteApplication",
                    showDeleteConfirmation,
                    "/Content/images/icons/Delete.png",
                    "Delete Application",
                    true);

            ko.applyBindings(applicationInfoVm, blade.content.find("#divApplicationInfoMain")[0]);

            self.bindApplicationAreaGrid();
            self.bindValidation();
        }
    }

    

    self.saveForm = function () {
        // validate form
        //if ($("#frmApplicationInfo").igValidator("validate"))
            applicationsVm.closeApplicationInfoBlade();
    }

    self.openApplicationAreaInfoBlade = function (focus) {
        // open blade for adding
        self.openApplicationAreaInfo(focus);

        self.promises.$openApplicationAreaInfoPromise.resolve("Done");
    }

    self.deleteApplicationArea = async function() {
        self.areaInfoBeasBladeManager.setUiFocus("delete");

        if (self.applicationArea) {
            if (ko.toJS(self.application).id <0) {
                let index = self.application.applicationAreas.findIndex(function(item) { return item.id === ko.toJS(self.applicationArea).id});
                self.application.applicationAreas.splice(index, 1);

                self.updateGridData();
                self.areaInfoBeasBladeManager.closeBlade( self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade);

            }
            else
            {
                try
                {
                    let area = await ajaxQuickAsync("DELETE",
                    null,
                    beasFunctionUrls.applicationAreas + "/" + ko.toJS(self.applicationArea).id);

                    self.areaInfoBeasBladeManager.setUiFocus("search");

                    let index = self.application.applicationAreas.findIndex(function(item) { return item.id === ko.toJS(self.applicationArea).id;});

                    self.application.applicationAreas.splice(index, 1);

                    self.updateGridData();
                    self.areaInfoBeasBladeManager.closeBlade( self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade);

                }
                catch(error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not delete application area.");
                }
            }
        }
    }

    self.newApplicationInfoCount =0;
    self.addArea = function () {
        self.newApplicationInfoCount++;

        self.applicationArea = new ApplicationArea({ applicationId: self.application.id, id: (self.newApplicationInfoCount*-1) });

        // close existing if open
        self.areaInfoBeasBladeManager.closeBlade( self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade);

        // open blade for adding
        self.openApplicationAreaInfoBlade("add");
    }

    self.openApplicationAreaInfo = function (focus) {
        self.promises.$openApplicationAreaInfoPromise = $.Deferred();

        self.promises.$openApplicationAreaInfoPromise.done(function () {
            self.areaInfoBeasBladeManager.setUiFocus(focus);
            self.areaInfoBeasBladeManager.setAndShowBlade(self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade,self.closeApplicationAreaInfoBlade);
        });
    }

    self.updateGridData = function () {
        bindGridData(self.areaInfoBeasBladeManager.blades.applicationInfoBlade, "#applicationAreasGrid", self.application.applicationAreas);
    }

    self.closeApplicationAreaInfoBlade = async function () {
        var blade = bladeUI.getBladeByName(self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade);

        if (blade) {
            // only post if the application has already been created
            if (ko.toJS(self.application).id <0) {
                if (self.application.applicationAreas === undefined)
                    self.application.applicationAreas = [];

                if (self.areaInfoBeasBladeManager.getUiFocus()=== "add") {
                    self.application.applicationAreas.push(ko.toJS(self.applicationArea));
                }
                else if (self.areaInfoBeasBladeManager.getUiFocus()=== "edit") {

                    let index = self.application.applicationAreas.findIndex(function (x) { return x.id === ko.toJS(self.applicationArea).id; });

                    self.application.applicationAreas[index] = ko.toJS(self.applicationArea);
                }

                self.updateGridData();
            }
            else {
                if (self.areaInfoBeasBladeManager.getUiFocus()=== "add") {
                    let data = JSON.stringify(ko.mapping.toJS(self.applicationArea), function (key, value) { if (key == "id") return undefined; else return value; });
                    try
                    {
                        let area = await ajaxQuickAsync("POST",
                        data,
                        beasFunctionUrls.applicationAreas);

                        self.application.applicationAreas.push(ko.toJS(area));
                        self.updateGridData()
                    }
                    catch(error) {
                        blade.setLoading(false);
                        blade.flashErrorMessage("Could not save application area.");
                    }
                }
                else if (self.areaInfoBeasBladeManager.getUiFocus()=== "edit") {
                    let data = JSON.stringify(ko.mapping.toJS(self.applicationArea));
                    try
                    {
                        let area = await ajaxQuickAsync("PUT",
                        data,
                        beasFunctionUrls.applicationAreas);

                        let index = self.application.applicationAreas.findIndex(function (item) { return item.id === area.id });
                            self.application.applicationAreas[index] = area;

                            self.updateGridData()
                    }
                    catch(error) {
                        blade.setLoading(false);
                        blade.flashErrorMessage("Could not save application area.");
                    }
                }
            }

            self.areaInfoBeasBladeManager.setUiFocus("search");
            self.areaInfoBeasBladeManager.closeBlade( self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade);
        }

        clearGridSelection("#applicationAreasGrid");
    }

    self.selectedItemId = ko.observable(0);
    
    self.selectionChanged = function (evt, ui) {

        let rowData = ui.row;

        // find it in the array so we don't lose the observables
        var selectedItemInArray = ko.utils.arrayFirst(self.application.applicationAreas, function (item) {
            return item.id === rowData.id;
        });

        if (selectedItemInArray != null) {
            self.applicationArea = selectedItemInArray;

            self.selectedItemId(parseInt(rowData.index));

            self.areaInfoBeasBladeManager.closeBlade( self.areaInfoBeasBladeManager.blades.applicationAreaInfoBlade);

            self.openApplicationAreaInfo("edit");

            self.promises.$openApplicationAreaInfoPromise.resolve("Done");
        }
        else {
            self.selectedItemId(0);
        }
    }


    self.bindValidation = function () {
        //blade.content.find("#frmApplicationInfo").igValidator({
        //    fields: [
        //        {
        //           required: true,
        //           selector: "#txtName",
        //           onblur: true,
        //           //custom: {
        //           //    method: function (value, fieldOptions) {
        //           //        var applications = applicationsVm.applications().find(function (item)
        //           //        { 
        //           //            return (item.name === value && item.id !== ko.toJS(self.application).id); 
        //           //         });

        //           //        if (applications)
        //           //            return false;
        //           //        else
        //           //            return true;
        //           //    },
        //           //    errorMessage: "The Application Name already exists."
        //           //}
        //        }
        //    ]
        //})
    }

    self.bindApplicationAreaGrid = function () {
        blade.content.find("#applicationAreasGrid")
            .igGrid({
                dataSource: self.application.applicationAreas,
                width: 500,
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
                            }
                        ]
                    },
                    {
                        name: 'Selection',
                        mode: 'row',
                        multipleSelection: false,
                        activation: true,
                        rowSelectionChanged: applicationInfoVm.selectionChanged

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

    const showDeleteConfirmation = function () {
        let deleteDialog = ".confirmDeleteApplication";
        $(deleteDialog).text("Are you sure you want to delete this application?");

        $(deleteDialog).dialog({
            resizable: false,
            height: "auto",
            width: 500,
            modal: true,
            buttons: {
                "Yes": function () {
                    $(deleteDialog).dialog("close");
                    applicationsVm.deleteApplication();
                },
                "No": function () {
                    $(deleteDialog).dialog("close");
                }
            },
            open: function () {
                $(".ui-widget-overlay").css("background", "black");
            },
            close: function () {
                $(deleteDialog).text("");
                $(deleteDialog).dialog("close");
            }
        });
    }
}