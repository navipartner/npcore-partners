codeunit 85177 "NPR POSActBGSISCashMgt Tests"
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
    [HandlerFunctions('ModalPageHandler_InputDialog_CashHandling')]
    procedure CashHandling_In()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISCashMgtB: Codeunit "NPR POS Action: BGSISCashMgt B";
    begin
        // [SCENARIO] Checks that manual cash-in gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Manually doing cash-in
        POSActionBGSISCashMgtB.PrepareHTTPRequest(0, POSUnit."No.", Salesperson.Code); // Note:: cannot use Direction::In directly in the code since In is reserved word and AL Code Cop does not allow it

        // [THEN] Seccessful response is received
        POSActionBGSISCashMgtB.HandleResponse(BGSISFiscalLibrary.GetCashHandlingMockResponse());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler_InputDialog_CashHandling')]
    procedure CashHandling_Out()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISCashMgtB: Codeunit "NPR POS Action: BGSISCashMgt B";
        Direction: Option In,Out;
    begin
        // [SCENARIO] Checks that manual cash-out gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Manually doing cash-out
        POSActionBGSISCashMgtB.PrepareHTTPRequest(Direction::Out, POSUnit."No.", Salesperson.Code);

        // [THEN] Seccessful response is received
        POSActionBGSISCashMgtB.HandleResponse(BGSISFiscalLibrary.GetCashHandlingMockResponse());
    end;

    [ModalPageHandler]
    procedure ModalPageHandler_InputDialog_CashHandling(var InputDialog: TestPage "NPR Input Dialog")
    begin
        InputDialog.InputField1.SetValue(100);
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