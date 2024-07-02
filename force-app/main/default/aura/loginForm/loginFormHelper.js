({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleLogin : function (component, event, helpler) {
        component.set("v.submitButtonLoading", "true");
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        var nonLocalStartUrl = component.get("v.nonLocalStartUrl");
        
        startUrl = decodeURIComponent(startUrl);
        console.log('Start Url '+startUrl);
        
        action.setParams({
            username:username,
            password:password,
            startUrl:startUrl,
            nonLocalStartUrl:nonLocalStartUrl,
            recatpchaSecret: component.get('v.reCaptchaSiteSecret'),
            recaptchaToken: component.get('v.reCaptchaToken')
        });
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            component.set("v.submitButtonLoading", "false");
            if (rtnValue !== null) {
                // Failed to login
                //UserLoginFailMessage
                let userLoginError = $A.get("$Label.c.UserLoginFailMessage");
                let userLoginLocked = $A.get("$Label.c.UserLoginLocked");
                let userIsInactive = $A.get("$Label.c.userIsInactive");
                if(userLoginError == rtnValue ){
                	component.set("v.showClickHere",false);
                }
                else if(userLoginLocked == rtnValue){
                    component.set("v.showClickHere",true);
                }
                else if(userIsInactive == rtnValue){
                    component.set("v.showClickHere",true);
                }
                else{
                    component.set("v.showClickHere",false);
                }
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);

                // Reset captcha state if recaptcha enabled
                var recaptchaUrlSetting = component.get('v.reCaptchaPublicSiteURL');

                if(recaptchaUrlSetting){
                    console.log('reset captcha status')
                    component.set('v.reCaptchaToken', '')
                    component.set('v.reCaptchaLoginDisabled', true);

                    // Refresh recaptcha
                    var nonce = Math.random().toString(16).substr(2, 8);
                    component.set('v.reCaptchaPublicSiteURLNonce', recaptchaUrlSetting + '?nonce='+nonce);
                    
                    // Set recaptcha visible
                    var iFrame = document.getElementById('recaptchaIframe') || {style:{}};
                    iFrame.style.height = "500px";
                }

            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie : function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },
    
    getUrlParameter : function (sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
        
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
	},
    
    goBack : function() {
        var travelNumber = window.sessionStorage.getItem("travel-number");
        window.history.go(-travelNumber);
    }
})