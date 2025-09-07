import { LightningElement,wire,track } from 'lwc';
import getUserProfile from '@salesforce/apex/phsProfileController.getUserProfile';
import { CurrentPageReference } from "lightning/navigation";
import My_Resource from '@salesforce/resourceUrl/phsResource';
export default class PhsCustomProfile extends LightningElement {


  notificationImageUrl = My_Resource + '/Profile/notification-icon.png';
  
  privacyImageUrl = My_Resource + '/Profile/privacy-icon.png';
  securityImageUrl = My_Resource + '/Profile/security-icon.png';
  
  isProfile=false;
  isSettings=false;
  isContactUs=false;
  isFeedback=false;
 
  
  @track displayValue;
    userProfile;
    mailToEmail;
      @wire(getUserProfile)
      retgetUserProfile({ error, data }) {
        // console.log("DP: getUserProfile is ", data);
        if (data) {
          this.userProfile = JSON.parse(data);
          this.mailToEmail='mailto:'+this.userProfile.Email;
         
        } else if (error) {
          // console.log("DP: getUserProfile error is ", error);
        }
      }


      @wire(CurrentPageReference)
getStateParameters(currentPageReference) {
 if (currentPageReference) {
   const urlValue = currentPageReference.state.type;
   this.isProfile=false;
   this.isSettings=false;
   this.isContactUs=false;
   this.isFeedback=false;
 
   if (urlValue) {
     this.displayValue = `URL Value was: ${urlValue}`;
    if(urlValue=='profile')
    {
      this.isProfile=true;
    }
    else if(urlValue=='settings')
    {
      this.isSettings=true;
    }
    else if(urlValue=='contactus')
    { 
      this.isContactUs=true; 
    }
      else if(urlValue=='feedback')
    {
      this.isFeedback=true;
    }

   } else {
     this.displayValue = `URL Value was not set`;
   }
 }

}

}