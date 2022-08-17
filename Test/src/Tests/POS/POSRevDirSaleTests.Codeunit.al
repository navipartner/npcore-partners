codeunit 85066 "NPR POS Rev. Dir. Sale Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Quantity: Decimal;
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        Item: Record Item;

    [Test]
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
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = false
        //ReturnReason = '';

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := false;
        ReturnReasonCode := '';

        SalesTicketNo := DoItemSale();

        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode);

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
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = false
        //ReturnReason <> '';

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := false;
        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReasonCode := ReturnReason.Code;

        SalesTicketNo := DoItemSale();

        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode);

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
    begin
        //[Scenario] Return Sale with parameters:
        //ObfucationMethod = None
        //CopyDimension = true
        //ReturnReason <> '';

        // [Given] POS & Payment setup
        InitializeData();

        //[Given] POS Action parameters
        ObfucationMethod := ObfucationMethod::None;
        CopyDim := true;
        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReasonCode := ReturnReason.Code;

        SalesTicketNo := DoItemSale();

        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyDim, ReturnReasonCode);

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
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
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