codeunit 85269 "NPR KDS Serving Flow Tests"
{
    // [FEATURE] KDS kitchen request serving flow

    Subtype = Test;

    var
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServeParentRequest_ChildrenServedAndOrderFinished()
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
        GrandchildKitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Serving a parent kitchen request cascades to all descendant requests and finishes the kitchen order
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A kitchen order with a parent request, a child request and a grandchild request
        CreateKitchenOrder(KitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, KitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenRequest(GrandchildKitchenRequest, KitchenOrder, ChildKitchenRequest."Request No.", GrandchildKitchenRequest."Line Status"::Planned);

        // [WHEN] The parent request is marked as served
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);

        // [THEN] Parent and all descendants are served
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        ChildKitchenRequest.Get(ChildKitchenRequest."Request No.");
        GrandchildKitchenRequest.Get(GrandchildKitchenRequest."Request No.");
        Assert.AreEqual(ParentKitchenRequest."Line Status"::Served, ParentKitchenRequest."Line Status", 'Parent request must be served');
        Assert.AreEqual(ChildKitchenRequest."Line Status"::Served, ChildKitchenRequest."Line Status", 'Child request must be served');
        Assert.AreEqual(GrandchildKitchenRequest."Line Status"::Served, GrandchildKitchenRequest."Line Status", 'Grandchild request must be served');
        Assert.IsTrue(ParentKitchenRequest."Served Date-Time" <> 0DT, 'Parent served date-time must be set');
        Assert.IsTrue(ChildKitchenRequest."Served Date-Time" <> 0DT, 'Child served date-time must be set');

        // [THEN] The kitchen order is finished
        KitchenOrder.Get(KitchenOrder."Order ID");
        Assert.AreEqual(KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status", 'Kitchen order must be finished');
        Assert.IsTrue(KitchenOrder."Finished Date-Time" <> 0DT, 'Kitchen order finished date-time must be set');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RevokeServingForParentRequest_ChildrenRevokedAndOrderReadyForServing()
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
        GrandchildKitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Revoking serving of a parent kitchen request cascades to served descendants and reopens the kitchen order
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A served kitchen order with a parent request, a child request and a grandchild request
        CreateKitchenOrder(KitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, KitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenRequest(GrandchildKitchenRequest, KitchenOrder, ChildKitchenRequest."Request No.", GrandchildKitchenRequest."Line Status"::"Ready for Serving");
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);
        KitchenOrder.Get(KitchenOrder."Order ID");
        Assert.AreEqual(KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status", 'Test prerequisite: kitchen order must be finished');

        // [WHEN] Serving is revoked for the parent request
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        KitchenOrderMgt.RevokeServingForRequestLine(ParentKitchenRequest, true);

        // [THEN] Parent and all descendant requests are back to ready for serving
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        ChildKitchenRequest.Get(ChildKitchenRequest."Request No.");
        GrandchildKitchenRequest.Get(GrandchildKitchenRequest."Request No.");
        Assert.AreEqual(ParentKitchenRequest."Line Status"::"Ready for Serving", ParentKitchenRequest."Line Status", 'Parent request serving must be revoked');
        Assert.AreEqual(ChildKitchenRequest."Line Status"::"Ready for Serving", ChildKitchenRequest."Line Status", 'Child request serving must be revoked');
        Assert.AreEqual(GrandchildKitchenRequest."Line Status"::"Ready for Serving", GrandchildKitchenRequest."Line Status", 'Grandchild request serving must be revoked');
        Assert.AreEqual(0DT, ParentKitchenRequest."Served Date-Time", 'Parent served date-time must be cleared');
        Assert.AreEqual(0DT, ChildKitchenRequest."Served Date-Time", 'Child served date-time must be cleared');

        // [THEN] The kitchen order is back to ready for serving
        KitchenOrder.Get(KitchenOrder."Order ID");
        Assert.AreEqual(KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status", 'Kitchen order must be ready for serving');
        Assert.AreEqual(0DT, KitchenOrder."Finished Date-Time", 'Kitchen order finished date-time must be cleared');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServeRequestLines_MultipleOrders_AllOrdersFinished()
    var
        KitchenOrder1: Record "NPR NPRE Kitchen Order";
        KitchenOrder2: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequest1: Record "NPR NPRE Kitchen Request";
        KitchenRequest2: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Serving a filtered set of kitchen requests spanning multiple kitchen orders finishes every affected order
        RestaurantCode := CreateRestaurant();

        // [GIVEN] Two kitchen orders, each with one request ready for serving
        CreateKitchenOrder(KitchenOrder1, RestaurantCode);
        CreateKitchenRequest(KitchenRequest1, KitchenOrder1, 0, KitchenRequest1."Line Status"::"Ready for Serving");
        CreateKitchenOrder(KitchenOrder2, RestaurantCode);
        CreateKitchenRequest(KitchenRequest2, KitchenOrder2, 0, KitchenRequest2."Line Status"::"Ready for Serving");

        // [WHEN] All requests of the restaurant are marked as served in one operation
        KitchenRequest.SetRange("Restaurant Code", RestaurantCode);
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLinesAsServed(KitchenRequest);

        // [THEN] Both requests are served and both kitchen orders are finished
        KitchenRequest1.Get(KitchenRequest1."Request No.");
        KitchenRequest2.Get(KitchenRequest2."Request No.");
        Assert.AreEqual(KitchenRequest1."Line Status"::Served, KitchenRequest1."Line Status", 'First request must be served');
        Assert.AreEqual(KitchenRequest2."Line Status"::Served, KitchenRequest2."Line Status", 'Second request must be served');
        KitchenOrder1.Get(KitchenOrder1."Order ID");
        KitchenOrder2.Get(KitchenOrder2."Order ID");
        Assert.AreEqual(KitchenOrder1."Order Status"::Finished, KitchenOrder1."Order Status", 'First kitchen order must be finished');
        Assert.AreEqual(KitchenOrder2."Order Status"::Finished, KitchenOrder2."Order Status", 'Second kitchen order must be finished');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServeParentRequest_MultipleSiblingChildren_AllChildrenServed()
    var
        ChildKitchenRequest1: Record "NPR NPRE Kitchen Request";
        ChildKitchenRequest2: Record "NPR NPRE Kitchen Request";
        ChildKitchenRequest3: Record "NPR NPRE Kitchen Request";
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Serving a parent kitchen request serves all sibling child requests without skipping any of them
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A kitchen order with a parent request and three sibling child requests
        CreateKitchenOrder(KitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, KitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest1, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest1."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest2, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest2."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest3, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest3."Line Status"::Planned);

        // [WHEN] The parent request is marked as served
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);

        // [THEN] All sibling child requests are served and the kitchen order is finished
        ChildKitchenRequest1.Get(ChildKitchenRequest1."Request No.");
        ChildKitchenRequest2.Get(ChildKitchenRequest2."Request No.");
        ChildKitchenRequest3.Get(ChildKitchenRequest3."Request No.");
        Assert.AreEqual(ChildKitchenRequest1."Line Status"::Served, ChildKitchenRequest1."Line Status", 'First child request must be served');
        Assert.AreEqual(ChildKitchenRequest2."Line Status"::Served, ChildKitchenRequest2."Line Status", 'Second child request must be served');
        Assert.AreEqual(ChildKitchenRequest3."Line Status"::Served, ChildKitchenRequest3."Line Status", 'Third child request must be served');
        KitchenOrder.Get(KitchenOrder."Order ID");
        Assert.AreEqual(KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status", 'Kitchen order must be finished');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RevokeServingForParentRequest_MultipleSiblingChildren_AllChildrenRevoked()
    var
        ChildKitchenRequest1: Record "NPR NPRE Kitchen Request";
        ChildKitchenRequest2: Record "NPR NPRE Kitchen Request";
        ChildKitchenRequest3: Record "NPR NPRE Kitchen Request";
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Revoking serving of a parent kitchen request revokes all served sibling child requests without skipping any of them
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A kitchen order with a served parent request and three served sibling child requests
        CreateKitchenOrder(KitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, KitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest1, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest1."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest2, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest2."Line Status"::"Ready for Serving");
        CreateKitchenRequest(ChildKitchenRequest3, KitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest3."Line Status"::"Ready for Serving");
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);

        // [WHEN] Serving is revoked for the parent request
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        KitchenOrderMgt.RevokeServingForRequestLine(ParentKitchenRequest, true);

        // [THEN] All sibling child requests are back to ready for serving and the kitchen order is reopened
        ChildKitchenRequest1.Get(ChildKitchenRequest1."Request No.");
        ChildKitchenRequest2.Get(ChildKitchenRequest2."Request No.");
        ChildKitchenRequest3.Get(ChildKitchenRequest3."Request No.");
        Assert.AreEqual(ChildKitchenRequest1."Line Status"::"Ready for Serving", ChildKitchenRequest1."Line Status", 'First child request serving must be revoked');
        Assert.AreEqual(ChildKitchenRequest2."Line Status"::"Ready for Serving", ChildKitchenRequest2."Line Status", 'Second child request serving must be revoked');
        Assert.AreEqual(ChildKitchenRequest3."Line Status"::"Ready for Serving", ChildKitchenRequest3."Line Status", 'Third child request serving must be revoked');
        KitchenOrder.Get(KitchenOrder."Order ID");
        Assert.AreEqual(KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status", 'Kitchen order must be ready for serving');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServeParentRequest_ChildInDifferentOrder_BothOrdersFinished()
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
        ChildKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Serving a parent kitchen request whose child belongs to another kitchen order refreshes both kitchen orders
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A parent request on one kitchen order and its child request on a different kitchen order
        CreateKitchenOrder(ParentKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, ParentKitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenOrder(ChildKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ChildKitchenRequest, ChildKitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest."Line Status"::"Ready for Serving");

        // [WHEN] The parent request is marked as served
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);

        // [THEN] Both requests are served and both kitchen orders are finished
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        ChildKitchenRequest.Get(ChildKitchenRequest."Request No.");
        Assert.AreEqual(ParentKitchenRequest."Line Status"::Served, ParentKitchenRequest."Line Status", 'Parent request must be served');
        Assert.AreEqual(ChildKitchenRequest."Line Status"::Served, ChildKitchenRequest."Line Status", 'Child request must be served');
        ParentKitchenOrder.Get(ParentKitchenOrder."Order ID");
        ChildKitchenOrder.Get(ChildKitchenOrder."Order ID");
        Assert.AreEqual(ParentKitchenOrder."Order Status"::Finished, ParentKitchenOrder."Order Status", 'Parent kitchen order must be finished');
        Assert.AreEqual(ChildKitchenOrder."Order Status"::Finished, ChildKitchenOrder."Order Status", 'Child kitchen order must be finished');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RevokeServingForParentRequest_ChildInDifferentOrder_BothOrdersReopened()
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
        ChildKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Revoking serving of a parent kitchen request whose child belongs to another kitchen order reopens both kitchen orders
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A served parent request and its served child request on different kitchen orders
        CreateKitchenOrder(ParentKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, ParentKitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenOrder(ChildKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ChildKitchenRequest, ChildKitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest."Line Status"::"Ready for Serving");
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);

        // [WHEN] Serving is revoked for the parent request
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        KitchenOrderMgt.RevokeServingForRequestLine(ParentKitchenRequest, true);

        // [THEN] Both requests and both kitchen orders are back to ready for serving
        ChildKitchenRequest.Get(ChildKitchenRequest."Request No.");
        Assert.AreEqual(ChildKitchenRequest."Line Status"::"Ready for Serving", ChildKitchenRequest."Line Status", 'Child request serving must be revoked');
        ParentKitchenOrder.Get(ParentKitchenOrder."Order ID");
        ChildKitchenOrder.Get(ChildKitchenOrder."Order ID");
        Assert.AreEqual(ParentKitchenOrder."Order Status"::"Ready for Serving", ParentKitchenOrder."Order Status", 'Parent kitchen order must be ready for serving');
        Assert.AreEqual(ChildKitchenOrder."Order Status"::"Ready for Serving", ChildKitchenOrder."Order Status", 'Child kitchen order must be ready for serving');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RevokeServingWithoutOrderRefresh_NoOrdersRefreshed()
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
        ChildKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Revoking with deferred order refresh revokes the requests but leaves every kitchen order status recomputation to the caller
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A served parent request and its served child request on different kitchen orders, both orders finished
        CreateKitchenOrder(ParentKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, ParentKitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenOrder(ChildKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ChildKitchenRequest, ChildKitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest."Line Status"::"Ready for Serving");
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);
        ChildKitchenOrder.Get(ChildKitchenOrder."Order ID");
        Assert.AreEqual(ChildKitchenOrder."Order Status"::Finished, ChildKitchenOrder."Order Status", 'Test prerequisite: child kitchen order must be finished');

        // [WHEN] Serving is revoked for the parent request without refreshing order statuses
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        KitchenOrderMgt.RevokeServingForRequestLine(ParentKitchenRequest, false);

        // [THEN] Both requests are revoked but neither kitchen order status has been recomputed
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        ChildKitchenRequest.Get(ChildKitchenRequest."Request No.");
        Assert.AreEqual(ParentKitchenRequest."Line Status"::"Ready for Serving", ParentKitchenRequest."Line Status", 'Parent request serving must be revoked');
        Assert.AreEqual(ChildKitchenRequest."Line Status"::"Ready for Serving", ChildKitchenRequest."Line Status", 'Child request serving must be revoked');
        ChildKitchenOrder.Get(ChildKitchenOrder."Order ID");
        ParentKitchenOrder.Get(ParentKitchenOrder."Order ID");
        Assert.AreEqual(ParentKitchenOrder."Order Status"::Finished, ParentKitchenOrder."Order Status", 'Parent kitchen order refresh must be deferred to the caller');
        Assert.AreEqual(ChildKitchenOrder."Order Status"::Finished, ChildKitchenOrder."Order Status", 'Child kitchen order refresh must be deferred to the caller');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServeRequestLines_MultipleOrdersWithChildren_AllServedAndFinished()
    var
        Child1KitchenRequest1: Record "NPR NPRE Kitchen Request";
        Child1KitchenRequest2: Record "NPR NPRE Kitchen Request";
        Child2KitchenRequest1: Record "NPR NPRE Kitchen Request";
        Child2KitchenRequest2: Record "NPR NPRE Kitchen Request";
        KitchenOrder1: Record "NPR NPRE Kitchen Order";
        KitchenOrder2: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        ParentKitchenRequest1: Record "NPR NPRE Kitchen Request";
        ParentKitchenRequest2: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Serving a filtered set of parent requests spanning multiple kitchen orders cascades to all sibling children and finishes every affected order
        RestaurantCode := CreateRestaurant();

        // [GIVEN] Two kitchen orders, each with a parent request and two sibling child requests
        CreateKitchenOrder(KitchenOrder1, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest1, KitchenOrder1, 0, ParentKitchenRequest1."Line Status"::"Ready for Serving");
        CreateKitchenRequest(Child1KitchenRequest1, KitchenOrder1, ParentKitchenRequest1."Request No.", Child1KitchenRequest1."Line Status"::"Ready for Serving");
        CreateKitchenRequest(Child1KitchenRequest2, KitchenOrder1, ParentKitchenRequest1."Request No.", Child1KitchenRequest2."Line Status"::"Ready for Serving");
        CreateKitchenOrder(KitchenOrder2, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest2, KitchenOrder2, 0, ParentKitchenRequest2."Line Status"::"Ready for Serving");
        CreateKitchenRequest(Child2KitchenRequest1, KitchenOrder2, ParentKitchenRequest2."Request No.", Child2KitchenRequest1."Line Status"::"Ready for Serving");
        CreateKitchenRequest(Child2KitchenRequest2, KitchenOrder2, ParentKitchenRequest2."Request No.", Child2KitchenRequest2."Line Status"::"Ready for Serving");

        // [WHEN] All requests of the restaurant are marked as served in one operation
        KitchenRequest.SetRange("Restaurant Code", RestaurantCode);
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLinesAsServed(KitchenRequest);

        // [THEN] All parent and child requests are served and both kitchen orders are finished
        ParentKitchenRequest1.Get(ParentKitchenRequest1."Request No.");
        ParentKitchenRequest2.Get(ParentKitchenRequest2."Request No.");
        Child1KitchenRequest1.Get(Child1KitchenRequest1."Request No.");
        Child1KitchenRequest2.Get(Child1KitchenRequest2."Request No.");
        Child2KitchenRequest1.Get(Child2KitchenRequest1."Request No.");
        Child2KitchenRequest2.Get(Child2KitchenRequest2."Request No.");
        Assert.AreEqual(ParentKitchenRequest1."Line Status"::Served, ParentKitchenRequest1."Line Status", 'First parent request must be served');
        Assert.AreEqual(ParentKitchenRequest2."Line Status"::Served, ParentKitchenRequest2."Line Status", 'Second parent request must be served');
        Assert.AreEqual(Child1KitchenRequest1."Line Status"::Served, Child1KitchenRequest1."Line Status", 'First child of first parent must be served');
        Assert.AreEqual(Child1KitchenRequest2."Line Status"::Served, Child1KitchenRequest2."Line Status", 'Second child of first parent must be served');
        Assert.AreEqual(Child2KitchenRequest1."Line Status"::Served, Child2KitchenRequest1."Line Status", 'First child of second parent must be served');
        Assert.AreEqual(Child2KitchenRequest2."Line Status"::Served, Child2KitchenRequest2."Line Status", 'Second child of second parent must be served');
        KitchenOrder1.Get(KitchenOrder1."Order ID");
        KitchenOrder2.Get(KitchenOrder2."Order ID");
        Assert.AreEqual(KitchenOrder1."Order Status"::Finished, KitchenOrder1."Order Status", 'First kitchen order must be finished');
        Assert.AreEqual(KitchenOrder2."Order Status"::Finished, KitchenOrder2."Order Status", 'Second kitchen order must be finished');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServeParentRequest_GrandchildInThirdOrder_AllOrdersFinished()
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
        ChildKitchenOrder: Record "NPR NPRE Kitchen Order";
        GrandchildKitchenOrder: Record "NPR NPRE Kitchen Order";
        GrandchildKitchenRequest: Record "NPR NPRE Kitchen Request";
        ParentKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Serving a parent kitchen request cascades through a child and grandchild on two other kitchen orders and refreshes all three orders
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A parent request, its child request and its grandchild request, each on its own kitchen order
        CreateKitchenOrder(ParentKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, ParentKitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenOrder(ChildKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ChildKitchenRequest, ChildKitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenOrder(GrandchildKitchenOrder, RestaurantCode);
        CreateKitchenRequest(GrandchildKitchenRequest, GrandchildKitchenOrder, ChildKitchenRequest."Request No.", GrandchildKitchenRequest."Line Status"::"Ready for Serving");

        // [WHEN] The parent request is marked as served
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);

        // [THEN] All three requests are served and all three kitchen orders are finished
        ChildKitchenRequest.Get(ChildKitchenRequest."Request No.");
        GrandchildKitchenRequest.Get(GrandchildKitchenRequest."Request No.");
        Assert.AreEqual(ChildKitchenRequest."Line Status"::Served, ChildKitchenRequest."Line Status", 'Child request must be served');
        Assert.AreEqual(GrandchildKitchenRequest."Line Status"::Served, GrandchildKitchenRequest."Line Status", 'Grandchild request must be served');
        ParentKitchenOrder.Get(ParentKitchenOrder."Order ID");
        ChildKitchenOrder.Get(ChildKitchenOrder."Order ID");
        GrandchildKitchenOrder.Get(GrandchildKitchenOrder."Order ID");
        Assert.AreEqual(ParentKitchenOrder."Order Status"::Finished, ParentKitchenOrder."Order Status", 'Parent kitchen order must be finished');
        Assert.AreEqual(ChildKitchenOrder."Order Status"::Finished, ChildKitchenOrder."Order Status", 'Child kitchen order must be finished');
        Assert.AreEqual(GrandchildKitchenOrder."Order Status"::Finished, GrandchildKitchenOrder."Order Status", 'Grandchild kitchen order must be finished');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RevokeServingForParentRequest_GrandchildInThirdOrder_AllOrdersReopened()
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
        ChildKitchenOrder: Record "NPR NPRE Kitchen Order";
        GrandchildKitchenOrder: Record "NPR NPRE Kitchen Order";
        GrandchildKitchenRequest: Record "NPR NPRE Kitchen Request";
        ParentKitchenOrder: Record "NPR NPRE Kitchen Order";
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
        Assert: Codeunit Assert;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
    begin
        // [SCENARIO] Revoking serving of a parent kitchen request cascades through a child and grandchild on two other kitchen orders and reopens all three orders
        RestaurantCode := CreateRestaurant();

        // [GIVEN] A served parent request, child request and grandchild request, each on its own finished kitchen order
        CreateKitchenOrder(ParentKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ParentKitchenRequest, ParentKitchenOrder, 0, ParentKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenOrder(ChildKitchenOrder, RestaurantCode);
        CreateKitchenRequest(ChildKitchenRequest, ChildKitchenOrder, ParentKitchenRequest."Request No.", ChildKitchenRequest."Line Status"::"Ready for Serving");
        CreateKitchenOrder(GrandchildKitchenOrder, RestaurantCode);
        CreateKitchenRequest(GrandchildKitchenRequest, GrandchildKitchenOrder, ChildKitchenRequest."Request No.", GrandchildKitchenRequest."Line Status"::"Ready for Serving");
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.SetRequestLineAsServed(ParentKitchenRequest);

        // [WHEN] Serving is revoked for the parent request
        ParentKitchenRequest.Get(ParentKitchenRequest."Request No.");
        KitchenOrderMgt.RevokeServingForRequestLine(ParentKitchenRequest, true);

        // [THEN] All three requests and all three kitchen orders are back to ready for serving
        ChildKitchenRequest.Get(ChildKitchenRequest."Request No.");
        GrandchildKitchenRequest.Get(GrandchildKitchenRequest."Request No.");
        Assert.AreEqual(ChildKitchenRequest."Line Status"::"Ready for Serving", ChildKitchenRequest."Line Status", 'Child request serving must be revoked');
        Assert.AreEqual(GrandchildKitchenRequest."Line Status"::"Ready for Serving", GrandchildKitchenRequest."Line Status", 'Grandchild request serving must be revoked');
        ParentKitchenOrder.Get(ParentKitchenOrder."Order ID");
        ChildKitchenOrder.Get(ChildKitchenOrder."Order ID");
        GrandchildKitchenOrder.Get(GrandchildKitchenOrder."Order ID");
        Assert.AreEqual(ParentKitchenOrder."Order Status"::"Ready for Serving", ParentKitchenOrder."Order Status", 'Parent kitchen order must be ready for serving');
        Assert.AreEqual(ChildKitchenOrder."Order Status"::"Ready for Serving", ChildKitchenOrder."Order Status", 'Child kitchen order must be ready for serving');
        Assert.AreEqual(GrandchildKitchenOrder."Order Status"::"Ready for Serving", GrandchildKitchenOrder."Order Status", 'Grandchild kitchen order must be ready for serving');
    end;

    local procedure CreateRestaurant(): Code[20]
    var
        Restaurant: Record "NPR NPRE Restaurant";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        exit(Restaurant.Code);
    end;

    local procedure CreateKitchenOrder(var KitchenOrder: Record "NPR NPRE Kitchen Order"; RestaurantCode: Code[20])
    begin
        KitchenOrder.Init();
        KitchenOrder."Order ID" := 0;
        KitchenOrder."Restaurant Code" := RestaurantCode;
        KitchenOrder."Order Status" := KitchenOrder."Order Status"::Planned;
        KitchenOrder."Created Date-Time" := CurrentDateTime();
        KitchenOrder.Insert();
    end;

    local procedure CreateKitchenRequest(var KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenOrder: Record "NPR NPRE Kitchen Order"; ParentRequestNo: BigInteger; LineStatus: Enum "NPR NPRE K.Request Line Status")
    begin
        KitchenRequest.Init();
        KitchenRequest."Request No." := 0;
        KitchenRequest."Order ID" := KitchenOrder."Order ID";
        KitchenRequest."Restaurant Code" := KitchenOrder."Restaurant Code";
        KitchenRequest."Parent Request No." := ParentRequestNo;
        KitchenRequest."Line Status" := LineStatus;
        KitchenRequest."Production Status" := KitchenRequest."Production Status"::Finished;
        KitchenRequest.Description := 'Test Kitchen Request';
        KitchenRequest."Created Date-Time" := CurrentDateTime();
        KitchenRequest.Insert();
    end;
}
