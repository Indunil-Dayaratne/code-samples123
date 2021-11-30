
var User = function (data) {
    var self = this;
    this.adName = (data ? ko.observable(data.adName) : ko.observable());
    this.id = (data ? ko.observable(data.id) : ko.observable());
    this.displayName = (data ? ko.observable(data.displayName) : ko.observable());
    this.emailAddress = (data ? ko.observable(data.emailAddress) : ko.observable());
    self.userApplicationAreaRoles = (data ? data.userApplicationAreaRoles : []);
}

var UsersViewModel = function (usersConfig, blade) {
    if(!blade)
        return;
    var self = this;

    self.userBladeManager = new BeasBladeManager(blade.path);

    self.users = ko.observableArray([]);

    self.user = {
        adName: ko.observable(),
        id: ko.observable(),
        displayName: ko.observable(),
        emailAddress: ko.observable(),
        userApplicationAreaRoles: []
    }

    self.initialise = function () {
        blade.setLoading('Loading Users');

        // close any open sub blades
        self.userBladeManager.closeBlade(self.userBladeManager.blades.userInfoBlade);
        self.userBladeManager.closeBlade(self.userBladeManager.blades.userRoleInfoBlade);

        blade.modifyButton("AddUser", self.addUser, "/Content/images/icons/Add.png", "Add User");

        // load Users
        self.getUsers();

        ko.applyBindings(usersVm, blade.content.find("#divUsersMain")[0]);

        self.bindUsersGrid();
    }

    self.promises = {
        $openUserInfoPromise: null
    }

    self.openUserInfo = function (focus) {
        self.promises.$openUserInfoPromise = $.Deferred();

        self.promises.$openUserInfoPromise.done(function () {
            self.userBladeManager.setUiFocus(focus);
            self.userBladeManager.setAndShowBlade(self.userBladeManager.blades.userInfoBlade,self.closeUserInfoBlade);
        });
    }
    self.openUserInfoBlade = function (focus) {
        // open blade for adding
        self.openUserInfo(focus);

        self.promises.$openUserInfoPromise.resolve("Done");
    }

    self.getUsers = async function () {
        await retry(async function () {
            let result = await ajaxQuickAsync("GET",
                null,
                beasFunctionUrls.user);

            self.users.removeAll();
            result.forEach(function (item) {
                self.users.push(item);
            });

            bindGridData("BeasUsers", "#usersGrid", self.users());

            blade.setLoading(false);
        }, 3, 4000, async function () {
            blade.setLoading(false);
            blade.flashErrorMessage("Could not load users, if the problem persists please contact the Service Desk.");
        });
    }

    self.addUser = function () {
        // define new role
        self.user = new User({ id: -1 });

        // if add already open close
        self.userBladeManager.closeBlade(self.userBladeManager.blades.userInfoBlade);

        self.openUserInfoBlade('add');
    }

    self.deleteUser = async function () {
        self.userBladeManager.setUiFocus("delete");

        if (self.user) {
            // save user area roles to new user
            try {
                if (self.user.userApplicationAreaRoles) {
                    for(let i=0;i<self.user.userApplicationAreaRoles.length;i++)
                    {
                        await ajaxQuickAsync("DELETE",
                        null,
                        beasFunctionUrls.userApplicationRole + "/" + self.user.userApplicationAreaRoles[i].id);
                    }
                }

                let deletedUser = await ajaxQuickAsync("DELETE",
                    null,
                    beasFunctionUrls.user + "/" + ko.toJS(self.user).id);

                // reload users
                await self.getUsers();

                self.userBladeManager.setUiFocus("search");
                self.userBladeManager.closeBlade(self.userBladeManager.blades.userInfoBlade);
            }
            catch (error) {
                blade.setLoading(false);
                blade.flashErrorMessage("Could not delete user");
            }
        }
    }


    self.closeUserInfoBlade = async function () {
        var blade = self.userBladeManager.getBlade(self.userBladeManager.blades.userInfoBlade);

        if (blade) {
            if (self.userBladeManager.getUiFocus() === "add" && blade.hasChanged) {
                let data = JSON.stringify(ko.mapping.toJS(self.user), function (key, value) { if (key == "id" || key == "userApplicationAreaRoles") return undefined; else return value; });
                try {

                    // save user
                    let user = await ajaxQuickAsync("POST",
                        data,
                        beasFunctionUrls.user);

                    // save user area roles
                    if (self.user.userApplicationAreaRoles) {
                        for(let i=0;i<self.user.userApplicationAreaRoles.length;i++) {
                            self.user.userApplicationAreaRoles[i].userId = user.id;

                            let uar = await ajaxQuickAsync("POST",
                                JSON.stringify(self.user.userApplicationAreaRoles[i], function (key, value) { if (key == "id") return undefined; else return value; }),
                                beasFunctionUrls.userApplicationRole);
                        }

                    }

                     // reload users
                    await self.getUsers();

                }
                catch (error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not save user, if the problem persists please contact the Service Desk.");
                }
            }
            else if (self.userBladeManager.getUiFocus() === "edit" && blade.hasChanged) {
                let data = JSON.stringify(ko.mapping.toJS(self.user), function (key, value) { if (key == "userApplicationAreaRoles") return undefined; else return value; });
                try {
                    let user = await ajaxQuickAsync("PUT",
                        data,
                        beasFunctionUrls.user);

                    let refreshedUser = await ajaxQuickAsync("GET",
                        null,
                        beasFunctionUrls.user + "/" + user.id);

                    self.users.replace(self.user, ko.toJS(refreshedUser[0]));
                    bindGridData("BeasUsers", "#usersGrid", self.users());
                }
                catch (error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not save user");
                }
            }
            else if (self.userBladeManager.getUiFocus() === "edit") {
                try {
                    let users = await ajaxQuickAsync("GET",
                        null,
                        beasFunctionUrls.user + "/" + self.user.id);

                    self.users.replace(self.user, ko.toJS(users[0]));
                    bindGridData("BeasUsers", "#usersGrid", self.users());
                }
                catch (error) {
                    blade.setLoading(false);
                    blade.flashErrorMessage("Could not refresh user");
                }
            }

            self.userBladeManager.setUiFocus("search");
            self.userBladeManager.closeBlade(self.userBladeManager.blades.userInfoBlade);
        }

        clearGridSelection("#usersGrid");
    }

    self.selectedItemId = ko.observable(0);

    self.selectionChanged = function (evt, ui) {
        let rowData = ui.row;

        // find it in the array so we don't lose the observables
        var selectedItemInArray = ko.utils.arrayFirst(self.users(), function (item) {
            return item.id === rowData.id;
        });

        if (selectedItemInArray != null) {

            self.user = selectedItemInArray;
            self.selectedItemId(parseInt(rowData.index));

            // if add already open close
            self.userBladeManager.closeBlade(self.userBladeManager.blades.userInfoBlade);

            // open blade for editing
            self.openUserInfo("edit");

            self.promises.$openUserInfoPromise.resolve("Done");
        }
        else {
            self.selectedItemId(0);
        }
    }

    self.bindUsersGrid = function () {
        blade.content.find("#usersGrid")
            .igGrid({
                dataSource: self.users(),
                width: 700,
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
                                columnKey: 'adName',
                                readOnly: true
                            },
                            {
                                columnKey: 'displayName',
                                readOnly: true
                            },
                            {
                                columnKey: 'emailAddress',
                                readOnly: true
                            },
                        ]
                    },
                    {
                        name: 'Selection',
                        mode: 'row',
                        multipleSelection: false,
                        activation: true,
                        rowSelectionChanged: usersVm.selectionChanged
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
                    { headerText: 'AD Name', key: 'adName', dataType: 'string' },
                    { headerText: 'Display Name', key: 'displayName', dataType: 'string' },
                    { headerText: 'Email Address', key: 'emailAddress', dataType: 'string' }
                ]
            });
    }
}