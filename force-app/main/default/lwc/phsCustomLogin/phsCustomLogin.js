import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import My_Resource from '@salesforce/resourceUrl/phsResource';
import isGuest from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';

const LOGINPAGEREF = {
    type: 'standard__webPage',
    attributes: {
        url: "/login"
    }
};

export default class PhsCustomLogin extends NavigationMixin(LightningElement) { 
    loginImage = My_Resource + '/Images/login-image.webp';
    f2flogo = My_Resource + '/Icons/F2flogo.png';

    navigateToLogin(){
        window.location.replace(basePath+'/login');
          
    }

    get bgImageStyle() {
        return 'background: url('+this.loginImage+') center/cover no-repeat';
    }

    navigateToHome()
    {
        window.location.replace(basepath);
    }     

    connectedCallback()
    {
        if(!isGuest)
        {
            this.navigateToHome();
        }
    }
    
}