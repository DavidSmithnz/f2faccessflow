import { LightningElement, wire } from 'lwc';  
import My_Resource from '@salesforce/resourceUrl/phsResource';
import getTip from '@salesforce/apex/phsCoachController.getCoachTip';

export default class PhsCoachTip extends LightningElement {

    tipIcon = My_Resource + '/Icons/tips_icon.svg';
    TipOfTheDay = "";
    showTip = false;
    showLoader = true;

    @wire(getTip) 
      retGetTip({ error, data }) {
        if (data) {
          this.TipOfTheDay = data;  
          this.showTip = true;
          this.showLoader = false;        
        } else if (error) {
          // console.log("ij: retGetTip error is ",error);          
        }
      };

}