import { LightningElement } from 'lwc';

export default class PhsCoachHome extends LightningElement {

    connectedCallback(){

    }

    get isFriday() {
        const today = new Date();
        return today.getDay() === 5; // 5 = Friday
    }

    
}