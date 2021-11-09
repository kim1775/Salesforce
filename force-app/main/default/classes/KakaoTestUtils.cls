/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 05-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   05-23-2021   Obidjon   Initial Version
 **/
@isTest
public class KakaoTestUtils {
    public static User createUser(String profileName) {
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@kakaoconsultchatter.app',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueUserName
        );
        insert u;
        return u;
    }

    public static void assignPermissionSet(String permSetName, Id userId) {
        PermissionSet ps = [SELECT id, name FROM PermissionSet WHERE name = :permSetName];
        // Given mocked Permission Set assigned to user for test
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
        insert psa;
    }
}