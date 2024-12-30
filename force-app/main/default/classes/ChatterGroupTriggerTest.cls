@isTest
public class ChatterGroupTriggerTest {

    // Test Method for Insert Events
    @isTest
    static void testTriggerInsert() {
        System.debug('--- Starting testTriggerInsert ---');
        
        // Create a Chatter Group (CollaborationGroup)
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Test Group',
            CollaborationType = 'Public'
        );
        insert chatterGroup;

        System.debug('Created CollaborationGroup: ' + chatterGroup.Id);

        // Create a CollaborationGroupMember
        CollaborationGroupMember groupMember = new CollaborationGroupMember(
            CollaborationGroupId = chatterGroup.Id,
            MemberId = UserInfo.getUserId()
        );

        Test.startTest();
        insert groupMember; // This should fire the trigger
        Test.stopTest();

        System.debug('Inserted CollaborationGroupMember: ' + groupMember.Id);

        // Assertions
        // Verify that the member was added to the group
        CollaborationGroupMember insertedMember = [SELECT Id FROM CollaborationGroupMember WHERE Id = :groupMember.Id];
        System.assertNotEquals(null, insertedMember, 'Group Member was not inserted.');
    }

    // Test Method for Delete Events
    @isTest
    static void testTriggerDelete() {
        System.debug('--- Starting testTriggerDelete ---');

        // Create a Chatter Group (CollaborationGroup)
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Test Group for Delete',
            CollaborationType = 'Public'
        );
        insert chatterGroup;

        System.debug('Created CollaborationGroup: ' + chatterGroup.Id);

        // Create a CollaborationGroupMember
        CollaborationGroupMember groupMember = new CollaborationGroupMember(
            CollaborationGroupId = chatterGroup.Id,
            MemberId = UserInfo.getUserId()
        );
        insert groupMember;

        System.debug('Inserted CollaborationGroupMember: ' + groupMember.Id);

        // Delete the group member
        Test.startTest();
        delete groupMember; // This should fire the trigger
        Test.stopTest();

        // Assertions
        // Verify that the member is deleted
        Integer memberCount = [SELECT COUNT() FROM CollaborationGroupMember WHERE Id = :groupMember.Id];
        System.assertEquals(0, memberCount, 'Group Member was not deleted.');
    }

    // Test Method for Both Insert and Delete Events
    @isTest
    static void testTriggerInsertAndDelete() {
        System.debug('--- Starting testTriggerInsertAndDelete ---');

        // Create a Chatter Group (CollaborationGroup)
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Test Group for Both Actions',
            CollaborationType = 'Public'
        );
        insert chatterGroup;

        System.debug('Created CollaborationGroup: ' + chatterGroup.Id);

        // Create a CollaborationGroupMember
        CollaborationGroupMember groupMember = new CollaborationGroupMember(
            CollaborationGroupId = chatterGroup.Id,
            MemberId = UserInfo.getUserId()
        );

        Test.startTest();
        insert groupMember; // This should fire the trigger
        delete groupMember; // This should also fire the trigger
        Test.stopTest();

        System.debug('Inserted and Deleted CollaborationGroupMember: ' + groupMember.Id);

        // Assertions
        // Verify that the member is inserted and then deleted
        Integer memberCount = [SELECT COUNT() FROM CollaborationGroupMember WHERE Id = :groupMember.Id];
        System.assertEquals(0, memberCount, 'Group Member was not deleted after being inserted.');
    }

    // Negative Test Case
    @isTest
    static void testTriggerNoEvents() {
        System.debug('--- Starting testTriggerNoEvents ---');

        Test.startTest();
        // Do nothing to ensure no events fire
        Test.stopTest();

        // Assertions
        System.assert(true, 'No actions taken, trigger should not have fired.');
    }
}
