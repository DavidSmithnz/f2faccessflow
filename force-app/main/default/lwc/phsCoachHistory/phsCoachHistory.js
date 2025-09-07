import { LightningElement } from 'lwc';
import getCoachConversations from '@salesforce/apex/phsCoachController.getCoachConversations';
import { refreshApex } from '@salesforce/apex';

export default class PhsCoachHistory extends LightningElement {

    coachConversations=[];
    coachConversationsData;    
    showLoader = true;
    coachConversationLength=0;
    viewMoreLabel = "View Older";
    showViewMoreLabel = false;

    connectedCallback() {
        this.getConversations();

    }

    handleRefreshEvent(event) {
        if (event.detail === 'refreshHistory') {
          this.getConversations();
        }
      }

    getConversations() {
        getCoachConversations().then(result => {
            if (result) {
                this.coachConversationsData = result;
                this.coachConversationLength = this.coachConversationsData.length;
                if(this.coachConversationLength > 2)
                {
                    for(var i=0; i< 2; i++)
                    {
                        this.coachConversations.push(this.coachConversationsData[this.coachConversationLength-2+i]);
                    }
                    this.showViewMoreLabel = true;
                }
                else{
                    this.coachConversations = this.coachConversationsData;
                    this.showViewMoreLabel = false;
                }
                this.showLoader = false;
            }
        });
    }

    handleViewOlderClick(){
        this.showLoader = true;
        this.coachConversations = this.coachConversationsData;
        this.showLoader = false;
        this.showViewMoreLabel = false;
    }

    
}