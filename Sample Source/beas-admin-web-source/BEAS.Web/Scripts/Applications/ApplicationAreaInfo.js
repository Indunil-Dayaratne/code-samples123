var ApplicationAreaInfoViewModel = function (applicationAreaInfoConfig, blade) {
    var self = this;

    self.applicationArea = {
        applicationId: ko.observable(),
        name: ko.observable(),
        id: ko.observable()
    };

    self.initialise = function() {
        blade.setLoading(false);

        self.focus = blade.params.focus;

        // main instance of object
        self.applicationArea = applicationInfoVm.applicationArea;

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

        ko.applyBindings(applicationAreaInfoVm, blade.content.find("#divApplicationAreaInfoMain")[0]);
        self.bindValidation();
    }

    self.saveForm = function () {
        if ($("#frmApplicationAreaInfo").igValidator("validate"))
            applicationInfoVm.closeApplicationAreaInfoBlade();
    }

    self.bindValidation = function () {
        blade.content.find("#frmApplicationAreaInfo").igValidator({
            fields: [
                {
                    required: true,
                    selector: "#txtName",
                    onblur: true
                }
            ]
        })
    }

    const showDeleteAreaRoleConfirmation = function () {
        let deleteDialog = ".confirmDeleteApplicationArea";
        $(deleteDialog).text("Are you sure you want to delete this application area?");

        $(deleteDialog).dialog({
            resizable: false,
            height: "auto",
            width: 500,
            modal: true,
            buttons: {
                "Yes": function () {
                    $(deleteDialog).dialog("close");
                    applicationInfoVm.deleteApplicationArea();
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