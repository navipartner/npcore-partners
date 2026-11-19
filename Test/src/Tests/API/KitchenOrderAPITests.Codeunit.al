#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85159 "NPR Kitchen Order API Tests"
{
    // [FEATURE] Kitchen Order API end-to-end tests

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;
        _CashPaymentMethod: Record "NPR POS Payment Method";
        _Seating: Record "NPR NPRE Seating";
        _RestaurantCode: Code[20];
        _RestaurantId: Guid;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrders_AfterCompleteSaleWithKitchenRequest_ReturnsOrders()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        KitchenRequest: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        DataArray: JsonArray;
        OrderToken: JsonToken;
        OrderObj: JsonObject;
        KitchenOrderNo: Text;
    begin
        // [SCENARIO] After completing a sale with kitchenRequest, the kitchen order should be available via GET /restaurant/{id}/orders
        Initialize();

        // [GIVEN] A completed sale with kitchen request
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();
        KitchenOrderNo := CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);

        // [WHEN] Get kitchen orders for the restaurant
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantId) + '/orders', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get kitchen orders should succeed');

        // [THEN] Response should contain the created kitchen order
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('data', JToken), 'Response should contain data array');
        DataArray := JToken.AsArray();
        Assert.IsTrue(DataArray.Count() >= 1, 'Should have at least one kitchen order');

        // [THEN] Find our kitchen order in the result
        DataArray.Get(0, OrderToken);
        OrderObj := OrderToken.AsObject();
        OrderObj.Get('orderNo', JToken);
        Assert.AreEqual(KitchenOrderNo, JToken.AsValue().AsText(), 'Kitchen order number should match');
        OrderObj.Get('restaurantCode', JToken);
        Assert.AreEqual(_RestaurantCode, JToken.AsValue().AsText(), 'Restaurant code should match');
        Assert.IsTrue(OrderObj.Contains('orderId'), 'Kitchen order should have orderId field');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrders_WithStatusFilter_ReturnsFilteredOrders()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        DataArray: JsonArray;
        OrderToken: JsonToken;
        OrderObj: JsonObject;
        KitchenOrderNoText: Text;
        KitchenOrderNo: BigInteger;
        i: Integer;
        AllHaveCorrectStatus: Boolean;
    begin
        // [SCENARIO] Get kitchen orders with status filter returns only orders with that status
        Initialize();

        // [GIVEN] A kitchen order that has been finished (status = Finished)
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();
        KitchenOrderNoText := CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);
        Evaluate(KitchenOrderNo, KitchenOrderNoText);
        LibraryRestaurant.FinishKitchenOrder(KitchenOrderNo);

        // [WHEN] Get kitchen orders with status filter = Finished
        Clear(Body);
        Clear(QueryParams);
        QueryParams.Add('status', 'Finished');
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantId) + '/orders', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get kitchen orders with filter should succeed');

        // [THEN] All returned orders should have status Finished
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('data', JToken);
        DataArray := JToken.AsArray();

        if DataArray.Count() > 0 then begin
            AllHaveCorrectStatus := true;
            for i := 0 to DataArray.Count() - 1 do begin
                DataArray.Get(i, OrderToken);
                OrderObj := OrderToken.AsObject();
                OrderObj.Get('status', JToken);
                if JToken.AsValue().AsText() <> 'Finished' then
                    AllHaveCorrectStatus := false;
            end;
            Assert.IsTrue(AllHaveCorrectStatus, 'All orders should have status Finished');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrders_Pagination_WorksCorrectly()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        DataArray: JsonArray;
        NextPageKey: Text;
        FirstOrderNo: Text;
        SecondOrderNo: Text;
        i: Integer;
    begin
        // [SCENARIO] Pagination returns correct pages of kitchen orders
        Initialize();

        // [GIVEN] Multiple kitchen orders (create 3 orders)
        for i := 1 to 3 do begin
            SaleId := CreateGuid();
            SaleLineId := CreateGuid();
            PaymentLineId := CreateGuid();
            CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);
        end;

        // [WHEN] Get first page with pageSize=1
        Clear(Body);
        Clear(QueryParams);
        QueryParams.Add('pageSize', '1');
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantId) + '/orders', Body, QueryParams, Headers);

        // [THEN] Should return OK with 1 result and nextPageKey
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get first page should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('data', JToken);
        DataArray := JToken.AsArray();
        Assert.AreEqual(1, DataArray.Count(), 'First page should have exactly 1 order');

        DataArray.Get(0, JToken);
        JToken.AsObject().Get('orderNo', JToken);
        FirstOrderNo := JToken.AsValue().AsText();

        ResponseBody.Get('morePages', JToken);
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'Should indicate more pages available');

        ResponseBody.Get('nextPageKey', JToken);
        NextPageKey := JToken.AsValue().AsText();
        Assert.AreNotEqual('', NextPageKey, 'Should have nextPageKey');

        // [WHEN] Get second page using nextPageKey
        Clear(QueryParams);
        QueryParams.Add('pageSize', '1');
        QueryParams.Add('pageKey', NextPageKey);
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantId) + '/orders', Body, QueryParams, Headers);

        // [THEN] Should return different order
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get second page should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('data', JToken);
        DataArray := JToken.AsArray();
        Assert.AreEqual(1, DataArray.Count(), 'Second page should have exactly 1 order');

        DataArray.Get(0, JToken);
        JToken.AsObject().Get('orderNo', JToken);
        SecondOrderNo := JToken.AsValue().AsText();
        Assert.AreNotEqual(FirstOrderNo, SecondOrderNo, 'Second page should have different order than first');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrders_NoOrders_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        FakeRestaurantId: Guid;
    begin
        // [SCENARIO] Get kitchen orders for non-existent restaurant returns not found
        Initialize();

        // [GIVEN] A restaurant ID that does not exist
        FakeRestaurantId := CreateGuid();

        // [WHEN] Get kitchen orders
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(FakeRestaurantId) + '/orders', Body, QueryParams, Headers);

        // [THEN] Should return 404 Not Found
        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get should return not found for non-existent restaurant');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrders_MultipleOrdersSameRestaurant_ReturnsAll()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        DataArray: JsonArray;
        KitchenOrderNo1: Text;
        KitchenOrderNo2: Text;
        i: Integer;
        OrderToken: JsonToken;
        OrderObj: JsonObject;
        FoundOrder1: Boolean;
        FoundOrder2: Boolean;
        OrderNo: Text;
    begin
        // [SCENARIO] Multiple kitchen orders for same restaurant are all returned
        Initialize();

        // [GIVEN] Two kitchen orders for the same restaurant
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();
        KitchenOrderNo1 := CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);

        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();
        KitchenOrderNo2 := CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);

        // [WHEN] Get all kitchen orders
        Clear(Body);
        Clear(QueryParams);
        QueryParams.Add('pageSize', '100');
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantId) + '/orders', Body, QueryParams, Headers);

        // [THEN] Should return both orders
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get kitchen orders should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('data', JToken);
        DataArray := JToken.AsArray();
        Assert.IsTrue(DataArray.Count() >= 2, 'Should have at least 2 kitchen orders');

        // Find both orders
        for i := 0 to DataArray.Count() - 1 do begin
            DataArray.Get(i, OrderToken);
            OrderObj := OrderToken.AsObject();
            OrderObj.Get('orderNo', JToken);
            OrderNo := JToken.AsValue().AsText();
            if OrderNo = KitchenOrderNo1 then
                FoundOrder1 := true;
            if OrderNo = KitchenOrderNo2 then
                FoundOrder2 := true;
        end;

        Assert.IsTrue(FoundOrder1, 'First kitchen order should be in results');
        Assert.IsTrue(FoundOrder2, 'Second kitchen order should be in results');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrders_ReturnsExpectedFields()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        DataArray: JsonArray;
        OrderToken: JsonToken;
        OrderObj: JsonObject;
    begin
        // [SCENARIO] Kitchen order response contains all expected fields
        Initialize();

        // [GIVEN] A kitchen order
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();
        CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);

        // [WHEN] Get kitchen orders
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantId) + '/orders', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get kitchen orders should succeed');

        // [THEN] Order should have all expected fields
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('data', JToken);
        DataArray := JToken.AsArray();
        Assert.IsTrue(DataArray.Count() >= 1, 'Should have at least one order');

        DataArray.Get(0, OrderToken);
        OrderObj := OrderToken.AsObject();

        Assert.IsTrue(OrderObj.Contains('orderId'), 'Order should have orderId field');
        Assert.IsTrue(OrderObj.Contains('orderNo'), 'Order should have orderNo field');
        Assert.IsTrue(OrderObj.Contains('restaurantCode'), 'Order should have restaurantCode field');
        Assert.IsTrue(OrderObj.Contains('status'), 'Order should have status field');
        Assert.IsTrue(OrderObj.Contains('priority'), 'Order should have priority field');
        Assert.IsTrue(OrderObj.Contains('createdDateTime'), 'Order should have createdDateTime field');
        Assert.IsTrue(OrderObj.Contains('onHold'), 'Order should have onHold field');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrder_BySystemId_ReturnsOrder()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        DataArray: JsonArray;
        OrderToken: JsonToken;
        OrderObj: JsonObject;
        KitchenOrderNoText: Text;
        KitchenOrderNo: BigInteger;
        OrderSystemId: Guid;
    begin
        // [SCENARIO] Get a specific kitchen order by its SystemId
        Initialize();

        // [GIVEN] A completed sale with kitchen order
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();
        KitchenOrderNoText := CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);
        Evaluate(KitchenOrderNo, KitchenOrderNoText);

        // [GIVEN] The kitchen order's SystemId
        KitchenOrder.SetRange("Order ID", KitchenOrderNo);
        KitchenOrder.FindFirst();
        OrderSystemId := KitchenOrder.SystemId;

        // [WHEN] GET /restaurant/:restaurantId/orders/:orderId
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantId) + '/orders/' + FormatGuid(OrderSystemId), Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get specific kitchen order should succeed');

        // [THEN] Response should contain the correct order fields
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('orderId', JToken);
        Assert.AreEqual(FormatGuid(OrderSystemId), JToken.AsValue().AsText(), 'orderId should match SystemId');

        ResponseBody.Get('orderNo', JToken);
        Assert.AreEqual(KitchenOrderNoText, JToken.AsValue().AsText(), 'Order number should match');

        ResponseBody.Get('restaurantCode', JToken);
        Assert.AreEqual(_RestaurantCode, JToken.AsValue().AsText(), 'Restaurant code should match');

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Released', JToken.AsValue().AsText(), 'Status should be Released for new kitchen order');

        Assert.IsTrue(ResponseBody.Contains('priority'), 'Should have priority field');
        Assert.IsTrue(ResponseBody.Contains('createdDateTime'), 'Should have createdDateTime field');
        Assert.IsTrue(ResponseBody.Contains('onHold'), 'Should have onHold field');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenOrder_WrongRestaurant_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        KitchenOrderNoText: Text;
        KitchenOrderNo: BigInteger;
        OrderSystemId: Guid;
        FakeRestaurantId: Guid;
    begin
        // [SCENARIO] Get kitchen order with wrong restaurant ID returns not found
        Initialize();

        // [GIVEN] A kitchen order
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();
        KitchenOrderNoText := CreateSaleWithKitchenOrder(SaleId, SaleLineId, PaymentLineId);
        Evaluate(KitchenOrderNo, KitchenOrderNoText);

        KitchenOrder.SetRange("Order ID", KitchenOrderNo);
        KitchenOrder.FindFirst();
        OrderSystemId := KitchenOrder.SystemId;

        // [WHEN] GET with a non-matching restaurant ID
        FakeRestaurantId := CreateGuid();
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(FakeRestaurantId) + '/orders/' + FormatGuid(OrderSystemId), Body, QueryParams, Headers);

        // [THEN] Should return not found
        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Should return not found for wrong restaurant');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_FirstOrdersOfTheDay_GetDisplayNosFromOne()
    var
        KitchenOrderCounter: Record "NPR NPRE Kitchen Order Counter";
        Assert: Codeunit Assert;
        OtherRestaurantCode: Code[20];
    begin
        // [SCENARIO] The restaurant's display order number restarts at 1 on a new day, counts up, and leaves other restaurants' counters alone
        Initialize();

        // [GIVEN] The restaurant's counter was last used yesterday, and another restaurant's counter is at 500 today
        SetDisplayOrderCounter(_RestaurantCode, 500, CalcDate('<-1D>', Today()));
        OtherRestaurantCode := CopyStr('OTHER-' + _RestaurantCode, 1, MaxStrLen(OtherRestaurantCode));
        SetDisplayOrderCounter(OtherRestaurantCode, 500, Today());

        // [WHEN] Two kitchen orders are created
        // [THEN] They get display numbers 1 and 2
        Assert.AreEqual(1, CreateSaleAndGetDisplayOrderNo(), 'First order of the day should get display number 1');
        Assert.AreEqual(2, CreateSaleAndGetDisplayOrderNo(), 'Second order of the day should get display number 2');

        // [THEN] The other restaurant's counter is unchanged
        KitchenOrderCounter.Get(OtherRestaurantCode);
        Assert.AreEqual(500, KitchenOrderCounter."Last Display Order No.", 'Another restaurant''s counter should not change');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_DisplayNo999Reached_WrapsToOne()
    var
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] The display order number wraps back to 1 after 999 within the same day
        Initialize();

        // [GIVEN] The restaurant's counter is at 999 today
        SetDisplayOrderCounter(_RestaurantCode, 999, Today());

        // [WHEN] A kitchen order is created
        // [THEN] It gets display number 1
        Assert.AreEqual(1, CreateSaleAndGetDisplayOrderNo(), 'Display number should wrap to 1 after 999');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_CounterDateAhead_ContinuesSequence()
    var
        KitchenOrderCounter: Record "NPR NPRE Kitchen Order Counter";
        Assert: Codeunit Assert;
        Tomorrow: Date;
    begin
        // [SCENARIO] A session whose date lags behind the stored counter date (a UTC API session after a local-time POS session) continues the sequence instead of resetting it
        Initialize();

        // [GIVEN] The restaurant's counter is at 10 with tomorrow's date
        Tomorrow := CalcDate('<+1D>', Today());
        SetDisplayOrderCounter(_RestaurantCode, 10, Tomorrow);

        // [WHEN] A kitchen order is created
        // [THEN] It gets display number 11 and the stored date is not moved back
        Assert.AreEqual(11, CreateSaleAndGetDisplayOrderNo(), 'Display number should continue the sequence');
        KitchenOrderCounter.Get(_RestaurantCode);
        Assert.AreEqual(Tomorrow, KitchenOrderCounter."Last Display Order Date", 'Counter date should not move backwards');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_StationSelectionWithoutRestaurant_UsesSeatingLocationRestaurant()
    var
        KitchenOrderCounter: Record "NPR NPRE Kitchen Order Counter";
        BlankRestaurantSelection: Record "NPR NPRE Kitchen Station Slct.";
        TempRestaurantSelection: Record "NPR NPRE Kitchen Station Slct." temporary;
        Assert: Codeunit Assert;
        DisplayOrderNo: Integer;
    begin
        // [SCENARIO] When the kitchen station is selected through a line without a restaurant code, the display number still comes from the ordering restaurant's counter
        Initialize();

        // [GIVEN] The restaurant's only station selection line has a blank restaurant code
        ReplaceStationSelectionWithBlankRestaurantLine(TempRestaurantSelection, BlankRestaurantSelection);

        // [GIVEN] The restaurant's counter is at 40 and the blank restaurant's counter is at 900
        SetDisplayOrderCounter(_RestaurantCode, 40, Today());
        SetDisplayOrderCounter('', 900, Today());

        // [WHEN] A kitchen order is created
        DisplayOrderNo := CreateSaleAndGetDisplayOrderNo();
        RestoreStationSelection(TempRestaurantSelection, BlankRestaurantSelection);

        // [THEN] It gets display number 41 from the restaurant's counter, and the blank restaurant's counter is unchanged
        Assert.AreEqual(41, DisplayOrderNo, 'Display number should come from the seating location''s restaurant');
        KitchenOrderCounter.Get('');
        Assert.AreEqual(900, KitchenOrderCounter."Last Display Order No.", 'The blank restaurant''s counter should not change');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SmsTemplate_DisplayOrderNoField_IsMerged()
    var
        NotificationEntry: Record "NPR NPRE Notification Entry";
        SmsTemplateHeader: Record "NPR SMS Template Header";
        SmsTemplateLine: Record "NPR SMS Template Line";
        SmsImplementation: Codeunit "NPR SMS Implementation";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] An SMS template can show the kitchen order's display number through field 2 of the notification entry
        Initialize();

        // [GIVEN] A notification entry for a kitchen order with display number 701, and an SMS template whose text references field 2
        CreateNotificationEntryForDisplayOrderNo(701, NotificationEntry);
        if not SmsTemplateHeader.Get('KDSPLNO') then begin
            SmsTemplateHeader.Code := 'KDSPLNO';
            SmsTemplateHeader."Table No." := Database::"NPR NPRE Notification Entry";
            SmsTemplateHeader.Insert();
            SmsTemplateLine."Template Code" := SmsTemplateHeader.Code;
            SmsTemplateLine."Line No." := 10000;
            SmsTemplateLine."SMS Text" := 'Order {2} is ready';
            SmsTemplateLine.Insert();
        end;

        // [WHEN] The SMS text is merged
        // [THEN] It contains the display number, not the order ID
        Assert.AreEqual('Order 701 is ready', SmsImplementation.MakeMessage(SmsTemplateHeader, NotificationEntry), 'SMS should contain the display order number');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EmailTemplate_DisplayOrderNoField_IsMerged()
    var
        NotificationEntry: Record "NPR NPRE Notification Entry";
        EmailTemplMgt: Codeunit "NPR E-mail Templ. Mgt.";
        Assert: Codeunit Assert;
        RecRef: RecordRef;
    begin
        // [SCENARIO] An e-mail template can show the kitchen order's display number through field 2 of the notification entry
        Initialize();

        // [GIVEN] A notification entry for a kitchen order with display number 701
        CreateNotificationEntryForDisplayOrderNo(701, NotificationEntry);
        RecRef.GetTable(NotificationEntry);

        // [WHEN] The e-mail text is merged
        // [THEN] It contains the display number, not the order ID
        Assert.AreEqual('Order 701 is ready', EmailTemplMgt.MergeMailContent(RecRef, 'Order {2} is ready', '', ''), 'E-mail should contain the display order number');
    end;

    local procedure CreateNotificationEntryForDisplayOrderNo(DisplayOrderNo: Integer; var NotificationEntry: Record "NPR NPRE Notification Entry")
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Assert: Codeunit Assert;
        KitchenOrderId: BigInteger;
    begin
        SetDisplayOrderCounter(_RestaurantCode, DisplayOrderNo - 1, Today());
        Evaluate(KitchenOrderId, CreateSaleWithKitchenOrder(CreateGuid(), CreateGuid(), CreateGuid()));
        KitchenOrder.Get(KitchenOrderId);
        Assert.AreEqual(DisplayOrderNo, KitchenOrder."Display Order No.", 'Kitchen order should get the expected display number');
        NotificationEntry.Init();
        NotificationEntry."Kitchen Order ID" := KitchenOrder."Order ID";
        NotificationEntry.Insert();
    end;

    local procedure ReplaceStationSelectionWithBlankRestaurantLine(var TempRestaurantSelection: Record "NPR NPRE Kitchen Station Slct." temporary; var BlankRestaurantSelection: Record "NPR NPRE Kitchen Station Slct.")
    var
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
    begin
        KitchenStationSelection.SetRange("Restaurant Code", _RestaurantCode);
        KitchenStationSelection.FindSet();
        repeat
            TempRestaurantSelection := KitchenStationSelection;
            TempRestaurantSelection.Insert();
        until KitchenStationSelection.Next() = 0;
        KitchenStationSelection.DeleteAll();

        BlankRestaurantSelection.Init();
        BlankRestaurantSelection."Restaurant Code" := '';
        BlankRestaurantSelection."Seating Location" := '';
        BlankRestaurantSelection."Serving Step" := '';
        BlankRestaurantSelection."Print Category Code" := '';
        BlankRestaurantSelection."Production Restaurant Code" := '';
        BlankRestaurantSelection."Kitchen Station" := TempRestaurantSelection."Kitchen Station";
        BlankRestaurantSelection."Production Step" := 1;
        BlankRestaurantSelection.Insert();
        Commit();
    end;

    local procedure RestoreStationSelection(var TempRestaurantSelection: Record "NPR NPRE Kitchen Station Slct." temporary; var BlankRestaurantSelection: Record "NPR NPRE Kitchen Station Slct.")
    var
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
    begin
        BlankRestaurantSelection.Delete();
        TempRestaurantSelection.FindSet();
        repeat
            KitchenStationSelection := TempRestaurantSelection;
            KitchenStationSelection.Insert();
        until TempRestaurantSelection.Next() = 0;
        Commit();
    end;

    local procedure SetDisplayOrderCounter(RestaurantCode: Code[20]; LastDisplayOrderNo: Integer; LastDisplayOrderDate: Date)
    var
        KitchenOrderCounter: Record "NPR NPRE Kitchen Order Counter";
    begin
        if not KitchenOrderCounter.Get(RestaurantCode) then begin
            KitchenOrderCounter."Restaurant Code" := RestaurantCode;
            KitchenOrderCounter.Insert();
        end;
        KitchenOrderCounter."Last Display Order No." := LastDisplayOrderNo;
        KitchenOrderCounter."Last Display Order Date" := LastDisplayOrderDate;
        KitchenOrderCounter.Modify();
        Commit();
    end;

    local procedure CreateSaleAndGetDisplayOrderNo(): Integer
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenOrderNo: BigInteger;
    begin
        Evaluate(KitchenOrderNo, CreateSaleWithKitchenOrder(CreateGuid(), CreateGuid(), CreateGuid()));
        KitchenOrder.Get(KitchenOrderNo);
        exit(KitchenOrder."Display Order No.");
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        Restaurant: Record "NPR NPRE Restaurant";
        UserSetup: Record "User Setup";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Restaurant');

        NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);

        _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
        _POSUnit.Modify();

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
        _Item."Unit Price" := 100;
        _Item.Modify();

        _CashPaymentMethod.SetRange("Processing Type", _CashPaymentMethod."Processing Type"::CASH);
        _CashPaymentMethod.FindFirst();

        // Setup restaurant for kitchen orders
        LibraryRestaurant.SetupRestaurantForKitchenOrders(_POSUnit, _Seating);
        LibraryRestaurant.SetupItemForKitchenOrders(_Item);

        // Get the restaurant code and ID
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");
        _RestaurantCode := Restaurant.Code;
        _RestaurantId := Restaurant.SystemId;

        CreateCleanupJobQueueEntry();

        _Initialized := true;
        Commit();
    end;

    local procedure CreateSaleWithKitchenOrder(SaleId: Guid; SaleLineId: Guid; PaymentLineId: Guid) KitchenOrderNo: Text
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        KitchenRequest: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenOrderId: BigInteger;
    begin
        // Create sale
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // Add sale line
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // Add payment
        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment should succeed');

        // Complete with kitchen request
        Clear(Body);
        KitchenRequest.Add('seatingCode', _Seating.Code);
        KitchenRequest.Add('noOfGuests', 2);
        Body.Add('kitchenRequest', KitchenRequest);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale with kitchen request should succeed');

        // Get kitchen order number and id from response
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('kitchenOrderNo', JToken), 'Response should contain kitchenOrderNo');
        KitchenOrderNo := JToken.AsValue().AsText();
        Assert.IsTrue(ResponseBody.Get('kitchenOrderId', JToken), 'Response should contain kitchenOrderId');
        Assert.AreNotEqual('', JToken.AsValue().AsText(), 'kitchenOrderId should not be empty');
        Evaluate(KitchenOrderId, KitchenOrderNo);
        KitchenOrder.Get(KitchenOrderId);
        Assert.IsTrue(ResponseBody.Get('kitchenOrderDisplayNo', JToken), 'Response should contain kitchenOrderDisplayNo');
        Assert.AreEqual(KitchenOrder."Display Order No.", JToken.AsValue().AsInteger(), 'kitchenOrderDisplayNo should match the stored display order number');
    end;

    local procedure CreateCleanupJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR JQ Cleanup Dead POS Sales");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR JQ Cleanup Dead POS Sales";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(true);
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif
