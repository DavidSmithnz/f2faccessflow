@isTest
public class phsSurveyUserQuestionsControllerTest {
    private static Contact createContact() {
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com'
        );
        insert c;
        return c;
    }
    
    @IsTest static void testgetUserQuestionList() 
    {
        Contact c=phsSurveyUserQuestionsControllerTest.createContact(); 
        Survey__c s=new Survey__c();
        insert s;
        Survey_Question__c survey=new Survey_Question__c(Category__c='Culture',Grouping__c='Culture',Question__c='What is SFDC 12347?'+System.currentTimeMillis(),Survey__c=s.Id);
        insert survey;
        phsUserSurveyQuestions__c obj=new phsUserSurveyQuestions__c(Category__c='Culture',Grouping__c='Culture',IsActive__c=true,
                                                                    Question__c='What is SFDC 12347?'+System.currentTimeMillis(),SurveyQuestionId__c=survey.Id,User__c=c.Id
                                                                    ,UserAnswer__c='Agree');
        insert obj;
        
        Test.startTest();
        String results=  phsSurveyUserQuestionsController.getUserQuestionList();
        Test.stopTest();
        List<phsUserSurveyQuestions__c> listSurveyQuestions=[Select Id from phsUserSurveyQuestions__c];
        System.assertEquals(1,listSurveyQuestions.size());
        //System.assert(results.contains('SFDC'));
    }
    
    @IsTest static void testupdateSurveyAnswer() 
    {
        Contact c=phsSurveyUserQuestionsControllerTest.createContact(); 
        Survey__c s=new Survey__c();
        insert s;
        Survey_Question__c survey=new Survey_Question__c(Category__c='Culture',Grouping__c='Culture',Question__c='What is SFDC 12341?'+System.currentTimeMillis(),Survey__c=s.Id);
        insert survey;
        phsUserSurveyQuestions__c obj=new phsUserSurveyQuestions__c(Category__c='Culture',Grouping__c='Culture',IsActive__c=true,
                                                                    Question__c='What is SFDC 12341?'+System.currentTimeMillis(),SurveyQuestionId__c=survey.Id,User__c=c.Id
                                                                    ,UserAnswer__c='Agree');
        insert obj;
        Test.startTest();
        String results=  phsSurveyUserQuestionsController.updateSurveyAnswer(obj.Id,'Agree');
        Test.stopTest();
        phsUserSurveyQuestions__c record=[Select Id , UserAnswer__c from phsUserSurveyQuestions__c where Id=:obj.Id];
        System.assert(results.contains('true'));
        System.assertEquals('Agree',record.UserAnswer__c);
    }
   
}