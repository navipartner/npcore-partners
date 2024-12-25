codeunit 85091 "NPR SI Compliance Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSPostingProfile: Record "NPR POS Posting Profile";
        _POSUnit: Record "NPR POS Unit";
        _ReturnReason: Record "Return Reason";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NormalPOSSaleFiscalization()
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
        EntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales gets successful response by the tax authority when SI audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibrarySIFiscal);

        // [Given] POS and SI audit setup
        InitializeData();

        // [When] Ending normal cash sale
        EntryNumber := DoItemSale();

        // [Then] For normal cash sale SI Audit Log is created and filled by the Tax Authority
        SIPOSAuditLogAuxInfo.SetRange("Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        SIPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        SIPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(SIPOSAuditLogAuxInfo."EOR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibrarySIFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReturnPOSSaleFiscalization()
    var
        POSEntry: Record "NPR POS Entry";
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
        EntryNumber: Integer;
        ReturnEntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales refund gets successful response by the tax authority when SI audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibrarySIFiscal);

        // [Given] POS and SI audit setup
        InitializeData();

        // [When] Ending and returning receipt
        EntryNumber := DoItemSale();
        POSEntry.Get(EntryNumber);
        ReturnEntryNumber := DoReturnSale(POSEntry."Document No.");

        // [Then] For normal cash sale SI Audit Log is created and filled by the Tax Authority for both sales and refund
        SIPOSAuditLogAuxInfo.SetRange("Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        SIPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        SIPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(SIPOSAuditLogAuxInfo."EOR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        SIPOSAuditLogAuxInfo.SetRange("Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        SIPOSAuditLogAuxInfo.SetRange("POS Entry No.", ReturnEntryNumber);
        SIPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(SIPOSAuditLogAuxInfo."EOR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibrarySIFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NormalSaleWithPrenumberedBook()
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
        EntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sale with paragon number gets successful response by the tax authority when SI audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibrarySIFiscal);

        // [Given] POS and SI audit setup
        InitializeData();

        // [When] Ending and returning receipt
        EntryNumber := DoItemSaleWithPrenumberedBook();

        // [Then] For normal cash sale with paragon number SI Audit Log is created and fields are filled by the Tax Authority
        SIPOSAuditLogAuxInfo.SetRange("Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        SIPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        SIPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(SIPOSAuditLogAuxInfo."Salesbook Entry No." <> 0, 'Salesbook Sale has to have a Salesbook Entry No.');
        _Assert.IsTrue(SIPOSAuditLogAuxInfo."EOR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibrarySIFiscal);
    end;

    internal procedure InitializeData()
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSSetup: Record "NPR POS Setup";
        _POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
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
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(_POSPostingProfile);
            _POSPostingProfile."POS Period Register No. Series" := '';
            _POSPostingProfile.Modify();
            LibrarySIFiscal.CreatePOSStore(_POSStore, _POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSUnit(GetTestPOSUnitNo(), _POSUnit, _POSStore.Code, _POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(_ReturnReason);
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

    local procedure DoItemSaleWithPrenumberedBook(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionPreInvIns: Codeunit "NPR POS Action: SIPreInv Ins.";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSActionPreInvIns.InputAuditPreInvoiceNumbersTest(GetTestSetNo(), GetTestSerialNo(), GetTestReceiptNo(), Today(), POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoReturnSale(ReceiptNumberToReturn: Code[20]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionRevDirSale: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSActionRevDirSale.ReverseSalesTicket(POSSaleRecord, ReceiptNumberToReturn, _ReturnReason.Code, true);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure GetTestPOSUnitNo(): Code[10]
    begin
        exit('077');
    end;

    local procedure GetTestSetNo(): Text
    begin
        exit('12');
    end;

    local procedure GetTestSerialNo(): Text
    begin
        exit('5001-00152');
    end;

    local procedure GetTestReceiptNo(): Text
    begin
        exit('30');
    end;
}