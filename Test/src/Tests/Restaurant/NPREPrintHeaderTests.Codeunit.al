#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85300 "NPR NPRE Print Header Tests"
{
    // [FEATURE] Restaurant kitchen/pre-receipt print header
    Subtype = Test;

    var
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetPrintHeaderFromPOSEntryResolvesSeating()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Seating: Record "NPR NPRE Seating";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        TempRestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        SeatingDescription: Text[50];
    begin
        // [SCENARIO] A sales receipt starts from a posted POS entry (no waiter-pad context); the header must still resolve the seating of the originating waiter pad
        // [GIVEN] A posted POS entry whose waiter pad is seated at a known seating
        SeatingDescription := 'Table 7';
        CreateBareWaiterPad(WaiterPad);
        CreatePrimarySeatingForWaiterPad(WaiterPad."No.", SeatingDescription, Seating);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);

        // [WHEN] The print header is built from the POS entry (sales-receipt path)
        KitchenPrintMgt.GetPrintHeader(POSEntry, false, TempRestaurantPrintHeader);

        // [THEN] The header carries the seating of the originating waiter pad
        Assert.AreEqual(Seating.Code, TempRestaurantPrintHeader."Seating Code", 'Header should resolve the seating code from the POS entry.');
        Assert.AreEqual(SeatingDescription, TempRestaurantPrintHeader."Seating Description", 'Header should resolve the seating description from the POS entry.');
        Assert.AreEqual(Seating."Seating No.", TempRestaurantPrintHeader."Seating No.", 'Header should resolve the seating no. (table no.) from the POS entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrderIdsFromPOSEntryResolvesTheOrder()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        KitchenOrderIds: List of [BigInteger];
        KitchenOrderId: BigInteger;
    begin
        CreateBareWaiterPad(WaiterPad);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);
        KitchenOrderId := CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");

        KitchenPrintMgt.GetKitchenOrderIds(POSEntry."Entry No.", KitchenOrderIds);

        Assert.AreEqual(1, KitchenOrderIds.Count(), 'One kitchen order should be resolved from the POS entry.');
        Assert.AreEqual(KitchenOrderId, KitchenOrderIds.Get(1), 'The resolved kitchen order should be the one created for the waiter pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrderIdsReturnsNothingWithoutAKitchenOrder()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        KitchenOrderIds: List of [BigInteger];
    begin
        CreateBareWaiterPad(WaiterPad);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);

        KitchenPrintMgt.GetKitchenOrderIds(POSEntry."Entry No.", KitchenOrderIds);

        Assert.AreEqual(0, KitchenOrderIds.Count(), 'A sale without a kitchen order should resolve no pickup number.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrderIdsDedupesRequestsOfTheSameOrder()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        KitchenOrderIds: List of [BigInteger];
        KitchenOrderId: BigInteger;
    begin
        CreateBareWaiterPad(WaiterPad);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);
        KitchenOrderId := CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");
        AddKitchenRequestForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.", KitchenOrderId, KitchenRequest."Line Status"::Planned);

        KitchenPrintMgt.GetKitchenOrderIds(POSEntry."Entry No.", KitchenOrderIds);

        Assert.AreEqual(1, KitchenOrderIds.Count(), 'Requests sharing a kitchen order should resolve to a single pickup number.');
        Assert.AreEqual(KitchenOrderId, KitchenOrderIds.Get(1), 'The resolved kitchen order should be the shared one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrderIdsReturnsEveryOrderOfTheSale()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        KitchenOrderIds: List of [BigInteger];
        FirstKitchenOrderId: BigInteger;
        SecondKitchenOrderId: BigInteger;
    begin
        CreateBareWaiterPad(WaiterPad);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);
        FirstKitchenOrderId := CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");
        SecondKitchenOrderId := CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");

        KitchenPrintMgt.GetKitchenOrderIds(POSEntry."Entry No.", KitchenOrderIds);

        Assert.AreEqual(2, KitchenOrderIds.Count(), 'Both kitchen orders of the sale should be resolved.');
        Assert.IsTrue(KitchenOrderIds.Contains(FirstKitchenOrderId), 'The first kitchen order should be resolved.');
        Assert.IsTrue(KitchenOrderIds.Contains(SecondKitchenOrderId), 'The second kitchen order should be resolved.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrderIdsReturnsOnlyOrdersOfThePaidWaiterPadLines()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        KitchenOrderIds: List of [BigInteger];
        PaidLineKitchenOrderId: BigInteger;
        UnpaidLineNo: Integer;
    begin
        CreateBareWaiterPad(WaiterPad);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);
        PaidLineKitchenOrderId := CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");
        UnpaidLineNo := POSEntryWaiterPadLink."Waiter Pad Line No." + 10000;
        CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", UnpaidLineNo);

        KitchenPrintMgt.GetKitchenOrderIds(POSEntry."Entry No.", KitchenOrderIds);

        Assert.AreEqual(1, KitchenOrderIds.Count(), 'Only the kitchen order of the waiter pad line on the receipt should be resolved.');
        Assert.AreEqual(PaidLineKitchenOrderId, KitchenOrderIds.Get(1), 'The resolved kitchen order should belong to the paid waiter pad line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrderIdMatchesTheFirstResolvedOrder()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        KitchenOrderSystemId: Guid;
        FirstKitchenOrderId: BigInteger;
        ResolvedKitchenOrderId: BigInteger;
    begin
        CreateBareWaiterPad(WaiterPad);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);
        FirstKitchenOrderId := CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");
        CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");

        ResolvedKitchenOrderId := KitchenPrintMgt.GetKitchenOrderId(POSEntry."Entry No.", KitchenOrderSystemId);

        Assert.AreEqual(FirstKitchenOrderId, ResolvedKitchenOrderId, 'The API should return the first kitchen order of the sale.');
        KitchenOrder.Get(FirstKitchenOrderId);
        Assert.AreEqual(KitchenOrder.SystemId, KitchenOrderSystemId, 'The resolved system id should belong to the resolved kitchen order.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrderIdsSkipsCancelledRequests()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        KitchenOrderIds: List of [BigInteger];
        LiveKitchenOrderId: BigInteger;
    begin
        CreateBareWaiterPad(WaiterPad);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);
        CreateCancelledKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");
        LiveKitchenOrderId := CreateKitchenOrderForWaiterPadLine(WaiterPad."No.", POSEntryWaiterPadLink."Waiter Pad Line No.");

        KitchenPrintMgt.GetKitchenOrderIds(POSEntry."Entry No.", KitchenOrderIds);

        Assert.AreEqual(1, KitchenOrderIds.Count(), 'A cancelled kitchen order should not resolve to a pickup number.');
        Assert.AreEqual(LiveKitchenOrderId, KitchenOrderIds.Get(1), 'Only the live kitchen order should be resolved.');
    end;

    local procedure CreateKitchenOrderForWaiterPadLine(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer) KitchenOrderId: BigInteger
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        KitchenOrder.Init();
        KitchenOrder.Insert(false);
        KitchenOrderId := KitchenOrder."Order ID";
        AddKitchenRequestForWaiterPadLine(WaiterPadNo, WaiterPadLineNo, KitchenOrderId, KitchenRequest."Line Status"::Planned);
    end;

    local procedure CreateCancelledKitchenOrderForWaiterPadLine(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer) KitchenOrderId: BigInteger
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        KitchenOrder.Init();
        KitchenOrder."Order Status" := KitchenOrder."Order Status"::Cancelled;
        KitchenOrder.Insert(false);
        KitchenOrderId := KitchenOrder."Order ID";
        AddKitchenRequestForWaiterPadLine(WaiterPadNo, WaiterPadLineNo, KitchenOrderId, KitchenRequest."Line Status"::Cancelled);
    end;

    local procedure AddKitchenRequestForWaiterPadLine(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; KitchenOrderId: BigInteger; LineStatus: Enum "NPR NPRE K.Request Line Status")
    var
        KitchenReqSrcLink: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        KitchenRequest.Init();
        KitchenRequest."Order ID" := KitchenOrderId;
        KitchenRequest."Line Status" := LineStatus;
        KitchenRequest.Insert(false);

        KitchenReqSrcLink.Init();
        KitchenReqSrcLink."Request No." := KitchenRequest."Request No.";
        KitchenReqSrcLink."Source Document Type" := KitchenReqSrcLink."Source Document Type"::"Waiter Pad";
        KitchenReqSrcLink."Source Document No." := WaiterPadNo;
        KitchenReqSrcLink."Source Document Line No." := WaiterPadLineNo;
        KitchenReqSrcLink.Insert(false);
    end;

    local procedure CreateBareWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPad.Init();
        WaiterPad."No." := CopyStr(LibraryUtility.GenerateRandomCode(WaiterPad.FieldNo("No."), Database::"NPR NPRE Waiter Pad"), 1, MaxStrLen(WaiterPad."No."));
        WaiterPad.Insert(true);
    end;

    local procedure CreatePrimarySeatingForWaiterPad(WaiterPadNo: Code[20]; SeatingDescription: Text[50]; var Seating: Record "NPR NPRE Seating")
    var
        SeatWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        Seating.Init();
        Seating.Code := CopyStr(LibraryUtility.GenerateRandomCode(Seating.FieldNo(Code), Database::"NPR NPRE Seating"), 1, MaxStrLen(Seating.Code));
        Seating."Seating No." := 'T-42'; // distinct from Code so assertions can tell the fields apart
        Seating.Description := SeatingDescription;
        Seating.Insert(false); // bypass dimension / seating-no. triggers not needed here

        SeatWaiterPadLink.Init();
        SeatWaiterPadLink."Seating Code" := Seating.Code;
        SeatWaiterPadLink."Waiter Pad No." := WaiterPadNo;
        SeatWaiterPadLink.Primary := true;
        SeatWaiterPadLink.Insert(false); // set Primary directly, skip its OnValidate reassignment
    end;

    local procedure CreatePostedEntryLinkedToWaiterPad(WaiterPadNo: Code[20]; var POSEntry: Record "NPR POS Entry"; var POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link")
    begin
        POSEntry.Init();
        POSEntry."Document No." := 'DOC-RCPT-01';
        POSEntry.Insert(false); // Entry No. is AutoIncrement

        POSEntryWaiterPadLink.Init();
        POSEntryWaiterPadLink."POS Entry No." := POSEntry."Entry No.";
        POSEntryWaiterPadLink."POS Entry Sales Line No." := 10000;
        POSEntryWaiterPadLink."Waiter Pad No." := WaiterPadNo;
        POSEntryWaiterPadLink."Waiter Pad Line No." := 10000;
        POSEntryWaiterPadLink.Insert();
    end;
}
#endif
