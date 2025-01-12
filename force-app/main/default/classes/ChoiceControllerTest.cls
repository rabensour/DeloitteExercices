@IsTest
public class ChoiceControllerTest {

    @IsTest
    public static void testSaveChoice() {
        // Start test setup
        System.debug('=== Starting testSaveChoice ===');
        Test.startTest();
        
        // Create test Party record with required fields
        Party__c testParty = new Party__c(
            Name = 'Test Party',
            PartyCode__c = '12345', // Valeur requise
            ManagerName__c = 'Test Manager' // Valeur requise
        );
        insert testParty;
        System.debug('Test Party inserted: ' + testParty);

        // Create test User record (use a Salesforce user instead of custom if applicable)
        User testUser = [SELECT Id, Name FROM User LIMIT 1]; // Assuming you use a valid Salesforce user
        System.debug('Test User selected: ' + testUser);

        // Define the inputs for the saveChoice method
        Id partyId = testParty.Id;
        Id userId = testUser.Id;
        String userName = testUser.Name;
        Date choiceDate = Date.today();
        System.debug('Inputs prepared: partyId=' + partyId + ', userId=' + userId + ', userName=' + userName + ', choiceDate=' + choiceDate);

        // Call the method
        ChoiceController.saveChoice(partyId, userId, userName, choiceDate);
        System.debug('saveChoice method called successfully.');

        // Query the inserted record to verify
        Choice__c insertedChoice = [SELECT Id, Party__c, User__c, LastUpdatedDate__c, Name 
                                    FROM Choice__c 
                                    WHERE Party__c = :partyId 
                                    AND User__c = :userId
                                    LIMIT 1];
        System.debug('Inserted Choice record: ' + insertedChoice);

        // Assertions to validate results
        System.assertNotEquals(null, insertedChoice, 'Choice record was not inserted.');
        System.assertEquals('Vote of ' + userName, insertedChoice.Name, 'Name field mismatch.');
        System.assertEquals(choiceDate, insertedChoice.LastUpdatedDate__c, 'Date field mismatch.');
        System.assertEquals(partyId, insertedChoice.Party__c, 'Party field mismatch.');
        System.assertEquals(userId, insertedChoice.User__c, 'User field mismatch.');

        // End test
        Test.stopTest();
        System.debug('=== Finished testSaveChoice ===');
    }
    
}
