public with sharing class phsCoachController
{
    // Tip: since this calls an external service (AI), avoid cacheable=true.
    // cacheable=true is meant for idempotent, cache-safe reads (no callouts).
    @AuraEnabled(cacheable=true)
    public static String getCoachTip() {
        String tip = '';
        try {
            phsUtilityController util = new phsUtilityController();        
            String contactId = util.getContactId();

            // Build prompt from assigned goals + instruction
            String message = getAssignedGoals(contactId);
            message += 'Give me a coach recommended tip in around 20 words. This tip must not be given to me earlier. The tip should be based on my assigned goals.';

           
            tip = phsChatBaseController.getTipFromAI(message, contactId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getCoachTip exception: ' + e.getMessage());
        }       
        return tip;
    }
    
    @AuraEnabled
    public static boolean isCoachCheckInRequired() {
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
        Datetime lastCheckInDate = Datetime.now();

        List<phsCoachCheckIn__c> listCheckIn = [
            SELECT Id, Checkin_required__c, Last_checkin_date__c
            FROM phsCoachCheckIn__c
            WHERE Contact__c = :contactId
            LIMIT 1
        ];

        if (listCheckIn.isEmpty()) {
            phsCoachCheckIn__c objCheckIn = new phsCoachCheckIn__c();
            objCheckIn.Contact__c = contactId;
            objCheckIn.Checkin_required__c = true;
            objCheckIn.Last_checkin_date__c = Datetime.now();
            insert objCheckIn;
            return true;
        } else if (listCheckIn[0].Checkin_required__c == true) {    
            if (listCheckIn[0].Last_checkin_date__c != null) {
                lastCheckInDate = listCheckIn[0].Last_checkin_date__c;
            }
            List<phsCheckInConversation__c> listConversations = [
                SELECT Id, Question__c, Question_Date__c, Answer__c, Answer_Date__c
                FROM phsCheckInConversation__c
                WHERE IsAnswered__c = true
                  AND Question_date__c >= :lastCheckInDate
                  AND Contact__c = :contactId
            ];
            if (listConversations.size() >= 3) {            
                phsCoachCheckIn__c checkIn = listCheckIn[0];
                checkIn.Checkin_required__c = false;
                checkIn.Last_checkin_date__c = Datetime.now();
                update checkIn;  
                return false;               
            } else {
                return true;
            }
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean isCoachCheckOutRequired() {
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
        Date lastCheckOutDate = System.today();

        List<phsCoachCheckOut__c> listCheckOut = [
            SELECT Id, Checkout_required__c, Last_checkout_date__c
            FROM phsCoachCheckOut__c
            WHERE Contact__c = :contactId
            LIMIT 1
        ];

        if (listCheckOut.isEmpty()) {
            phsCoachCheckOut__c objCheckOut = new phsCoachCheckOut__c();
            objCheckOut.Contact__c = contactId;
            objCheckOut.Checkout_required__c = true;
            objCheckOut.Last_checkout_date__c = Datetime.now();
            insert objCheckOut;
            return true;
        } else if (listCheckOut[0].Last_checkout_date__c == null
                   || listCheckOut[0].Last_checkout_date__c.date() != lastCheckOutDate) {

            if (listCheckOut[0].Checkout_required__c == false) {
                phsCoachCheckOut__c objCheckOut = listCheckOut[0];
                objCheckOut.Checkout_required__c = true;
                objCheckOut.Last_checkout_date__c = Datetime.now();
                update objCheckOut;
            }
            return true;       
        } else if (listCheckOut[0].Checkout_required__c == true) {
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static String getCoachQuestion(String type) {
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
        
        List<phsCheckInConversation__c> listConversations = [
            SELECT Id, Question__c, Question_Date__c, Answer__c, Answer_Date__c
            FROM phsCheckInConversation__c
            WHERE IsAnswered__c = true
              AND Contact__c = :contactId
            ORDER BY Question_Date__c DESC
            LIMIT 2
        ];
                    
        return getQuestionFromAI(contactId, listConversations, type);
    }
    
    @AuraEnabled
    public static String getCheckOutQuestion() {
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
        
        List<phsCoachcheckOutQuestions__c> listQuestions = [
            SELECT Id, Question__c, QuestionType__c
            FROM phsCoachcheckOutQuestions__c
            WHERE Id NOT IN (
                SELECT Question__c
                FROM phsCheckOutConversation__c
                WHERE Question_Date__c > YESTERDAY
                  AND Contact__c = :contactId
            )
            LIMIT 1
        ];

        if (!listQuestions.isEmpty()) {
            CheckOutQuestion objQ = new CheckOutQuestion();
            objQ.type = listQuestions[0].QuestionType__c;
            objQ.question = listQuestions[0].Question__c;
            objQ.questionId = listQuestions[0].Id;
            return JSON.serialize(objQ);
        } else {
            // checkout complete
            List<phsCoachCheckOut__c> listCheckOut = [
                SELECT Id, Checkout_required__c, Last_checkout_date__c
                FROM phsCoachCheckOut__c
                WHERE Contact__c = :contactId
                LIMIT 1
            ];
            if (!listCheckOut.isEmpty() && listCheckOut[0].Checkout_required__c == true) {
                phsCoachCheckOut__c objCheckOut = listCheckOut[0];
                objCheckOut.Checkout_required__c = false;
                objCheckOut.Last_checkout_date__c = Datetime.now();
                update objCheckOut;
            }           
            return 'Check Out Complete';
        }
    }
    
    @AuraEnabled
    public static String insertCheckOutConversation(String data){
        Question questionData = (Question)JSON.deserialize(data, Question.class);
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
            
        phsCheckOutConversation__c conversation = new phsCheckOutConversation__c();
        conversation.Contact__c = contactId;
        conversation.Question__c = questionData.id;
        conversation.Question_Date__c = Datetime.now();
        conversation.Answer__c = questionData.answer;
        conversation.Answer_Date__c = Datetime.now();
        insert conversation;
        
        return 'success';
    }
    
    class CheckOutQuestion {
        public String type;
        public String question;
        public String questionId;
    }
    
    static String getQuestionFromAI(String contactId, List<phsCheckInConversation__c> listConversations, String type)
    {
        String message = '';
        Integer count = 1;

        if (type != 'followup') {
            message += getAssignedGoals(contactId).stripHtmlTags();
        }
        
        if (!listConversations.isEmpty()) {
            count = Math.min(2, listConversations.size());
            message += ':://::----------X-----------  Coach and user conversation done so far ::';
            for (Integer i = 1; i <= count; i++) {
                Integer idx = listConversations.size() - i;
                message += 'Coach asked Question ' + (idx + 1) + ' on ' + listConversations[idx].Question_Date__c + ': ' + listConversations[idx].Question__c.stripHtmlTags() + '. ';
                message += 'User answered the Question ' + (idx + 1) + ' on ' + listConversations[idx].Answer_Date__c + ': ' + listConversations[idx].Answer__c.stripHtmlTags() + '. ';
            }
        }
        
        message += ':://::----------X-----------  You need to act like a coach based on goals data provided and engage in conversation with user.' +
                   ' In answer to last question, if user has asked a question or asked for help, then answer his question first.' +
                   ' If user has asked for help then advise a suggestion as a coach in short (maximum 50-100 words) after appreciating/empathizing his reply but dont label it.' +
                   ' After that either ask a new question based on users response to last question asked by coach or else ask user a new coach question based on goals assigned to him.' +
                   ' The question should not be repetitive. If a followup question is available to the last coach question asked then ask only followup question otherwise ask main question without followup.' +
                   ' If you are asking a follup question, then dont show in words that its a follup question.' +
                   ' The question asked should be single and short and should not look like AI is answering. Keep all text within 200 characters.';

        String question = phsChatBaseController.getCoachQuestionFromAI(message, contactId);
        return question;
    }
    
    @AuraEnabled
    public static String insertCoachConversation(String data){
        Question questionData = (Question)JSON.deserialize(data, Question.class);
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
            
        phsCheckInConversation__c conversation = new phsCheckInConversation__c();
        conversation.Contact__c = contactId;
        conversation.Question__c = questionData.question;
        conversation.Question_Date__c = Datetime.now();
        conversation.Answer__c = questionData.answer;
        conversation.Answer_Date__c = Datetime.now();
        insert conversation;
        
        return 'success';
    }
    
    @AuraEnabled
    public static List<phsCheckInConversation__c> getCoachConversations(){
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
        List<phsCheckInConversation__c> listConversations = [
            SELECT Id, Question__c, Answer__c, Question_Date__c, Answer_Date__c
            FROM phsCheckInConversation__c
            WHERE IsAnswered__c = true
              AND Contact__c = :contactId
            ORDER BY Answer_Date__c ASC
        ];
        return listConversations;           
    }
    
    static String getAssignedGoals(String contactId)
    {
        String message = '';
        Integer count = 1;
        List<phsUserGoals__c> listGoals = [
            SELECT Id, GoalName__c, FocusArea__c, Status__c
            FROM phsUserGoals__c
            WHERE Active__c = true
              AND UserId__c = :contactId
        ];
        if (!listGoals.isEmpty()) {            
            message += 'Goals assigned to me are:: ';
            for (phsUserGoals__c goal : listGoals) {
                message += 'Goals ' + count + '= ' + goal.FocusArea__c + ': ' + goal.GoalName__c + '. The status of goals is ' + goal.Status__c + '. ';
                count++;
            }            
        } 
        return message;     
    }
    
    class Question {
        public String id;
        public String question;
        public String answer;
    }
}


// public with sharing class phsCoachController
// {

//     @AuraEnabled(cacheable=true)
//     public static String getCoachTip() {
//         String tip ='';
//         try{
//             phsUtilityController util = new phsUtilityController();        
//             String contactId = util.getContactId();
//             String message = '';
//             message += getAssignedGoals(contactId);
//             message +='Give me a coach recommended tip in around 20 words. This tip must not be given to me earlier. The tip should be based on my assigned goals.';
            
//             phsChatBaseController ctrl = new phsChatBaseController();
//             tip = ctrl.getTipFromAI(message, contactId);
//         }
//         catch(Exception e) {
//             System.debug('An exception occurred: ' + e.getMessage());
//         }       
        
//         return tip;
//     }
    
//     @AuraEnabled
//     public static boolean isCoachCheckInRequired() {
//         phsUtilityController util = new phsUtilityController();        
//         String contactId = util.getContactId();
//         Datetime lastCheckInDate = Datetime.now();
//         List<phsCoachCheckIn__c> listCheckIn = [select id,Checkin_required__c,Last_checkin_date__c from phsCoachCheckIn__c where contact__c = :contactId LIMIT 1];
//         if(listCheckIn.size() <= 0)
//         {
//             phsCoachCheckIn__c objCheckIn = new phsCoachCheckIn__c();
//             objCheckIn.contact__c = contactId;
//             objCheckIn.Checkin_required__c = true;
//             objCheckIn.Last_checkin_date__c = Datetime.now();
//             insert objCheckIn;
//             return true;
//         }
//         else if(listCheckIn.size() > 0 && listCheckIn[0].Checkin_required__c == true)
//         {    
//             if(listCheckIn[0].Last_checkin_date__c != null)
//             {lastCheckInDate = listCheckIn[0].Last_checkin_date__c;}
            
//             List<phsCheckInConversation__c> listConversations = [select id, Question__c, Question_Date__c, Answer__c, Answer_Date__c from phsCheckInConversation__c where isAnswered__c = true AND Question_date__c >= :lastCheckInDate AND Contact__c = :contactId];
//             if(listConversations.size() >= 3)
//             {            
//                 phsCoachCheckIn__c checkIn = listCheckIn[0];
//                 checkIn.Checkin_required__c = false;
//                 checkIn.Last_checkin_date__c = Datetime.now();
//                 update checkIn;  
//                 return false;               
//             }   
//             else
//             {
//                 return true;
//             }
            
            
//         }
//         else
//         {
//             return false;
//         }
//     }
    
// @AuraEnabled
//     public static boolean isCoachCheckOutRequired() {
//         phsUtilityController util = new phsUtilityController();        
//         String contactId = util.getContactId();
//         Date lastCheckOutDate = System.today();
//         List<phsCoachCheckOut__c> listCheckOut = [select id,Checkout_required__c,Last_checkout_date__c from phsCoachCheckOut__c where contact__c = :contactId LIMIT 1];
//         if(listCheckOut.size() <= 0)
//         {
//             phsCoachCheckOut__c objCheckOut = new phsCoachCheckOut__c();
//             objCheckOut.contact__c = contactId;
//             objCheckOut.Checkout_required__c = true;
//             objCheckOut.Last_checkout_date__c = Datetime.now();
//             insert objCheckOut;
//             return true;
//         }
//         else if(listCheckOut.size() > 0 && listCheckOut[0].Last_checkout_date__c.date() != lastCheckOutDate )
//         {   
//             if( listCheckOut[0].Checkout_required__c == false)
//             {
//                 phsCoachCheckOut__c objCheckOut = listCheckOut[0];
//                 objCheckOut.Checkout_required__c = true;
//                 objCheckOut.Last_checkout_date__c = Datetime.now();
//                 update objCheckOut;
//             }
            
//             return true;       
//         }
//         else if(listCheckOut[0].Checkout_required__c == true)
//         {
//             return true;
//         }
//         else
//         {
//             return false;
//         }
//     }



//     @AuraEnabled
//     public static String getCoachQuestion( String type) {
//         phsUtilityController util = new phsUtilityController();        
//         String contactId = util.getContactId();
        
//         List<phsCheckInConversation__c> listConversations = [select id, Question__c, Question_Date__c, Answer__c, Answer_Date__c from phsCheckInConversation__c where isAnswered__c = true AND Contact__c = :contactId order by Question_Date__c desc limit 2];
                    
//         return getQuestionFromAI(contactId, listConversations, type);
//     }
    
//      @AuraEnabled
//     public static String getCheckOutQuestion( ) {
//         phsUtilityController util = new phsUtilityController();        
//         String contactId = util.getContactId();
        
//         List<phsCoachcheckOutQuestions__c> listQuestions = [select id, Question__c, QuestionType__c from phsCoachcheckOutQuestions__c where id not in (select Question__c from phsCheckOutConversation__c where Question_Date__c > YESTERDAY AND contact__c = :contactId )];
//         if(listQuestions.size() > 0)
//         {
//             CheckOutQuestion objQ = new CheckOutQuestion();
//             objQ.type = listQuestions[0].QuestionType__c;
//             objQ.question = listQuestions[0].Question__c;
//             objQ.questionId = listQuestions[0].id;
//             return JSON.serialize(objQ);
//         }
//         else
//         {
//             //check out complete.
//             List<phsCoachCheckOut__c> listCheckOut = [select id,Checkout_required__c,Last_checkout_date__c from phsCoachCheckOut__c where contact__c = :contactId LIMIT 1];
//             if(listCheckOut.size() > 0 &&listCheckOut[0].Checkout_required__c == true )
//             {
//                 phsCoachCheckOut__c objCheckOut = listCheckOut[0];
//                 objCheckOut.Checkout_required__c = false;
//                 objCheckOut.Last_checkout_date__c = Datetime.now();
//                 update objCheckOut;
//             }           
//         }      
//          return 'Check Out Complete';  
//     }
    
//      @AuraEnabled
//     public static String insertCheckOutConversation(String data){
//         Question questionData = (Question)JSON.deserialize(data, Question.class);
//         String id = questionData.Id;
//         phsUtilityController util = new phsUtilityController();        
//         String contactId = util.getContactId();
            
//         phsCheckOutConversation__c conversation = new phsCheckOutConversation__c(); //[select id, Contact__c, Question__c, Answer__c, Answer_Date__c from phsCoachUserConversation__c where id = :id LIMIT 1];
//         conversation.contact__c = contactId;
//         conversation.Question__c = questionData.id;
//         conversation.Question_Date__c = Datetime.now();
//         conversation.Answer__c = questionData.answer;
//         conversation.Answer_Date__c = Datetime.now();
//         insert conversation;
        
//         //String contactId = conversation.Contact__c;    
//         return 'success';
//     }
    
//     class CheckOutQuestion
//     {
//         public String type;
//         public String question;
//         public String questionId;
//     }
    
//     static String getQuestionFromAI(String contactId, List<phsCheckInConversation__c> listConversations, String type)
//     {
//         String Message = '';
//         integer count = 1;
//         Question objQuestion = new Question();
        
//         if(type != 'followup')
//         {
//             //get goals assigned
//             Message += getAssignedGoals(contactId).stripHtmlTags() ;   
//         }
        
//         //load list of questions asked
//         if(listConversations.size() >0)
//         {
//             if(listConversations.size() > 2)
//             {
//                 count = 2;
//             }
//             else
//             {
//                 count = listConversations.size();
//             }
            
//             Message += ':://::----------X-----------  Coach and user conversation done so far ::';
//             for(integer i=1; i<= count; i++) //phsCoachUserConversation__c conversation : listConversations)
//             {
//                 Message += 'Coach asked Question '+(listConversations.size()+1-i)+' on '+listConversations[listConversations.size()-i].Question_Date__c+': '+listConversations[listConversations.size()-i].Question__c.stripHtmlTags()+'. ';
//                 Message += 'User answered the Question '+(listConversations.size()+1-i)+' on '+listConversations[listConversations.size()-i].Answer_Date__c+': '+listConversations[listConversations.size()-i].Answer__c.stripHtmlTags()+'. ';
                
//             }
//         }
        
//         //give Prompt to AI
//         Message += ':://::----------X-----------  You need to act like a coach based on goals data provided and engage in conversation with user. '+
//                 +' In answer to last question, if user has asked a question or asked for help, then answer his question first.'+
//                 +' If user has asked for help then advise a suggestion as a coach in short (maximum 50-100 words) after appreciating/empathizing his reply but dont label it.'+
//                 +' After that either ask a new question based on users response to last question asked by coach or else ask user a new coach question based on goals assigned to him. '+
//                 +' The question should not be repetitive. If a followup question is available to the last coach question asked then ask only followup question otherwise ask main question without followup. '+
//                 +' If you are asking a follup question, then dont show in words that its a follup question.'+
//                 +' The question asked should be single and short and should not look like AI is answering. Keep all text within 200 characters.';
//         phsChatBaseController objChatBase = new phsChatBaseController();
//         String question = objChatBase.getCoachQuestionFromAI(Message, contactId);
        
//         //if(!String.isBlank(question))
//         //{
//             //phsCoachUserConversation__c objConversation = new phsCoachUserConversation__c();
//             //objConversation.Question__c = question;
//             //objConversation.Question_date__c =System.today();
//             //objConversation.contact__c = contactId;
//             //insert objConversation;
//             //objQuestion.id = objConversation.id;
//             //objQuestion.question = objConversation.Question__c;
            
//         //}
//         return question;
//         //return JSON.serialize(objQuestion);
//     }
    
//     @AuraEnabled
//     public static String insertCoachConversation(String data){
//         Question questionData = (Question)JSON.deserialize(data, Question.class);
//         String id = questionData.Id;
//         phsUtilityController util = new phsUtilityController();        
//         String contactId = util.getContactId();
            
//         phsCheckInConversation__c conversation = new phsCheckInConversation__c(); //[select id, Contact__c, Question__c, Answer__c, Answer_Date__c from phsCoachUserConversation__c where id = :id LIMIT 1];
//         conversation.contact__c = contactId;
//         conversation.Question__c = questionData.question;
//         conversation.Question_Date__c = Datetime.now();
//         conversation.Answer__c = questionData.answer;
//         conversation.Answer_Date__c = Datetime.now();
//         insert conversation;
        
//         //String contactId = conversation.Contact__c;    
//         return 'success';
//     }
    
//     @AuraEnabled
//     public static List<phsCheckInConversation__c> getCoachConversations(){
//         phsUtilityController util = new phsUtilityController();        
//         String contactId = util.getContactId();
//         List<phsCheckInConversation__c> listConversations = [select id, Question__c, Answer__c, question_date__c, answer_date__c from phsCheckInConversation__c where isAnswered__c = true AND Contact__c = :contactId order by answer_date__c asc];
//         return listConversations;           
//     }
    
//     static String getAssignedGoals(String contactId)
//     {
//         String Message = '';
//         Integer count = 1;
//         List<phsUserGoals__c> listGoals = [select id, GoalName__c, FocusArea__c, Status__c from phsUserGoals__c where Active__c = true AND UserId__c = :contactId];
//         if(listGoals.size() > 0)
//         {            
//             Message += 'Goals assigned to me are:: ';
//             for(phsUserGoals__c goal: listGoals)
//             {
//                 Message += 'Goals '+count+'= '+goal.FocusArea__c+': '+goal.GoalName__c+'. The status of goals is '+goal.Status__c+'. ';
//                 count++;
//             }            
//         } 
//         return Message;     
//     }
    
//     class Question {
//         public String id;
//         public String question;
//         public String answer;
//     }
    

// }