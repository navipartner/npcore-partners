codeunit 85197 "NPR AT Receipt Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        ATCashRegister: Record "NPR AT Cash Register";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateReceipt()
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ReceiptShouldBeValidatedErr: Label 'Receipt should be validated.', Locked = true;
    begin
        // [SCENARIO] Checks validating of receipt with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] Control transaction POS Audit Log for initialization receipt exists
        InsertATPOSAuditLogAuxInfo(ATCashRegister, POSUnit, ATPOSAuditLogAuxInfo, Enum::"NPR AT Receipt Type"::INITIALIZATION);

        // [WHEN] Validating receipt at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.ValidateReceipt(ATPOSAuditLogAuxInfo);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] Control transaction POS Audit Log for initialization receipt is validated from FinanzOnline
        Assert.AreEqual(ATPOSAuditLogAuxInfo."FON Receipt Validation Status", ATPOSAuditLogAuxInfo."FON Receipt Validation Status"::SUCCESS, ReceiptShouldBeValidatedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo."Validated At" <> 0DT, ReceiptShouldBeValidatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SignReceipt()
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        POSEntryNo: Integer;
        SalesShouldBeSignedErr: Label 'Sales should be signed.', Locked = true;
    begin
        // [SCENARIO] Checks signing of AT POS Audit Log Aux. Info record with successful response from Fiskaly for successful cash sales
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [WHEN] Ending normal cash sale
        POSEntryNo := DoItemSale();

        // [THEN] For normal cash sale AT Audit Log is created and signed
        ATPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ATPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ATPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ATPOSAuditLogAuxInfo.FindFirst();
        Assert.IsFalse(IsNullGuid(ATPOSAuditLogAuxInfo."AT SCU Id"), SalesShouldBeSignedErr);
        Assert.IsFalse(IsNullGuid(ATPOSAuditLogAuxInfo."AT Cash Register Id"), SalesShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" <> '', SalesShouldBeSignedErr);
        Assert.AreEqual(ATPOSAuditLogAuxInfo."Receipt Type", ATPOSAuditLogAuxInfo."Receipt Type"::NORMAL, SalesShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo.Signed, SalesShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo.GetQRCode() <> '', SalesShouldBeSignedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SignControlReceipt()
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        ControlReceiptShouldBeSignedErr: Label 'Control receipt should be signed.', Locked = true;
    begin
        // [SCENARIO] Checks signing of control AT POS Audit Log Aux. Info record with successful response from Fiskaly
        // [GIVEN] POS and AT audit setup
        InitializeData();

        // [GIVEN] Control transaction POS Audit Log for initialization receipt exists
        InsertATPOSAuditLogAuxInfo(ATCashRegister, POSUnit, ATPOSAuditLogAuxInfo, Enum::"NPR AT Receipt Type"::NORMAL);

        // [WHEN] Signing control receipt at Fiskaly
        BindSubscription(ATFiscalLibrary);
        ATFiskalyCommunication.SignControlReceipt(ATPOSAuditLogAuxInfo);
        UnbindSubscription(ATFiscalLibrary);

        // [THEN] Control transaction POS Audit Log is signed from Fiskaly
        Assert.AreEqual(ATPOSAuditLogAuxInfo."Audit Entry Type", ATPOSAuditLogAuxInfo."Audit Entry Type"::"Control Transaction", ControlReceiptShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo."POS Entry No." = 0, ControlReceiptShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo."Amount Incl. Tax" = 0, ControlReceiptShouldBeSignedErr);
        Assert.IsFalse(IsNullGuid(ATPOSAuditLogAuxInfo."AT SCU Id"), ControlReceiptShouldBeSignedErr);
        Assert.IsFalse(IsNullGuid(ATPOSAuditLogAuxInfo."AT Cash Register Id"), ControlReceiptShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" <> '', ControlReceiptShouldBeSignedErr);
        Assert.AreEqual(ATPOSAuditLogAuxInfo."Receipt Type", ATPOSAuditLogAuxInfo."Receipt Type"::NORMAL, ControlReceiptShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo.Signed, ControlReceiptShouldBeSignedErr);
        Assert.IsTrue(ATPOSAuditLogAuxInfo.GetQRCode() <> '', ControlReceiptShouldBeSignedErr);
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        ATFiscalLibrary.SetSigned(true);
        BindSubscription(ATFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ATFiscalLibrary);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure InsertATPOSAuditLogAuxInfo(ThisATCashRegister: Record "NPR AT Cash Register"; ThisPOSUnit: Record "NPR POS Unit"; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; ReceiptType: Enum "NPR AT Receipt Type")
    var
        ATSCUToUse: Record "NPR AT SCU";
    begin
        ATPOSAuditLogAuxInfo.Init();
        ATPOSAuditLogAuxInfo."Audit Entry Type" := ATPOSAuditLogAuxInfo."Audit Entry Type"::"Control Transaction";
        ATPOSAuditLogAuxInfo."Entry Date" := Today();
        ATPOSAuditLogAuxInfo."POS Store Code" := ThisPOSUnit."POS Store Code";
        ATPOSAuditLogAuxInfo."POS Unit No." := ThisATCashRegister."POS Unit No.";
        ATPOSAuditLogAuxInfo."Receipt Type" := ReceiptType;
        ATSCUToUse.Get(ThisATCashRegister."AT SCU Code");
        ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCUToUse."AT Organization Code";
        ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCUToUse.Code;
        ATPOSAuditLogAuxInfo."AT SCU Id" := ATSCUToUse.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Id" := ThisATCashRegister.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := ThisATCashRegister."Serial Number";
        ATPOSAuditLogAuxInfo.Insert(true);
    end;

    local procedure InitializeData()
    var
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
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
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
            ATFiscalLibrary.CreateAuditProfileAndATSetups(POSAuditProfile, VATPostingSetup, POSUnit);
            CreateATOrganization(ATOrganization);
            CreateATSCU(ATSCU, ATOrganization.Code);
            CreateATCashRegister(ATCashRegister, POSUnit."No.", ATSCU.Code);

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

    local procedure CreateATOrganization(var ThisATOrganization: Record "NPR AT Organization")
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATOrganization(ThisATOrganization);
        ATFiscalLibrary.AuthenticateATOrganizaiton(ThisATOrganization);
    end;

    local procedure CreateATSCU(var ThisATSCU: Record "NPR AT SCU"; ATOrganizationCode: Code[20])
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATSCU(ThisATSCU);
        ATFiscalLibrary.InitializeATSCU(ThisATSCU, ATOrganizationCode);
    end;

    local procedure CreateATCashRegister(var ThisATCashRegister: Record "NPR AT Cash Register"; POSUnitNo: Code[10]; ATSCUCode: Code[20])
    var
        ATFiscalLibrary: Codeunit "NPR Library AT Fiscal";
    begin
        ATFiscalLibrary.CreateATCashRegister(ThisATCashRegister, POSUnitNo);
        ATFiscalLibrary.InitializeATCashRegister(ThisATCashRegister, ATSCUCode);
    end;
}