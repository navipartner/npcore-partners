codeunit 85164 "NPR POS Act CRO Aud Look Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenCROAuditLogPageWithAllFiscalisedParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening CRO Audit Log Info
        // [Given] POS and CRO audit setup
        BindSubscription(LibraryCROFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllCROAuditLog(ParameterShow::AllFiscalised);
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenCROAuditLogPageWithAllParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening CRO Audit Log Info
        // [Given] POS and CRO audit setup
        BindSubscription(LibraryCROFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllCROAuditLog(ParameterShow::All);
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenCROAuditLogPageWithAllNonFiscalisedParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening CRO Audit Log Info
        // [Given] POS and CRO audit setup
        BindSubscription(LibraryCROFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllCROAuditLog(ParameterShow::AllNonFiscalised);
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenCROAuditLogPageWithLastTransactionParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening CRO Audit Log Info
        // [Given] POS and CRO audit setup
        BindSubscription(LibraryCROFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllCROAuditLog(ParameterShow::LastTransaction);
        UnbindSubscription(LibraryCROFiscal);
    end;

    internal procedure InitializeData()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        ReturnReason: Record "Return Reason";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end else begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(GetTestPOSUnitNo(), _POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            _Item."Unit Price" := 10;
            _Item.Modify();

            LibraryCROFiscal.CreateAuditProfileAndCROSetup(POSAuditProfile, _POSUnit, _POSPaymentMethod, _Salesperson);

            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
            ReportSelectionRetail.DeleteAll();
            ObjectOutputSelection.DeleteAll();

            LibraryRPTemplate.CreateDummySalesReceipt(TemplateHeader);
            LibraryRPTemplate.ConfigureReportSelection(ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)", TemplateHeader);

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure ShowAllCROAuditLog(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        CROPOSAuditLogAuxInfoPage: Page "NPR CRO POS Aud. Log Aux. Info";
    begin
        case ParameterShow of
            ParameterShow::AllFiscalised:
                CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
            ParameterShow::AllNonFiscalised:
                CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", false);
            ParameterShow::LastTransaction:
                begin
                    ShowLastCROAuditLog();
                    exit;
                end;
        end;
        CROPOSAuditLogAuxInfoPage.SetTableView(CROPOSAuditLogAuxInfo);
        CROPOSAuditLogAuxInfoPage.RunModal();
    end;

    local procedure ShowLastCROAuditLog()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        CROPOSAuditLogAuxInfo2: Record "NPR CRO POS Aud. Log Aux. Info";
        CROPOSAuditLogAuxInfoPage: Page "NPR CRO POS Aud. Log Aux. Info";
    begin
        CROPOSAuditLogAuxInfo.SetLoadFields("Audit Entry Type", "Audit Entry No.");
        CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
        CROPOSAuditLogAuxInfo.FindLast();
        CROPOSAuditLogAuxInfo2.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type");
        CROPOSAuditLogAuxInfo2.SetRange("Audit Entry No.", CROPOSAuditLogAuxInfo."Audit Entry No.");
        CROPOSAuditLogAuxInfoPage.SetTableView(CROPOSAuditLogAuxInfo2);
        CROPOSAuditLogAuxInfoPage.RunModal();
    end;

    [ModalPageHandler]
    procedure OpenModalPageHandler(var CROPOSAuditLogAuxInfoPage: TestPage "NPR CRO POS Aud. Log Aux. Info")
    begin
        _Assert.IsTrue(true, 'Page opened.');
    end;

    local procedure GetTestPOSUnitNo(): Code[10]
    begin
        exit('077');
    end;
}