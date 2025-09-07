import { LightningElement } from 'lwc';
import getOnBoardingStatus from '@salesforce/apex/phsOnboardingController.getOnBoardingStatus';
import getOnBoardingQuestions from '@salesforce/apex/phsOnboardingController.getOnBoardingQuestions';
import addUpdateOnBoardingUserAnswer from '@salesforce/apex/phsOnboardingController.addUpdateOnBoardingUserAnswer';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import basePath from '@salesforce/community/basePath';

export default class PhsOnBoardingQuestion extends LightningElement {

    f2flogo = My_Resource + '/Icons/F2flogo.avif';

     connectedCallback() {
    const toastContainer = ToastContainer.instance();
    toastContainer.maxShown = 3;
    toastContainer.toastPosition = 'top-center';
  }
  showToast(title, message, varinat) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: varinat
    });
    this.dispatchEvent(evt);
  }

    onBoardingQuestionList=[];
    userAnswerList=[];
    

 constructor() {
        super();
               getOnBoardingQuestions().then(result =>{

                                    // console.log('DP getOnBoardingQuestions  : ',result);
                                    this.onBoardingQuestionList=JSON.parse(result);


                                }).catch(error =>{ 
                                  // console.log('DP getOnBoardingQuestions  : ',error);
                                });

 }
handle_submit()
{
    let isQuestionAnswer=false;
    this.userAnswerList=[];

    for(var i=0;i<this.onBoardingQuestionList.length;i++)
        {
            let QId=this.onBoardingQuestionList[i].Id;
            let OId='';
            let userAnswer='';
            let userAnswerId='';
            
            isQuestionAnswer=false;
            for(var j=0;j<this.onBoardingQuestionList[i].Options.length;j++)
            {
            var QId_OptionId=this.onBoardingQuestionList[i].Options[j].QId_OptionId;
            OId=this.onBoardingQuestionList[i].Options[j].Id;
            var quesSelection=this.template.querySelector('[data-id="'+OId+'"]');
            if(quesSelection.checked==true)
            {
            isQuestionAnswer=true;
            //userAnswer=OId;
            
                 if(this.onBoardingQuestionList[i].IsMultiChoice==true)
                 {
                    userAnswer=userAnswer+quesSelection.value+",";
                    userAnswerId=userAnswerId+OId+",";
                 }
                 else
                 {
                    userAnswer=quesSelection.value;
                    userAnswerId=OId;
                 }
            }


       
         }
            if(isQuestionAnswer==false)
            {
           
             this.showToast('FiveToFlow', 'Please answer all the questions', 'error');
            break;
            }
            this.userAnswerList.push({'QId':QId,'OId':userAnswerId,'UserAnswer':userAnswer});


        }
        if (isQuestionAnswer==true)
            {
                 
                // console.log('DP userAnswerList' ,this.userAnswerList);


                addUpdateOnBoardingUserAnswer({'userAnswerList': JSON.stringify(this.userAnswerList)})
                                    .then(result =>{ 
                                        // console.log('DP addUpdateOnBoardingUserAnswer  : ',result);
                                        if(JSON.parse(result)==true)
                                        {
                                            this.showToast('FiveToFlow', 'All the questions are submitted', 'success');
                                            sessionStorage.setItem('OnBoardingCompleted', true);
                                            window.location.replace(basePath);
                                           
                                        }
                                        else    {
                                        this.showToast('FiveToFlow', 'Question not submitted , please contact Admin', 'error');
                                             }
                                      })
                                    .catch(error =>{ 
                                      // console.log('DP addUpdateOnBoardingUserAnswer  : ',error);
                                         this.showToast('FiveToFlow', 'Question not submitted , please contact Admin', 'error');
                                    }); 
                
            } 

}
handle_selectionchanged(evt)
{

}

}