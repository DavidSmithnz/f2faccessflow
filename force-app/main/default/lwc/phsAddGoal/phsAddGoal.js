import { LightningElement } from 'lwc';

export default class PhsAddGoal extends LightningElement {

    focusArea ="";
    goalName= "";
    goalType= "";
    goalStrategy= "";
    

    handlefocusAreaChange(event){
        this.focusArea = event.target.value;
    } 

    handlegoalNameChange(event){
        this.goalName = event.target.value;
    } 

    
    
    handleGoalTypeManager(){
        this.goalType = 'Manager';
    } 
    handleGoalTypeIndividual(){
        this.goalType = 'Individual';
    } 
    handleGoalTypeOrganization(){
        this.goalType = 'Organization';
    } 

    handlegoalStrategyChange(event){
        this.goalStrategy = event.target.value;
    } 

    handleAddGoal() {

        alert('Focus '+ this.focusArea);
        alert('Name '+ this.goalName);
        alert('Type '+ this.goalType);
        alert('Stretagy '+ this.goalStrategy);
        
    }
    
    handleCancelGoal() {
        alert('Cancel ');
    }
}