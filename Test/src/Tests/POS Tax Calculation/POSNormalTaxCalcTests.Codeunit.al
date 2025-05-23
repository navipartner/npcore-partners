codeunit 85035 "NPR POS Normal Tax Calc. Tests"
{
    // // [Feature] POS Active Normal and Reverse Charge Tax Calculation
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = TableData "G/L Entry" = rimd,
                  TableData "VAT Entry" = rimd;

    trigger OnRun()
    begin
        Initialized := false;
    end;

    var
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryTaxCalc: Codeunit "NPR POS Lib. - Tax Calc.";
        Initialized: Boolean;
        CreatedSalesOrderNo: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleNormalVATLineDiscountManualPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        exit; //TODO: [Test result: FAIL] Fixing in progress
        // [SCENARIO] Verify Tax Calculation has been posted backward for debit sale with tax calculation type set as normal vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SkipTaxCalcForwardForZeroAmountDebitSaleNormalVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesPOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] POS Tax Amount calculation is skipped if amount on active sale is equal to zero

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalesPOS);
        SelectCustomerAction.AttachCustomer(SalesPOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price 0
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := 0;
        Item.Modify();

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify POS Active Tax Amount Calculation has not been created
        VerifyPOSTaxAmountCalculationNotCreated();

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SkipTaxCalcForwardForZeroAmountInclTaxDebitSaleNormalVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesPOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] POS Tax Amount calculation is skipped if amount on active sale is equal to zero

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalesPOS);
        SelectCustomerAction.AttachCustomer(SalesPOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price 0
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := 0;
        Item.Modify();

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify POS Active Tax Amount Calculation has not been created
        VerifyPOSTaxAmountCalculationNotCreated();

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDirectSaleNormalVAT()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        //Forward direct sale for normal vat is not possbile due to Tax Type setup on POS View Profile
        exit;

        // [SCENARIO] Verify Tax Calculation has been created forward for direct sale with tax calculation type set as normal vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [WHEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcForward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceForward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleNormalVAT()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for direct sale with tax calculation type set as normal vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleNormalVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        SalesPOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] Verify Tax Calculation has been created forward for debit sale with tax calculation type set as normal vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalesPOS);
        SelectCustomerAction.AttachCustomer(SalesPOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcForward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceForward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleNormalVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for debit sale with tax calculation type set as normal vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell withtout discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleNormalVATLineDiscountManual()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for direct sale with tax calculation type set as normal vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithLineDiscount(POSSaleTaxLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleNormalVATLineDiscountManual()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for debit sale with tax calculation type set as normal vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcForward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithLineDiscount(POSSaleTaxLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceForward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleNormalVATLineDiscountManual()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesPOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for debit sale with tax calculation type set as normal vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalesPOS);
        SelectCustomerAction.AttachCustomer(SalesPOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with Unit Price    
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithLineDiscount(POSSaleTaxLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleNormalVATPosted()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for direct sale with tax calculation type set as normal vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleNormalVATPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted forward for debit sale with tax calculation type set as normal vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);



        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleNormalVATPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for debit sale with tax calculation type set as normal vat
        // Note: Calculation is done for specific cases:
        //   VAT %: 16
        //   Unit Price: 29.90512

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 16;
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);



        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := 29.90512;//LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell withtout discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleNormalVATLineDiscountManualPosted()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for direct sale with tax calculation type set as normal vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleNormalVATLineDiscountManualPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for debit sale with tax calculation type set as normal vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with Unit Price    
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 10;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, VATPostingSetup."VAT %", LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);


        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SkipTaxCalcForwardForZeroAmountDebitSaleReverseVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        LibraryERM: Codeunit "Library - ERM";
    begin
        // [SCENARIO] POS Tax Amount calculation is skipped if amount on active sale is equal to zero

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."Reverse Chrg. VAT Acc." := LibraryERM.CreateGLAccountNo();
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := 0;
        Item.Modify();
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify POS Active Tax Amount Calculation has not been created
        VerifyPOSTaxAmountCalculationNotCreated();

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SkipTaxCalcForwardForZeroAmountInclTaxDebitSaleReverseVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        LibraryERM: Codeunit "Library - ERM";
    begin
        //[SCENARIO] POS Tax Amount calculation is skipped if amount on active sale is equal to zero

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        VATPostingSetup."Reverse Chrg. VAT Acc." := LibraryERM.CreateGLAccountNo();
        VATPostingSetup.Modify();
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Add Item to active sale
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := 0;
        Item.Modify();
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify POS Active Tax Amount Calculation has not been created
        VerifyPOSTaxAmountCalculationNotCreated();

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleReverseVAT()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for direct sale with tax calculation type set as reverse charge vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleReverseVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created forward for debit sale with tax calculation type set as reverse charge vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcForward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceForward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleReverseVAT()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for debit sale with tax calculation type set as reverse charge vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell withtout discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleReverseVATLineDiscountManual()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for direct sale with tax calculation type set as reverse charge vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithLineDiscount(POSSaleTaxLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleReverseVATLineDiscountManual()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for debit sale with tax calculation type set as reverse charge vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcForward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithLineDiscount(POSSaleTaxLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceForward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleReverseVATLineDiscountManual()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
    begin
        // [SCENARIO] Verify Tax Calculation has been created backward for debit sale with tax calculation type set as reverse charge vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [GIVEN] Item with Unit Price    
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        VerifyTaxLineCalcBackward(TempPOSSaleTaxLine, POSSaleTaxLine);
        VerifyTaxLineCalcWithLineDiscount(POSSaleTaxLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSSaleTaxLine, POSSaleTax);
        VerifyTaxCalcHeaderCopied2Source(POSSaleTax, SaleLinePOS);
        VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleReverseVATPosted()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for direct sale with tax calculation type set as reverse charge vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleReverseVATPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted forward for debit sale with tax calculation type set as reverse charge vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleReverseVATPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for debit sale with tax calculation type set as reverse charge vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);


        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell withtout discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDirectSaleReverseVATLineDiscountManualPosted()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for direct sale with tax calculation type set as reverse charge vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price 
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcForwardForDebitSaleReverseVATLineDiscountManualPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for debit sale with tax calculation type set as reverse charge vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);


        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesForward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyTaxCalcBackwardForDebitSaleReverseVATLineDiscountManualPosted()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line" temporary;
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
        InvDiscAmt: Decimal;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Verify Tax Calculation has been posted backward for debit sale with tax calculation type set as reverse charge vat including discount

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Customer
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Reverse Charge VAT");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);


        // [GIVEN] Item with Unit Price    
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // Quantity to sell with line discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);
        InvDiscAmt := 0;

        //Store random decimal values in temporary record
        SetRandomValuesBackward(TempPOSSaleTaxLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [GIVEN] Add Item to active sale
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", Qty, LineDiscPct);

        // [GIVEN] Get amount to pay for active sale
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);

        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        VerifySingleTaxLineCalculation(POSSaleTaxLine, POSSaleTax);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify tax calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifySingleTaxLineCalculation(POSPostedTaxAmountLine, POSEntry);
        VerifyActiveTaxCalcCopied2PostedTaxCalc(POSSaleTaxLine, POSPostedTaxAmountLine);
        VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine, POSEntry);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;



    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);

        if not Initialized then begin
            LibraryTaxCalc.BindNormalTaxCalcTest();
            LibraryApplicationArea.EnableVATSetup();
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            DeletePOSPostedEntries();

            Initialized := true;
        end;

        Commit();
    end;

    local procedure DeletePOSPostedEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
    begin
        //Just in case if performance test is created and run on test company for POS test unit
        //then POS posting is terminated because POS entries are stored in database with sales tickect no.
        //defined in the Library POS Master Data 
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        VATEntry.DeleteAll();
        GLEntry.DeleteAll();
    end;

    local procedure CreateCustomer(var Customer: Record Customer; PricesIncludingTax: Boolean)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        Customer."Prices Including VAT" := PricesIncludingTax;
        Customer.Modify();
    end;

    local procedure CreatePOSViewProfile(var POSViewProfile: Record "NPR POS View Profile"; PricesIncludingTax: Boolean)
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        if PricesIncludingTax then
            POSViewProfile."Show Prices Including VAT" := PricesIncludingTax
        else
            Error('For other Sales Tax Type use test unit POSSalesTaxCalcTests.Codeunit.al');
        POSViewProfile.Modify();
    end;

    local procedure AssignPOSViewProfileToPOSUnit(POSViewProfileCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(POSUnit, POSViewProfileCode);
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; TaxCaclType: Enum "NPR POS Tax Calc. Type")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryTaxCalc2.CreateTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, TaxCaclType);
    end;

    local procedure AssignVATBusPostGroupToPOSPostingProfile(VATBusPostingGroupCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATBusPostGroupToPOSPostingProfile(POSStore, VATBusPostingGroupCode);
    end;

    local procedure AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup: Record "VAT Posting Setup")
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATPostGroupToPOSSalesRoundingAcc(POSStore, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure CreateItem(var Item: Record Item; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; PricesIncludesVAT: Boolean)
    var
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
    begin
        LibraryTaxCalc2.CreateItem(Item, VATProdPostingGroupCode, VATBusPostingGroupCode);
        Item."Price Includes VAT" := PricesIncludesVAT;
        Item.Modify();
        CreateGeneralPostingSetupForItem(Item);
    end;

    local procedure CreateGeneralPostingSetupForItem(Item: Record Item)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        POSStore.GetProfile(POSPostingProfile);
        LibraryPOSMasterData.CreateGeneralPostingSetupForSaleItem(
                                        POSPostingProfile."Gen. Bus. Posting Group",
                                        Item."Gen. Prod. Posting Group",
                                        POSStore."Location Code",
                                        Item."Inventory Posting Group");
    end;

    local procedure VerifyPOSTaxAmountCalculationNotCreated()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsFalse(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Active Tax Calculation created');
        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        Assert.IsTrue(POSSaleTaxLine.IsEmpty(), 'POS Active Tax Amount Lines created');
    end;

    local procedure VerifySourceIsCopiedToPOSTaxAmtCalc(SaleLinePOS: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        Assert.AreEqual(SaleLinePOS."Price Includes VAT", POSSaleTax."Source Prices Including Tax", 'Source Prices Including Tax not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS.Date, POSSaleTax."Source Posting Date", 'Source Date not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."Quantity (Base)", POSSaleTax."Source Quantity (Base)", 'Source Quantity (Base) not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS.Quantity, POSSaleTax."Source Quantity", 'Source Quantity not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."Unit Price", POSSaleTax."Source Unit Price", 'Source Unit Price not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."Currency Code", POSSaleTax."Source Currency Code", 'Source Currency Code not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."VAT Identifier", POSSaleTax."Source Tax Identifier", 'Source VAT Identifier not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."VAT %", POSSaleTax."Source Tax %", 'Source VAT % not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."Allow Line Discount", POSSaleTax."Source Allow Line Discount", 'Source Allow Line Discount not copied to tax calculation');
    end;

    local procedure VerifySourceAmountsAreCopiedToPOSTaxAmtCalc(SaleLinePOS: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        Assert.AreEqual(SaleLinePOS."Discount %", POSSaleTax."Source Prices Including Tax", 'Source Discount % not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."Discount Amount", POSSaleTax."Source Posting Date", 'Source Discount Amount not copied to tax calculation');
        Assert.AreEqual(SaleLinePOS."Line Amount", POSSaleTax."Source Line Amount", 'Source Line Amount not copied to tax calculation');
    end;

    local procedure VerifySourceAmountsAreCopiedToForwardPOSTaxAmtCalc(SaleLinePOS: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        Assert.AreEqual(SaleLinePOS.Amount, POSSaleTax."Source Amount", 'Source Amount Including VAT not copied to tax calculation');
    end;

    local procedure VerifySourceAmountsAreCopiedToBackwardPOSTaxAmtCalc(SaleLinePOS: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", POSSaleTax."Source Amount", 'Source Amount Including VAT not copied to tax calculation');
    end;

    local procedure VerifyHeaderCopied2Line(POSSaleTax: Record "NPR POS Sale Tax"; POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    begin
        Assert.AreEqual(POSSaleTax."Source Quantity (Base)", POSSaleTaxLine."Quantity (Base)", 'Quantity (Base) not copied to tax calculation line from header');
        Assert.AreEqual(POSSaleTax."Source Quantity", POSSaleTaxLine.Quantity, 'Quantity not copied to tax calculation line from header');
        Assert.AreEqual(POSSaleTax."Source Line Amount", POSSaleTaxLine."Line Amount", 'Line Amount not copied to tax calculation line from header');
        Assert.AreEqual(POSSaleTax."Source Discount Amount", POSSaleTaxLine."Discount Amount", 'Discount Amount not copied to tax calculation line from header');
        Assert.AreEqual(POSSaleTax."Source Posting Date", POSSaleTaxLine."Posting Date", 'Posting Date not copied to tax calculation line from header');
        Assert.AreEqual(POSSaleTax."Source Tax Calc. Type", POSSaleTaxLine."Tax Calc. Type", 'Tax Calculation Type not copied to tax calculation line from header');
        Assert.AreEqual(POSSaleTax."Source Currency Code", POSSaleTaxLine."Currency Code", 'Currency Code not copied to tax calculation line from header');
        Assert.AreEqual(POSSaleTax."Source Allow Line Discount", POSSaleTaxLine."Allow Line Discount", 'Allow Line Discount not copied to tax calculation line from header');
    end;

    local procedure VerifyHeaderCopied2LineForward(POSSaleTax: Record "NPR POS Sale Tax"; POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    begin
        Assert.AreEqual(POSSaleTax."Source Unit Price", POSSaleTaxLine."Unit Price Excl. Tax", 'Unit Price not copied to tax calculation line from header');
    end;

    local procedure VerifyHeaderCopied2LineBackward(POSSaleTax: Record "NPR POS Sale Tax"; POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    begin
        Assert.AreEqual(POSSaleTax."Source Unit Price", POSSaleTaxLine."Unit Price Incl. Tax", 'Unit Price not copied to tax calculation line from header')
    end;

    local procedure VerifyTaxLineCalcForward(var TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    var
        Currency: Record Currency;
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.GetCurrency(Currency, POSSaleTaxLine."Currency Code");

        TempPOSSaleTaxLine."Amount Excl. Tax" := TempPOSSaleTaxLine."Unit Price Excl. Tax" * TempPOSSaleTaxLine.Quantity - TempPOSSaleTaxLine."Discount Amount";
        TempPOSSaleTaxLine."Amount Incl. Tax" := TempPOSSaleTaxLine."Amount Excl. Tax" * (1 + TempPOSSaleTaxLine."Tax %" / 100);
        TempPOSSaleTaxLine."Tax Amount" := TempPOSSaleTaxLine."Amount Incl. Tax" - TempPOSSaleTaxLine."Amount Excl. Tax";

        TempPOSSaleTaxLine."Amount Excl. Tax" := Round(TempPOSSaleTaxLine."Amount Excl. Tax", Currency."Amount Rounding Precision");
        TempPOSSaleTaxLine."Amount Incl. Tax" := Round(TempPOSSaleTaxLine."Amount Incl. Tax", Currency."Amount Rounding Precision");
        TempPOSSaleTaxLine."Tax Amount" := Round(TempPOSSaleTaxLine."Tax Amount", Currency."Amount Rounding Precision");
        TempPOSSaleTaxLine."Unit Price Excl. Tax" := Round(TempPOSSaleTaxLine."Unit Price Excl. Tax", Currency."Unit-Amount Rounding Precision");

        //After tax line rounding is performed for some specific cases like in test procedure VerifyTaxCalcBackwardForDebitSaleNormalVATPosted()
        //deviation is possible.
        //TempPOSSaleTaxLine store original values aka Source Amount values stored in Tax Amount Caclulation before actual tax calculation is performed
        //while values calculated on Tax Amount Calculation Line store line rounded amounts
        Assert.IsTrue(Abs(TempPOSSaleTaxLine."Amount Excl. Tax" - POSSaleTaxLine."Amount Excl. Tax") <= 0.01, 'Deviation between calculated amount excluding tax and source amount excluding tax is higher then 0.01');
        Assert.AreEqual(POSSaleTaxLine."Amount Excl. Tax", POSSaleTaxLine."Line Amount", 'Calculated amounts excluding tax and line amount are not equal');
        Assert.IsTrue(Abs(TempPOSSaleTaxLine."Amount Incl. Tax" - POSSaleTaxLine."Amount Incl. Tax") <= 0.01, 'Deviation between calculated amount including tax and source amount including tax is higher then 0.01');
        Assert.IsTrue(Abs(TempPOSSaleTaxLine."Tax Amount" - POSSaleTaxLine."Tax Amount") <= 0.01, 'Deviation between calculated tax amount and source tax amount is higher then 0.01');

        Assert.AreEqual(TempPOSSaleTaxLine."Unit Price Excl. Tax", POSSaleTaxLine."Unit Price Excl. Tax", 'Calculated price excluding tax is not correct');
    end;

    local procedure VerifyTaxLineCalcBackward(var TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    var
        Currency: Record Currency;
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.GetCurrency(Currency, POSSaleTaxLine."Currency Code");

        TempPOSSaleTaxLine."Amount Incl. Tax" := TempPOSSaleTaxLine."Unit Price Incl. Tax" * TempPOSSaleTaxLine.Quantity - TempPOSSaleTaxLine."Discount Amount";
        TempPOSSaleTaxLine."Amount Excl. Tax" := TempPOSSaleTaxLine."Amount Incl. Tax" / (1 + POSSaleTaxLine."Tax %" / 100);
        TempPOSSaleTaxLine."Tax Amount" := TempPOSSaleTaxLine."Amount Incl. Tax" - TempPOSSaleTaxLine."Amount Excl. Tax";

        TempPOSSaleTaxLine."Amount Incl. Tax" := Round(TempPOSSaleTaxLine."Amount Incl. Tax", Currency."Amount Rounding Precision");
        TempPOSSaleTaxLine."Amount Excl. Tax" := Round(TempPOSSaleTaxLine."Amount Excl. Tax", Currency."Amount Rounding Precision");
        TempPOSSaleTaxLine."Tax Amount" := Round(TempPOSSaleTaxLine."Tax Amount", Currency."Amount Rounding Precision");
        TempPOSSaleTaxLine."Unit Price Incl. Tax" := Round(TempPOSSaleTaxLine."Unit Price Incl. Tax", Currency."Unit-Amount Rounding Precision");

        //After tax line rounding is performed for some specific cases like in test procedure VerifyTaxCalcBackwardForDebitSaleNormalVATPosted()
        //deviation is possible.
        //TempPOSSaleTaxLine store original values aka Source Amount values stored in Tax Amount Caclulation before actual tax calculation is performed
        //while values calculated on Tax Amount Calculation Line store line rounded amounts
        Assert.IsTrue(Abs(TempPOSSaleTaxLine."Amount Incl. Tax" - POSSaleTaxLine."Amount Incl. Tax") <= 0.01, 'Deviation between calculated amount including tax and source amount including tax is higher then 0.01');
        Assert.AreEqual(POSSaleTaxLine."Amount Incl. Tax", POSSaleTaxLine."Line Amount", 'Calculated amount including tax and line amount are not equal');

        Assert.IsTrue(Abs(TempPOSSaleTaxLine."Amount Excl. Tax" - POSSaleTaxLine."Amount Excl. Tax") <= 0.01, 'Deviation between calculated amount excluding tax and source amount excluding tax is higher then 0.01');
        Assert.IsTrue(Abs(TempPOSSaleTaxLine."Tax Amount" - POSSaleTaxLine."Tax Amount") <= 0.01, 'Deviation between calculated tax amount and source tax amount is higher then 0.01');
        Assert.AreEqual(TempPOSSaleTaxLine."Unit Price Incl. Tax", POSSaleTaxLine."Unit Price Incl. Tax", 'Calculated prices including tax are not equal');
    end;

    local procedure VerifyTaxLineCalcWithoutDiscount(POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    begin
        Assert.IsFalse(POSSaleTaxLine."Applied Line Discount", 'Line Disocunt applied');
        Assert.AreEqual(0, POSSaleTaxLine."Discount %", 'Active Tax Line Discount % is not equal to zero');
        Assert.AreEqual(0, POSSaleTaxLine."Discount Amount", 'Active Tax Line Discount Amount is not equal to zero');

    end;

    local procedure VerifyTaxLineCalcWithLineDiscount(POSSaleTaxLine: Record "NPR POS Sale Tax Line"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Assert.IsTrue(POSSaleTaxLine."Applied Line Discount", 'Line Disocunt not applied');
        Assert.AreEqual(SaleLinePOS."Discount %", POSSaleTaxLine."Discount %", 'Active Tax Line Discount % is not equal to source discount %');
        Assert.AreEqual(SaleLinePOS."Discount Amount", POSSaleTaxLine."Discount Amount", 'Active Tax Line Discount Amount is not equal to source discount amount');
    end;

    local procedure VerifyTaxLineCalcWithDiscount(POSSaleTaxLine: Record "NPR POS Sale Tax Line"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Assert.IsTrue(POSSaleTaxLine."Applied Line Discount", 'Line Disocunt not applied');
        Assert.AreEqual(SaleLinePOS."Discount %", POSSaleTaxLine."Discount %", 'Active Tax Line Discount % is not equal to source discount %');
        Assert.AreEqual(SaleLinePOS."Discount Amount", POSSaleTaxLine."Discount Amount", 'Active Tax Line Discount Amount is not equal to source discount amount');
    end;

    local procedure VerifyTaxCalcLineCopied2Header(POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        Assert.AreEqual(POSSaleTaxLine."Unit Price Excl. Tax", POSSaleTax."Calculated Price Excl. Tax", 'Calculated unit prices excluding tax not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Unit Tax", POSSaleTax."Calculated Unit Tax", 'Calculated unit taxes not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Unit Price Incl. Tax", POSSaleTax."Calculated Price Incl. Tax", 'Calculated unit prices including tax not equal on line and header');

        Assert.AreEqual(POSSaleTaxLine."Amount Excl. Tax", POSSaleTax."Calculated Amount Excl. Tax", 'Calculated amounts excluding tax not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Tax Amount", POSSaleTax."Calculated Tax Amount", 'Calculated tax amounts not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Amount Incl. Tax", POSSaleTax."Calculated Amount Incl. Tax", 'Calculated amounts including tax not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Tax %", POSSaleTax."Calculated Tax %", 'Calculated tax % not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Line Amount", POSSaleTax."Calculated Line Amount", 'Calculated line amounts not equal on line and header');

        Assert.AreEqual(POSSaleTaxLine."Applied Line Discount", POSSaleTax."Calc. Applied Line Discount", 'Calculated applied line discounts not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Discount %", POSSaleTax."Calculated Discount %", 'Calculated discount % not equal on line and header');
        Assert.AreEqual(POSSaleTaxLine."Discount Amount", POSSaleTax."Calculated Discount Amount", 'Calculated discount amounts not equal on line and header');
    end;

    local procedure VerifyTaxCalcHeaderCopied2Source(POSSaleTax: Record "NPR POS Sale Tax"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Assert.AreEqual(POSSaleTax."Calculated Discount %", SaleLinePOS."Discount %", 'Calculated discounts % not equal on header and source');
        Assert.AreEqual(POSSaleTax."Calculated Discount Amount", SaleLinePOS."Discount Amount", 'Calculated discount amounts not equal on header and source');

        Assert.AreEqual(POSSaleTax."Calculated Amount Excl. Tax", SaleLinePOS.Amount, 'Calculated amounts excluding tax are not equal on header and source');
        Assert.AreEqual(SaleLinePOS.Amount, SaleLinePOS."VAT Base Amount", 'Amount and VAT Base Amount are not equal on header and source');
        Assert.AreEqual(POSSaleTax."Calculated Amount Incl. Tax", SaleLinePOS."Amount Including VAT", 'Calculated amounts including tax are not equal on header and source');
        Assert.AreEqual(POSSaleTax."Calculated Tax %", SaleLinePOS."VAT %", 'Tax percents are not equal on header and source');
    end;

    local procedure VerifyTaxCalcHeaderCopied2SourceForward(POSSaleTax: Record "NPR POS Sale Tax"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Assert.AreEqual(POSSaleTax."Calculated Amount Excl. Tax", SaleLinePOS.Amount, 'Calculated line amounts are not equal on header and source');
    end;

    local procedure VerifyTaxCalcHeaderCopied2SourceBackward(POSSaleTax: Record "NPR POS Sale Tax"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Assert.AreEqual(POSSaleTax."Calculated Amount Incl. Tax", SaleLinePOS."Amount Including VAT", 'Calculated line amounts are not equal on header and source');
    end;

    local procedure VerifyActiveTaxCalcCopied2PostedTaxCalc(var POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line")
    begin
        Assert.AreEqual(POSSaleTaxLine."Tax Identifier", POSPostedTaxAmountLine."VAT Identifier", 'VAT Identifier not posted from active to posted tax line');
        Assert.IsTrue(POSPostedTaxAmountLine."Tax Type" = POSPostedTaxAmountLine."Tax Type"::"Use Tax Only", 'Tax Type not posted as an Use Tax Only to posted tax line');
        Assert.AreEqual(POSSaleTaxLine.Positive, POSPostedTaxAmountLine.Positive, 'Positive not posted from active to posted tax line');
        Assert.AreEqual(POSSaleTaxLine."Tax Calculation Type", POSPostedTaxAmountLine."Tax Calculation Type", 'Tax Calculation Type not posted from active to posted tax line');
        Assert.AreEqual(POSSaleTaxLine.Quantity, POSPostedTaxAmountLine.Quantity, 'Quantity not posted from active to posted tax line');

        Assert.AreEqual(POSSaleTaxLine."Amount Excl. Tax", POSPostedTaxAmountLine."Tax Base Amount", 'Tax Base Amount not posted from active Amount Excl. Tax calculation');
        Assert.AreEqual(POSSaleTaxLine."Amount Excl. Tax", POSPostedTaxAmountLine."Tax Base Amount FCY", 'Tax Base Amount FCY not posted from active Amount Excl. Tax calculation');
        Assert.AreEqual(POSSaleTaxLine."Line Amount", POSPostedTaxAmountLine."Amount Including Tax", 'Line Amount not posted from active tax line amount');
        Assert.AreEqual(POSSaleTaxLine."Amount Incl. Tax", POSPostedTaxAmountLine."Amount Including Tax", 'Amount Including Tax not posted from active Amount Incl. Tax calculation');
        Assert.AreEqual(POSSaleTaxLine."Tax %", POSPostedTaxAmountLine."Tax %", 'Tax % not posted from active to posted tax line');

        Assert.AreEqual(POSSaleTaxLine."Tax Amount", POSPostedTaxAmountLine."Calculated Tax Amount", 'Calculated tax amount not posted from active Tax Amount calculation');
        Assert.AreEqual(POSSaleTaxLine."Tax Amount", POSPostedTaxAmountLine."Tax Amount", 'Tax amount not posted from active Tax Amount calculation');
    end;

    local procedure VerifyPostedTaxCalcCopied2Entries(POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; POSEntry: Record "NPR POS Entry")
    begin
        Assert.AreEqual(POSPostedTaxAmountLine.Quantity, POSEntry."Sales Quantity", 'POSPostedTaxAmountLine."Tax Base Amount" <> POSEntry."Amount Excl. Tax"');
        Assert.AreEqual(POSPostedTaxAmountLine."Tax Base Amount", POSEntry."Amount Excl. Tax", 'POSPostedTaxAmountLine."Tax Base Amount" <> POSEntry."Amount Excl. Tax"');
        Assert.AreEqual(POSPostedTaxAmountLine."Amount Including Tax", POSEntry."Amount Incl. Tax", 'POSPostedTaxAmountLine."Amount Including Tax" <> POSEntry."Amount Excl. Tax"');
        Assert.AreEqual(POSPostedTaxAmountLine."Tax Amount", POSEntry."Tax Amount", 'POSPostedTaxAmountLine."Tax Amount" <> POSEntry."Tax Amount"');
        Assert.AreEqual(POSPostedTaxAmountLine."Calculated Tax Amount", POSEntry."Tax Amount", 'POSPostedTaxAmountLine."Calculated Tax Amount" <> POSEntry."Tax Amount"');
    end;

    local procedure SetRandomValuesForward(var TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line"; Item: Record Item; Qty: Decimal; TaxPct: Decimal; LineDisc: Decimal; LineDiscPct: Decimal)
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Currency: Record Currency;
    begin
        POSSaleTaxCalc.GetCurrency(Currency, TempPOSSaleTaxLine."Currency Code");

        if Item."Price Includes VAT" then
            TempPOSSaleTaxLine."Unit Price Excl. Tax" := Round(Item."Unit Price" / (1 + TaxPct / 100), Currency."Unit-Amount Rounding Precision")
        else
            TempPOSSaleTaxLine."Unit Price Excl. Tax" := Item."Unit Price";
        TempPOSSaleTaxLine.Quantity := Qty;
        TempPOSSaleTaxLine."Tax %" := TaxPct;

        case true of
            LineDiscPct <> 0:
                begin
                    TempPOSSaleTaxLine."Discount %" := LineDiscPct;
                    TempPOSSaleTaxLine."Discount Amount" := Round(TempPOSSaleTaxLine."Unit Price Excl. Tax" * TempPOSSaleTaxLine.Quantity * TempPOSSaleTaxLine."Discount %" / 100, Currency."Amount Rounding Precision");
                end;
            LineDisc <> 0:
                begin
                    TempPOSSaleTaxLine."Discount Amount" := Round(LineDisc, Currency."Amount Rounding Precision");
                    TempPOSSaleTaxLine."Discount %" := TempPOSSaleTaxLine."Discount Amount" * 100 / TempPOSSaleTaxLine."Unit Price Excl. Tax" * TempPOSSaleTaxLine.Quantity;
                end;
        end;

        TempPOSSaleTaxLine."Allow Line Discount" := (TempPOSSaleTaxLine."Discount Amount" > 0) or (TempPOSSaleTaxLine."Discount %" > 0);
    end;

    local procedure SetRandomValuesBackward(var TempPOSSaleTaxLine: Record "NPR POS Sale Tax Line"; Item: Record Item; Qty: Decimal; TaxPct: Decimal; LineDisc: Decimal; LineDiscPct: Decimal)
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Currency: Record Currency;
    begin
        POSSaleTaxCalc.GetCurrency(Currency, TempPOSSaleTaxLine."Currency Code");
        if not Item."Price Includes VAT" then
            TempPOSSaleTaxLine."Unit Price Incl. Tax" := Item."Unit Price" * (1 + TaxPct / 100)
        else
            TempPOSSaleTaxLine."Unit Price Incl. Tax" := Item."Unit Price";
        TempPOSSaleTaxLine.Quantity := Qty;
        TempPOSSaleTaxLine."Tax %" := TaxPct;
        TempPOSSaleTaxLine."Discount Amount" := LineDisc;

        case true of
            LineDiscPct <> 0:
                begin
                    TempPOSSaleTaxLine."Discount %" := LineDiscPct;
                    //Debit sale
                    //Double rounding is set on Line Discount Amount in TAB 37 Sales Line
                    TempPOSSaleTaxLine."Discount Amount" := Round(Round(TempPOSSaleTaxLine."Unit Price Incl. Tax" * TempPOSSaleTaxLine.Quantity, Currency."Amount Rounding Precision") * TempPOSSaleTaxLine."Discount %" / 100, Currency."Amount Rounding Precision");
                end;
            LineDisc <> 0:
                begin
                    TempPOSSaleTaxLine."Discount Amount" := Round(LineDisc, Currency."Amount Rounding Precision");
                    TempPOSSaleTaxLine."Discount %" := TempPOSSaleTaxLine."Discount Amount" * 100 / TempPOSSaleTaxLine."Unit Price Incl. Tax" * TempPOSSaleTaxLine.Quantity;
                end;
        end;

        TempPOSSaleTaxLine."Allow Line Discount" := (TempPOSSaleTaxLine."Discount Amount" > 0) or (TempPOSSaleTaxLine."Discount %" > 0);
    end;

    local procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; Customer: Record Customer; Item: Record Item; Qty: Decimal; LineDiscPct: Decimal)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, Customer."No.");
        SalesHeader.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", Qty);
        SalesLine.Validate("Line Discount %", LineDiscPct);
        CreatedSalesOrderNo := SalesHeader."No.";
    end;

    local procedure VerifySingleTaxLineCalculation(var POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        Assert.IsFalse(POSSaleTaxLine.IsEmpty(), 'POS Active Tax Amount Lines not created');
        Assert.AreEqual(1, POSSaleTaxLine.Count(), 'More then one tax amount line is created');
        POSSaleTaxLine.FindFirst();
    end;

    local procedure VerifySingleTaxLineCalculation(var POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; POSEntry: Record "NPR POS Entry")
    var
        POSPostedTaxCalc: codeunit "NPR POS Entry Tax Calc.";
    begin
        POSPostedTaxCalc.FilterLines(POSEntry."Entry No.", POSPostedTaxAmountLine);
        Assert.IsFalse(POSPostedTaxAmountLine.IsEmpty(), 'POS Tax Amount Lines not posted');
        Assert.AreEqual(1, POSPostedTaxAmountLine.Count(), 'More then one tax amount line is posted');
        POSPostedTaxAmountLine.FindFirst();
    end;

    local procedure ClearSalesOrder()
    begin
        CreatedSalesOrderNo := ''
    end;

    local procedure GetAmountToPay(SaleLinePOS: Record "NPR POS Sale Line"): Decimal
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AmountToPay: Decimal;
    begin
        POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId);
        AmountToPay := POSSaleTax."Calculated Amount Incl. Tax";
        AmountToPay := Round(AmountToPay, 1, '>');
        exit(AmountToPay);
    end;

    local procedure VerifyPostedTaxCalcCopied2VATEntries(var POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; POSEntry: Record "NPR POS Entry")
    var
        VAtEntry: Record "VAT Entry";
    begin
        VAtEntry.SetRange("Document No.", POSEntry."Document No.");
        VAtEntry.SetRange("Posting Date", POSEntry."Posting Date");
        Assert.IsFalse(VAtEntry.IsEmpty(), 'VAT Entry not created');

        VAtEntry.CalcSums(Amount);
        POSPostedTaxAmountLine.CalcSums("Tax Amount", "Calculated Tax Amount");

        Assert.AreEqual(-POSPostedTaxAmountLine."Tax Amount", VAtEntry.Amount, 'POSPostedTaxAmountLine."Tax Amount" <> VAtEntry.Amount');
        Assert.AreEqual(-POSPostedTaxAmountLine."Calculated Tax Amount", VAtEntry.Amount, 'POSPostedTaxAmountLine."Calculated Tax Amount" <> VAtEntry.Amount');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Tax", 'OnAfterCopyFromSource', '', true, true)]
    local procedure VerifyOnAfterCopyFromSource(sender: Record "NPR POS Sale Tax"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        VerifySourceIsCopiedToPOSTaxAmtCalc(SaleLinePOS, sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Tax", 'OnAfterCopyFromSourceAmounts', '', true, true)]
    local procedure VerifyOnAfterCopyFromSourceAmounts(sender: Record "NPR POS Sale Tax"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        VerifySourceAmountsAreCopiedToPOSTaxAmtCalc(SaleLinePOS, sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Normal Tax Forward", 'OnBeforeCalculateTaxLines', '', true, true)]
    local procedure VerifyOnBeforeCalculateTaxLinesForward(POSSaleTax: Record "NPR POS Sale Tax"; Rec: Record "NPR POS Sale Line")
    begin
        VerifySourceAmountsAreCopiedToForwardPOSTaxAmtCalc(Rec, POSSaleTax);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Tax Line", 'OnAfterCopyFromHeader', '', true, true)]
    local procedure VerifyOnAfterCopyFromHeaderForward(sender: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        if POSSaleTax."Source Prices Including Tax" then
            exit;
        VerifyHeaderCopied2Line(POSSaleTax, sender);
        VerifyHeaderCopied2LineForward(POSSaleTax, sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Normal Tax Backward", 'OnBeforeCalculateTaxLines', '', true, true)]
    local procedure VerifyOnBeforeCalculateTaxLinesBackward(POSSaleTax: Record "NPR POS Sale Tax"; Rec: Record "NPR POS Sale Line")
    begin
        VerifySourceAmountsAreCopiedToBackwardPOSTaxAmtCalc(Rec, POSSaleTax);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Tax Line", 'OnAfterCopyFromHeader', '', true, true)]
    local procedure VerifyOnAfterCopyFromHeaderBackward(sender: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        if not POSSaleTax."Source Prices Including Tax" then
            exit;
        VerifyHeaderCopied2Line(POSSaleTax, sender);
        VerifyHeaderCopied2LineBackward(POSSaleTax, sender);
    end;
}