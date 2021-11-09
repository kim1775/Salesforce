/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 06-03-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   06-03-2021   Obidjon   Initial Version
 **/
@IsTest
private class KakaoCustomerReference_Test {
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json =
            '{' +
            '    \"user_key\": \"aEmSUzBR1OsV\",' +
            '    \"sender_key\": \"6f77c070905056b409a5125ef96c99ab659c2b34\",' +
            '    \"app_user_id\": null,' +
            '    \"time\": 1.622703928625e12,' +
            '    \"reference\": { \"extra\": \"\", \"text\": \"\", \"lastText\": \"\", \"lastTextDate\": \"\", \"appUserId\": null },' +
            '    \"last_reference\": { \"extra\": \"\", \"bot\": \"\", \"bot_event\": \"\", \"created_at\": \"\" }' +
            '}';
        KakaoCustomerReference r = KakaoCustomerReference.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KakaoCustomerReference.Last_reference objLast_reference = new KakaoCustomerReference.Last_reference(
            System.JSON.createParser(json)
        );
        System.assert(objLast_reference != null);
        System.assert(objLast_reference.extra == null);
        System.assert(objLast_reference.bot == null);
        System.assert(objLast_reference.bot_event == null);
        System.assert(objLast_reference.created_at == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KakaoCustomerReference.Reference objReference = new KakaoCustomerReference.Reference(
            System.JSON.createParser(json)
        );
        System.assert(objReference != null);
        System.assert(objReference.extra == null);
        System.assert(objReference.text == null);
        System.assert(objReference.lastText == null);
        System.assert(objReference.lastTextDate == null);
        System.assert(objReference.appUserId == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KakaoCustomerReference objKakaoCustomerReference = new KakaoCustomerReference(System.JSON.createParser(json));
        System.assert(objKakaoCustomerReference != null);
        System.assert(objKakaoCustomerReference.user_key == null);
        System.assert(objKakaoCustomerReference.sender_key == null);
        System.assert(objKakaoCustomerReference.app_user_id == null);
        System.assert(objKakaoCustomerReference.time_Z == null);
        System.assert(objKakaoCustomerReference.reference == null);
        System.assert(objKakaoCustomerReference.last_reference == null);
    }
}