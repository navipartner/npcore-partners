codeunit 85120 "NPR POS Act. Open Drawer Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenDrawer()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSPaymentBin: Record "NPR POS Payment Bin";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        OpenDrawerBL: Codeunit "NPR POS Action: Open Drawer B";
        POSSale: Codeunit "NPR POS Sale";
        SetupOut: Codeunit "NPR POS Setup";
    begin
        // [Given] POS initialization
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile.Modify();
        POSPaymentBin.Get(POSUnit."Default POS Payment Bin");
        POSPaymentBin.Validate("Eject Method", 'OPOS');
        POSPaymentBin.Modify();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSetup(SetupOut);

        // [When]
        OpenDrawerBL.OnActionOpenCashDrawer(POSSale, SetupOut, '');

        //[Then]
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::MANUAL_DRAWER_OPEN);
        POSAuditLog.SetRange("User ID", UserId);
        POSAuditLog.SetRange("Acted on POS Unit No.", POSUnit."No.");
        if POSAuditLog.IsEmpty then
            Assert.AssertRecordNotFound();
    end;
}