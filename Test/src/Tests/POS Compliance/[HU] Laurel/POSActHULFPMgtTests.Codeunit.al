codeunit 85228 "NPR POS Act HU L FP Mgt Tests"
{
    Subtype = Test;

    var
        _POSUnit: Record "NPR POS Unit";
        _Customer: Record Customer;
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        POSActionHULFPMgtB: Codeunit "NPR POS Action: HU L FP Mgt. B";
        _LibraryHULFiscal: Codeunit "NPR Library HU L Fiscal";
        _Initialized: Boolean;
        _POSActMethod: Option openFiscalDay,closeFiscalDay,cashierFCUReport,getDailyTotal,resetPrinter,setEuroRate,printReceiptCopy;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenDayCommandTest()
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
        FiscalDayNotOpenedOnPOSUnitErr: Label 'Fiscal Day has not been successfully opened on POS Unit %1.', Comment = '%1 = POS Unit No.';
    begin
        // [SCENARIO] Checks that open day command gets successful response from the fiscal printer when HU Laurel audit handler is enabled on POS unit.
        // [GIVEN] POS and HU Laurel audit setup
        InitializeData();

        // [WHEN] Open day command
        OpenFiscalDay();

        // [THEN] For successful response from open day command, HU L POS Unit mapping FCU status is set to open
        HULPOSUnitMapping.Get(_POSUnit."No.");
        _Assert.IsTrue(HULPOSUnitMapping."POS FCU Day Status" = HULPOSUnitMapping."POS FCU Day Status"::OPEN, StrSubStNo(FiscalDayNotOpenedOnPOSUnitErr, _POSUnit."No."));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CloseDayCommandTest()
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
        FiscalDayNotClosedOnPOSUnitErr: Label 'Fiscal Day has not been successfully closed on POS Unit %1.', Comment = '%1 = POS Unit No.';
    begin
        // [SCENARIO] Checks that close day command gets successful response from the fiscal printer when HU Laurel audit handler is enabled on POS unit.
        // [GIVEN] POS and HU Laurel audit setup
        InitializeData();

        // [WHEN] Close day command
        CloseFiscalDay();

        // [THEN] For successful response from close day command, HU L POS Unit mapping FCU status is set to closed
        HULPOSUnitMapping.Get(_POSUnit."No.");
        _Assert.IsTrue(HULPOSUnitMapping."POS FCU Day Status" = HULPOSUnitMapping."POS FCU Day Status"::CLOSED, StrSubStNo(FiscalDayNotClosedOnPOSUnitErr, _POSUnit."No."));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('DailyTotalsMessageHandler')]
    procedure GetDailyTotalCommandTest()
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
        DailyTotalsNotPopulatedErr: Label 'Daily totals have not been successfully populated on POS Unit %1.', Comment = '%1 = POS Unit No.';
    begin
        // [SCENARIO] Checks that get daily totals command gets successful response from the fiscal printer when HU Laurel audit handler is enabled on POS unit.
        // [GIVEN] POS and HU Laurel audit setup
        InitializeData();

        // [WHEN] Get daily totals command
        GetDailyTotals();

        // [THEN] For successful response from get daily totals command, HU L POS Unit mapping field is populated with daily totals information
        HULPOSUnitMapping.Get(_POSUnit."No.");
        _Assert.IsTrue(HULPOSUnitMapping."POS FCU Daily Totals".HasValue(), StrSubStNo(DailyTotalsNotPopulatedErr, _POSUnit."No."));
    end;

    local procedure InitializeData()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();

            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(_POSUnit, POSStore.Code, POSPostingProfile.Code);
            _LibraryHULFiscal.CreateHULPOSUnitMapping(_POSUnit."No.");

            _LibraryHULFiscal.CreateHULPOSAuditProfileAndSetToPOSUnit(_POSUnit);
            _LibraryHULFiscal.CreateHULFiscalizationSetup();

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure CreateFirstTimeCheckpoint(POSUnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSUnitNo);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);

        if (POSWorkshiftCheckpoint.IsEmpty()) then begin
            POSWorkshiftCheckpoint."Entry No." := 0;
            POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
            POSWorkshiftCheckpoint.Open := false;
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
            POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
            POSWorkshiftCheckpoint.Insert();
        end;
    end;

    local procedure OpenFiscalDay()
    var
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        CreateFirstTimeCheckpoint(_POSUnit."No.");
        POSActionHULFPMgtB.PrepareOpenFiscalDayRequest(POSSale);
        POSActionHULFPMgtB.ProcessLaurelMiniPOSResponse(_LibraryHULFiscal.GetOpenFiscalDayMockResponse(), POSSale."Register No.", _POSActMethod::openFiscalDay);
    end;

    local procedure CloseFiscalDay()
    var
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSActionHULFPMgtB.PrepareCloseFiscalDayRequest(POSSale);
        POSActionHULFPMgtB.ProcessLaurelMiniPOSResponse(_LibraryHULFiscal.GetCloseFiscalDayMockResponse(), POSSale."Register No.", _POSActMethod::closeFiscalDay);
    end;

    local procedure GetDailyTotals()
    var
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSActionHULFPMgtB.PrepareGetDailyTotalRequest();
        POSActionHULFPMgtB.ProcessLaurelMiniPOSResponse(_LibraryHULFiscal.GetDailyTotalsMockResponse(), POSSale."Register No.", _POSActMethod::getDailyTotal);
    end;

    [MessageHandler]
    procedure DailyTotalsMessageHandler(Msg: Text[1024])
    begin
        _Assert.ExpectedMessage('Total: "7400.00"\Void Count: "0"\Refund Count: "0"\Non Fisc. Count: "0"\Non Fisc. Cancelled Count: "0"\BBOX Printer ID: "Y11900016"\Closure No.: "94"\Receipt No.: "17"\Invoice No.: "0"\Total Void: "0.00"\Total Refund: "0.00"\Cancelled Void Count: "0"\Cancelled Refunds Count: "0"\In-Payment Voucher Count: "0"\In-Payment Voucher Cancelled Count: "0"\Out-Payment Voucher Count: "0"\Out-Payment Voucher Cancelled Count: "0"\Media Exchange Voucher Count: "0"\Media Exchange Voucher Cancelled Count: "0"\Cancelled Receipts Count: "15"\Cancelled Invoices Count: "0"\', Msg);
    end;
}