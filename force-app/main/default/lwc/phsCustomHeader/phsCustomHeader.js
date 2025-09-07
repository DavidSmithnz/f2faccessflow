import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import isGuest from '@salesforce/user/isGuest';
const LOGOUTPAGEREF = {
    type: "comm__loginPage",
    attributes: {
        actionName: "logout"
    }
}
const LOGINPAGEREF = {
    type: 'standard__webPage',
    attributes: {
        url: "/flogin"
    }
};

export default class PhsCustomHeader extends NavigationMixin(LightningElement) {    
    showNavigation = true;  
    

    connectedCallback()
    {        
        if(isGuest)
            {
                this.NavigateToLogin();
            }
    }

    NavigateToLogin()
    {
        sessionStorage.clear();
        this[NavigationMixin.Navigate](LOGINPAGEREF);        
    }
}