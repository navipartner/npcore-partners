codeunit 85414 "NPR NPRE Setup Proxy Tests"
{
    // [FEATURE] Restaurant setup resolution: which level of the setup hierarchy answers each question the rest of the module asks
    Subtype = Test;

    var
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        _Assert: Codeunit Assert;
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _RestaurantInitialized: Boolean;

    #region Resolving the restaurant

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadOnSeating_ProxyInitializedFromPad_SettingsComeFromOwningRestaurant()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        // [SCENARIO] A waiter pad is enough to find the restaurant whose rules apply to it
        // [GIVEN] A restaurant that assigns a new order ID each time, and a pad on one of its seatings
        Initialize();
        SetRestaurantOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"New Each Time");
        SetGlobalOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"Same for Source Document");
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);

        // [WHEN] The proxy is initialized from the pad alone
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);

        // [THEN] It answers with the restaurant behind the pad's seating, not the global setup
        _Assert.AreEqual(
            "NPR NPRE Ord.ID Assign. Method"::"New Each Time", SetupProxy.OrderIDAssignmentMethod(),
            'A proxy initialized from a waiter pad should resolve the restaurant that owns the pad''s seating.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadWithoutSeating_ResolvedProxyReinitialized_PreviousRestaurantSurvives()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        // [SCENARIO] Re-initialising an already resolved proxy from an unseated pad leaves the previous restaurant's
        //            settings in place
        //
        // [!] This pins a defect, not intended behaviour - raised as CORE-1963. SetSeating opens with
        //     "if NewSeatingCode = _Seating.Code then exit", so an unseated pad's '' is a no-op whenever _Seating.Code
        //     is already '': InitializeDefault() never runs, and _Restaurant keeps whatever it held and answers for a
        //     pad that has no restaurant.
        //
        //     Getting there needs a direct SetRestaurant or SetSeatingLocation followed by InitializeUsingWaiterPad on
        //     the same proxy instance, which is what this test does. Arriving from a seated pad does not: SetSeating
        //     (seatingA) leaves _Seating.Code = seatingA, so the next SetSeating('') passes the guard and does reset.
        //     No product object pairs a setter with InitializeUsingWaiterPad on one instance today - every
        //     SetRestaurant and SetSeatingLocation call site uses a proxy local to its procedure, and the one object
        //     that holds a proxy as a codeunit global, "NPR NPRE Restaurant Print", only ever calls
        //     InitializeUsingWaiterPad. So the defect is latent rather than live, and CORE-1963 says so. It is still
        //     worth pinning: the next caller to reuse an instance inherits it silently.
        //
        //     Asserted as-is so the suite states the current behaviour rather than an aspiration. When CORE-1963 is
        //     fixed this test fails, and the expected value becomes the global setup's.
        //
        //     The proxy has to be pointed at a restaurant first for this to mean anything: a fresh instance already
        //     has a blank _Restaurant, so an assertion against the global setup would hold whether the call reset
        //     anything or not.
        // [GIVEN] A proxy already resolved to a restaurant, and a pad with no seating link
        Initialize();
        SetRestaurantOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"New Each Time");
        SetGlobalOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"Same for Source Document");
        WaiterPadMgt.InsertWaiterPad(WaiterPad, true);
        SetupProxy.SetRestaurant(_Restaurant.Code);

        // [WHEN] The proxy is initialized from that pad
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);

        // [THEN] The previously resolved restaurant still answers, rather than the global setup
        _Assert.AreEqual(
            "NPR NPRE Ord.ID Assign. Method"::"New Each Time", SetupProxy.OrderIDAssignmentMethod(),
            'CORE-1963: an unseated pad does not reset the proxy, so the restaurant it last resolved still answers.');
    end;

    #endregion

    #region The setup hierarchy

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantSetsItsOwnValues_ProxyResolves_RestaurantWinsOverGlobal()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        // [SCENARIO] Every setting a restaurant can state for itself outranks the company-wide default
        // [GIVEN] A global setup and a restaurant that contradicts it on every overridable setting
        Initialize();
        RestaurantSetup.Get();
        RestaurantSetup."Auto-Send Kitchen Order" := RestaurantSetup."Auto-Send Kitchen Order"::No;
        RestaurantSetup."Re-send All on New Lines" := RestaurantSetup."Re-send All on New Lines"::No;
        RestaurantSetup."Default Number of Guests" := RestaurantSetup."Default Number of Guests"::Zero;
        // The three booleans are deliberately not all the same, here or in the test below, and the two tests use
        // different patterns - false/true/false against Yes/No/Yes here, true/true/false against Default there. Set
        // together to one value they would be indistinguishable: any of the three inherits wired to the wrong source
        // field would still answer what the assertion expects.
        RestaurantSetup."Kitchen Printing Active" := false;
        RestaurantSetup."Print on POS Sale Cancel" := true;
        RestaurantSetup."KDS Active" := false;
        RestaurantSetup."Order ID Assignment Method" := RestaurantSetup."Order ID Assignment Method"::"Same for Source Document";
        RestaurantSetup."Kitchen Req. Handl. On Serving" := RestaurantSetup."Kitchen Req. Handl. On Serving"::"Do Nothing";
        RestaurantSetup."Order Is Ready For Serving" := RestaurantSetup."Order Is Ready For Serving"::"All Requests";
        RestaurantSetup."Mark Requests as Served" := RestaurantSetup."Mark Requests as Served"::Manual;
        RestaurantSetup."Default Service Flow Profile" := '';
        RestaurantSetup.Modify();

        _Restaurant.Find();
        _Restaurant."Auto Send Kitchen Order" := _Restaurant."Auto Send Kitchen Order"::Yes;
        _Restaurant."Resend All On New Lines" := _Restaurant."Resend All On New Lines"::Yes;
        _Restaurant."Default Number of Guests" := _Restaurant."Default Number of Guests"::One;
        _Restaurant."Kitchen Printing Active" := _Restaurant."Kitchen Printing Active"::Yes;
        _Restaurant."Print on POS Sale Cancel" := _Restaurant."Print on POS Sale Cancel"::No;
        _Restaurant."KDS Active" := _Restaurant."KDS Active"::Yes;
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::"New Each Time";
        _Restaurant."Station Req. Handl. On Serving" := _Restaurant."Station Req. Handl. On Serving"::"Finish All";
        _Restaurant."Order Is Ready For Serving" := _Restaurant."Order Is Ready For Serving"::"Any Request";
        _Restaurant."Mark Requests as Served" := _Restaurant."Mark Requests as Served"::"When Prod. Finished";
        _Restaurant."Service Flow Profile" := _ServFlowProfile.Code;
        _Restaurant.Modify();

        // [WHEN] The proxy resolves that restaurant
        SetupProxy.SetRestaurant(_Restaurant.Code);

        // [THEN] Every answer is the restaurant's, not the global one
        _Assert.AreEqual(
            "NPR NPRE Auto Send Kitch.Order"::Yes, SetupProxy.AutoSendKitchenOrder(),
            'Auto-send should follow the restaurant rather than the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Send All on New Lines"::Yes, SetupProxy.ResendAllOnNewLines(),
            'Resend-all should follow the restaurant rather than the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Default No. of Guests"::One, SetupProxy.DefaultNumberOfGuests(),
            'Default number of guests should follow the restaurant rather than the global setup.');
        _Assert.IsTrue(SetupProxy.KitchenPrintingActivated(), 'Kitchen printing should be on because the restaurant says so.');
        _Assert.IsFalse(SetupProxy.PrintOnSaleCancelActivated(), 'Print on sale cancel should be off because the restaurant says so.');
        _Assert.IsTrue(SetupProxy.KDSActivated(), 'KDS should be on because the restaurant says so.');
        _Assert.AreEqual(
            "NPR NPRE Ord.ID Assign. Method"::"New Each Time", SetupProxy.OrderIDAssignmentMethod(),
            'Order ID assignment should follow the restaurant rather than the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Req.Handl.on Serving"::"Finish All", SetupProxy.StationReqHandlingOnServing(),
            'Station request handling on serving should follow the restaurant rather than the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Order Ready Serving"::"Any Request", SetupProxy.KitchenOrderIsReadyForServingOn(),
            'Order-ready-for-serving should follow the restaurant rather than the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Mark Req. as Served"::"When Prod. Finished", SetupProxy.MarkRequestsAsServed(),
            'Mark-requests-as-served should follow the restaurant rather than the global setup.');
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        _Assert.AreEqual(
            _ServFlowProfile.Code, ServiceFlowProfile.Code,
            'The service flow profile should be the restaurant''s rather than the global default.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantLeavesEverythingDefault_ProxyResolves_GlobalSetupAnswers()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        // [SCENARIO] A restaurant that states nothing inherits the company-wide setup, which is what makes Default mean "ask upstairs"
        // [GIVEN] A global setup with distinct values and a restaurant left entirely on Default
        Initialize();
        RestaurantSetup.Get();
        RestaurantSetup."Auto-Send Kitchen Order" := RestaurantSetup."Auto-Send Kitchen Order"::Ask;
        RestaurantSetup."Re-send All on New Lines" := RestaurantSetup."Re-send All on New Lines"::Ask;
        RestaurantSetup."Default Number of Guests" := RestaurantSetup."Default Number of Guests"::"Min Party Size";
        RestaurantSetup."Kitchen Printing Active" := true;
        RestaurantSetup."Print on POS Sale Cancel" := true;
        RestaurantSetup."KDS Active" := false;
        RestaurantSetup."Order ID Assignment Method" := RestaurantSetup."Order ID Assignment Method"::"Same for Source Document";
        RestaurantSetup."Kitchen Req. Handl. On Serving" := RestaurantSetup."Kitchen Req. Handl. On Serving"::"Cancel All Unfinished";
        RestaurantSetup."Order Is Ready For Serving" := RestaurantSetup."Order Is Ready For Serving"::"Any Request";
        RestaurantSetup."Mark Requests as Served" := RestaurantSetup."Mark Requests as Served"::"When Prod. Finished";
        RestaurantSetup."Default Service Flow Profile" := _ServFlowProfile.Code;
        RestaurantSetup.Modify();

        _Restaurant.Find();
        _Restaurant."Auto Send Kitchen Order" := _Restaurant."Auto Send Kitchen Order"::Default;
        _Restaurant."Resend All On New Lines" := _Restaurant."Resend All On New Lines"::Default;
        _Restaurant."Default Number of Guests" := _Restaurant."Default Number of Guests"::Default;
        _Restaurant."Kitchen Printing Active" := _Restaurant."Kitchen Printing Active"::Default;
        _Restaurant."Print on POS Sale Cancel" := _Restaurant."Print on POS Sale Cancel"::Default;
        _Restaurant."KDS Active" := _Restaurant."KDS Active"::Default;
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::Default;
        _Restaurant."Station Req. Handl. On Serving" := _Restaurant."Station Req. Handl. On Serving"::Default;
        _Restaurant."Order Is Ready For Serving" := _Restaurant."Order Is Ready For Serving"::Default;
        _Restaurant."Mark Requests as Served" := _Restaurant."Mark Requests as Served"::Default;
        _Restaurant."Service Flow Profile" := '';
        _Restaurant.Modify();

        // [WHEN] The proxy resolves that restaurant
        SetupProxy.SetRestaurant(_Restaurant.Code);

        // [THEN] Every answer comes from the global setup
        _Assert.AreEqual(
            "NPR NPRE Auto Send Kitch.Order"::Ask, SetupProxy.AutoSendKitchenOrder(),
            'A restaurant on Default should inherit auto-send from the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Send All on New Lines"::Ask, SetupProxy.ResendAllOnNewLines(),
            'A restaurant on Default should inherit resend-all from the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Default No. of Guests"::"Min Party Size", SetupProxy.DefaultNumberOfGuests(),
            'A restaurant on Default should inherit the default number of guests from the global setup.');
        _Assert.IsTrue(SetupProxy.KitchenPrintingActivated(), 'A restaurant on Default should inherit kitchen printing from the global setup.');
        _Assert.IsTrue(SetupProxy.PrintOnSaleCancelActivated(), 'A restaurant on Default should inherit print-on-cancel from the global setup.');
        _Assert.IsFalse(SetupProxy.KDSActivated(), 'A restaurant on Default should inherit KDS activation from the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Ord.ID Assign. Method"::"Same for Source Document", SetupProxy.OrderIDAssignmentMethod(),
            'A restaurant on Default should inherit order ID assignment from the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Req.Handl.on Serving"::"Cancel All Unfinished", SetupProxy.StationReqHandlingOnServing(),
            'A restaurant on Default should inherit station request handling from the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Order Ready Serving"::"Any Request", SetupProxy.KitchenOrderIsReadyForServingOn(),
            'A restaurant on Default should inherit order-ready-for-serving from the global setup.');
        _Assert.AreEqual(
            "NPR NPRE Mark Req. as Served"::"When Prod. Finished", SetupProxy.MarkRequestsAsServed(),
            'A restaurant on Default should inherit mark-requests-as-served from the global setup.');
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        _Assert.AreEqual(
            _ServFlowProfile.Code, ServiceFlowProfile.Code,
            'A restaurant with no service flow profile should inherit the global default profile.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingLocationSetsItsOwnValues_ProxyResolves_LocationWinsOverRestaurant()
    var
        Seating: Record "NPR NPRE Seating";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        // [SCENARIO] The three settings a seating location can state for itself outrank the restaurant, giving the hierarchy a third level
        // [GIVEN] A restaurant saying Yes/Yes/One and a seating location under it saying No/No/Zero
        Initialize();
        _Restaurant.Find();
        _Restaurant."Auto Send Kitchen Order" := _Restaurant."Auto Send Kitchen Order"::Yes;
        _Restaurant."Resend All On New Lines" := _Restaurant."Resend All On New Lines"::Yes;
        _Restaurant."Default Number of Guests" := _Restaurant."Default Number of Guests"::One;
        _Restaurant.Modify();

        _SeatingLocation.Find();
        _SeatingLocation."Auto Send Kitchen Order" := _SeatingLocation."Auto Send Kitchen Order"::No;
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation."Default Number of Guests" := _SeatingLocation."Default Number of Guests"::Zero;
        _SeatingLocation.Modify();
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);

        // [WHEN] The proxy is pointed at a seating in that location
        SetupProxy.SetSeating(Seating.Code);

        // [THEN] The location's values answer
        _Assert.AreEqual(
            "NPR NPRE Auto Send Kitch.Order"::No, SetupProxy.AutoSendKitchenOrder(),
            'A seating location stating its own auto-send should outrank the restaurant.');
        _Assert.AreEqual(
            "NPR NPRE Send All on New Lines"::No, SetupProxy.ResendAllOnNewLines(),
            'A seating location stating its own resend-all should outrank the restaurant.');
        _Assert.AreEqual(
            "NPR NPRE Default No. of Guests"::Zero, SetupProxy.DefaultNumberOfGuests(),
            'A seating location stating its own default number of guests should outrank the restaurant.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GlobalOnlySettings_ResolvedForARestaurant_StillComeFromGlobalSetup()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        // [SCENARIO] Two settings on the proxy are company-wide by design, and no restaurant can override them
        //
        // [!] Corrects catalogue scenario S3-11, which reads "Given a restaurant configured with a specific layout type".
        //     There is no such field: "Restaurant View Layout" exists only on "NPR NPRE Restaurant Setup", and
        //     GetRestaurantLayoutType() reads it without consulting the restaurant at all. The same is true of
        //     ServingStepDiscoveryMethod(). Both are pinned here as global, which is what the product does.
        Initialize();
        RestaurantSetup.Get();
        RestaurantSetup."Restaurant View Layout" := RestaurantSetup."Restaurant View Layout"::MODERN;
        RestaurantSetup."Serving Step Discovery Method" := RestaurantSetup."Serving Step Discovery Method"::"Item Routing Profiles";
        RestaurantSetup.Modify();

        // [WHEN] The proxy is resolved against a specific restaurant
        SetupProxy.SetRestaurant(_Restaurant.Code);

        // [THEN] Both answers are the global ones
        _Assert.AreEqual(
            "NPR NPRE Restaur. Layout Type"::MODERN, SetupProxy.GetRestaurantLayoutType(),
            'The restaurant view layout is a company-wide setting and should be returned whichever restaurant is resolved.');
        _Assert.AreEqual(
            "NPR NPRE Serv.Step Discovery"::"Item Routing Profiles", SetupProxy.ServingStepDiscoveryMethod(),
            'The serving step discovery method is a company-wide setting and should be returned whichever restaurant is resolved.');
    end;

    #endregion

    #region KDS activation across restaurants

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OneRestaurantRunsKDS_AskedAboutAnyRestaurant_ReturnsTrue()
    var
        RestaurantWithoutKDS: Record "NPR NPRE Restaurant";
        TempRestaurantBefore: Record "NPR NPRE Restaurant" temporary;
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        GlobalKDSActiveBefore: Boolean;
    begin
        // [SCENARIO] KDS-wide behaviour switches on as soon as a single restaurant runs a kitchen display, and off
        //            only when none of them does
        //
        // [!] The negative half is what makes this discriminating. The check scans the whole restaurant table and
        //     nothing can scope it, so with any KDS-active restaurant left in the company - and the library creates
        //     every restaurant with KDS on - the positive assertion holds under any implementation, including one
        //     that simply returned true.
        // [GIVEN] Every restaurant in the company switched off, and the global setup off with them
        Initialize();
        _LibraryRestaurant.CreateRestaurant(RestaurantWithoutKDS, _ServFlowProfile.Code);
        GlobalKDSActiveBefore := GlobalKDSActive();
        CaptureRestaurantKDSFlags(TempRestaurantBefore);
        SetKDSActiveOnEveryRestaurant(false);
        SetGlobalKDSActive(false);

        // [WHEN] The proxy is asked whether any restaurant runs KDS
        // [THEN] It says no
        _Assert.IsFalse(
            SetupProxy.KDSActivatedForAnyRestaurant(),
            'With no restaurant running KDS the any-restaurant check should be false.');

        // [WHEN] One restaurant is switched on
        _Restaurant.Find();
        _LibraryRestaurant.SetRestaurantKDSActive(_Restaurant, true);

        // [THEN] It says yes
        _Assert.IsTrue(
            SetupProxy.KDSActivatedForAnyRestaurant(),
            'One restaurant with KDS active should be enough for the any-restaurant check.');

        // This is the one test in the suite that writes outside its own fixture - it has to, because the check scans
        // every restaurant in the company. Left behind, a global "KDS Active" of false would reach the suites that run
        // after this one, where a restaurant on Default would stop being KDS active and a send would silently produce
        // no kitchen requests at all. Restored here rather than relied on being repaired downstream.
        RestoreRestaurantKDSFlags(TempRestaurantBefore);
        SetGlobalKDSActive(GlobalKDSActiveBefore);
    end;

    local procedure SetKDSActiveOnEveryRestaurant(Active: Boolean)
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        // Company-wide on purpose: KDSActivatedForAnyRestaurant scans the whole table, so leaving any other test's
        // restaurant switched on would make the negative assertion above unfalsifiable.
        if Restaurant.FindSet() then
            repeat
                _LibraryRestaurant.SetRestaurantKDSActive(Restaurant, Active);
            until Restaurant.Next() = 0;
    end;

    local procedure SetGlobalKDSActive(Active: Boolean)
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        RestaurantSetup.Get();
        RestaurantSetup."KDS Active" := Active;
        RestaurantSetup.Modify();
    end;

    local procedure GlobalKDSActive(): Boolean
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        RestaurantSetup.Get();
        exit(RestaurantSetup."KDS Active");
    end;

    local procedure CaptureRestaurantKDSFlags(var TempRestaurant: Record "NPR NPRE Restaurant" temporary)
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        TempRestaurant.Reset();
        TempRestaurant.DeleteAll();
        if Restaurant.FindSet() then
            repeat
                TempRestaurant := Restaurant;
                TempRestaurant.Insert();
            until Restaurant.Next() = 0;
    end;

    local procedure RestoreRestaurantKDSFlags(var TempRestaurant: Record "NPR NPRE Restaurant" temporary)
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        if TempRestaurant.FindSet() then
            repeat
                if Restaurant.Get(TempRestaurant.Code) then
                    if Restaurant."KDS Active" <> TempRestaurant."KDS Active" then begin
                        Restaurant."KDS Active" := TempRestaurant."KDS Active";
                        Restaurant.Modify();
                    end;
            until TempRestaurant.Next() = 0;
    end;

    #endregion

    #region Buffer contract

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NonTemporaryStationBuffer_KitchenStationsRequested_CallRejected()
    var
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        // [SCENARIO] Station routing refuses to fill a real table, because it wipes the buffer it is handed
        // [GIVEN] A non-temporary station selection record
        Initialize();

        // [WHEN] It is passed as the station buffer
        asserterror KitchenOrderMgt.FindApplicableWPLineKitchenStations(KitchenStationSelection, WaiterPadLine, '', '');

        // [THEN] The call is refused rather than deleting the live routing setup
        _Assert.ExpectedError('non-temporary variable');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NonTemporaryRestaurantBuffer_RestaurantListRequested_CallRejected()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        // [SCENARIO] The same guard protects the restaurant list the proxy itself builds
        // [GIVEN] A non-temporary restaurant record
        Initialize();

        // [WHEN] It is passed as the restaurant buffer
        asserterror SetupProxy.GetRestaurantList(Restaurant);

        // [THEN] The call is refused
        _Assert.ExpectedError('non-temporary variable');
    end;

    #endregion

    local procedure Initialize()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        if not _RestaurantInitialized then begin
            _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
            _LibraryRestaurant.CreateMealFlowStatuses();
            _LibraryRestaurant.CreateSeatingFlowStatuses();
            _LibraryRestaurant.CreateServiceFlowProfile(_ServFlowProfile);
            _LibraryRestaurant.CreateRestaurant(_Restaurant, _ServFlowProfile.Code);
            _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
            _RestaurantInitialized := true;
        end;

        // Every test here states the hierarchy level it is exercising, so both levels start from a known blank slate
        // rather than from whatever the previous test left behind.
        _Restaurant.Find();
        _Restaurant."Auto Send Kitchen Order" := _Restaurant."Auto Send Kitchen Order"::Default;
        _Restaurant."Resend All On New Lines" := _Restaurant."Resend All On New Lines"::Default;
        _Restaurant."Default Number of Guests" := _Restaurant."Default Number of Guests"::Default;
        _Restaurant."Kitchen Printing Active" := _Restaurant."Kitchen Printing Active"::Default;
        _Restaurant."Print on POS Sale Cancel" := _Restaurant."Print on POS Sale Cancel"::Default;
        _Restaurant."KDS Active" := _Restaurant."KDS Active"::Default;
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::Default;
        _Restaurant."Station Req. Handl. On Serving" := _Restaurant."Station Req. Handl. On Serving"::Default;
        _Restaurant."Order Is Ready For Serving" := _Restaurant."Order Is Ready For Serving"::Default;
        _Restaurant."Mark Requests as Served" := _Restaurant."Mark Requests as Served"::Default;
        _Restaurant."Service Flow Profile" := _ServFlowProfile.Code;
        _Restaurant.Modify();

        _SeatingLocation.Find();
        _SeatingLocation."Auto Send Kitchen Order" := _SeatingLocation."Auto Send Kitchen Order"::Default;
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::Default;
        _SeatingLocation."Default Number of Guests" := _SeatingLocation."Default Number of Guests"::Default;
        _SeatingLocation.Modify();
        Commit();
    end;

    local procedure SetRestaurantOrderIDAssignment(Method: Enum "NPR NPRE Ord.ID Assign. Method")
    begin
        _Restaurant.Find();
        _Restaurant."Order ID Assign. Method" := Method;
        _Restaurant.Modify();
    end;

    local procedure SetGlobalOrderIDAssignment(Method: Enum "NPR NPRE Ord.ID Assign. Method")
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        RestaurantSetup.Get();
        RestaurantSetup."Order ID Assignment Method" := Method;
        RestaurantSetup.Modify();
    end;
}
