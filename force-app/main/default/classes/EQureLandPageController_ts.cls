/**
 * Created by I2MAX on 2021-07-24.
 */

@IsTest
private class EQureLandPageController_ts {
    @IsTest
    static void testBehavior() {
        EQureLandPageController lp = new EQureLandPageController();
        lp.doInit();
        EQureLandPageController.runTest();
    }
}