var riskEntrySheet = riskEntrySheet || {};

riskEntrySheet.utils = function () {

    var systems = ["BUAA_Request", "Britflow_TPU", "CDP_CDP", "Britflow_CMT", "EPeer_Program", "DWF_Batch", "Britflow_Query", "Ignis_Enquiry", "Britflow_PRC", "Britflow_Referral"];

    var NONE = 0;
    var GREEN = 1;
    var BLUE = 2;
    var AMBER = 3;
    var RED = 4;
    var GRAY = 5;

    var colours = {
        0: "",
        1: "green",
        2: "blue",
        3: "amber",
        4: "red",
        5: "gray"
    }

    function azureAjax(options) {

        var promise = $.Deferred();

        acquireMsalSilentToken(options.clientId, [options.scope]).then(function (access_token) {
            $.ajax({
                type: options.type,
                crossDomain: true,
                contentType: "application/json; charset=utf-8",
                url: options.url,
                dataType: "json",
                data: JSON.stringify(options.data),
                xhrFields: {
                    withCredentials: false
                },
                headers: {
                    'Authorization': 'Bearer ' + access_token
                },
                success: function (data) {
                    if (options.success) {
                        options.success(data);
                    }
                    promise.resolve(data);
                },
                error: function () {
                    if (options.error) {
                        options.error();
                    }
                    promise.resolve();
                }
            });
        });

        return promise;
    }


    function azureAjaxWithToken(options) {

        var promise = $.Deferred();
        $.ajax({
                type: options.type,
                crossDomain: true,
                contentType: "application/json; charset=utf-8",
                url: options.url,
                dataType: "json",
                data: JSON.stringify(options.data),
                xhrFields: {
                    withCredentials: false
                },
                headers: {
                    'Authorization': 'Bearer ' + options.access_token
                },
                success: function (data) {
                    if (options.success) {
                        options.success(data);
                    }
                    promise.resolve(data);
                },
                error: function () {
                    if (options.error) {
                        options.error();
                    }
                    promise.resolve();
                }
            });
        return promise;
    }

    return {
        azureAjax: azureAjax,
        azureAjaxWithToken: azureAjaxWithToken,
        compareValues: compareValues,
        setStatusColour: setStatusColour,
        setQueryStatusColour: setQueryStatusColour,
        setReferralStatusColour: setReferralStatusColour,
        setBUAAStatusColour: setBUAAStatusColour,
        setCDPStatusColour: setCDPStatusColour
    };

    function compareValues(key, order = 'asc') {
        return function innerSort(a, b) {
            if (!a.hasOwnProperty(key) || !b.hasOwnProperty(key)) {
                // property doesn't exist on either object
                return 0;
            }
            const varA = (typeof a[key] === 'string')
                ? a[key].toUpperCase() : a[key];
            const varB = (typeof b[key] === 'string')
                ? b[key].toUpperCase() : b[key];

            let comparison = 0;
            if (varA > varB) {
                comparison = 1;
            } else if (varA < varB) {
                comparison = -1;
            }
            return (
                (order === 'desc') ? (comparison * -1) : comparison
            );
        };
    }

    function setCDPStatusColour(serviceInfo, statusProperty, assignedToProperty) {
        var colour = serviceInfo.items.length > 0 ? AMBER : NONE;

        serviceInfo.items.some(function (item) {
            var status = item[statusProperty]
            var isItemOpen = (status !== "Completed by Onshore" && status !== "Onshore Review Passed");
            if (isItemOpen) {
                colour = AMBER;
            }
            else {
                colour = GREEN;
            }
            return colour === AMBER; // quit if loop amber	
        });

        serviceInfo.colour = colours[colour];
    }

    function setStatusColour(serviceInfo, statusProperty, assignedToProperty) {
        var colour = serviceInfo.items.length > 0 ? GREEN : NONE;

        serviceInfo.items.some(function (item) {
            var status = item[statusProperty]
            if (status !== "Closed" && status !== "Complete") {
                if (isCurrentUserInList(item[assignedToProperty])) {
                    colour = RED;
                } else if (status === "Queried") {
                    colour = AMBER;
                } else if (colour < AMBER) {
                    colour = BLUE;
                }
            }

            return colour === RED;	// quit loop if RED
        });

        serviceInfo.colour = colours[colour];
    }

    function setQueryStatusColour(serviceInfo, statusProperty, assignedToProperty) {
        var colour = serviceInfo.items.length > 0 ? GREEN : NONE;

        serviceInfo.items.some(function (item) {
            if (item[statusProperty] !== "Closed") {
                if (isCurrentUserInList(item[assignedToProperty])) {
                    colour = RED;
                } else {
                    colour = AMBER;
                }
            }

            return colour === RED;	// quit loop if RED
        });

        serviceInfo.colour = colours[colour];
    }

    function setReferralStatusColour(serviceInfo, statusProperty, assignedToProperty) {
        var colour = serviceInfo.items.length > 0 ? GREEN : NONE;

        serviceInfo.items.some(function (item) {
            var status = item[statusProperty]
            if (status !== "Closed" && status !== "Cancelled") {
                if (isCurrentUserInList(item[assignedToProperty])) {
                    colour = RED;
                } else if (status === "Queried") {
                    colour = AMBER;
                } else {
                    colour = BLUE;
                }
            }

            return colour === RED;	// quit loop if RED
        });

        serviceInfo.colour = colours[colour];
    }

    function setBUAAStatusColour(serviceInfo, statusProperty, assignedToProperty) {

        var colour = serviceInfo.items.length > 0 ? AMBER : NONE;

        if (serviceInfo.items.length > 0) {
            serviceInfo.items.sort(function (a, b) {
                a = new Date(a.CreatedAt);
                b = new Date(b.CreatedAt);
                return a > b ? -1 : a < b ? 1 : 0;
            });
            var latestBUAA = serviceInfo.items[0];
            var latestAssignedToMe = isCurrentUserInListBUAA(latestBUAA.AssignedTo);
            if (latestBUAA.Status == 'Complete' || latestBUAA.Status == 'console.log closed' || latestBUAA.Status == 'BUAA Raised' || latestBUAA.Status == 'console.log Superceded') {
                colour = GREEN;
            }
            else if ((latestBUAA.Type == 2 && latestBUAA.Status == 'Rejected') || (latestAssignedToMe)) {
                colour = RED;
            }
            else if (latestBUAA.Status == 'Request Cancelled') {
                colour = GRAY;
            }
        }
        serviceInfo.colour = colours[colour];
    }

    function isCurrentUserInList(users) {
        var result = false;

        if (users) {
            if (Array.isArray(users)) {
                result = users.some(function (user) {
                    return user.Name && user.Name.toLowerCase() ===  riskEntrySheet.currentUser;
                });
            } else {
                result = users.Name && users.Name.toLowerCase() ===  riskEntrySheet.currentUser;
            }
        }

        return result;
    }

    function isCurrentUserInListBUAA(users) {
        var result = false;
        var currentUser =  riskEntrySheet.currentUser.substr( riskEntrySheet.currentUser.indexOf("\\") + 1);
        if (users) {
            result = users && users.Name && users.Name.toLowerCase() === currentUser;
        }
        return result;
    }

}();