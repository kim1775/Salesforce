/****************************************************************************************
  * File Name   : XmlToJson
  * Description : XmlToJson Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.02.19.    ldb3100    Create
****************************************************************************************/
@isTest class XmlToJsonTest {
    @isTest static void test() {
        Dom.Document doc = new Dom.Document();
        doc.load(
                '<a>'+
                        '<b><c>Hello World</c><d>2016-05-01</d><e>2016-05-01 11:29:00 +03:00</e><f>true</f><g>3.1415</g><h>Two</h><h>Parts</h></b>'+
                        '<b><c>Hello World</c><d>2016-05-01</d><e>2016-05-01 11:29:00 +03:00</e><f>true</f><g>3.1415</g><h>Two</h><h>Parts</h></b>'+
                        '</a>'
        );

        String json = XmlToJson.parseDocumentToJson(doc); // XML TO JSON
        System.debug('json : ' + json);

        A r = (A)XmlToJson.parseDocumentToObject(doc, a.class);
        System.assertNotEquals(null, r);
        System.assertNotEquals(null, r.b);
        for(Integer i = 0; i != 2; i++) {
            System.assertNotEquals(null, r.b[i].c);
            System.assertNotEquals(null, r.b[i].d);
            System.assertNotEquals(null, r.b[i].e);
            System.assertNotEquals(null, r.b[i].f);
            System.assertNotEquals(null, r.b[i].g);
            System.assertNotEquals(null, r.b[i].h);
        }
    }
    class A {
        B[] b;
    }
    class B {
        String c;
        Date d;
        DateTime e;
        Boolean f;
        Decimal g;
        String[] h;
    }
}