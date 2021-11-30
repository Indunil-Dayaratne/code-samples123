$(document).ready(function () {
    $("#testCors").click(function () {
        $.ajax({
            url: "http://localhost:41204/api/Values",
            xhrFields: {
                withCredentials: true
            }
        }).done(function (data) {
            console.log(data);
        });
    });

    $("#testPutCors").click(function () {
        $.ajax({
            url: "http://localhost:41204/api/Values/eclipse-policy-in",
            method: "PUT",
            dataType: "json",
            contentType: 'application/json',
            data: JSON.stringify("my test data"),
            xhrFields: {
                withCredentials: true
            }
        }).done(function (data) {
            console.log("done: " + data);
        }).fail(function (jqXHR, textStatus, errorThrown) {
            console.log(`fail status=${textStatus}, errorThrown=${errorThrown}`);
        });
    });

    $("#testPutCorsNoAuth").click(function () {
        $.ajax({
            url: "http://localhost:41204/api/Values/123",
            method: "PUT",
            dataType: "json",
            contentType: 'application/json',
            data: JSON.stringify("my test data")
        }).done(function (data) {
            console.log("done: " + data);
        }).fail(function (jqXHR, textStatus, errorThrown) {
            console.log(`fail status=${textStatus}, errorThrown=${errorThrown}`);
        });
    });

    $("#postTopicMessage").click(function () {
        var message = $("#message").val();
        $.ajax({
            url: "http://localhost:41204/ESB/Topic/Message/test/WebTest",
            method: "POST",
            dataType: "json",
            contentType: 'application/json',
            data: JSON.stringify(message),
            xhrFields: {
                withCredentials: true
            }
        }).done(function (data) {
            console.log("done: " + data);
        }).fail(function (jqXHR, textStatus, errorThrown) {
            console.log(`fail status=${textStatus}, errorThrown=${errorThrown}`);
        });
    });

});