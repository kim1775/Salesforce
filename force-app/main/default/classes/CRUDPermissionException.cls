/**
 * @description       : Custom Exception for CRUD permission breaks
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-05-2021   Obidjon   Initial Version
 **/
public with sharing class CRUDPermissionException extends Exception {
    public CRUDPermissionException(String target, String action) {
        setMessage('Failed to ' + action + ' on ' + target);
    }
}