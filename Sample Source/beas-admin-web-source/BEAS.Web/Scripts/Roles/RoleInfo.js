
var Role = function (data) {
    var self = this;
    self.name = (data ? ko.observable(data.name) : ko.observable());
    self.id = (data ? ko.observable(data.id) : ko.observable());
}

var RoleInfoViewModel = function (roleInfoConfig, blade) {
    var self = this;

    self.role = {
        name: ko.observable(),
        id: ko.observable(),
    };

    self.roleArea = {
        id: ko.observable(),
        name: ko.observable(),
        roleId: ko.observable()
    }

    self.blades = {
        roleInfoBlade: "BeasRoleInfo"
    }


    self.initialise = async function () {
        if (blade != null) {
            blade.setLoading(false);

            self.focus = blade.params.focus;

            self.role = rolesVm.role;

            // save button
            blade.modifyButton("SaveRole",
               self.saveForm,
                "/Content/images/icons/Save.png",
                "Save",
                true);

            if (self.focus === "edit")
                blade.modifyButton("DeleteRole",
                    showDeleteConfirmation,
                    "/Content/images/icons/Delete.png",
                    "Delete Role",
                    true);

            ko.applyBindings(roleInfoVm, blade.content.find("#divRoleInfoMain")[0]);

            self.bindValidation();
        }
    }

    self.saveForm = function () {
        // validate form
        if ($("#frmRoleInfo").igValidator("validate"))
            rolesVm.closeRoleInfoBlade();
    }

    self.uiManagement = {
        uiFocus: "search"
    }
 
    
    self.bindValidation = function () {
        blade.content.find("#frmRoleInfo").igValidator({
            fields: [
                {
                   required: true,
                   selector: "#txtName",
                   onblur: true,
                   custom: {
                       method: function (value, fieldOptions) {

                           var roles = rolesVm.roles().find(function (item)
                           { return (item.name === value && item.id !== ko.toJS(self.role).id); });

                           if (roles)
                               return false;
                           else
                               return true;
                       },
                       errorMessage: "The Role Name already exists."
                   }
                }
            ]
        })
    }

    const showDeleteConfirmation = function () {
        let deleteDialog = ".confirmDeleteRole";
        $(deleteDialog).text("Are you sure you want to delete this role?");

        $(deleteDialog).dialog({
            resizable: false,
            height: "auto",
            width: 500,
            modal: true,
            buttons: {
                "Yes": function () {
                    $(deleteDialog).dialog("close");
                    rolesVm.deleteRole();
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