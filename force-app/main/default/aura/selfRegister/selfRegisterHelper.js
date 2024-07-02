({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        var submitButton= component.find('submitButton');
        submitButton.set('v.disabled',true);
        // var submitButtonLoading = component.get("v.submitButtonLoading");
        component.set("v.submitButtonLoading", "true");

        var accountId = component.get("v.accountId");
        
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        
        var email = component.find("email").get("v.value");
        var confirmEmail = component.find("confirmEmail").get("v.value");
        if(this.checkIfInvalidEmail(component, email)){
            return;
        }
        if(!this.checkEmailConfirmMatching(component,email,confirmEmail)){
            return;
        }
        
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        
        var birthDateMonth = component.find("birthdateMonth").get("v.value");
        var birthDateDay = component.find("birthdateDay").get("v.value");
        var birthDateYear = component.find("birthdateYear").get("v.value");
        
        
        var birthDateNew = 'empty';
        if(birthDateYear != null){
            birthDateNew = birthDateYear + '-' + birthDateMonth + '-' + birthDateDay;
        }
        
        //var sixTnYrsOld = component.find("checkboxAge").get("v.value").toString(); //lightning page sign up button fix
        // var sixTnYrsOld = component.find("checkboxAge").get("v.value");
        // console.log("value" + sixTnYrsOld);
        //var commercialconsent = component.find("commercialConsentText").get("v.value").toString(); //lightning page sign up button fix
        var commercialconsent = component.find("commercialConsentText").get("v.value");
        console.log("value" + commercialconsent);
        
        /* var gender = '';
        
        if(component.find("r0").get("v.value") == true){
            gender = 'Male';
        }
        else if(component.find("r1").get("v.value") == true){
            gender = 'Female';
        }else if (component.find("r2").get("v.value") == true){
            gender = 'Other';
        } */
        
        //var birthdate = component.find("birthdate").get("v.value");
        var postcode = component.find("postcode").get("v.value");
        var houseNumber = component.find("houseNumber").get("v.value");
        var streetName = component.find("streetName").get("v.value");
        var cityName = component.find("cityName").get("v.value");
        // var mobileNumber = component.find("mobileNumber").get("v.value");
        var mobileNumber = null;
        
        startUrl = decodeURIComponent(startUrl);
        action.setParams({firstname:firstname,lastname:lastname,email:email,
                          password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, 
                          extraFields:extraFields, startUrl:startUrl, includePassword:includePassword,
                          birthDateNew:birthDateNew, postcode:postcode,houseNumber:houseNumber,
                          streetName:streetName, cityName:cityName,mobileNumber:mobileNumber, 
                          commercialConsent:commercialconsent});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            component.set("v.submitButtonLoading", "false");
            if (rtnValue !== null) {
                submitButton.set('v.disabled',false);
                console.log(rtnValue);
                window.scrollTo(0,0);
                component.set("v.showError",false);
                component.set("v.errorMessage",null);
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
                console.log(component.get("v.errorMessage"));
            } else {
                submitButton.set('v.disabled',false);
                component.set("v.showError",false);
                console.log('response is '+rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
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
    addSpaceAfter4NumberForPostcode: function (component) {   
        
        var postcode = component.find("postcode").get("v.value");
        postcode = postcode.replace(/[^\dA-Za-z0-9]/g, '').replace(/(.{4})/g, '$1 ').trim();
        postcode = postcode.toUpperCase();
        console.log(postcode);
        component.set("v.postcodevalue", postcode);
        
    },
    queryInvalidEmail: function(component){
        var action = component.get("c.getInvalidEmails");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.invalidEmailList", rtnValue.invalidEmails);
                console.log(rtnValue.invalidEmails);
            } else {
                component.set("v.showError",false);
            }
        });
        $A.enqueueAction(action);
    },
    checkIfInvalidEmail: function(component, email){
        var result = false;
        component.set("v.showError",false);
        component.set("v.errorMessage",null);
        
        let IEL = component.get("v.invalidEmailList");
        if(!$A.util.isUndefinedOrNull(this.searchInList(Object.values(IEL), email))){
            component.set("v.errorMessage",'E-mailaddressen die beginnen met info@, admin@, etc. worden niet geaccepteerd. Voer alstublieft een persoonlijk e-mailadres in.');
            component.set("v.showError",true);
            result = true;
        }
        return result;
    },
    checkEmailConfirmMatching: function(component,email,confirmEmail){
        var result = false;
        var submitButton= component.find('submitButton');
        component.set("v.showError",false);
        component.set("v.errorMessage",null);
        
        if(confirmEmail === email){
            component.set("v.showError",false);
            component.set("v.errorMessage",null);
            result = true;
        }
        else{
            component.set("v.errorMessage",'De opgegeven e-mailadressen komen niet overeen.');
            component.set("v.showError",true);
            component.set("v.submitButtonLoading", false);
            component.set("v.submitButton", false);
            submitButton.set('v.disabled',false);
            window.scrollTo(0, 0);
        }
        return result;
    },
    searchInList: function(stringList, keyword){
        return stringList.find(testing => keyword.toLowerCase().search(testing.toLowerCase()) > -1);
    }
})