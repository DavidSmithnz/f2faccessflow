import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getUserPerformanceDetails from '@salesforce/apex/phsUserPerformanceController.getUserPerformanceDetails';
import getUserGoalList from '@salesforce/apex/phsUserGoalsController.getUserGoalList';
import getUserGoalListUpdate from '@salesforce/apex/phsUserGoalsController.getUserGoalListUpdate';
import updatePerformance from '@salesforce/apex/phsUserPerformanceController.updatePerformance';
import getGoalList from '@salesforce/apex/phsGoalController.getGoalList';
import getStrategiesList from '@salesforce/apex/phsStrategyController.getStrategiesList';
import addUserGoal from '@salesforce/apex/phsUserGoalsController.addUserGoal';
import addStrategies from '@salesforce/apex/phsStrategyController.addStrategies';
import addStrategy from '@salesforce/apex/phsStrategyController.addStrategy';

import getUserGoalStrategiesList from '@salesforce/apex/phsStrategyController.getUserGoalStrategiesList';
import deleteStrategy from '@salesforce/apex/phsStrategyController.deleteStrategy';
import updateUserGoal from '@salesforce/apex/phsUserGoalsController.updateUserGoal';

import addSharedGoal from '@salesforce/apex/phsSharedGoalController.addSharedGoal';
import addSharedGoalStrategies from '@salesforce/apex/phsSharedGoalController.addSharedGoalStrategies';
import getSharedGoalList from '@salesforce/apex/phsSharedGoalController.getSharedGoalList';
import getSharedGoalStrategiesList from '@salesforce/apex/phsStrategyController.getSharedGoalStrategiesList';

import getMyTeamList from '@salesforce/apex/phsMyTeamsController.getMyTeamList';

import getMyUserPerformanceDetails from '@salesforce/apex/phsUserPerformanceController.getMyUserPerformanceDetails';
import getMyUserGoalList from '@salesforce/apex/phsUserGoalsController.getMyUserGoalList';
import updateManagerFeedback from '@salesforce/apex/phsUserGoalsController.updateManagerFeedback';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import ToastContainer from 'lightning/toastContainer';


export default class PhsMyGoals extends LightningElement {

  sliderImageUrl = My_Resource + '/Goals/Slider4.jpg';
  sliderProgressImageUrl = My_Resource + '/Goals/Slider3.jpeg';
  editIcon = My_Resource + '/Icons/edit-icon.png';
  performancekeyId = "";
  stressLevel__c = 0;
  timeInFlowState__c = 0;
  focusQuality__c = 0;
  isChecked = '';

  stressLevel_css = '';
  timeInFlowState_css = '';
  focusQuality_css = '';


  successStories__c = "";
  challengesFaced__c = "";
  userPerformanceDetails;
  myGoals;
  myGoalsAll;
  myGoalsActive;
  myGoalsInActive;
  isMyProgress = true;
  isEditProgress = false;
  isGoals = false;
  isMyTeam = false;
  isAddGoal = false;
  goallist = [];
  focusArealist = [];
  focusArealistdistinct = [];
  goalTypeListDistinct = ["Individual", "Shared"];
  goalTypeListDistinctManager = ["Individual", "Manager", "Shared"];
  goallistbyfocusarea = [];
  viewGoal;
  userGoalStrategiesData = [];
  appRole = '';
  searchKey = '';
  isManager = false;
  isShared = false;
  goalSharedBy = '';
  goalStrategyStatusList=[];
  userGoalStrategyViewValue='';

  @wire(getUserPerformanceDetails)
  retgetUserPerformanceDetails({ error, data }) {
    // console.log("DP: retgetUserPerformanceDetails is ", data);
    if (data) {
      this.userPerformanceDetails = JSON.parse(data);
      this.appRole = this.userPerformanceDetails.appRole;

      // console.log("DP: approle : ", this.appRole);

      // console.log("DP: userPerformanceDetails : ", this.userPerformanceDetails);

      if (this.appRole == 'Team Manager' || this.appRole == 'Project Manager') {
        this.isManager = true;
      }

      this.performancekeyId = this.userPerformanceDetails.keyId;
    //  if (this.userPerformanceDetails.stressLevel) 
        {
        this.stressLevel__c = this.userPerformanceDetails.stressLevel;
        this.stressLevel_css = 'progress-circle progress-' + Math.round(this.stressLevel__c) + '0';

      }

      if (this.userPerformanceDetails.successStories) 
        {
        this.successStories__c = this.userPerformanceDetails.successStories;

      }
   //   if (this.userPerformanceDetails.timeInFlowState) 
        {
        this.timeInFlowState__c = this.userPerformanceDetails.timeInFlowState;

        this.timeInFlowState_css = 'progress-circle progress-' + Math.round(this.timeInFlowState__c) + '0';
        // console.log('DP CSS : ',this.timeInFlowState_css);
      }
    //  if (this.userPerformanceDetails.focusQuality) 
        {
        this.focusQuality__c = this.userPerformanceDetails.focusQuality;
        this.focusQuality_css = 'progress-circle progress-' + Math.round(this.focusQuality__c) + '0';

      }
      if (this.userPerformanceDetails.challengesFaced) {
        this.challengesFaced__c = this.userPerformanceDetails.challengesFaced;
      }

    } else if (error) {
      // console.log("DP: getUserPerformanceDetails error is ", error);
    }
  }


  @wire(getUserGoalList)
  retgetUserGoalList({ error, data }) {
    // console.log("DP: getUserGoalList is ", data);
    if (data) {
      this.myGoalsAll = JSON.parse(data);
      this.myGoals = this.myGoalsAll.filter(element => element.GoalStrategyStatus == 'In Progress');
      if(this.myGoals.length==0)
      {
         this.myGoals = this.myGoalsAll;
      }
      // console.log("DP: getUserGoalListfilter is ", this.myGoals);
    } else if (error) {
      // console.log("DP: getUserGoalList error is ", error);
    }
  }

  handlesgoaloption(event) {
    const goaloption = event.target.value;
    // console.log('Option : ', goaloption);
    if (goaloption === 'InProgress') {
      this.myGoals = this.myGoalsAll.filter(element => element.GoalStrategyStatus == 'In Progress');
      this.isMyProgress = false;
      this.isGoals = true;
      this.isAddGoal = false;
      this.isViewGoal = false;
      this.isEditProgress = false;
      this.isMyTeam = false;
    }
    else if (goaloption === 'SharedGoals') {
      this.myGoals = this.myGoalsAll.filter(element => element.SharedBy != null);
      this.isMyProgress = false;
      this.isGoals = true;
      this.isAddGoal = false;
      this.isViewGoal = false;
      this.isEditProgress = false;
      this.isMyTeam = false;

    }
    else if (goaloption === 'Established') {
      this.myGoals = this.myGoalsAll.filter(element => element.GoalStrategyStatus == 'Established');
      this.isMyProgress = false;
      this.isGoals = true;
      this.isAddGoal = false;
      this.isViewGoal = false;
      this.isEditProgress = false;
      this.isMyTeam = false;
    }
        else if (goaloption === 'Deactivated') {
      this.myGoals = this.myGoalsAll.filter(element => element.GoalStrategyStatus == 'Deactivated');
      this.isMyProgress = false;
      this.isGoals = true;
      this.isAddGoal = false;
      this.isViewGoal = false;
      this.isEditProgress = false;
      this.isMyTeam = false;
    }
    else if (goaloption === 'AllGoals') {
      this.myGoals = this.myGoalsAll;
      this.isMyProgress = false;
      this.isGoals = true;
      this.isAddGoal = false;
      this.isViewGoal = false;
      this.isEditProgress = false;
      this.isMyTeam = false;

    }
  }
  handleclickAll() {
    this.myGoals = this.myGoalsAll;
    this.isMyProgress = false;
    this.isGoals = true;
    this.isAddGoal = false;
    this.isViewGoal = false;
    this.isEditProgress = false;
    this.isMyTeam = false;

  }
  handleclickActive() {
    this.myGoals = this.myGoalsAll.filter(element => element.GoalStrategyStatus == 'In Progress');
    this.isMyProgress = false;
    this.isGoals = true;
    this.isAddGoal = false;
    this.isViewGoal = false;
    this.isEditProgress = false;
    this.isMyTeam = false;
    this.isMyTeamUserView = false;
    this.isMyTeamUserProgress = false;
    this.template.querySelector('.tab1')?.classList.remove('selected');
    this.template.querySelector('.tab3')?.classList.remove('selected');
    this.template.querySelector('.tab2')?.classList.add('selected');
  }
  myTeamList = [];
  handleclickMyTeam() {
    // this.myGoals = this.myGoalsAll.filter(element => element.isActive==false);
    this.isMyProgress = false;
    this.isGoals = false;
    this.isAddGoal = false;
    this.isViewGoal = false;
    this.isEditProgress = false;
    this.isMyTeam = true;
    this.isMyTeamUserProgress = false;
    this.isMyTeamUserView = false;
    this.template.querySelector('.tab1')?.classList.remove('selected');
    this.template.querySelector('.tab2')?.classList.remove('selected');
    this.template.querySelector('.tab3')?.classList.add('selected');


    getMyTeamList().then(result => {

      // console.log('DP My Team List : ', result);
      this.myTeamList = JSON.parse(result);

    }).catch(ex => {

      // console.log('DP My Team List Error', ex);
    });
  }

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


  handleclickMyProgress() {
    this.isMyProgress = true;
    this.isEditProgress = false;
    this.isGoals = false;
    this.isAddGoal = false;
    this.isViewGoal = false;
    this.isViewGoal = false;
    this.isMyTeam = false;
    this.isMyTeamUserView = false;
    this.isMyTeamUserProgress = false;
    this.template.querySelector('.tab3')?.classList.remove('selected');
    this.template.querySelector('.tab2')?.classList.remove('selected');
    this.template.querySelector('.tab1')?.classList.add('selected');
  }

  topFunction() {
    const scrollOptions = {
      left: 0,
      top: 0,
      behavior: 'smooth'
    }
    window.scrollTo(scrollOptions);
  }

  handleclickEditProgress() {
    this.isGoals = false;
    this.isMyProgress = false;
    this.isEditProgress = true;
    this.isAddGoal = false;
    this.isViewGoal = false;
    this.isMyTeam = false;
    this.isMyTeamUserView = false;
    this.topFunction();
  }
  isAddJournalChallenge=false;
  isAddJournalSuccessStory=false;
  handleAddJournalChallenge()
  {
    this.isAddJournalChallenge=true;
  }
    handleSaveJournalChallenge()
  {
    this.handleclickEditSave();
    this.isAddJournalChallenge=false;
  }
    handleCancelJournalChallenge()
  {
    this.isAddJournalChallenge=false;
  }

handleAddJournalSuccessStory()
  {
    this.isAddJournalSuccessStory=true;
  }
    handleSaveJournalSuccessStory()
  {
    this.handleclickEditSave();
    this.isAddJournalSuccessStory=false;
  }
    handleCancelJournalSuccessStory()
  {
    this.isAddJournalSuccessStory=false;
  }


  handleclickEditSave() {
    updatePerformance({
      upId: this.performancekeyId, stressLevel: this.stressLevel__c, focusQuality: this.focusQuality__c,
      timeInFlowState: this.timeInFlowState__c, challengesFaced: this.challengesFaced__c, successStories: this.successStories__c
    })
      .then(result => {
        // alert( JSON.stringify( result));
        this.showToast('Progress Updated Successfully', ' ', 'success');
      })
      .catch(error => {
        //alert('Error'+  JSON.stringify(error) );
        this.showToast('Progress Failed to Update', ' ', 'error');
      });


    this.isMyProgress = true;
    this.isEditProgress = false;
    this.isMyTeam = false;
    this.topFunction();
  }

  handleclickEditCancel() {
    this.isMyProgress = true;
    this.isEditProgress = false;
    this.isAddGoal = false;
    this.isMyTeam = false;
    this.topFunction();
  }

  handlestreelevelChange(event) {
    this.stressLevel__c = event.target.value;
    this.stressLevel_css = 'progress-circle progress-' + this.stressLevel__c + '0';
  }
  handlefocusQualityChange(event) {
    this.focusQuality__c = event.target.value;
    this.focusQuality_css = 'progress-circle progress-' + this.focusQuality__c + '0';
  }
  handlefflowstateChange(event) {
    this.timeInFlowState__c = event.target.value;
    this.timeInFlowState_css = 'progress-circle progress-' + this.timeInFlowState__c + '0';
  }
  handlechallengesfacedChange(event) {
    this.challengesFaced__c = event.target.value;
  }
  handlesuccessstoryChange(event) {
    this.successStories__c = event.target.value;
  }


  handlesaddgoals() {
    this.isMyProgress = false;
    this.isEditProgress = false;
    this.isGoals = false;
    this.isAddGoal = true;
    this.isMyTeam = false;
    this.userSelectedStrategies = [];
  }

  focusArea = "";
  goalNameId = "";
  goalName = "";
  goalType = "";
  goalStrategy = "";

  handleGoalTypeChange(event) {
    const selectedGoal = event.target.value;
    if (selectedGoal) {
      if (selectedGoal == "Individual")
        this.handleGoalTypeIndividual();
      else if (selectedGoal == "Manager")
        this.handleGoalTypeManager();
      else if (selectedGoal == "Shared")
        this.handleGoalTypeShared();
    }
  }

  handlefocusAreaChange(event) {
    this.focusArea = event.target.value;
    if (this.focusArea != '') {

      this.goallistbyfocusarea = this.goallist.filter(element => element.focusAreaName == this.focusArea);
    }

    else {
      this.goallistbyfocusarea = [];
    }

  }
  isAddCustomGoal = false;
  goalStrategies = [];

  handlegoalNameChange(event) {
   // this.goalCustomStrategyDesc='';
    this.strategyDescription='';

    this.userSelectedStrategies = [];
    this.goalNameId = event.target.value;

    if (this.goalNameId == 'addCustomGoal') {
      this.isAddCustomGoal = true;
      this.goalName='';
this.goalStrategies=[];

    }
    else {
      if (this.goalNameId == '' || this.goalNameId == 'addCustomGoal') {
        this.goalStrategies = [];
      }
      else {
        this.goalName = this.goallist.find(e => e.goalId == this.goalNameId).goalName;
        this.goalSharedBy = this.goallist.find(e => e.goalId == this.goalNameId).SharedBy;
        this.isAddCustomGoal = false;
        //get strategies 


        if (this.isShared) {
          getSharedGoalStrategiesList({ goalId: this.goalNameId })
            .then(result => {
              this.goalStrategies = JSON.parse(result);
              if (this.goalStrategies.length > 0) {
              }
            })
            .catch(error => {
              // console.log('Error 1' , JSON.stringify(error));
            });
        }
        else {
          // console.log('DP Goal ID : ', this.goalNameId);
          getStrategiesList({ goalId: this.goalNameId })
            .then(result => {
              this.goalStrategies = JSON.parse(result);
              if (this.goalStrategies.length > 0) {
              }
            })
            .catch(error => {
              // console.log('Error 1' , JSON.stringify(error));
            });
        }

      }
    }
  }


  handlecustomgoalNameChange(event) {
    if (this.goalNameId == 'addCustomGoal') {
    //  this.goalNameId = event.target.value;
      this.goalName = event.target.value;
    }

  }



  handleGoalTypeManager() {
    this.isShared = false;
    this.goallist = [];
    this.focusArealistdistinct = [];
    this.goallistbyfocusarea = [];
    this.goalStrategies = [];
    this.userSelectedStrategies = [];
    this.goalType = 'Manager';
    this.strategyDescription = '';
    this.addNewGoalLoad();
  }
  handleGoalTypeIndividual() {
    this.isShared = false;
    this.goallist = [];
    this.focusArealistdistinct = [];
    this.goallistbyfocusarea = [];
    this.goalStrategies = [];
    this.userSelectedStrategies = [];
    this.goalType = 'Individual';
    this.strategyDescription = '';
    this.addNewGoalLoad();


  }
  handleGoalTypeShared() {
    this.goalType = 'Shared';
    this.isShared = true;

    this.goallist = [];
    this.focusArealistdistinct = [];
    this.goallistbyfocusarea = [];
    this.goalStrategies = [];
    this.userSelectedStrategies = [];
    this.addNewSharedGoalLoad();
    this.strategyDescription = '';
    // console.log('DP Is Shared : ', this.isShared);
  }

  addNewSharedGoalLoad() {
    // console.log('DP Shared Goal : ', 'Test');
    getSharedGoalList()
      .then(result => {
        //  alert(result);
        this.goallist = JSON.parse(result);
        // console.log('DP Goal List', JSON.parse(result));
        if (this.goallist.length > 0) {


          //   this.focusArealist=this.goallist.map(t=>t.focusAreaName);

          this.goallist.map((goal) => {
            this.focusArealist.push(goal.focusAreaName);
          });

          // console.log('DP focusarea ', this.focusArealist);


          this.focusArealistdistinct = this.focusArealist.filter((item, index) => this.focusArealist.indexOf(item) === index);

          // console.log('DP focusarea filter ', this.focusArealistdistinct);
          //  alert (this.focusArealist);
        }
      })
      .catch(error => {
        // console.log('Error 1' , JSON.stringify(error));
      });

  }





  addNewGoalLoad() {
    getGoalList({ role: this.goalType })
      .then(result => {
        //  alert(result);
        this.goallist = JSON.parse(result);
        // console.log('DP Goal List', this.goallist);
        if (this.goallist.length > 0) {


          //   this.focusArealist=this.goallist.map(t=>t.focusAreaName);

          this.goallist.map((goal) => {
            this.focusArealist.push(goal.focusAreaName);
          });

          // console.log('DP focusarea ', this.focusArealist);


          this.focusArealistdistinct = this.focusArealist.filter((item, index) => this.focusArealist.indexOf(item) === index);

          // console.log('DP focusarea filter ', this.focusArealistdistinct);
          //  alert (this.focusArealist);
        }
      })
      .catch(error => {
        // console.log('Error 1' , JSON.stringify(error));
      });

  }
  changeToggle(event) {
    //alert(event.target.checked);
    // console.log('DP Is Shared :', event.target.checked);
    this.isShared = event.target.checked;
  }

  handleGoalTypeOrganization() {
    this.goalType = 'Organization';
  }

  strategyDescription = '';
  isAddCustomStrategy = false;

  handlegoalStrategyChange(event) {
    this.isCustomStrategyEntered=true;
    this.goalStrategy = event.target.value;
    // alert(this.isAddCustomStrategy);
    this.strategyDescription = '';
    if (this.goalStrategy === 'add-own') {
      this.isAddCustomStrategy = true;
      this.goalCustomStrategyName='';
      this.goalCustomStrategyDesc='';
      
    }
    else {
      if (this.goalStrategy != 'add-own' && this.goalStrategy != '') {
        this.strategyDescription = this.goalStrategies.find(el => el.strategyId == this.goalStrategy).description;
        this.isAddCustomStrategy = false;
      }
    }
    if (this.goalStrategy === '') {
      this.isAddCustomStrategy = false;
    }

  }


  goalCustomStrategyName = '';
  goalCustomStrategyDesc = '';

  handlecustomgoalStrategyChange(event) {
    if (this.goalStrategy == 'add-own') {
      this.goalCustomStrategyName = event.target.value;
    }
  }
  handlecustomgoalStrategyDescChange(event) {
    if (this.goalStrategy == 'add-own') {
      this.goalCustomStrategyDesc = event.target.value;
    }
  }

  userSelectedStrategies = [];
  isStrategyAdded = false;
  handleAddGoalStrategy() {

    this.isStrategyAdded = false;
    this.isStrategyAdded = true;
    if (this.goalStrategy == 'add-own') {

      if (this.goalCustomStrategyName != '' ) {
        if (this.userSelectedStrategies.find(element => element.strategyId == this.goalCustomStrategyName) == null) {

          if(this.userSelectedStrategies.length < 1)
          {
          this.userSelectedStrategies.push({
            strategyId: this.goalCustomStrategyName,
            strategyName: this.goalCustomStrategyName, description: this.goalCustomStrategyDesc
          });
        }
        else
        {
          this.showToast('Only one strategy allowed', ' ', 'error'); 
          return false;
        }
        }
        else
        {  if(this.userSelectedStrategies.find(element => element.strategyId == this.goalCustomStrategyName) != null)
          { 
            this.isStrageyAdded=false;
           // this.showToast('Strategy already added', ' ', 'error'); 
            return false;
          }
        }
      }
  
    }
    else {

      if (this.goalStrategy != '' && this.userSelectedStrategies.find(element => element.strategyId == this.goalStrategy) == null) {
        
        if(this.userSelectedStrategies.length < 1)
          {
        this.userSelectedStrategies.push(this.goalStrategies.find(el => el.strategyId == this.goalStrategy));
          }
          else
          {
            this.showToast('Only one strategy allowed', ' ', 'error'); 
            return false;
          }
      }
      else
      {
        if(this.userSelectedStrategies.find(element => element.strategyId == this.goalStrategy) != null)
        {
          this.isStrageyAdded=false;
          //this.showToast('Strategy already added', ' ', 'error');
          return false;
         }
      }

    }

    if( this.goalStrategy=='')
    {
      this.isStrategy=false;
          //this.showToast('Select Strategy', ' ', 'error');
          return false;
    }
    else
    {
      if(this.goalStrategy=='add-own' && (this.goalCustomStrategyName==''  ))
      {
        this.isStrategy=false;
        //this.showToast('Select Strategy', ' ', 'error');
         return false;
      }
    }
    return true;
  }

  handleEditGoalStrategy() {
    // console.log('this.userGoalStrategiesData',this.userGoalStrategiesData);
    this.isStrategyAdded = false;
    this.isStrategyAdded = true;
    if (this.goalStrategy == 'add-own') {
      if(this.goalCustomStrategyName == '' || this.goalCustomStrategyDesc == '')
      {
        this.showToast('Enter Strategy & Description', ' ', 'error');
        return false;
      }
      if ( this.userGoalStrategiesData.find(element => element.strategyName == this.goalCustomStrategyName) == null) {

        if(this.userGoalStrategiesData.length < 2)
        {
          let deleteStrategyId= this.userGoalStrategiesData[0].strategyId;
        addStrategy({
          strategyName: this.goalCustomStrategyName, goalId: this.userGoalId,
          description: this.goalCustomStrategyDesc
        }).then(result => {

          // console.log('DP Strategy Added : ', JSON.parse(result));

          if(JSON.parse(result)==true)
          {
          getUserGoalStrategiesList({ userGoalId: this.userGoalId }).then(result => {
            // console.log("DP: getUserGoalStrategiesList is ", result);

            this.userGoalStrategiesData = JSON.parse(result);
             this.showToast('Strategy Added', ' ', 'success');

                deleteStrategy({ userGoalId: deleteStrategyId }).then(result => {
                //  console.log("DP: getUserGoalList is ", result);
                if (JSON.parse(result) === true) {
                this.userGoalStrategiesData = this.userGoalStrategiesData.filter(element => element.strategyId != deleteStrategyId);
                }
               }
              ).catch(error => {
                //  console.log('Delete Strategy : ' , JSON.parse(error));
                 return false;

              });



             return true;
          }
          ).catch(error => {
           // alert('Load Goals : ' + JSON.parse(error));
           return false;
          });
          }
          else if(JSON.parse(result)=='exists')
          {
            this.showToast('Goal-Strategy already exists', ' ', 'error'); 
            return false;
          }
          else
          {
            this.showToast('Add Strategy Failed', ' ', 'error'); 
            return false;
          }
        }

        ).catch(error => {
          // console.log('DP Strategy Error : ' ,JSON.parse(error));
          return false;

        });
      }
      else
      {
        this.showToast('Only one strategy allowed', ' ', 'error');
        return false;
      }
      }
      else{
  this.showToast('Goal-Strategy already exists', ' ', 'error'); 
return false;
      }
    }
    else {


      // console.log('DP St -', this.goalStrategies);
      // console.log('DP Name -', this.goalStrategy);

    if(this.goalStrategy=='' || this.goalStrategy==null )
    {
      this.showToast('Select Strategy', ' ', 'error');
      return false;
    }

      // console.log('Find : ', this.goalStrategies.find(element => element.strategyId == this.goalStrategy));
      let sname = this.goalStrategies.find(element => element.strategyId == this.goalStrategy).strategyName;
      if (this.goalStrategy != '' && this.userGoalStrategiesData.find(element => element.strategyName == sname) == null) {
        if(this.userGoalStrategiesData.length < 2)
          {
             let deleteStrategyId= this.userGoalStrategiesData[0].strategyId;
        addStrategy({
          strategyName: sname, goalId: this.userGoalId,
          description: this.strategyDescription
        }).then(result => {
          // console.log('DP Strategy Added : ', JSON.parse(result));
         if(JSON.parse(result)==true)
        {
          getUserGoalStrategiesList({ userGoalId: this.userGoalId }).then(result => {
            // console.log("DP: getUserGoalStrategiesList is ", result);

            this.userGoalStrategiesData = JSON.parse(result);
            this.showToast('Strategy Added', ' ', 'success');

             deleteStrategy({ userGoalId: deleteStrategyId }).then(result => {
                //  console.log("DP: getUserGoalList is ", result);
                if (JSON.parse(result) === true) {
                this.userGoalStrategiesData = this.userGoalStrategiesData.filter(element => element.strategyId != deleteStrategyId);
                }
               }
              ).catch(error => {
                // console.log('Delete Strategy : ' , JSON.parse(error));
                 return false;
              });




            return true;

          }
          ).catch(error => {
            //alert('Load Goals : ' + JSON.parse(error));
            return false;
          });
        }
      
          else if(JSON.parse(result)=='exists')
          {
            this.showToast('Goal-Strategy already exists1', ' ', 'error'); 
            return false;
          }
          else
          {
            this.showToast('Add Strategy Failed', ' ', 'error'); 
            return false;
          }         

        }

        ).catch(error => {
          // console.log('DP Strategy Error : ' , JSON.parse(error));
          return false;
        });
      }
      else
      {
          this.showToast('Only one strategy allowed', ' ', 'error');
          return false;
      }
      }
      else
      {
          this.showToast('Goal-Strategy already exists2', ' ', 'error'); 
          return false;
      }

    }
   
    //alert (this.userSelectedStrategies);
    // console.log('DP Goal Strategy : ', this.userSelectedStrategies);
     return true;
  }

  handleUserSelectedStrategyDelete() {
    let recordId = event.target.dataset.value;
    this.userSelectedStrategies = this.userSelectedStrategies.filter(el => el.strategyId != recordId);
  }


  isGoalType=true;
  isFocusArea=true;
  isGoalName=true;
  isStrategy=true;
  isStrageyAdded=true;
  existingGoalStatus='';
  handleAddGoal() {

  this.userSelectedStrategies=[];

  this.isGoalType=true;
  this.isFocusArea=true;
  this.isGoalName=true;
  this.isStrategy=true;
  this.isStrageyAdded=true;



    let SharedTo = '';
    let isSharerdBinding = '';
    if (this.isShared) {
      SharedTo = 'Team';
      isSharerdBinding = 'Shared';
    }
    // console.log('DP this.goalSharedBy : ', this.goalSharedBy);

    // console.log('DP this.goalName : ', this.goalName);

    if ( this.goalType == '' ) {
      this.isGoalType=false;
    }
     else if (this.focusArea == '' )
    {
      this.isFocusArea=false;
    }
    else if (this.goalName == '' )
    {
      this.isGoalName=false;
    }
    
 
    else {
     
      let retval= this.handleAddGoalStrategy();
     if(retval==false)
      {
        return;
      }
     
      addUserGoal({
        goalName: this.goalName, goalType: this.goalType,
        focusArea: this.focusArea, managerGoalId: null,
        StandardGoalId: this.goalNameId, SharedBy: this.goalSharedBy, SharedTo: SharedTo, isShared: this.isSharerdBinding,
        GoalStrategy:this.userSelectedStrategies[0].strategyName
      })
        .then(result => {
          //alert(JSON.parse(result));
          const usergoalId = JSON.parse(result);

          if (usergoalId.status == 'GoalExists') {
            this.existingGoalStatus=usergoalId.goalStatus;
            //this.showToast("Goal already exist with strategy", " ", "error");
            this.isStrageyAdded=false;
            return;
          }
          // console.log('Test Return ', usergoalId);
          //alert(  JSON.stringify(stratgiesdata));
          // console.log('DP Strategy List: ', this.userSelectedStrategies);


          const strategiesToAdd = [];
          for (let idx in this.userSelectedStrategies) {
            strategiesToAdd.push({
              strategyName: this.userSelectedStrategies[idx].strategyName,
              goalId: usergoalId, description: this.userSelectedStrategies[idx].description
            })
          }
          // console.log('DP Selected Strategy : ', strategiesToAdd);
          addStrategies({ data: JSON.stringify(strategiesToAdd) }).then(result => {

            this.isMyProgress = false;
            this.isGoals = true;
            this.isAddGoal = false;
            // console.log('DP getUserGoalListUpdate : ', 'Test');
            this.showToast('Goal Added Successfully', ' ', 'success');
            this.isAddCustomStrategy=false;
            getUserGoalListUpdate().then(result => {
              // console.log("DP: getUserGoalListUpdate is ", JSON.parse(result));
              this.myGoalsAll = [];
              this.myGoals = [];
              this.myGoalsAll = JSON.parse(result);

              this.myGoals = this.myGoalsAll.filter(el => el.GoalStrategyStatus == 'In Progress');
            }
            ).catch(error => {
              // console.log('Load Goals : ' , JSON.parse(error));
            });
            //add shared goals & stategies

            if (this.isShared) {
              addSharedGoal({ goalName: this.goalName, focusArea: this.focusArea }).then(result => {

                const sharedGoalId = JSON.parse(result);
                for (let s in strategiesToAdd) {
                  strategiesToAdd[s].goalId = sharedGoalId;
                }

                console.log('DP SharedGoalStrategy : ', strategiesToAdd)
                addSharedGoalStrategies({ data: JSON.stringify(strategiesToAdd) }).then(result => {

                  // console.log('DP sharedGoalStrategy response : ', result);

                }).catch(err => { 
                  // console.log('DP addShareGoalStrategy response Error : ', JSON.parse(err));
                 });


              }).catch(err => { });
              // console.log('DP addShareGoal Error : ', JSON.parse(err));

            }



          }
          ).catch(error => {
            //alert('Strategy : '+JSON.parse( error));
          });

        })
        .catch(error => {
          //alert('Goal : '+JSON.parse( error));
        });
    }
  }



  handleCancelGoal() {
    this.isMyProgress = false;
    this.isEditProgress = false;
    this.isGoals = true;
    this.isAddGoal = false;
  }

  userGoalId = '';
  handleViewGoal() {

    this.isGoalStrategyExist=false;
  this.isCustomStrategyEntered=true;
   // this.userGoalStrategyViewValue='';
    this.strategyDescription = '';
    this.isAddCustomStrategy = false;
    this.isMyProgress = false;
    this.isEditProgress = false;
    this.isGoals = false;
    this.isAddGoal = false;
    this.isViewGoal = true;
    this.userSelectedStrategies = [];
    event.preventDefault();
    let recordId = event.target.dataset.value;


    this.userGoalId = recordId;
    this.viewGoal = this.myGoalsAll.find(e => e.keyId == recordId);
    // console.log("ij inisde handle view goal record id is : ", this.viewGoal);

    this.goalStrategyStatusList=[];
    if(this.viewGoal.GoalStrategyStatus=='In Progress')
    {
      this.goalStrategyStatusList.push({statusName:'Established'});
      this.goalStrategyStatusList.push({statusName:'Deactivated'});
    }
    else if (this.viewGoal.GoalStrategyStatus=='Deactivated')
    {
      this.goalStrategyStatusList.push({statusName:'In Progress'}); 
   
    }
    else if (this.viewGoal.GoalStrategyStatus=='Established')
    {
       this.goalStrategyStatusList.push({statusName:'Deactivated'}); 
    }

    if (this.viewGoal.isActive) {
      this.isChecked = 'checked';
    }
    else {
      this.isChecked = '';
    }
    //alert(this.viewGoal.keyId);
    this.userGoalgoalAdherence = this.viewGoal.goalAdherence; 
    this.userGoalgoalEffectiveness =this.viewGoal.goalEffectiveness;
    this.userGoalgoalStrategyStatus=this.viewGoal.GoalStrategyStatus;
    getUserGoalStrategiesList({ userGoalId: recordId }).then(result => {
      // console.log("DP: getUserGoalStrategiesList is ", result);

      this.userGoalStrategiesData = JSON.parse(result);
      
    if(this.userGoalStrategiesData.length>0)
    {
    this.userGoalStrategyViewValue=this.userGoalStrategiesData[0].strategyName;
    //  console.log('TS Strategy',this.userGoalStrategyViewValue);
    }


    // console.log('DP G ID : ', this.viewGoal.StandardGoalId);
    getStrategiesList({ goalId: this.viewGoal.StandardGoalId })
      .then(result => {

        this.goalStrategies = JSON.parse(result);

    let isFound1=false;
      for (let i = 0; i < this.goalStrategies.length; i++) 
      {
      if(this.goalStrategies[i].strategyName==this.userGoalStrategyViewValue)
      {
        this.goalStrategies[i].isSelected=true;
        isFound1=true;
      }
    }
    if(isFound1==false && this.userGoalStrategyViewValue!='' && this.userGoalStrategyViewValue!=null)
    {
      this.goalStrategies.push({strategyName:this.userGoalStrategyViewValue,isSelected:true,strategyId:this.userGoalStrategyViewValue});
    }
    // console.log('Strategy IsSelected',this.goalStrategies);   


      })
      .catch(error => {
        // console.log('Error 1' , JSON.stringify(error));
      });



  });
/*
    let isFound=false;
      for (let i = 0; i < this.goalStrategies.length; i++) 
      {
      if(this.goalStrategies[i].strategyName==this.userGoalStrategyViewValue)
      {
        this.goalStrategies[i].isSelected=true;
        isFound=true;
      }
    }
    if(isFound==false && this.userGoalStrategyViewValue!='' && this.userGoalStrategyViewValue!=null)
    {
      this.goalStrategies.push({strategyName:this.userGoalStrategyViewValue,isSelected:true,strategyId:this.userGoalStrategyViewValue});
    }

    }
    ).catch(error => {
      alert('Load Goals : ' + JSON.parse(error));
    });
*/

    
  }


  userGoalgoalEffectiveness = 0;
  userGoalgoalAdherence = 0;
  userGoalActive = false;
  userGoalgoalStrategyStatus='';
   userGoalgoalStrategyStatusNewValue='';
  handleuserGoalgoalEffectiveness(event) {
    this.userGoalgoalEffectiveness = event.target.value;
    this.viewGoal.goalEffectiveness = event.target.value;
    // console.log('DP Effect Value : ', this.userGoalgoalEffectiveness);
  }
  handleuserGoalgoalAdherence(event) {
    this.userGoalgoalAdherence = event.target.value;
    this.viewGoal.goalAdherence = event.target.value;
    // console.log('DP Adh Value : ', this.userGoalgoalAdherence);
  }

  handlegoalStrategystatusChange(event) {
    this.userGoalgoalStrategyStatusNewValue = event.target.value;
    this.viewGoal.userGoalgoalStrategyStatus = event.target.value;
    // console.log('DP Strategy Status Value : ', this.userGoalgoalStrategyStatusNewValue);
  }
  handleuserGoalActive(event) {
    this.userGoalActive = event.target.checked === true;

    if (this.userGoalActive) {
      this.isChecked = 'checked';
    }
    else {
      this.isChecked = '';
    }
  }

  isGoalStrategyExist=false;
  isCustomStrategyEntered=true;

  handleSaveGoal() {

  this.isGoalStrategyExist=false;
  this.isCustomStrategyEntered=true;
        // console.log('goalStrategy',this.goalStrategy);

//if(this.userGoalStrategyViewValue!=this.goalCustomStrategyName || this.userGoalStrategyViewValue!=strategyNametemp)
if(this.goalStrategy!='' && this.goalStrategy!=null)
{
  let strategyNametemp='';
    if (this.goalStrategy == 'add-own') 
    {
    strategyNametemp=this.goalCustomStrategyName;
    }
    else
    {
    strategyNametemp=this.goalStrategies.find(el => el.strategyId == this.goalStrategy).strategyName;
    }
    // console.log('userGoalStrategyViewValue',this.userGoalStrategyViewValue);
    // console.log('goalCustomStrategyName',this.goalCustomStrategyName);
  // console.log('strategyNametemp',strategyNametemp);
    // console.log('this.goalStrategies',this.goalStrategies);

    if(strategyNametemp!=this.userGoalStrategyViewValue)
    {    
 
  if (this.goalStrategy == 'add-own') 
    {
      if(this.goalCustomStrategyName == '')
      {
       // this.showToast('Enter Strategy', ' ', 'error');
        this.isCustomStrategyEntered=false;
        return false;
      }  

       let deleteStrategyId= this.userGoalStrategiesData[0].strategyId;
        addStrategy({
          strategyName: this.goalCustomStrategyName, goalId: this.userGoalId,
          description: this.goalCustomStrategyDesc
        }).then(result => {

          // console.log('DP Strategy Added : ', JSON.parse(result));

          if(JSON.parse(result).status=='true')
          {
          getUserGoalStrategiesList({ userGoalId: this.userGoalId }).then(result => {
            // console.log("DP: getUserGoalStrategiesList is ", result);

            this.userGoalStrategiesData = JSON.parse(result);
            // this.showToast('Strategy Added', ' ', 'success');

                deleteStrategy({ userGoalId: deleteStrategyId }).then(result => {
                //  console.log("DP: getUserGoalList is ", result);
                if (JSON.parse(result) === true) {
                this.userGoalStrategiesData = this.userGoalStrategiesData.filter(element => element.strategyId != deleteStrategyId);
                  this.updateGoal();
                return;
                }
               }
              ).catch(error => {
                //  console.log('Delete Strategy : ' , JSON.parse(error));
                 return false;

              });
            }
              ).catch(error => {
           // alert('Load Goals : ' + JSON.parse(error));
           return false;
          });
        }
            else if(JSON.parse(result).status=='exists')
          {
            this.existingGoalStatus=JSON.parse(result).goalStatus;
            this.isGoalStrategyExist=true;
         //   this.showToast('Goal-Strategy already exists1', ' ', 'error'); 
            return false;
          }
          else
          {
            this.showToast('Add Strategy Failed', ' ', 'error'); 
            return false;
          }

      });
    }
      // console.log('DP St -', this.goalStrategies);
      // console.log('DP Name -', this.goalStrategy);

    if(this.goalStrategy=='' || this.goalStrategy==null )
    {
     
   //   this.showToast('Select Strategy', ' ', 'error');
      return false;
    }
 if (this.goalStrategy != 'add-own')
  { 
     let sname = this.goalStrategies.find(element => element.strategyId == this.goalStrategy).strategyName;
      let deleteStrategyId1= this.userGoalStrategiesData[0].strategyId;
        addStrategy({
          strategyName: sname, goalId: this.userGoalId,
          description: this.strategyDescription
        }).then(result => {
          // console.log('DP Strategy Added : ', JSON.parse(result));
         if(JSON.parse(result).status=='true')
        {
          getUserGoalStrategiesList({ userGoalId: this.userGoalId }).then(result => {
            // console.log("DP: getUserGoalStrategiesList is ", result);

            this.userGoalStrategiesData = JSON.parse(result);
            this.showToast('Strategy Added', ' ', 'success');

             deleteStrategy({ userGoalId: deleteStrategyId1 }).then(result => {
                //  console.log("DP: getUserGoalList is ", result);
                if (JSON.parse(result) === true) {
                this.userGoalStrategiesData = this.userGoalStrategiesData.filter(element => element.strategyId != deleteStrategyId1);
                this.updateGoal();
                }
               }
              ).catch(error => {
                // console.log('Delete Strategy : ' , JSON.parse(error));

                 return false;
              });



  }   ).catch(error => {
            //alert('Load Goals : ' + JSON.parse(error));
            return false;
          });
        }
        else if(JSON.parse(result).status=='exists')
          {
            this.existingGoalStatus=JSON.parse(result).goalStatus;
            this.isGoalStrategyExist=true;
           // this.showToast('Goal-Strategy already exists2', ' ', 'error'); 
            return false;
          }
          else
          {
            this.showToast('Add Strategy Failed', ' ', 'error'); 
            return false;
          }


        }).catch(error => {
          this.showToast('Add Strategy Failed', ' ', 'error'); 
          // console.log('DP Strategy Error : ' , JSON.parse(error));
          return false;
        });

      }
    }
       else
      {
        this.updateGoal();
      }
    
    }
  
      else
      {
        this.updateGoal();
      }
    
  }
    


  updateGoal()
  {
    
    if( this.userGoalStrategiesData.length == 0)
   {
    this.showToast('Goal does not have Strategy', ' ', 'error');
    return;
   }
    this.isGoals = true;
    this.isViewGoal = false;
    if(this.isChecked == 'checked')
    {
      this.userGoalActive = true;
    }
    else
    {this.userGoalActive = false;}

    if(this.userGoalgoalStrategyStatusNewValue=='')
    {
      this.userGoalgoalStrategyStatusNewValue=this.userGoalgoalStrategyStatus;
    }



    updateUserGoal({ usergoalId: this.userGoalId, effectiveness: this.userGoalgoalEffectiveness, adherence: this.userGoalgoalAdherence, isActive: this.userGoalActive,goalStrategyStatus:this.userGoalgoalStrategyStatusNewValue }).then(result => {
      //alert(JSON.parse(result));
      if (JSON.parse(result) == 'Updated') {
        getUserGoalListUpdate().then(result => {
          // console.log("DP: getUserGoalList is ", result);
          this.myGoalsAll = [];
          this.myGoals = [];
          this.myGoalsAll = JSON.parse(result);

          this.myGoals = this.myGoalsAll.filter(el => el.GoalStrategyStatus == 'In Progress');
          this.showToast('Goal Updated Successfully', ' ', 'success');
        }
        ).catch(error => {
          // alert('Load Goals : '+JSON.parse( error));
          this.showToast('Goal Failed to Update', ' ', 'error');
        });
      }

    }
    ).catch(error => {
       this.showToast('Goal Failed to Update', ' ', 'error');
      // console.log('Goal Update Failed : ' , error);
    }
    )

  }


  handleSaveCancelGoal() {
    this.isGoals = true;

    this.isViewGoal = false;
  }



  handleStrategyDelete() {
    let recordId = event.target.dataset.value;
    //alert(recordId);

    deleteStrategy({ userGoalId: recordId }).then(result => {
      // console.log("DP: getUserGoalList is ", result);
      if (JSON.parse(result) === true) {
        this.userGoalStrategiesData = this.userGoalStrategiesData.filter(element => element.strategyId != recordId);
      }
    }
    ).catch(error => {
      // console.log('Delete Strategy : ' , JSON.parse(error));
    });



    //   console.log('DP Goal Strategy after Filter : ',this.userGoalStrategiesData);
  }

  flagshowHideDesc = 'Show-Desc';
  showHideDesc = '';
  handleStrategyDescShowHide() {
    let recordId = event.target.dataset.value;


    const isShow = this.userGoalStrategiesData.find(el => el.strategyId == recordId).isShow;
    console.log('DP : isShow : ', isShow)
    if (isShow === true) {
      this.userGoalStrategiesData.find(el => el.strategyId == recordId).isShow = false;
    }
    else {
      this.userGoalStrategiesData.find(el => el.strategyId == recordId).isShow = true;
    }

    // console.log('DP Goal : ', this.userGoalStrategiesData.find(el => el.strategyId == recordId));


  }

  isMyTeamUserProgress = false;
  myTeamUserProgress = null;
  myTeamUserGoals = [];
  myTeamUserGoalsAll = [];
  stressLeveluser_css;
  focusQualityuser_css;
  timeInFlowStateuser_css;
  myTeamMemberName = '';
  handleViewUserGoals() {
    event.preventDefault();
    this.isMyTeam = false;
    this.isMyTeamUserProgress = true;
    this.template.querySelector('.tab1')?.classList.remove('selected');
    this.template.querySelector('.tab2')?.classList.remove('selected');
    this.template.querySelector('.tab3')?.classList.add('selected');
    let recordId = event.target.dataset.value;
    this.myTeamMemberName = this.myTeamList.find(el => el.Id == recordId).Name;
    // console.log('DP Teammember Name : ', this.myTeamMemberName);
    getMyUserPerformanceDetails({ userId: recordId }).then(result => {
      // console.log('DP getMyUserPerformanceDetails  : ', JSON.parse(result));
      this.myTeamUserProgress = JSON.parse(result);
      this.stressLeveluser_css = 'progress-circle progress-' + this.myTeamUserProgress.stressLevel + '0';
      this.focusQualityuser_css = 'progress-circle progress-' + this.myTeamUserProgress.focusQuality + '0';
      this.timeInFlowStateuser_css = 'progress-circle progress-' + this.myTeamUserProgress.timeInFlowState + '0';

    }).catch(ex => {
      //  console.log('DP getMyUserPerformanceDetails Error : ', ex)
       });

    getMyUserGoalList({ userId: recordId }).then(result => {
      // console.log('DP myTeamUserGoals  : ', JSON.parse(result));
      this.myTeamUserGoalsAll = JSON.parse(result);
      this.myTeamUserGoals = this.myTeamUserGoalsAll.filter(element => element.GoalStrategyStatus == 'In Progress');
    }).catch(ex => { 
      // console.log('DP myTeamUserGoals Error : ', ex) 
    });

  }



  handlesusergoaloption(event) {
    const goaloption = event.target.value;
    // console.log('Option : ', goaloption);
    if (goaloption === 'InProgress') {
      this.myTeamUserGoals = this.myTeamUserGoalsAll.filter(element => element.GoalStrategyStatus == 'In Progress');

    }
    else if (goaloption === 'SharedGoals') {
      this.myTeamUserGoals = this.myTeamUserGoalsAll.filter(element => element.SharedBy != null);

    }
    else if (goaloption === 'Deactivated') {
      this.myTeamUserGoals = this.myTeamUserGoalsAll.filter(element => element.GoalStrategyStatus == 'Deactivated');

    }
    else if (goaloption === 'Established') {
      this.myTeamUserGoals = this.myTeamUserGoalsAll.filter(element => element.GoalStrategyStatus == 'Established');

    }
    else if (goaloption === 'AllGoals') {
      this.myTeamUserGoals = this.myTeamUserGoalsAll;

    }
  }

  isMyTeamUserView = false;
  userMyTeamGoalStrategiesData = [];
  myTeamUserViewGoal = null;
  isMyTeamUserChecked = false;

  handleViewUserGoalDetails(event) {
    this.isMyTeamUserView = true;
    this.isMyTeamUserProgress = false;
    let recordId = event.target.dataset.value;
    // console.log('DP handleViewUserGoalDetails : ', event.target.dataset.value);
    this.myTeamUserViewGoal = this.myTeamUserGoalsAll.find(el => el.keyId == recordId);
    if (this.myTeamUserViewGoal.isActive) {
      this.isMyTeamUserChecked = 'checked';
    }
    else {
      this.isMyTeamUserChecked = '';
    }

    getUserGoalStrategiesList({ userGoalId: recordId }).then(result => {
      // console.log("DP: user getUserGoalStrategiesList is ", result);

      this.userMyTeamGoalStrategiesData = JSON.parse(result);

    }
    ).catch(error => {
      // console.log('User Load Goals : ' , JSON.parse(error));
    });

  }

  handleBackMyTeamUserGoal() {
    this.isMyTeamUserView = false;
    this.isMyTeamUserProgress = true;
  }
  handleUpdateFeedbackTeamUserGoal() {
    // console.log('DP Manager Feedback : ', this.managerFeedback);
    if (this.managerFeedback != '') {
      updateManagerFeedback({ userId: this.myTeamUserViewGoal.keyId, feedback: this.managerFeedback }).then(result => {
        // console.log('DP Feedback Update : ', result);
        this.showToast('Feedback Updated Successfully', ' ', 'success');
      }).catch(ex => {
        this.showToast('Feedback Failed to Update', ' ', 'success');
        console.log('DP Feedback Update Error: ', ex)
      });
    }
  }
  managerFeedback = '';
  handleManagerFeedbackChange(event) {
    this.managerFeedback = event.target.value;
  }

  arrowFocusArea = "arrow up";
  handleFocusAreaSorting() {
    if (this.arrowFocusArea == "arrow up") {
      this.arrowFocusArea = "arrow down";
      const sortedList = this.myGoals.sort((a, b) =>
        b.focusArea.localeCompare(a.focusArea));
      // console.log('DP MyGoal Sorting ', this.myGoals);
    }
    else {
      this.arrowFocusArea = "arrow up";
      const sortedList = this.myGoals.sort((a, b) =>
        a.focusArea.localeCompare(b.focusArea));
      // console.log(sortedList);
    }
  }

  arrowGoal = "arrow up";
  handleGoalSorting() {
    if (this.arrowGoal == "arrow up") {
      this.arrowGoal = "arrow down";
      const sortedList = this.myGoals.sort((a, b) =>
        b.goalName.localeCompare(a.goalName));
      // console.log('DP MyGoal Sorting ', this.myGoals);
    }
    else {
      this.arrowGoal = "arrow up";
      const sortedList = this.myGoals.sort((a, b) =>
        a.goalName.localeCompare(b.goalName));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }

    arrowGoalStrategy = "arrow up";
  handleStrategySorting() {
    if (this.arrowGoalStrategy == "arrow up") {
      this.arrowGoalStrategy = "arrow down";
      const sortedList = this.myGoals.sort((a, b) =>
        b.StrategyTitle.localeCompare(a.StrategyTitle));
      // console.log('DP MyGoal Sorting ', this.myGoals);
    }
    else {
      this.arrowGoalStrategy = "arrow up";
      const sortedList = this.myGoals.sort((a, b) =>
        a.StrategyTitle.localeCompare(b.StrategyTitle));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }


     arrowGoalStatus = "arrow up";
  handleStatusSorting() {
    if (this.arrowGoalStatus == "arrow up") {
      this.arrowGoalStatus = "arrow down";
      const sortedList = this.myGoals.sort((a, b) =>
        b.GoalStrategyStatus.localeCompare(a.GoalStrategyStatus));
      // console.log('DP MyGoal Sorting ', this.myGoals);
    }
    else {
      this.arrowGoalStatus = "arrow up";
      const sortedList = this.myGoals.sort((a, b) =>
        a.GoalStrategyStatus.localeCompare(b.GoalStrategyStatus));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }


  arrowEffectiveness = "arrow up";
  handleEffectivenessSorting() {
    if (this.arrowEffectiveness == "arrow up") {
      this.arrowEffectiveness = "arrow down";
      const sortedList = this.myGoals.sort((a, b) =>
        b.goalEffectiveness - a.goalEffectiveness);
      // console.log('DP MyGoal Sorting ', this.myGoals);
    }
    else {
      this.arrowEffectiveness = "arrow up";
      const sortedList = this.myGoals.sort((a, b) =>
        a.goalEffectiveness - b.goalEffectiveness);
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }


  arrowAdherence = "arrow up";
  handleAdherenceSorting() {
    if (this.arrowAdherence == "arrow up") {
      this.arrowAdherence = "arrow down";
      const sortedList = this.myGoals.sort((a, b) =>
        b.goalAdherence - a.goalAdherence);
      // console.log('DP MyGoal Sorting ', this.myGoals);
    }
    else {
      this.arrowAdherence = "arrow up";
      const sortedList = this.myGoals.sort((a, b) =>
        a.goalAdherence - b.goalAdherence);
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }

  arrowLastCheckInDate = "arrow up";
  handleLastDateSorting() {
    if (this.arrowLastCheckInDate == "arrow up") {
      this.arrowLastCheckInDate = "arrow down";
      const sortedList = this.myGoals.sort((a, b) =>
        new Date(b.CheckInDate) - new Date(a.CheckInDate));
      // console.log('DP MyGoal Sorting ', this.myGoals);
    }
    else {
      this.arrowLastCheckInDate = "arrow up";
      const sortedList = this.myGoals.sort((a, b) =>
        new Date(a.CheckInDate) - new Date(b.CheckInDate));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }


  //My Team Goal 

  arrowFocusAreaMyTeam = "arrow up";
  handleFocusAreaSortingMyTeam() {
    if (this.arrowFocusAreaMyTeam == "arrow up") {
      this.arrowFocusAreaMyTeam = "arrow down";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        b.focusArea.localeCompare(a.focusArea));
      // console.log('DP MyGoal Sorting ', this.myTeamUserGoals);
    }
    else {
      this.arrowFocusAreaMyTeam = "arrow up";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        a.focusArea.localeCompare(b.focusArea));
      // console.log(sortedList);
    }
  }

  arrowGoalMyTeam = "arrow up";
  handleGoalSortingMyTeam() {
    if (this.arrowGoalMyTeam == "arrow up") {
      this.arrowGoalMyTeam = "arrow down";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        b.goalName.localeCompare(a.goalName));
      // console.log('DP MyGoal Sorting ', this.myTeamUserGoals);
    }
    else {
      this.arrowGoalMyTeam = "arrow up";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        a.goalName.localeCompare(b.goalName));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }


  arrowStrategyMyTeam = "arrow up";
  handleStrategySortingMyTeam() {
    if (this.arrowStrategyMyTeam == "arrow up") {
      this.arrowStrategyMyTeam = "arrow down";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        b.StrategyTitle.localeCompare(a.StrategyTitle));
      // console.log('DP MyGoal Sorting ', this.myTeamUserGoals);
    }
    else {
      this.arrowStrategyMyTeam = "arrow up";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        a.StrategyTitle.localeCompare(b.StrategyTitle));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }

    arrowStatusMyTeam = "arrow up";
  handleStatusSortingMyTeam() {
    if (this.arrowStatusMyTeam == "arrow up") {
      this.arrowStatusMyTeam = "arrow down";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        b.GoalStrategyStatus.localeCompare(a.GoalStrategyStatus));
      // console.log('DP MyGoal Sorting ', this.myTeamUserGoals);
    }
    else {
      this.arrowStatusMyTeam = "arrow up";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        a.GoalStrategyStatus.localeCompare(b.GoalStrategyStatus));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }




  arrowEffectivenessMyTeam = "arrow up";
  handleEffectivenessSortingMyTeam() {
    if (this.arrowEffectivenessMyTeam == "arrow up") {
      this.arrowEffectivenessMyTeam = "arrow down";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        b.goalEffectiveness - a.goalEffectiveness);
      // console.log('DP MyGoal Sorting ', this.myTeamUserGoals);
    }
    else {
      this.arrowEffectivenessMyTeam = "arrow up";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        a.goalEffectiveness - b.goalEffectiveness);
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }


  arrowAdherenceMyTeam = "arrow up";
  handleAdherenceSortingMyTeam() {
    if (this.arrowAdherenceMyTeam == "arrow up") {
      this.arrowAdherenceMyTeam = "arrow down";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        b.goalAdherence - a.goalAdherence);
      // console.log('DP MyGoal Sorting ', this.myTeamUserGoals);
    }
    else {
      this.arrowAdherenceMyTeam = "arrow up";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        a.goalAdherence - b.goalAdherence);
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }

  arrowLastCheckInDateMyTeam = "arrow up";
  handleLastDateSortingMyTeam() {
    if (this.arrowLastCheckInDateMyTeam == "arrow up") {
      this.arrowLastCheckInDateMyTeam = "arrow down";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        new Date(b.CheckInDate) - new Date(a.CheckInDate));
      // console.log('DP MyGoal Sorting ', this.myTeamUserGoals);
    }
    else {
      this.arrowLastCheckInDateMyTeam = "arrow up";
      const sortedList = this.myTeamUserGoals.sort((a, b) =>
        new Date(a.CheckInDate) - new Date(b.CheckInDate));
      // console.log('DP MyGoal Sorting ', sortedList);
    }
  }

  arrowUserNameMyTeam = "arrow up";
  handleUserNameSortingMyTeam() {
    if (this.arrowUserNameMyTeam == "arrow up") {
      this.arrowUserNameMyTeam = "arrow down";
      const sortedList = this.myTeamList.sort((a, b) =>
        b.Name.localeCompare(a.Name));
      // console.log('DP MyTeam Sorting ', this.myTeamList);
    }
    else {
      this.arrowUserNameMyTeam = "arrow up";
      const sortedList = this.myTeamList.sort((a, b) =>
        a.Name.localeCompare(b.Name));
      // console.log('DP MyTeam Sorting ', sortedList);
    }
  }

  arrowUserTitleMyTeam = "arrow up";
  handleUserTitleSortingMyTeam() {
    if (this.arrowUserTitleMyTeam == "arrow up") {
      this.arrowUserTitleMyTeam = "arrow down";
      const sortedList = this.myTeamList.sort((a, b) =>
        b.Title.localeCompare(a.Title));
      // console.log('DP MyTeam Sorting ', this.myTeamList);
    }
    else {
      this.arrowUserTitleMyTeam = "arrow up";
      const sortedList = this.myTeamList.sort((a, b) =>
        a.Title.localeCompare(b.Title));
      // console.log('DP MyTeam Sorting ', sortedList);
    }
  }

  get goalTypeOptions() {
    return this.isManager ? this.goalTypeListDistinctManager : this.goalTypeListDistinct;
}


}