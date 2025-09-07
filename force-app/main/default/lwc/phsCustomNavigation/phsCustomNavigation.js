import { LightningElement } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import { NavigationMixin } from "lightning/navigation";
import formFactorPropertyName from '@salesforce/client/formFactor';
import { RefreshEvent } from 'lightning/refresh';
import basePath from '@salesforce/community/basePath';

const LOGOUTPAGEREF = {
  type: "comm__loginPage",
  attributes: {
      actionName: "logout"
  }
};

export default class PhsCustomNavigation extends NavigationMixin(LightningElement) {
  f2flogo = My_Resource + '/Icons/F2flogo.avif';

  // courseicon = My_Resource+ '/Icons/graduation-cap.svg';
  // goalicon = My_Resource + '/Icons/goals-list.svg';
  // wwicon = My_Resource + '/Icons/ww-icon.svg';
  // coachesicon = My_Resource + '/Icons/coach-icon.svg';  

  //  courseicon = My_Resource+ '/Icons/courses_300525.svg';
   courseicon = My_Resource+ '/Icons/coach_120625.png';
  // goalicon = My_Resource + '/Icons/goals-list.svg';
  goalicon = My_Resource + '/Icons/myplan_120625.jpg';
  wwicon = My_Resource + '/Icons/ww_300525.svg';
  coachesicon = My_Resource + '/Icons/coach_300525.svg'; 


  get isDesktop() {
    return formFactorPropertyName === 'Large';
}
get isMobile() {
  return formFactorPropertyName != 'Large';
}
  connectedCallback()
  {
    
  }

  handleGoalClick(){
    if(window.location.pathname.indexOf('/goals') > -1)
    {
      this.beginRefresh();
    }
    else{
       window.location.href = basePath+'/goals';
    }
  }

  handleWWClick(){
    if(window.location.pathname.indexOf('/wwhome') > -1)
    {
      this.beginRefresh();
    }
    else{
       window.location.href = basePath+'/wwhome';
    }
  }

  beginRefresh() {
    window.location.reload();
}

    myFunction() {
        var x = document.getElementById("myTopnav");
        if (x.className === "topnav") {
          x.className += " responsive";
        } else {
          x.className = "topnav";
        }
      }

      logout()
          {
              sessionStorage.clear();
              this[NavigationMixin.Navigate](LOGOUTPAGEREF);
          }
}