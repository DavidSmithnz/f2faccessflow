import { LightningElement } from 'lwc';
import getUserQuestionList from '@salesforce/apex/phsSurveyUserQuestionsController.getUserQuestionList';
import updateSurveyAnswer from '@salesforce/apex/phsSurveyUserQuestionsController.updateSurveyAnswer';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent  } from 'lightning/platformShowToastEvent';
export default class PhsWellnessCheckin extends LightningElement {
    userQuestionList=[];
    counter=1;
    qobj=null;
    qcount=0;
    slidervalue=1;
    rightArrowImage=My_Resource+ '/Wellness/next.png';
    leftArrowImage=My_Resource+ '/Wellness/back.png';
    categorycss;
    cssCircle1;
    cssCircle2;
    cssCircle3;
    btnstatus=false;


    connectedCallback() { 
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 1;
        toastContainer.toastPosition = 'top-center';
      }
      showToast(title,message,varinat) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: varinat
        });
        this.dispatchEvent(evt);
      }
      isAllAmswered=false;
    constructor() {
        super();
    //    console.log('DP Constructor Load : ','Test');

       getUserQuestionList()
                   .then(result => {
                     this.userQuestionList= JSON.parse( result);                    
                        this.qobj=this.userQuestionList.find(el=>el.rowNo==this.counter);
                        // console.log('DP qlist : ',this.userQuestionList);
                        this.qobj.Question = this.qobj.Question.replace('<p>', '').replace('</p>', '');
                        this.qcount=this.userQuestionList.length;
                        this.cssLoad(this.qobj.Category);
                        this.cssCircle1='dotfilled';
                        this.cssCircle2='dotblank';
                        this.cssCircle3='dotblank';
                        this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
                        // console.log('DP Array Length : ',this.qcount);
                        let answeredcount=0;
                        this.userQuestionList.forEach(element => {
                            if( element.UserAnswer!=null)
                            {
                                answeredcount=answeredcount+1;
                            }
                         
                       });
                    //    console.log('DP Ans Count : ' , answeredcount);
                       if(answeredcount==3)
                       {
                        this.isAllAmswered=true;

                       }
                    })
                   .catch(error => {
                     
                   });

      }

      cssLoad(cat)
      {
        if(cat=='People')
        {
            this.categorycss='inner-survey-container-people';
        }
        else if (cat=='Culture')
            {
                this.categorycss='inner-survey-container-culture';
            }
            else if (cat=='Process')
                {
                    this.categorycss='inner-survey-container-process';
                }
                else if (cat=='Technology')
                    {
                        this.categorycss='inner-survey-container-technology';
                    }
                    else if (cat=='Analytics')
                        {
                            this.categorycss='inner-survey-container-analytics';
                        }
            
      }

      cssbtn_StronglyDisagree;
      cssbtn_Disagree;
      cssbtn_Neutral;
      cssbtn_Agree;
      cssbtn_StronglyAgree;
      
      cssSelectedAnswerbtn(answer)
      {
        if(answer=='' || answer==null)
        {
            this.cssbtn_StronglyDisagree='btn-size';
            this.cssbtn_Disagree='btn-size';
            this.cssbtn_Neutral='btn-size';
            this.cssbtn_Agree='btn-size';
            this.cssbtn_StronglyAgree='btn-size';   
        }
        else if (answer=='Strongly Disagree')
        {
            this.cssbtn_StronglyDisagree='btn-size-selected';
            this.cssbtn_Disagree='btn-size';
            this.cssbtn_Neutral='btn-size';
            this.cssbtn_Agree='btn-size';
            this.cssbtn_StronglyAgree='btn-size';  
        }
        else if (answer=='Disagree')
            {
                this.cssbtn_StronglyDisagree='btn-size';
                this.cssbtn_Disagree='btn-size-selected';
                this.cssbtn_Neutral='btn-size';
                this.cssbtn_Agree='btn-size';
                this.cssbtn_StronglyAgree='btn-size';  
            }
            
        else if (answer=='Neutral')
            {
                this.cssbtn_StronglyDisagree='btn-size';
                this.cssbtn_Disagree='btn-size';
                this.cssbtn_Neutral='btn-size-selected';
                this.cssbtn_Agree='btn-size';
                this.cssbtn_StronglyAgree='btn-size';  
            }
            
        else if (answer=='Agree')
            {
                this.cssbtn_StronglyDisagree='btn-size';
                this.cssbtn_Disagree='btn-size';
                this.cssbtn_Neutral='btn-size';
                this.cssbtn_Agree='btn-size-selected';
                this.cssbtn_StronglyAgree='btn-size';  
            }
            
        else if (answer=='Strongly Agree')
            {
                this.cssbtn_StronglyDisagree='btn-size';
                this.cssbtn_Disagree='btn-size';
                this.cssbtn_Neutral='btn-size';
                this.cssbtn_Agree='btn-size';
                this.cssbtn_StronglyAgree='btn-size-selected';  
            }
      }

      handle_StronglyDisagree()
      {
        if(this.btnstatus==false)
        {
            this.btnstatus=true;
        
        this.qobj.UserAnswer='Strongly Disagree';
        updateSurveyAnswer({qid:this.qobj.Id,answer:this.qobj.UserAnswer}).then(result=>{
            // console.log('DP User Answer Update : ',JSON.parse(result));
                if(JSON.parse(result)==true)
                {
                    this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
                    this.showToast('FiveToFlow','Selection Submitted Successfully','success');
                    this.btnstatus=false;
                }}
        ).catch(ex=> {
            // console.log('DP updateSurveyAnswer : ',JSON.parse(ex));
            this.btnstatus=false;
        });
       
    } 
    }
      handle_Disagree()
      {
        if(this.btnstatus==false)
            {
                this.btnstatus=true;
            
        this.qobj.UserAnswer='Disagree';
        updateSurveyAnswer({qid:this.qobj.Id,answer:this.qobj.UserAnswer}).then(result=>{
            // console.log('DP User Answer Update : ',JSON.parse(result));
                if(JSON.parse(result)==true)
                {
                    this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
                    this.showToast('FiveToFlow','Selection Submitted Successfully','success');
                    this.btnstatus=false;
                }}
        ).catch(ex=> {
            // console.log('DP updateSurveyAnswer : ',JSON.parse(ex));
            this.btnstatus=false;
        });
      }
    }
      handle_Neutral()
      { if(this.btnstatus==false)
        {
            this.btnstatus=true;
        this.qobj.UserAnswer='Neutral';
        updateSurveyAnswer({qid:this.qobj.Id,answer:this.qobj.UserAnswer}).then(result=>{
            // console.log('DP User Answer Update : ',JSON.parse(result));
                if(JSON.parse(result)==true)
                {
                    this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
                    this.showToast('FiveToFlow','Selection Submitted Successfully','success');
                    this.btnstatus=false;
                }}
        ).catch(ex=> {
            // console.log('DP updateSurveyAnswer : ',JSON.parse(ex));
            this.btnstatus=false;
        });
        
    }this.btnstatus=false;
      }
      handle_Agree()
      {
        if(this.btnstatus==false)
            {
                this.btnstatus=true;
        this.qobj.UserAnswer='Agree';
        updateSurveyAnswer({qid:this.qobj.Id,answer:this.qobj.UserAnswer}).then(result=>{
            // console.log('DP User Answer Update : ',JSON.parse(result));
                if(JSON.parse(result)==true)
                {
                    this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
                    this.showToast('FiveToFlow','Selection Submitted Successfully','success');
                    this.btnstatus=false;
                }}
        ).catch(ex=> {
            // console.log('DP updateSurveyAnswer : ',JSON.parse(ex));
            this.btnstatus=false;
        });
            }   
    }
      handle_StronglyAgree()
      {
        if(this.btnstatus==false)
            {
                this.btnstatus=true;
        this.qobj.UserAnswer='Strongly Agree';
        updateSurveyAnswer({qid:this.qobj.Id,answer:this.qobj.UserAnswer}).then(result=>{
            // console.log('DP User Answer Update : ',JSON.parse(result));
                if(JSON.parse(result)==true)
                {
                    this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
                    this.showToast('FiveToFlow','Selection Submitted Successfully','success');
                    this.btnstatus=false;
                }}
        ).catch(ex=> {
            // console.log('DP updateSurveyAnswer : ',JSON.parse(ex));
            this.btnstatus=false;
        });
         }
         
        }

    handleleftArrowImage()
    {
        if(this.counter > 1)
            {       
        this.counter--;
        this.qobj=this.userQuestionList.find(el=>el.rowNo==this.counter);
        this.cssLoad(this.qobj.Category);
        this.slidervalue=this.counter;
            }

    this.cssCircle1='dotblank';
    this.cssCircle2='dotblank';
    this.cssCircle3='dotblank';
    
    if(this.counter==1)
    {
        this.cssCircle1='dotfilled';
    }
    else if(this.counter==2)
    {
        this.cssCircle2='dotfilled';
    }
    else if(this.counter==3)
     {
            this.cssCircle3='dotfilled';
     }
     this.cssSelectedAnswerbtn(this.qobj.UserAnswer);

    }
    handlerightArrowImage()
    {
        if(this.counter<this.qcount)
            {
            this.counter++;
            this.qobj=this.userQuestionList.find(el=>el.rowNo==this.counter);
            this.cssLoad(this.qobj.Category);
              this.slidervalue=this.counter;
    
        }  

        this.cssCircle1='dotblank';
    this.cssCircle2='dotblank';
    this.cssCircle3='dotblank';
    
    if(this.counter==1)
    {
        this.cssCircle1='dotfilled';
    }
    else if(this.counter==2)
    {
        this.cssCircle2='dotfilled';
    }
    else if(this.counter==3)
     {
            this.cssCircle3='dotfilled';
     }
     this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
    }
    

    handle_circle1()
    {

            this.counter=1;
            this.qobj=this.userQuestionList.find(el=>el.rowNo==this.counter);
            this.qobj.Question = this.qobj.Question.replace('<p>', '').replace('</p>', '');
            this.cssLoad(this.qobj.Category);
              this.slidervalue=this.counter;
    
  

        this.cssCircle1='dotblank';
    this.cssCircle2='dotblank';
    this.cssCircle3='dotblank';
    
    if(this.counter==1)
    {
        this.cssCircle1='dotfilled';
    }
    else if(this.counter==2)
    {
        this.cssCircle2='dotfilled';
    }
    else if(this.counter==3)
     {
            this.cssCircle3='dotfilled';
     }
     this.cssSelectedAnswerbtn(this.qobj.UserAnswer);


    }
    handle_circle2()
    {
        
        this.counter=2;
        this.qobj=this.userQuestionList.find(el=>el.rowNo==this.counter);
        this.qobj.Question = this.qobj.Question.replace('<p>', '').replace('</p>', '');
        this.cssLoad(this.qobj.Category);
          this.slidervalue=this.counter;
    this.cssCircle1='dotblank';
this.cssCircle2='dotblank';
this.cssCircle3='dotblank';

if(this.counter==1)
{
    this.cssCircle1='dotfilled';
}
else if(this.counter==2)
{
    this.cssCircle2='dotfilled';
}
else if(this.counter==3)
 {
        this.cssCircle3='dotfilled';
 }
 this.cssSelectedAnswerbtn(this.qobj.UserAnswer);

    }
    handle_circle3()
    {
 
        this.counter=3;
        this.qobj=this.userQuestionList.find(el=>el.rowNo==this.counter);
        this.qobj.Question = this.qobj.Question.replace('<p>', '').replace('</p>', '');
        this.cssLoad(this.qobj.Category);
          this.slidervalue=this.counter;



    this.cssCircle1='dotblank';
this.cssCircle2='dotblank';
this.cssCircle3='dotblank';

if(this.counter==1)
{
    this.cssCircle1='dotfilled';
}
else if(this.counter==2)
{
    this.cssCircle2='dotfilled';
}
else if(this.counter==3)
 {
        this.cssCircle3='dotfilled';
 }
 this.cssSelectedAnswerbtn(this.qobj.UserAnswer);
   
    }

}