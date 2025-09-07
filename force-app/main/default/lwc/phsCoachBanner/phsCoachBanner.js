import { LightningElement, track, api } from 'lwc';
import isCoachCheckInRequired from '@salesforce/apex/phsCoachController.isCoachCheckInRequired';
import isCoachCheckOutRequired from '@salesforce/apex/phsCoachController.isCoachCheckOutRequired';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import basePath from '@salesforce/community/basePath';


export default class PhsCoachBanner extends LightningElement {
    showPopup = false;
    checkinUrl = basePath +'/coach';
    popupText = "";

    checkInRequired = false;
    coachMessage = "";
    //bellIcon = My_Resource + '/Icons/bell.png';
      bellIcon = My_Resource + '/Icons/notification_300525.svg';
    firstName = "there";

    connectedCallback() {
        if (this.isFriday()) {
            this.getCheckOutRequired();
        }
        else {
            this.getCheckInRequired();
        }
    }

    isFriday() {
        const today = new Date();
        return today.getDay() === 5; // 5 = Friday
    }

    handleDismiss() {
        this.showPopup = false;
    }

    getCheckInRequired() {
        isCoachCheckInRequired().then(result => {
            if (result) {
                result;
                if (result == true) {
                    //this.getCoachQuestion();
                    this.checkInRequired = true;
                  //  this.coachMessage = "Coach check-in pending. Click to proceed";
                  this.coachMessage=" take a moment to set your goals for this week.";
                    this.popupText = "I am your virtual coach. Your weekly check-in is pending. Ready to complete it now?";
                    if (sessionStorage && sessionStorage.getItem("firstName")) {
                        this.firstName = sessionStorage.getItem("firstName");
                    }

                    if (!(sessionStorage && sessionStorage.getItem("coachPopupDisplayed"))) {
                        this.showPopup = true;
                    }
                }
                sessionStorage.setItem("coachPopupDisplayed", true);
            }
        });
    }

    getCheckOutRequired() {
        isCoachCheckOutRequired().then(result => {
            if (result) {
                result;
                if (result == true) {
                    //this.getCoachQuestion();
                    this.checkInRequired = true;
                    // this.coachMessage = "Friday check-out pending. Click to proceed";
                    this.coachMessage = "It's time for your Friday check-out!";
                    this.popupText = "I'm your virtual coach. How was your week?";
                    if (sessionStorage && sessionStorage.getItem("firstName")) {
                        this.firstName = sessionStorage.getItem("firstName");
                    }

                    if (!(sessionStorage && sessionStorage.getItem("coachPopupDisplayed"))) {
                        this.showPopup = true;
                    }
                }
                sessionStorage.setItem("coachPopupDisplayed", true);
            }
        });
    }
}