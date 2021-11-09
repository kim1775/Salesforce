/****************************************************************************************
  * @filename      : I2ComUtil
  * @author        : I2MAX
  * @date          : 2020-12-29 오후 5:28
  * @group         : 
  * @group-content : 
  * @description   : Util에 관한 class
  * @tester        : I2ComUtil_ts.cls
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-12-29 오후 5:28      I2MAX               Create
****************************************************************************************/
public class I2ComUtil {

    /**
     * 선택목록 반환
     *
     * @param obj   : String
     * @param field : String
     *
     * @return  List<Schema.PicklistEntry>
     */
    public static List<Schema.PicklistEntry> getPickList(final String obj, final String field){
        return (((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType())
                .getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues();
    }

    /**
     * Sobject의 Field 를 이용한 Select Options 생성
     *
     * @param obj   : String
     * @param field : String
     *
     * @return  List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field){
        return makePickListOptions(obj, field, false);
    }

    /**
     * Sobject의 Field 를 이용한 Select Options 생성
     *
     * @param obj       : String
     * @param field     : String
     * @param notBlank  : Boolean
     *
     * @return  List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field, final Boolean notBlank){
        return makePickListOptions(obj, field, notBlank, false);
    }

    /**
     * Sobject의 Field 를 이용한 Select Options 생성
     *
     * @param obj           : String
     * @param field         : String
     * @param notBlank      : Boolean
     * @param isSelectAll   : Boolean
     *
     * @return  List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field, final Boolean notBlank, final Boolean isSelectAll){
        return   makePickListOptions(obj, field, notBlank, isSelectAll, null);
    }

    /**
     * Sobject의 Field 를 이용한 Select Options 생성
     *
     * @param obj           : String
     * @param field         : String
     * @param notBlank      : Boolean
     * @param isSelectAll   : Boolean
     * @param excludes      : Set<String>
     *
     * @return  List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field, final Boolean notBlank, final Boolean isSelectAll, final Set<String> excludes){
        List<I2ComClass.Option> tmpList = makeInitOptions( (isSelectAll ? '--All--' : null), notBlank);
        for(Schema.PicklistEntry pick : getPickList(obj, field)) {
            if(excludes == null) {
                tmpList.add(new I2ComClass.Option(pick.getLabel(), pick.getValue()));
            }
            else {
                if(excludes.contains(pick.getValue()) == false) {
                    tmpList.add(new I2ComClass.Option(pick.getLabel(), pick.getValue()));
                }
            }
        }
        return tmpList;
    }

    /**
     * Select Option의 기본값을 세팅하여 리턴
     *
     * @param selectAllComment : String
     *
     * @return  List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> makeInitOptions(final String selectAllComment){
        return makeInitOptions(selectAllComment, false);
    }

    /**
     * Select Option의 기본값을 세팅하여 리턴
     *
     * @param selectAllComment  : String
     * @param notBlank          : Boolean
     *
     * @return  List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> makeInitOptions(final String selectAllComment, final Boolean notBlank){
        List<I2ComClass.Option> tmpOptions = new List<I2ComClass.Option>();
        if(notBlank == false) {
            tmpOptions.add(new I2ComClass.Option(String.isNotBlank(selectAllComment) ? selectAllComment : '--None--', ''));
        }
        return tmpOptions;
    }

    /**
     * UUID 생성
     */
    private static String kHexChars = '0123456789abcdef';
    public static String NewGuid() {
        System.debug('Start : '+System.Now());
        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {
            if (i==4 || i==6 || i==8 || i==10) returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }
        System.debug('End : '+System.Now());
        return returnValue;
    }

    public static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;
        if (str.length() <= 0) return str;
        if (index == str.length()) return null;

        return str.substring(index, index+1);
    }

    public static String getUniqueId(){
        System.debug('Start : '+System.Now().getTime());
        String milliseconds = String.ValueOf(System.Now().getTime()); //unix timestamp
        Blob pseudoHash = Blob.ValueOf(milliseconds + String.ValueOf(Crypto.getRandomInteger()));
        String uniqueString = EncodingUtil.convertToHex(pseudoHash);
        uniqueString = uniqueString.length() > 255 ? uniqueString.substring(0,255) : uniqueString;
        System.debug('End : '+System.Now().getTime());

        return uniqueString;
    }


}