({
  initialize: function (component, event, helper) {
    $A.get("e.siteforce:registerQueryEventMap")
      .setParams({ qsToEvent: helper.qsToEventMap })
      .fire();
    $A.get("e.siteforce:registerQueryEventMap")
      .setParams({ qsToEvent: helper.qsToEventMap2 })
      .fire();
    component.set(
      "v.extraFields",
      helper.getExtraFields(component, event, helper)
    );
    window.scrollTo(0, 0);
    helper.queryInvalidEmail(component);
  },

  handleSelfRegister: function (component, event, helpler) {
    helpler.handleSelfRegister(component, event, helpler);
  },
  handleEmailConfirmFoucusOut: function (component, event, helper) {
    var email = component.find("email").get("v.value");
    var confirmEmail = component.find("confirmEmail").get("v.value");
    helper.checkEmailConfirmMatching(component, email, confirmEmail);
  },

  setStartUrl: function (component, event, helpler) {
    var startUrl = event.getParam("startURL");
    if (startUrl) {
      component.set("v.startUrl", startUrl);
    }
  },

  setExpId: function (component, event, helper) {
    var expId = event.getParam("expid");
    if (expId) {
      component.set("v.expid", expId);
    }
    helper.setBrandingCookie(component, event, helper);
  },

  onKeyUp: function (component, event, helpler) {
    //checks for "enter" key
    if (event.getParam("keyCode") === 13) {
      helpler.handleSelfRegister(component, event, helpler);
    }
  },
  addSpaceAfter4NumberForPostcode: function (component, event, helper) {
    helper.addSpaceAfter4NumberForPostcode(component);
  }
});
