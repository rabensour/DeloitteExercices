public with sharing class ChoiceController {
    
    @AuraEnabled
    public static void saveChoice(Id partyId, Id userId, String userName , Date choiceDate) {
        try {
            Choice__c newChoice = new Choice__c(
                Party__c = partyId,
                User__c = userId,
                LastUpdatedDate__c = choiceDate,
                Name = 'Vote of ' + UserName  
            );
            
            insert newChoice; 
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating choice record: ' + e.getMessage());
        }
    }
}