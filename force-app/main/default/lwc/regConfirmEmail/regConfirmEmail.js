import { LightningElement, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
// import { NavigationMixin } from "lightning/navigation";
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import confirmEmail from "@salesforce/apex/LightningConfirmEmailController.confirmEmail";

export default class RegConfirmEmail extends LightningElement {
  @api
  loginUrl;

  currentPageReference = null;
  urlStateParameters = null;
  hach64 = null;
  email = null;
  isLoading = true;
  emailConfirmed = false;
  isRenderCallbackActionExecuted = false;

  renderedCallback() {
    if (this.isRenderCallbackActionExecuted) {
      return;
    }
    this.isRenderCallbackActionExecuted = true;
    if (this.hach64 && this.email) {
      confirmEmail({
        hach64: this.hach64,
        email: this.email,
        loginUrl: this.loginUrl
      })
        .then((response) => {
          this.isLoading = false;
          console.log(response);
          if (response === "Confirmed" || response === "Already confirmed") {
            this.emailConfirmed = true;
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
    this.hach64 = this.urlStateParameters.s || null;
    this.email = this.urlStateParameters.u || null;
  }

  /* handleNavigate() {
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: this.loginUrl
            }
        };
        this[NavigationMixin.Navigate](config);
    } */

  /* showSuccessToast() {
        const toast = new ShowToastEvent({
            title: 'E-mail bevestigd',
            message: 'je e-mailadres is nu bevestigd, gebruik je e-mailadres en wachtwoord om in te loggen',
            variant: 'Success',
        });
        this.dispatchEvent(toast);
    } */
}
