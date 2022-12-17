codeunit 85101 "NPR POS Action Layaway Tests"
{
    Subtype = Test;

    var
        Customer: Record Customer;
        Item: Record Item;
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        PaymentTerms: Record "Payment Terms";
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LayawayCreateBussLogic: Codeunit "NPR POS Act.: Layaway Create-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateLayaway()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        //[Given] Init Data
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        CheckPrepmtAccNo(SalePOS, Item."Gen. Prod. Posting Group");

        //[When]
        LayawayCreateBussLogic.CreateLayaway(POSSession, 10, 1, '', PaymentTerms.Code, PaymentTerms.Code, false, false);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //[Given]
        if not SalesInvHeader.Get(SaleLinePOS."Posted Sales Document No.") then
            Assert.AssertRecordNotFound();
        SalesInvHeader.CalcFields("Amount Including VAT");
        Assert.IsTrue(SalesInvHeader."Amount Including VAT" = Round(Item."Unit Price" * 0.1, 0.01), StrSubstNo('Downpayment percent is not calculated. %1', System.Round(Item."Unit Price" * 0.1, 2)));
        if not SalesHeader.Get("Sales Document Type"::Order, SalesInvHeader."Prepayment Order No.") then
            Assert.AssertRecordNotFound();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SOListHandler,PrepaymentInvListHandler')]
    procedure ShowLayaway()
    var
        SalePOS: Record "NPR POS Sale";
        ShowLayawayBL: Codeunit "NPR POS Action: LayawayShow-B";
    begin
        //[Given] Init Data
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        CheckPrepmtAccNo(SalePOS, Item."Gen. Prod. Posting Group");
        LayawayCreateBussLogic.CreateLayaway(POSSession, 10, 1, '', PaymentTerms.Code, PaymentTerms.Code, false, false);

        //[When]
        ShowLayawayBL.RunDocument(true, PaymentTerms.Code, POSSale);

    end;

    [ModalPageHandler]
    procedure SOListHandler(var SOList: TestPage "Sales Order List")
    var
        SalesHeader: Record "Sales Header";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesInvHeader: Record "Sales Invoice Header";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SalesInvHeader.Get(SaleLinePOS."Posted Sales Document No.");
        SalesHeader.Get("Sales Document Type"::Order, SalesInvHeader."Prepayment Order No.");
        SOList.GoToRecord(SalesHeader);
        SOList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure PrepaymentInvListHandler(var PrepayInv: TestPage "NPR POS Prepaym. Invoices")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesInvHeader: Record "Sales Invoice Header";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SalesInvHeader.Get(SaleLinePOS."Posted Sales Document No.");
        Assert.IsTrue(PrepayInv.GoToRecord(SalesInvHeader), '');
    end;

    internal procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";

    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibrarySales.CreateCustomer(Customer);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            CreatePaymentTerm(PaymentTerms);
            CheckSalesReceivableSetup();

            Initialized := true;
        end;

        Commit();
    end;

    local procedure CheckSalesReceivableSetup()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        if SalesSetup."Posted Prepmt. Inv. Nos." = '' then begin
            SalesSetup."Posted Prepmt. Inv. Nos." := LibraryERM.CreateNoSeriesCode();
            SalesSetup.Modify();
        end;
    end;

    local procedure CheckPrepmtAccNo(SalePOS: Record "NPR POS Sale"; GenProdPostingGroup: Code[20])
    var
        GLAccount: Record "G/L Account";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostSetup: Record "VAT Posting Setup";
    begin
        if GeneralPostingSetup.Get(SalePOS."Gen. Bus. Posting Group", GenProdPostingGroup) then
            if GeneralPostingSetup."Sales Prepayments Account" = '' then begin
                LibraryERM.CreateGLAccount(GLAccount);
                GLAccount.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                if GLAccount."VAT Prod. Posting Group" = '' then
                    GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                GLAccount.Modify();
                if not VATPostSetup.Get(SalePOS."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group") then
                    LibraryERM.CreateVATPostingSetup(VATPostSetup, SalePOS."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
                GeneralPostingSetup.Validate("Sales Prepayments Account", GLAccount."No.");
                GeneralPostingSetup.Modify();
            end else begin
                GLAccount.Get(GeneralPostingSetup."Sales Prepayments Account");
                if GLAccount."Gen. Prod. Posting Group" = '' then begin
                    GLAccount.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                    GLAccount.Modify();
                end;
                if GLAccount."VAT Prod. Posting Group" = '' then begin
                    GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                    GLAccount.Modify();
                end;
            end;
    end;

    local procedure CreatePaymentTerm(var PaymentTerms: Record "Payment Terms")
    var
        DateFormulaVariable: DateFormula;
    begin
        LibraryInventory.CreatePaymentTerms(PaymentTerms);
        Evaluate(DateFormulaVariable, 'CM');
        PaymentTerms."Due Date Calculation" := DateFormulaVariable;
        PaymentTerms.Modify(true);
    end;

}