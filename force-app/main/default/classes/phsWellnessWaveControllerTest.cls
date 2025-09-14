@IsTest
public class phsWellnessWaveControllerTest {
    
    private static Contact createContact() {
        Survey__c s = new Survey__c(); 
        insert s;
        
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com',
            Most_Recent_Survey__c = s.Id
        );
        insert c;
        return c;
    }
    
    @IsTest
    public static void testGetWellnessScoreTakenStatus() {
        Contact c = createContact();        
        Test.startTest();
        String result = phsWellnessWaveController.getWellnessScoreTakenStatus();
        Test.stopTest();        
        System.assertNotEquals(null, result, 'Should return JSON, not null');
    }
    
    @IsTest
    public static void testGetWellnessScore() {
        // Create Contact + Survey
        Survey__c s = new Survey__c();
        insert s;        
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com',
            Most_Recent_Survey__c = s.Id
        );
        insert c;
        
        // Insert Survey Question (assuming User__c is Contact lookup)
        phsUserSurveyQuestions__c userSurvey1 = new phsUserSurveyQuestions__c(Category__c = 'Culture',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow1.', UserAnswer__c = 'Agree');   
        phsUserSurveyQuestions__c userSurvey2 = new phsUserSurveyQuestions__c(Category__c = 'Culture',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow2.', UserAnswer__c = 'Disagree');    
        phsUserSurveyQuestions__c userSurvey3 = new phsUserSurveyQuestions__c(Category__c = 'Culture',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow3.', UserAnswer__c = 'Neutral');
        phsUserSurveyQuestions__c userSurvey4 = new phsUserSurveyQuestions__c(Category__c = 'Culture',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow4.', UserAnswer__c = 'Strongly Disagree');
        phsUserSurveyQuestions__c userSurvey5 = new phsUserSurveyQuestions__c(Category__c = 'Culture',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow5.', UserAnswer__c = 'Strongly Agree');
        
        
        phsUserSurveyQuestions__c userSurvey6 = new phsUserSurveyQuestions__c(Category__c = 'Technology',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow1.', UserAnswer__c = 'Agree');   
        phsUserSurveyQuestions__c userSurvey7 = new phsUserSurveyQuestions__c(Category__c = 'Technology',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow2.', UserAnswer__c = 'Disagree');    
        phsUserSurveyQuestions__c userSurvey8 = new phsUserSurveyQuestions__c(Category__c = 'Technology',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow3.', UserAnswer__c = 'Neutral');
        phsUserSurveyQuestions__c userSurvey9 = new phsUserSurveyQuestions__c(Category__c = 'Technology',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                              Question__c = 'I have measurable goals and degree plans to follow4.', UserAnswer__c = 'Strongly Disagree');
        phsUserSurveyQuestions__c userSurvey10 = new phsUserSurveyQuestions__c(Category__c = 'Technology',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow5.', UserAnswer__c = 'Strongly Agree');
        
        phsUserSurveyQuestions__c userSurvey11 = new phsUserSurveyQuestions__c(Category__c = 'Process',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow1.', UserAnswer__c = 'Agree');   
        phsUserSurveyQuestions__c userSurvey12 = new phsUserSurveyQuestions__c(Category__c = 'Process',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow2.', UserAnswer__c = 'Disagree');    
        phsUserSurveyQuestions__c userSurvey13 = new phsUserSurveyQuestions__c(Category__c = 'Process',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow3.', UserAnswer__c = 'Neutral');
        phsUserSurveyQuestions__c userSurvey14 = new phsUserSurveyQuestions__c(Category__c = 'Process',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow4.', UserAnswer__c = 'Strongly Disagree');
        phsUserSurveyQuestions__c userSurvey15 = new phsUserSurveyQuestions__c(Category__c = 'Process',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow5.', UserAnswer__c = 'Strongly Agree');    
        
        phsUserSurveyQuestions__c userSurvey16 = new phsUserSurveyQuestions__c(Category__c = 'Analytics',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow1.', UserAnswer__c = 'Agree');   
        phsUserSurveyQuestions__c userSurvey17 = new phsUserSurveyQuestions__c(Category__c = 'Analytics',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow2.', UserAnswer__c = 'Disagree');    
        phsUserSurveyQuestions__c userSurvey18 = new phsUserSurveyQuestions__c(Category__c = 'Analytics',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow3.', UserAnswer__c = 'Neutral');
        phsUserSurveyQuestions__c userSurvey19 = new phsUserSurveyQuestions__c(Category__c = 'Analytics',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow4.', UserAnswer__c = 'Strongly Disagree');
        phsUserSurveyQuestions__c userSurvey20 = new phsUserSurveyQuestions__c(Category__c = 'Analytics',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow5.', UserAnswer__c = 'Strongly Agree');      
        
        phsUserSurveyQuestions__c userSurvey21 = new phsUserSurveyQuestions__c(Category__c = 'People',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow1.', UserAnswer__c = 'Agree');   
        phsUserSurveyQuestions__c userSurvey22 = new phsUserSurveyQuestions__c(Category__c = 'People',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow2.', UserAnswer__c = 'Disagree');    
        phsUserSurveyQuestions__c userSurvey23 = new phsUserSurveyQuestions__c(Category__c = 'People',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow3.', UserAnswer__c = 'Neutral');
        phsUserSurveyQuestions__c userSurvey24 = new phsUserSurveyQuestions__c(Category__c = 'People',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow4.', UserAnswer__c = 'Strongly Disagree');
        phsUserSurveyQuestions__c userSurvey25 = new phsUserSurveyQuestions__c(Category__c = 'People',Grouping__c = 'Culture',IsActive__c = true,Name = 'Q1',User__c = c.Id,
                                                                               Question__c = 'I have measurable goals and degree plans to follow5.', UserAnswer__c = 'Strongly Agree');      
        
        insert userSurvey1;
        insert userSurvey2;
        insert userSurvey3;
        insert userSurvey4;
        insert userSurvey5;
        insert userSurvey6;
        insert userSurvey7;
        insert userSurvey8;
        insert userSurvey9;
        insert userSurvey10;
        insert userSurvey11;
        insert userSurvey12;
        insert userSurvey13;
        insert userSurvey14;
        insert userSurvey15;
        insert userSurvey16;
        insert userSurvey17;
        insert userSurvey18;
        insert userSurvey19;
        insert userSurvey20;
        insert userSurvey21;
        insert userSurvey22;
        insert userSurvey23;
        insert userSurvey24;
        insert userSurvey25;
        
        
        // Insert a Tip
        phsTips__c tip = new phsTips__c(
            Name = 'Tip1',
            Description__c = 'Stay positive!',
            Category__c = 'Culture',
            IsActive__c = true
        );
        insert tip;
        
        phsTips__c tip2 = new phsTips__c(
            Name = 'Tip2',
            Description__c = 'Stay positive2!',
            Category__c = 'Culture',
            IsActive__c = true
        );
        insert tip2;
        
        Test.startTest();
        String result = phsWellnessWaveController.getWellnessScore();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals('', result.trim(), 'Result should not be empty');
        
        // First parse into an object (it’s still a JSON string)
        Object parsedObj = JSON.deserializeUntyped(result);
        
        System.assert(parsedObj instanceof Map<String,Object>, 
                      'Expected a Map after parsing JSON, but got: ' + parsedObj);
        
        Map<String, Object> parsed = (Map<String, Object>) parsedObj;
        System.debug('Parsed wellness score: ' + parsed);        
        // Validate fields
        System.assert(parsed.containsKey('Culture'), 'Should contain Culture key');
        System.assert(parsed.containsKey('LowScoreCategory'), 'Should contain LowScoreCategory');
        System.assertNotEquals(null, parsed.get('TipOfTheDay'), 'TipOfTheDay should not be null');
    }
    
    
    @IsTest
    public static void testGetCategoryDescription() {
        insert new List<phsCoreElements__c>{
            new phsCoreElements__c(CoreElement__c='Analytics',CoreElementDescription__c='Analytics',Name='Analytics'),
                new phsCoreElements__c(CoreElement__c='Culture',CoreElementDescription__c='Culture',Name='Culture'),
                new phsCoreElements__c(CoreElement__c='People',CoreElementDescription__c='People',Name='People'),
                new phsCoreElements__c(CoreElement__c='Process',CoreElementDescription__c='Process',Name='Process'),
                new phsCoreElements__c(CoreElement__c='Technology',CoreElementDescription__c='Technology',Name='Technology')
                };
                    
                    Test.startTest();
        String result = phsWellnessWaveController.getCategoryDescription();
        Test.stopTest();
        
        System.assert(result.contains('Analytics'), 'Should return Analytics element');
    }
}