@isTest
public class ChatterGroupHandlerTest {
    @isTest
    static void testHandleInsert() {
        // Créer un utilisateur de test
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardUserProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Créer un groupe CollaborationGroup avec CollaborationType
        CollaborationGroup testGroup = new CollaborationGroup(
            Name = 'Test Collaboration Group',
            CollaborationType = 'Public' // Valeur requise pour le champ CollaborationType
        );
        insert testGroup;

        // Ajouter un membre au groupe
        System.runAs(testUser) {
            CollaborationGroupMember testMember = new CollaborationGroupMember(
                CollaborationGroupId = testGroup.Id,
                MemberId = testUser.Id
            );
            insert testMember;

            // Appeler la méthode handleInsert
            Test.startTest();
            ChatterGroupHandler.handleInsert(new List<CollaborationGroupMember>{testMember});
            Test.stopTest();

            // Vérifier les résultats (aucune erreur dans l'exécution)
            System.debug('Test completed for handleInsert.');
        }
    }

    @isTest
    static void testHandleDelete() {
        // Créer un utilisateur de test
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardUserProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Créer un groupe CollaborationGroup avec CollaborationType
        CollaborationGroup testGroup = new CollaborationGroup(
            Name = 'Test Collaboration Group',
            CollaborationType = 'Public' // Valeur requise pour le champ CollaborationType
        );
        insert testGroup;

        // Ajouter un membre au groupe
        System.runAs(testUser) {
            CollaborationGroupMember testMember = new CollaborationGroupMember(
                CollaborationGroupId = testGroup.Id,
                MemberId = testUser.Id
            );
            insert testMember;

            // Supprimer le membre
            delete testMember;

            // Appeler la méthode handleDelete
            Test.startTest();
            ChatterGroupHandler.handleDelete(new List<CollaborationGroupMember>{testMember});
            Test.stopTest();

            // Vérifier les résultats (aucune erreur dans l'exécution)
            System.debug('Test completed for handleDelete.');
        }
    }
}
