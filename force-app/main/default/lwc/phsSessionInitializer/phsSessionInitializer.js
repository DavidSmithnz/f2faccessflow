import { LightningElement, wire, track } from 'lwc';
import getUserPerformanceDetails from '@salesforce/apex/phsUserPerformanceController.getUserPerformanceDetails';
import getUserGoalList from '@salesforce/apex/phsUserGoalsController.getUserGoalList';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getContactDetails from '@salesforce/apex/phsHeaderController.getContactDetails';
import addUserGoal from '@salesforce/apex/phsUserGoalsController.addUserGoal';
import { NavigationMixin } from "lightning/navigation";
import My_Resource from '@salesforce/resourceUrl/phsResource';
import basePath from '@salesforce/community/basePath';

const LOGOUTPAGEREF = {
  type: "comm__loginPage",
  attributes: {
    actionName: "logout"
  }
};

export default class PhsSessionInitializer extends NavigationMixin(LightningElement) {
  contactDetails;
  userPerformanceDetails;
  chatBaseMetadata = {};
  stressLevel__c = "NA";
  timeInFlowState__c = "NA";
  focusQuality__c = "NA";
  successStories__c = "NA";
  challengesFaced__c = "NA";
  myGoals;
  myGoalsMetadata;
  myGoalsAll;
  myGoalsActive;
  NameInitial;
  userName;
  userEmail;
  showDropDown = false;
  redirectedToOnboarding = false;
  pendoAccountId = '';
  _loaded = false;
  _inited = false;
  _popHooked = false;


  profileImageUrl = My_Resource + '/Profile/profile-icon.png';
  contactusImageUrl = My_Resource + '/Profile/contact-icon.png';

  feedbackImageUrl = My_Resource + '/Profile/feedback-icon.png';
  logoutImageUrl = My_Resource + '/Profile/logout-icon.png';

  settingsImageUrl = My_Resource + '/Profile/settings-icon.png';



  @wire(getUserGoalList)
  retgetUserGoalList({ error, data }) {
    if (data) {
      this.myGoalsAll = JSON.parse(data);
      this.myGoals = this.myGoalsAll.filter(element => element.isActive == true);
      var i = 1;
      this.myGoals.map((goal) => {
        var goalName = "goal" + i + "Name";
        var goalType = "goal" + i + "Type";
        var goalStatus = "goal" + i + "Status";
        var goalFocusArea = "goal" + i + "FocusArea";
        var goalEffectiveness = "goal" + i + "Effectiveness";
        var goalAdherence = "goal" + i + "Adherence";
        if (goal.goalName)
          this.chatBaseMetadata[goalName] = goal.goalName;
        if (goal.goalType)
          this.chatBaseMetadata[goalType] = goal.goalType;
        if (goal.goalStatus)
          this.chatBaseMetadata[goalStatus] = goal.goalStatus;
        if (goal.focusArea)
          this.chatBaseMetadata[goalFocusArea] = goal.focusArea;
        if (goal.goalEffectiveness)
          this.chatBaseMetadata[goalEffectiveness] = '"' + goal.goalEffectiveness + '"';
        if (goal.goalAdherence)
          this.chatBaseMetadata[goalAdherence] = '"' + goal.goalAdherence + '"';

        i++;
      })

    } else if (error) {
      console.log("AS: getUserGoalList error is ", error);
    }
  }

  @wire(getUserPerformanceDetails)
  retgetUserPerformanceDetails({ error, data }) {
    //console.log("AS: retgetUserPerformanceDetails is ", data);
    if (data) {
      this.userPerformanceDetails = JSON.parse(data);
      //console.log("AS: getUserPerformanceDetails is ",data);

      if (this.userPerformanceDetails.stressLevel) {
        this.stressLevel__c = this.userPerformanceDetails.stressLevel;
        this.chatBaseMetadata.myStressLevel = '"' + this.stressLevel__c + '"';
        sessionStorage.setItem("goalStressLevel", this.stressLevel__c);
      }

      if (this.userPerformanceDetails.successStories) {
        this.successStories__c = this.userPerformanceDetails.successStories;
        this.chatBaseMetadata.mySuccessStories = this.successStories__c;
      }
      if (this.userPerformanceDetails.timeInFlowState) {
        this.timeInFlowState__c = this.userPerformanceDetails.timeInFlowState;
        this.chatBaseMetadata.myTimeInFlowState = '"' + this.timeInFlowState__c + '"';
        sessionStorage.setItem("goalTimeInFlowState", this.timeInFlowState__c);
      }
      if (this.userPerformanceDetails.focusQuality) {
        this.focusQuality__c = this.userPerformanceDetails.focusQuality;
        this.chatBaseMetadata.myFocusQuality = '"' + this.focusQuality__c + '"';
        sessionStorage.setItem("goalFocusQuality", this.focusQuality__c);
      }

      if (this.userPerformanceDetails.challengesFaced) {
        this.challengesFaced__c = this.userPerformanceDetails.challengesFaced;
        this.chatBaseMetadata.challengesFaced = this.challengesFaced__c;
      }

    } else if (error) {
      console.log("AS: getUserPerformanceDetails error is ", error);
    }
  }

  connectedCallback() {
    if (!(sessionStorage && sessionStorage.getItem('contactId'))) {

      this.InitializeSessionDetails();
    }
    else {
      this.pendoAccountId = sessionStorage.getItem('accountId');
      this.SetSessionDetails();
      this.postToChatBase();
      this.handlePendo();
    }

  }

  SetSessionDetails() {
    if (sessionStorage && sessionStorage.getItem("firstName")) {
      this.NameInitial = sessionStorage.getItem("firstName").charAt(0);
      this.userName = sessionStorage.getItem("firstName") + ' ' + sessionStorage.getItem("lastName");
      this.userEmail = sessionStorage.getItem("email");
    }

    if (sessionStorage && sessionStorage.getItem("email")) {
      this.userEmail = sessionStorage.getItem("email");
    }
    if (sessionStorage.getItem("OnBoardingCompleted") == "false") {
      this.redirectToOnboardingPage();
    }
  }

  InitializeSessionDetails() {
    getContactDetails().then(result => {
      if (result !== '{}') {
        const jsonResult = JSON.parse(result);
        this.contactDetails = jsonResult;

        if (this.contactDetails.id) {
          sessionStorage.setItem('contactId', this.contactDetails.id);
        }

        if (this.contactDetails.role && this.contactDetails.role != '')
          sessionStorage.setItem('role', this.contactDetails.role);
        else
          sessionStorage.setItem('role', 'Individual');

        if (this.contactDetails.firstName) {
          this.NameInitial = this.contactDetails.firstName.charAt(0);
          this.userName = this.contactDetails.firstName + ' ' + this.contactDetails.lastName;
          this.userEmail = this.contactDetails.email;
          sessionStorage.setItem('firstName', this.contactDetails.firstName);
        }

        if (this.contactDetails.email) {
          console.log('AS Email', this.contactDetails.email);
          sessionStorage.setItem('email', this.contactDetails.email);
          // this.userEmail=this.contactDetails.Email;
        }
        if (this.contactDetails.lastName)
          sessionStorage.setItem('lastName', this.contactDetails.lastName);

        if (this.contactDetails.account)
          sessionStorage.setItem('account', this.contactDetails.account);

        if (this.contactDetails.chatBaseHash)
          sessionStorage.setItem('chatBaseHash', this.contactDetails.chatBaseHash);

        if (this.contactDetails.OnBoardingCompleted != null && this.contactDetails.OnBoardingCompleted == "true") {
          sessionStorage.setItem('OnBoardingCompleted', true);
        }
        else {
          sessionStorage.setItem('OnBoardingCompleted', false);
          this.redirectToOnboardingPage();
        }
        if (this.contactDetails.accountId)
          sessionStorage.setItem('accountId', this.contactDetails.accountId);

        if (this.contactDetails.pendoApiKey)
          sessionStorage.setItem('pendoApiKey', this.contactDetails.pendoApiKey);

        this.postToChatBase();
        this.handlePendo();
      }
    })
      .catch(error => {
        console.log('Error fetching contact details: ' + error);
      })
      .finally(() => {
        //placeholder
      });
  }

  renderedCallback() {
    //this.postToChatBase();
  }

  redirectToOnboardingPage() {
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: '/onboarding'  // Replace with the actual URL for your onboarding page
      }
    });
  }

  handleLogout() {
    sessionStorage.clear();
    window.location.replace(basePath + '/secur/logout.jsp?retUrl=/flogin');
  }

  handleUserIconClick() {
    if (this.showDropDown) {
      this.showDropDown = false;
    } else {
      this.showDropDown = true;
    }
  }


  postToChatBase() {
    var contactId = sessionStorage.getItem('contactId');
    var chatBaseHash = sessionStorage.getItem('chatBaseHash');
    var temp = {};
    temp = this.chatBaseMetadata;


    //Identify user with ChatBase
    window.chatbase("identify", {
      user_id: contactId,
      user_hash: chatBaseHash,
      user_metadata: temp
    });

    //Chat Base Actions
    window.chatbase.registerTools({
      When_user_asks_to_create_a_new_goal: async (args, user) => {
        // args contains parameters defined in your custom action
        // user contains authenticated user data if identity verification is set up
        try {
          const response = await addUserGoal({ goalName: args.goalName, goalType: 'Individual', focusArea: 'Recovery Management', managerGoalId: null });
          const data = "Goals are created into system";
          return { data, status: "success" };
        } catch (error) {
          // Return only the error message without any data
          return { status: "error", message: error.message };
        }
      },
      Update_answer_of_coach_question: async (args, user) => {
        // args contains parameters defined in your custom action
        // user contains authenticated user data if identity verification is set up
        try {
          //const response = await addUserGoal({ goalName: args.goalName, goalType: 'Individual', focusArea: 'Recovery Management', managerGoalId: null });
          const data = "Answer to coach question is saved in the system. You can ask user if he wants to answer more questions";
          
          return { data, status: "success" };
        } catch (error) {
          // Return only the error message without any data
          return { status: "error", message: error.message };
        }
      },
    });
  }

  handlePendo() {
    if (this._loaded) return;

    const PENDO_KEY = sessionStorage.getItem('pendoApiKey');
    const contactId = sessionStorage.getItem('contactId');
    const accountId = sessionStorage.getItem('accountId');

    // Guard: need the API key at minimum
    if (!PENDO_KEY) {
      // eslint-disable-next-line no-console
      console.warn('Pendo: API key not found in sessionStorage');
      return;
    }

    const PENDO_URL = `https://cdn.pendo.io/agent/static/${PENDO_KEY}/pendo.js`;

    loadScript(this, PENDO_URL)
      .then(() => {
        this._loaded = true;

        // Build identity as a plain JS object (not a Map)
        const identity = {
          visitorId: contactId || 'anonymous',
          accountId: accountId || 'public'
        };

        if (this._inited) return;
        this._inited = true;

        // Sometimes the agent takes a beat to attach initialize
        if (!window.pendo || typeof window.pendo.initialize !== 'function') {
          setTimeout(() => this._init(identity), 300);
        } else {
          this._init(identity);
        }
      })
      .catch(err => {
        // eslint-disable-next-line no-console
        console.error('Pendo load/init error:', err);
      });

    // Hook SPA navigation once
    if (!this._popHooked) {
      window.addEventListener('popstate', () => this._pageLoad());
      this._popHooked = true;
    }
  }

  _init(identity) {
    try {
      window.pendo = window.pendo || {};
      if (typeof window.pendo.initialize !== 'function') {
        // Give the agent one more short retry if still not ready
        setTimeout(() => this._init(identity), 300);
        return;
      }
      window.pendo.initialize({
        visitor: { id: identity.visitorId || 'anonymous' },
        account: { id: identity.accountId || 'public' }
      });
      this._pageLoad(); // first page load
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error('Pendo initialize failed:', e);
    }
  }

  _pageLoad() {
    try {
      if (window.pendo && typeof window.pendo.pageLoad === 'function') {
        window.pendo.pageLoad();
      }
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error('Pendo pageLoad failed:', e);
    }
  }
}