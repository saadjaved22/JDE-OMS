({
  qsToEventMap: {
    startURL: "e.c:setStartUrl"
  },

  qsToEventMap2: {
    expid: "e.c:setExpId"
  },

  handleLogin: function (component, event, helpler) {
    var username = component.find("username").get("v.value");
    var password = component.find("password").get("v.value");
    var action = component.get("c.login");
    var startUrl = component.get("v.startUrl");
    var nonLocalStartUrl = component.get("v.nonLocalStartUrl");

    startUrl = decodeURIComponent(startUrl);

    action.setParams({
      username: username,
      password: password,
      startUrl: startUrl,
      nonLocalStartUrl: nonLocalStartUrl
    });
    action.setCallback(this, function (a) {
      setTimeout(function () {
        $A.get("e.force:refreshView").fire();
      }, 20000);

      var rtnValue = a.getReturnValue();
      if (rtnValue !== null) {
        component.set("v.errors", rtnValue);
        component.set("v.showError", true);
        setTimeout(function () {
          $A.get("e.force:refreshView").fire();
        }, 20000);
      }
      var rtnValue = a.getReturnValue();
      if (rtnValue !== null) {
        component.set("v.errors", rtnValue);
        component.set("v.showError", true);
      }
    });
    $A.enqueueAction(action);
  },

  getIsUsernamePasswordEnabled: function (component, event, helpler) {
    var action = component.get("c.getIsUsernamePasswordEnabled");
    action.setCallback(this, function (a) {
      var rtnValue = a.getReturnValue();
      if (rtnValue !== null) {
        component.set("v.isUsernamePasswordEnabled", rtnValue);
      }
    });
    $A.enqueueAction(action);
  },

  getIsSelfRegistrationEnabled: function (component, event, helpler) {
    var action = component.get("c.getIsSelfRegistrationEnabled");
    action.setCallback(this, function (a) {
      var rtnValue = a.getReturnValue();
      if (rtnValue !== null) {
        component.set("v.isSelfRegistrationEnabled", rtnValue);
      }
    });
    $A.enqueueAction(action);
  },

  getCommunityForgotPasswordUrl: function (component, event, helpler) {
    var action = component.get("c.getForgotPasswordUrl");
    action.setCallback(this, function (a) {
      var rtnValue = a.getReturnValue();
      if (rtnValue !== null) {
        component.set("v.communityForgotPasswordUrl", rtnValue);
      }
    });
    $A.enqueueAction(action);
  },

  getCommunitySelfRegisterUrl: function (component, event, helpler) {
    var action = component.get("c.getSelfRegistrationUrl");
    action.setCallback(this, function (a) {
      var rtnValue = a.getReturnValue();
      if (rtnValue !== null) {
        component.set("v.communitySelfRegisterUrl", rtnValue);
      }
    });
    $A.enqueueAction(action);
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

  getUrlParameter: function (sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
      sURLVariables = sPageURL.split("&"),
      sParameterName,
      i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("=");

      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined ? true : sParameterName[1];
      }
    }
  },

  getUrlParameterNoDecode: function (sParam) {
    var sPageURL = window.location.search.substring(1),
      sURLVariables = sPageURL.split("&"),
      sParameterName,
      i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("=");

      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined ? true : sParameterName[1];
      }
    }
  },

  goBack: function (component, event, helper) {
    var referrerUrl = window.sessionStorage.getItem("referrer");
    if (referrerUrl != undefine && referrerUrl != "") {
      window.location = referrerUrl;
    } else {
      window.history.back();
    }
  }
});
