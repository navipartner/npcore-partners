codeunit 85020 "NPR POS End of Day"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _VoucherType: Record "NPR NpRv Voucher Type";
        _EodWorkshiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;
        _PrimeNumbers: array[10] of Integer;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ItemSaleCashPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
    begin

        // [Scenario] Check that multiple sales are added correctly for the End of Day summary
        InitializeSetupLCY();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] 10 sales with 2 lines each
        NumberOfSales := 10;
        for SalesOffset := 1 to NumberOfSales do begin

            POSSale.GetCurrentSale(SalePOS);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
            VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

            Item."Unit Price" := _PrimeNumbers[SalesOffset];
            Item.Modify;

            LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals            
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);

            LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision", _POSPaymentMethod.GetRoundingType());
            TotalAmount += LineAmount * 2;
            TotalNetAmount += LineAmount * 2 / (100 + VATPostingSetup."VAT %") * 100;
            TotalQty += LineQty * 2;

            SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, LineAmount * 2, '');
            Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');
        end;

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);

        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint, BinCheckPoint for each Payment Method and BinEntries detailing result must be created.
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalQty, WorkshiftCheckpoint."Direct Item Sales Quantity", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales Quantity")));
        Assert.AreEqual(TotalQty, WorkshiftCheckpoint."Direct Item Quantity Sum", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Quantity Sum")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Direct Item Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales (LCY)")));
        Assert.AreEqual(NumberOfSales, WorkshiftCheckpoint."Direct Sales Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Sales Count")));
        Assert.AreEqual(NumberOfSales * 2, WorkshiftCheckpoint."Direct Item Sales Line Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales Line Count")));

        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));
        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));

        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Returns (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Returns Line Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns Line Count")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Returns Quantity", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns Quantity")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));

        // Bin CheckPoint is per payment metod. End Of Day creates "checkpoint" transactions that summarizes the End of Day activity for each payment method
        // With "Virtual" count, system will move full amount to designated bin.
        BinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpoint."Entry No.");
        BinCheckPoint.SetFilter(Type, '=%1', BinCheckPoint.Type::ZREPORT);
        BinCheckPoint.SetFilter("Payment Method No.", '=%1', _POSPaymentMethod.Code);
        BinCheckPoint.FindFirst();

        Assert.AreEqual(BinCheckPoint.Status::TRANSFERED, BinCheckPoint.Status, StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption(Status)));
        Assert.AreEqual(TotalAmount, BinCheckPoint."Calculated Amount Incl. Float", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Calculated Amount Incl. Float")));
        Assert.AreEqual(TotalAmount, BinCheckPoint."Counted Amount Incl. Float", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Counted Amount Incl. Float")));
        Assert.AreEqual(TotalAmount, BinCheckPoint."Move to Bin Amount", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Move to Bin Amount")));
        Assert.AreEqual(_POSPaymentMethod."Bin for Virtual-Count", BinCheckPoint."Move to Bin Code", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Move to Bin Code")));
        Assert.AreEqual(0, BinCheckPoint."Bank Deposit Amount", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Bank Deposit Amount")));
        Assert.AreEqual(0, BinCheckPoint."New Float Amount", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("New Float Amount")));

        // The Payment Bin has multiple transactions, one for each type of event end of day did with bin
        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::CHECKPOINT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::FLOAT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(0, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(0, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::ADJUSTMENT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(TotalAmount, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(TotalAmount, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::BIN_TRANSFER_OUT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ItemReturnCashPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
    begin

        // [Scenario] Check that multiple refunds are added correctly for the End of Day summary
        InitializeSetupLCY();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] 10 return sales with 2 lines each
        NumberOfSales := 10;
        for SalesOffset := 1 to NumberOfSales do begin

            POSSale.GetCurrentSale(SalePOS);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
            VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

            Item."Unit Price" := _PrimeNumbers[SalesOffset];
            Item.Modify;

            LineQty := -1 * (1 + _PrimeNumbers[SalesOffset] / 100); // will be 2 decimals            
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);

            LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision");
            TotalAmount += LineAmount * 2;
            TotalNetAmount += LineAmount * 2 / (100 + VATPostingSetup."VAT %") * 100;
            TotalQty += LineQty * 2;

            SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, LineAmount * 2, '');
            Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');
        end;

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);

        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint, BinCheckPoint for each Payment Method and BinEntries detailing result must be created.
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Direct Item Returns (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns (LCY)")));
        Assert.AreEqual(NumberOfSales * 2, WorkshiftCheckpoint."Direct Item Returns Line Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns Line Count")));
        Assert.AreEqual(TotalQty, WorkshiftCheckpoint."Direct Item Returns Quantity", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns Quantity")));

        Assert.AreEqual(TotalQty, WorkshiftCheckpoint."Direct Item Quantity Sum", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Quantity Sum")));
        Assert.AreEqual(NumberOfSales, WorkshiftCheckpoint."Direct Sales Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Sales Count")));
        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));

        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Sales Quantity", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales Quantity")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Sales Line Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales Line Count")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));

        // Bin CheckPoint is per payment metod. End Of Day creates "checkpoint" transactions that summarizes the End of Day activity for each payment method
        // With "Virtual" count, system will move full amount to designated bin.
        BinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpoint."Entry No.");
        BinCheckPoint.SetFilter(Type, '=%1', BinCheckPoint.Type::ZREPORT);
        BinCheckPoint.SetFilter("Payment Method No.", '=%1', _POSPaymentMethod.Code);
        BinCheckPoint.FindFirst();

        Assert.AreEqual(BinCheckPoint.Status::TRANSFERED, BinCheckPoint.Status, StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption(Status)));
        Assert.AreEqual(TotalAmount, BinCheckPoint."Calculated Amount Incl. Float", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Calculated Amount Incl. Float")));
        Assert.AreEqual(TotalAmount, BinCheckPoint."Counted Amount Incl. Float", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Counted Amount Incl. Float")));
        Assert.AreEqual(TotalAmount, BinCheckPoint."Move to Bin Amount", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Move to Bin Amount")));
        Assert.AreEqual(_POSPaymentMethod."Bin for Virtual-Count", BinCheckPoint."Move to Bin Code", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Move to Bin Code")));
        Assert.AreEqual(0, BinCheckPoint."Bank Deposit Amount", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("Bank Deposit Amount")));
        Assert.AreEqual(0, BinCheckPoint."New Float Amount", StrSubstNo('Value of "%1" is not correct.', BinCheckPoint.FieldCaption("New Float Amount")));

        // The Bin has multiple transactions, one for each type of event end of day did with bin
        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::CHECKPOINT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::FLOAT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(0, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(0, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::ADJUSTMENT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(TotalAmount, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(TotalAmount, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

        POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', BinCheckPoint."Entry No.");
        POSBinEntry.SetFilter(Type, '=%1', POSBinEntry.Type::BIN_TRANSFER_OUT);
        POSBinEntry.SetFilter("Payment Method Code", '=%1', _POSPaymentMethod.Code);
        POSBinEntry.FindFirst();
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount"), POSBinEntry.Type));
        Assert.AreEqual(TotalAmount * -1, POSBinEntry."Transaction Amount (LCY)", StrSubstNo('Value of "%1" for %2 is not correct.', POSBinEntry.FieldCaption("Transaction Amount (LCY)"), POSBinEntry.Type));

    end;


    [Test]
    procedure ItemSaleAndReturnCashPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
    begin

        // [Scenario] Check that multiple sales and refunds are added correctly for the End of Day summary
        InitializeSetupLCY();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] 10 sales with 1 sales line and 1 return line each resulting in a zero amount sale
        NumberOfSales := 10;
        for SalesOffset := 1 to NumberOfSales do begin

            POSSale.GetCurrentSale(SalePOS);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
            VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

            Item."Unit Price" := _PrimeNumbers[SalesOffset];
            Item.Modify;

            LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals            
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty * -1);

            LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision");
            TotalAmount += LineAmount;
            TotalNetAmount += LineAmount / (100 + VATPostingSetup."VAT %") * 100;
            TotalQty += LineQty;

            SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 0, '');
            Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');
        end;

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);

        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint must created with the correct sums
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalQty, WorkshiftCheckpoint."Direct Item Sales Quantity", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales Quantity")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Direct Item Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales (LCY)")));
        Assert.AreEqual(NumberOfSales, WorkshiftCheckpoint."Direct Item Sales Line Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Sales Line Count")));
        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));

        Assert.AreEqual(TotalAmount * -1, WorkshiftCheckpoint."Direct Item Returns (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns (LCY)")));
        Assert.AreEqual(NumberOfSales, WorkshiftCheckpoint."Direct Item Returns Line Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns Line Count")));
        Assert.AreEqual(TotalQty * -1, WorkshiftCheckpoint."Direct Item Returns Quantity", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Returns Quantity")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Direct Item Quantity Sum", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Quantity Sum")));
        Assert.AreEqual(NumberOfSales, WorkshiftCheckpoint."Direct Sales Count", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Sales Count")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));

        // Bin CheckPoint is per payment metod. End Of Day creates "checkpoint" transactions that summarizes the End of Day activity for each payment method
        // With "Virtual" count, system will move full amount to designated bin.
        BinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpoint."Entry No.");
        BinCheckPoint.SetFilter(Type, '=%1', BinCheckPoint.Type::ZREPORT);
        BinCheckPoint.SetFilter("Payment Method No.", '=%1', _POSPaymentMethod.Code);
        if (BinCheckPoint.FindFirst()) then
            Error('Bin CheckPoint not expected when sales and return sales are equal.')

    end;


    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ItemSaleEftPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        EFTTest: Codeunit "NPR EFT Tests";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
    begin

        // [Scenario] Check that EFT sales are added correctly for the End of Day summary
        InitializeSetupLCY();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        NumberOfSales := 1;
        SalesOffset := 1;

        // [GIVEN] 1 sale using the EFT Mock implementation
        POSSale.GetCurrentSale(SalePOS);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

        Item."Unit Price" := _PrimeNumbers[SalesOffset];
        Item.Modify;

        LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals            
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);

        LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision");
        TotalAmount += LineAmount;
        TotalNetAmount += Round(LineAmount / (100 + VATPostingSetup."VAT %") * 100, _POSPaymentMethod."Rounding Precision");
        TotalQty += LineQty;

        // Simulate EFT Payment & finish sale
        EFTTest.GenericEFTPaymentSuccess(_POSSession, SalePOS, LineAmount);
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 0, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);

        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint must created with the correct sums
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));

        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));
        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));

    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ItemSaleCashAndEftPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        EFTTest: Codeunit "NPR EFT Tests";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
    begin

        // [Scenario] Check that multiple payments methods are added correctly for the End of Day summary
        InitializeSetupLCY();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        NumberOfSales := 1;
        SalesOffset := 1;

        // [GIVEN] 1 sale with 2 payments (EFT and Cash)
        POSSale.GetCurrentSale(SalePOS);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

        Item."Unit Price" := _PrimeNumbers[SalesOffset];
        Item.Modify;

        LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals            
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);

        LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision");
        TotalAmount += LineAmount;
        TotalNetAmount += Round(LineAmount / (100 + VATPostingSetup."VAT %") * 100, _POSPaymentMethod."Rounding Precision");
        TotalQty += LineQty * 2;

        // Simulate EFT Payment & finish sale
        EFTTest.GenericEFTPaymentSuccess(_POSSession, SalePOS, LineAmount);
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, LineAmount, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);

        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint must created with the correct sums
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));

        Assert.AreEqual(TotalNetAmount * 2, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));
        Assert.AreEqual(TotalNetAmount * 2, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));
        Assert.AreEqual(TotalAmount * 2, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));

    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ItemSaleForeignCurrencyPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        EFTTest: Codeunit "NPR EFT Tests";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
        RelativeRate: Decimal;
    begin

        // [Scenario] Check that foreign currency is added correctly for the End of Day summary
        RelativeRate := 0.5; // a relative rate less than 1 will ensure rounding is in our favour when finishing sale. We will get a FC that evaluates to same or more than LCY
        InitializeSetupFC(RelativeRate);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        NumberOfSales := 1;
        SalesOffset := 2;

        // [GIVEN] 1 sale with foreign currency
        POSSale.GetCurrentSale(SalePOS);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

        Item."Unit Price" := _PrimeNumbers[SalesOffset];
        Item.Modify;

        LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals            
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);

        LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision");
        TotalAmount += LineAmount;
        TotalNetAmount += Round(LineAmount / (100 + VATPostingSetup."VAT %") * 100, _POSPaymentMethod."Rounding Precision");
        TotalQty += LineQty;

        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, LineAmount / RelativeRate, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);
        Assert.AreNotEqual(0, PosEntryNo, StrSubstNo('End of WorkShift failed creating POS Entry, last error was: %1', GetLastErrorText()));
        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint must created with the correct sums
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));
        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));
        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));

    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ItemSaleVoucherPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        EFTTest: Codeunit "NPR EFT Tests";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        NpRvVoucher: Record "NPR NpRv Voucher";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
    begin

        // [Scenario] Check that foreign currency is added correctly for the End of Day summary
        InitializeSetupVoucher();
 
        NumberOfSales := 1;
        SalesOffset := 4;

        // [GIVEN] 1 sale with foreign currency
        POSSale.GetCurrentSale(SalePOS);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

        Item."Unit Price" := _PrimeNumbers[SalesOffset];
        Item.Modify;

        LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals   
        LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision");
        CreateVoucherInPOSTransaction(NpRvVoucher, LineAmount);

        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);

        TotalAmount += LineAmount;
        TotalNetAmount += Round(LineAmount / (100 + VATPostingSetup."VAT %") * 100, _POSPaymentMethod."Rounding Precision");
        TotalQty += LineQty;

        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, LineAmount, NpRvVoucher."Reference No.");
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);
        Assert.AreNotEqual(0, PosEntryNo, StrSubstNo('End of WorkShift failed creating POS Entry, last error was: %1', GetLastErrorText()));
        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint must created with the correct sums
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Redeemed Vouchers (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Redeemed Vouchers (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));
        Assert.AreEqual(LineAmount, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));

        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));
        Assert.AreEqual(TotalNetAmount, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));
        Assert.AreEqual(TotalAmount, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));
    end;



    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ItemDiscountSaleCashPayment_Z()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        EFTTest: Codeunit "NPR EFT Tests";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        DimensionSetId: Integer;
        SalesOffset: Integer;
        NumberOfSales: Integer;
        PosEntryNo: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
        DiscountPct: Integer;
        DiscountAmount: Decimal;
        TotalDiscountAmount: Decimal;
        TotalDiscountNetAmount: Decimal;
        TotalNetDiscountAmount: Decimal;
    begin

        // [Scenario] Check that cash sale with discount is added correctly for the End of Day summary
        InitializeSetupLCY();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        NumberOfSales := 1;
        SalesOffset := 1;

        // [GIVEN] 1 sale with a discounted item
        POSSale.GetCurrentSale(SalePOS);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");

        Item."Unit Price" := _PrimeNumbers[SalesOffset];
        Item.Modify;

        DiscountPct := _PrimeNumbers[SalesOffset];
        LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals            
        NPRLibraryPOSMock.CreateItemLineWithDiscount(_POSSession, Item."No.", LineQty, DiscountPct);

        LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision");
        DiscountAmount := Round(LineAmount * DiscountPct / 100, _POSPaymentMethod."Rounding Precision");

        TotalDiscountAmount += DiscountAmount;
        TotalAmount += LineAmount;

        TotalNetAmount += Round(LineAmount / (100 + VATPostingSetup."VAT %") * 100, _POSPaymentMethod."Rounding Precision");
        TotalDiscountNetAmount += Round((LineAmount - DiscountAmount) / (100 + VATPostingSetup."VAT %") * 100, _POSPaymentMethod."Rounding Precision");
        TotalNetDiscountAmount += (DiscountAmount) / (100 + VATPostingSetup."VAT %") * 100; // Hmm - this amount is not rounded when summed!
        TotalQty += LineQty;

        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, LineAmount - DiscountAmount, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [WHEN] User invokes the Z-Report
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", DimensionSetId);

        WorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', PosEntryNo);
        WorkshiftCheckpoint.FindLast();

        // [THEN] WorkShiftCheckPoint must be created with the correct sums
        // WorkShift Checkpoint is a summary for End of Day
        Assert.IsTrue(WorkshiftCheckpoint.Type = WorkshiftCheckpoint.Type::ZREPORT, 'Workshift checkpoint must be of type Z-Report.');
        Assert.IsFalse(WorkshiftCheckpoint.Open, 'A posted workshift should not be open.');

        Assert.AreEqual(TotalAmount - TotalDiscountAmount, WorkshiftCheckpoint."Local Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Local Currency (LCY)")));

        Assert.AreEqual(TotalDiscountNetAmount, WorkshiftCheckpoint."Direct Item Net Sales (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Direct Item Net Sales (LCY)")));
        Assert.AreEqual(TotalDiscountNetAmount, WorkshiftCheckpoint."Net Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)")));
        Assert.AreEqual(TotalAmount - TotalDiscountAmount, WorkshiftCheckpoint."Turnover (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Turnover (LCY)")));

        Assert.AreEqual(TotalDiscountAmount, WorkshiftCheckpoint."Total Discount (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Total Discount (LCY)")));
        Assert.AreEqual(TotalNetDiscountAmount, WorkshiftCheckpoint."Total Net Discount (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Total Net Discount (LCY)")));

        Assert.AreEqual(0, WorkshiftCheckpoint."Foreign Currency (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("Foreign Currency (LCY)")));
        Assert.AreEqual(0, WorkshiftCheckpoint."EFT (LCY)", StrSubstNo('Value of "%1" is not correct.', WorkshiftCheckpoint.FieldCaption("EFT (LCY)")));

    end;

    [ModalPageHandler]
    procedure PageHandler_POSPaymentBinCheckpoint_LookupOK(var UIEndOfDay: Page "NPR POS Payment Bin Checkpoint"; var ActionResponse: Action)
    begin
        UIEndOfDay.DoOnOpenPageProcessing();
        UIEndOfDay.DoOnClosePageProcessing();
        ActionResponse := Action::LookupOK;
    end;

    procedure InitializeSetupLCY()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        Initialize();

        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
        _POSPaymentMethod."Rounding Precision" := 0.01;
        _POSPaymentMethod."Rounding Type" := _POSPaymentMethod."Rounding Type"::Nearest;
        _POSPaymentMethod.Modify();
    end;

    procedure InitializeSetupFC(RelativeRate: Decimal)
    var
        Currency: Record Currency;
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
        InitializeSetupLCY();

        if (RelativeRate <> 1) then begin
            LibraryERM.CreateCurrency(Currency);
            LibraryERM.CreateExchangeRate(Currency.Code, Today(), RelativeRate, RelativeRate);
            _POSPaymentMethod."Fixed Rate" := RelativeRate * 100;
            _POSPaymentMethod."Currency Code" := Currency.Code;
            _POSPaymentMethod.Modify();
        end;
    end;

    procedure InitializeSetupVoucher()
    var
        Currency: Record Currency;
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
        InitializeSetupLCY();
        _POSPaymentMethod."Processing Type" := _POSPaymentMethod."Processing Type"::VOUCHER;
        _POSPaymentMethod.Modify();
    end;

    local procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSPaymentBin: Record "NPR POS Payment Bin";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
            Clear(_POSSession);
            WorkDate(Today);
        end;

        if not _Initialized then begin
            _PrimeNumbers[1] := 19;
            _PrimeNumbers[2] := 23;
            _PrimeNumbers[3] := 29;
            _PrimeNumbers[4] := 31;
            _PrimeNumbers[5] := 37;
            _PrimeNumbers[6] := 41;
            _PrimeNumbers[7] := 43;
            _PrimeNumbers[8] := 47;
            _PrimeNumbers[9] := 53;
            _PrimeNumbers[10] := 59;

            NPRLibraryPOSMasterData.CreatePartialVoucherType(_VoucherType, false);
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();
            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            _Initialized := true;

        end;
        NPRLibraryPOSMasterData.ItemReferenceCleanup();

        Commit;
    end;

    local procedure CreateVoucherInPOSTransaction(var NpRvVoucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal)
    var
        SalePOS: Record "NPR Sale POS";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSEntry: Record "NPR POS Entry";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        TransactionEnded: Boolean;
    begin
        LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        POSPaymentMethod."Rounding Precision" := 0.01;
        POSPaymentMethod.Modify();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherType.Code, 1, VoucherAmount, '', 0);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, POSPaymentMethod.Code, VoucherAmount, '');
        // [THEN] Retail Voucher Exist
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherType.Code);
        NpRvVoucher.FindFirst();
    end;
   

}
