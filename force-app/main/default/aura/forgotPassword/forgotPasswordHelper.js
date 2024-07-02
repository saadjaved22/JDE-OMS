({
    qsToEventMap: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleForgotPassword: function (component, event, helpler){
        component.set("v.submitButtonLoading", "true");
        var username = component.find("username").get("v.value");
        console.log('username' + username);
        var checkEmailUrl = component.get("v.checkEmailUrl");
        console.log('checkEmailURL' + checkEmailUrl);
        
        var action = component.get("c.forgotPassword");
        
        
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            component.set("v.submitButtonLoading", "false");
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },
    
    goBack : function() {
        window.history.back();
    }
})