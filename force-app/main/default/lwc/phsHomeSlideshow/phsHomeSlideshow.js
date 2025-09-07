import { LightningElement, wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import { generateUrl } from "lightning/fileDownload";
import getSurveyDetails from '@salesforce/apex/phsHomePageController.getSurveyDetails';
import getSlideShowDetails from '@salesforce/apex/phsHomePageController.getSlideShowDetails';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
//import SWIPER from '@salesforce/resourceUrl/Swiper'; // Upload SwiperJS to static resources

export default class PhsHomeSlideshow extends LightningElement {
  homepageSliderImage1Mobile = My_Resource + '/Images/homepageslideshowimages/slideshowM.webp'; //'/Images/homepageslideshowimages/slideshow1.avif';
  homepageSliderImage1Desktop = My_Resource + '/Images/homepageslideshowimages/slideshowD.jpg'; //'/Images/homepageslideshowimages/slideshow1Desktop.jpg';
  homepageSliderImage1;
  homepageSliderImage2 = My_Resource + '/Images/homepageslideshowimages/slideshow2.avif';
  // homepageSliderImage3 = My_Resource + '/Images/homepageslideshowimages/social1.jpg';
  // homepageSliderImage4 = My_Resource + '/Images/homepageslideshowimages/social3.jpg';
  swiperInstance;
  swiperInitialized = false;
  downloadIcon = My_Resource + '/Icons/download.png';
  firstName;
  message;
  slideIndex = 1;
  elements;
  timeIntervalInstance;
  fileDownloadUrl;
  surveyDetails;
  slideShowDetails;
  weeklyProgress;
  stressLevel_css = 'progress-circle progress-20';
  timeInFlowState_css = 'progress-circle progress-20';
  focusQuality_css = 'progress-circle progress-20';
  wwScoreAnalytics_css = 'progress-circle progress-20';
  wwScoreTechnology_css = 'progress-circle progress-20';
  wwScoreProcess_css = 'progress-circle progress-20';
  wwScoreCulture_css = 'progress-circle progress-20';
  wwScorePeople_css = 'progress-circle progress-20';
  stressLevel__c = 0;
  timeInFlowState__c = 0;
  focusQuality__c = 0;
  goalProgressSet = false;
  goalProgressInterval;

  get isDesktop() {
    return formFactorPropertyName === 'Large';
  }
  get isMobile() {
    return formFactorPropertyName != 'Large';
  }

  get bgImage(){
    return `--bg-img: url('${this.homepageSliderImage2}')`;
  }

  //get survery details
  @wire(getSurveyDetails)
  retSurveyDetails({ error, data }) {
    if (data) {
      this.surveyDetails = JSON.parse(data);
      if (this.surveyDetails.firstName) {
        this.firstName = this.surveyDetails.firstName;
      }
      if (this.surveyDetails.pdfDownloadLink) {
        this.fileDownloadUrl = generateUrl(this.surveyDetails.pdfDownloadLink);
      }
      if (this.surveyDetails.analyticsScore) {
        this.wwScoreAnalytics_css = 'wwScore progress-square progressAnalytics  progress-' + Math.round(this.surveyDetails.analyticsScore * 2) + '0';
        
        this.surveyDetails.analyticsScore=Math.round(this.surveyDetails.analyticsScore*10)/10;
      }
      if (this.surveyDetails.technologyScore) {
        this.wwScoreTechnology_css = 'wwScore progress-square progressTechnology progress-' + Math.round(this.surveyDetails.technologyScore * 2) + '0';
        //this.focusQuality_css='progress-circle progress-'+this.focusQuality__c+'0';
        this.surveyDetails.technologyScore=Math.round(this.surveyDetails.technologyScore*10)/10;
      }
      if (this.surveyDetails.processScore) {
        this.wwScoreProcess_css = 'wwScore progress-square progressProcess progress-' + Math.round(this.surveyDetails.processScore * 2) + '0';
        //this.focusQuality_css='progress-circle progress-'+this.focusQuality__c+'0';
         this.surveyDetails.processScore=Math.round(this.surveyDetails.processScore*10)/10;
      }
      if (this.surveyDetails.cultureScore) {
        this.wwScoreCulture_css = 'wwScore progress-square progressCulture progress-' + Math.round(this.surveyDetails.cultureScore * 2) + '0';
        //this.focusQuality_css='progress-circle progress-'+this.focusQuality__c+'0';
         this.surveyDetails.cultureScore=Math.round(this.surveyDetails.cultureScore*10)/10;
      }
      if (this.surveyDetails.peopleScore) {
        this.wwScorePeople_css = 'wwScore progress-square progressPeople progress-' + Math.round(this.surveyDetails.peopleScore * 2) + '0';
        //this.focusQuality_css='progress-circle progress-'+this.focusQuality__c+'0';
         this.surveyDetails.peopleScore=Math.round(this.surveyDetails.peopleScore*10)/10;
      }
    } else if (error) {
      //console.log("ij: surveydetails error is ", error);
    }
  }

  @wire(getSlideShowDetails)
  retSlideShowDetails({ error, data }) {
    if (data) {
      this.slideShowDetails = data;
    } else if (error) {
      //console.log("ij: slideShowDetails error is ", error);
    }
  }


  connectedCallback() {
    this.setBackgroundImages();
    this.setGoalsSlide();
    //this.carousel();
  }

  renderedCallback() {

    this.initSwiper();
  }

  setBackgroundImages() {
    if (this.isMobile) {
      this.homepageSliderImage1 = this.homepageSliderImage1Mobile;
    }
    else {
      this.homepageSliderImage1 = this.homepageSliderImage1Desktop;
    }
  }

  setGoalsSlide() {
    if (!this.goalProgressInterval) {
      this.goalProgressInterval = setInterval(() => {
        if (sessionStorage) {
          if (sessionStorage.getItem("goalFocusQuality")) {
            this.focusQuality__c = sessionStorage.getItem("goalFocusQuality");
            this.focusQuality_css = 'progress-circle progress-' + this.focusQuality__c + '0';
          }
          if (sessionStorage.getItem("goalTimeInFlowState")) {
            this.timeInFlowState__c = sessionStorage.getItem("goalTimeInFlowState");
            this.timeInFlowState_css = 'progress-circle progress-' + this.timeInFlowState__c + '0';
          }
          if (sessionStorage.getItem("goalStressLevel")) {
            this.stressLevel__c = sessionStorage.getItem("goalStressLevel");
            this.stressLevel_css = 'progress-circle progress-' + this.stressLevel__c + '0';
          }
          this.goalProgressSet = true;
          clearInterval(this.goalProgressInterval);
        }
      }, 2000);
    }
  }

  get getFirstCardBackgroundImage() {
    return `background:url("${this.homepageSliderImage1}") no-repeat center`;
  }

  barStyling(score) {
    return 'width:' + (score * 60) + '%';
  }

  carousel() {
    if (!this.timeIntervalInstance) {
      this.timeIntervalInstance = setInterval(() => {
        var i;
        if (this.elements) { var x = this.elements; }
        else {
          var x = this.template.querySelectorAll('.card-item');
        }
        for (i = 0; i < x.length; i++) {
          x[i].style.display = "none";
        }
        this.slideIndex++;
        if (this.slideIndex > x.length) { this.slideIndex = 1 }
        x[this.slideIndex - 1].style.display = "block";
      }, 7000);
    }
  }

  initSwiper() {
    if (this.swiperInitialized || !this.slideShowDetails) return;

    this.swiperInitialized = true;

    // Delay to ensure DOM is painted
    Promise.all([
      loadScript(this, My_Resource + '/Scripts/swiper-bundle.min.js'),
      loadStyle(this, My_Resource + '/Scripts/swiper-bundle.min.css')
    ]).then(() => {
      setTimeout(() => {
        const container = this.template.querySelector('.swiper');
        new window.Swiper(container, {
          loop: true,
          autoplay: {
            delay: 7000,
            disableOnInteraction: false,
          },
          navigation: {
            nextEl: container.querySelector('.swiper-button-next'),
            prevEl: container.querySelector('.swiper-button-prev'),
          },
          pagination: {
            el: container.querySelector('.swiper-pagination'),
            clickable: true,
          },
        });
      }, 0);
    });
  }

}