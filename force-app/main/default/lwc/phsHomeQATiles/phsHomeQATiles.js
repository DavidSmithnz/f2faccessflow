import { LightningElement } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/phsResource';

export default class PhsHomeQATiles extends LightningElement {
    imgTips = My_Resource+ '/Images/homeQATiles/imgQuickLinks.png';
    imgCommunity = My_Resource + '/Images/homeQATiles/imgCommunity.png';
    imgEvents = My_Resource + '/Images/homeQATiles/imgEvents1.png';      
}