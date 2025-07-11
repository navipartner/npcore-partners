codeunit 85079 "NPR POS Act. Doc. Prepay Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        Customer: Record Customer;
        POSPaymentMethodCash: Record "NPR POS Payment Method";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        SalesSetup: Record "Sales & Receivables Setup";
        Assert: Codeunit Assert;
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        LibraryERM: Codeunit "Library - ERM";
        Initialized: Boolean;
        LibrarySales: Codeunit "Library - Sales";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure CreatePrepaymentLineWithMaxPrepaymentValue()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        PrepaymentValue: Decimal;
        ValueIsAmount: Boolean;
        PREPAYMENT: Label 'Prepayment of %1 %2';
        ExpectedPrepayAmt: Decimal;
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        // [Scenario] Create prepayment for existing order, prepayment amount is value
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSalesOrder(SalesHeader); //Sales Order With with one line
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;

        POSSale.GetCurrentSale(SalePOS);
        SalesHeader.CalcFields("Amount Including VAT");
        // parameters
        PrepaymentValue := SalesHeader."Amount Including VAT" + 1;
        ValueIsAmount := true;
        // [When]
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentValue, ValueIsAmount, false, false, POSSalesDocumentPost);
        POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, PrepaymentValue);
        ExpectedPrepayAmt := PrepaymentValue;
        // [Then]
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = ExpectedPrepayAmt, 'Max Prepayment Amt. is SalesHeader."Amount Including VAT"');
        Assert.IsTrue(SaleLinePOS."Sales Document Prepayment" = true, 'Prepayment set');
        Assert.IsTrue(SaleLinePOS."Sales Doc. Prepayment Value" = PrepaymentValue, 'Prepayment Value set');
        Assert.IsTrue(SaleLinePOS."Sales Document No." = SalesHeader."No.", 'Order Set');
        Assert.IsTrue(SaleLinePOS.Description = StrSubstNo(PREPAYMENT, SalesHeader."Document Type", SalesHeader."No."), 'Description Prepayment');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure CreatePrepaymentLineWithPrepaymentPrc()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        PrepaymentValue: Decimal;
        ValueIsAmount: Boolean;
        LibraryRandom: Codeunit "Library - Random";
        PREPAYMENT: Label 'Prepayment of %1 %2';
        ExpectedPrepayAmt: Decimal;
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        // [Scenario] Create prepayment for existing order, prepayment amount is in percentage
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSalesOrder(SalesHeader); //Sales Order With with one line
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;

        POSSale.GetCurrentSale(SalePOS);
        SalesHeader.CalcFields("Amount Including VAT");
        // parameters
        PrepaymentValue := 50;
        ValueIsAmount := true;
        // [When]
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentValue, ValueIsAmount, false, false, POSSalesDocumentPost);
        POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, PrepaymentValue);
        ExpectedPrepayAmt := PrepaymentValue;
        // [Then]
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = ExpectedPrepayAmt, 'Prepayment Value is set');
        Assert.IsTrue(SaleLinePOS."Sales Document Prepayment" = true, 'Prepayment set');
        Assert.IsTrue(SaleLinePOS."Sales Doc. Prepayment Value" = ExpectedPrepayAmt, 'Prepayment Value set');
        Assert.IsTrue(SaleLinePOS."Sales Document No." = SalesHeader."No.", 'Order Set');
        Assert.IsTrue(SaleLinePOS.Description = StrSubstNo(PREPAYMENT, SalesHeader."Document Type", SalesHeader."No."), 'Description Prepayment');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure CreatePrepaymentLineWithPrepaymentAmt()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        PrepaymentValue: Decimal;
        ValueIsAmount: Boolean;
        ExpectedPrepayAmt: Decimal;
        PREPAYMENT: Label 'Prepayment of %1 %2';
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        // [Scenario] Create prepayment for existing order, prepayment amount is value
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSalesOrder(SalesHeader); //Sales Order With with one line
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;

        POSSale.GetCurrentSale(SalePOS);
        SalesHeader.CalcFields("Amount Including VAT");
        // parameters
        PrepaymentValue := 100;
        ValueIsAmount := true;
        // [When]
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentValue, ValueIsAmount, false, false, POSSalesDocumentPost);
        POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, PrepaymentValue);
        ExpectedPrepayAmt := PrepaymentValue;
        // [Then]
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = ExpectedPrepayAmt, 'Prepayment value ok');
        Assert.IsTrue(SaleLinePOS."Sales Document Prepayment" = true, 'Prepayment set');
        Assert.IsTrue(SaleLinePOS."Sales Doc. Prepayment Value" = PrepaymentValue, 'Prepayment Value set');
        Assert.IsTrue(SaleLinePOS."Sales Document No." = SalesHeader."No.", 'Order Set');
        Assert.IsTrue(SaleLinePOS.Description = StrSubstNo(PREPAYMENT, SalesHeader."Document Type", SalesHeader."No."), 'Description Prepayment');

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
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethodCash, POSPaymentMethodCash."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            LibrarySales.CreateCustomer(Customer);
            CheckSalesReceivableSetup();
            CheckPrepmtAccNo();

            Initialized := true;
        end;

        Commit();
    end;

    [Test]
    internal procedure CreateRefundPrepaymentLine()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleEnded: Boolean;
        PrepaymentValue: Decimal;
        ValueIsAmount: Boolean;
        PREPAYMENT_REFUND: Label 'Prepayment refund of %1 %2';
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        // [Scenario] Chose order with prepayment ,post it and then refund prepayment
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSalesOrder(SalesHeader); //Sales Order With with one line
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;
        // Create and post prepayment
        // parameters
        PrepaymentValue := 50;
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentValue, ValueIsAmount, false, false, POSSalesDocumentPost);
        // End Sale
        SalesHeader.CalcFields("Amount Including VAT");
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, SalesHeader."Amount Including VAT", '');
        // [When] Chose order with prepayment
        POSActionDocPrepayB.CreatePrepaymentRefundLine(possession, salesHeader, false, false, false, false, POSSalesDocumentPost);
        // [Then]
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS."Sales Document Prepay. Refund" = true, 'Prepayment Refund set');
        Assert.IsTrue(SaleLinePOS."Sales Document No." = SalesHeader."No.", 'Order Set');
        Assert.IsTrue(SaleLinePOS.Description = StrSubstNo(PREPAYMENT_REFUND, SalesHeader."Document Type", SalesHeader."No."), 'Description Prepayment Refund');
    end;

    procedure CreateSalesOrder(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
    end;

    local procedure CheckSalesReceivableSetup()
    begin
        SalesSetup.Get();
        If SalesSetup."Posted Prepmt. Inv. Nos." = '' then begin
            SalesSetup."Posted Prepmt. Inv. Nos." := LibraryERM.CreateNoSeriesCode();
            SalesSetup.Modify();
        end;
    end;

    local procedure CheckPrepmtAccNo()
    var
        VATPostSetup: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        IF GeneralPostingSetup.Get(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
            IF GeneralPostingSetup."Sales Prepayments Account" = '' then begin
                LibraryERM.CreateGLAccount(GLAccount);
                GLAccount.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                if GLAccount."VAT Prod. Posting Group" = '' then
                    GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                GLAccount.Modify();
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
        if not VATPostSetup.Get(Customer."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group") then
            LibraryERM.CreateVATPostingSetup(VATPostSetup, Customer."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
    end;
}
