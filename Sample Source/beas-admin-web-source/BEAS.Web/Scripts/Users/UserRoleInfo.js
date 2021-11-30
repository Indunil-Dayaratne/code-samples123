var UserRoleInfoViewModel = function (userRoleInfoConfig, blade) {
    var self = this;

    self.userApplicationAreaRole = {
        roleId: ko.observable(),
        applicationAreaId: ko.observable(),
        userId: ko.observable(),
        id: ko.observable()
    };

    self.initialise = function() {
        blade.setLoading(false);

        self.focus = blade.params.focus;

        // main instance of object
        self.userApplicationAreaRole = userInfoVm.userApplicationAreaRole;

        // save button
        blade.modifyButton("Save",
            self.saveForm,
            "/Content/images/icons/Save.png",
            "Save",
            true);

        if (self.focus === "edit")
            blade.modifyButton("DeleteAreaRole",
                showDeleteAreaRoleConfirmation,
                "/Content/images/icons/Delete.png",
                "Delete Application Area Role",
                true);

        ko.applyBindings(userRoleInfoVm, blade.content.find("#divUserRoleInfoMain")[0]);
        self.bindValidation();
    }

    self.saveForm = function () {
        if ($("#frmUserRoleInfo").igValidator("validate"))
            userInfoVm.closeUserRoleInfoBlade();
    }

    self.bindValidation = function () {
        blade.content.find("#frmUserRoleInfo").igValidator({
            fields: [
                {
                    required: true,
                    selector: "#selRole",
                    onblur: true
                },
                {
                    required: true,
                    selector: "#selApplicationArea",
                    onblur: true
                }
            ]
        })
    }

    const showDeleteAreaRoleConfirmation = function () {
        let deleteDialog = ".confirmDeleteAreaRole";
        $(deleteDialog).text("Are you sure you want to delete this application area role?");

        $(deleteDialog).dialog({
            resizable: false,
            height: "auto",
            width: 500,
            modal: true,
            buttons: {
                "Yes": function () {
                    $(deleteDialog).dialog("close");
                    userInfoVm.deleteApplicationAreaRole();
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