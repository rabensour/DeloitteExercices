@IsTest
public class PartyControllerTest {

    @IsTest
    public static void testCreateParty() {
        System.debug('=== Starting testCreateParty ===');
        Test.startTest();
        
        // Inputs pour la méthode createParty
        String name = 'Test Party';
        String code = 'TP123';
        String description = 'This is a test party';
        String leader = 'Test Leader';

        // Appeler la méthode et capturer l'ID retourné
        Id createdPartyId = PartyController.createParty(name, code, description, leader);
        System.debug('Created Party ID: ' + createdPartyId);

        // Vérifier que l'ID retourné n'est pas nul
        System.assertNotEquals(null, createdPartyId, 'Party ID should not be null.');

        // Query pour vérifier si l'enregistrement a été inséré
        Party__c createdParty = [SELECT Id, Name, PartyCode__c, Description__c, ManagerName__c 
                                 FROM Party__c WHERE Id = :createdPartyId];
        
        // Valider que les champs ont les valeurs correctes
        System.assertEquals(name, createdParty.Name, 'Name does not match.');
        System.assertEquals(code, createdParty.PartyCode__c, 'PartyCode does not match.');
        System.assertEquals(description, createdParty.Description__c, 'Description does not match.');
        System.assertEquals(leader, createdParty.ManagerName__c, 'ManagerName does not match.');

        Test.stopTest();
        System.debug('=== Finished testCreateParty ===');
    }

    @IsTest
    public static void testGetParties() {
        System.debug('=== Starting testGetParties ===');
        Test.startTest();

        // Créer quelques enregistrements Party__c
        Party__c party1 = new Party__c(
            Name = 'Party 1',
            PartyCode__c = 'P001',
            Description__c = 'First party description',
            ManagerName__c = 'Leader 1'
        );
        Party__c party2 = new Party__c(
            Name = 'Party 2',
            PartyCode__c = 'P002',
            Description__c = 'Second party description',
            ManagerName__c = 'Leader 2'
        );
        insert new List<Party__c>{party1, party2};

        // Appeler la méthode getParties
        List<Party__c> parties = PartyController.getParties();
        System.debug('Retrieved Parties: ' + parties);

        // Valider que les enregistrements ont été récupérés
        System.assertNotEquals(0, parties.size(), 'getParties should return at least one party.');

        // Vérifier que les enregistrements créés sont dans les résultats
        Boolean party1Found = false, party2Found = false;
        for (Party__c party : parties) {
            if (party.Name == 'Party 1') {
                party1Found = true;
                System.assertEquals('P001', party.PartyCode__c, 'PartyCode for Party 1 does not match.');
                System.assertEquals('First party description', party.Description__c, 'Description for Party 1 does not match.');
                System.assertEquals('Leader 1', party.ManagerName__c, 'ManagerName for Party 1 does not match.');
            }
            if (party.Name == 'Party 2') {
                party2Found = true;
                System.assertEquals('P002', party.PartyCode__c, 'PartyCode for Party 2 does not match.');
                System.assertEquals('Second party description', party.Description__c, 'Description for Party 2 does not match.');
                System.assertEquals('Leader 2', party.ManagerName__c, 'ManagerName for Party 2 does not match.');
            }
        }

        System.assert(party1Found, 'Party 1 was not found in getParties results.');
        System.assert(party2Found, 'Party 2 was not found in getParties results.');

        Test.stopTest();
        System.debug('=== Finished testGetParties ===');
    }
}
