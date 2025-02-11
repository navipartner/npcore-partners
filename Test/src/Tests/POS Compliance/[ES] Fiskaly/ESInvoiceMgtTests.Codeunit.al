codeunit 85212 "NPR ES Invoice Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        ESClient: Record "NPR ES Client";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure CreateInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntryNo: Integer;
        SalesShouldBeCreatedErr: Label 'Sales should be created.', Locked = true;
    begin
        // [SCENARIO] Checks creating invoice for ES POS Audit Log Aux. Info record with successful response from Fiskaly for successful cash sales
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Ending normal cash sale
        POSEntryNo := DoItemSale(Enum::"NPR ES Inv. Registration State"::PENDING);

        // [THEN] For normal cash sale ES POS Audit Log is created
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ESPOSAuditLogAuxInfo.FindFirst();
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Invoice No." <> '', SalesShouldBeCreatedErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Signer Id"), SalesShouldBeCreatedErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Client Id"), SalesShouldBeCreatedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::ISSUED, SalesShouldBeCreatedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Issued At" <> 0DT, SalesShouldBeCreatedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo.GetQRCode() <> '', SalesShouldBeCreatedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Validation URL" <> '', SalesShouldBeCreatedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::PENDING, SalesShouldBeCreatedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::NOT_CANCELLED, SalesShouldBeCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure RetrieveInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSEntryNo: Integer;
        SalesShouldBeRetrievedErr: Label 'Sales should be retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving invoice for ES POS Audit Log Aux. Info record with successful response from Fiskaly for successful cash sales
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES POS Audit Log for invoice exists
        POSEntryNo := DoItemSale(Enum::"NPR ES Inv. Registration State"::PENDING);
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ESPOSAuditLogAuxInfo.FindFirst();

        // [WHEN] Retrieving invoice from Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        ESFiskalyCommunication.RetrieveInvoice(ESPOSAuditLogAuxInfo);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES POS Audit Log for invoice is retrieved
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Signer Id"), SalesShouldBeRetrievedErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Client Id"), SalesShouldBeRetrievedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::ISSUED, SalesShouldBeRetrievedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Issued At" <> 0DT, SalesShouldBeRetrievedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo.GetQRCode() <> '', SalesShouldBeRetrievedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Validation URL" <> '', SalesShouldBeRetrievedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED, SalesShouldBeRetrievedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::NOT_CANCELLED, SalesShouldBeRetrievedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure CancelInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSEntryNo: Integer;
        SalesShouldBeCancelledErr: Label 'Sales should be cancelled.', Locked = true;
    begin
        // [SCENARIO] Checks cancelling invoice for ES POS Audit Log Aux. Info record with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES POS Audit Log for invoice registered at Fiskaly exists
        POSEntryNo := DoItemSale(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ESPOSAuditLogAuxInfo.FindFirst();

        // [WHEN] Cancelling invoice at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        ESFiscalLibrary.SetInvoiceCancellationState(Enum::"NPR ES Inv. Cancellation State"::CANCELLED);
        ESFiskalyCommunication.CancelInvoice(ESPOSAuditLogAuxInfo);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES POS Audit Log for invoice is cancelled
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Signer Id"), SalesShouldBeCancelledErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Client Id"), SalesShouldBeCancelledErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::CANCELLED, SalesShouldBeCancelledErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Issued At" <> 0DT, SalesShouldBeCancelledErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo.GetQRCode() <> '', SalesShouldBeCancelledErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Validation URL" <> '', SalesShouldBeCancelledErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED, SalesShouldBeCancelledErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::CANCELLED, SalesShouldBeCancelledErr);
    end;

    local procedure DoItemSale(InvoiceRegistrationState: Enum "NPR ES Inv. Registration State"): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        ESFiscalLibrary.SetInvoiceRegistrationState(InvoiceRegistrationState);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        CancelConfirmQst: Label 'Are you sure that you want to cancel this invoice since it is irreversible?';
        CreateCompleteInvoiceQst: Label 'Do you want to create complete invoice?', Locked = true;
        QuestionNotExpectedErr: Label 'Question "%1" is not expected.', Locked = true;
    begin
        case true of
            Question = CancelConfirmQst:
                Reply := true;
            Question = CreateCompleteInvoiceQst:
                Reply := false;
            else
                Error(QuestionNotExpectedErr, Question);
        end;
    end;

    local procedure InitializeData()
    var
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReturnReason: Record "Return Reason";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if Initialized then begin
            // Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end else begin
            POSMasterDataLibrary.CreatePOSSetup(POSSetup);
            POSMasterDataLibrary.CreateDefaultVoucherType(VoucherTypeDefault, false);
            POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            POSMasterDataLibrary.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            CreateSalesperson();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            Item."Unit Price" := 10;
            Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            ESFiscalLibrary.CreateAuditProfileAndESSetups(POSAuditProfile, VATPostingSetup, POSUnit);
            ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);
            ESFiscalLibrary.CreateESSigner(ESSigner, ESOrganization.Code);
            ESFiscalLibrary.CreateESClient(ESClient, ESSigner, POSUnit."No.", ESOrganization.Code);

            Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); // Clean between tests
        Commit();
    end;

    local procedure CreateSalesperson()
    begin
        if not Salesperson.Get('1') then begin
            Salesperson.Init();
            Salesperson.Validate(Code, '1');
            Salesperson.Validate(Name, 'Test');
            Salesperson.Insert();
        end;
        Salesperson."NPR Register Password" := '1';
        Salesperson.Modify();
    end;
}