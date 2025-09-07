import { LightningElement, wire, track } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import getWellnessScoreTakenStatus from '@salesforce/apex/phsWellnessWaveController.getWellnessScoreTakenStatus';


export default class PhsHomePage extends LightningElement {

      isSurveyTaken=true;
      isSurveySiteShow=false;
    profileIcon = My_Resource + '/Icons/profile.png';

    handleSurveyPage()
    {
        this.isSurveySiteShow=true;
    }
    handleSurveyPageBack()
    {
         this.isSurveySiteShow=false;
    }
    surveyStatus=null;
     @wire(getWellnessScoreTakenStatus)
          retgetWellnessScoreTakenStatus({ error, data }) {
             
             if (data) {
               this.surveyStatus = JSON.parse(data);
               //console.log("DP: getWellnessScoreTakenStatus : ",  this.surveyStatus);
                if(this.surveyStatus==null)
                {
                    this.isSurveyTaken=false;
                }
                else
                {
                    this.isSurveyTaken=true;
                }

                  } else if (error) {
           //console.log("DP: getWellnessScoreTakenStatus error : ", error);
         }
       }

}