import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isCoachCheckInRequired from '@salesforce/apex/phsCoachController.isCoachCheckInRequired';
import getCoachQuestion from '@salesforce/apex/phsCoachController.getCoachQuestion';
import insertCoachConversation from '@salesforce/apex/phsCoachController.insertCoachConversation';
import getCoachConversations from '@salesforce/apex/phsCoachController.getCoachConversations';
import ToastContainer from 'lightning/toastContainer';


export default class PhsCoachCheckIn extends LightningElement {

    isCheckInRequired = false;
    coachQuestion;
    //coachQuestionId;
    coachAnswer;
    userName = "";
    showFollowUpMessage = false;
    showCoachQuestion = false;
    followUpQuestion = "Coach check-in complete. Would you like to answer more questions?";
    showThankYouMessage = false;
    showLoader = true;
    coachQuestionData;
    coachConversations = [];
    coachConversation = {};
    historyLoaded = false;

    connectedCallback() {

        //this.getCheckInRequired();
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 3;
        toastContainer.toastPosition = 'top-center';
        this.initiateCheckIn();

    }

    renderedCallback() {
        const chatThread = this.template.querySelector('[data-id="chatThread"]');
        if (chatThread) {
            chatThread.scrollTop = chatThread.scrollHeight;
        }
        const coachInputTextBox = this.template.querySelector('[data-id="coachInputTextBox"]');
        if (coachInputTextBox)
            coachInputTextBox.value = '';

        if (!this.historyLoaded) {
            this.loadMoreHistory();
        }

        // Scroll chat to the bottom
        const scrollContainer = this.template.querySelector('[data-id="scrollContainer"]');
        if (scrollContainer) {
            scrollContainer.scrollTop = scrollContainer.scrollHeight;
        }

        const inputBox = this.template.querySelector('[data-id="coachInputTextBox"]');
        if (inputBox) {
            inputBox.value = '';
        }
    }

    async getCheckInRequired() {
        isCoachCheckInRequired().then(result => {
            if (result && result == true) {
                this.isCheckInRequired = true;
                //this.getCoachQuestion();
                //this.initiateCheckIn();
            }
            else {
                //this.showCoachFollowup();
                if (this.isCheckInRequired) {
                    this.isCheckInRequired = false;
                    this.showToast('Check-in Complete', 'Coach check-in complete for this week', 'success');
                }
            }
        });
    }

    initiateCheckIn() {
        this.getCoachQuestion();
        this.getCheckInRequired();

    }

    sendPromptToChatbase(prompt) {
        if (window.Chatbase && typeof window.Chatbase.sendMessage === 'function') {
            window.Chatbase.sendMessage(prompt);
        } else {
            // console.error('Chatbase not loaded or sendMessage function not available');
        }
    }

    getCoachQuestion(type) {
        getCoachQuestion(type).then(result => {
            if (result) {
                this.coachQuestionData = result;//JSON.parse(result);
                this.coachQuestion = result;//this.coachQuestionData.question;
                //this.coachQuestionId = this.coachQuestionData.id;
                this.showCoachQuestion = true;
                this.coachAnswer = "";
                this.showLoader = false;
                //window.chatbase.open();
            }
        });
    }

    handleCoachAnswerChange(event) {
        this.coachAnswer = event.target.value;
    }

    handleCoachAnswerSubmit() {
        if (this.coachAnswer == null || this.coachAnswer.trim() == "") {
            return;
        }

        this.showLoader = true;
        this.showCoachQuestion = false;

        const data = {
            "question": this.coachQuestion,
            "answer": this.coachAnswer
        };
        insertCoachConversation({ data: JSON.stringify(data) }).then(result => {
            if (result) {
                //this.showLoader = false;                
                this.initiateCheckIn();
                //this.triggerHistoryRefresh();

                //this.showCoachFollowup();
                this.coachConversation.Question__c = this.coachQuestion;
                this.coachConversation.Answer__c = this.coachAnswer;
                this.coachConversations.push(this.coachConversation);
                this.coachConversation = {};

                this.coachQuestion = "";
                this.coachAnswer = "";

                //this.template.querySelector('[data-id="chatThread"]').scrollTop = this.template.querySelector('[data-id="chatThread"]').scrollHeight  +"100";
                if (this.isCheckInRequired) {
                    this.getCheckInRequired();
                }
            }
        });


        // }
    }

    triggerHistoryRefresh() {
        const refreshEvent = new CustomEvent('refreshHistory');
        this.dispatchEvent(refreshEvent);
    }

    handleFollowUpButtonYes() {
        this.showFollowUpMessage = false;
        this.showLoader = true;
        this.getCoachQuestion();
    }
    handleFollowUpButtonNo() {
        this.showThankYouMessage = true;
        this.showFollowUpMessage = false;
    }

    showCoachFollowup() {
        this.showFollowUpMessage = true;
        this.showLoader = false;
    }

    showToast(title, message, varinat) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: varinat,
            mode: "sticky"
        });
        this.dispatchEvent(evt);
    }

    handleScroll(event) {
        const container = event.target;
        if (container.scrollTop === 0 && !this.loadingHistory) {
            this.loadMoreHistory();
        }
    }

    loadMoreHistory() {
        this.loadingHistory = true;
        getCoachConversations().then(result => {
            if (result) {
                // Simulate loading earlier messages only
                this.coachConversations = [...result, ...this.coachConversations];
            }
            this.loadingHistory = false;
            this.historyLoaded = true;
        }).catch(error => {
            // console.error('Error loading more history:', error);
            this.loadingHistory = false;
        });
        this.historyLoaded = true;
    }

}