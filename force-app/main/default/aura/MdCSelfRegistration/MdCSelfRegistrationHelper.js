({
  qsToEventMap: {
    startURL: "e.c:setStartUrl"
  },

  qsToEventMap2: {
    expid: "e.c:setExpId"
  },

  handleSelfRegister: function (component, event, helper) {
    var accountId = component.get("v.accountId");
    helper.validateCustomerData(component, event, helper);
    console.log(component.get("v.showError"));
    if (component.get("v.showError") == false) {
      var regConfirmUrl = component.get("v.regConfirmUrl");
      var firstname = component.find("firstname").get("v.value");
      var lastname = component.find("lastname").get("v.value");
      var email = component.find("email").get("v.value");
      var includePassword = component.get("v.includePasswordField");
      var password = component.find("password").get("v.value");
      var confirmPassword = component.find("confirmPassword").get("v.value");
      var action = component.get("c.selfRegister");
      var startUrl = component.get("v.startUrl");
      var birthDateMonth = component.find("birthdateMonth").get("v.value");
      var birthDateDay = component.find("birthdateDay").get("v.value");
      var birthDateYear = component.find("birthdateYear").get("v.value");
      console.log("making birthdate");
      var birthDateNew = "";
      if (birthDateYear && birthDateMonth && birthDateDay) {
        birthDateNew =
          birthDateYear + "-" + birthDateMonth + "-" + birthDateDay;
      }
      console.log("birthdate made");
      var sixTnYrsOld = component.find("checkboxAge").get("v.value");
      var commercialconsent = component
        .find("commercialConsentText")
        .get("v.value");

      var gender = component.get("v.gender");

      //var birthdate = component.find("birthdate").get("v.value");
      var postcode = component.find("postcode").get("v.value");
      /*var houseNumber = component.find("houseNumber").get("v.value");
            var streetName = component.find("streetName").get("v.value");*/
      var cityName = component.find("cityName").get("v.value");
      /*var mobileNumber = component.find("mobileNumber").get("v.value");*/
      var country = component.get("v.country");
      var applianceOwnership = component.get("v.applianceOwnership");
      var applianceOwnershipString = "";
      applianceOwnership.forEach(function (item) {
        applianceOwnershipString += item + ";";
      });

      startUrl = decodeURIComponent(startUrl);
      action.setParams({
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        accountId: accountId,
        regConfirmUrl: regConfirmUrl,
        startUrl: startUrl,
        includePassword: includePassword,
        gender: gender,
        country: country,
        birthdate: birthDateNew,
        postcode: postcode,
        city: cityName,
        applianceOwnership: applianceOwnershipString,
        sixTnYrsOld: sixTnYrsOld,
        commercialConsent: commercialconsent
      });
      action.setCallback(this, function (response) {
        var rtnValue = response.getReturnValue();
        if (rtnValue !== null) {
          window.scrollTo(0, 0);
          var errors = component.get("v.errors");
          errors.push(rtnValue);
          component.set("v.errors", errors);
          component.set("v.showError", true);
        }
      });
      $A.enqueueAction(action);
    }
  },

  getApplianceOwnershipValues: function (component, event, helpler) {
    var action = component.get("c.returnApplianceOwnershipValues");
    action.setCallback(this, function (response) {
      var rtnValue = response.getReturnValue();
      if (rtnValue !== null) {
        console.log(rtnValue);
        component.set("v.applianceOwnershipValues", rtnValue);
      }
    });
    $A.enqueueAction(action);
  },

  setBrandingCookie: function (component, event, helpler) {
    var expId = component.get("v.expid");
    if (expId) {
      var action = component.get("c.setExperienceId");
      action.setParams({ expId: expId });
      //action.setCallback(this, function(response){ });
      $A.enqueueAction(action);
    }
  },

  validateCustomerData: function (component, event, helper) {
    component.set("v.showError", false);
    var isValid = true;
    var errors = [];
    component.set("v.errors", errors);
    var firstname = component.find("firstname");
    var lastname = component.find("lastname");
    var email = component.find("email");
    var includePassword = component.get("v.includePasswordField");
    var password = component.find("password");
    var confirmPassword = component.find("confirmPassword");
    var birthDate = component.find("birthdate");
    var sixTnYrsOld = component.find("checkboxAge");
    var commercialconsent = component.find("commercialConsentText");
    var postcode = component.find("postcode");
    /*var houseNumber = component.find("houseNumber").get("v.value");
        var streetName = component.find("streetName").get("v.value");*/
    var cityName = component.find("cityName");
    //var mobileNumber = component.find("mobileNumber");
    var gender = component.get("v.gender");
    var applianceOwnership = component.get("v.applianceOwnership");

    if (!gender) {
      isValid = false;
      var genderRadio = component.find("gender");
      $A.util.addClass(genderRadio, "error");
      console.log("gender missing");
    } else {
      $A.util.removeClass(genderRadio, "error");
    }
    if (!firstname.get("v.value")) {
      isValid = false;
      $A.util.addClass(firstname, "error");
      console.log("firstname missing");
    } else {
      $A.util.removeClass(firstname, "error");
    }
    if (!lastname.get("v.value")) {
      isValid = false;
      $A.util.addClass(lastname, "error");
      console.log("lastname missing");
    } else {
      $A.util.removeClass(lastname, "error");
    }
    if (!email.get("v.value")) {
      isValid = false;
      $A.util.addClass(email, "error");
      console.log("email missing");
    } else {
      if (helper.validateEmail(email.get("v.value"))) {
        $A.util.removeClass(email, "error");
      } else {
        $A.util.addClass(email, "error");
        errors.push("Veuillez saisir une adresse email valide");
        console.log("email invalid");
      }
    }
    if (!postcode.get("v.value")) {
      isValid = false;
      $A.util.addClass(postcode, "error");
      console.log("postcode missing");
    } else {
      $A.util.removeClass(postcode, "error");
    }
    if (!cityName.get("v.value")) {
      isValid = false;
      $A.util.addClass(cityName, "error");
      console.log("city missing");
    } else {
      $A.util.removeClass(cityName, "error");
    }
    if (!applianceOwnership) {
      isValid = false;
      $A.util.addClass(applianceOwnership, "error");
      console.log("applianceOwnership missing");
      component.set("v.selectABrewerError", true);
    } else {
      component.set("v.selectABrewerError", false);
      $A.util.removeClass(applianceOwnership, "error");
    }
    if (
      includePassword == true &&
      password.get("v.value") &&
      confirmPassword.get("v.value")
    ) {
      /*if(password == confirmPassword){
                helper.validatePass(component, helper, password, confirmPassword);
            } else*/ if (
        password.get("v.value") != confirmPassword.get("v.value")
      ) {
        isValid = false;
        $A.util.addClass(password, "error");
        $A.util.addClass(confirmPassword, "error");
        errors.push("Passwords do not match");
        console.log("passwords do not match");
      } else {
        $A.util.removeClass(password, "error");
        $A.util.removeClass(confirmPassword, "error");
      }
    }
    if (sixTnYrsOld.get("v.value") == false) {
      console.log("Age consent not checked");
      isValid = false;
      $A.util.addClass(sixTnYrsOld, "checkbox-error");
    } else {
      $A.util.removeClass(sixTnYrsOld, "checkbox-error");
    }
    if (isValid == false) {
      errors.push("Veuillez remplir tous les champs obligatoire");
      component.set("v.showError", true);
      component.set("v.errors", errors);
    }
  },

  validateEmail: function (email) {
    var re =
      /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  }
});
