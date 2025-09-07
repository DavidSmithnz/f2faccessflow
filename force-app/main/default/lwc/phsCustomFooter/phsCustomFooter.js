import { LightningElement } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/phsResource';
import { NavigationMixin } from "lightning/navigation";

const LOGOUTPAGEREF = {
    type: "standard__webPage",
    attributes: {
        actionName: "logout",
        url: "/flogin"
    }    
};

export default class PhsCustomFooter extends NavigationMixin(LightningElement) {
    profileIcon = My_Resource + '/Icons/profile.png';
    journalIcon = My_Resource + '/Icons/book.png';
    helpIcon = My_Resource + '/Icons/help.png';
    challengesIcon = My_Resource + '/Icons/challenges.png';
    showFooter = true;  

    
    connectedCallback()
    {
        
    }

    logout()
    {
        sessionStorage.clear();
        this[NavigationMixin.Navigate](LOGOUTPAGEREF);
    }

    

    
}