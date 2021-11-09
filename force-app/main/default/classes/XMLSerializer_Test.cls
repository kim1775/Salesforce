/****************************************************************************************
  * File Name   : XMLSerializer
  * Description : XMLSerializer Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.02.19.    ldb3100    Create
****************************************************************************************/
@isTest
public class XMLSerializer_Test {
    
    static string xmlString = '<catalog><books><book><title>Advanced Apex Programming</title><subTitle>for Salesforce.com and Force.com</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
   
    //Serialize test
    private static testMethod void serialize_Test(){
        clsLibrary library = new clsLibrary();
        clsCatalog catalog = new clsCatalog();
        clsBooks books = new clsBooks();
        List<clsBook> book = new List<clsBook>();
        
        clsBook book1 = new clsBook();
        book1.title = 'Advanced Apex Programming';
        clsAuthors apexAuthors = new clsAuthors();
        List<String> apexAuthor = new List<String>();
        apexAuthor.add('Dan Appleman');
        apexAuthors.author = apexAuthor;
        book1.authors = apexauthors;
        book.add(book1);
        books.book = book;
        catalog.books = books;
        library.catalog = catalog;
        
        XmlSerializer serializer = new XmlSerializer();
        String serializedWithDefaultOptions = serializer.serialize(library);
         System.debug('serializedWithDefaultOptions:' +    serializedWithDefaultOptions);
        //properties with no value serialized with default options
        System.assert(serializedWithDefaultOptions.containsIgnoreCase('<subTitle></subTitle>'));
        
        string serializedXMLWithOptions = serializer.serialize(library, true, 'Root');
        //properties without value (null or empty) are omitted with suppressApexObjectNulls setting to true
        System.assert(!serializedXMLWithOptions.containsIgnoreCase('<subTitle></subTitle>'));
        //check that the XML is wrapped with root element
        System.assert(serializedXMLWithOptions.contains('<Root>'));
        System.assert(serializedXMLWithOptions.contains('</Root>'));
        
        System.debug('serializedXMLWithOptions:' +    serializedXMLWithOptions);        
        
    }

    //deSerialize test
    private static testMethod void deSerialize_Test(){
        XmlSerializer serializer = new XmlSerializer();
        clsLibrary library = (clsLibrary)serializer.deSerialize(xmlString, clsLibrary.class,new Set<String>{'author'});  
        
        System.assertEquals(2, library.catalog.books.book.size());
        
        for(clsBook b: library.catalog.books.book){            
            if(b.title == 'Advanced Apex Programming') system.assertEquals(1, b.authors.author.size()); //Make sure author is deSerialized as list even with one element in array
            else system.assertEquals(4, b.authors.author.size());
        }
    }
    
    //deSerializeUntyped test
    private static testMethod void deSerializeUnTyped_Test(){
       XmlSerializer serializer = new XmlSerializer();
       object o = serializer.deSerializeUnTyped(xmlString, new Set<String>{'author'});          
        System.assert(o instanceOf Map<String,Object>);
        Map<String,Object> libraryMap = (Map<string,Object>)o;
        System.assert(libraryMap.containsKey('catalog'));
        serializer.resetDefaults(); //reset to default options
        object xmlToUnTypedObjectDefault = serializer.deSerializeUnTyped(xmlString);
         Map<String,Object> libraryMap1 = (Map<string,Object>)xmlToUnTypedObjectDefault;
        System.assert(libraryMap1.containsKey('catalog'));
        
        object xmlToUnTypedObjectWithOptions = serializer.deSerializeUnTyped(xmlString,new Set<String>{'author'});
         Map<String,Object> libraryMap2 = (Map<string,Object>)xmlToUnTypedObjectWithOptions;
        System.assert(libraryMap2.containsKey('catalog'));        
    }
    
    //XML to Json conversion test
   private static testMethod void XMLToJSonConversion_Test(){
        XmlSerializer serializer = new XmlSerializer();
        String jsonString = serializer.XMLToJSON(xmlString);               
        String expectedOutput = '{"catalog":{"books":{"book":[{"price":"39.95","authors":{"author":"Dan Appleman"},"subTitle":"for Salesforce.com and Force.com","title":"Advanced Apex Programming"},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
        System.assertEquals(expectedOutput, jsonString);
       
       String jsonStringWithConvertAsArray = serializer.XMLToJSON(xmlString,new Set<String>{'author'}); 
       System.debug('jsonStringWithConvertAsArray:' + jsonStringWithConvertAsArray);
       String expectedOutputWithArray ='{"catalog":{"books":{"book":[{"price":"39.95","authors":{"author":["Dan Appleman"]},"subTitle":"for Salesforce.com and Force.com","title":"Advanced Apex Programming"},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
       System.assertNotEquals(expectedOutput, jsonStringWithConvertAsArray);
       System.assertEquals(expectedOutputWithArray, jsonStringWithConvertAsArray);
    }
    
    //Json to XML converion test
    private static testMethod void JsonToXMLConversion_Test(){        
        String jsonString = '{"catalog":{"books":{"book":[{"price":"39.95","authors":{"author":"Dan Appleman"},"subTitle":"for Salesforce.com and Force.com","title":null},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
		XmlSerializer serializer = new XmlSerializer();
        String convertedXmlString = serializer.JSONToXML(jsonString);   

        String expectedOutputWithDefaultOptions = '<catalog><books><book><price>39.95</price><authors><author>Dan Appleman</author></authors><subTitle>for Salesforce.com and Force.com</subTitle><title></title></book><book><price>37.88</price><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><title>Design Patterns</title></book></books></catalog>';
        System.assertEquals(expectedOutputWithDefaultOptions, convertedXmlString);
        
        string convertedStringWithOptions = serializer.JsonToXML(jsonString, true);
        System.debug('convertedStringWithOptions:' + convertedStringWithOptions);
        String expectedOutputWithOptions = '<catalog><books><book><price>39.95</price><authors><author>Dan Appleman</author></authors><subTitle>for Salesforce.com and Force.com</subTitle></book><book><price>37.88</price><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><title>Design Patterns</title></book></books></catalog>';
        System.assertEquals(expectedOutputWithOptions, convertedStringWithOptions);
        
    }
     

    
    public class clsLibrary {        
        public clsCatalog catalog;
    }
     public class clsCatalog {
        public clsBooks books;
    }
    public class clsBooks {
        public List<clsBook> book;
    }
    public class clsBook {
        public String title;
        public String subTitle;
        public clsAuthors authors;
        public String price;
    }
    
    public class clsAuthors {
        public List<String> author;
    }

    private static testMethod void doTest(){
        String xml = '';
        xml += '<OrderInformation>';
        xml += '<Status>Success</Status>';
        xml += '<Order>';
        xml += '<OrderNumber>2021012600001</OrderNumber>';
        xml += '<CustomerCode>1001655</CustomerCode>';
        xml += '<Status>Approved</Status>';
        xml += '<DeliveryDate>20210127</DeliveryDate>';
        xml += '<CreatedDate>20210126</CreatedDate>';
        xml += '<TotalAmount>204000</TotalAmount>';
        xml += '<CancelReasonCode/>';
        xml += '<CancelReason/>';
        xml += '<OrderItem>';
        xml += '<ProductCode>MFKSFT</ProductCode>';
        xml += '<Quantity>30</Quantity>';
        xml += '<Amount>122400</Amount>';
        xml += '</OrderItem>';
        xml += '<OrderItem>';
        xml += '<ProductCode>MBKSIBL</ProductCode>';
        xml += '<Quantity>20</Quantity>';
        xml += '<Amount>81600</Amount>';
        xml += '</OrderItem>';
        xml += '</Order>';
        xml += '<Order>';
        xml += '<OrderNumber>2021012600002</OrderNumber>';
        xml += '<CustomerCode>1001656</CustomerCode>';
        xml += '<Status>Approved</Status>';
        xml += '<DeliveryDate>20210127</DeliveryDate>';
        xml += '<CreatedDate>20210122</CreatedDate>';
        xml += '<TotalAmount>163300</TotalAmount>';
        xml += '<CancelReasonCode/>';
        xml += '<CancelReason/>';
        xml += '<OrderItem>';
        xml += '<ProductCode>MBGDULT</ProductCode>';
        xml += '<Quantity>30</Quantity>';
        xml += '<Amount>122400</Amount>';
        xml += '</OrderItem>';
        xml += '<OrderItem>';
        xml += '<ProductCode>HSVLB20</ProductCode>';
        xml += '<Quantity>10</Quantity>';
        xml += '<Amount>40900</Amount>';
        xml += '</OrderItem>';
        xml += '</Order>';
        xml += '</OrderInformation>';

        XmlSerializer serializer = new XmlSerializer();
        String jsonString = serializer.XMLToJSON(xml);
        system.debug('==============================jsonString '+jsonString);

        OrderWrapper rw = (OrderWrapper) JSON.deserialize(jsonString, OrderWrapper.class);
        system.debug('============================== '+rw);

    }

    private class OrderWrapper {
        OrderInformation orderInformation;
    }
    private class OrderInformation {
        List<Order> order;
    }
    private class Order {
        String OrderNumber;
        String CustomerCode;
        String Status;
        String DeliveryDate;
        String CreatedDate;
        String TotalAmount;
        String CancelReasonCode;
        String CancelReason;
        List<OrderItem> orderItem;
    }
    private class OrderItem {
        String ProductCode;
        String Quantity;
        String Amount;
    }
    private static testMethod void doTest2(){
        String xml = '';
        xml += '<CustomerInformation>';
        xml += '<Retailer>';
        xml += '<CustomerCode>1001655</CustomerCode>';
        xml += '<CustomerName>장수슈퍼</CustomerName>';
        xml += '<PMGrade>P5</PMGrade>';
        xml += '<SRZCode>2406</SRZCode>';
        xml += '<CustomerStatus>A</CustomerStatus>';
        xml += '<Address>경기도 광주시 오포읍양촌길 190</Address>';
        xml += '<AddressZipcode>12798</AddressZipcode>';
        xml += '<MainPhoneNo>031-768-3885</MainPhoneNo>';
        xml += '<SubPhoneNo />';
        xml += '<BusinessRegiNo>1260992902</BusinessRegiNo>';
        xml += '<HostName />';
        xml += '<deliveryDay>MON</deliveryDay>';
        xml += '</Retailer>';
        xml += '<Retailer>';
        xml += '<rowNo>250</rowNo>';
        xml += '<CustomerCode>1001656</CustomerCode>';
        xml += '<CustomerName>한국유통그린점ㅁㄴㅇㄹ</CustomerName>';
        xml += '<PMGrade>P4</PMGrade>';
        xml += '<SRZCode>2407</SRZCode>';
        xml += '<CustomerStatus>A</CustomerStatus>';
        xml += '<Address>경기도 성남시 중원구둔촌대로425번길 28, (상대원동) ㅁㅁ 호효ㅕㅛㅕㅛㅕ</Address>';
        xml += '<AddressZipcode>13221</AddressZipcode>';
        xml += '<MainPhoneNo>031-735 -ㅑㅐㅕㅑ</MainPhoneNo>';
        xml += '<SubPhoneNo />';
        xml += '<BusinessRegiNo>1291786817</BusinessRegiNo>';
        xml += '<HostName />';
        xml += '<deliveryDay>MON</deliveryDay>';
        xml += '</Retailer>';
        xml += '</CustomerInformation>';


        XmlSerializer serializer = new XmlSerializer();
        String jsonString = serializer.XMLToJSON(xml);
        system.debug('==============================jsonString '+jsonString);

        CustomerWrapper rw = (CustomerWrapper) JSON.deserialize(jsonString, CustomerWrapper.class);
        system.debug('============================== '+rw);

    }

    private class CustomerWrapper {
        CustomerInformation customerInformation;
    }
    private class CustomerInformation {
        List<Retailer> retailer;
    }
    private class Retailer {
        String rowNo;
        String CustomerCode;
        String CustomerName;
        String PMGrade;
        String SRZCode;
        String CustomerStatus;
        String Address;
        String AddressZipcode;
        String MainPhoneNo;
        String SubPhoneNo;
        String BusinessRegiNo;
        String HostName;
        String deliveryDay;
    }

    private static testMethod void dotest3(){
        String jsonString = '{"OrderInformation":{"Order":[{"OrderItem":[{"Amount":"122400","Quantity":"30","ProductCode":"MFKSFT"},{"Amount":"81600","Quantity":"20","ProductCode":"MBKSIBL"}],"CancelReason":"","CancelReasonCode":"","TotalAmount":"204000","CreatedDate":"20210126","DeliveryDate":"20210127","Status":"Approved","CustomerCode":"1001655","OrderNumber":"2021012600001"},{"OrderItem":[{"Amount":"122400","Quantity":"30","ProductCode":"MBGDULT"},{"Amount":"40900","Quantity":"10","ProductCode":"HSVLB20"}],"CancelReason":"","CancelReasonCode":"","TotalAmount":"163300","CreatedDate":"20210122","DeliveryDate":"20210127","Status":"Approved","CustomerCode":"1001656","OrderNumber":"2021012600002"}],"Status":"Success"}}';
        XmlSerializer serializer = new XmlSerializer();
        String xmlString = serializer.jsonToXML(jsonString);
        System.debug('xmlString : ' + xmlString);
    }

    private static testMethod void doTest4(){
        String jsonString = '{"CustomerInformation":{"Retailer":[{"deliveryDay":"MON","HostName":"","BusinessRegiNo":"1260992902","SubPhoneNo":"","MainPhoneNo":"031-768-3885","AddressZipcode":"12798","Address":"경기도 광주시 오포읍양촌길 190","CustomerStatus":"A","SRZCode":"2406","PMGrade":"P5","CustomerName":"장수슈퍼","CustomerCode":"1001655"},{"deliveryDay":"MON","HostName":"","BusinessRegiNo":"1291786817","SubPhoneNo":"","MainPhoneNo":"031-735 -ㅑㅐㅕㅑ","AddressZipcode":"13221","Address":"경기도 성남시 중원구둔촌대로425번길 28, (상대원동) ㅁㅁ 호효ㅕㅛㅕㅛㅕ","CustomerStatus":"A","SRZCode":"2407","PMGrade":"P4","CustomerName":"한국유통그린점ㅁㄴㅇㄹ","CustomerCode":"1001656","rowNo":"250"}]}}';
        XMLSerializer serializer = new XMLSerializer();
        String xmlString = serializer.jsonToXML(jsonString);
        System.debug('xml String : ' + xmlString);
    }
}