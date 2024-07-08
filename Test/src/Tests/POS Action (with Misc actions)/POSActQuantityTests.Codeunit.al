codeunit 85068 "NPR POS Act. Quantity Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityPositive()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        Quantity: Decimal;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        ReturnReasonCode: Code[20];
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        //[parameters]
        //ReturnReasonCode = '';
        //Quantity = random positive
        //UnitPrice = 0;
        //ConstraintOption = No Contstraint
        //NegativeInput = false
        //SkipItemAvailCheck = true

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        ReturnReasonCode := '';
        UnitPrice := 0;
        ConstraintOption := ConstraintOption::"No Constraint";
        NegativeInput := false;
        SkipItemAvailabilityCheck := true;
        Quantity := LibraryRandom.RandDecInRange(1, 100, 4);

        POSSession.GetSaleLine(SaleLine);

        POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS.Quantity = Quantity, 'Quantity changed');
        Assert.IsTrue(SaleLinePOS."Return Reason Code" = '', 'Return Reason Code is empty');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityPositiveFail()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        Quantity: Decimal;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        ReturnReasonCode: Code[20];
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        //[parameters]
        //ReturnReasonCode = '';
        //Quantity = random positive
        //UnitPrice = 0;
        //ConstraintOption = Only Negative
        //NegativeInput = false
        //SkipItemAvailCheck = true

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        ReturnReasonCode := '';
        UnitPrice := 0;
        ConstraintOption := ConstraintOption::"Positive Quantity Only";
        NegativeInput := false;
        SkipItemAvailabilityCheck := true;
        Quantity := -LibraryRandom.RandDecInRange(1, 100, 4);

        POSSession.GetSaleLine(SaleLine);

        // [THEN] Expected Error
        asserterror POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityNegative()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        Quantity: Decimal;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        ReturnReasonCode: Code[20];
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        //[parameters]
        //ReturnReasonCode = '';
        //Quantity = random positive
        //UnitPrice = random;
        //ConstraintOption = No Contstraint
        //NegativeInput = false
        //SkipItemAvailCheck = true

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        ReturnReasonCode := '';
        UnitPrice := LibraryRandom.RandDecInRange(1, 100, 4);
        ConstraintOption := ConstraintOption::"No Constraint";
        NegativeInput := false;
        SkipItemAvailabilityCheck := true;
        Quantity := -LibraryRandom.RandDecInRange(1, 100, 4);

        POSSession.GetSaleLine(SaleLine);

        POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS.Quantity = Quantity, 'Quantity changed');
        Assert.IsTrue(SaleLinePOS."Return Reason Code" = '', 'Return Reason Code is empty');
        Assert.IsTrue(SaleLinePOS."Unit Price" = UnitPrice, 'Unit Price changed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityNegativeInput()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        Quantity: Decimal;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        ReturnReasonCode: Code[20];
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        //[parameters]
        //ReturnReasonCode = '';
        //Quantity = random positive
        //UnitPrice = random;
        //ConstraintOption = No Contstraint
        //NegativeInput = true
        //SkipItemAvailCheck = true

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        ReturnReasonCode := '';
        UnitPrice := LibraryRandom.RandDecInRange(1, 100, 4);
        ConstraintOption := ConstraintOption::"No Constraint";
        NegativeInput := true;
        SkipItemAvailabilityCheck := true;
        Quantity := LibraryRandom.RandDecInRange(1, 100, 4);

        POSSession.GetSaleLine(SaleLine);

        POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS.Quantity = -Quantity, 'Quantity changed');
        Assert.IsTrue(SaleLinePOS."Return Reason Code" = '', 'Return Reason Code is empty');
        Assert.IsTrue(SaleLinePOS."Unit Price" = UnitPrice, 'Unit Price changed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityNegativeFail()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        Quantity: Decimal;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        ReturnReasonCode: Code[20];
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        //[parameters]
        //ReturnReasonCode = '';
        //Quantity = random positive
        //UnitPrice = 0;
        //ConstraintOption = Only Positive
        //NegativeInput = false
        //SkipItemAvailCheck = true


        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        ReturnReasonCode := '';
        UnitPrice := 0;
        ConstraintOption := ConstraintOption::"Negative Quantity Only";
        NegativeInput := false;
        SkipItemAvailabilityCheck := true;
        Quantity := LibraryRandom.RandDecInRange(1, 100, 4);

        POSSession.GetSaleLine(SaleLine);

        // [THEN] Expected Error
        asserterror POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityReturnReasonCode()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        Quantity: Decimal;
        POSActQuantityB: Codeunit "NPR POS Action: Quantity B";
        ReturnReasonCode: Code[20];
        UnitPrice: Decimal;
        ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only";
        NegativeInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        ReturnReason: Record "Return Reason";
    begin
        //[parameters]
        //ReturnReasonCode = '';
        //Quantity = random positive
        //UnitPrice = 0;
        //ConstraintOption = No Contstraint
        //NegativeInput = true
        //SkipItemAvailCheck = true

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReasonCode := ReturnReason.Code;
        ConstraintOption := ConstraintOption::"No Constraint";
        NegativeInput := false;
        SkipItemAvailabilityCheck := true;
        Quantity := LibraryRandom.RandDecInRange(1, 100, 4);

        POSSession.GetSaleLine(SaleLine);

        POSActQuantityB.ChangeQuantity(ReturnReasonCode, Quantity, UnitPrice, ConstraintOption, NegativeInput, SkipItemAvailabilityCheck, SaleLine);

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS.Quantity = Quantity, 'Quantity changed');
        Assert.IsTrue(SaleLinePOS."Return Reason Code" = ReturnReasonCode, 'Return Reason Code is inserted');
    end;
}