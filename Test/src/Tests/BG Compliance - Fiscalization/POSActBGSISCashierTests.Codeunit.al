codeunit 85179 "NPR POSActBGSISCashier Tests"
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
    procedure GetCashierData()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISCashierB: Codeunit "NPR POS Action: BG SISCashierB";
        Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier;
    begin
        // [SCENARIO] Checks that get cashier data gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Getting cashier data
        POSActionBGSISCashierB.PrepareHTTPRequest(Method::getCashierData, POSUnit."No.", Salesperson.Code);

        // [THEN] Seccessful response is received
        POSActionBGSISCashierB.HandleResponse(BGSISFiscalLibrary.GetGetCashierDataMockResponse(), Method::getCashierData, '');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IsCashierSet()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISCashierB: Codeunit "NPR POS Action: BG SISCashierB";
        Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier;
    begin
        // [SCENARIO] Checks that check is cashier set gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Checking is cashier set
        POSActionBGSISCashierB.PrepareHTTPRequest(Method::isCashierSet, POSUnit."No.", Salesperson.Code);

        // [THEN] Seccessful response is received
        POSActionBGSISCashierB.HandleResponse(BGSISFiscalLibrary.GetGetCashierDataMockResponse(), Method::isCashierSet, Salesperson.Code);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler_Selepersons_Select')]
    procedure SetCashier()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISCashierB: Codeunit "NPR POS Action: BG SISCashierB";
        Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier;
    begin
        // [SCENARIO] Checks that set cashier gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Setting cashier
        POSActionBGSISCashierB.PrepareHTTPRequest(Method::setCashier, POSUnit."No.", '');

        // [THEN] Seccessful response is received
        POSActionBGSISCashierB.HandleResponse(BGSISFiscalLibrary.GetSetCashierMockResponse(), Method::setCashier, '');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler_Selepersons_Select')]
    procedure DeleteCashier()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISCashierB: Codeunit "NPR POS Action: BG SISCashierB";
        Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier;
    begin
        // [SCENARIO] Checks that delete cashier gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Deleting cashier
        POSActionBGSISCashierB.PrepareHTTPRequest(Method::deleteCashier, POSUnit."No.", '');

        // [THEN] Seccessful response is received
        POSActionBGSISCashierB.HandleResponse(BGSISFiscalLibrary.GetDeleteCashierMockResponse(), Method::deleteCashier, '');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TrySetCashier()
    var
        BGSISFiscalLibrary: Codeunit "NPR Library BG SIS Fiscal";
        POSActionBGSISCashierB: Codeunit "NPR POS Action: BG SISCashierB";
        Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier;
    begin
        // [SCENARIO] Checks that try set cashier gets successful response from the fiscal printer when BG SIS audit handler is enabled on POS unit.
        // [GIVEN] POS and BG SIS audit setup
        InitializeData();

        // [WHEN] Trying to set cashier
        POSActionBGSISCashierB.PrepareHTTPRequest(Method::trySetCashier, POSUnit."No.", Salesperson.Code);

        // [THEN] Seccessful response is received
        POSActionBGSISCashierB.HandleResponse(BGSISFiscalLibrary.GetTrySetCashierMockResponse(), Method::trySetCashier, '');
    end;

    [ModalPageHandler]
    procedure ModalPageHandler_Selepersons_Select(var Salespersons: TestPage "Salespersons/Purchasers")
    begin
        Salespersons.Filter.SetFilter(Code, Salesperson.Code);
        Salespersons.First();
        Salespersons.OK().Invoke();
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