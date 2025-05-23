codeunit 85163 "NPR CRO Compliance Tests"
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
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        EntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales gets successful response by the tax authority when CRO audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup
        InitializeData();

        // [When] Ending normal cash sale
        EntryNumber := DoItemSale();

        // [Then] For normal cash sale CRO Audit Log is created and filled by the Tax Authority
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReturnPOSSaleFiscalization()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        EntryNumber: Integer;
        ReturnEntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales refund gets successful response by the tax authority when CRO audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup
        InitializeData();

        // [When] Ending and returning receipt
        EntryNumber := DoItemSale();
        POSEntry.Get(EntryNumber);
        ReturnEntryNumber := DoReturnSale(POSEntry."Document No.");

        // [Then] For normal cash sale CRO Audit Log is created and filled by the Tax Authority for both sales and refund
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", ReturnEntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NormalSaleWithParagonNumber()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        EntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sale with paragon number gets successful response by the tax authority when CRO audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup
        InitializeData();

        // [When] Ending and returning receipt
        EntryNumber := DoItemSaleWithParagon();

        // [Then] For normal cash sale with paragon number CRO Audit Log is created and fields are filled by the Tax Authority
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibraryCROFiscal);
    end;

    internal procedure InitializeData()
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
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
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, _POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(GetTestPOSUnitNo(), _POSUnit, POSStore.Code, _POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(_ReturnReason);
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

    local procedure DoItemSaleWithParagon(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionParagonInsert: Codeunit "NPR POS Action: CROParagon Ins";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSActionParagonInsert.InputAuditParagonNumberTest(GetTestParagonNo(), POSSaleRecord);
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

    local procedure GetTestParagonNo(): Text
    begin
        exit('123/777');
    end;
}