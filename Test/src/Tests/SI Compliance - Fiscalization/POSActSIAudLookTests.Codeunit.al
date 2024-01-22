codeunit 85167 "NPR POS Act SI Aud Look Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenSIAuditLogPageWithAllFiscalisedParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening SI Audit Log Info
        // [Given] POS and SI audit setup
        BindSubscription(LibrarySIFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllSIAuditLog(ParameterShow::AllFiscalised);
        UnbindSubscription(LibrarySIFiscal);
    end;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenSIAuditLogPageWithAllParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening SI Audit Log Info
        // [Given] POS and SI audit setup
        BindSubscription(LibrarySIFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllSIAuditLog(ParameterShow::All);
        UnbindSubscription(LibrarySIFiscal);
    end;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenSIAuditLogPageWithAllNonFiscalisedParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening SI Audit Log Info
        // [Given] POS and SI audit setup
        BindSubscription(LibrarySIFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllSIAuditLog(ParameterShow::AllNonFiscalised);
        UnbindSubscription(LibrarySIFiscal);
    end;

    [Test]
    [HandlerFunctions('OpenModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenSIAuditLogPageWithLastTransactionParameter()
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        // [Scenario] Test action for opening SI Audit Log Info
        // [Given] POS and SI audit setup
        BindSubscription(LibrarySIFiscal);

        InitializeData();

        // [When] Ending normal cash sale
        DoItemSale();

        //[Then]
        ShowAllSIAuditLog(ParameterShow::LastTransaction);
        UnbindSubscription(LibrarySIFiscal);
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
        _POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        ReturnReason: Record "Return Reason";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(GetTestPOSUnitNo(), _POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            _Item."Unit Price" := 10;
            _Item.Modify();

            LibrarySIFiscal.CreateAuditProfileAndSISetup(POSAuditProfile, _POSStore, _POSUnit, _Salesperson);

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

    local procedure ShowAllSIAuditLog(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        SIPOSAuditLogAuxInfoPage: Page "NPR SI POS Audit Log Aux. Info";
    begin
        case ParameterShow of
            ParameterShow::AllFiscalised:
                SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
            ParameterShow::AllNonFiscalised:
                SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", false);
            ParameterShow::LastTransaction:
                begin
                    ShowLastSIAuditLog();
                    exit;
                end;
        end;
        SIPOSAuditLogAuxInfoPage.SetTableView(SIPOSAuditLogAuxInfo);
        SIPOSAuditLogAuxInfoPage.RunModal();
    end;

    local procedure ShowLastSIAuditLog()
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        SIPOSAuditLogAuxInfo2: Record "NPR SI POS Audit Log Aux. Info";
        SIPOSAuditLogAuxInfoPage: Page "NPR SI POS Audit Log Aux. Info";
    begin
        SIPOSAuditLogAuxInfo.SetLoadFields("Audit Entry Type", "Audit Entry No.");
        SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
        SIPOSAuditLogAuxInfo.FindLast();
        SIPOSAuditLogAuxInfo2.SetRange("Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry Type");
        SIPOSAuditLogAuxInfo2.SetRange("Audit Entry No.", SIPOSAuditLogAuxInfo."Audit Entry No.");
        SIPOSAuditLogAuxInfoPage.SetTableView(SIPOSAuditLogAuxInfo2);
        SIPOSAuditLogAuxInfoPage.RunModal();
    end;

    [ModalPageHandler]
    procedure OpenModalPageHandler(var SIPOSAuditLogAuxInfoPage: TestPage "NPR SI POS Audit Log Aux. Info")
    begin
        _Assert.IsTrue(true, 'Page opened.');
    end;

    local procedure GetTestPOSUnitNo(): Code[10]
    begin
        exit('077');
    end;
}