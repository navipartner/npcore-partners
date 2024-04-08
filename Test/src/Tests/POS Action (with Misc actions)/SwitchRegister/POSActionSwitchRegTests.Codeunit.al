codeunit 85152 "NPR POS Action:SwitchReg Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SwitchRegisterTest()
    var
        POSSale: Codeunit "NPR POS Sale";
        POSActSwitchRegB: Codeunit "NPR POS Action: Switch RegistB";
        RegisterNo: Code[10];
        POSUnit2: Record "NPR POS Unit";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSStore2: Record "NPR POS Store";
        Initialized2: Boolean;
        Setup: Codeunit "NPR POS Setup";
        UserSetup: Record "User Setup";
    begin
        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMock.InitializeData(Initialized2, POSUnit2, POSStore2);
        RegisterNo := POSUnit2."No.";

        UserSetup.Get(UserId);
        UserSetup."NPR Allow Register Switch" := true;
        UserSetup.Modify();

        POSSession.GetSetup(Setup);

        POSActSwitchRegB.SwitchRegister(RegisterNo, Setup);
        Clear(POSUnit);
        Setup.GetPOSUnit(POSUnit);

        Assert.IsTrue(POSUnit."No." = POSUnit2."No.", 'Register switched.');
    end;
}