import { LightningElement, wire , track  } from 'lwc';
import getUserPerformanceDetails from '@salesforce/apex/phsUserPerformanceController.getUserPerformanceDetails';
import getUserGoalList from '@salesforce/apex/phsUserGoalsController.getUserGoalList';

export default class PhsChatBot extends LightningElement {
  userPerformanceDetails;
       chatBaseMetadata ={};
       stressLevel__c="NA";
       timeInFlowState__c="NA";
       focusQuality__c="NA";
       successStories__c="NA";
       challengesFaced__c="NA";
       myGoals;
       myGoalsMetadata;
       myGoalsAll;
       myGoalsActive;
     
       @wire(getUserPerformanceDetails) 
       retgetUserPerformanceDetails({ error, data }) {
          // console.log("DP: retgetUserPerformanceDetails is ",data);
          if (data) {
            this.userPerformanceDetails = JSON.parse(data);
            //console.log("DP: getUserPerformanceDetails is ",data);
        
            if(this.userPerformanceDetails.stressLevel)
            {
              this.stressLevel__c = this.userPerformanceDetails.stressLevel;
              this.chatBaseMetadata.myStressLevel ='"'+ this.stressLevel__c+'"';
            }
          
            if(this.userPerformanceDetails.successStories)
            {
              this.successStories__c = this.userPerformanceDetails.successStories;
              this.chatBaseMetadata.mySuccessStories = this.successStories__c;
            }
           if(this.userPerformanceDetails.timeInFlowState)
            {
              this.timeInFlowState__c = this.userPerformanceDetails.timeInFlowState;
              this.chatBaseMetadata.myTimeInFlowState ='"'+this.timeInFlowState__c+'"';          
            }
            if(this.userPerformanceDetails.focusQuality)
            {
              this.focusQuality__c = this.userPerformanceDetails.focusQuality;
              this.chatBaseMetadata.myFocusQuality ='"'+ this.focusQuality__c +'"';
            }
    
            if(this.userPerformanceDetails.challengesFaced)
            {
              this.challengesFaced__c = this.userPerformanceDetails.challengesFaced;
              this.chatBaseMetadata.challengesFaced = this.challengesFaced__c;
            }
           
          } else if (error) {
            // console.log("DP: getUserPerformanceDetails error is ",error);
          }
        }
      
      
        @wire(getUserGoalList) 
        retgetUserGoalList({ error, data }) {
          // console.log("DP: getUserGoalList is ",data);
          if (data) {  
            this.myGoalsAll=JSON.parse(data);    
            this.myGoals = this.myGoalsAll.filter(element => element.isActive==true);
            var i = 1;
            this.myGoals.map((goal) => {
             var goalName = "goal"+i+"Name";
             var goalType = "goal"+i+"Type";
             var goalStatus = "goal"+i+"Status";
             var goalFocusArea = "goal"+i+"FocusArea";
             var goalEffectiveness = "goal"+i+"Effectiveness";
             var goalAdherence = "goal"+i+"Adherence";
             this.chatBaseMetadata[goalName] = goal.goalName;
             this.chatBaseMetadata[goalType] = goal.goalType;
             this.chatBaseMetadata[goalStatus] = goal.goalStatus;
             this.chatBaseMetadata[goalFocusArea] = goal.focusArea;
             this.chatBaseMetadata[goalEffectiveness] ='"'+ goal.goalEffectiveness+'"';
             this.chatBaseMetadata[goalAdherence] = '"'+goal.goalAdherence+'"';

             i++;
            })
            
          } else if (error) {
            // console.log("DP: getUserGoalList error is ",error);
          }
        }

 connectedCallback()
 {
  this.postToChatBase();
 }

 renderedCallback(){
  this.postToChatBase();
 }

    postToChatBase()
    {
        // console.log("ij session contactid is ", sessionStorage.getItem('contactId'));
        // console.log("ij session hash is ", sessionStorage.getItem('chatBaseHash'));
        var contactId = sessionStorage.getItem('contactId');
        var chatBaseHash = sessionStorage.getItem('chatBaseHash');
        // console.log("ij contactId is : ",contactId);
        // console.log("ij chatBaseHash is : ",chatBaseHash);
        var temp = {};
        temp=this.chatBaseMetadata;

        // console.log("ij second temp is ", temp);
    
        window.chatbase("identify", {
            user_id: contactId,
            user_hash: chatBaseHash,
            user_metadata: temp
          });        
    }
}