codeunit 85151 "NPR POS Act. Start POS Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        Setup: Codeunit "NPR POS Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BeforeStartPOSEmptyBinTest()
    var
        POSActStartPOSB: Codeunit "NPR POS Action: Start POS B";
        EoDActionCode: Code[20];
        ConfirmBin: Boolean;
        BalancingIsNotAllowed: Boolean;
        BinContentsHTML: Text;
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
    begin
        Initialize();

        POSWorkshiftCheckpoint.CloseWorkshift(true, true, POSUnit."No.");

        POSActStartPOSB.BeforeStartPOS(Setup, EoDActionCode, ConfirmBin, BalancingIsNotAllowed, BinContentsHTML);

        Assert.IsTrue(BinContentsHTML = '<b>The payment bin should be empty.</b>', 'Payment bin should be empty');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BeforeStartPOSNeverBalancedTest()
    var
        POSActStartPOSB: Codeunit "NPR POS Action: Start POS B";
        EoDActionCode: Code[20];
        ConfirmBin: Boolean;
        BalancingIsNotAllowed: Boolean;
        BinContentsHTML: Text;
    begin
        Initialize();

        POSActStartPOSB.BeforeStartPOS(Setup, EoDActionCode, ConfirmBin, BalancingIsNotAllowed, BinContentsHTML);

        Assert.IsTrue(BinContentsHTML = '<b>The payment bin has never been balanced. Do you want to open POS without balancing the bin?</b>', 'Payment bin has never been balanced');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BeforeStartPOSMasterClosedTest()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActStartPOSB: Codeunit "NPR POS Action: Start POS B";
        EoDActionCode: Code[20];
        ConfirmBin: Boolean;
        BalancingIsNotAllowed: Boolean;
        BinContentsHTML: Text;
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        MasterPOSUnit: Record "NPR POS Unit";
    begin
        Initialize();

        NPRLibraryPOSMasterData.CreatePOSUnit(MasterPOSUnit, POSStore.Code, POSPostingProfile.Code);
        MasterPOSUnit.Validate(Status, MasterPOSUnit.Status::CLOSED);
        MasterPOSUnit.Modify();

        if POSEndOfDayProfile.Get('SP-TEST') then begin
            POSEndOfDayProfile."End of Day Type" := POSEndOfDayProfile."End of Day Type"::MASTER_SLAVE;
            POSEndOfDayProfile."Master POS Unit No." := MasterPOSUnit."No.";
            POSEndOfDayProfile.Modify();
        end;

        asserterror POSActStartPOSB.BeforeStartPOS(Setup, EoDActionCode, ConfirmBin, BalancingIsNotAllowed, BinContentsHTML);

        Assert.ExpectedError(StrSubstNo('This POS is managed by POS Unit %1 [%2] and it is therefore required that %1 is opened prior to opening this POS.', MasterPOSUnit."No.", MasterPOSUnit.Name));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BeforeStartPOSMasterOpenTest()
    var
        POSActStartPOSB: Codeunit "NPR POS Action: Start POS B";
        EoDActionCode: Code[20];
        ConfirmBin: Boolean;
        BalancingIsNotAllowed: Boolean;
        BinContentsHTML: Text;
        MasterPOSUnit: Record "NPR POS Unit";
    begin
        Initialize();

        NPRLibraryPOSMasterData.CreatePOSUnit(MasterPOSUnit, POSStore.Code, POSPostingProfile.Code);
        if POSEndOfDayProfile.Get('SP-TEST') then begin
            POSEndOfDayProfile."End of Day Type" := POSEndOfDayProfile."End of Day Type"::MASTER_SLAVE;
            POSEndOfDayProfile."Master POS Unit No." := MasterPOSUnit."No.";
            POSEndOfDayProfile.Modify();
        end;

        POSActStartPOSB.BeforeStartPOS(Setup, EoDActionCode, ConfirmBin, BalancingIsNotAllowed, BinContentsHTML);

        Assert.IsTrue(BinContentsHTML = '<b>The workshift was closed. Do you want to open a new workshift?</b>', 'The worhshift should be closed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]

    procedure StartPOSSaleViewTest()
    var
        POSActStartPOSB: Codeunit "NPR POS Action: Start POS B";
        POSViewProfile: Record "NPR POS View Profile";
        CurrentView: Codeunit "NPR POS View";
        POSSale: Codeunit "NPR POS Sale";
    begin
        Initialize();

        NPRLibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Initial Sales View" := POSViewProfile."Initial Sales View"::SALES_VIEW;
        POSViewProfile.Modify();

        POSUnit."POS View Profile" := POSViewProfile.Code;
        POSUnit.Modify();
        NPRLibraryPOSMock.InitializePOSSession(POSSession, POSUnit);

        POSActStartPOSB.StartPOS(Setup, true);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Sale, Format(CurrentView.Type()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StartPOSRestaurantViewTest()
    var
        POSActStartPOSB: Codeunit "NPR POS Action: Start POS B";
        POSViewProfile: Record "NPR POS View Profile";
        CurrentView: Codeunit "NPR POS View";
        POSSale: Codeunit "NPR POS Sale";
    begin
        Initialize();

        NPRLibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Initial Sales View" := POSViewProfile."Initial Sales View"::RESTAURANT_VIEW;
        POSViewProfile.Modify();

        POSUnit."POS View Profile" := POSViewProfile.Code;
        POSUnit.Modify();
        NPRLibraryPOSMock.InitializePOSSession(POSSession, POSUnit);

        POSActStartPOSB.StartPOS(Setup, true);
        POSSession.GetCurrentView(CurrentView);


        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Restaurant, Format(CurrentView.Type()));
    end;

    local procedure Initialize()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        if Initialized then begin
            POSSession.ClearAll();
            Clear(POSSession);
            WorkDate(Today);
        end;

        // delete report selection -> skip printing in startpos
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        if ReportSelectionRetail.FindSet() then
            ReportSelectionRetail.DeleteAll();

        NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);

        NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);

        if (not POSEndOfDayProfile.Get('SP-TEST')) then begin
            POSEndOfDayProfile.Code := 'SP-TEST';
            POSEndOfDayProfile.Insert();
        end;
        POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
        POSEndOfDayProfile.Modify();

        POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
        POSUnit.Modify();

        Setup.SetPOSUnit(POSUnit);

        Commit();
    end;
}