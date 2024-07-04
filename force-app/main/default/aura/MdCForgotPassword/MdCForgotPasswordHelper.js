({
  qsToEventMap: {
    expid: "e.c:setExpId"
  },

  handleForgotPassword: function (component, event, helper) {
    var username = component.find("username").get("v.value");
    var checkEmailUrl = component.get("v.checkEmailUrl");

    console.log("Hello");
    if (helper.validateEmail(username)) {
      var action = component.get("c.forgotPassword");

      action.setParams({ username: username, checkEmailUrl: checkEmailUrl });
      action.setCallback(this, function (a) {
        var rtnValue = a.getReturnValue();
        if (rtnValue != null) {
          component.set("v.errorMessage", rtnValue);
          component.set("v.showError", true);
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set(
        "v.errorMessage",
        "Veuillez entrer une adresse email valide"
      );
      component.set("v.showError", true);
    }
  },

  setBrandingCookie: function (component, event, helpler) {
    var expId = component.get("v.expid");
    if (expId) {
      var action = component.get("c.setExperienceId");
      action.setParams({ expId: expId });
      action.setCallback(this, function (a) {});
      $A.enqueueAction(action);
    }
  },

  goBack: function () {
    window.history.back();
  },

  validateEmail: function (email) {
    console.log("validating email");
    var re =
      /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    console.log("re set");
    console.log(re.test(email));
    console.log("done");
    return re.test(email);
  }
});
