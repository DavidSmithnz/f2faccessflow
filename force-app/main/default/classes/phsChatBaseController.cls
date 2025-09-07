public with sharing class phsChatBaseController {

    // ---- Simple holder for CMDT config ----
    private class Cfg {
        String apiKey;
        String apiPath;   // e.g. '/api/v1/chat'
        String chatbotId;
    }

    // ---- Loader (must be top-level static in Apex) ----
    private static Cfg loadCfg() {
        Chatbase_Config__mdt c = [
            SELECT ApiKey__c, ApiPath__c, ChatbotId__c
            FROM Chatbase_Config__mdt
            LIMIT 1
        ];
        Cfg cfg = new Cfg();
        cfg.apiKey    = String.valueOf(c.ApiKey__c);
        cfg.apiPath   = String.isBlank(c.ApiPath__c) ? '/api/v1/chat' : c.ApiPath__c.trim();
        cfg.chatbotId = String.valueOf(c.ChatbotId__c);

        if (String.isBlank(cfg.apiKey))    throw new CalloutException('Chatbase API key not configured (CMDT ApiKey__c).');
        if (String.isBlank(cfg.chatbotId)) throw new CalloutException('Chatbase chatbotId not configured (CMDT ChatbotId__c).');
        if (!cfg.apiPath.startsWith('/'))  cfg.apiPath = '/' + cfg.apiPath;

        return cfg;
    }

    @AuraEnabled(cacheable=false)
    public static String getTipFromAI(String message, String conversationId) {
        return sendRequestToAIWithRetry(message, conversationId, 1);
    }

    @AuraEnabled(cacheable=false)
    public static String getCoachQuestionFromAI(String message, String conversationId) {
        return sendRequestToAIWithRetry(message, conversationId, 1);
    }

    private static String sendRequestToAIWithRetry(String message, String conversationId, Integer attempt) {
        try {
            String response = sendRequestToAI(message, conversationId);
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response);
            if (parsed != null && parsed.containsKey('text')) {
                return String.valueOf(parsed.get('text'));
            }
            return 'Unexpected API response: ' + response;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Chatbase API call failed: ' + e.getMessage());
            if (attempt < 2) {
                return sendRequestToAIWithRetry(message, conversationId, attempt + 1);
            }
            return 'An error occurred after retry: ' + e.getMessage();
        }
    }

    private static String sendRequestToAI(String message, String conversationId) {
        Cfg cfg = loadCfg();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Chatbase' + cfg.apiPath); // NC 'Chatbase' + path from CMDT
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Inject Authorization from CMDT (reliable everywhere)
        req.setHeader('Authorization', 'Bearer ' + cfg.apiKey);

        req.setBody(createJsonBody(message, conversationId, cfg.chatbotId));

        Http http = new Http();
        System.debug(LoggingLevel.INFO, 'Callouts used so far: ' + Limits.getCallouts());
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('Chatbase API returned status ' + res.getStatusCode() + ': ' + res.getBody());
        }
        return res.getBody();
    }

    private static String createJsonBody(String message, String conversationId, String chatbotId) {
        message = String.isNotBlank(message) ? message.replaceAll('"','') : '';
        Map<String, Object> payload = new Map<String, Object>{
            'messages' => new List<Object>{
                new Map<String, Object>{
                    'content' => message,
                    'role'    => 'user'
                }
            },
            'chatbotId'      => chatbotId,
            'stream'         => false,
            'temperature'    => 1,
            'conversationId' => conversationId
        };
        return JSON.serialize(payload);
    }

    public class CalloutException extends Exception {}
}





// public class phsChatBaseController
// {

//     public String getTipFromAI(String Message, String ConversationId)
//     {
//         String response = sendRequestToAI(Message, ConversationId);
//         Map<String, String> m = (Map<String, String>) JSON.deserialize(response, Map<String, String>.class);
//         String text = m.get('text');
//         return text;
//     }
    
//     // public String getCoachQuestionFromAI(String Message, String ConversationId)
//     // {        
//     //     String text='';
//     //     String response='';
//     //     try{ 
//     //         response = sendRequestToAI(Message, ConversationId);            
//     //         Map<String, String> m = (Map<String, String>) JSON.deserialize(response, Map<String, String>.class);
//     //         text = m.get('text');
//     //     }
//     //     catch(Exception e)
//     //     {
//     //         text = 'An error Occured - ' +e.getMessage();
//     //         //try once again
//     //         getCoachQuestionFromAI(Message, ConversationId);
//     //     }
//     //     return text;     
//     // }

//     public String getCoachQuestionFromAI(String Message, String ConversationId) {
//     return getCoachQuestionFromAIInternal(Message, ConversationId, 1); // 1 = first attempt
// }

// private String getCoachQuestionFromAIInternal(String Message, String ConversationId, Integer attempt) {
//     String text = '';
//     try {
//         String response = sendRequestToAI(Message, ConversationId);
//         Map<String, String> m = (Map<String, String>) JSON.deserialize(response, Map<String, String>.class);
//         text = m.get('text');
//     } catch (Exception e) {
//         if (attempt < 2) { // limit retries
//             text = getCoachQuestionFromAIInternal(Message, ConversationId, attempt + 1);
//         } else {
//             text = 'An error occurred after retry: ' + e.getMessage();
//         }
//     }
//     return text;
// }


    
    
//     public String sendRequestToAI(String Message, String ConversationId){
    
//         HttpRequest req = new HttpRequest();
//         req.setEndpoint('callout:Chatbase/path/to/api');
//         req.setMethod('POST');
//         // String endpoint = 'https://www.chatbase.co/api/v1/chat';
//         // String method = 'POST';
//         // req.setHeader('Authorization', 'Bearer b15fb3e0-2932-4e7a-a3bb-781bbdc343b1');
//         // req.setHeader('Content-Type', 'application/json');        
//         req.setBody(this.createPreFormattedJsonBody(Message, ConversationId));        
//         // req.setEndpoint(endpoint);
//         // req.setMethod(method);
        
//         Http http = new Http();
//         HTTPResponse response = http.send(req);
//         System.debug('ij: response of fetch is '+ response.getBody());
//         //String json_data = response;
        
//         //if(response.status_code == 200)
//         //  System.Debug('response:', json_data['text']);
//         //else
//         //  System.Debug('Error:' + json_data['message']);
//         return response.getBody();
//      }
     
//      public String createPreFormattedJsonBody(String Message, String ConversationId)
//      {
//          Message = Message.replaceAll('"','');
//          //List<String> arrMessage = Message.split(':://::');
//          //System.debug('ij array is '+arrMessage);
//          String data ='';
//          //for(integer i=0; i< arrMessage.size(); i++)
//          //{
//          //    data += '{\"content\": \"'+arrMessage[i]+'\", \"role\":\"user\" },';
//          //}   
//          data += '{\"content\": \"'+Message+'\", \"role\":\"user\" }';
//          //data = data.removeEnd(',');     
         
         
//          String json = '{'+
//         '  \"messages\": ['+
//             data +
//         //'    {\"content\": \"'+Message+'\", \"role\":\"user\" }'+       
//         '  ],'+
//         '  \"chatbotId\": \"zGmnaYxVXpFZjJ5_ggpwv\",'+
//         '  \"stream\": false,'+
//         '  \"temperature\": 1,'+
//         '  \"conversationId\": \"'+ConversationId+'\"'+
//         '}';
//         System.Debug('ij message is '+json);
//         //JSON2Apex payload = new JSON2Apex();
//         //JSON2Apex parsedPayload = payload.parse(json);
//         //String jsonString = JSON.serialize(parsedPayload);
//         return json;
//      }  
     
     
//      public String createJsonBody(String Message, String ConversationId)
//      {
//          String json = '{'+
//         '  \"messages\": ['+
//         '    {\"content\": \"'+Message+'\", \"role\":\"user\" }'+       
//         '  ],'+
//         '  \"chatbotId\": \"zGmnaYxVXpFZjJ5_ggpwv\",'+
//         '  \"stream\": false,'+
//         '  \"temperature\": 1,'+
//         '  \"conversationId\": \"'+ConversationId+'\"'+
//         '}';
//         System.Debug('ij message is '+json);
//         //JSON2Apex payload = new JSON2Apex();
//         //JSON2Apex parsedPayload = payload.parse(json);
//         //String jsonString = JSON.serialize(parsedPayload);
//         return json;
//      }  
//  }