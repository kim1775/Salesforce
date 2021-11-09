/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-02-08 오후 1:55
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-02-08 오후 1:55     i2max_Junseok.Kwon        Create
    0.2     2021-03-03              i2max_Sukun               Update
****************************************************************************************/
// Util extend 받아 사용 위해 abstract로 변경하였습니다
@SuppressWarnings('PMD')
global abstract class Util {

    public static String getRecordTypeId(String objName, String devName) {

        List<RecordType> recordTypeList = [
                SELECT
                        DeveloperName,
                        Id,
                        IsActive,
                        Name,
                        SobjectType
                FROM RecordType
                WHERE SobjectType = :objName
                AND DeveloperName = :devName
                AND IsActive = TRUE
        ];
        if (!recordTypeList.isEmpty()) {
            return recordTypeList[0].Id;
        } else {
            return '';
        }
    }

    /**
     * @param objName
     *
     * @return Map<Id, String> RecordType Id 별 RecordType DeveloperName
     */
    /*
    public static Map<Id, String> getRecordTypeBySObject(String objName) {

        List<RecordType> rtList = [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE SobjectType = :objName
                AND IsActive = TRUE
        ];

        Map<Id, String> rtnMap = new Map<Id, String>();

        for(RecordType rt : rtList){
            rtnMap.put(rt.DeveloperName, rt.Id);
        }

        return rtnMap;
    }
     */

    public static Integer getInteger(Object str) {
        Integer value;
        try {
            value = Integer.valueOf(str);
        } catch (Exception e) {
            return 0;
        }
        if (Util.isEmpty(value)) {
            return 0;
        } else {
            return value;
        }
    }
    public static Double getDouble(Object str) {
        Double value;
        try {
            value = Double.valueOf(str);
        } catch (Exception e) {
            return 0;
        }
        if (Util.isEmpty(value)) {
            return 0;
        } else {
            return value;
        }
    }
    // Date to YYYY-MM-DD
    public static String yyyy_mm_dd(Date d) {
        String result = '';
        if (d != null) {
            String sMonth = String.valueof(d.month());
            String sDay = String.valueof(d.day());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            if (sDay.length() == 1) {
                sDay = '0' + sDay;
            }
            result = String.valueof(d.year()) + '-' + sMonth + '-' + sDay;
        }
        return result;
    }

    // Date to YYYY-MM
    public static String yyyy_mm(Date d) {
        String result = '';
        if (d != null) {
            String sMonth = String.valueof(d.month());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            result = String.valueof(d.year()) + '-' + sMonth;
        }
        return result;
    }

    // Date to YYYYMMDD
    public static String yyyymmdd(Date d) {
        String result = '';
        if (d != null) {
            String sMonth = String.valueof(d.month());
            String sDay = String.valueof(d.day());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            if (sDay.length() == 1) {
                sDay = '0' + sDay;
            }
            result = String.valueof(d.year()) + sMonth + sDay;
        }
        return result;
    }

    // Datetime to YYYY-MM-DD
    public static String yyyy_mm_dd(Datetime d) {
        String result = '';
        if (d != null) {
            String sMonth = String.valueof(d.month());
            String sDay = String.valueof(d.day());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            if (sDay.length() == 1) {
                sDay = '0' + sDay;
            }
            result = String.valueof(d.year()) + '-' + sMonth + '-' + sDay ;
        }
        return result;
    }

    // Datetime to YYYY-MM
    public static String yyyy_mm(Datetime d) {
        String result = '';
        if (d != null) {
            String sMonth = String.valueof(d.month());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            result = String.valueof(d.year()) + '-' + sMonth ;
        }
        return result;
    }

    // Datetime to YYYYMMDD
    public static String yyyymmdd(Datetime d) {
        String result = '';
        if (d != null) {
            String sMonth = String.valueof(d.month());
            String sDay = String.valueof(d.day());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            if (sDay.length() == 1) {
                sDay = '0' + sDay;
            }
            result = String.valueof(d.year()) + sMonth + sDay;
        }
        return result;
    }

    // String(YYYYMMDD) to Date
    public static Date yymmddToDate(String d) {
        Integer year = Integer.valueOf(d.substring(0, 4));
        Integer month = Integer.valueOf(d.substring(4, 6));
        Integer day = Integer.valueOf(d.substring(6, 8));
        return Date.newInstance(year, month, day);
    }

    // String(YYYYMMDD) to Date - YYYY(9999) -> YYYY(2999)
    public static Date yymmddToDate_exceedYear(String d) {
        Integer year = Integer.valueOf(d.substring(0, 4));
        if (year > 3000) year = 2999;
        Integer month = Integer.valueOf(d.substring(4, 6));
        Integer day = Integer.valueOf(d.substring(6, 8));
        return Date.newInstance(year, month, day);
    }

    // String(YYMMDD) to Date
    public static Datetime yymmddToDateTime(String d) {
        Integer year = Integer.valueOf(d.substring(0, 4));
        Integer month = Integer.valueOf(d.substring(4, 6));
        Integer day = Integer.valueOf(d.substring(6, 8));
        return Datetime.newInstance(year, month, day);
    }

    // String(2017-07-19 13:37:10) to Date
    public static Date yyyy_mm_dd_hh_mm_ssToDate(String d) {
        List<String> result = d.split(' ')[0].split('-');

        return Date.newInstance(Integer.valueOf(result[0]), Integer.valueOf(result[1]), Integer.valueOf(result[2]));
    }

    public static Datetime yyymmdd_hhmmssToDateTime(String d) {
        //List<String> result = d.split(' ')[0].split('-');
        List<String> result = d.split(' ');
        Integer year = Integer.valueOf(result[0].substring(0, 4));
        Integer month = Integer.valueOf(result[0].substring(4, 6));
        Integer day = Integer.valueOf(result[0].substring(6, 8));

        List<String> hms = result[1].split(':');
        Integer h = Integer.valueOf(hms[0]);
        Integer m = Integer.valueOf(hms[1]);
        Integer s = Integer.valueOf(hms[2]);

        return Datetime.newInstance(year, month, day, h, m, s);
    }

    //  String('2019-10-07T16:18:18.952+0800') to DateTime
    public static Datetime yyyy_mm_dd_T_hh_mm_ssToDateTime(String d) {
        if (d.length() != 28 && d.length() != 24) return null;
        List<String> result = d.split('T')[0].split('-');
        Integer year = Integer.valueOf(result[0].substring(0, 4));
        Integer month = Integer.valueOf(result[1].substring(0, 2));
        Integer day = Integer.valueOf(result[2].substring(0, 2));

        List<String> hms = d.split('T')[1].substring(0, 8).split(':');
        Integer h = Integer.valueOf(hms[0]);
        Integer m = Integer.valueOf(hms[1]);
        Integer s = Integer.valueOf(hms[2]);

        return Datetime.newInstance(year, month, day, h, m, s);
    }

    /**
     * Date String Type Change #1
     * @param d     String
     * @return      String(2017-07-19 13:37:10) to String(YYYYMMDD_HH24MISS)
     * @Author
     * e.g) Util.ymd_hms('2017-07-19 13:37:10'); --> '20170719_133710'
     */
    public static String ymd_hms(String d) {
        List<String> result = d.split(' ')[0].split('-');
        //List<String> result = d.split(' ');

        String year = String.valueOf(result[0]);
        String month = String.valueOf(result[1]);
        String day = String.valueOf(result[2]);

        List<String> hms = d.split(' ')[1].split(':');
        String h = String.valueOf(hms[0]);
        String m = String.valueOf(hms[1]);
        String s = String.valueOf(hms[2]);

        String convert = year + month + day + '_' + h + m + s;

        return convert;
    }

    //Locale Date Format
    private static Map<String, String> localeMap = new Map<String, String>{
            'ar' => 'dd/MM/yyyy hh:mm a',
            'ar_AE' => 'dd/MM/yyyy hh:mm a',
            'ar_BH' => 'dd/MM/yyyy hh:mm a',
            'ar_JO' => 'dd/MM/yyyy hh:mm a',
            'ar_KW' => 'dd/MM/yyyy hh:mm a',
            'ar_LB' => 'dd/MM/yyyy hh:mm a',
            'ar_SA' => 'dd/MM/yyyy hh:mm a',
            'bg_BG' => 'yyyy-M-d H:mm',
            'ca' => 'dd/MM/yyyy HH:mm',
            'ca_ES' => 'dd/MM/yyyy HH:mm',
            'ca_ES_EURO' => 'dd/MM/yyyy HH:mm',
            'cs' => 'd.M.yyyy H:mm',
            'cs_CZ' => 'd.M.yyyy H:mm',
            'da' => 'dd-MM-yyyy HH:mm',
            'da_DK' => 'dd-MM-yyyy HH:mm',
            'de' => 'dd.MM.yyyy HH:mm',
            'de_AT' => 'dd.MM.yyyy HH:mm',
            'de_AT_EURO' => 'dd.MM.yyyy HH:mm',
            'de_CH' => 'dd.MM.yyyy HH:mm',
            'de_DE' => 'dd.MM.yyyy HH:mm',
            'de_DE_EURO' => 'dd.MM.yyyy HH:mm',
            'de_LU' => 'dd.MM.yyyy HH:mm',
            'de_LU_EURO' => 'dd.MM.yyyy HH:mm',
            'el_GR' => 'd/M/yyyy h:mm a',
            'en_AU' => 'd/MM/yyyy HH:mm',
            'en_B' => 'M/d/yyyy h:mm a',
            'en_BM' => 'M/d/yyyy h:mm a',
            'en_CA' => 'dd/MM/yyyy h:mm a',
            'en_GB' => 'dd/MM/yyyy HH:mm',
            'en_GH' => 'M/d/yyyy h:mm a',
            'en_ID' => 'M/d/yyyy h:mm a',
            'en_IE' => 'dd/MM/yyyy HH:mm',
            'en_IE_EURO' => 'dd/MM/yyyy HH:mm',
            'en_NZ' => 'd/MM/yyyy HH:mm',
            'en_SG' => 'M/d/yyyy h:mm a',
            'en_US' => 'M/d/yyyy h:mm a',
            'en_ZA' => 'yyyy/MM/dd hh:mm a',
            'es' => 'd/MM/yyyy H:mm',
            'es_AR' => 'dd/MM/yyyy HH:mm',
            'es_BO' => 'dd-MM-yyyy hh:mm a',
            'es_CL' => 'dd-MM-yyyy hh:mm a',
            'es_CO' => 'd/MM/yyyy hh:mm a',
            'es_CR' => 'dd/MM/yyyy hh:mm a',
            'es_EC' => 'dd/MM/yyyy hh:mm a',
            'es_ES' => 'd/MM/yyyy H:mm',
            'es_ES_EURO' => 'd/MM/yyyy H:mm',
            'es_GT' => 'd/MM/yyyy hh:mm a',
            'es_HN' => 'MM-dd-yyyy hh:mm a',
            'es_MX' => 'd/MM/yyyy hh:mm a',
            'es_PE' => 'dd/MM/yyyy hh:mm a',
            'es_PR' => 'MM-dd-yyyy hh:mm a',
            'es_PY' => 'dd/MM/yyyy hh:mm a',
            'es_SV' => 'MM-dd-yyyy hh:mm a',
            'es_UY' => 'dd/MM/yyyy hh:mm a',
            'es_VE' => 'dd/MM/yyyy hh:mm a',
            'et_EE' => 'd.MM.yyyy H:mm',
            'fi' => 'd.M.yyyy H:mm',
            'fi_FI' => 'd.M.yyyy H:mm',
            'fi_FI_EURO' => 'd.M.yyyy H:mm',
            'fr' => 'dd/MM/yyyy HH:mm',
            'fr_BE' => 'd/MM/yyyy H:mm',
            'fr_CA' => 'yyyy-MM-dd HH:mm',
            'fr_CH' => 'dd.MM.yyyy HH:mm',
            'fr_FR' => 'dd/MM/yyyy HH:mm',
            'fr_FR_EURO' => 'dd/MM/yyyy HH:mm',
            'fr_LU' => 'dd/MM/yyyy HH:mm',
            'fr_MC' => 'dd/MM/yyyy HH:mm',
            'hr_HR' => 'yyyy.MM.dd HH:mm',
            'hu' => 'yyyy.MM.dd. H:mm',
            'hy_AM' => 'M/d/yyyy h:mm a',
            'is_IS' => 'd.M.yyyy HH:mm',
            'it' => 'dd/MM/yyyy H.mm',
            'it_CH' => 'dd.MM.yyyy HH:mm',
            'it_IT' => 'dd/MM/yyyy H.mm',
            'iw' => 'HH:mm dd/MM/yyyy',
            'iw_IL' => 'HH:mm dd/MM/yyyy',
            'ja' => 'yyyy/MM/dd H:mm',
            'ja_JP' => 'yyyy/MM/dd H:mm',
            'kk_KZ' => 'M/d/yyyy h:mm a',
            'km_KH' => 'M/d/yyyy h:mm a',
            'ko' => 'yyyy. M. d a h:mm',
            'ko_KR' => 'yyyy. M. d a h:mm',
            'lt_LT' => 'yyyy.M.d HH.mm',
            'lv_LV' => 'yyyy.d.M HH:mm',
            'ms_MY' => 'dd/MM/yyyy h:mm a',
            'nl' => 'd-M-yyyy H:mm',
            'nl_BE' => 'd/MM/yyyy H:mm',
            'nl_NL' => 'd-M-yyyy H:mm',
            'nl_SR' => 'd-M-yyyy H:mm',
            'no' => 'dd.MM.yyyy HH:mm',
            'no_NO' => 'dd.MM.yyyy HH:mm',
            'pl' => 'yyyy-MM-dd HH:mm',
            'pt' => 'dd-MM-yyyy H:mm',
            'pt_AO' => 'dd-MM-yyyy H:mm',
            'pt_BR' => 'dd/MM/yyyy HH:mm',
            'pt_PT' => 'dd-MM-yyyy H:mm',
            'ro_RO' => 'dd.MM.yyyy HH:mm',
            'ru' => 'dd.MM.yyyy H:mm',
            'sk_SK' => 'd.M.yyyy H:mm',
            'sl_SI' => 'd.M.y H:mm',
            'sv' => 'yyyy-MM-dd HH:mm',
            'sv_SE' => 'yyyy-MM-dd HH:mm',
            'th' => 'M/d/yyyy h:mm a',
            'th_TH' => 'd/M/yyyy => H:mm ?.',
            'tr' => 'dd.MM.yyyy HH:mm',
            'ur_PK' => 'M/d/yyyy h:mm a',
            'vi_VN' => 'HH:mm dd/MM/yyyy',
            'zh' => 'yyyy-M-d ah:mm',
            'zh_CN' => 'yyyy-M-d ah:mm',
            'zh_HK' => 'yyyy-M-d ah:mm',
            'zh_TW' => 'yyyy/M/d a h:mm'
    };

    global static String getDateFormat(String localeKey) {
        String f = localeMap.get(localeKey);
        return f == null ? localeMap.get('ko_KR') : f;
    }

    /**
     * Null Check
     * @param o     Object
     * @return      o가 null 이면 true, null이 아니면 false 를 return.
     * @Author      snowChoi
     * e.g.) Util.isNull(null) --> true
     **/
    global static Boolean isNull(Object o) {
        return o == null ? true : false;
    }

    /**
     * Empty Check
     * @param o     Object
     * @return      o가 null 혹은 '' 이면 true, 아니면 false 를 return.
     * @Author      김성일
     * e.g.) Util.isEmpty(' ') --> true
     **/
    global static Boolean isEmpty(Object o) {
        if (o == null) return true;

        if (o instanceOf String) {
            if (''.equals(o)) return true;
            if (''.equals(String.valueOf(o).trim())) return true; // SPACE도 empty로 본다.
        } // type 별 null 기준 정의 필요. Number일 경우 등.

        return false;
    }

    /**
     * SAP의 숫자형 문자 비교.
     * @param s     String
     * @return      o가 null, '', '00000' 이면 true, 아니면 false 를 return.
     * @Author      김성일
     * e.g.) Util.isSAPEmpty('000000') --> true
     **/
    global static Boolean isSAPEmpty(String s) {
        if (s == null) return true;

        if (''.equals(s)) return true;
        if (''.equals(String.valueOf(s).trim())) return true; // SPACE도 empty로 본다.

        String b = s.replaceAll('[0]', ''); // 0으로 채워져 있는 지 판단한다.
        return (b.length() == 0);
    }

    /**
     * Not Empty Check
     * @param o     Object
     * @return      o가 null 혹은 '' 이면 true, 아니면 false 를 return.
     * @Author      김성일
     * e.g.) Util.isNotEmpty('a') --> true
     **/
    global static Boolean isNotEmpty(Object o) {
        return !isEmpty(o);
    }

    /**
     * Integer NVL
     * @param o     Integer
     * @return      o가 null 이면 0을 return. null이 아니면 o 를 return.
     * @Author      snowChoi
     * e.g.) Util.nvlInt(null) --> 0
     **/
    global static Integer nvlInt(Integer o) {
        return nvlInt(o, 0);
    }
    global static Integer nvlInt(Integer o, Integer r) {
        return o == null ? r : o;
    }

    global static Decimal nvlDec(Decimal o) {
        return nvlDec(o, 0);
    }
    global static Decimal nvlDec(Decimal o, Decimal r) {
        return o == null ? r : o;
    }

    global static String nvlStr(String o) {
        return nvlStr(o, '');
    }
    global static String nvlStr(String o, String r) {
        String tmp = '';
        if (o == null || ''.equals(o) || o == 'null') {
            tmp = r;
        } else {
            tmp = o;
        }
        return tmp;
    }

    global static String nvlObj(Object o, String r) {
        return nvlStr(o + '', r);
    }

    /**
     * 숫자여부
     * @param str   문자열
     * @return      str 이 숫자형 문자이면 true, 그렇지 않으면 false
     * @Author      snowChoi
     * e.g.) Util.isNumber('123') --> true
     **/
    global static Boolean isNumber(String str) {
        return Pattern.Matches('[0-9]+', str);
    }

    /**
     * Padding Left
     * @param s     원본 문자열
     * @param p     추가할 문자
     * @param l     길이
     * @return      l만큼 s의 왼쪽에 p를 추가한 문자열
     * @Author      snowChoi
     * e.g.) lpad('123', '0', 5) --> '00123'
     **/
    global static String lpad(String s, String p, Integer l) {
        if (s == null) return null;

        while (s.length() < l) {
            s = p + s;
        }
        return s;
    }
    global static String lpad(Integer i, String p, Integer l) {
        return lpad(i + '', p, l);
    }

    /**
     * Padding Right
     * @param s     원본 문자열
     * @param p     추가할 문자
     * @param l     길이
     * @return      l만큼 s의 오른쪽에 p를 추가한 문자열
     * @Author      snowChoi
     * e.g.) rpad('123', '0', 5) --> '12300'
     **/
    global static String rpad(String s, String p, Integer l) {
        while (s.length() < l) {
            s += p;
        }
        return s;
    }

    /**
     * substring
     * @param s     원본 문자열
     * @param startIndex        substring 시작 위치.
     * @param endIndex      substring 종료 위치.
     * @return       substring 된 문자열.
     * @Author      김성일
     * e.g.) Utiil.substring('123', 1, 2) --> '12300'
     * 정확히 짜르지 않으면 "Ending position out of bounds" 에러가 발생하여 정확히 짜르기 위함.
     **/
    global static String substring(String s, Integer startIndex, Integer endIndex) {
        if (isEmpty(s)) return null;

        if (startIndex > s.length()) return '';

        if (endIndex > s.length()) {
            endIndex = s.length();
        }
        return s.substring(startIndex, endIndex);
    }

    /**
     * Date to String
     * @return      오늘 날짜의 문자열을 return.
     * @Author      snowChoi
     * e.g.) Util.strDate() --> '20150421'
     **/
    global static String strDate() {
        return dateFormat(Date.today(), '');
    }
    global static String strDate(String delimiter) {
        return dateFormat(Date.today(), delimiter);
    }
    global static String strYYMM() {
        return String.valueOf(Date.today().year()) + lpad(String.valueOf(Date.today().month()), '0', 2);
    }

    global static String strYYMM(Date d) {
        return String.valueOf(d.year()) + lpad(String.valueOf(d.month()), '0', 2);
    }
    global static String strYYYYMMDD(Date d) {
        if (isEmpty(d)) return null;

        String sMonth = String.valueof(d.month());
        String sDay = String.valueof(d.day());
        if (sMonth.length() == 1) {
            sMonth = '0' + sMonth;
        }
        if (sDay.length() == 1) {
            sDay = '0' + sDay;
        }
        return String.valueof(d.year()) + sMonth + sDay ;
    }


    /**
     * Date format
     * @param i     '-'가 뒤에 붙은 문자열
     * @return      '-' 기호를 앞에 붙힌 숫자
     * @Author      김성일
     * e.g.) Util.revertMinus('1000-') --> -1000
     **/
    global static Decimal revertMinus(String i) {
        String a = i.trim();
        if (a.endsWith('-')) { // GERP는 '-' 가 뒤에 붙어서 옴.
            a = a.replace('-', '');
            a = '-' + a;
        }
        return Decimal.valueOf(a);
    }
    /**
     * Date format
     * @param d     Date형 문자열
     * @return      yyyymmdd 를 yyyy-mm-dd 로 변경.
     * @Author      snowChoi
     * e.g.) Util.formatDate('20160816') --> '2016-08-16'
     **/
    global static String formatDate(String d) {
        return formatDate(d, '-');
    }
    /**
     * Date format
     * @param d         Date형 문자열
     * @param delimiter 구분자
     * @return          delimiter 를 구분자로 포맷을 변경함.
     * @Author          snowChoi
     * e.g.) 20160708 -> 2016/07/08, 2016-07-08, 2016.07.08
     **/
    global static String formatDate(String d, String delimiter) {
        if (d == null || d.length() != 8) return d; // 8 자리일 경우에만 해당

        String yyyy = d.substring(0, 4);
        String mm = d.substring(4, 6);
        String dd = d.substring(6, 8);
        return yyyy + delimiter + mm + delimiter + dd;
    }

    /**
     * Next Month
     * @param dt_work   년월 형식의 문자열
     * @return          dt_work 의 다음 달에 해당하는 문자열을 return.
     * @Author          snowChoi
     * e.g.) Util.strNextYYMM('201601') --> '201602'
     **/
    global static String strNextYYMM(String dt_work) {

        Integer y = Integer.valueOf(dt_work.left(4));
        Integer m = Integer.valueOf(dt_work.right(2));

        Date dt = Date.newInstance(y, m, 1);
        Date ndt1 = dt.addMonths(1);

        return strYYMM(ndt1);
    }

    /**
     * Previous Month
     * @param dt_work   년월 형식의 문자열
     * @return          dt_work 의 이전 달에 해당하는 문자열을 return.
     * @Author          snowChoi
     * e.g.) Util.strPreYYMM('201601') --> '201512'
     **/
    global static String strPreYYMM(String dt_work) {

        Integer y = Integer.valueOf(dt_work.left(4));
        Integer m = Integer.valueOf(dt_work.right(2));

        Date dt = Date.newInstance(y, m, 1);
        Date pdt1 = dt.addMonths(-1);

        return strYYMM(pdt1);
    }

    /**
     * Date Format
     * @param d         Date
     * @param delimiter 구분자
     * @return          d 날짜의 문자열을 구분자를 포함하는 형태의 문자열로 return
     * @Author          snowChoi
     * e.g.) Util.dateFormat(Date.today()) --> '2015-04-21'
     **/
    global static String dateFormat(Date d) {
        return dateFormat(d, '-');
    }

    /**
     * Date Format
     * @param d         Date
     * @param delimiter 구분자
     * @return          d 날짜의 문자열을 구분자를 포함하는 형태의 문자열로 return
     * @Author          snowChoi
     * e.g.) Util.dateFormat(Date.today(), '-') --> '2015-04-21'
     **/
    global static String dateFormat(Date d, String delimiter) {
        if (d == null) return null;
        return String.valueOf(d.year()) + delimiter + lpad(String.valueOf(d.month()), '0', 2) + delimiter + lpad(String.valueOf(d.day()), '0', 2);
    }

    /**
     * 일별 일련번호 생성
     * @param objName   sObject API Name
     * @return          sObject 의 오늘의 Max 값 + 1 리턴
     * @Author          snowChoi
     * e.g.) Util.getMax('Account') --> 4
     **/
    global static Decimal getMax(String objName) {
        List<AggregateResult> arList = database.query('SELECT MAX(Name) nm FROM ' + objName + ' WHERE CreatedDate = TODAY');

        if (arList.size() == 0 || isNull(arList[0].get('nm'))) {
            return 1;
        } else {
            String name = (String) arList[0].get('nm');
            return name.right(3).isNumeric() ? Decimal.valueOf(name.right(3)) + 1 : 1;
        }
    }

    /**
     * 월별 일련번호 생성
     * @param objName   sObject API Name
     * @return          sObject 의 월별 Max 값 + 1 리턴
     * @Author          snowChoi
     * e.g.) Util.getMax('Account') --> 4
     **/
    global static Decimal getMaxMonth(String objName) {
        List<AggregateResult> arList = database.query('SELECT MAX(Name) nm FROM ' + objName + ' WHERE CreatedDate = THIS_MONTH');

        if (arList.size() == 0 || isNull(arList[0].get('nm'))) {
            return 1;
        } else {
            String name = (String) arList[0].get('nm');
            return name.right(3).isNumeric() ? Decimal.valueOf(name.right(3)) + 1 : 1;
        }
    }

    /**
     * 일련번호 생성
     * @param idx       Index Number
     * @param prefix    일련 번호의 Prefix 문자열
     * @return          prefix + 오늘날짜 + 순번.
     * @Author          snowChoi
     * e.g.) Util.getName(4, 'SO') --> SO-20150428-004
     **/
    global static String getName(Decimal idx, String prefix) {
        return prefix + '-' + strDate() + '-' + lpad(idx + '', '0', 3);
    }

    /**
     * 일련번호 생성
     * @param objName   sObject API Name
     * @param prefix    일련 번호의 Prefix 문자열
     * @return          prefix + 오늘날짜 + 순번(sObject의 오늘의 Max).
     * @Author          snowChoi
     * e.g.) Util.getName('Account', 'SO') --> SO-20150428-004
     **/
    global static String getName(String objName, String prefix) {
        List<AggregateResult> arList = database.query('SELECT MAX(Name) nm FROM ' + objName + ' WHERE CreatedDate = TODAY');

        if (arList.size() == 0 || isNull(arList[0].get('nm'))) {
            return prefix + '-' + strDate() + '-001';
        } else {
            String name = (String) arList[0].get('nm');
            Integer idx = name.right(3).isNumeric() ? Integer.valueOf(name.right(3)) : 0;
            return prefix + '-' + strDate() + '-' + lpad(idx + 1 + '', '0', 3);
        }
    }

    /**
     * 일련번호 생성
     * @param objName   sObject API Name
     * @param prefix    일련 번호의 Prefix 문자열
     * @return          prefix + 이번달 + 순번(sObject의 당월의 Max).
     * @Author          snowChoi
     * e.g.) Util.getNameOfMonth('Account', 'SO') --> SO-201504-004
     **/
    global static String getNameOfMonth(String objName, String prefix) {
        List<AggregateResult> arList = database.query('SELECT MAX(ID) nm FROM ' + objName + ' WHERE CreatedDate = THIS_MONTH');
        if (arList.size() == 0 || isNull(arList[0].get('nm'))) {
            return prefix + '-' + strYYMM() + '-001';
        } else {
            String name = (String) arList[0].get('nm');
            Integer idx = name.right(3).isNumeric() ? Integer.valueOf(name.right(3)) : 0;
            return prefix + '-' + strYYMM() + '-' + lpad(idx + 1 + '', '0', 3);
        }
    }

    /**
     * 일련번호 생성
     * @param idx       순번
     * @param prefix    일련 번호의 Prefix 문자열
     * @return          prefix + 이번달 + 순번(idx).
     * @Author          snowChoi
     * e.g.) Util.getNameOfMonth('Account', 'SO') --> SO-201504-004
     **/
    global static String getNameOfMonth(Decimal idx, String prefix) {
        return prefix + '-' + strYYMM() + '-' + lpad(idx + '', '0', 3);
    }

    /**
     * 일련번호 생성
     * @param obj       sObject
     * @param fld       picklist Field Name
     * @param hasNone   picklist의 첫번째값에 '전체' 추가 여부.
     * @return          sObject 의 Field의 Picklist 값을 반환한다.
     * @Author          snowChoi
     * e.g.) Util.getPicklistValues('Account', 'Type', true)
     **/
    //i2max이관
    /*
   global static List<SelectOption> getPicklistValues(String obj, String fld, Boolean hasNone) {

       List<SelectOption> options = new List<SelectOption>();
       Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
       Schema.SObjectType sobjType = gd.get(obj);
       Schema.DescribeSObjectResult objDescribe = sobjType.getDescribe();
       Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
       List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();

       if(hasNone) {
           options.add(new SelectOption('','--'+Label.CB_All+'--'));
       }
       for (Schema.PicklistEntry a : values) {
           options.add(new SelectOption(a.getValue(), a.getLabel()));
       }


       return options;
   }
   */
    /**
     * 문자열을 Date 로 변환
     * @param str       Date 형식의 문자열
     * @return          String Type 일자를 Date 으로 변환하여 리턴.
     * @Author          snowChoi
     * e.g.) Util.str2Dt('20150825') -->
     * e.g.) Util.str2Dt('2015-08-25') -->
     **/
    global static Date str2Date(String str) {
        Date d;
        if (str != null) {
            try {
                d = Date.parse(str);
            } catch (System.TypeException te) {
                if (str.length() == 8) {
                    d = Date.newInstance(Integer.valueOf(str.left(4)), Integer.valueOf(str.substring(4, 6)), Integer.valueOf(str.right(2)));
                } else if (str.length() == 10) {
                    d = Date.newInstance(Integer.valueOf(str.left(4)), Integer.valueOf(str.substring(5, 7)), Integer.valueOf(str.right(2)));
                }
            }
        }
        return d;
    }

    /**
     * 문자열을 Date 로 변환
     * @param str       Date 형식의 문자열
     * @return          String Type 일자를 Date 으로 변환하여 리턴.
     * @Author
     * e.g.) Util.str2Dt('17/07/31') -->
     **/
    global static Date str2Date_v2(String str) {
        Date d;
        if (str != null) {
            try {
                d = Date.parse(str);
            } catch (System.TypeException te) {
                if (str.length() == 8) {
                    List<String> paramList = str.split('/');
                    if (paramList.size() == 3) d = Date.newInstance(Integer.valueOf(paramList[0]) + 2000, Integer.valueOf(paramList[1]), Integer.valueOf(paramList[2]));

                }
            }
        }
        return d;
    }

    /**
     * 문자열을 DateTime 으로 변환
     * @param str       DateTime 형식의 문자열
     * @return          String Type 일자를 DateTime 으로 변환한다.
     * @Author          snowChoi
     * e.g.) Util.str2Dt('201508251137') -->
     * e.g.) Util.str2Dt('20150825113723') -->
     **/
    global static DateTime str2Dt(String str) {
        DateTime dt;
        if (str != null) {
            if (str.length() == 12) {
                dt = DateTime.newInstance(Integer.valueOf(str.left(4)), Integer.valueOf(str.substring(4, 6)), Integer.valueOf(str.substring(6, 8))
                        , Integer.valueOf(str.substring(8, 10)), Integer.valueOf(str.right(2)), 0);
            } else if (str.length() == 14) {
                dt = DateTime.newInstance(Integer.valueOf(str.left(4)), Integer.valueOf(str.substring(4, 6)), Integer.valueOf(str.substring(6, 8))
                        , Integer.valueOf(str.substring(8, 10)), Integer.valueOf(str.substring(10, 12)), Integer.valueOf(str.right(2)));
            }
        }
        return dt;
    }

    /**
     * Byte Size
     * @param s     문자열
     * @return      문자열의 Byte 수
     * @Author      snowChoi
     * e.g.) Util.byteSize('123가나다abc') --> 12
     **/
    global static Integer byteSize(String s) {
        Integer b = 0;
        for (Integer i = 0; i < s.length(); i++) {
            b += s.charAt(i) < 128 ? 1 : 2;
        }
        return b;
    }

    /**
     * 반올림
     * @param d     숫자
     * @return      소수점 2째자리 반올림
     * @Author      snowChoi
     * e.g.) Util.round(3.141592) --> 3.14
     **/
    global static Decimal round(Decimal d) {
        return round(d, 2);
    }
    global static Decimal round(Decimal d, Integer dp) {
        return Math.round(d * Math.pow(10, dp)) / Math.pow(10, dp);
    }

    /**
     * 절상
     * @param d     숫자
     * @return      소수점 2째자리 올림
     * @Author      snowChoi
     * e.g.) Util.ceil(3.141592) --> 3.15
     **/
    global static Decimal ceil(Decimal d) {
        return ceil(d, 2);
    }
    /**
     * 절상
     * @param d     숫자
     * @return      소수점 2째자리 올림
     * @Author      snowChoi
     * e.g.) Util.ceil(3.141592, 2) --> 3.15
     **/
    global static Decimal ceil(Decimal d, Integer dp) {
        return Math.ceil(d * Math.pow(10, dp)) / Math.pow(10, dp);
    }

    /**
     * 절삭
     * @param d     숫자
     * @return      소수점 2째자리 내림
     * @Author      snowChoi
     * e.g.) Util.floor(3.141592) --> 3.14
     **/
    global static Decimal floor(Decimal d) {
        return floor(d, 2);
    }
    /**
     * 절삭
     * @param d     숫자
     * @return      소수점 2째자리 내림
     * @Author      snowChoi
     * e.g.) Util.floor(3.141592, 2) --> 3.14
     **/
    global static Decimal floor(Decimal d, Integer dp) {
        return Math.floor(d * Math.pow(10, dp)) / Math.pow(10, dp);
    }

    /**
     * debug
     * LoggingLevel.DEBUG
     * e.g.) Util.debug('msg') -->
     **/
    global static void debug(String message) {
        system.debug(LoggingLevel.DEBUG, message);
    }

    /**
     * debug
     * Logginglevel.DEBUG, page에 debug message View. VisualForce 용
     * e.g.) Util.debug('msg', true) -->
     **/
    global static void debug(String message, Boolean isPageView) {

        debug(message);

        if (isPageView) {
            ApexPages.Message msg =
                    new ApexPages.Message(
                            ApexPages.severity.INFO, message
                    );
            ApexPages.addMessage(msg);
        }
    }

    /**
     * getUserInfo
     * User 의 정보를 반환한다.
     * e.g.) Util.getUserInfo() -->
     **/
    global static User getUserInfo() {
        User userSession;
        userSession = [
                SELECT Id
                        , Name
                        , ProfileId
                        , Profile.Name
                        , EmployeeNumber
                        , ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        return userSession;
    }

    /**
    * isDPSUser
    * DPS user 여부를 판단.
    * e.g.) Util.isDPSUser() -->
    **/
    global static Boolean isDPSUser() {
        User userSession = getUserInfo();
        return !(isEmpty(userSession.ContactId));
    }

    /**
    * getListValue
   * 검색결과가 담긴 String List를 반환한다.
   * @param groupType  공통코드 Group Type
   * @return           l 값중 field name을 가진 문자열 목록
   * @Author           김성일
   * e.g.) Util.getListValue(l, s) -->
    **/
    global static List<String> getListValue(List<SObject> l, String field) {
        List<String> l2 = new List<String>();
        for (SObject o : l) {
            l2.add((String) o.get(field));
        }
        return l2;
    }

    /**
     * getParentHeader
    * 부모창 제어를 위해 부모창의 도메인 반환
    * @param groupType  String baseUrl = ApexPages.currentPage().getHeaders().get('referer');
    * @return           페이지 주소를 제외한 주소값을 리턴
    * @Author           이신영
    * e.g.) Util.getParentHeader('https://sec-dsp--dev.cs6.my.salesforce.com/006N0000008V8aN') --> 'https://sec-dsp--dev.cs6.my.salesforce.com'
     **/
    global static String getParentHeader() {
        String baseUrl = ApexPages.currentPage().getHeaders().get('referer');
        baseUrl = baseUrl == null ? 'none/' : baseUrl;
        return baseUrl.substring(0, baseUrl.lastIndexOf('/'));
    }
    /**
     * isValidDate
    * 부모창 제어를 위해 부모창의 도메인 반환
    * @param String s
    * @return
    * @Author           김성일
    * e.g.) Util.getParentHeader('https://sec-dsp--dev.cs6.my.salesforce.com/006N0000008V8aN') --> 'https://sec-dsp--dev.cs6.my.salesforce.com'
     **/
    global static Boolean isValidDate(String s) {
        String a = s.substring(0, 4) + '-' + s.substring(4, 6) + '-' + s.substring(6, 8);
        try {
            Date d = Date.valueOf(a);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * isValidDate
    * 부모창 제어를 위해 부모창의 도메인 반환
    * @param String s
    * @return
    * @Author           김성일
    * e.g.) Util.getParentHeader('https://sec-dsp--dev.cs6.my.salesforce.com/006N0000008V8aN') --> 'https://sec-dsp--dev.cs6.my.salesforce.com'
     **/
    global static Map<String, String> splitAddr(String s) {
        //String s = '부산광역시 금정구 장전동 산 30번지 부산대학교 의과대학 대학원 예방의학전공 123동 123호';
        if (isEmpty(s)) {
            Map<String, String> resultMap = new Map<String, String>();
            resultMap.put('firstAddr', '');
            resultMap.put('lastAddr', '');

            return resultMap;
        }
        String[] a = s.split(' ');
        String firstAddr = a[0] + ' ';
        String lastAddr = Util.substring(s, s.indexOf(firstAddr) + firstAddr.length(), s.length());

        Integer breakPoint = 1;
        //while(lastAddr.length() > 40) {
        while (Util.byteSize(lastAddr) > 40) {// 한글을 2byte로 인식함.
            firstAddr += a[breakPoint] + ' ';
            Integer index = s.indexOf(firstAddr);
            lastAddr = Util.substring(s, index + firstAddr.length(), s.length());

            breakPoint++;
            if (breakPoint >= 10) break; // 무한 루프 방지
        }

        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('firstAddr', firstAddr.trim());
        resultMap.put('lastAddr', lastAddr.trim());

        return resultMap;
    }

    /**
     *  시간딜레이 발생
     *  delay 1000 == 1초
    */
    global static void makeDelay(Integer delay){
        Long start = DateTime.now().getTime();
        while(DateTime.now().getTime() - start < delay);
    }

    /**
     * executeDynamicBatch
     * 배치를 동적으로 실행해야하는 경우 사용
     *
     * @param batchName 실행될 배치 클래스명
     * @param batchSize 실행될 배치 사이즈
     * @param paramMap  실행될 배치에 global 변수로 선언되어있어, 파라미터 형식으로 셋팅할 값들
     * @Author Junseok.Kwon
     */
    global static void executeDynamicBatch(String batchName, Integer batchSize, Map<String, Object> paramMap){

        Type classType = Type.forName(batchName);

        String paramStr = JSON.serialize(paramMap);

        Object batch = JSON.deserialize(paramStr, classType);
        Database.executeBatch((Database.Batchable<sObject>)batch, batchSize);
    }
    // 파라미터가 없는 케이스
    global static void executeDynamicBatch(String batchName, Integer batchSize){

        executeDynamicBatch(batchName, batchSize, new Map<String, Object>());
    }
}