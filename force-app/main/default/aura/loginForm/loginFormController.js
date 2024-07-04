({
  initialize: function (component, event, helper) {
    $A.get("e.siteforce:registerQueryEventMap")
      .setParams({ qsToEvent: helper.qsToEventMap })
      .fire();
    $A.get("e.siteforce:registerQueryEventMap")
      .setParams({ qsToEvent: helper.qsToEventMap2 })
      .fire();
    component.set(
      "v.isUsernamePasswordEnabled",
      helper.getIsUsernamePasswordEnabled(component, event, helper)
    );
    component.set(
      "v.isSelfRegistrationEnabled",
      helper.getIsSelfRegistrationEnabled(component, event, helper)
    );
    component.set(
      "v.communityForgotPasswordUrl",
      helper.getCommunityForgotPasswordUrl(component, event, helper)
    );
    component.set(
      "v.communitySelfRegisterUrl",
      helper.getCommunitySelfRegisterUrl(component, event, helper)
    );
    var startUrl = helper.getUrlParameter("startUrl");
    if (startUrl != undefined && startUrl != "") {
      component.set("v.nonLocalStartUrl", startUrl);
    }
    component.set(
      "v.loginUrl",
      window.location.pathname + window.location.search
    );
    window.sessionStorage.setItem(
      "loginUrl",
      window.location.pathname + window.location.search
    );
    var travelNumber = window.sessionStorage.getItem("travel-number");
    if (travelNumber == undefined || travelNumber == "") {
      window.sessionStorage.setItem("travel-number", 1);
    }

    var recaptchaUrlSetting = component.get("v.reCaptchaPublicSiteURL");

    if (recaptchaUrlSetting) {
      component.set("v.reCaptchaLoginDisabled", true);
      component.set(
        "v.reCaptchaPublicSiteURLNonce",
        recaptchaUrlSetting + "?nonce"
      );
    } else {
      component.set("v.reCaptchaLoginDisabled", false);
    }

    // Iframe encoding of origin
    var iframeTarget = component.get("v.iframeTargetOrigin");
    component.set("v.iframeTargetOrigin", encodeURIComponent(iframeTarget));

    // Recaptcha event capture
    window.addEventListener(
      "message",
      function (event) {
        // console.log("new message:");
        // console.log(event.origin + ' | ' + event.data)

        var iFrame = document.getElementById("recaptchaIframe") || {
          style: {}
        };

        // if(event.origin != iframeTarget)
        //    return;
        if (event.data == "expired") {
          this.set("v.reCaptchaLoginDisabled", true);
          this.set("v.reCaptchaToken", "");
          iFrame.style.height = "500px";
          return;
        }

        // console.log("VALID");
        this.set("v.reCaptchaLoginDisabled", false);
        this.set("v.reCaptchaToken", event.data);
        iFrame.style.height = "95px";
      }.bind(component),
      false
    );
  },

  handleLogin: function (component, event, helpler) {
    helpler.handleLogin(component, event, helpler);
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
      helpler.handleLogin(component, event, helpler);
    }
  },

  navigateToForgotPassword: function (cmp, event, helper) {
    var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
    if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
      forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
    }
    var attributes = { url: forgotPwdUrl };
    $A.get("e.force:navigateToURL").setParams(attributes).fire();
  },

  navigateToSelfRegister: function (cmp, event, helper) {
    var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
    if (selrRegUrl == null) {
      selrRegUrl = cmp.get("v.selfRegisterUrl");
    }

    var attributes = { url: selrRegUrl };
    $A.get("e.force:navigateToURL").setParams(attributes).fire();
  },

  doAction: function (component, event, helper) {
    var inputCmp = component.find("username");
    var value = inputCmp.get("v.value");
    if (true) {
      inputCmp.set("v.errors", [{ message: "Input not a number: " + value }]);
    } else {
      //clear error
      inputCmp.set("v.errors", null);
    }
  },

  returnToPrevious: function (component, event, helper) {
    helper.goBack();
  }
});
