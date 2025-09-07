import { LightningElement, wire } from 'lwc';  
import My_Resource from '@salesforce/resourceUrl/phsResource';
import getTip from '@salesforce/apex/phsHomePageController.getTipOfTheDay';

export default class PhsCustomHomeTip extends LightningElement {
   tipIcon = My_Resource + '/Icons/tips_icon.svg';
    
    TipOfTheDay = "";

    @wire(getTip) 
      retGetTip({ error, data }) {
        if (data) {
          this.TipOfTheDay = data;          
        } else if (error) {
          // console.log("ij: retGetTip error is ",error);          
        }
      };
}