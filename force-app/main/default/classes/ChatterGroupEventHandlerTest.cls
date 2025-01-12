@isTest
public class ChatterGroupEventHandlerTest {
    @isTest
    static void testHandlePlatformEvents_AddMember() {
        // Créer un utilisateur fictif pour le test
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

        // Préparer un événement d'ajout
        ChatterGroupEvent__e addEvent = new ChatterGroupEvent__e(
            Action__c = 'add',
            ChatterGroupName__c = 'Test Group',
            UserId__c = testUser.Id
        );

        // Tester la méthode handlePlatformEvents
        Test.startTest();
        ChatterGroupEventHandler.handlePlatformEvents(new List<ChatterGroupEvent__e>{addEvent});
        Test.stopTest();

        // Vérifier que le groupe a été créé
        Group createdGroup = [SELECT Id, Name FROM Group WHERE Name = 'Test Group' LIMIT 1];
        System.assertNotEquals(null, createdGroup, 'Le groupe devrait être créé.');
        System.assertEquals('Test Group', createdGroup.Name, 'Le nom du groupe devrait correspondre.');

        // Vérifier que l'utilisateur a été ajouté au groupe
        GroupMember addedMember = [
            SELECT Id, GroupId, UserOrGroupId
            FROM GroupMember
            WHERE GroupId = :createdGroup.Id AND UserOrGroupId = :testUser.Id
            LIMIT 1
        ];
        System.assertNotEquals(null, addedMember, 'Le membre devrait être ajouté au groupe.');
    }

    @isTest
    static void testHandlePlatformEvents_RemoveMember() {
        // Créer un utilisateur fictif pour le test
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

        // Créer un groupe public
        Group testGroup = new Group(
            Name = 'Test Group',
            Type = 'Regular'
        );
        insert testGroup;

        // Ajouter un membre au groupe
        GroupMember testMember = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = testUser.Id
        );
        insert testMember;

        // Préparer un événement de suppression
        ChatterGroupEvent__e removeEvent = new ChatterGroupEvent__e(
            Action__c = 'remove',
            ChatterGroupName__c = 'Test Group',
            UserId__c = testUser.Id
        );

        // Tester la méthode handlePlatformEvents
        Test.startTest();
        ChatterGroupEventHandler.handlePlatformEvents(new List<ChatterGroupEvent__e>{removeEvent});
        Test.stopTest();

        // Vérifier que le membre a été supprimé
        Integer memberCount = [
            SELECT COUNT()
            FROM GroupMember
            WHERE GroupId = :testGroup.Id AND UserOrGroupId = :testUser.Id
        ];
        System.assertEquals(0, memberCount, 'Le membre devrait être supprimé du groupe.');
    }
}
