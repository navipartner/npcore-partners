codeunit 85079 "NPR POS Act. Doc. Prepay Tests"
{
    Subtype = Test;

    var
        Item: Record Item;
        Customer: Record Customer;
        POSPaymentMethodCash: Record "NPR POS Payment Method";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        LibraryERM: Codeunit "Library - ERM";
        Initialized: Boolean;
        LibrarySales: Codeunit "Library - Sales";

    [Test]
    internal procedure CreatePrepaymentLineWithMaxPrepaymentValue()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        AutoQtyOpt: Option Disabled,None,All;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        PrepaymentValue: Decimal;
        ValueIsAmount: Boolean;
        LibraryRandom: Codeunit "Library - Random";
        PREPAYMENT: Label 'Prepayment of %1 %2';
        ExpectedPrepayAmt: Decimal;
    begin
        // [Scenario] Create prepayment for existing order, prepayment amount is value
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSalesOrder(SalesHeader); //Sales Order With with one line

        POSSale.GetCurrentSale(SalePOS);
        SalesHeader.CalcFields("Amount Including VAT");
        // parameters
        PrepaymentValue := SalesHeader."Amount Including VAT" + 1;
        ValueIsAmount := true;
        // [When]
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentValue, ValueIsAmount, false, false);
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
    internal procedure CreatePrepaymentLineWithPrepaymentPrc()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        AutoQtyOpt: Option Disabled,None,All;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        PrepaymentValue: Decimal;
        ValueIsAmount: Boolean;
        LibraryRandom: Codeunit "Library - Random";
        PREPAYMENT: Label 'Prepayment of %1 %2';
        ExpectedPrepayAmt: Decimal;
    begin
        // [Scenario] Create prepayment for existing order, prepayment amount is in percentage
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSalesOrder(SalesHeader); //Sales Order With with one line

        POSSale.GetCurrentSale(SalePOS);
        SalesHeader.CalcFields("Amount Including VAT");
        // parameters
        PrepaymentValue := LibraryRandom.RandDecInRange(0, 100, 4);
        ValueIsAmount := true;
        // [When]
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentValue, ValueIsAmount, false, false);
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
    internal procedure CreatePrepaymentLineWithPrepaymentAmt()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        AutoQtyOpt: Option Disabled,None,All;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        PrepaymentValue: Decimal;
        ValueIsAmount: Boolean;
        LibraryRandom: Codeunit "Library - Random";
        ExpectedPrepayAmt: Decimal;
        PREPAYMENT: Label 'Prepayment of %1 %2';
    begin
        // [Scenario] Create prepayment for existing order, prepayment amount is value
        // [Given]
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateSalesOrder(SalesHeader); //Sales Order With with one line

        POSSale.GetCurrentSale(SalePOS);
        SalesHeader.CalcFields("Amount Including VAT");
        // parameters
        PrepaymentValue := 100;
        ValueIsAmount := true;
        // [When]
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentValue, ValueIsAmount, false, false);
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
        VATPostSetup: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
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
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethodCash, POSPaymentMethodCash."Processing Type"::CASH, '', false);
            LibrarySales.CreateCustomer(Customer);
            IF GeneralPostingSetup.Get(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                IF GeneralPostingSetup."Sales Prepayments Account" = '' then begin
                    LibraryERM.CreateGLAccount(GLAccount);
                    GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                    GLAccount.Modify();
                    IF not VATPostSetup.Get(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                        LibraryERM.CreateVATPostingSetup(VATPostSetup, Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
                    GeneralPostingSetup.Validate("Sales Prepayments Account", GLAccount."No.");
                    GeneralPostingSetup.Modify();
                end else begin
                    GLAccount.Get(GeneralPostingSetup."Sales Prepayments Account");
                    if GLAccount."VAT Prod. Posting Group" = '' then begin
                        GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                        GLAccount.Modify();
                    end
                end;

            Initialized := true;
        end;

        Commit();
    end;

    procedure CreateSalesOrder(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
    end;
}
