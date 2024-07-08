codeunit 85101 "NPR POS Action Layaway Tests"
{
    Subtype = Test;

    var
        Customer: Record Customer;
        Item: Record Item;
        POSPaymentMethod: Record "NPR POS Payment Method";
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
        CreatedSalesHeader: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateLayaway()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        //[Given] Init Data
        InitDataForLayway();

        //[When]
        LayawayCreateBussLogic.CreateLayaway(POSSession, 10, 1, '', PaymentTerms.Code, PaymentTerms.Code, false, false);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //[Then]
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ChooseSOListHandler,ClickOnOKMsg')]
    procedure CancelLayaway()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        LayawayCancelB: Codeunit "NPR POS Act.:Layaway Cancel-B";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        //[Given] Init Data
        InitDataForLayway();
        LayawayCreateBussLogic.CreateLayaway(POSSession, 10, 1, '', PaymentTerms.Code, PaymentTerms.Code, false, false);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SalesInvHeader.Get(SaleLinePOS."Posted Sales Document No.");
        SalesHeader.Get("Sales Document Type"::Order, SalesInvHeader."Prepayment Order No.");
        CreatedSalesHeader := SalesHeader."No.";
        LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '', false);

        PostPosEntry();

        //[When]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        LayawayCancelB.CancelLayaway(POSSale, POSSaleLine, '', PaymentTerms.Code, false, true, false);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"Customer Deposit");
        SaleLinePOS.FindFirst();
        Assert.IsTrue(SaleLinePOS."Buffer Document Type" = SaleLinePOS."Buffer Document Type"::"Credit Memo", 'Credit Memo is not created.');
        Assert.IsTrue(SalesCrMemoHeader.Get(SaleLinePOS."Buffer Document No."), 'Credit Memo is not find');
        Assert.IsTrue(SalesCrMemoHeader."Prepayment Order No." = CreatedSalesHeader, 'Credit Memo is not created with Prepayment Order No.');
        SalesHeader.Reset();
        Assert.IsFalse(SalesHeader.Get(Enum::"Sales Document Type"::Order, CreatedSalesHeader), 'Order is not deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ChooseSOListHandler')]
    procedure PayLayaway()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        LayawayCancelB: Codeunit "NPR POS Action: Layaway Pay-B";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        AmountToPay, PaidAmount : Decimal;
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        //[Given] Init Data
        InitDataForLayway();
        LayawayCreateBussLogic.CreateLayaway(POSSession, 10, 1, '', PaymentTerms.Code, PaymentTerms.Code, false, false);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SalesInvHeader.Get(SaleLinePOS."Posted Sales Document No.");
        SalesHeader.Get("Sales Document Type"::Order, SalesInvHeader."Prepayment Order No.");
        CreatedSalesHeader := SalesHeader."No.";
        PaidAmount := SaleLinePOS."Amount Including VAT";
        SalesHeader.CalcFields("Amount Including VAT");
        AmountToPay := SalesHeader."Amount Including VAT" - PaidAmount;
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;

        LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '', false);

        PostPosEntry();

        //[When]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        LayawayCancelB.PayLayaway(POSSession, '', 0, false, false, POSSalesDocumentPost);

        //[Then]
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange("Document No.", SalesInvHeader."No.");
        CustLedgEntry.SetRange("Customer No.", SalesInvHeader."Bill-to Customer No.");
        CustLedgEntry.FindFirst();
        Assert.IsTrue(CustLedgEntry.Open = false, 'Cust Ledger Entry is not closed.');

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.FindFirst();
        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = AmountToPay, 'Amount of prepayment invoice is not paid');

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.SetRange("Sales Document Type", SaleLinePOS."Sales Document Type"::Order);
        SaleLinePOS.SetRange("Sales Document No.", CreatedSalesHeader);
        SaleLinePOS.SetRange("Amount Including VAT", 0);
        if SaleLinePOS.IsEmpty() then
            Assert.AssertNothingInsideFilter();
    end;

    local procedure PostPosEntry()
    var
        POSEntry: Record "NPR POS Entry";
        POSPostEntries: Codeunit "NPR POS Post Entries";
    begin
        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
        if POSEntry."Post Item Entry Status" < POSEntry."Post Item Entry Status"::Posted then
            POSPostEntries.SetPostItemEntries(true);
        if POSEntry."Post Entry Status" < POSEntry."Post Entry Status"::Posted then
            POSPostEntries.SetPostPOSEntries(true);
        POSPostEntries.SetStopOnError(true);
        POSPostEntries.SetPostCompressed(false);
        POSPostEntries.Run(POSEntry);
    end;

    [ModalPageHandler]
    procedure ChooseSOListHandler(var SOList: TestPage "Sales List")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get("Sales Document Type"::Order, CreatedSalesHeader);
        SOList.GoToRecord(SalesHeader);
        SOList.OK().Invoke();
    end;

    [MessageHandler]
    procedure ClickOnOKMsg(Msg: Text[1024])
    var
        Text001: Label 'Layaway order credited and deleted.\Refund line has been created for total paid amount minus fees.';
    begin
        Assert.IsTrue(Msg = Text001, Msg);
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
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
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
        if (SalesSetup."Posted Prepmt. Inv. Nos." <> '') and (SalesSetup."Posted Prepmt. Cr. Memo Nos." <> '') then
            exit;
        if SalesSetup."Posted Prepmt. Inv. Nos." = '' then
            SalesSetup."Posted Prepmt. Inv. Nos." := LibraryERM.CreateNoSeriesCode();
        if SalesSetup."Posted Prepmt. Cr. Memo Nos." = '' then
            SalesSetup."Posted Prepmt. Cr. Memo Nos." := LibraryERM.CreateNoSeriesCode();
        SalesSetup.Modify();
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

    local procedure InitDataForLayway()
    var
        SalePOS: Record "NPR POS Sale";
    begin
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        CheckPrepmtAccNo(SalePOS, Item."Gen. Prod. Posting Group");
    end;
}