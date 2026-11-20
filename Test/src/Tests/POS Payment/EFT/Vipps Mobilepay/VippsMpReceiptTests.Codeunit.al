// [FEATURE] Vipps MobilePay receipt content
codeunit 85653 "NPR Vipps Mp Receipt Tests"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSaleWithItemAndAttachedComment_WhenReceiptContentIsBuilt_ThenTheCommentLineHasTheIdComment()
    var
        Item: Record Item;
        Assert: Codeunit Assert;
        InsertCommentB: Codeunit "NPR POS Action - Insert Comm B";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        VippsMpePaymentAPI: Codeunit "NPR Vipps Mp ePayment API";
        CommentOrderLine: JsonObject;
        ItemOrderLine: JsonObject;
        Receipt: JsonObject;
        ItemLineMissingMsg: Label 'F2: the receipt should have an order line for the item %1', Locked = true;
        ItemLineIdMsg: Label 'F2: the order line of the item %1 should have the item no. as its id', Locked = true;
    begin
        // [SCENARIO] The Vipps receipt sends the id Comment for a comment attached to an item, and the item no. for the item
        Initialize();

        // [GIVEN] F2: a POS sale of the item "Coffee" with the comment "No sugar" attached to it (No. "*")
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := 'Coffee';
        Item.Modify();
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        InsertCommentB.InputPosCommentLine('No sugar', true, POSSaleLine);

        // [WHEN] The Vipps receipt content of the current sale is built
        Receipt := VippsMpePaymentAPI.ReceiptContent();

        // [THEN] The order line of the comment has the id Comment
        Assert.IsTrue(FindOrderLine(Receipt, 'No sugar', CommentOrderLine), 'F2: the receipt should have an order line for the comment "No sugar"');
        Assert.AreEqual('Comment', GetOrderLineId(CommentOrderLine), 'F2: the order line of the comment "No sugar" should have the id Comment');

        // [THEN] The order line of the item has the item no. as its id
        Assert.IsTrue(FindOrderLine(Receipt, 'Coffee', ItemOrderLine), StrSubstNo(ItemLineMissingMsg, Item."No."));
        Assert.AreEqual(Item."No.", GetOrderLineId(ItemOrderLine), StrSubstNo(ItemLineIdMsg, Item."No."));
    end;

    local procedure Initialize()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        LibraryPOSMock.InitializeData(_IsInitialized, _POSUnit, _POSStore);
    end;

    local procedure FindOrderLine(Receipt: JsonObject; Name: Text; var OrderLine: JsonObject): Boolean
    var
        LineToken: JsonToken;
        NameToken: JsonToken;
        OrderLinesToken: JsonToken;
    begin
        if not Receipt.Get('orderLines', OrderLinesToken) then
            exit(false);
        foreach LineToken in OrderLinesToken.AsArray() do
            if LineToken.AsObject().Get('name', NameToken) then
                if NameToken.AsValue().AsText() = Name then begin
                    OrderLine := LineToken.AsObject();
                    exit(true);
                end;
    end;

    local procedure GetOrderLineId(OrderLine: JsonObject): Text
    var
        IdToken: JsonToken;
    begin
        if not OrderLine.Get('id', IdToken) then
            exit('');
        exit(IdToken.AsValue().AsText());
    end;
}
