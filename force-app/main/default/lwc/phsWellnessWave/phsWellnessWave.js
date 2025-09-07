import { LightningElement, wire, track } from 'lwc';
import getWellnessScore from '@salesforce/apex/phsWellnessWaveController.getWellnessScore';
import { generateUrl } from "lightning/fileDownload";
import getSurveyDetails from '@salesforce/apex/phsHomePageController.getSurveyDetails'; 
import getCategoryDescription from '@salesforce/apex/phsWellnessWaveController.getCategoryDescription'; 
import My_Resource from '@salesforce/resourceUrl/phsResource';

export default class PhsWellnessWave extends LightningElement {


    peopleImageUrl = My_Resource + '/WW/People.jpg';
    cultureImageUrl = My_Resource + '/WW/Culture.jpg';
    technologyImageUrl = My_Resource + '/WW/Technology.jpg';
    processImageUrl = My_Resource + '/WW/Process.jpg';
    analyticsImageUrl = My_Resource + '/WW/Analytics.jpg';
    downloadIcon = My_Resource + '/Icons/download-icon.png';
    homepageSliderImage2 = My_Resource + '/Images/homepageslideshowimages/slideshow2.avif';
    wellnessImage = My_Resource + '/Images/homepageslideshowimages/slideshow1Desktop.jpg';
    isWellnessWaveDetails=false;
    isWellnessWaveScore=true;
    progressWWProcess='';
    progressWWPeople='';
    progressWWTechnology='';
    progressWWCulture='';
    progressWWAnalytics='';
    categoryDescriptionDetails='';
    categoryTitle='';

    progressSurveyProcess='';
    progressSurveyPeople='';
    progressSurveyTechnology='';
    progressSurveyCulture='';
    progressSurveyAnalytics='';
    
    isSurveyTaken=true;
    
    wellnessObj=null;

      get bgImage(){
        return `--bg-img: url('${this.wellnessImage}')`;
      }

      surveyDetailsObj=null;
      fileDownloadUrl='';
      @wire(getSurveyDetails)
      retgetSurveyDetails({ error, data }) {
         
         if (data) {
           this.surveyDetailsObj = JSON.parse(data);
 
           if (this.surveyDetailsObj.pdfDownloadLink) {
                  this.fileDownloadUrl = generateUrl(this.surveyDetailsObj.pdfDownloadLink);                  
                }

          getWellnessScore()
                .then(result => {
                
                      if (result) {
                        this.wellnessObj = JSON.parse(result);
                        this.progressWWProcess='progress-circle progress-'+ (this.wellnessObj.Process + this.surveyDetailsObj.processScore)  * 10 ;
                        this.progressWWPeople='progress-circle progress-'+(this.wellnessObj.People +this.surveyDetailsObj.peopleScore) * 10 ;
                        this.progressWWTechnology='progress-circle progress-'+(this.wellnessObj.Technology +this.surveyDetailsObj.technologyScore)*10 ;
                        this.progressWWCulture='progress-circle progress-'+(this.wellnessObj.Culture +this.surveyDetailsObj.cultureScore)*10 ;
                        this.progressWWAnalytics='progress-circle progress-'+(this.wellnessObj.Analytics + this.surveyDetailsObj.analyticsScore)*10 ;
       

                        this.wellnessObj.Process=( this.wellnessObj.Process + this.surveyDetailsObj.processScore)/2;
                        this.wellnessObj.People=( this.wellnessObj.People + this.surveyDetailsObj.peopleScore)/2;
                        this.wellnessObj.Technology=( this.wellnessObj.Technology + this.surveyDetailsObj.technologyScore)/2;
                        this.wellnessObj.Culture=( this.wellnessObj.Culture + this.surveyDetailsObj.cultureScore)/2;
                        this.wellnessObj.Analytics=( this.wellnessObj.Analytics + this.surveyDetailsObj.analyticsScore)/2;

                        this.wellnessObj.Process=Math.round(this.wellnessObj.Process * 10) / 10;
                        this.wellnessObj.People=Math.round(this.wellnessObj.People * 10) / 10;
                        this.wellnessObj.Technology=Math.round(this.wellnessObj.Technology * 10) / 10;
                        this.wellnessObj.Culture=Math.round(this.wellnessObj.Culture * 10) / 10;
                        this.wellnessObj.Analytics=Math.round(this.wellnessObj.Analytics * 10) / 10;

                        if(this.wellnessObj.MostRecentSurvey !=null )
                        {
                          this.isSurveyTaken=true;
                        }
                        else
                        {
                          this.isSurveyTaken=false;
                        this.wellnessObj.Process=0;
                        this.wellnessObj.People=0;
                        this.wellnessObj.Technology=0;
                        this.wellnessObj.Culture=0;
                        this.wellnessObj.Analytics=0;
                        this.progressWWProcess='progress-circle progress-0' ;
                        this.progressWWPeople='progress-circle progress-0' ;
                        this.progressWWTechnology='progress-circle progress-0' ;
                        this.progressWWCulture='progress-circle progress-0' ;
                        this.progressWWAnalytics='progress-circle progress-0' ;          

                        }

                      }  
                })
                .catch(error => {
                  alert('getWellnessScore 1' + JSON.stringify(error));
                });




         } else if (error) {
           //console.log("DP: retgetSurveyDetails error : ", error);
         }
       }

       categoryDescription;
       @wire(getCategoryDescription)
       retgetCategoryDescription({ error, data }) {
          if (data) {
            this.categoryDescription = JSON.parse(data);
            
          } else if (error) {
            //console.log("DP: getCategoryDescription error : ", error);
          }
        }


      
       handleShowDetailsPeople()
       {
       // this.isWellnessWaveDetails=true;
       // this.isWellnessWaveScore=false;
       this.categoryDescriptionDetails=this.categoryDescription.People;
       this.categoryTitle='People : ';
       }

       handleShowDetailsCulture()
       {
       // this.isWellnessWaveDetails=true;
       // this.isWellnessWaveScore=false;
       this.categoryDescriptionDetails=this.categoryDescription.Culture;
        this.categoryTitle='Culture : ';
       }
       handleShowDetailsProcess()
       {
       // this.isWellnessWaveDetails=true;
       // this.isWellnessWaveScore=false;
       this.categoryDescriptionDetails=this.categoryDescription.Process;
      this.categoryTitle='Process : ';
       }
       handleShowDetailsTechnology()
       {
       // this.isWellnessWaveDetails=true;
       // this.isWellnessWaveScore=false;
        this.categoryDescriptionDetails=this.categoryDescription.Technology;
         this.categoryTitle='Technology : ';
       }
       handleShowDetailsAnalytics()
       {
       // this.isWellnessWaveDetails=true;
       // this.isWellnessWaveScore=false;
        this.categoryDescriptionDetails=this.categoryDescription.Analytics;
        this.categoryTitle='Analytics : ';
       }




       handlebacktoScore()
       {
        this.isWellnessWaveDetails=false;
        this.isWellnessWaveScore=true;
       }

       isSurveySiteShow=false;
       handleSurveyPage()
       {
       this.isWellnessWaveScore=false;
       this.isWellnessWaveDetails=false;
       this.isSurveySiteShow=true;

       }
       handleSurveyPageBack()
       {
       this.isWellnessWaveScore=true;
       this.isWellnessWaveDetails=false;
       this.isSurveySiteShow=false;

       }

}