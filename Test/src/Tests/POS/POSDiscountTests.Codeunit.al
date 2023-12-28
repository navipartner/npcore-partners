codeunit 85147 "NPR POS Discount Tests"
{
    Subtype = Test;

    var
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        POSPaymentMethodCash: Record "NPR POS Payment Method";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        LibrarySales: Codeunit "Library - Sales";
        Initialized: Boolean;
        LibraryERM: Codeunit "Library - ERM";
        LibraryDim: Codeunit "Library - Dimension";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure UpdateDimensionValue()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemReference: Record "Item Reference";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        DimSetIDLine: Integer;
        OldDimSetIDLine: Integer;
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Apply Dimension Code and Dimension Value
        // [GIVEN] POS & Payment setup
        Initialize();
        LibraryDim.CreateDimension(Dimension);
        LibraryDim.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, SalespersonPurchaser, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, 500, '', '', '');
        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100);
        DiscountType := DiscountType::LineUnitPrice;
        PresetMultiLineDiscTarget := PresetMultiLineDiscTarget::"Positive Only";

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        OldDimSetIDLine := SaleLinePOS."Dimension Set ID";
        //  [WHEN]
        POSActionDiscountB.StoreAdditionalParams('', '', DimensionValue."Dimension Code", DimensionValue.Code, '', InputIncludesTax::Always);
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        //  [THEN]
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        DimSetIDLine := SaleLinePOS."Dimension Set ID";
        //  [THEN]
        Assert.IsTrue(OldDimSetIDLine <> DimSetIDLine, 'Sale Line Dimension Set Id has been changed');
        //  [THEN]
        DimensionSetEntry.SetRange("Dimension Set ID", DimSetIDLine);
        DimensionSetEntry.SetRange("Dimension Code", Dimension.Code);
        DimensionSetEntry.SetRange("Dimension Value Code", DimensionValue.Code);
        Assert.IsTrue(DimensionSetEntry.FindFirst(), 'Dimension Set Id is correct');
        //  [THEN] Try to End Sale
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, SalePOS."Amount Including VAT", '');
        //  [THEN] Sale ended with information on new POS entry
        Assert.IsTrue(SaleEnded, 'Sale ended');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'Sale was moved to POS Entry');
        POSEntry.TestField(SystemId, SalePOS.SystemId);
        //  [THEN]
        Assert.IsTrue(DimSetIDLine <> POSEntry."Dimension Set ID", 'Dimension isn''t transfered to POS Entry according to test');
        //  [THEN]
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("Dimension Set ID", DimSetIDLine);
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'POS Entry Sales Line has good Dimension Set ID');
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', 0); //CleanUp
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure CheckDiscountTypeWithNegativeAmtWithError()
    var
        DiscountAmt: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        NegativeAmtErr: Label 'Negative amount is not allowed. Please specify a positive figure.';
    begin
        // [GIVEN]
        DiscountAmt := LibraryRandom.RandDecInRange(-100, -1, 4);
        DiscountType := DiscountType::TotalAmount;
        // [WHEN]
        asserterror POSActionDiscountB.CheckNegativeAmount(DiscountType, DiscountAmt);
        // [THEN]
        Assert.ExpectedError(NegativeAmtErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyDiscountInInvalidPercentage()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        DiscountPercentError: Label 'Discount percentage must be between 0 and 100.';
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Set invalid discount percentage
        //[GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, SalespersonPurchaser, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandInt(100);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Quantity);
        // Parameters 
        DiscountQuantity := 101;
        DiscountType := DiscountType::DiscountPercentREL;
        PresetMultiLineDiscTarget := PresetMultiLineDiscTarget::All;

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        // [WHEN]
        asserterror POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        Assert.ExpectedError(DiscountPercentError);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyDiscountToWrongTargetLines()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        DiscTargetOtherOptionsLbl: Label 'Positive quantity lines only,Negative quantity lines only';
        NoDiscTargetFound: Label 'System couldn''t find lines the discount to be applied to.\The POS action is preset for discounts to be applied to %1.', Comment = 'Lines Target';
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Discount set to apply on negative lines only.
        // No negative lines in Sale
        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, SalespersonPurchaser, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Quantity);
        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100);
        DiscountType := DiscountType::DiscountPercentREL;
        PresetMultiLineDiscTarget := PresetMultiLineDiscTarget::"Negative Only";

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        // [WHEN]
        asserterror POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        Assert.ExpectedError(StrSubstNo(NoDiscTargetFound, LowerCase(SelectStr(PresetMultiLineDiscTarget, DiscTargetOtherOptionsLbl))));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyTotalDiscountOnlyToNegativeLineQty()
    var
        SalePOS: Record "NPR POS Sale";
        AmountIncVATBeforeDiscount: Decimal;
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSTest: Record "NPR POS Sale Line";
        ItemReference: Record "Item Reference";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Discount set to apply on negative lines only , negative amount is decreased
        //[GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, SalespersonPurchaser, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity * 2, Item."Unit Price", '', '', '');
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, -Quantity, Item."Unit Price", '', '', '');

        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100);
        DiscountType := DiscountType::TotalDiscountAmount;
        PresetMultiLineDiscTarget := PresetMultiLineDiscTarget::"Negative Only";

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        AmountIncVATBeforeDiscount := SalePOS."Amount Including VAT";

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        // [WHEN]
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        Assert.IsTrue(SalePOS."Amount Including VAT" = AmountIncVATBeforeDiscount + DiscountQuantity, 'Amount is set'); // Discount Quantity is positive
        // [THEN]
        SaleLinePOSTest.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSTest.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSTest.SetRange("Line Type", SaleLinePOSTest."Line Type"::Item);
        SaleLinePOSTest.SetFilter(Quantity, '<0');
        SaleLinePOSTest.SetRange("Discount Amount", -DiscountQuantity);
        Assert.IsTrue(SaleLinePOSTest.FindFirst(), 'Discount applied to negative line only');
        // [THEN] 
        SaleLinePOSTest.SetFilter(Quantity, '>0');
        SaleLinePOSTest.SetFilter("Discount Amount", '<>0');
        Assert.IsTrue(SaleLinePOSTest.IsEmpty(), 'Discount isnt'' applied to positive');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyTotalDiscountAmount()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        ItemReference: Record "Item Reference";
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        SaleLinePOSTest: Record "NPR POS Sale Line";
        Amount1: Decimal;
        Amount2: Decimal;
        TotalAmountDisc: Decimal;
        Discount1: Decimal;
        Discount2: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Discount set to apply to both negative and positive lines
        //[GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, SalespersonPurchaser, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity * 2, 500, '', '', '');
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Amount1 := SaleLinePOS.Quantity * SaleLinePOS."Unit Price";

        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, -Quantity, 500, '', '', '');
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Amount2 := SaleLinePOS.Quantity * SaleLinePOS."Unit Price";
        // Parameters
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100); // same discount on both lines
        DiscountType := DiscountType::TotalDiscountAmount;
        PresetMultiLineDiscTarget := PresetMultiLineDiscTarget::All;
        TotalAmountDisc := Round(DiscountQuantity / (Amount1 - Amount2) * 100, 0.001, '='); //positive + (-negative)

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        //[WHEN]
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        //  [THEN]
        // SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOSTest.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSTest.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSTest.SetRange("Line Type", SaleLinePOSTest."Line Type"::Item);
        SaleLinePOSTest.SetFilter(Quantity, '>0');
        SaleLinePOSTest.FindFirst();
        Discount1 := Round(SaleLinePOSTest."Discount %", 0.001, '=');
        Assert.AreEqual(TotalAmountDisc, Discount1, 'Discount is ok');

        SaleLinePOSTest.SetFilter(Quantity, '<0');
        SaleLinePOSTest.FindFirst();
        Assert.AreEqual(TotalAmountDisc, Discount2 + Discount1, 'Rounding is good');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyTotalAmountDiscountType()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSTest: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        AmountIncVATBeforeDiscount: Decimal;
        ItemReference: Record "Item Reference";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Set Total Amount to positive line
        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, SalespersonPurchaser, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity * 2, 500, '', '', '');
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, -Quantity, 500, '', '', ''); //2 lines
        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100);
        DiscountType := DiscountType::TotalAmount;
        PresetMultiLineDiscTarget := PresetMultiLineDiscTarget::"Positive Only";

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        AmountIncVATBeforeDiscount := SalePOS."Amount Including VAT";

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [WHEN]
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOSTest.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSTest.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSTest.SetRange("Line Type", SaleLinePOSTest."Line Type"::Item);
        SaleLinePOSTest.SetFilter(Quantity, '>0');
        SaleLinePOSTest.CalcSums("Amount Including VAT");
        Assert.IsTrue(SaleLinePOSTest."Amount Including VAT" = DiscountQuantity, 'Total Amount is correct');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyLineDiscountPercentageWithReasonCode()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSTest: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        ItemReference: Record "Item Reference";
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        Reason: Record "Reason Code";
        Dimension: Record Dimension;
        Salesperson: Record "Salesperson/Purchaser";
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Set Line Discount % to Positive Line with Reason Code,Salesperson Code and Dimension Code without Dimension Value
        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryERM.CreateReasonCode(Reason);
        LibrarySales.CreateSalesperson(Salesperson);
        LibraryDim.CreateDimension(Dimension);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');
        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100);
        DiscountType := DiscountType::LineDiscountPercentREL;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        // [WHEN]
        POSActionDiscountB.StoreAdditionalParams(Salesperson.Code, Reason.Code, Dimension.Code, '', '', InputIncludesTax::IfPricesInclTax);
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        ;
        SaleLinePOSTest.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSTest.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSTest.SetRange("Line Type", SaleLinePOSTest."Line Type"::Item);
        SaleLinePOSTest.SetRange("Discount %", DiscountQuantity);
        Assert.IsTrue(SaleLinePOSTest.FindFirst(), 'Discount % applied properly');
        Assert.IsTrue(SaleLinePOSTest."Discount Authorised by" = Salesperson.Code, 'Discount is Authorised');
        Assert.IsTrue(SaleLinePOSTest."Reason Code" = Reason.Code, 'Reason Code is set');
        Assert.IsTrue(SaleLinePOSTest."Shortcut Dimension 1 Code" <> Dimension.Code, 'Dimension isn''t applied');
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', 0); //CleanUp
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyDiscountHigherThanSaleAmount()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        ItemReference: Record "Item Reference";
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        DiscountAmountErr: Label 'Total discount amount entered must be less than the Sale Total!';
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Set Line Discount Higher than Sale Amount
        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, 1, '', '', '');
        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(2, 100);
        DiscountType := DiscountType::LineAmount;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        // [WHEN]
        asserterror POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        Assert.ExpectedError(DiscountAmountErr);
    end;

    local procedure Initialize()
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

            Initialized := true;
        end;

        Commit();
    end;

    local procedure InitializeSalesDocMgt(var SaleLine: Codeunit "NPR POS Sale Line"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.")
    var
        POSActionDocExportB: Codeunit "NPR POS Action: Doc. ExportB";
        AmountExclVAT: Decimal;
        AmountInclVAT: Decimal;
        VATAmount: Decimal;
        DocumentTypeNegative: Option ReturnOrder,CreditMemo,Restrict;
        DocumentTypePozitive: Option "Order",Invoice,Quote,Restrict,"Blanket Order";
        LocationSource: Option Undefined,"POS Store","POS Sale",SpecificLocation;
        PaymentMethodCodeSource: Option "Sales Header Default","Force Blank Code","Specific Payment Method Code";
    begin
        RetailSalesDocMgt.SetAsk(false);
        RetailSalesDocMgt.SetPrint(false);
        RetailSalesDocMgt.SetInvoice(false);
        RetailSalesDocMgt.SetReceive(true);
        RetailSalesDocMgt.SetShip(true);
        RetailSalesDocMgt.SetSendPostedPdf2Nav(false);
        RetailSalesDocMgt.SetRetailPrint(false);
        RetailSalesDocMgt.SetAutoReserveSalesLine(false);
        RetailSalesDocMgt.SetTransferSalesPerson(true);
        RetailSalesDocMgt.SetTransferPostingsetup(true);
        RetailSalesDocMgt.SetTransferDimensions(true);
        RetailSalesDocMgt.SetTransferTaxSetup(true);
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(false);
        RetailSalesDocMgt.SetSendDocument(false);
        RetailSalesDocMgt.SetSendICOrderConf(false);
        RetailSalesDocMgt.SetCustomerCreditCheck(false);
        RetailSalesDocMgt.SetWarningCustomerCreditCheck(false);
        RetailSalesDocMgt.SetPrintProformaInvoice(false);

        RetailSalesDocMgt.SetAsyncPosting(false);

        SaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);

        POSActionDocExportB.SetDocumentType(AmountInclVAT, RetailSalesDocMgt, DocumentTypePozitive::Invoice, DocumentTypeNegative::CreditMemo);
        POSActionDocExportB.SetLocationSource(RetailSalesDocMgt, LocationSource::"POS Store", '');
        POSActionDocExportB.SetPaymentMethodCode(RetailSalesDocMgt, PaymentMethodCodeSource::"Sales Header Default", '');
    end;

    local procedure GetCreatedSalesInvoiceHeader(SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesHeader."No.");
        SalesInvoiceHeader.FindFirst();
    end;

    local procedure GetCreatedSalesInvoiceLine(SaleLinePOS: Record "NPR POS Sale Line"; SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SetRange("No.", SaleLinePOS."No.");

        SalesInvoiceLine.FindFirst();
    end;

    local procedure AddDiscountToPOSSaleLine(var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; var DiscountAmount: Decimal; var DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra)
    var
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
    begin
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', InputIncludesTax::Always);
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountAmount, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
    end;

    local procedure ProcessSalesDocument(var SalesInvoiceLine: Record "Sales Invoice Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        InitializeSalesDocMgt(SaleLine, RetailSalesDocMgt);
        RetailSalesDocMgt.ProcessPOSSale(POSSale);
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        GetCreatedSalesInvoiceHeader(SalesHeader, SalesInvoiceHeader);
        GetCreatedSalesInvoiceLine(SaleLinePOS, SalesInvoiceHeader, SalesInvoiceLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ClearLineDiscount()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        ItemReference: Record "Item Reference";
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        AmountInclVatBeforeDiscount: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Set Line Discount and then Clear it
        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');
        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100);
        DiscountType := DiscountType::LineDiscountPercentABS;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        AmountInclVatBeforeDiscount := SalePOS."Amount Including VAT";
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        // [WHEN]
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        DiscountType := DiscountType::ClearLineDiscount;
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        Assert.IsTrue(SalePOS."Amount Including VAT" = AmountInclVatBeforeDiscount, 'Total Sale Amount is ok');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure SetDiscountPercentRelative()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        DiscountQuantityExtra: Decimal;
        ItemReference: Record "Item Reference";
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        NewDiscountQty: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Set Line Discount and then set extra Discount
        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');
        // Parameters 
        DiscountQuantity := LibraryRandom.RandIntInRange(1, 100); //10
        DiscountType := DiscountType::LineDiscountPercentABS;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        // [WHEN]
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        DiscountQuantityExtra := LibraryRandom.RandIntInRange(1, 100);
        DiscountType := DiscountType::DiscountPercentREL;
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantityExtra, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        NewDiscountQty := DiscountQuantity + DiscountQuantityExtra - (DiscountQuantityExtra * DiscountQuantity / 100);
        Assert.IsTrue(SaleLinePOS."Discount %" = NewDiscountQty, 'Extra discount applied');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure DiscountDoesntIncludeTax()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountQuantity: Decimal;
        ItemReference: Record "Item Reference";
        PresetMultiLineDiscTarget: Option Auto,"Positive Only","Negative Only",All,Ask;
        Quantity: Decimal;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] If Prices include VAT set Discount that doesn't include Tax
        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // Parameters 
        DiscountQuantity := 1;
        DiscountType := DiscountType::LineDiscountAmount;
        // [WHEN]
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', InputIncludesTax::Never);
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountQuantity, SalePOS, SaleLinePOS, PresetMultiLineDiscTarget);
        // [THEN]
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Discount Amount" = Round(DiscountQuantity * (1 + SaleLinePOS."VAT %" / 100)), 'Discount Amount is ok');
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', 0); //CleanUp
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyZeroLineAmountDiscountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] 0 line amount
        // - Add item
        // - Apply 0 line amount
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := 0;
        DiscountType := DiscountType::LineAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyPartialLineAmountDiscountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Partial line amount
        // - Add item
        // - Apply line amount that is bigger than 0 but lower than the amount of the line
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := LibraryRandom.RandDecInRange(1, Round(SaleLinePOS.Amount - 1, 1, '='), 4);
        DiscountType := DiscountType::LineAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyZeroTotalAmountDiscountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] 0 total amount
        // - Add item
        // - Apply 0 total amount
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := 0;
        DiscountType := DiscountType::TotalAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyPartialTotalAmountDiscountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Partial total amount
        // - Add item
        // - Apply total amount that is bigger than 0 but lower than the amount on the line
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := LibraryRandom.RandDecInRange(1, Round(SaleLinePOS.Amount - 1, 1, '='), 4);
        DiscountType := DiscountType::TotalAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyFullLineDiscountAmountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Full line discount amount
        // - Add item
        // - Apply line discount amount equal to the line amount of the line
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := SaleLinePOS.Amount;
        DiscountType := DiscountType::LineDiscountAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyPartialLineDiscountAmountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Partial line discount amount
        // - Add item
        // - Apply line discount amount bigger than 0, but lower than the line amount
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := LibraryRandom.RandDecInRange(1, Round(SaleLinePOS.Amount - 1, 1, '='), 4);
        DiscountType := DiscountType::LineDiscountAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyFullTotalDiscountAmountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Full total discount amount
        // - Add item
        // - Apply total discount amount equal to the total amount of the line
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := SaleLinePOS.Amount;
        DiscountType := DiscountType::TotalDiscountAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyPartialTotalDiscountAmountToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] Partial total discount amount
        // - Add item
        // - Apply total discount amount bigger than 0 but lower than the line amount
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := LibraryRandom.RandDecInRange(1, Round(SaleLinePOS.Amount - 1, 1, '='), 4);
        DiscountType := DiscountType::TotalDiscountAmount;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyLineDiscountOfHundredPctToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] 50% line discount percent
        // - Add item
        // - Apply 100% line discount percent
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := 100;
        DiscountType := DiscountType::LineDiscountPercentABS;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyLineDiscountOfFiftyPctToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] 50% line discount percent
        // - Add item
        // - Apply 50% line discount percent
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := 50;
        DiscountType := DiscountType::LineDiscountPercentABS;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyTotalDiscountOfHundredPctToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] 100% total discount percent
        // - Add item
        // - Apply 100% total discount percent
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := 100;
        DiscountType := DiscountType::DiscountPercentABS;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ApplyTotalDiscountOfFiftyPctToSalesInvoice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DiscountAmount: Decimal;
        Quantity: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        // [SCENARIO] 50% total discount percent
        // - Add item
        // - Apply 50% total discount percent
        // - Invoice customer
        // - Check if the discount in the posted sales invoice is correct

        // [GIVEN] POS & Payment setup with Sale
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := LibraryRandom.RandIntInRange(1, 100);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, Quantity, Item."Unit Price", '', '', '');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Set prices including VAT on POS Sale Line
        SalePOS.Validate("Prices Including VAT", true);
        SalePOS.Modify(true);

        // [GIVEN] Discount Amount and Type
        DiscountAmount := 50;
        DiscountType := DiscountType::DiscountPercentABS;

        // [GIVEN] Sale with discount 
        AddDiscountToPOSSaleLine(SalePOS, SaleLinePOS, DiscountAmount, DiscountType);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Process and Post Sales Document
        ProcessSalesDocument(SalesInvoiceLine);

        // [THEN] Check discount amount on the POS Sale Line and Sales Invoice Line
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreNearlyEqual(SaleLinePOS."Discount Amount", SalesInvoiceLine."Line Discount Amount", 0.01, 'Discount Amount must be equal on the POS and Invoice Line');
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", SalesInvoiceLine."Line Discount %", 0.01, 'Discount % must be equal on the POS and Invoice Line');
    end;
}