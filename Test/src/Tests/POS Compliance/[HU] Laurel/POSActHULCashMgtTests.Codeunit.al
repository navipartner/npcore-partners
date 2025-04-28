codeunit 85227 "NPR POS Act HUL Cash Mgt Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _ReturnReason: Record "Return Reason";
        _Salesperson: Record "Salesperson/Purchaser";
        _POSUnit: Record "NPR POS Unit";
        _Customer: Record Customer;
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;
        MoneyMgtMethod: Option moneyIn,moneyOut;
        CashTransactionRecordMustBeCreatedErr: Label 'A Record in Cash Transaction table must be created.';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('CashInMgtReasonModalHandler,POSPaymentMethodModalHandler,InputDialogCashAmountModalHandler')]
    procedure CashMgt_MoneyIn()
    var
        HULCashTransaction: Record "NPR HU L Cash Transaction";
        POSActionHULCashMgtB: Codeunit "NPR POS Action: HUL Cash Mgt B";
        LibraryHULFiscal: Codeunit "NPR Library HU L Fiscal";
        RequestObject: JsonObject;
    begin
        // [SCENARIO] Checks that manual cash-in gets successful response from the fiscal control unit when HU Laurel audit handler is enabled on POS unit.
        // [GIVEN] POS and HU Laurel audit setup
        InitializeData();

        // [WHEN] Manually doing cash-in
        POSActionHULCashMgtB.CreateMoneyInRequest(RequestObject, _POSUnit, MoneyMgtMethod::moneyIn);

        // [THEN] Successful response is received
        POSActionHULCashMgtB.ProcessLaurelMiniPOSResponse(LibraryHULFiscal.GetCashMgtMoneyInMockResponse());

        // [THEN] An entry in Cash Transactions table is created
        HULCashTransaction.SetRange("Entry Type", HULCashTransaction."Entry Type"::moneyIn);
        HULCashTransaction.FindLast();
        _Assert.IsTrue(HULCashTransaction."FCU ID" <> '', CashTransactionRecordMustBeCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('CashOutMgtReasonModalHandler,POSPaymentMethodModalHandler,InputDialogCashAmountModalHandler')]
    procedure CashMgt_MoneyOut()
    var
        HULCashTransaction: Record "NPR HU L Cash Transaction";
        POSActionHULCashMgtB: Codeunit "NPR POS Action: HUL Cash Mgt B";
        LibraryHULFiscal: Codeunit "NPR Library HU L Fiscal";
        RequestObject: JsonObject;
    begin
        // [SCENARIO] Checks that manual cash-out gets successful response from the fiscal control unit when HU Laurel audit handler is enabled on POS unit.
        // [GIVEN] POS and HU Laurel audit setup
        InitializeData();

        // [WHEN] Manually doing cash-in
        POSActionHULCashMgtB.CreateMoneyInRequest(RequestObject, _POSUnit, MoneyMgtMethod::moneyOut);

        // [THEN] Successful response is received
        POSActionHULCashMgtB.ProcessLaurelMiniPOSResponse(LibraryHULFiscal.GetCashMgtMoneyInMockResponse());

        // [THEN] An entry in Cash Transactions table is created
        HULCashTransaction.SetRange("Entry Type", HULCashTransaction."Entry Type"::moneyOut);
        HULCashTransaction.FindLast();
        _Assert.IsTrue(HULCashTransaction."FCU ID" <> '', CashTransactionRecordMustBeCreatedErr);
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
        LibraryHULFiscal: Codeunit "NPR Library HU L Fiscal";
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
            LibraryHULFiscal.CreateHULPOSUnitMapping(_POSUnit."No.");

            LibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            LibraryHULFiscal.CreateHULPOSPaymentMethodMapping(_POSPaymentMethod);

            LibraryHULFiscal.CreateHULPOSAuditProfileAndSetToPOSUnit(_POSUnit);
            LibraryHULFiscal.CreateHULFiscalizationSetup();

            _Initialized := true;
        end;

        Commit();
    end;

    [ModalPageHandler]
    procedure CashInMgtReasonModalHandler(var Page: Page "NPR HU L Cash Mgt. Reasons"; var Response: Action)
    var
        HULCashMgtReason: Record "NPR HU L Cash Mgt. Reason";
    begin
        Page.GetRecord(HULCashMgtReason);
        HULCashMgtReason.Get(1);
        Page.SetRecord(HULCashMgtReason);
        Response := Action::LookupOK;
    end;

    [ModalPageHandler]
    procedure CashOutMgtReasonModalHandler(var Page: Page "NPR HU L Cash Mgt. Reasons"; var Response: Action)
    var
        HULCashMgtReason: Record "NPR HU L Cash Mgt. Reason";
    begin
        Page.GetRecord(HULCashMgtReason);
        HULCashMgtReason.Get(31);
        Page.SetRecord(HULCashMgtReason);
        Response := Action::LookupOK;
    end;

    [ModalPageHandler]
    procedure POSPaymentMethodModalHandler(var Page: Page "NPR HU L POS Paym. Meth. Mapp."; var Response: Action)
    var
        HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
    begin
        Page.GetRecord(HULPOSPaymMethMapp);
        HULPOSPaymMethMapp.Get(_POSPaymentMethod.Code);
        Page.SetRecord(HULPOSPaymMethMapp);
        Response := Action::LookupOK;
    end;

    [ModalPageHandler]
    procedure InputDialogCashAmountModalHandler(var InputDialog: TestPage "NPR Input Dialog")
    begin
        InputDialog.InputField1.SetValue(100);
        InputDialog.OK().Invoke();
    end;
}