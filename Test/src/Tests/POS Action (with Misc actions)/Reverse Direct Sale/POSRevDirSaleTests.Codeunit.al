codeunit 85066 "NPR POS Rev. Dir. Sale Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        Item: Record Item;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReverseSale()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        ReturnReasonCode: Code[10];
        SalesTicketNo: Code[20];
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        ObfucationMethod: Option "None",MI;
        CopyDim: Boolean;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSEntryLine: Record "NPR POS Entry Sales Line";
        IncludePayLines: Boolean;
        CopyLineDimensions: Boolean;
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = false
        //ReturnReason = '';
        //IncludePayLines = false;
        //CopyLineDimensions = false;

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := false;
        ReturnReasonCode := '';
        IncludePayLines := false;
        CopyLineDimensions := false;

        SalesTicketNo := DoItemSale();

        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode, IncludePayLines, CopyLineDimensions);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSEntryLine.SetRange("Document No.", SalesTicketNo);
        POSEntryLine.FindFirst();

        Assert.IsTrue(POSEntryLine."No." = SaleLinePOS."No.", 'Item inserted');
        Assert.IsTrue(POSEntryLine.Quantity = -SaleLinePOS.Quantity, 'Quantity reversed');
        Assert.IsTrue(POSEntryLine."Amount Excl. VAT" = -SaleLinePOS.Amount, 'Amount reversed');
        Assert.IsTrue(POSEntryLine."Return Reason Code" = '', 'Return Reason Code is empty');
        Assert.IsTrue(POSEntryLine.SystemId = SaleLinePOS."Orig.POS Entry S.Line SystemId", 'System ID is copied.');
        Assert.IsTrue(-(POSEntryLine."Unit Cost" * POSEntryLine.Quantity) = SaleLinePOS.Cost, 'Cost reversed');
        Assert.IsTrue(POSEntryLine."VAT Base Amount" = -SaleLinePOS."VAT Base Amount", 'VAT Base Amount reversed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReverseSaleWithReasonCode()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        ReturnReasonCode: Code[10];
        SalesTicketNo: Code[20];
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        ObfucationMethod: Option "None",MI;
        CopyDim: Boolean;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSEntryLine: Record "NPR POS Entry Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        ReturnReason: Record "Return Reason";
        IncludePayLines: Boolean;
        CopyLineDimensions: Boolean;
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = false
        //ReturnReason <> '';
        //IncludePayLines := false;
        //CopyLineDimensions = false;

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := false;
        IncludePayLines := false;
        CopyLineDimensions := false;

        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReasonCode := ReturnReason.Code;

        SalesTicketNo := DoItemSale();

        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode, IncludePayLines, CopyLineDimensions);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSEntryLine.SetRange("Document No.", SalesTicketNo);
        POSEntryLine.FindFirst();

        Assert.IsTrue(POSEntryLine."No." = SaleLinePOS."No.", 'Item inserted');
        Assert.IsTrue(POSEntryLine.Quantity = -SaleLinePOS.Quantity, 'Quantity reversed');
        Assert.IsTrue(POSEntryLine."Amount Excl. VAT" = -SaleLinePOS.Amount, 'Amount reversed');
        Assert.IsTrue(ReturnReasonCode = SaleLinePOS."Return Reason Code", 'Return Reason Code inserted');
        Assert.IsTrue(POSEntryLine.SystemId = SaleLinePOS."Orig.POS Entry S.Line SystemId", 'System ID is copied.');
        Assert.IsTrue(-(POSEntryLine."Unit Cost" * POSEntryLine.Quantity) = SaleLinePOS.Cost, 'Cost reversed');
        Assert.IsTrue(POSEntryLine."VAT Base Amount" = -SaleLinePOS."VAT Base Amount", 'VAT Base Amount reversed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReverseSaleWithReasonCodeAndDimensions()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        ReturnReasonCode: Code[10];
        SalesTicketNo: Code[20];
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        ObfucationMethod: Option "None",MI;
        CopyDim: Boolean;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSEntryLine: Record "NPR POS Entry Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        ReturnReason: Record "Return Reason";
        IncludePayLines: Boolean;
        CopyLineDimensions: Boolean;
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = true
        //ReturnReason <> '';
        //IncludePayLines := false;
        //CopyLineDimensions = true;

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := true;
        IncludePayLines := false;
        CopyLineDimensions := true;

        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReasonCode := ReturnReason.Code;

        SalesTicketNo := DoItemSale();

        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode, IncludePayLines, CopyLineDimensions);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSEntryLine.SetRange("Document No.", SalesTicketNo);
        POSEntryLine.FindFirst();

        Assert.IsTrue(POSEntryLine."No." = SaleLinePOS."No.", 'Item inserted');
        Assert.IsTrue(POSEntryLine.Quantity = -SaleLinePOS.Quantity, 'Quantity reversed');
        Assert.IsTrue(POSEntryLine."Amount Excl. VAT" = -SaleLinePOS.Amount, 'Amount reversed');
        Assert.IsTrue(ReturnReasonCode = SaleLinePOS."Return Reason Code", 'Return Reason Code inserted');
        Assert.IsTrue(POSEntryLine.SystemId = SaleLinePOS."Orig.POS Entry S.Line SystemId", 'System ID is copied.');
        Assert.IsTrue(-(POSEntryLine."Unit Cost" * POSEntryLine.Quantity) = SaleLinePOS.Cost, 'Cost reversed');
        Assert.IsTrue(POSEntryLine."VAT Base Amount" = -SaleLinePOS."VAT Base Amount", 'VAT Base Amount reversed');
        Assert.IsTrue(POSEntryLine."Dimension Set ID" = SaleLinePOS."Dimension Set ID", 'Dimension Set ID copied.');
        Assert.IsTrue(POSEntryLine."Shortcut Dimension 1 Code" = SaleLinePOS."Shortcut Dimension 1 Code", 'Shortcut Dimension 1 Code copied.');
        Assert.IsTrue(POSEntryLine."Shortcut Dimension 2 Code" = SaleLinePOS."Shortcut Dimension 2 Code", 'Shortcut Dimension 2 Code copied.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReverseSaleWithIncludePaymentLines()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PaymentLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        ReturnReasonCode: Code[10];
        SalesTicketNo: Code[20];
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        ObfucationMethod: Option "None",MI;
        CopyDim: Boolean;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSEntryLine: Record "NPR POS Entry Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        ReturnReason: Record "Return Reason";
        IncludePayLines: Boolean;
        CopyLineDimensions: Boolean;
        POSEntryPaymentLines: Record "NPR POS Entry Payment Line";
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = true
        //ReturnReason <> '';
        //IncludePayLines := true;
        //CopyLineDimensions = true;

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := true;
        IncludePayLines := true;
        CopyLineDimensions := true;

        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReasonCode := ReturnReason.Code;

        SalesTicketNo := DoItemSale();

        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode, IncludePayLines, CopyLineDimensions);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSEntryLine.SetRange("Document No.", SalesTicketNo);
        POSEntryLine.FindFirst();

        Assert.IsTrue(POSEntryLine."No." = SaleLinePOS."No.", 'Item inserted');
        Assert.IsTrue(POSEntryLine.Quantity = -SaleLinePOS.Quantity, 'Quantity reversed');
        Assert.IsTrue(POSEntryLine."Amount Excl. VAT" = -SaleLinePOS.Amount, 'Amount reversed');
        Assert.IsTrue(ReturnReasonCode = SaleLinePOS."Return Reason Code", 'Return Reason Code inserted');
        Assert.IsTrue(POSEntryLine.SystemId = SaleLinePOS."Orig.POS Entry S.Line SystemId", 'System ID is copied.');
        Assert.IsTrue(-(POSEntryLine."Unit Cost" * POSEntryLine.Quantity) = SaleLinePOS.Cost, 'Cost reversed');
        Assert.IsTrue(POSEntryLine."VAT Base Amount" = -SaleLinePOS."VAT Base Amount", 'VAT Base Amount reversed');
        Assert.IsTrue(POSEntryLine."Dimension Set ID" = SaleLinePOS."Dimension Set ID", 'Dimension Set ID copied.');
        Assert.IsTrue(POSEntryLine."Shortcut Dimension 1 Code" = SaleLinePOS."Shortcut Dimension 1 Code", 'Shortcut Dimension 1 Code copied.');
        Assert.IsTrue(POSEntryLine."Shortcut Dimension 2 Code" = SaleLinePOS."Shortcut Dimension 2 Code", 'Shortcut Dimension 2 Code copied.');

        POSEntryPaymentLines.SetRange("Document No.", SalesTicketNo);
        if POSEntryPaymentLines.FindSet() then
            repeat
                PaymentLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                PaymentLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
                PaymentLinePOS.SetRange("Sale Type", PaymentLinePOS."Sale Type"::Sale);
                PaymentLinePOS.SetRange("Line Type", PaymentLinePOS."Line Type"::"POS Payment");
                if PaymentLinePOS.FindSet() then
                    repeat
                        Assert.IsTrue(PaymentLinePOS."No." = POSEntryPaymentLines."POS Payment Method Code", 'Payment Method code copied.');
                        Assert.IsTrue(PaymentLinePOS."EFT Approved" = POSEntryPaymentLines.EFT, 'EFT copied');
                        Assert.IsTrue(PaymentLinePOS."Shortcut Dimension 1 Code" = POSEntryPaymentLines."Shortcut Dimension 1 Code", 'Shortcut Dimension 1 Code copied.');
                        Assert.IsTrue(PaymentLinePOS."Shortcut Dimension 2 Code" = POSEntryPaymentLines."Shortcut Dimension 2 Code", 'Shortcut Dimension 2 Code copied.');
                        Assert.IsTrue(PaymentLinePOS."Dimension Set ID" = POSEntryPaymentLines."Dimension Set ID", 'Dimension Set ID copied.');
                        Assert.IsTrue(PaymentLinePOS."VAT Bus. Posting Group" = POSEntryPaymentLines."VAT Bus. Posting Group", 'VAT Bus. Posting Group copied.');
                        Assert.IsTrue(PaymentLinePOS."VAT Prod. Posting Group" = POSEntryPaymentLines."VAT Prod. Posting Group", 'VAT Prod. Posting Group copied.');
                        Assert.IsTrue(PaymentLinePOS.Description = POSEntryPaymentLines.Description, 'Description copied');
                        if POSEntryPaymentLines."Currency Code" <> '' then begin
                            Assert.IsTrue(PaymentLinePOS."Currency Amount" = -POSEntryPaymentLines.Amount, 'Amount reversed');
                            Assert.IsTrue(PaymentLinePOS."Amount Including VAT" = -POSEntryPaymentLines."Amount (LCY)", 'Amount reversed');
                        end else
                            Assert.IsTrue(PaymentLinePOS."Amount Including VAT" = -POSEntryPaymentLines.Amount, 'Amount reversed');
                        if POSEntryPaymentLines."VAT Base Amount (LCY)" <> 0 then
                            Assert.IsTrue(PaymentLinePOS."VAT Base Amount" = -POSEntryPaymentLines."VAT Base Amount (LCY)", 'VAT Base Amount reversed');
                    until PaymentLinePOS.Next() = 0;
            until POSEntryPaymentLines.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReverseSaleWithIncludePaymentLinesPaymentMethod()
    var
        ReturnReasonCode: Code[10];
        SalesTicketNo: Code[20];
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        ObfucationMethod: Option "None",MI;
        CopyDim: Boolean;
        LibraryERM: Codeunit "Library - ERM";
        ReturnReason: Record "Return Reason";
        IncludePayLines: Boolean;
        CopyLineDimensions: Boolean;
        ActualMessage, ExpectedMessage : Text;
        PaymentMethodCode: Code[20];
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = true
        //ReturnReason <> '';
        //IncludePayLines := true;

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := true;
        IncludePayLines := true;
        CopyLineDimensions := true;

        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReasonCode := ReturnReason.Code;

        SalesTicketNo := DoItemSale();
        PaymentMethodCode := POSPaymentMethod.Code;

        POSPaymentMethod.Delete(true);
        Commit();

        asserterror POSPaymentMethod.Get(PaymentMethodCode);
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        asserterror POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode, IncludePayLines, CopyLineDimensions);
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, ExpectedMessage);

    end;

    local procedure DoItemSale(): Code[20]
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '')) then begin
            error('Sale did not end as expected');
        end;
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        Exit(POSEntry."Document No.");
    end;

    procedure InitializeData()
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
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            Initialized := true;
        end;

        Commit();
    end;
}