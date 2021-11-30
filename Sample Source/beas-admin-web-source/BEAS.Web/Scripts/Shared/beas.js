const timeout = ms => new Promise(res => setTimeout(res, ms));

class BeasBladeManager {
    constructor(currentBladePath) {
        this.currentBladePath = currentBladePath;

        this.uiManagement = {
            uiFocus : "search",
            openBlades :[]
        }

        this.blades = {
            applicationInfoBlade: "BeasApplicationInfo",
            applicationAreaInfoBlade: "BeasApplicationAreaInfo",
            roleInfoBlade : "BeasRoleInfo",
            userInfoBlade: "BeasUserInfo",
            userRoleInfoBlade: "BeasUserRoleInfo"
        }
    }

    setOpenBlade(blade) {
        this.uiManagement.openBlades.push(blade);
    }

    setBladeCloseHandler(bladeName,closeHandlerFunc) {
        if(bladeUI)
        {
            var blade = bladeUI.getBladeByName(bladeName);

            if(blade)
                blade.setCloseHandler(closeHandlerFunc);
        }
    }

    setAndShowBlade(blade,closeHandler)
    {
        this.setOpenBlade(blade);
        page.show(this.getBladeInfoPath(blade));
        this.setBladeCloseHandler(blade,closeHandler);
    }

    getBladeInfoPath(bladeName)
    {
        return this.currentBladePath + "/"+bladeName+"(focus='" + this.uiManagement.uiFocus + "')";
    }

    getBlade(bladeName)
    {
        return bladeUI.getBladeByName(bladeName);
    }

    setUiFocus(focus) {
        this.uiManagement.uiFocus = focus;
    }

    getUiFocus() { return this.uiManagement.uiFocus; }

    closeBlade(bladeName) {
        if(bladeUI)
        {
            let openBladeIndex = this.uiManagement.openBlades.findIndex(function(x) { return x === bladeName;});

            if(openBladeIndex > -1) {
                // remove blade from array
                this.uiManagement.openBlades.splice(openBladeIndex,1);

                let blade = bladeUI.getBladeByName(bladeName);

                if(blade)
                {
                    blade.hasChanged = false;
                    blade.close();
                }
                
            }
            else
            {
                let blade = bladeUI.getBladeByName(bladeName);

                if(blade)
                {
                    blade.hasChanged = false;
                    blade.close();
                }
            }
        }
    }
}

const azureGetAccessToken = async function (resourceUrlWithScope) {
    // assume Opus has already accquired a valid token
    return await acquireMsalSilentToken(azureClientApplicationResourceId, [resourceUrlWithScope]);    
}

const retry = async function(functionToBeExecuted, numberOfRetries, timeoutBetween,onErrorFunctionToBeExecuted) {
    let error = null;
    for (let i = 0; i < numberOfRetries; i++) {
        try {
            await functionToBeExecuted();
        }
        catch (err) {
            error = err;
        }

        console.log("Retry Number: " + i);

        if (!error)
            break;

        await timeout(timeoutBetween);
    }

    if (error) {

        await onErrorFunctionToBeExecuted();

    }
        
}

const ajaxQuickAsync = async function (type, data, url) {
    let accessToken = await azureGetAccessToken(beasFunctionUrls.scope);
    return $.ajax({
        crossDomain: true,
        type: type,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
            xhr.withCredentials = true;
        },
        url: url,
        dataType: 'json',
        data: data
    });
}

const ajaxQuick =async function (type, data, url, functionOnSuccess, functionOnError, async = true) {
    let accessToken = await azureGetAccessToken(beasFunctionUrls.scope);
    $.ajax({
        crossDomain: true,
        type: type,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
            xhr.withCredentials = true;
        },
        url: url,
        async: async,
        dataType: 'json',
        data: data,
        success: function (data) {

            if (functionOnSuccess)
                functionOnSuccess(data);
        },
        error: function (xhr, ajaxOptions, thrownError) {

            if (functionOnError)
                functionOnError(xhr, ajaxOptions, thrownError);
        }
    });
}

const clearGridSelection = function (gridId) {

    if ($(gridId))
        $(gridId).igGridSelection("clearSelection");
}

const bindGridData = function (bladeName, gridId, dataSource) {
    var blade = bladeUI.getBladeByName(bladeName);

    if (blade != null) {
        blade.content.find(gridId).igGrid("dataSourceObject", dataSource);
        blade.content.find(gridId).igGrid("dataBind");
    }

    
}


