import { LightningElement, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import confirmEmailChange from "@salesforce/apex/LightningConfirmEmailChangeController.confirmEmailChange";

export default class ConfirmEmailChange extends LightningElement {
  @api
  loginUrl;

  currentPageReference = null;
  urlStateParameters = null;
  hashCode = null;
  email = null;
  isLoading = true;
  emailChangeConfirmed = false;
  isRenderCallbackActionExecuted = false;

  renderedCallback() {
    if (this.isRenderCallbackActionExecuted) {
      return;
    }
    this.isRenderCallbackActionExecuted = true;
    // console.log('hashcode '+this.hashCode);
    if (this.hashCode && this.email) {
      confirmEmailChange({
        hashCode: this.hashCode,
        currentEmail: this.email,
        loginUrl: this.loginUrl
      })
        .then((response) => {
          this.isLoading = false;
          console.log(response);
          if (response === "Confirmed") {
            this.emailChangeConfirmed = true;
          }
        })
        .catch((error) => {
          this.error = error;
          console.log(error);
          this.isLoading = false;
        });
    } else {
      this.isLoading = false;
    }
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlStateParameters = currentPageReference.state;
      this.setParametersBasedOnUrl();
    }
  }
  setParametersBasedOnUrl() {
    this.hashCode = this.urlStateParameters.s || null;
    this.email = this.urlStateParameters.u || null;
  }
}
