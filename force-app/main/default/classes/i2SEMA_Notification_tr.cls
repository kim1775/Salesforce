/****************************************************************************************
  * @filename       : i2SEMA_Notification_tr
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-14 오후 4:17
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_Notification_tr_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author              description
  * ===============================================================
    0.1     2020-04-14 오후 4:17     i2max_byeon.jw       Create
    0.2     2020-06-02 오후 1:17     i2max_shlee          수정 : 테스트 옵션시, 등록된 폰 번호로만 메세지 발송 validation 추가
****************************************************************************************/
@SuppressWarnings('PMD.ApexSOQLInjection')
public without sharing class i2SEMA_Notification_tr extends i2SEMA_TriggerHandler{

    private final String TYPE_ADVERTISING = '1';
    private final String TYPE_INFORMATION = '2';

    //TODO SIT or UAT 일경우 TRUE임. 운영 배포시 반드시 FALSE로 값 변경하고 배포해야함
    private Boolean SITUAT = FALSE;
    private Set<String> testNumberSet = new Set<String>{
              '01022884132' // I2MAX 이상협
            , '01050414193' // I2MAX ㄴ
            , '01023035629' // I2MAX 이지현
            , '01038319905' // I2MAX 박현은
            , '01056454513' // I2MAX 전예린
            , '01064102254' // PMK 서지원
            , '01071927651' // PMK 신해나 1
            , '01027387651' // PMK 신해나 2
            , '01051060569' // PMK 심원지 1
            , '01027610569' // PMK 심원지 2
            , '01057423960' // PMK 한인규
            , '01021428373' // WISE 권철민
            , '01065676339' // WISE
            , '01057978520' // WISE
            , '01090305236' // WISE
            , '01028311132' // WISE
            , '01088907101' // 백남호
            , '01042557327' // 이단비
            , '01039304121' // 이동후 DonghuLee
            , '01081078689' // Park, Kelly
            , '01098114277' // 이재현
            , '01094484354' // 박민선 MinsunPark
            , '01090802854' // 김지현 jihyun kim
            , '01080817777' // 두승훈 SeunghoonDoo
            , '01066095133' // 허동렬
            , '01065843080' // 함형규 HenryHam
            , '01056101005' // Sadykova, Salamat
            , '01052221798' // Bryant Park
            , '01052218878' // 강혜주
            , '01051785703' // 김재혁 JaehyukKim
            , '01040804722' // Lee, Boram
            , '01034262540' // 정유리 NicoleJung
            , '01033735042' // 김미연 CarrieKim
            , '01033100113' // 정희경 BellaJeong
            , '01032507169' // 이근우 KWLee
            , '01024242349' // 이규일 KyuilLee
            , '01099142464' // agentCC4
            , '01099142464' // Anny.Lee
            , '01098427749' // 예송희 SOnghuiYe
            , '01097221460' // 김금영 GeumYoungKim
            , '01096251040' // 김희영 HeeyoungKim
            , '01096069048' // 반혜빈 HyebinBan
            , '01094088011' // 김태은 Kim, Taen
            , '01092514152' // 최승현
            , '01092481435' // 최예림 yerim
            , '01092405418' // 이혜지 HYejiLee
            , '01091787990' // Kim, Ji Hyun
            , '01088882590' // 안준영 JunYoungAhn
            , '01088810527' // 이혁순 HyucksoonLee
            , '01088541967' // 조연수 YUnsuCho
            , '01087961960' // 박기태 GItaePark
            , '01086712858' // 김용주 YOngjuGim
            , '01086177249' // 김유진 YUjinKim
            , '01085451213' // 김지현 JIhyunKim
            , '01085446958' // 강연화 YEonhwaKang
            , '01085198491' // 홍다정 DAjungHong
            , '01083696463' // 박시현 SIhyeonPark
            , '01082990751' // 김남현 NamhyunKim
            , '01081498520' // 이진우 JinwooLee
            , '01076899711' // 이단비 DAnbiLee
            , '01076535607' // 박설희 SEolheePark
            , '01076089768' // 신소연 SOyeonShin
            , '01076034771' // 신혜린 HYerinShin
            , '01072321219' // 이현주 HYunjooLee
            , '01071927651' // 신해나 KaylaShin
            , '01071765473' // 이호민
            , '01071227707' // 신민영 MInyoungSin
            , '01071052271' // 김리하 RIaKim
            , '01066799389' // 이윤미 YOonmiLee
            , '01065540108' // 김은진 EUnjinKim
            , '01064363645' // 이예니 YEniLEe
            , '01064102254' // 서지원 GeewonSeo
            , '01064045699' // 류정현 JHRyu
            , '01063836827' // 정재인 JaeinJung
            , '01063066152' // 윤수영 SueyoungYun
            , '01062677253' // 손은수 EUnsuson
            , '01062632601' // 김용남 YongnamKim
            , '01062355301' // 오교용 KyoyongOh
            , '01058987698' // 박혜린 HYerinPark
            , '01057901721' // 이동호 DOnghoLee
            , '01057558454' // 권아영 AyoungKwon
            , '01057423960' // 한인규 AlexHan
            , '01056209285' // 조미선 MISUN_JO
            , '01055343134' // 김동엽 DOngyeopKim
            , '01054775703' // 고유미 yumi
            , '01054712140' // 김희영 ChristineKim
            , '01054453131' // Shin, Irene
            , '01053944282' // GenesysPS
            , '01053944282' // 노승재
            , '01053485441' // 송기범 KIbeomsong
            , '01052524382' // 정성윤
            , '01052500180' // 김철준 MikeKim
            , '01052452722' // 김정진 JungjinKim
            , '01051698765' // 양성준
            , '01051678117' // 배경완
            , '01049335919' // 윤소영 SOyeongYun
            , '01048745324' // 서장훈
            , '01048536798' // 박륜경
            , '01046954810' // Kim, Shin
            , '01045362702' // 이기정
            , '01045027984' // 이서형 SeohyeongLee
            , '01044794587' // 배서정 SEojungBae
            , '01044440280' // 김재영 JaeyoungKim
            , '01043545557' // 이승주
            , '01042376608' // 이나리 NariLee
            , '01041841261' // 박재율
            , '01041115642' // 강슬아
            , '01039969326' // 김해수
            , '01039391694' // 노재희 Jaehui
            , '01039318441' // 박보훈 bhpark
            , '01039218375' // 김민성
            , '01039117132' // Baek, John
            , '01038999315' // 김승권 seungkwon
            , '01038487657' // 오성우 DanielOh
            , '01036176494' // 방대영
            , '01034226405' // 한아름 AreumHan
            , '01032523387' // Park, Victor
            , '01031110261' // EunHye.Lee
            , '01031003523' // Magento_InterfaceOnly
            , '01029264815' // 이정복 JEongbokLee
            , '01029228373' // 권철민 ChulminKwon
            , '01028701457' // 오승훈 SeunghunOh
            , '01028660521' // 양우석 WooseokYang
            , '01028480936' // kim saetbyeol
            , '01028100860' // 김윤정 YOonjungKim
            , '01027990193' // 김연실 YEonsilKim
            , '01027875997' // 임재현 JaehyunLim
            , '01027258029' // 이재연 JAeyeonLee
            , '01027095617' // 박영재 YoungjaePark
            , '01026428083' // 김태진 TaeJinKim
            , '01023755857' // 홍태근
            , '01023737943' // 전동식 DongsikJeon
            , '01023015806' // Jason Lee
            , '01021270722' // 장지원 JiwonJang
            , '01021037846' // 윤영모 RandyYoon
            , '01072598851' // 류종덕
            , '01028821068' // Wise
            , '01050588177' // Wise
            , '01095141492' // Notiforce Test
            , '01090381298' // 박수진
            , '01033600534'
            , '01099250955'
            , '01072442438'
            , '01065472438'//
            , '01040804722'
            , '01073782801'
            , '01032523387'
            , '01064089664'
            , '01036037671'
            , '01035940914' // 김태규 TedKim
            , '01030755735'
            , '01050929396'
            , '01038400146'
            , '01095800583'
            , '01028735727'
            , '01048388522'
    };

    private final static Id RT_Contact_ProspectId       = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Prospect').getRecordTypeId();     // 고객 : Prospect
    private final static Id RT_Contact_MemberId         = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Member').getRecordTypeId();       // 고객 : iqos.com 회원 멤버

    static List<Notification__c> notifications;
    static Set<String> unsubscriptionNumbers    = new Set<String>();
    static Set<Id> proceedIds                   = new Set<Id>();

    public override void beforeInsert(){
        this.setPhoneNumber();      // 수신자 Phone Number 설정
        this.setContact();          // Contact 없는 경우 Phone으로 Contact 찾아서매핑하기
    }
    public override void beforeUpdate(){
        this.setPhoneNumber();      // 수신자 Phone Number 설정
        this.setPhoneNull();
    }

    public override void afterInsert(){
        this.getData();             // Notification 조회
        this.convertContents();     // Notification 본문치환
        this.checkData();           // Notification 유효체크
    }
    public override void afterUpdate(){
        this.getData();             // Notification 조회
        this.convertContents();     // Notification 본문치환
        this.checkData();           // Notification 유효체크

    }

    /**
     * @description 수신자 Phone Number 설정
     *  - i2SEMA Config 설정값 참조
     */
    private void setPhoneNumber(){
        List<Notification__c> newData = (List<Notification__c>)Trigger.new;

        Map<String,Set<Id>> targetData = new Map<String,Set<Id>> {
                SObjectType.Account.getName()   => new Set<Id>(),
                SObjectType.Contact.getName()   => new Set<Id>(),
                SObjectType.Lead.getName()      => new Set<Id>(),
                SObjectType.User.getName()      => new Set<Id>()
        };

        // Notification 별 발송 대상 수집
        for( Notification__c notification : newData ){
            Id targetId = i2SEMA_Util.isNotEmpty(notification.Account__c) ? notification.Account__c
                    : i2SEMA_Util.isNotEmpty(notification.Contact__c) ? notification.Contact__c
                            : i2SEMA_Util.isNotEmpty(notification.Lead__c) ? notification.Lead__c
                                    : i2SEMA_Util.isNotEmpty(notification.User__c) ? notification.User__c : null;

            if( i2SEMA_Util.isNotEmpty(targetId)){
                String targetObject = targetId.getSobjectType().getDescribe().getName();
                Set<Id> targetIds = targetData.get(targetObject);
                targetIds.add(targetId);
                targetData.put(targetObject,targetIds);
            }
        }
        System.debug('targetData : '+targetData);
        // 발송대상의 전화번호 조회
        Map<Id,SObject> receiverData = new Map<Id,SObject>();
        for( String targetObject : targetData.keySet() ){
            Set<Id> targetIds = targetData.get(targetObject);

            if( !targetIds.isEmpty()){
                String queryString  = 'SELECT Id, Name, ';
                queryString         += targetObject.equals(SObjectType.Account.getName()) ? i2SEMA_Base.getAccountDefaultPhoneField()
                        : targetObject.equals(SObjectType.Contact.getName()) ? i2SEMA_Base.getContactDefaultPhoneField()
                                : targetObject.equals(SObjectType.Lead.getName()) ? i2SEMA_Base.getLeadDefaultPhoneField()
                                        : targetObject.equals(SObjectType.User.getName()) ? i2SEMA_Base.getUserDefaultPhoneField() : null;
                //PMK DCE
                if(targetObject.equals(SObjectType.Contact.getName()) )
                    queryString     += ' ,KDCE_ConvertedConsumer__c ,KDCE_MarketingOptIn__c, KDCE_InformationOptIn__c, KDCE_OldInformationOptIn__c, KDCE_OldMarketingOptIn__c, RecordTypeId ';
                queryString         += ' FROM ' + targetObject;
                queryString         += ' WHERE Id IN: targetIds';

                system.debug('------------->> Set Phone Query');
                system.debug(queryString);

                receiverData.putAll( new Map<Id,SObject>(Database.query(queryString)));
            }
        }

        // Notification 의 발송 대상 Phone 설정
        for( Notification__c notification : newData ){
            Id targetId = i2SEMA_Util.isNotEmpty(notification.Account__c) ? notification.Account__c
                    : i2SEMA_Util.isNotEmpty(notification.Contact__c) ? notification.Contact__c
                            : i2SEMA_Util.isNotEmpty(notification.Lead__c) ? notification.Lead__c
                                    : i2SEMA_Util.isNotEmpty(notification.User__c) ? notification.User__c : null;

            if( targetId != null && receiverData.containsKey(targetId)){
                SObject receiver    = receiverData.get(targetId);
                String receiverType = receiver.getSObjectType().getDescribe().getName();

                notification.Phone__c =  receiverType.equals(SObjectType.Account.getName()) ? (String)receiver.get(i2SEMA_Base.getAccountDefaultPhoneField())
                        : receiverType.equals(SObjectType.Contact.getName()) ? (String)receiver.get(i2SEMA_Base.getContactDefaultPhoneField())
                                : receiverType.equals(SObjectType.Lead.getName()) ? (String)receiver.get(i2SEMA_Base.getLeadDefaultPhoneField())
                                        : receiverType.equals(SObjectType.User.getName()) ? (String)receiver.get(i2SEMA_Base.getUserDefaultPhoneField()) : null;
                //PMK DCE Opt-in/out by shlee
                if(receiverType.equals(SObjectType.Contact.getName())) {
                    //TODO 권책임 수정  Prospect / Member 값을 위에서 soql 실행시 가져오고, Prospect/ Member에 대한 조건처리 작성

                    // Prospect => New Or Old 둘 중 하나라도 true 
                    if((Id)receiver.get('RecordTypeId') == RT_Contact_ProspectId){

                        if((Boolean)receiver.get('KDCE_MarketingOptIn__c') || (Boolean)receiver.get('KDCE_OldMarketingOptIn__c')) notification.ContactMarketingOptIn__c = true;
                        if((Boolean)receiver.get('KDCE_InformationOptIn__c') || (Boolean)receiver.get('KDCE_OldInformationOptIn__c')) notification.ContactInformationOptIn__c = true;
                    }
                    // Member
                    else if ((Id)receiver.get('RecordTypeId') == RT_Contact_MemberId) {

                        if((Boolean)receiver.get('KDCE_ConvertedConsumer__c')) { //new IQOS.COM 전환고객 new Opt-In
                            notification.ContactMarketingOptIn__c = (Boolean)receiver.get('KDCE_MarketingOptIn__c');
                            notification.ContactInformationOptIn__c = (Boolean)receiver.get('KDCE_InformationOptIn__c');
                        } else { //미전환고객 old Opt-In
                            notification.ContactMarketingOptIn__c = (Boolean)receiver.get('KDCE_OldMarketingOptIn__c');
                            notification.ContactInformationOptIn__c = (Boolean)receiver.get('KDCE_OldInformationOptIn__c');
                        }

                    }

                    /*
                    //Member
                    if((Boolean)receiver.get('KDCE_ConvertedConsumer__c')) { //new IQOS.COM 전환고객 new Opt-In
                        notification.ContactMarketingOptIn__c = (Boolean)receiver.get('KDCE_MarketingOptIn__c');
                        notification.ContactInformationOptIn__c = (Boolean)receiver.get('KDCE_InformationOptIn__c');
                    } else { //미전환고객 old Opt-In
                        notification.ContactMarketingOptIn__c = (Boolean)receiver.get('KDCE_OldMarketingOptIn__c');
                        notification.ContactInformationOptIn__c = (Boolean)receiver.get('KDCE_OldInformationOptIn__c');
                    }
                    */

                    System.debug('setPhoneNumber ContactMarketingOptIn__c : '+notification.ContactMarketingOptIn__c);
                    System.debug('setPhoneNumber ContactInformationOptIn__c : '+notification.ContactInformationOptIn__c);
                }
            }else if(targetId != null){
                notification.Phone__c = null;
            }else if(targetId == null){
                /**
                 *  CTI에서 전화번호로만 문자 발송 가능하게 변경
                 *  by 이동후
                 **/
                notification.ContactInformationOptIn__c = true;
            }
        }
    }

    /**
     * @description Notification 조회
     */
    private void getData(){
        Set<Id> newDataIds = Trigger.newMap != null ? Trigger.newMap.keySet() : new Set<Id>();

        // Notification 조회
        notifications = [SELECT Id, OriginSystem__c, byHeroku__c, KDCE_ShortenURL__c
                ,Account__c,Contact__c,Lead__c,Phone__c, Content__c
                ,ContactMarketingOptIn__c,ContactInformationOptIn__c, Type__c
                ,Channel__c,NotificationTemplate__c,NotificationTemplate__r.IsActive__c,NotificationTemplate__r.IF_Status__c, NotificationTemplate__r.NPS__c
                ,fm_Label1Usage__c,fm_Label2Usage__c,fm_Label3Usage__c,fm_Label4Usage__c,fm_Label5Usage__c
                ,LABEL1__c,LABEL2__c,LABEL3__c,LABEL4__c,LABEL5__c
                ,IsSendingReservation__c, SendingTime__c
                ,RawContents__c, IsForcedSend__c
        FROM Notification__c
        WHERE Id IN:newDataIds AND Id NOT IN:proceedIds];

        // Unsubscription 조회
        Set<String> notificationNumbers = new Set<String>();
        for(Notification__c noti : notifications ){
            if( i2SEMA_Util.isNotEmpty(noti.Phone__c)){
                notificationNumbers.add(noti.Phone__c);
            }
        }
        List<Unsubscription__c> unSubscriptions = [SELECT Id,Phone__c
        FROM Unsubscription__c
        WHERE Active__c = TRUE
        AND Phone__c IN: notificationNumbers];

        for(Unsubscription__c unsubscription : unSubscriptions ){
            unsubscriptionNumbers.add(i2SEMA_Util.convertPhoneNumberFormat(unsubscription.Phone__c));
        }
    }
    /**
     * @description Notification 본문 치환 : 단건 NPS URL치환 처리 할지 말지 협의
     */
    private void convertContents(){
        for(Notification__c nt : notifications ){

            if(nt.KDCE_ShortenURL__c) continue;

            nt.Content__c = nt.RawContents__c;
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label1Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL1__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_01_VAL , nt.LABEL1__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label2Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL2__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_02_VAL , nt.LABEL2__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label3Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL3__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_03_VAL , nt.LABEL3__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label4Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL4__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_04_VAL , nt.LABEL4__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label5Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL5__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_05_VAL , nt.LABEL5__c);
            }
        }
    }

    /**
     * @description Notification 유효체크
     */
    private void checkData(){
        System.debug('notifications :: ' + notifications);

        String userName = UserInfo.getName();
        Boolean userFlag = false;
        if(userName == 'Heroku Connector') userFlag = true;
        if(userFlag == true) return;

        for(Notification__c nt : notifications ){
            Notification__c originData = ((Map<Id,Notification__c>)Trigger.newMap).get(nt.Id);

            nt.Validity__c      = true;
            nt.ErrorMessage__c  = null;

            //Heroku 통해서 생성될 경우, validation Skip by shlee PMK DCE 커스텀
            if(nt.byHeroku__c) {
                proceedIds.add(nt.Id);
                continue;
            }

            // 수신자 유효확인
            if( nt.Validity__c && nt.Phone__c == null ){
                nt.Validity__c      = false;
                nt.ErrorMessage__c  = Label.i2SEMA_MSG_RECEIVER_PHONE_NOT_EXIST;

                // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_RECEIVER_PHONE_NOT_EXIST);
            }

            // 수신차단 유효확인
            if( nt.Validity__c && i2SEMA_Util.isNotEmpty(nt.Phone__c) && unsubscriptionNumbers.contains(i2SEMA_Util.convertPhoneNumberFormat(nt.Phone__c))){
                nt.Validity__c      = false;
                nt.ErrorMessage__c  = Label.i2SEMA_MSG_RECEIVER_PHONE_UNSUBSCRIBED;

                // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_RECEIVER_PHONE_UNSUBSCRIBED);
            }

            // 예약발송 유효확인 (당일 예약불가)
            if( nt.Validity__c && nt.IsSendingReservation__c == true ){
                // 스케쥴 시간이 비어있는 경우
                if( i2SEMA_Util.isEmpty(nt.SendingTime__c)){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID;

                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID);
                }
                else if( nt.SendingTime__c.dateGmt() <= Date.today()){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID;

                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID);
                }
            }

            // 템플릿 유효확인
            if( nt.Validity__c && nt.NotificationTemplate__c != null &&
                    (nt.NotificationTemplate__r.IsActive__c != true || !'Completed'.equalsIgnoreCase(nt.NotificationTemplate__r.IF_Status__c))){
                nt.Validity__c      = false;
                nt.ErrorMessage__c  = Label.i2SEMA_MSG_TEMPLATE_INVALID;

                // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                if( !System.isQueueable() && !Test.isRunningTest() ) originData.addError(Label.i2SEMA_MSG_TEMPLATE_INVALID);
            }

            // 라벨 유효확인
            if( nt.Validity__c){
                Boolean label1Valid = (nt.fm_Label1Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL1__c)) || (nt.fm_Label1Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL1__c));
                Boolean label2Valid = (nt.fm_Label2Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL2__c)) || (nt.fm_Label2Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL2__c));
                Boolean label3Valid = (nt.fm_Label3Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL3__c)) || (nt.fm_Label3Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL3__c));
                Boolean label4Valid = (nt.fm_Label4Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL4__c)) || (nt.fm_Label4Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL4__c));
                Boolean label5Valid = (nt.fm_Label5Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL5__c)) || (nt.fm_Label5Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL5__c));
                if( !label1Valid || !label2Valid || !label3Valid || !label4Valid || !label5Valid ){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_TEMPLATE_LABEL_INVALID;

                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest() ) originData.addError(Label.i2SEMA_MSG_TEMPLATE_LABEL_INVALID);
                }
            }
            // 길이 유효확인
            if( nt.Validity__c ){
                Boolean lengthValid = i2SEMA_Util.isValidMessageLength(nt.Channel__c , nt.Content__c);
                if( !lengthValid ){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_LENGTH_LIMIT_EXCEED;

                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest() ) originData.addError(Label.i2SEMA_MSG_LENGTH_LIMIT_EXCEED);
                }
            }
            // PMK DCE Contact's Opt-in
            if( nt.Validity__c ) {
                if ( !nt.IsForcedSend__c ) { // 화면에서 직접 전송하는 경우(IsForcedSend__c = T)에는 optIn을 고려하지 않는다
                    Boolean MarketingOptInValid = nt.ContactMarketingOptIn__c; //1 : 광고성,
                    Boolean InformationOptInValid = nt.ContactInformationOptIn__c; //2 : 정보성
//                System.debug('checkData NPS : '+nt.NotificationTemplate__r.NPS__c);
//                System.debug('checkData nt.Type__c : '+nt.Type__c);
//                System.debug('checkData MarketingOptInValid : '+MarketingOptInValid);
//                System.debug('checkData InformationOptInValid : '+InformationOptInValid);

                    //NPS 설문조사 메세지가 일경우, 무조건 발송 NPS는 무조건 템플릿을 통해서만 발송가능
                    if (Util.isEmpty(nt.NotificationTemplate__c) || (Util.isNotEmpty(nt.NotificationTemplate__c) && !nt.NotificationTemplate__r.NPS__c)) {
                        //Marketing Type (1) 은 Marketing Opt-in 이여야 발송가능
                        if (TYPE_ADVERTISING.equals(nt.Type__c) && !MarketingOptInValid) {
                            nt.Validity__c = false;
                            nt.ErrorMessage__c = 'You can not send this message. because of this contact\'s Marketing Opt-out';
                            // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                            if (!System.isQueueable() && !Test.isRunningTest()) originData.addError('You can not send this message. because of this contact\'s Marketing Opt-out');
                        }
                        //Information Type (2) 은 Information Opt-in 이여야 발송가능
                        else if (TYPE_INFORMATION.equals(nt.Type__c) && !InformationOptInValid) {
                            nt.Validity__c = false;
                            nt.ErrorMessage__c = 'You can not send this message. because of this contact\'s Information Opt-out';
                            // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                            if (!System.isQueueable() && !Test.isRunningTest()) originData.addError('You can not send this message. because of this contact\'s Information Opt-out');
                        }
                    }
                }
            }


            // PMK DCE Contact's Opt-in TEST 설정한 전화번호로만 발송, 일반인에게 발송되는 것 막음.
            if( nt.Validity__c ){
                if(SITUAT && !testNumberSet.contains(nt.Phone__c)) {

                    // TODO 등록 되지 않은 번호는 Notification 데이터만 만들고 오류는 발생시키지 않고 문자만 나가지 않도록 수정하였습니다. 2021.05.19 권준석
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = 'SIT & UAT 중에는 등록된 전화번호만 발송 가능합니다.';

                    //if(!Test.isRunningTest()) continue;
                    //if( !System.isQueueable() && !Test.isRunningTest()) originData.addError('SIT & UAT 중에는 등록된 전화번호만 발송 가능합니다. ');
                }
            }

            // 처리완료 목록에 추가
            proceedIds.add(nt.Id);
        }
        System.debug('checkData notifications :'+notifications);
        update notifications;
    }

    /**
     * 21-05-12 추가, Park He
     * phone을 키로 Contact과 매핑
     */
    private void setContact() {
        System.debug('=====Notification_tr.setContact Start=====');

        String userName = UserInfo.getName();
        Boolean userFlag = false;
        if(userName == 'Heroku Connector') userFlag = true;

        List<Notification__c> newData = (List<Notification__c>)Trigger.new;

        Set<String> phoneNumSet = new Set<String>();
        for(Notification__c nt : newData){
            if(nt.Contact__c != null) continue;
            if(nt.Phone__c == null) continue;
            phoneNumSet.add(nt.Phone__c);
        }

        Map<String, Id> contactIdsByPhone = new Map<String, Id>();
        for(Contact contact : [SELECT Id, KDCE_PNKey__c FROM Contact WHERE KDCE_PNKey__c IN :phoneNumSet]){
            contactIdsByPhone.put(contact.KDCE_PNKey__c, contact.Id);
        }

        System.debug('contactIdsByPhone : ' + contactIdsByPhone);

        for(Notification__c nt : newData){
            if(nt.Contact__c != null) continue;
            nt.Contact__c = contactIdsByPhone?.get(nt.Phone__c);
        }
        System.debug('newData : ' + newData);
        System.debug('=====Notification_tr.setContact END=====');

        // 전송완료 된 메시지는 전화번호 null 처리
        for(Notification__c nt : newData){
            if(userFlag == true) nt.Phone__c = null;
        }
    }

    private void setPhoneNull() {

        String userName = UserInfo.getName();
        Boolean userFlag = false;
        if(userName == 'Heroku Connector') userFlag = true;

        for(Notification__c nt : (List<Notification__c>)Trigger.new){
            if(userFlag == true) nt.Phone__c = null;
        }
    }
}