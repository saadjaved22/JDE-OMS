({
  init: function (component, event, helper) {
    component.set("v.loginUrl", sessionStorage.getItem("loginUrl"));
  },

  returnToPrevious: function (component, event, helper) {
    window.location = sessionStorage.getItem("loginUrl");
  }
});
