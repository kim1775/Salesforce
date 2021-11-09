/**
 * @description       : File save service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-21-2021   Obidjon   Initial Version
 **/
public without sharing class FileSaveService {
    @future(callout=true)
    public static void saveFile(String url, Id recordId, String filename) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //Replace any spaces in extFileUrl with %20
        url = url.replace(' ', '%20');
        //Set the end point URL
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/jpeg');
        req.setCompressed(true);
        req.setTimeout(60000);
        //Now Send HTTP Request
        HttpResponse res = h.send(req);
        system.debug('Response from Server: ' + res.getBody());
        //getBodyAsBlob method was will convert the response into Blob
        Blob blobFile = res.getBodyAsBlob();
        Attachment attach = new Attachment();
        attach.ParentId = recordId;
        attach.Name = filename;
        attach.Body = blobFile;
        attach.ContentType = 'image/jpeg';
        if (
            Schema.SObjectType.Attachment.fields.ParentId.isCreateable() &&
            Schema.SObjectType.Attachment.fields.Name.isCreateable() &&
            Schema.SObjectType.Attachment.fields.Body.isCreateable() &&
            Schema.SObjectType.Attachment.fields.ContentType.isCreateable()
        ) {
            insert attach;
        } else {
            throw new CRUDPermissionException('Attachmant is not creatable with current permissions');
        }
    }
}