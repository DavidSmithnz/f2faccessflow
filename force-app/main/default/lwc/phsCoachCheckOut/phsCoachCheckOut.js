import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import apxIsCoachCheckOutRequired from '@salesforce/apex/phsCoachController.isCoachCheckOutRequired';
import apxGetCheckOutQuestion from '@salesforce/apex/phsCoachController.getCheckOutQuestion';
import apxInsertCheckOutConversation from '@salesforce/apex/phsCoachController.insertCheckOutConversation';
import ToastContainer from 'lightning/toastContainer';


export default class PhsCoachCheckOut extends LightningElement {

    isQuestionTypeScale = false;
    isCheckOutRequired = true;
    coachQuestion;
    //coachQuestionId;
    coachAnswer;
    userName = "";
    showFollowUpMessage = false;
    showCoachQuestion = false;
    followUpQuestion = "Friday check-out complete.";
    showThankYouMessage = false;
    showLoader = true;
    coachQuestionData;
    coachConversations = [];
    coachConversation = {};
    showAnswerTextbox = true;
    scaleLevel = 0;

    connectedCallback() {

        //this.getCheckInRequired();
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 3;
        toastContainer.toastPosition = 'top-center';

        if (true) {
            this.initiateCheckOut();
        }
    }

    renderedCallback() {
        const chatThread = this.template.querySelector('[data-id="chatThread"]');
        if (chatThread) {
            chatThread.scrollTop = chatThread.scrollHeight;
        }
        const coachInputTextBox = this.template.querySelector('[data-id="coachInputTextBox"]');
        if(coachInputTextBox)
            coachInputTextBox.value = '';
    }

    async getCheckOutRequired() {
        apxIsCoachCheckOutRequired().then(result => {
            if (result && result == true) {
                this.isCheckOutRequired = true;
                this.getCheckOutQuestion();
            }
            else {
                this.isCheckOutRequired = false;
            }
            return this.isCheckOutRequired;
        });

    }

    initiateCheckOut() {
        //this.getCheckOutRequired();
        this.getCheckOutQuestion();
    }

    isFriday() {
        const today = new Date();
        return today.getDay() === 5; // 5 = Friday
    }


    getCheckOutQuestion() {
        apxGetCheckOutQuestion().then(result => {
            if (result) {
                if (result == "Check Out Complete") {
                    this.isCheckOutRequired = false;
                    this.showToast('Friday Check-Out Complete', 'Friday check-out complete for this week', 'success');
                    this.showAnswerTextbox = false;
                    this.showThankYouMessage = true;
                }
                else {
                    this.coachQuestionData = JSON.parse(result);
                    this.coachQuestion = this.coachQuestionData.question;
                    this.coachQuestionId = this.coachQuestionData.questionId;
                    if (this.coachQuestionData.type == "Scale") {
                        this.isQuestionTypeScale = true;
                        this.scaleLevel = 0;
                    }
                    else {
                        this.isQuestionTypeScale = false;
                    }
                    this.showCoachQuestion = true;
                    this.coachAnswer = "";
                    this.showLoader = false;
                }
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
            "answer": this.coachAnswer,
            "id": this.coachQuestionId
        };
        apxInsertCheckOutConversation({ data: JSON.stringify(data) }).then(result => {
            if (result) {
                this.coachConversation.Question__c = this.coachQuestion;
                this.coachConversation.Answer__c = this.coachAnswer;
                this.coachConversations.push(this.coachConversation);
                this.coachConversation = {};
                this.coachQuestion = "";
                this.coachAnswer = "";
                this.scaleLevel = 0;
                this.getCheckOutQuestion();
            }
        });
    }



    showCoachFollowup() {
        this.showFollowUpMessage = true;
        this.showLoader = false;
    }

    handleScaleLevelChange(event) {
        this.scaleLevel = event.target.value;
        this.coachAnswer = this.scaleLevel;
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
}