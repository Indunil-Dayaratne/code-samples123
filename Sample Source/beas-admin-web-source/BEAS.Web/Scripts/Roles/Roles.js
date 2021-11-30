


var Role = function (data) {
    var self = this;
    this.name = (data ? ko.observable(data.name) : ko.observable());
    this.id = (data ? ko.observable(data.id) : ko.observable());
}

var RolesViewModel = function (rolesConfig, blade) {
    if(!blade)
        return;

    var self = this;

    self.openBlades = [];

    self.roleBladeManager = new BeasBladeManager(blade.path);

    self.blades = {
        openRoleInfoFlag: false,
        closeRoleInfoFlag: true,
        roleInfoBlade: "BeasRoleInfo"
    }

    self.roles = ko.observableArray([]);

    self.role = {
        id: ko.observable(),
        name: ko.observable(),
    }

    self.initialise = function () {

        blade.setLoading('Loading Roles');

        // close any open sub blades
        self.roleBladeManager.closeBlade( self.roleBladeManager.blades.roleInfoBlade);

        blade.modifyButton("AddRole", self.addRole, "/Content/images/icons/Add.png", "Add Role");

        // load Roles
        self.getRoles();

        ko.applyBindings(rolesVm, blade.content.find("#divRolesMain")[0]);

        self.bindRolesGrid();
    }

    self.uiManagement = {
        uiFocus: "search"
    }

    
    self.promises = {
        $openRoleInfoPromise: null
    }

    self.openRoleInfo = function (focus) {
        self.promises.$openRoleInfoPromise = $.Deferred();

        self.promises.$openRoleInfoPromise.done(function () {
            self.uiManagement.uiFocus = focus;
            self.blades.openRoleInfoFlag = true;

            let bladePath = blade.path + "/BeasRoleInfo(focus='" + focus + "')";

            page.show(bladePath);

            // add to array
            self.openBlades.push(self.blades.roleInfoBlade);

            if (bladeUI.getBladeByName(self.blades.roleInfoBlade)) {
                var roleBlade = bladeUI.getBladeByName(self.blades.roleInfoBlade);
                roleBlade.setCloseHandler(self.closeRoleInfoBlade)
            }
        });
    }

    self.openRoleInfoBlade = function (focus) {
        // open blade for adding
        self.openRoleInfo(focus);

        self.promises.$openRoleInfoPromise.resolve("Done");
    }

    self.addRole = function () {
        // define new role
        self.role = new Role({ id: -1 });

        // if add already open close
        self.roleBladeManager.closeBlade( self.roleBladeManager.blades.roleInfoBlade);

        self.openRoleInfoBlade('add');
    }

    self.deleteRole = async function () {
        self.uiManagement.uiFocus = "delete";

        if (self.role) {
            try {
                await ajaxQuickAsync("DELETE",
                    null,
                    beasFunctionUrls.role + "/" + ko.toJS(self.role).id);

                    await self.getRoles();

                self.uiManagement.uiFocus = "search";
                self.roleBladeManager.closeBlade( self.roleBladeManager.blades.roleInfoBlade);
            }
            catch (error) {
                blade.setLoading(false);
                blade.flashErrorMessage("Could not delete role.");
            }
        }
    }


    self.closeRoleInfoBlade = async function () {
        var blade = bladeUI.getBladeByName("BeasRoleInfo");

        if (blade) {
            if (self.uiManagement.uiFocus === "add" && blade.hasChanged) {
                let data = JSON.stringify(ko.mapping.toJS(self.role), function (key, value) { if (key == "id") return undefined; else return value; });
                try {
                    let result = await ajaxQuickAsync("POST",
                        data,
                        beasFunctionUrls.role);

                    // reload role and push to array
                    await self.getRoles();
                }
                catch (error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not save role.");
                }
            }
            else if (self.uiManagement.uiFocus === "edit" && blade.hasChanged) {
                let data = JSON.stringify(ko.mapping.toJS(self.role));
                try {
                    let result = await ajaxQuickAsync("PUT",
                        data,
                        beasFunctionUrls.role);

                    // reload role and push to array
                    ajaxQuick("GET", null, beasFunctionUrls.role + "/" + result.id, function (data) {
                        self.roles.replace(self.role, ko.toJS(data[0]));
                        bindGridData("BeasRoles", "#rolesGrid", self.roles());
                    }, function (xhr, ajaxOptions, thrownError) {
                        console.log(thrownError);
                    });
                }
                catch (error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not save role.");
                }
            }
            else if (self.uiManagement.uiFocus === "edit") {
                try {
                    let result = await ajaxQuickAsync("GET",
                        null,
                        beasFunctionUrls.role + "/" + self.role.id);

                    self.roles.replace(self.role, ko.toJS(result[0]));
                    bindGridData("BeasRoles", "#rolesGrid", self.roles());
                }
                catch (error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not refresh role.");
                }
            }

            self.uiManagement.uiFocus = "search";
            self.blades.openRoleInfoFlag = false;

            self.roleBladeManager.closeBlade( self.roleBladeManager.blades.roleInfoBlade);
        }

        clearGridSelection("#rolesGrid");
    }

    self.selectedItemId = ko.observable(0);

    self.selectionChanged = function (evt, ui) {
        let rowData = ui.row;

        // find it in the array so we don't lose the observables
        var selectedItemInArray = ko.utils.arrayFirst(self.roles(), function (item) {
            return item.id === rowData.id;
        });

        if (selectedItemInArray != null) {

            self.role = selectedItemInArray;
            self.selectedItemId(parseInt(rowData.index));

            // if add already open close
            self.roleBladeManager.closeBlade( self.roleBladeManager.blades.roleInfoBlade);

            // open blade for editing
            self.openRoleInfo("edit");

            self.promises.$openRoleInfoPromise.resolve("Done");
        }
        else {
            self.selectedItemId(0);
        }
    }

    self.getRoles = async function () {
        await retry(async function () {
            let result = await ajaxQuickAsync("GET",
                null,
                beasFunctionUrls.role);

            self.roles.removeAll();
            result.forEach(function (item) {
                self.roles.push(item);
            });

            bindGridData("BeasRoles", "#rolesGrid", self.roles());

            blade.setLoading(false);
        }, 3, 4000, async function () {
            blade.setLoading(false);
            blade.flashErrorMessage("Could not load roles, if the problem persists please contact the Service Desk.");
        });
    }

    self.bindRolesGrid = function () {
        blade.content.find("#rolesGrid")
            .igGrid({
                dataSource: self.roles(),
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
                        rowSelectionChanged: rolesVm.selectionChanged
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