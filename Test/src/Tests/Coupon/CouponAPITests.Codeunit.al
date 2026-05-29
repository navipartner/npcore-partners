#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85262 "NPR Coupon API Tests"
{
    // [FEATURE] Coupon API end-to-end tests via the API request processor.

    Subtype = Test;

    var
        _CouponType: Record "NPR NpDc Coupon Type";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullLifecycle_CreateReserveCancelReserveRedeem()
    var
        Assert: Codeunit Assert;
        CouponId: Text;
        ReferenceNo: Text;
        DocA: Text;
        DocB: Text;
    begin
        // [SCENARIO] Walk a coupon through create -> reserve -> cancel -> reserve -> redeem.
        Initialize();
        DocA := 'EXT-LIFE-' + Format(CreateGuid());
        DocB := 'EXT-LIFE-' + Format(CreateGuid());

        // [GIVEN] A new coupon
        CouponId := CreateCouponViaApi(ReferenceNo);

        // [THEN] Fresh check reports active with empty reservations
        AssertCheckState(CouponId, 'active');
        AssertReservationCount(CouponId, 0);

        // [WHEN] Reserve with docA
        ReserveCouponViaApi(CouponId, DocA);

        // [THEN] State is reserved (single-use coupon, 1/1 in use); docA is listed
        AssertCheckState(CouponId, 'reserved');
        AssertReservationCount(CouponId, 1);
        AssertReservedByContains(CouponId, DocA);

        // [WHEN] Cancel docA's reservation
        CancelReservationViaApi(CouponId, DocA);

        // [THEN] State is active again
        AssertCheckState(CouponId, 'active');
        AssertReservationCount(CouponId, 0);

        // [WHEN] Reserve and redeem with docB
        ReserveCouponViaApi(CouponId, DocB);
        RedeemCouponViaApi(ReferenceNo, DocB);

        // [THEN] Find by referenceNo surfaces the archived coupon with status CONSUMED
        CouponId := AssertFindByReferenceReturnsConsumed(ReferenceNo);
        AssertCheckRespondsArchived(CouponId);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Reserve_BlockedByAnotherSale()
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        CouponId: Text;
        ReferenceNo: Text;
        DocA: Text;
        DocB: Text;
    begin
        // [SCENARIO] Single-use coupon: when docA holds the reservation, docB cannot reserve.
        Initialize();
        DocA := 'CONFLICT-' + Format(CreateGuid());
        DocB := 'CONFLICT-' + Format(CreateGuid());

        CouponId := CreateCouponViaApi(ReferenceNo);
        ReserveCouponViaApi(CouponId, DocA);

        // [WHEN] docB attempts to reserve
        Clear(Body);
        Body.Add('documentNo', DocB);
        Response := LibraryAPI.CallApi('POST', '/coupon/' + CouponId + '/reservation', Body, QueryParams, Headers);

        // [THEN] 400 with the "reserved by a different document number" message
        Assert.IsFalse(LibraryAPI.IsSuccessStatusCode(Response), 'docB reserve should be rejected');
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'Expected 400');

        ResponseBody := LibraryAPI.GetResponseBody(Response);
        ResponseBody.Get('message', JToken);
        Assert.AreEqual('Coupon is already reserved by a different document number', JToken.AsValue().AsText(), 'Message should describe the conflict');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancel_NonExistentReservation_IsIdempotent()
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        CouponId: Text;
        ReferenceNo: Text;
        DocPhantom: Text;
    begin
        // [SCENARIO] Cancel reservation for a docNo that never reserved -> 200 OK (idempotent),
        // not 400. Caller reconciles via CheckCoupon if they need ground truth.
        Initialize();
        DocPhantom := 'EXT-PHANTOM-' + Format(CreateGuid());

        CouponId := CreateCouponViaApi(ReferenceNo);

        Response := LibraryAPI.CallApi('POST', '/coupon/reservation/' + DocPhantom + '/' + CouponId, Body, QueryParams, Headers);

        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), 'Cancel against unknown documentNo should return 200 (idempotent)');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FindCoupons_BlankReferenceNo_Returns400()
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
    begin
        // [SCENARIO] ?referenceNo= with an empty value is rejected, not silently matched against blank refs.
        Initialize();

        QueryParams.Add('referenceNo', '');
        Response := LibraryAPI.CallApi('GET', '/coupon', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryAPI.IsSuccessStatusCode(Response), 'Blank referenceNo should be rejected');
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'Expected 400');

        ResponseBody := LibraryAPI.GetResponseBody(Response);
        ResponseBody.Get('message', JToken);
        Assert.AreEqual('''referenceNo'' cannot be blank', JToken.AsValue().AsText(), 'Message should explain blank rejection');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCoupon_UnknownId_Returns400CouponNotFound()
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        UnknownId: Text;
    begin
        // [SCENARIO] GET /coupon/<unknown-uuid> returns 400 "Coupon not found".
        Initialize();
        UnknownId := LowerCase(Format(CreateGuid(), 0, 4));

        Response := LibraryAPI.CallApi('GET', '/coupon/' + UnknownId, Body, QueryParams, Headers);

        Assert.IsFalse(LibraryAPI.IsSuccessStatusCode(Response), 'Unknown id should not succeed');
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'Expected 400');

        ResponseBody := LibraryAPI.GetResponseBody(Response);
        ResponseBody.Get('message', JToken);
        Assert.AreEqual('Coupon not found', JToken.AsValue().AsText(), 'Message should be the normalized not-found text');
    end;

    local procedure Initialize()
    var
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        ModuleResolver: Codeunit "NPR CouponModuleResolver";
    begin
        if not _Initialized then begin
            LibraryCoupon.CreateCouponSetup();
            LibraryCoupon.CreateDiscountPctCouponType(
                LibraryUtility.GenerateRandomCode20(_CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"),
                _CouponType, 10);

            LibraryAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), ModuleResolver.GetRequiredPermissionSet());

            _Initialized := true;
        end;
        Commit();
    end;

    local procedure CreateCouponViaApi(var ReferenceNo: Text) CouponId: Text
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Coupon: JsonObject;
    begin
        Body.Add('couponType', _CouponType.Code);
        Body.Add('customerNo', '');
        Response := LibraryAPI.CallApi('POST', '/coupon', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo('Create coupon should succeed: %1', LibraryAPI.GetResponseBody(Response)));

        Coupon := GetCouponObject(LibraryAPI.GetResponseBody(Response));
        CouponId := JsonText(Coupon, 'id');
        ReferenceNo := JsonText(Coupon, 'referenceNo');
        Assert.AreNotEqual('', CouponId, 'Response should include coupon id');
        Assert.AreNotEqual('', ReferenceNo, 'Response should include reference number');
    end;

    local procedure ReserveCouponViaApi(CouponId: Text; DocumentNo: Text)
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('documentNo', DocumentNo);
        Response := LibraryAPI.CallApi('POST', '/coupon/' + CouponId + '/reservation', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo('Reserve for %1 should succeed: %2', DocumentNo, LibraryAPI.GetResponseBody(Response)));
    end;

    local procedure CancelReservationViaApi(CouponId: Text; DocumentNo: Text)
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryAPI.CallApi('POST', '/coupon/reservation/' + DocumentNo + '/' + CouponId, Body, QueryParams, Headers);
        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo('Cancel reservation for %1 should succeed: %2', DocumentNo, LibraryAPI.GetResponseBody(Response)));
    end;

    local procedure RedeemCouponViaApi(ReferenceNo: Text; DocumentNo: Text)
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('referenceNo', ReferenceNo);
        Body.Add('documentNo', DocumentNo);
        Response := LibraryAPI.CallApi('POST', '/coupon/redeem', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo('Redeem for %1 should succeed: %2', DocumentNo, LibraryAPI.GetResponseBody(Response)));
    end;

    local procedure CheckCouponViaApi(CouponId: Text): JsonObject
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryAPI.CallApi('POST', '/coupon/check/' + CouponId, Body, QueryParams, Headers);
        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo('Check coupon should succeed: %1', LibraryAPI.GetResponseBody(Response)));
        exit(LibraryAPI.GetResponseBody(Response));
    end;

    local procedure AssertCheckState(CouponId: Text; ExpectedState: Text)
    var
        Assert: Codeunit Assert;
        ResponseBody: JsonObject;
    begin
        ResponseBody := CheckCouponViaApi(CouponId);
        Assert.AreEqual(ExpectedState, JsonText(ResponseBody, 'state'), 'Unexpected state');
    end;

    local procedure AssertReservationCount(CouponId: Text; ExpectedCount: Integer)
    var
        Assert: Codeunit Assert;
        ResponseBody: JsonObject;
        JToken: JsonToken;
    begin
        ResponseBody := CheckCouponViaApi(CouponId);
        ResponseBody.Get('reservedByDocumentNos', JToken);
        Assert.AreEqual(ExpectedCount, JToken.AsArray().Count(), 'Reservation array length mismatch');
    end;

    local procedure AssertReservedByContains(CouponId: Text; ExpectedDocumentNo: Text)
    var
        Assert: Codeunit Assert;
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ItemToken: JsonToken;
        Found: Boolean;
    begin
        ResponseBody := CheckCouponViaApi(CouponId);
        ResponseBody.Get('reservedByDocumentNos', JToken);
        foreach ItemToken in JToken.AsArray() do
            if ItemToken.AsValue().AsText() = ExpectedDocumentNo then
                Found := true;
        Assert.IsTrue(Found, StrSubstNo('Reservation list should contain %1', ExpectedDocumentNo));
    end;

    local procedure AssertCheckRespondsArchived(CouponId: Text)
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        Message: Text;
    begin
        Response := LibraryAPI.CallApi('POST', '/coupon/check/' + CouponId, Body, QueryParams, Headers);
        Assert.IsFalse(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo('Check on archived coupon should fail: %1', LibraryAPI.GetResponseBody(Response)));
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'Expected 400');

        ResponseBody := LibraryAPI.GetResponseBody(Response);
        ResponseBody.Get('message', JToken);
        Message := JToken.AsValue().AsText();
        Assert.IsTrue((Message = 'Coupon is archived') or (Message = 'Coupon is expired and archived'),
            StrSubstNo('Unexpected archive message: %1', Message));
    end;

    local procedure AssertFindByReferenceReturnsConsumed(ReferenceNo: Text) CouponId: Text
    var
        Assert: Codeunit Assert;
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        CouponsArray: JsonArray;
        CouponToken: JsonToken;
        FoundConsumed: Boolean;
    begin
        QueryParams.Add('referenceNo', ReferenceNo);
        QueryParams.Add('includeArchived', 'true');
        Response := LibraryAPI.CallApi('GET', '/coupon', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo('Find by referenceNo should succeed: %1', LibraryAPI.GetResponseBody(Response)));

        ResponseBody := LibraryAPI.GetResponseBody(Response);
        ResponseBody.Get('coupons', JToken);
        CouponsArray := JToken.AsArray();
        Assert.IsTrue(CouponsArray.Count() >= 1, 'Find should return at least one row for an archived coupon by referenceNo');

        foreach CouponToken in CouponsArray do begin
            if JsonText(CouponToken.AsObject(), 'status') = 'CONSUMED' then begin
                FoundConsumed := true;

                if (JsonText(CouponToken.AsObject(), 'id') <> '') then
                    CouponId := JsonText(CouponToken.AsObject(), 'id');
            end
        end;

        Assert.IsTrue(FoundConsumed, 'Archived row should be present with status CONSUMED');
    end;

    local procedure GetCouponObject(ResponseBody: JsonObject) Coupon: JsonObject
    var
        JToken: JsonToken;
    begin
        if ResponseBody.Get('coupon', JToken) then
            exit(JToken.AsObject());
        exit(ResponseBody);
    end;

    local procedure JsonText(Obj: JsonObject; PropertyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if not Obj.Get(PropertyName, JToken) then
            exit('');
        if not JToken.IsValue() then
            exit('');
        exit(JToken.AsValue().AsText());
    end;
}
#endif
