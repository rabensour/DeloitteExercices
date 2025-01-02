public class ChatterGroupHandler {
    public static void handlePlatformEvents(List<ChatterGroupEvent__e> events) {

        System.debug('Events received: ' + events);

        // Prepare lists for DML operations
        List<Group> groupsToCreate = new List<Group>();
        List<GroupMember> groupMembersToAdd = new List<GroupMember>();
        List<GroupMember> groupMembersToDelete = new List<GroupMember>();

        // Retrieve unique group names
        Set<String> chatterGroupNames = new Set<String>();
        for (ChatterGroupEvent__e event : events) {
                chatterGroupNames.add(event.ChatterGroupName__c);
        }
        System.debug('Unique Chatter Group Names: ' + chatterGroupNames);

        // Retrieve existing public groups
        Map<String, Group> existingGroups = new Map<String, Group>();
        try {
            for (group g :[SELECT Id, name FROM Group WHERE name IN :chatterGroupNames]) {
                if (!existingGroups.containsKey(g.name)) {
                    existingGroups.put(g.name, g);
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching existing groups: ' + e.getMessage());
        }

        System.debug('Existing Groups Retrieved: ' + existingGroups);

        // Create missing groups
        for (ChatterGroupEvent__e event : events) {
            String groupName = event.ChatterGroupName__c;
            String action = event.Action__c;

            if (!existingGroups.containsKey(groupName) && action == 'add') {
                Group newGroup = new Group(
                    Name = groupName,
                    Type = 'Regular'
                );
                System.debug('Creating new group : ' + groupName);
                groupsToCreate.add(newGroup);
                existingGroups.put(groupName, newGroup); 
            }
        }

        try {
            // Insert new public groups
            if (!groupsToCreate.isEmpty()) {
                System.debug('Inserting new groups: ' + groupsToCreate);
                insert groupsToCreate;

                // Update created groups with IDs after insertion
                for (Group createdGroup : groupsToCreate) {
                    existingGroups.put(createdGroup.name, createdGroup);
                }
            }

            // Process the events
            for (ChatterGroupEvent__e event : events) {
                String action = event.Action__c;
                String groupName = event.ChatterGroupName__c;
                String userId = event.UserId__c;

                System.debug('Processing event: Action=' + action + ', ChatterGroupName=' + groupName + ', UserId=' + userId);

                Group publicGroup = existingGroups.get(groupName);
                if (action == 'add') {
                    if (publicGroup != null) {
                        System.debug('Adding member to group: ' + publicGroup.Id + ', UserId: ' + userId);
                        groupMembersToAdd.add(new GroupMember(
                            GroupId = publicGroup.Id,
                            UserOrGroupId = userId
                        ));
                    } else {
                        System.debug('Public Group not found for adding member: ' + groupName);
                    }
                } else if (action == 'remove') {
                    if (publicGroup != null) {
                        try {
                            GroupMember memberToDelete = [
                                SELECT Id FROM GroupMember 
                                WHERE GroupId = :publicGroup.Id AND UserOrGroupId = :userId 
                                LIMIT 1
                            ];
                            System.debug('Found member to delete: ' + memberToDelete.Id);
                            groupMembersToDelete.add(memberToDelete);
                        } catch (Exception e) {
                            System.debug('Error finding Group Member to delete: ' + e.getMessage());
                        }
                    } else {
                        System.debug('Public Group not found for removing member: ' + groupName);
                    }
                }
            }

            // Execute DML operations
            if (!groupMembersToAdd.isEmpty()) {
                System.debug('Inserting new Group Members: ' + groupMembersToAdd);
                insert groupMembersToAdd;
            }
            if (!groupMembersToDelete.isEmpty()) {
                System.debug('Deleting Group Members: ' + groupMembersToDelete);
                delete groupMembersToDelete;
            }
        } catch (DmlException e) {
            System.debug('DML Exception occurred: ' + e.getMessage());
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('DML Error on record ' + e.getDmlId(i) + ': ' + e.getDmlMessage(i));
            }
        }
    }
}
