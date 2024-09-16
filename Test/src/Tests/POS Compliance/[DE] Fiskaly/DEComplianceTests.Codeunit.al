codeunit 85214 "NPR DE Compliance Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _POSSession: Codeunit "NPR POS Session";
        _Assert: Codeunit Assert;
        _Initialized: Boolean;

        _Salesperson: Record "Salesperson/Purchaser";
        _POSUnit: Record "NPR POS Unit";

        _POSPaymentMethod: Record "NPR POS Payment Method";

        _ReturnReason: Record "Return Reason";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateTSSandClientData()
    var
        DEAuditSetup: Record "NPR DE Audit Setup";
        DETSS: Record "NPR DE TSS";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
    begin
        // [Scenario] Check that TSS and Client are successfully created.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryDEFiscal);

        // [When] Creating TSS and Client setup
        LibraryDEFiscal.CreateDEConnectionParamSet(DEAuditSetup);
        LibraryDEFiscal.CreateTSSClient(DETSS, DEAuditSetup);
        LibraryDEFiscal.CreatePOSUnit(POSUnit, POSStore, POSPostingProfile);
        LibraryDEFiscal.CreateDEPOSUnitAuxInfo(DEPOSUnitAuxInfo, POSUnit, DETSS, DEAuditSetup);

        // [Then] Setup records are filled with information received from Fiskaly
        _Assert.IsTrue(DETSS."Fiskaly TSS Created at" <> 0DT, 'Fiskaly TSS Created at must be initialized.');
        _Assert.IsTrue(DETSS."Fiskaly TSS State" in [DETSS."Fiskaly TSS State"::CREATED, DETSS."Fiskaly TSS State"::INITIALIZED], 'Fiskaly TSS State must be CREATED or INITIALIZED.');
        _Assert.IsTrue(DEPOSUnitAuxInfo."Fiskaly Client Created at" <> 0DT, 'Fiskaly Client Created at must be initialized.');
        _Assert.IsTrue(DEPOSUnitAuxInfo."Fiskaly Client State" in [DEPOSUnitAuxInfo."Fiskaly Client State"::REGISTERED], 'Fiskaly Client state must be REGISTERED.');

        // [Cleanup] Cleanum and Unbind Event Subscriptions in Test Library Codeunit
        DEAuditSetup.DeleteAll();
        DETSS.DeleteAll();
        DEPOSUnitAuxInfo.DeleteAll();
        UnbindSubscription(LibraryDEFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetTSSClientList()
    var
        DEAuditSetup: Record "NPR DE Audit Setup";
        DETSS: Record "NPR DE TSS";
        DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
    begin
        // [Scenario] Check that Clients are successfully retrieved from Fiskaly.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryDEFiscal);

        // [When] Creating TSS and Client setup
        LibraryDEFiscal.CreateDEConnectionParamSet(DEAuditSetup);
        LibraryDEFiscal.CreateTSSClient(DETSS, DEAuditSetup);
        DEFiskalyCommunication.GetTSSClientList(DETSS, DEPOSUnitAuxInfo);

        // [Then] Setup records are filled with information received from Fiskaly
        _Assert.IsTrue(DEPOSUnitAuxInfo.FindFirst(), 'Client List has not been imported correctly');

        // [Cleanup] Cleanum and Unbind Event Subscriptions in Test Library Codeunit
        DEAuditSetup.DeleteAll();
        DETSS.DeleteAll();
        DEPOSUnitAuxInfo.DeleteAll();
        UnbindSubscription(LibraryDEFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateNormalSale()
    var
        DEPOSAuditLogAuxInfo: Record "NPR DE POS Audit Log Aux. Info";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
        POSEntryNo: Integer;
    begin
        // [Scenario] Check that TSS and Client are successfully created.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryDEFiscal);

        // [Given] Base setup for sale and DE Setup
        InitializeData();

        // [WHEN] Ending normal cash sale
        POSEntryNo := DoItemSale();

        // [Then] DE POS Audit Log filled with information received from Fiskaly
        DEPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        DEPOSAuditLogAuxInfo.FindFirst();
        DEPOSAuditLogAuxInfo.CalcFields(Signature);
        _Assert.IsTrue(DEPOSAuditLogAuxInfo."Fiscalization Status" in [DEPOSAuditLogAuxInfo."Fiscalization Status"::Fiscalized], 'POS Sale Transaction must be fiscalized.');
        _Assert.IsTrue(DEPOSAuditLogAuxInfo.Signature.HasValue(), 'Signature must have a value in DE POS Audit Log Aux Info');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryDEFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateReturnSale()
    var
        POSEntry: Record "NPR POS Entry";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
        DEPOSAuditLogAuxInfo: Record "NPR DE POS Audit Log Aux. Info";
        EntryNumber: Integer;
        ReturnEntryNumber: Integer;
    begin
        // [Scenario] Check that TSS and Client are successfully created.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryDEFiscal);

        // [Given] Base setup for sale and DE Setup
        InitializeData();

        // [WHEN] Ending normal cash sale and returning it
        EntryNumber := DoItemSale();
        POSEntry.Get(EntryNumber);
        ReturnEntryNumber := DoReturnSale(POSEntry."Document No.");

        // [Then] DE POS Audit Log filled with information received from Fiskaly
        DEPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        DEPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(DEPOSAuditLogAuxInfo."Fiscalization Status" in [DEPOSAuditLogAuxInfo."Fiscalization Status"::Fiscalized], 'POS Sale Transaction must be fiscalized.');
        DEPOSAuditLogAuxInfo.CalcFields(Signature);
        _Assert.IsTrue(DEPOSAuditLogAuxInfo.Signature.HasValue(), 'Signature must have a value in DE POS Audit Log Aux Info');

        DEPOSAuditLogAuxInfo.SetRange("POS Entry No.", ReturnEntryNumber);
        DEPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(DEPOSAuditLogAuxInfo."Fiscalization Status" in [DEPOSAuditLogAuxInfo."Fiscalization Status"::Fiscalized], 'POS Return Transaction must be fiscalized.');
        DEPOSAuditLogAuxInfo.CalcFields(Signature);
        _Assert.IsTrue(DEPOSAuditLogAuxInfo.Signature.HasValue(), 'Signature must have a value in DE POS Audit Log Aux Info');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryDEFiscal);
    end;

    local procedure InitializeData()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSAuditLog: Record "NPR POS Audit Log";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if _Initialized then begin
            // Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end else begin
            LibraryDEFiscal.CreatePOSUnit(_POSUnit, POSStore, POSPostingProfile);
            LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            LibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);
            _Item."Unit Price" := 10;
            _Item.Modify();
            LibraryERM.CreateReturnReasonCode(_ReturnReason);
            LibraryDEFiscal.CreateVATPostingSetup(POSPostingProfile."VAT Bus. Posting Group", _Item."VAT Prod. Posting Group");
            LibraryDEFiscal.CreatePOSPaymentMethod(_POSPaymentMethod, Enum::"NPR Payment Processing Type"::CASH);
            LibraryDEFiscal.CreateAuditProfileSetup(POSAuditProfile, _POSUnit);

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); // Clean between tests
        Commit();
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(_POSSession, _Item."No.", 1);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
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
}