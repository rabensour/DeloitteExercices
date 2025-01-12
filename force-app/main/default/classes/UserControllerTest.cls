@isTest
public class UserControllerTest {
    @isTest
    static void testGetCurrentUserInfo() {
        // Créer un nom d'utilisateur unique
        String uniqueUsername = 'testuser-' + System.currentTimeMillis() + '@example.com';

        // Création de l'utilisateur de test
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User', // Nom de famille explicitement défini
            Email = 'testuser@example.com',
            Username = uniqueUsername, // Garantit un nom d'utilisateur unique
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        System.debug('Création d\'un utilisateur : ' + testUser);
        insert testUser;

        // Contexte d'exécution en tant qu'utilisateur de test
        System.runAs(testUser) {
            System.debug('Contexte System.runAs activé pour l\'utilisateur : ' + testUser.Id);

            // Appel de la méthode à tester
            UserController.UserInfoResponse response = UserController.getCurrentUserInfo();
            System.debug('Réponse reçue de UserController.getCurrentUserInfo : ' + response);

            // Vérifications (assertions)
            System.assertNotEquals(null, response, 'La réponse ne doit pas être nulle.');
            System.debug('Validation : la réponse n\'est pas nulle.');

            System.assertEquals(testUser.Id, response.userId, 'L\'ID utilisateur devrait correspondre.');
            System.debug('Validation : l\'ID utilisateur correspond.');

            System.assertEquals(
                testUser.FirstName + ' ' + testUser.LastName, 
                response.userName, 
                'Le nom de l\'utilisateur devrait correspondre.'
            );
            System.debug('Validation : le nom de l\'utilisateur correspond.');
        }
    }
}
