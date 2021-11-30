

var UserApplicationAreaRole = function (data) {
    var self = this;
    self.id = (data ? ko.observable(data.id) : ko.observable());
    self.userId = (data ? ko.observable(data.userId) : ko.observable());
    self.roleId = (data ? ko.observable(data.roleId) : ko.observable());
    self.applicationAreaId = (data ? ko.observable(data.applicationAreaId) : ko.observable());
}

var User = function (data) {
    var self = this;
    self.adName = (data ? ko.observable(data.adName) : ko.observable());
    self.id = (data ? ko.observable(data.id) : ko.observable());
    self.displayName = (data ? ko.observable(data.displayName) : ko.observable());
    self.emailAddress = (data ? ko.observable(data.emailAddress) : ko.observable());
    self.userApplicationAreaRoles = (data ? data.userApplicationAreaRoles :[]);
}

var UserInfoViewModel = function (userInfoConfig, blade) {
    var self = this;

    self.userInfoBladeManager = new BeasBladeManager(blade.path);

    self.user = {
        name: ko.observable(),
        id: ko.observable(),
        userApplicationAreaRoles: []
    };

    self.userApplicationAreaRole = {
        id: ko.observable(),
        roleId: ko.observable(),
        userId: ko.observable(),
        applicationAreaId: ko.observable(),
    }

    self.roles = [];
    self.applicationAreas = [];
    self.applications = [];

    self.promises = {
        $openUserRoleInfoPromise: null
    }

    self.loadLookups = async function () {
        try {
            let roles = await ajaxQuickAsync("GET",
                null,
                beasFunctionUrls.role);

            if (roles)
                roles.forEach(function (item) { self.roles.push(item); });
        }
        catch (error) {
            blade.setLoading(false);
            blade.flashErrorMessage("Could not load roles.");
        }

        try {
            let applications = await ajaxQuickAsync("GET",
                null,
                beasFunctionUrls.application);

            if (applications) {
                applications.forEach(function (item) { self.applications.push(item); });

                self.applications.forEach(function (item) {
                    item.applicationAreas.forEach(function (aa) {

                        aa["nameWithAppName"] = item.name + "->" + aa.name;

                        self.applicationAreas.push(aa);
                    })
                });
            } 
        }
        catch (error) {
            blade.setLoading(false);
            blade.flashErrorMessage("Could not load application areas.");
        }
    }

    self.lookupDisplayValue = function (type, id) {
        var lookupItem = null;

        if (type === "role") {
            let item = self.roles.find(function (item) { return item.id == id; });

            lookupItem = item.name;
        }
        else if (type === "applicationArea") {
            let appArea = self.applicationAreas.find(function (item) { return item.id == id; });
            let application = self.applications.find(function (item) { return item.id == appArea.applicationId; });

            lookupItem = application.name + "->" + appArea.name;
        }

        return lookupItem;
    }

    self.initialise = async function () {
        if (blade != null) {
            self.userInfoBladeManager.closeBlade(self.userInfoBladeManager.blades.userRoleInfoBlade);

            blade.setLoading(false);

            self.focus = blade.params.focus;

            self.user = usersVm.user;

            await self.loadLookups();

            // save button
            blade.modifyButton("SaveUser",
               self.saveForm,
                "/Content/images/icons/Save.png",
                "Save",
                true);

            // save button
            blade.modifyButton("AddAreaRole",
                self.addAreaRole,
                "/Content/images/icons/Add.png",
                "Add Application Area Role",
                true);

            if (self.focus === "edit")
                blade.modifyButton("DeleteUser",
                    showDeleteConfirmation,
                    "/Content/images/icons/Delete.png",
                    "Delete User",
                    true);

            ko.applyBindings(userInfoVm, blade.content.find("#divUserInfoMain")[0]);

            self.bindApplicationAreaGrid();
            self.bindValidation();
        }
    }

    

    self.saveForm = function () {
        // validate form
        if ($("#frmUserInfo").igValidator("validate"))
            usersVm.closeUserInfoBlade();
    }

    self.openUserRoleInfoBlade = function (focus) {
        // open blade for adding
        self.openUserRoleInfo(focus);

        self.promises.$openUserRoleInfoPromise.resolve("Done");
    }

    self.deleteApplicationAreaRole = async function() {
        self.userInfoBladeManager.setUiFocus("delete");

        if (self.userApplicationAreaRole) {
            if (ko.toJS(self.user).id === -1) {
                let index = self.user.userApplicationAreaRoles.findIndex(function(item) { return item.id === ko.toJS(self.userApplicationAreaRole).id});
                self.user.userApplicationAreaRoles.splice(index, 1);

                self.updateGridData();
                self.userInfoBladeManager.closeBlade(self.userInfoBladeManager.blades.userRoleInfoBlade);
            }
            else
            {
                try
                {
                    let area = await ajaxQuickAsync("DELETE",
                    null,
                    beasFunctionUrls.userApplicationRole + "/" + ko.toJS(self.userApplicationAreaRole).id);
                    self.userInfoBladeManager.setUiFocus("search");

                    let index = self.user.userApplicationAreaRoles.findIndex(function(item) { return item.id === ko.toJS(self.userApplicationAreaRole).id;
                });

                    self.user.userApplicationAreaRoles.splice(index, 1);

                    self.updateGridData();
                    self.userInfoBladeManager.closeBlade(self.userInfoBladeManager.blades.userRoleInfoBlade);
                }
                catch(error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not delete user application role.");
                }
            }
        }
    }

    self.newUserInfoCount =0;
    self.addAreaRole = function () {
        self.newUserInfoCount++;

        self.userApplicationAreaRole = new UserApplicationAreaRole({ userId: self.user.id, id: (self.newUserInfoCount*-1) });

        // close existing if open
        self.userInfoBladeManager.closeBlade(self.userInfoBladeManager.blades.userRoleInfoBlade);

        // open blade for adding
        self.openUserRoleInfoBlade("add");
    }

    self.openUserRoleInfo = function (focus) {
        self.promises.$openUserRoleInfoPromise = $.Deferred();

        self.promises.$openUserRoleInfoPromise.done(function () {
            self.userInfoBladeManager.setUiFocus(focus);
            self.userInfoBladeManager.setAndShowBlade(self.userInfoBladeManager.blades.userRoleInfoBlade,self.closeUserRoleInfoBlade);
        });
    }

    self.updateGridData = function () {
        bindGridData(self.userInfoBladeManager.blades.userInfoBlade, "#userApplicationAreaRolesGrid", self.user.userApplicationAreaRoles);
    }

    self.closeUserRoleInfoBlade = async function () {
        var blade = bladeUI.getBladeByName(self.userInfoBladeManager.blades.userRoleInfoBlade);

        if (blade) {
            // only post if the user has already been created
            if (ko.toJS(self.user).id === -1) {
                if (self.user.userApplicationAreaRoles === undefined)
                    self.user.userApplicationAreaRoles = [];

                if (self.userInfoBladeManager.getUiFocus()=== "add") {
                    self.user.userApplicationAreaRoles.push(ko.toJS(self.userApplicationAreaRole));
                }
                else if (self.userInfoBladeManager.getUiFocus() === "edit") {
                    self.user.userApplicationAreaRoles.replace(self.userApplicationAreaRole, self.userApplicationAreaRole);
                }

                self.updateGridData();
            }
            else {
                if (self.userInfoBladeManager.getUiFocus() === "add") {
                    let data = JSON.stringify(ko.mapping.toJS(self.userApplicationAreaRole), function (key, value) { if (key == "id") return undefined; else return value; });
                    await ajaxQuick("POST",
                        data,
                        beasFunctionUrls.userApplicationRole,
                        function (data) {
                            self.user.userApplicationAreaRoles.push(ko.toJS(data));
                            self.updateGridData()
                        },
                        function (xhr, ajaxOptions, thrownError) {
                            blade.setLoading(false);
                            blade.flashErrorMessage("Could not save user application area role, if the problem persists please contact the Service Desk.");
                        }
                    );
                }
                else if (self.userInfoBladeManager.getUiFocus() === "edit") {
                    let data = JSON.stringify(ko.mapping.toJS(self.userApplicationAreaRole));
                    await ajaxQuick("PUT",
                        data,
                        beasFunctionUrls.userApplicationRole,
                        function (data) {
                            let index = self.user.userApplicationAreaRoles.findIndex(function (item) { return item.id === data.id });
                            self.user.userApplicationAreaRoles[index] = data;

                            self.updateGridData()
                        },
                        function (xhr, ajaxOptions, thrownError) {
                            blade.setLoading(false);
                            blade.flashErrorMessage("Could not user application area role, if the problem persists please contact the Service Desk."); blade.setLoading(false);
                        }
                    );
                }
            }

           
            self.userInfoBladeManager.setUiFocus("search");
            self.userInfoBladeManager.closeBlade(self.userInfoBladeManager.blades.userRoleInfoBlade);
        }

        clearGridSelection("#userApplicationAreaRolesGrid");
    }

    self.selectedItemId = ko.observable(0);
    
    self.selectionChanged = function (evt, ui) {

        let rowData = ui.row;

        // find it in the array so we don't lose the observables
        var selectedItemInArray = ko.utils.arrayFirst(self.user.userApplicationAreaRoles, function (item) {
            return item.id === rowData.id;
        });

        if (selectedItemInArray != null) {
            self.userApplicationAreaRole = selectedItemInArray;

            self.selectedItemId(parseInt(rowData.index));

            self.userInfoBladeManager.closeBlade(self.userInfoBladeManager.blades.userRoleInfoBlade);
            self.openUserRoleInfo("edit");

            self.promises.$openUserRoleInfoPromise.resolve("Done");
        }
        else {
            self.selectedItemId(0);
        }
    }


    self.bindValidation = function () {
        blade.content.find("#frmUserInfo").igValidator({
            fields: [
                {
                    required: true,
                    selector: "#txtName",
                    onblur: true,
                    custom: {
                        method: function (value, fieldOptions) {

                            var users = usersVm.users().find(function (item)
                            { return (item.adName === value && item.id !== ko.toJS(self.user).id); });

                            if (users)
                                return false;
                            else
                                return true;
                        },
                        errorMessage: "The AD Name already exists."
                    }
                },
                {
                    required: true,
                    selector: "#txtDisplayName",
                    onblur: true
                },
                {
                    required: true,
                    selector: "#txtEmailAddress",
                    onblur: true,
                    email: true
                }
            ]
        })
    }

    self.bindApplicationAreaGrid = function () {
        blade.content.find("#userApplicationAreaRolesGrid")
            .igGrid({
                dataSource: self.user.userApplicationAreaRoles,
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
                        rowSelectionChanged: userInfoVm.selectionChanged

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
                    { headerText: 'Role', key: 'roleId', dataType: 'string', formatter: function (val, record) { return self.lookupDisplayValue('role', val); } },
                    { headerText: 'Application Area', key: 'applicationAreaId', dataType: 'string', formatter: function (val, record) { return self.lookupDisplayValue('applicationArea', val); } },
                ]
            });
    }

    const showDeleteConfirmation = function () {
        let deleteDialog = ".confirmDeleteUser";
        $(deleteDialog).text("Are you sure you want to delete this user?");

        $(deleteDialog).dialog({
            resizable: false,
            height: "auto",
            width: 500,
            modal: true,
            buttons: {
                "Yes": function () {
                    $(deleteDialog).dialog("close");
                    usersVm.deleteUser();
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