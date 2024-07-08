codeunit 85181 "NPR POSActBGSISReprFR Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler_InputDialog_ReprintFiscalReceiptFromElectronicJournal')]
    procedure ReprintFiscalReceiptFromElectronicJournal()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISReprFRB: Codeunit "NPR POS Action: BG SIS ReprFRB";
        Type: Option enterGrandReceiptNo,reprintSelectedFiscalized;
    begin
        // [SCENARIO] Checks that reprinting of fiscal receipt from electronic journal gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Reprinting fiscal receipt from electronic journal
        POSActionBGSISReprFRB.PrepareHTTPRequest(Type::enterGrandReceiptNo, POSUnit."No.");

        // [THEN] Seccessful response is received
        POSActionBGSISReprFRB.HandleResponse(BGSISFiscalLibrary.GetReprintFiscalReceiptMockResponse());
    end;

    [ModalPageHandler]
    procedure ModalPageHandler_InputDialog_ReprintFiscalReceiptFromElectronicJournal(var InputDialog: TestPage "NPR Input Dialog")
    begin
        InputDialog.InputField1.SetValue(1);
        InputDialog.OK().Invoke();
    end;

    local procedure InitializeData()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReturnReason: Record "Return Reason";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
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
            BGSISFiscalLibrary.CreateAuditProfileAndBGSISSetups(POSAuditProfile, VATPostingSetup, POSUnit);

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