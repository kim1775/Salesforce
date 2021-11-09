/**
 * Created by I2MAX on 2021-07-20.
 */

@IsTest
private class CCR_PicklistTranslationController_ts {
    @IsTest
    static void testBehavior() {
        PageReference myPage = Page.CCR_PicklistTranslations;
        Test.setCurrentPage(myPage);
        ApexPages.currentPage().getParameters().put('object', 'asset');
        ApexPages.currentPage().getParameters().put('field', 'name');
        ApexPages.currentPage().getParameters().put('value', '123');
        CCR_PicklistTranslationController ptc = new CCR_PicklistTranslationController();
        CCR_PicklistTranslationController.getEnglishValue('Asset', 'Name', '123');
    }
}