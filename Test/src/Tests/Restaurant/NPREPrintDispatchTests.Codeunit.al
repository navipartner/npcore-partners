codeunit 85412 "NPR NPRE Print Dispatch Tests"
{
    // [FEATURE] Kitchen print template resolution and job dispatch, and Old/New parity on the shared orchestration
    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _TestPrintHandler: Codeunit "NPR NPRE Test Print Handler";
        _TestRPPreprocess: Codeunit "NPR NPRE Test RP Preprocess";
        _TestRPPreprocessWPad: Codeunit "NPR NPRE Test RP Pre WPad";
        _FlagAtEntry: Boolean;
        _FlagCaptured: Boolean;
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        StarterStepTok: Label 'STARTER', Locked = true;
        NothingToSendErr: Label 'Nothing to send.', Locked = true;

    // SCOPE. Both dispatch routes are covered. The handler codeunit route (the "New Restaurant Print Experience"
    // feature flag) hands the job to a codeunit named on the template, so "NPR NPRE Test Print Handler" stands in for
    // it and reports what it was given. The retail print template route has no such seam - it resolves an
    // "NPR RP Template Header" and prints it - so it is observed one level lower, through
    // "NPR Object Output Mgt.".OnBeforeSendLinePrint, which fires once per dispatched job and lets the subscriber skip
    // the printer. The feature flag defaults to off, so the retail print template route is the one most tenants run.

    #region Template resolution and dispatch, new print experience

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TemplateConfigured_PadSent_JobReachesTheConfiguredHandler()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        Item: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A kitchen print template hands the job to whichever codeunit it names
        // [GIVEN] The new print experience, and a template for kitchen orders naming a handler codeunit
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, Item, WaiterPadLine, MainCourseStepTok);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        SendToKitchen(WaiterPad);

        // [THEN] The named handler ran, and was handed the job for this pad
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The handler named on the print template should have been run once.');
        _Assert.AreEqual(WaiterPad."No.", _TestPrintHandler.CapturedWaiterPadNo(), 'The dispatched job should name the waiter pad it came from.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoLinesOneJob_PadSent_BothLinesInTheJob()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        FirstItem: Record Item;
        SecondItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A handler receives the whole job, not one line at a time
        // [GIVEN] A template that does not split jobs, and a pad with two routed lines
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, FirstItem, FirstLine, MainCourseStepTok);
        AddRoutedLine(WaiterPad, SecondItem, SecondLine, MainCourseStepTok);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        SendToKitchen(WaiterPad);

        // [THEN] One job carried both lines
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'Both lines should have gone out as a single job.');
        _Assert.AreEqual(2, _TestPrintHandler.LastJobLineCount(), 'The job should carry both waiter pad lines.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitByPrintCategory_TwoCategories_TwoJobsDispatched()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        FirstCategory: Record "NPR NPRE Print/Prod. Cat.";
        SecondCategory: Record "NPR NPRE Print/Prod. Cat.";
        FirstItem: Record Item;
        SecondItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A template set to split by print category sends one job per category, so each section
        //            of the kitchen gets its own ticket
        // [GIVEN] A splitting template and two lines carrying different print categories
        Initialize();
        SetNewPrintExperience(true);
        _LibraryRestaurant.CreatePrintCategory(FirstCategory);
        _LibraryRestaurant.CreatePrintCategory(SecondCategory);
        CreatePrintTemplate(PrintTemplateOption."Split Print Jobs By"::"Print Category", '');
        CreatePadWithRoutedLine(WaiterPad, FirstItem, FirstLine, MainCourseStepTok, FirstCategory.Code);
        AddRoutedLine(WaiterPad, SecondItem, SecondLine, MainCourseStepTok, SecondCategory.Code);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        SendToKitchen(WaiterPad);

        // [THEN] Two separate jobs were dispatched
        _Assert.AreEqual(2, _TestPrintHandler.InvocationCount(), 'Splitting by print category should dispatch one job per category.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadInTwoRestaurants_OnlyGenericTemplate_LineQueuedOnce()
    var
        Item: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A pad whose seatings span two restaurants, served by one generic template, prints each dish once
        //
        // Template resolution runs once per seating location the pad is linked to and, for each location that found
        // nothing, once more for a blank location under that location's restaurant. "Seating Location" is never
        // relaxed, so a generic template - blank restaurant, blank seating location - cannot be matched on the
        // per-location passes and is reached twice on the blank ones, once per restaurant. Both passes resolve the
        // same template and buffer the same lines, and the dispatch groups on the handler codeunit without filtering
        // "Entry No.", so without a duplicate guard every dish reaches the kitchen twice on one ticket.
        //
        // [GIVEN] One generic kitchen order template, and a pad seated in two restaurants
        Initialize();
        SetNewPrintExperience(true);
        CreateGenericPrintTemplate();
        CreatePadWithRoutedLine(WaiterPad, Item, WaiterPadLine, MainCourseStepTok);
        LinkPadToASeatingInAnotherRestaurant(WaiterPad);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        SendToKitchen(WaiterPad);

        // [THEN] One job went out, carrying the line once
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The generic template should have produced a single job.');
        _Assert.AreEqual(
            1, _TestPrintHandler.LastJobLineCount(),
            'The line should be on the ticket once. Twice means both blank-location passes queued it.');
        RestoreNewPrintExperience();
    end;

    #endregion

    #region Template resolution and dispatch, retail print template route

    // Both tests here bind "NPR Retail Print Handler" around the send. It is not what they measure - that is the
    // stand-in pre-processing codeunit - but the job does reach "NPR Object Output Mgt." and, with no output
    // configured for a freshly created template, that opens the printer selection page. The handler's subscriber sets
    // Skip before that happens, so nothing is asked for and nothing leaves the session.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LegacyRoute_TwoLinesOneTemplate_BothLinesInOneJob()
    var
        PrintTempl: Record "NPR NPRE Print Templ.";
        FirstItem: Record Item;
        SecondItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
    begin
        // [SCENARIO] With the feature flag off, a pad with two lines and one template prints one ticket
        //
        // This is the acceptance test for the group the retail print template dispatch builds by hand. The two routes
        // share one output buffer whose primary key is a surrogate entry number, so the group cannot be taken from
        // SetRecFilter() - that would select a single row and turn every waiter pad line into its own ticket. Nothing
        // else in the suite reaches this code: the parity test runs with kitchen printing off.
        //
        // [GIVEN] The retail print template route, a template that does not split jobs, and a pad with two lines
        Initialize();
        SetNewPrintExperience(false);
        CreateLegacyPrintTemplate(PrintTempl."Split Print Jobs By"::None);
        CreatePadWithRoutedLine(WaiterPad, FirstItem, FirstLine, MainCourseStepTok);
        AddRoutedLine(WaiterPad, SecondItem, SecondLine, MainCourseStepTok);
        _TestRPPreprocess.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        BindSubscription(RetailPrintHandler);
        SendToKitchen(WaiterPad);
        UnbindSubscription(RetailPrintHandler);

        // [THEN] One print job was dispatched, and it selected both lines
        _Assert.AreEqual(
            1, PrintLogCount(WaiterPad."No.", FirstLine."Line No."),
            'The template should have been resolved for the line. Without that the job count below is vacuous.');
        _Assert.AreEqual(
            1, _TestRPPreprocess.InvocationCount(),
            'Both lines belong to one print group and should have gone out as a single job.');
        _Assert.AreEqual(
            WaiterPad."No.", _TestRPPreprocess.CapturedWaiterPadNo(), 'The job should have carried this pad.');
        _Assert.AreEqual(
            2, _TestRPPreprocess.JobLineCount(1),
            'The job should have selected both dishes. A job that selected none would still be one job.');
        _Assert.AreEqual(
            1, _TestRPPreprocess.JobIndexContainingLine(FirstLine."Line No."), 'The first dish should be on the ticket.');
        _Assert.AreEqual(
            1, _TestRPPreprocess.JobIndexContainingLine(SecondLine."Line No."), 'The second dish should be on the ticket.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LegacyRoute_TemplateSplitByServingStep_OneJobPerStep()
    var
        PrintTempl: Record "NPR NPRE Print Templ.";
        StarterItem: Record Item;
        MainItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        StarterLine: Record "NPR NPRE Waiter Pad Line";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
    begin
        // [SCENARIO] A template split by serving step prints the starter and the main course on separate tickets
        //
        // The companion to the test above: that one fails if the group is too narrow, this one fails if it is too
        // wide. Together they pin the hand-written group to the fields the legacy buffer's primary key used to supply.
        //
        // [GIVEN] The retail print template route, a template split by serving step, and a line in each step
        Initialize();
        SetNewPrintExperience(false);
        CreateLegacyPrintTemplate(PrintTempl."Split Print Jobs By"::"Serving Step");
        CreatePadWithRoutedLine(WaiterPad, StarterItem, StarterLine, StarterStepTok);
        AddRoutedLine(WaiterPad, MainItem, MainLine, MainCourseStepTok);
        _TestRPPreprocess.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        BindSubscription(RetailPrintHandler);
        SendToKitchen(WaiterPad);
        UnbindSubscription(RetailPrintHandler);

        // [THEN] Each serving step got its own print job, carrying that step's dish and no other
        _Assert.AreEqual(
            2, _TestRPPreprocess.InvocationCount(), 'Splitting by serving step should dispatch one job per step.');
        _Assert.AreEqual(
            1, _TestRPPreprocess.JobLineCount(1), 'The first ticket should carry one dish.');
        _Assert.AreEqual(
            1, _TestRPPreprocess.JobLineCount(2), 'The second ticket should carry one dish.');
        _Assert.AreNotEqual(
            _TestRPPreprocess.JobIndexContainingLine(StarterLine."Line No."),
            _TestRPPreprocess.JobIndexContainingLine(MainLine."Line No."),
            'The starter and the main course should be on different tickets.');
        _Assert.AreNotEqual(
            0, _TestRPPreprocess.JobIndexContainingLine(StarterLine."Line No."), 'The starter should be on a ticket at all.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LegacyRoute_WaiterPadHeaderTemplate_OneJobForThePad()
    var
        PrintTempl: Record "NPR NPRE Print Templ.";
        FirstItem: Record Item;
        SecondItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
    begin
        // [SCENARIO] A template built on the waiter pad rather than its lines prints the pad once
        //
        // The dispatch branches on the resolved template's "Table ID": a waiter pad line template is handed the marked
        // set of lines, a waiter pad template is handed the pad itself with SetRecFilter(). The two tests above cover
        // the line branch; this one covers the header branch, which is the shape a pre-receipt uses.
        //
        // [GIVEN] The retail print template route and a kitchen order template built on the waiter pad table
        Initialize();
        SetNewPrintExperience(false);
        CreateLegacyWaiterPadTemplate(PrintTempl."Split Print Jobs By"::None);
        CreatePadWithRoutedLine(WaiterPad, FirstItem, FirstLine, MainCourseStepTok);
        AddRoutedLine(WaiterPad, SecondItem, SecondLine, MainCourseStepTok);
        _TestRPPreprocessWPad.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        BindSubscription(RetailPrintHandler);
        SendToKitchen(WaiterPad);
        UnbindSubscription(RetailPrintHandler);

        // [THEN] One job went out, and it selected this pad and only this pad
        _Assert.AreEqual(
            1, _TestRPPreprocessWPad.InvocationCount(),
            'Two lines on one pad are one print group, so the pad should have been printed once.');
        _Assert.AreEqual(
            1, _TestRPPreprocessWPad.CapturedPadCount(),
            'The job should have been narrowed to a single pad. Without SetRecFilter it would carry every pad.');
        _Assert.AreEqual(
            WaiterPad."No.", _TestRPPreprocessWPad.CapturedWaiterPadNo(), 'The job should have carried this pad.');
        RestoreNewPrintExperience();
    end;

    #endregion

    #region Old and New parity on the shared orchestration

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SamePadUnderBothImplementations_SameKitchenOutcome()
    var
        OldPathPad: Record "NPR NPRE Waiter Pad";
        NewPathPad: Record "NPR NPRE Waiter Pad";
        OldItem: Record Item;
        NewItem: Record Item;
        OldLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] The two print implementations put the same work in front of the kitchen
        //
        // This is the guard against the two copy-pasted orchestration bodies drifting apart, and it is the
        // acceptance test for stage 2b, which removes the duplication by unifying the output buffers. It asserts
        // on the shared outcome - kitchen requests and print log entries - and not on the dispatch tail, which
        // genuinely differs between the two and is covered for the new experience only.
        //
        // [GIVEN] Kitchen printing off, so both implementations do KDS output through the shared path only.
        //         Leaving printing on would drag the dispatch tails in, and those genuinely differ - which is
        //         the thing this test must not compare.
        Initialize();
        SetKitchenPrintingActive(false);

        // [WHEN] An equivalent pad is sent under the legacy implementation and then under the new one
        SetNewPrintExperience(false);
        CreatePadWithRoutedLine(OldPathPad, OldItem, OldLine, MainCourseStepTok);
        SendToKitchen(OldPathPad);

        SetNewPrintExperience(true);
        CreatePadWithRoutedLine(NewPathPad, NewItem, NewLine, MainCourseStepTok);
        SendToKitchen(NewPathPad);

        // [THEN] Both produced the same number of kitchen requests and the same print log
        _Assert.AreEqual(
            KitchenRequestCount(OldPathPad."No."), KitchenRequestCount(NewPathPad."No."),
            'Both print implementations should raise the same kitchen requests for an equivalent pad.');
        _Assert.AreEqual(
            KdsLogCount(OldPathPad."No.", OldLine."Line No."), KdsLogCount(NewPathPad."No.", NewLine."Line No."),
            'Both print implementations should log the send the same way.');
        _Assert.AreEqual(1, KitchenRequestCount(NewPathPad."No."), 'Each pad should have produced exactly one kitchen request.');
        // The log comparison above is a relative one, so a regression that stopped writing KDS log entries would break
        // both sides equally and still compare equal. This anchors one side to an absolute value.
        _Assert.AreEqual(
            1, KdsLogCount(NewPathPad."No.", NewLine."Line No."), 'Each pad should have produced exactly one KDS print log entry.');
        RestoreNewPrintExperience();
    end;

    #endregion

    #region Item add-on lines on step-specific serving requests

    // An add-on item with no routing profile has no serving step and no print category of its own. A serving request
    // for one step selects lines by serving step, so these tests check that such an add-on goes out with the dish it is
    // attached to, and that nothing else is pulled in with it.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnroutedAddOn_ServingRequestedForDishStep_AddOnOnTheDishTicketAndLogged()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A serving request for the dish's step prints the dish's unrouted add-on on the same ticket
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course
        //         dish with an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] One ticket went out, and it carried both the dish and its add-on
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The serving request should have gone out as a single job.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on the ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."),
            _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The add-on should be on the same ticket as its dish.');

        // [THEN] The add-on is logged as serving requested at the main course step
        AddOnLine.Find();
        AddOnLine.SetRange("Output Type Filter", AddOnLine."Output Type Filter"::Print);
        AddOnLine.SetRange("Serving Step Filter", MainCourseStepTok);
        AddOnLine.CalcFields("Serving Requested");
        _Assert.IsTrue(AddOnLine."Serving Requested", 'The add-on should be logged as serving requested at the main course step.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LegacyRoute_UnroutedAddOn_ServingRequestedForDishStep_AddOnOnTheDishTicket()
    var
        PrintTempl: Record "NPR NPRE Print Templ.";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
    begin
        // [SCENARIO] On the retail print template route, a serving request for the dish's step prints the dish's
        //            unrouted add-on on the same ticket
        // [GIVEN] The retail print template route, a serving request template that does not split jobs, and a main
        //         course dish with an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(false);
        CreateLegacyPrintTemplate(PrintTempl."Print Type"::"Serving Request", PrintTempl."Split Print Jobs By"::None);
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        _TestRPPreprocess.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        BindSubscription(RetailPrintHandler);
        RequestServing(WaiterPad, MainCourseStepTok);
        UnbindSubscription(RetailPrintHandler);

        // [THEN] One print job went out, and it selected both the dish and its add-on
        _Assert.AreEqual(1, _TestRPPreprocess.InvocationCount(), 'The serving request should have gone out as a single job.');
        _Assert.AreNotEqual(0, _TestRPPreprocess.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on the ticket.');
        _Assert.AreEqual(
            _TestRPPreprocess.JobIndexContainingLine(DishLine."Line No."),
            _TestRPPreprocess.JobIndexContainingLine(AddOnLine."Line No."),
            'The add-on should be on the same ticket as its dish.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TemplateSplitByServingStep_UnroutedAddOn_ServingRequested_AddOnOnTheDishTicket()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A serving request template split by serving step keeps an unrouted add-on on its dish's ticket
        // [GIVEN] The new print experience, a serving request template split by serving step, and a main course dish
        //         with an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::"Serving Step", '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] One ticket went out, and the add-on is on it together with the dish
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The dish and its add-on should have gone out as a single job.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on the ticket.');
        // This is the assertion that fails without the fix: the add-on is not selected for the step at all, so it is on
        // no ticket.
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."),
            _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The add-on should be on the same ticket as its dish, not split off by serving step.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishesInTwoSteps_ServingRequestedForOneStep_OnlyThatDishAndItsAddOnPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        MainItem: Record Item;
        StarterItem: Record Item;
        MainAddOnItem: Record Item;
        StarterAddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        StarterLine: Record "NPR NPRE Waiter Pad Line";
        MainAddOnLine: Record "NPR NPRE Waiter Pad Line";
        StarterAddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A serving request for one step prints that step's dish with its add-on, and leaves the other
        //            step's dish and add-on alone
        // [GIVEN] The new print experience, a serving request template that does not split jobs, a main course dish
        //         and a starter dish, each with an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, MainItem, MainLine, MainCourseStepTok);
        CreateAddOnItem(MainAddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainAddOnItem."No.", 1, MainLine."Line No.", MainAddOnLine);
        AddRoutedLine(WaiterPad, StarterItem, StarterLine, StarterStepTok);
        CreateAddOnItem(StarterAddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", StarterAddOnItem."No.", 1, StarterLine."Line No.", StarterAddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] One ticket went out with the main course dish and its add-on, and nothing from the starter
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The serving request should have gone out as a single job.');
        _Assert.AreEqual(2, _TestPrintHandler.JobLineCount(1), 'The ticket should carry the main course dish and its add-on only.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(MainLine."Line No."), 'The main course dish should be on the ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(MainLine."Line No."),
            _TestPrintHandler.JobIndexContainingLine(MainAddOnLine."Line No."),
            'The main course add-on should be on the same ticket as its dish.');
        _Assert.AreEqual(0, _TestPrintHandler.JobIndexContainingLine(StarterLine."Line No."), 'The starter dish should not be on the ticket.');
        _Assert.AreEqual(
            0, _TestPrintHandler.JobIndexContainingLine(StarterAddOnLine."Line No."), 'The starter add-on should not be on the ticket.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoDishesWithAddOnsInOneStep_ServingRequested_AllFourLinesOnOneTicket()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        FirstItem: Record Item;
        SecondItem: Record Item;
        FirstAddOnItem: Record Item;
        SecondAddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
        FirstAddOnLine: Record "NPR NPRE Waiter Pad Line";
        SecondAddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Two main course dishes, each with its own unrouted add-on, both bring their add-on onto the ticket
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and two main course
        //         dishes, each with an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, FirstItem, FirstLine, MainCourseStepTok);
        CreateAddOnItem(FirstAddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", FirstAddOnItem."No.", 1, FirstLine."Line No.", FirstAddOnLine);
        AddRoutedLine(WaiterPad, SecondItem, SecondLine, MainCourseStepTok);
        CreateAddOnItem(SecondAddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", SecondAddOnItem."No.", 1, SecondLine."Line No.", SecondAddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] One ticket went out with both dishes and both add-ons, each line once
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The serving request should have gone out as a single job.');
        _Assert.AreNotEqual(
            0, _TestPrintHandler.JobIndexContainingLine(FirstAddOnLine."Line No."), 'The first add-on should be on the ticket.');
        _Assert.AreNotEqual(
            0, _TestPrintHandler.JobIndexContainingLine(SecondAddOnLine."Line No."), 'The second add-on should be on the ticket.');
        _Assert.AreEqual(
            4, _TestPrintHandler.JobLineCount(1), 'The ticket should carry both dishes and both add-ons, each once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnOfAnAddOn_ServingRequested_OnlyTheDirectAddOnJoinsTheDish()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        MainItem: Record Item;
        AddOnItem: Record Item;
        SubAddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SubAddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Only add-ons attached directly to the dish go out with it. An add-on attached to another add-on is
        //            not picked up.
        // [GIVEN] The new print experience, a serving request template that does not split jobs, a main course dish, an
        //         add-on attached to it and a second add-on attached to that add-on, neither add-on routed
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, MainItem, MainLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        CreateAddOnItem(SubAddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainLine."Line No.", AddOnLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", SubAddOnItem."No.", 1, AddOnLine."Line No.", SubAddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] The direct add-on is on the dish's ticket, and the add-on of the add-on is neither printed nor logged
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(MainLine."Line No."), 'The dish should be on the ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(MainLine."Line No."),
            _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The direct add-on should be on the same ticket as its dish.');
        _Assert.AreEqual(
            0, _TestPrintHandler.JobIndexContainingLine(SubAddOnLine."Line No."), 'The add-on of the add-on should not be on any ticket.');
        _Assert.AreEqual(
            0, PrintLogCount(WaiterPad."No.", SubAddOnLine."Line No."), 'The add-on of the add-on should not be logged as printed.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RoutedAddOnWithUnroutedAddOn_ServingRequested_UnroutedAddOnNotPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        SubAddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SubAddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Unrouted add-ons join only a top-level dish. An add-on routed to the dish's step goes out on its own
        //            routing, and does not bring along the unrouted add-on attached to it.
        // [GIVEN] The new print experience, a serving request template that does not split jobs, a main course dish, an
        //         add-on routed to the main course attached to the dish, and an unrouted add-on attached to that add-on
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        AddRoutedLine(WaiterPad, AddOnItem, AddOnLine, MainCourseStepTok, '', DishLine."Line No.");
        CreateAddOnItem(SubAddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", SubAddOnItem."No.", 1, AddOnLine."Line No.", SubAddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] The routed add-on is on the dish's ticket, and the unrouted add-on attached to it is neither printed
        //        nor logged
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on the ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."),
            _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The routed add-on should be on the same ticket as its dish.');
        _Assert.AreEqual(
            0, _TestPrintHandler.JobIndexContainingLine(SubAddOnLine."Line No."),
            'The unrouted add-on of a routed add-on should not be on any ticket.');
        _Assert.AreEqual(
            0, PrintLogCount(WaiterPad."No.", SubAddOnLine."Line No."),
            'The unrouted add-on of a routed add-on should not be logged as printed.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TemplateSplitByPrintCategory_UnroutedAddOn_ServingRequested_AddOnTakesTheDishCategory()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        // [SCENARIO] An unrouted add-on takes its dish's print category, so a template split by print category keeps it
        //            on the dish's ticket and logs it under the dish's category and step
        // [GIVEN] The new print experience, a serving request template split by print category, and a main course dish
        //         with a print category and an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(true);
        _LibraryRestaurant.CreatePrintCategory(PrintCategory);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::"Print Category", '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok, PrintCategory.Code);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] One ticket went out, carrying the add-on once together with the dish
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The dish and its add-on should have gone out as a single job.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on the ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."),
            _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The add-on should be on the same ticket as its dish, not split off by print category.');
        _Assert.AreEqual(1, _TestPrintHandler.JobCountContainingLine(AddOnLine."Line No."), 'The add-on should be on one ticket only.');

        // [THEN] The add-on's serving request is logged under the dish's print category and serving step
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPad."No.");
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", AddOnLine."Line No.");
        WPadLinePrintLogEntry.SetRange("Output Type", WPadLinePrintLogEntry."Output Type"::Print);
        WPadLinePrintLogEntry.SetRange("Print Type", WPadLinePrintLogEntry."Print Type"::"Serving Request");
        _Assert.AreEqual(1, WPadLinePrintLogEntry.Count(), 'The add-on''s serving request should be logged once.');
        WPadLinePrintLogEntry.FindFirst();
        _Assert.AreEqual(
            PrintCategory.Code, WPadLinePrintLogEntry."Print Category Code",
            'The add-on should be logged under the dish''s print category.');
        _Assert.AreEqual(
            MainCourseStepTok, WPadLinePrintLogEntry."Flow Status Code", 'The add-on should be logged at the dish''s serving step.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenOrderSplitByServingStep_UnroutedAddOn_AddOnStaysOnItsOwnTicket()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A kitchen order still prints an unrouted add-on apart from its dish. Only step-specific serving
        //            requests move the add-on onto the dish's ticket.
        // [GIVEN] The new print experience, a kitchen order template split by serving step, and a main course dish with
        //         an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Kitchen Order", PrintTemplateOption."Split Print Jobs By"::"Serving Step", '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] The pad is sent to the kitchen
        SendToKitchen(WaiterPad);

        // [THEN] The dish and the add-on are on separate tickets, the dish's ticket carries the dish alone, and the
        //        add-on is logged as printed once
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on a ticket.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."), 'The add-on should be on a ticket.');
        _Assert.AreNotEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."),
            _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'On a kitchen order the add-on should stay on its own ticket.');
        _Assert.AreEqual(
            1, _TestPrintHandler.JobLineCount(_TestPrintHandler.JobIndexContainingLine(DishLine."Line No.")),
            'The dish''s ticket should carry the dish only.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestForSelectedLines_UnroutedAddOn_AddOnPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        // [SCENARIO] A serving request for selected lines with no serving step, as the waiter pad page sends it, still
        //            prints an unrouted add-on
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course dish
        //         with an add-on that has no routing of its own
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for both selected lines, without a serving step
        WaiterPad.Find();
        RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, true);

        // [THEN] The add-on is logged as printed once
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnRoutedToAnotherStep_ServingRequestedForDishStep_AddOnNotPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] An add-on with a serving step of its own follows its own step, not its dish's
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course dish
        //         with an add-on routed to the starter step
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        AddRoutedLine(WaiterPad, AddOnItem, AddOnLine, StarterStepTok, '', DishLine."Line No.");
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] One ticket went out with the dish alone
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The serving request should have gone out as a single job.');
        _Assert.AreEqual(1, _TestPrintHandler.JobLineCount(1), 'The ticket should carry the dish only.');
        _Assert.AreEqual(
            0, _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."), 'The add-on routed to the starter should not be on the ticket.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnWithPrintCategoryOnly_ServingRequestedForDishStep_AddOnNotPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] An add-on with a print category but no serving step is routed, so it does not join its dish's ticket
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course dish
        //         with an add-on whose routing profile assigns a print category and no serving step
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreatePrintCategory(PrintCategory);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignPrintCategoryToRoutingProfile(ItemRoutingProfile, PrintCategory.Code);
        _LibraryRestaurant.LinkItemToRoutingProfile(AddOnItem, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        _Assert.AreEqual(0, AddOnLine.TotalNoOfServingSteps(), 'The add-on should have no serving step of its own.');
        _Assert.IsTrue(AddOnLine.TotalNoOfPrintCategories() > 0, 'The add-on should have a print category of its own.');
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] The dish is on the ticket, and the add-on is neither printed nor logged
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on the ticket.');
        _Assert.AreEqual(
            0, _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."), 'The add-on with a print category should not be on the ticket.');
        _Assert.AreEqual(
            0, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on with a print category should not be logged as printed.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestedTwice_UnroutedAddOn_SecondRequestHasNothingToSend()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Once serving has been requested for the dish, a repeated serving request does not reprint its add-on alone
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course dish
        //         with an add-on that has no routing of its own, whose serving has already been requested
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested again
        asserterror RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] The request reports there is nothing to send, and no ticket went out
        _Assert.ExpectedError(NothingToSendErr);
        _Assert.AreEqual(0, _TestPrintHandler.InvocationCount(), 'A repeated serving request should not print anything.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishQuantityChangedAfterServingRequested_ServingRequestedAgain_AddOnPrintedWithMain()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        PrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        // [SCENARIO] When the dish quantity changed after its serving step was requested, requesting that step again prints
        //            the unrouted add-on on the dish's ticket again
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with an unrouted add-on, whose serving has been requested, after which the dish
        //         quantity went from 1 to 2
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        SetLineQuantity(DishLine, 2);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the main course again
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] The add-on is on the dish's ticket and is logged a second time at the main course, with a sent quantity of
        //        0 because only the dish changed
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The changed dish should be on a ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The add-on should be on the dish ticket.');
        PrintLogEntry.SetRange("Waiter Pad No.", WaiterPad."No.");
        PrintLogEntry.SetRange("Waiter Pad Line No.", AddOnLine."Line No.");
        PrintLogEntry.SetRange("Print Type", PrintLogEntry."Print Type"::"Serving Request");
        PrintLogEntry.SetRange("Output Type", PrintLogEntry."Output Type"::Print);
        PrintLogEntry.SetRange("Flow Status Code", MainCourseStepTok);
        _Assert.AreEqual(2, PrintLogEntry.Count(), 'The add-on should be logged twice at the main course.');
        PrintLogEntry.FindLast();
        _Assert.AreEqual(0, PrintLogEntry."Sent Quanity (Base)", 'The second add-on log entry should have a sent quantity of 0.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnAddedAfterServingRequested_ServingRequestedAgain_NothingToSend()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] An unrouted add-on attached after serving was requested for its dish is not printed by a repeated serving request,
        //            because it goes out only with its dish
        // [GIVEN] The new print experience, a serving request template that does not split jobs, a main course dish whose
        //         serving has already been requested, and an add-on with no routing of its own attached to it afterwards
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        RequestServing(WaiterPad, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested again
        asserterror RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] The request reports that there is nothing to send. asserterror rolls back the add-on line,
        //        so the error is the only result the test can check
        _Assert.ExpectedError(NothingToSendErr);
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnroutedAddOn_SentAndServingRequested_NoExtraKitchenRequestOrKdsEntry()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Moving an unrouted add-on onto its dish's serving ticket changes printing only. The kitchen display
        //            gets no extra request and no KDS entry for the add-on.
        // [GIVEN] The new print experience, kitchen order and serving request templates that do not split jobs, and a
        //         main course dish with an add-on that has no routing of its own, sent to the kitchen
        Initialize();
        SetNewPrintExperience(true);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Kitchen Order", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        SendToKitchen(WaiterPad);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving of the main course is requested
        RequestServing(WaiterPad, MainCourseStepTok);

        // [THEN] The pad has one kitchen request, and the add-on has no KDS entry of its own
        _Assert.AreEqual(1, KitchenRequestCount(WaiterPad."No."), 'The pad should have exactly one kitchen request.');
        _Assert.AreEqual(0, KdsLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should have no KDS entry of its own.');
        RestoreNewPrintExperience();
    end;

    #endregion

    #region Item add-on lines on serving requests for selected lines after a step-specific request

    // A step-specific serving request prints an unrouted add-on on its dish's ticket and logs it at the dish's step. A
    // serving request for selected lines has no serving step, so it looks at the add-on at the blank step, where nothing
    // was logged. These tests check that the add-on is not printed a second time there, and that it is still printed when
    // its quantity changed, when it was never sent, or when the request resends every line.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestedForStep_ThenSelectedLinesRequested_UnroutedAddOnNotReprinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on that went out with its dish on a step-specific serving request is not printed again
        //            by a serving request for the selected dish and add-on
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with a print category and an unrouted add-on, whose serving has been requested
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        _LibraryRestaurant.CreatePrintCategory(PrintCategory);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok, PrintCategory.Code);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] Nothing was sent, no ticket went out, and the add-on is still logged as printed once
        _Assert.IsFalse(Sent, 'The request should have had nothing to send.');
        _Assert.AreEqual(0, _TestPrintHandler.InvocationCount(), 'No ticket should have gone out.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should still be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestedForStep_ThenAddOnAloneRequested_AddOnNotReprinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on that went out with its dish on a step-specific serving request is not printed again
        //            by a serving request for the add-on alone
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with an unrouted add-on, whose serving has been requested
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected add-on alone, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] Nothing was sent, no ticket went out, and the add-on is still logged as printed once
        _Assert.IsFalse(Sent, 'The request should have had nothing to send.');
        _Assert.AreEqual(0, _TestPrintHandler.InvocationCount(), 'No ticket should have gone out.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should still be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishQuantityChangedAfterServingRequested_SelectedLinesRequested_AddOnNotReprinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] When only the dish changed after its serving was requested, the dish is printed again and its unchanged
        //            unrouted add-on is not
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with an unrouted add-on, whose serving has been requested, after which the dish
        //         quantity went from 1 to 2
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        SetLineQuantity(DishLine, 2);
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] The dish went out again, the add-on is on no ticket, and the add-on is still logged as printed once
        _Assert.IsTrue(Sent, 'The changed dish should have been sent.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The changed dish should be on a ticket.');
        _Assert.AreEqual(0, _TestPrintHandler.JobCountContainingLine(AddOnLine."Line No."), 'The unchanged add-on should not be on any ticket.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should still be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishRoutedToTwoSteps_ServingRequestedForBoth_SelectedLinesRequested_AddOnNotReprinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        Seating: Record "NPR NPRE Seating";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on that went out with a dish served in two steps is not printed again by a serving
        //            request for the selected dish and add-on
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a dish routed to the starter and the main course with an unrouted add-on, whose serving has been
        //         requested for both steps
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        // The routing is copied to the line when it is added, so both steps are assigned before that.
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(DishItem, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, StarterStepTok);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(DishItem, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", DishItem."No.", 1, 0, DishLine);
        _Assert.AreEqual(2, DishLine.TotalNoOfServingSteps(), 'The dish should be routed to two serving steps.');
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, StarterStepTok);
        RequestServing(WaiterPad, MainCourseStepTok);
        _Assert.AreEqual(
            2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should have gone out with the dish at both steps.');
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] Nothing was sent, and the add-on is still logged as printed twice
        _Assert.IsFalse(Sent, 'The request should have had nothing to send.');
        _Assert.AreEqual(2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should still be logged as printed twice.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenOrderSent_ThenServingRequestedForStep_ThenSelectedLinesRequested_AddOnNotReprinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        LogsBefore: Integer;
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on that was on the kitchen order and then went out with its dish on a step-specific
        //            serving request is not printed again by a serving request for the selected dish and add-on
        // [GIVEN] The new print experience, sent lines not resent, kitchen order and serving request templates that do
        //         not split jobs, and a main course dish with an unrouted add-on, sent to the kitchen and then requested
        //         for serving
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Kitchen Order", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        SendToKitchen(WaiterPad);
        RequestServing(WaiterPad, MainCourseStepTok);
        // The print log count includes the kitchen order, so the assertion below compares against this value.
        LogsBefore := PrintLogCount(WaiterPad."No.", AddOnLine."Line No.");
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] Nothing was sent, no ticket went out, and the add-on got no new print log entry
        _Assert.IsFalse(Sent, 'The request should have had nothing to send.');
        _Assert.AreEqual(0, _TestPrintHandler.InvocationCount(), 'No ticket should have gone out.');
        _Assert.AreEqual(
            LogsBefore, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should have no new print log entry.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnQuantityChangedAfterServingRequested_SelectedLinesRequested_AddOnPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on whose quantity changed after it went out with its dish is printed again
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with an unrouted add-on, whose serving has been requested, after which the
        //         add-on quantity went from 1 to 2
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        SetLineQuantity(AddOnLine, 2);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected add-on alone, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] One ticket went out, and the add-on is logged as printed twice
        _Assert.IsTrue(Sent, 'The changed add-on should have been sent.');
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The changed add-on should have gone out on one ticket.');
        _Assert.AreEqual(2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed twice.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestedForStep_ThenAddOnAloneForceResent_AddOnPrintedAgain()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] A forced resend prints an unrouted add-on again, even though it already went out with its dish
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with an unrouted add-on, whose serving has been requested
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is force resent for the selected add-on alone, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', true, false);

        // [THEN] The add-on was sent, and it is logged as printed twice
        _Assert.IsTrue(Sent, 'The forced resend should have sent the add-on.');
        _Assert.AreEqual(2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed twice.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnAttachedAfterServingRequested_SelectedLinesRequested_AddOnPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on attached after its dish's serving was requested never went out, so a serving
        //            request for the selected dish and add-on prints it
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish whose serving has been requested, with an unrouted add-on attached afterwards
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        RequestServing(WaiterPad, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] The add-on went out on one ticket, and it is logged as printed once
        _Assert.IsTrue(Sent, 'The new add-on should have been sent.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed once.');
        _Assert.AreEqual(1, _TestPrintHandler.JobCountContainingLine(AddOnLine."Line No."), 'The add-on should be on one ticket.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [HandlerFunctions('ResendAllLinesStrMenuHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestedForStep_ThenSelectedLinesAskAll_AddOnPrintedAgain()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] When the waiter is asked and chooses to send all lines, an unrouted add-on that already went out with
        //            its dish is printed again
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course dish
        //         with an unrouted add-on, whose serving has been requested while sent lines were not resent. The seating
        //         location then asks whether to resend sent lines.
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        _SeatingLocation.Find();
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::Ask;
        _SeatingLocation.Modify();
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step, and the waiter chooses to
        //        send all lines
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] The lines were sent, and the add-on is logged as printed twice
        _Assert.IsTrue(Sent, 'Choosing to send all lines should have sent them.');
        _Assert.AreEqual(2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed twice.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnWithOwnTicketAndChangedQuantity_ServingRequestedThenSelectedLines_AddOnPrinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        FirstSelection: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on that was once requested alone has a serving ticket of its own. It follows its own
        //            quantity, so after its quantity changed it is printed again by a serving request for it alone, even
        //            though it also went out with its dish at the new quantity.
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with an unrouted add-on. The add-on was requested alone, its quantity then went
        //         from 1 to 2, and then serving was requested for the main course, where the add-on went out with its dish.
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        FirstSelection.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        FirstSelection.Mark(true);
        FirstSelection.SetRange("Waiter Pad No.", WaiterPad."No.");
        FirstSelection.MarkedOnly(true);
        WaiterPad.Find();
        RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, FirstSelection, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should have been printed once on its own.');
        SetLineQuantity(AddOnLine, 2);
        RequestServing(WaiterPad, MainCourseStepTok);
        _Assert.AreEqual(2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should have gone out with its dish.');
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected add-on alone again, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] One ticket went out, and the add-on is logged as printed three times
        _Assert.IsTrue(Sent, 'The changed add-on should have been sent.');
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'The changed add-on should have gone out on one ticket.');
        _Assert.AreEqual(3, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed three times.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [HandlerFunctions('ResendOnlyNewLinesStrMenuHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestedForStep_ThenSelectedLinesAskOnlyNew_AddOnNotReprinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] When the waiter is asked and chooses to send only new lines, an unrouted add-on that already went out
        //            with its dish is not printed again
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course dish
        //         with an unrouted add-on, whose serving has been requested while sent lines were not resent. The seating
        //         location then asks whether to resend sent lines.
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        _SeatingLocation.Find();
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::Ask;
        _SeatingLocation.Modify();
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step, and the waiter chooses to
        //        send only new lines
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] Nothing was sent, no ticket went out, and the add-on is still logged as printed once
        _Assert.IsFalse(Sent, 'The request should have had nothing to send.');
        _Assert.AreEqual(0, _TestPrintHandler.InvocationCount(), 'No ticket should have gone out.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should still be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishRoutedToTwoSteps_ServingRequestedForStarter_SelectedLinesRequested_AddOnPrintedWithMain()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        Seating: Record "NPR NPRE Seating";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        PrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on that went out with a two-step dish at the starter only is printed again with the
        //            dish by a serving request for the selected dish and add-on, because the dish now also goes out at the
        //            main course, where the add-on has not gone out yet
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a dish routed to the starter and the main course with an unrouted add-on, whose serving has been
        //         requested for the starter only
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        // The routing is copied to the line when it is added, so both steps are assigned before that.
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(DishItem, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, StarterStepTok);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(DishItem, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", DishItem."No.", 1, 0, DishLine);
        _Assert.AreEqual(2, DishLine.TotalNoOfServingSteps(), 'The dish should be routed to two serving steps.');
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, StarterStepTok);
        _Assert.AreEqual(
            1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should have gone out with the dish at the starter.');
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] One ticket went out with the dish and the add-on on it, and the add-on is logged as printed twice, the
        //        second time by this request without a serving step
        _Assert.IsTrue(Sent, 'The dish should have been sent for the main course.');
        _Assert.AreEqual(1, _TestPrintHandler.InvocationCount(), 'One ticket should have gone out.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on a ticket.');
        _Assert.AreEqual(1, _TestPrintHandler.JobCountContainingLine(AddOnLine."Line No."), 'The add-on should be on exactly one ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The add-on should be on the dish ticket.');
        _Assert.AreEqual(2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed twice.');
        PrintLogEntry.SetRange("Waiter Pad No.", WaiterPad."No.");
        PrintLogEntry.SetRange("Waiter Pad Line No.", AddOnLine."Line No.");
        PrintLogEntry.SetRange("Print Type", PrintLogEntry."Print Type"::"Serving Request");
        PrintLogEntry.SetRange("Output Type", PrintLogEntry."Output Type"::Print);
        PrintLogEntry.SetRange("Flow Status Code", '');
        _Assert.AreEqual(1, PrintLogEntry.Count(), 'The add-on should be logged once for the request without a serving step.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequestedForStep_ThenAddOnAloneAskMode_NothingToSendWithoutPrompt()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] When the seating location asks whether to resend sent lines, a serving request for an unrouted add-on
        //            alone that already went out with its dish has nothing to send and does not ask the waiter
        // [GIVEN] The new print experience, a serving request template that does not split jobs, and a main course dish
        //         with an unrouted add-on, whose serving has been requested while sent lines were not resent. The seating
        //         location then asks whether to resend sent lines.
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        _SeatingLocation.Find();
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::Ask;
        _SeatingLocation.Modify();
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected add-on alone, without a serving step. The test binds no handler,
        //        so a prompt would fail it.
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] Nothing was sent, no ticket went out, and the add-on is still logged as printed once
        _Assert.IsFalse(Sent, 'The request should have had nothing to send.');
        _Assert.AreEqual(0, _TestPrintHandler.InvocationCount(), 'No ticket should have gone out.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should still be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishWithCategoryQuantityChangedAfterServingRequested_SelectedLinesRequested_AddOnNotReprinted()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] When only a dish with a print category changed after its serving was requested, the dish is printed
        //            again and its unchanged unrouted add-on is not
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a main course dish with a print category and an unrouted add-on, whose serving has been requested,
        //         after which the dish quantity went from 1 to 2
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        _LibraryRestaurant.CreatePrintCategory(PrintCategory);
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        CreatePadWithRoutedLine(WaiterPad, DishItem, DishLine, MainCourseStepTok, PrintCategory.Code);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, MainCourseStepTok);
        SetLineQuantity(DishLine, 2);
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] The dish went out again, the add-on is on no ticket, and the add-on is still logged as printed once
        _Assert.IsTrue(Sent, 'The changed dish should have been sent.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The changed dish should be on a ticket.');
        _Assert.AreEqual(0, _TestPrintHandler.JobCountContainingLine(AddOnLine."Line No."), 'The unchanged add-on should not be on any ticket.');
        _Assert.AreEqual(1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should still be logged as printed once.');
        RestoreNewPrintExperience();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishRoutedToTwoSteps_StarterRequested_DishQuantityChanged_SelectedLinesRequested_AddOnPrintedWithMain()
    var
        PrintTemplateOption: Record "NPR NPRE Print Template";
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        Seating: Record "NPR NPRE Seating";
        DishItem: Record Item;
        AddOnItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        SelectedLines: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Sent: Boolean;
    begin
        // [SCENARIO] An unrouted add-on that went out with a two-step dish at the starter only is printed again with the
        //            dish by a serving request for the selected dish and add-on, also when the dish quantity changed after
        //            the starter was requested
        // [GIVEN] The new print experience, sent lines not resent, a serving request template that does not split jobs,
        //         and a dish routed to the starter and the main course with an unrouted add-on, whose serving has been
        //         requested for the starter only, after which the dish quantity went from 1 to 2
        Initialize();
        SetNewPrintExperience(true);
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        CreatePrintTemplate(
            PrintTemplateOption."Print Type"::"Serving Request", PrintTemplateOption."Split Print Jobs By"::None, '');
        // The routing is copied to the line when it is added, so both steps are assigned before that.
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(DishItem, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, StarterStepTok);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(DishItem, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", DishItem."No.", 1, 0, DishLine);
        _Assert.AreEqual(2, DishLine.TotalNoOfServingSteps(), 'The dish should be routed to two serving steps.');
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);
        RequestServing(WaiterPad, StarterStepTok);
        _Assert.AreEqual(
            1, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should have gone out with the dish at the starter.');
        SetLineQuantity(DishLine, 2);
        SelectedLines.Get(DishLine."Waiter Pad No.", DishLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.Get(AddOnLine."Waiter Pad No.", AddOnLine."Line No.");
        SelectedLines.Mark(true);
        SelectedLines.SetRange("Waiter Pad No.", WaiterPad."No.");
        SelectedLines.MarkedOnly(true);
        _TestPrintHandler.ClearCaptured();

        // [WHEN] Serving is requested for the selected dish and add-on, without a serving step
        WaiterPad.Find();
        Sent := RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, SelectedLines, PrintTemplateOption."Print Type"::"Serving Request", '', false, false);

        // [THEN] The lines were sent, the add-on is on one ticket, the same one as the dish, and it is logged as printed twice
        _Assert.IsTrue(Sent, 'The dish should have been sent.');
        _Assert.AreNotEqual(0, _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), 'The dish should be on a ticket.');
        _Assert.AreEqual(
            _TestPrintHandler.JobIndexContainingLine(DishLine."Line No."), _TestPrintHandler.JobIndexContainingLine(AddOnLine."Line No."),
            'The add-on should be on the dish ticket.');
        _Assert.AreEqual(1, _TestPrintHandler.JobCountContainingLine(AddOnLine."Line No."), 'The add-on should be on exactly one ticket.');
        _Assert.AreEqual(2, PrintLogCount(WaiterPad."No.", AddOnLine."Line No."), 'The add-on should be logged as printed twice.');
        RestoreNewPrintExperience();
    end;

    [StrMenuHandler]
    procedure ResendAllLinesStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        // The second option sends all lines, including the ones already sent.
        Choice := 2;
    end;

    [StrMenuHandler]
    procedure ResendOnlyNewLinesStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        // The first option sends only the lines that were not sent yet.
        Choice := 1;
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        KitchenStationSelectionAll: Record "NPR NPRE Kitchen Station Slct.";
        PrintTemplateAll: Record "NPR NPRE Print Template";
        LegacyPrintTemplAll: Record "NPR NPRE Print Templ.";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore);
        if not _RestaurantInitialized then begin
            _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
            _LibraryRestaurant.CreateMealFlowStatuses();
            _LibraryRestaurant.CreateSeatingFlowStatuses();
            _LibraryRestaurant.CreateWaiterPadFlowStatuses();
            _LibraryRestaurant.CreateServiceFlowProfile(_ServFlowProfile);
            _LibraryRestaurant.CreateRestaurant(_Restaurant, _ServFlowProfile.Code);
            _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
            _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
            _POSUnit.Modify();
            _RestaurantInitialized := true;
        end;

        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        // Kitchen printing has to be switched on for the Print output type to exist at all. Without it the
        // orchestration buffers KDS rows only, no print template is ever resolved and nothing is dispatched.
        SetKitchenPrintingActive(true);

        // Templates and routing both leak between tests, so both start empty. Both template master tables are wiped:
        // which one is read depends on the feature flag, and tests in this codeunit run on either side of it.
        PrintTemplateAll.DeleteAll();
        LegacyPrintTemplAll.DeleteAll();
        KitchenStationSelectionAll.DeleteAll();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _TestPrintHandler.ClearCaptured();

        // The flag is company-wide and committed, so leaving it set would change which implementation every later
        // codeunit runs - NPREKitchenPrintTests in particular documents running with the flag "as the company has it".
        // Restoring here repairs it for the next test in this codeunit; each toggling test also restores on its way out,
        // because nothing runs after the last one and AL gives a test codeunit no teardown hook.
        RestoreNewPrintExperience();
        Commit();
    end;

    local procedure RestoreNewPrintExperience()
    var
        NewRestaurantPrintExp: Codeunit "NPR New Restaurant Print Exp.";
    begin
        if not _FlagCaptured then begin
            _FlagAtEntry := NewRestaurantPrintExp.IsFeatureEnabled();
            _FlagCaptured := true;
            exit;
        end;
        if NewRestaurantPrintExp.IsFeatureEnabled() <> _FlagAtEntry then begin
            NewRestaurantPrintExp.SetFeatureEnabled(_FlagAtEntry);
            Commit();
        end;
        // SetFeatureEnabled exits silently when the "NPR Feature" row is missing, which would make the restore a no-op
        // and leak the flag out of the suite unnoticed.
        _Assert.AreEqual(
            _FlagAtEntry, NewRestaurantPrintExp.IsFeatureEnabled(), 'The new print experience flag should have been restored.');
    end;

    local procedure SetKitchenPrintingActive(Enabled: Boolean)
    begin
        _Restaurant.Find();
        if Enabled then
            _Restaurant."Kitchen Printing Active" := _Restaurant."Kitchen Printing Active"::Yes
        else
            _Restaurant."Kitchen Printing Active" := _Restaurant."Kitchen Printing Active"::No;
        _Restaurant.Modify();
        Commit();
    end;

    local procedure SetNewPrintExperience(Enabled: Boolean)
    var
        NewRestaurantPrintExp: Codeunit "NPR New Restaurant Print Exp.";
    begin
        // SetFeatureEnabled assigns and modifies without Validate, so it toggles both ways from test code even
        // though the feature is irreversible through the UI. LibraryFeatureFlags is the wrong tool here - it
        // flips every flag in the company at once.
        NewRestaurantPrintExp.SetFeatureEnabled(Enabled);
        Commit();

        // SetFeatureEnabled exits silently when the "NPR Feature" row does not exist, which would make every toggle in
        // this suite a no-op and leave the parity test comparing one implementation against itself while still green.
        _Assert.AreEqual(
            Enabled, NewRestaurantPrintExp.IsFeatureEnabled(),
            'The new print experience flag should have taken the requested value. Without it the parity test is vacuous.');
    end;

    local procedure CreatePrintTemplate(SplitJobsBy: Option; PrintCategoryCode: Code[20])
    var
        PrintTemplate: Record "NPR NPRE Print Template";
    begin
        CreatePrintTemplate(PrintTemplate."Print Type"::"Kitchen Order", SplitJobsBy, PrintCategoryCode);
    end;

    local procedure CreatePrintTemplate(PrintType: Option; SplitJobsBy: Option; PrintCategoryCode: Code[20])
    var
        PrintTemplate: Record "NPR NPRE Print Template";
    begin
        PrintTemplate.Init();
        PrintTemplate."Print Type" := PrintType;
        PrintTemplate."Restaurant Code" := _Restaurant.Code;
        PrintTemplate."Seating Location" := _SeatingLocation.Code;
        PrintTemplate."Serving Step" := '';
        PrintTemplate."Print Category Code" := PrintCategoryCode;
        PrintTemplate."Split Print Jobs By" := SplitJobsBy;
        PrintTemplate."Codeunit ID" := Codeunit::"NPR NPRE Test Print Handler";
        PrintTemplate.Insert(true);
    end;

    local procedure CreateGenericPrintTemplate()
    var
        PrintTemplate: Record "NPR NPRE Print Template";
    begin
        // No restaurant and no seating location, so it is only ever reached by the blank-location fallback pass.
        PrintTemplate.Init();
        PrintTemplate."Print Type" := PrintTemplate."Print Type"::"Kitchen Order";
        PrintTemplate."Restaurant Code" := '';
        PrintTemplate."Seating Location" := '';
        PrintTemplate."Serving Step" := '';
        PrintTemplate."Print Category Code" := '';
        PrintTemplate."Split Print Jobs By" := PrintTemplate."Split Print Jobs By"::None;
        PrintTemplate."Codeunit ID" := Codeunit::"NPR NPRE Test Print Handler";
        PrintTemplate.Insert(true);
    end;

    local procedure CreateLegacyPrintTemplate(SplitJobsBy: Option) TemplateCode: Code[20]
    var
        PrintTempl: Record "NPR NPRE Print Templ.";
    begin
        exit(CreateLegacyPrintTemplate(PrintTempl."Print Type"::"Kitchen Order", SplitJobsBy));
    end;

    local procedure CreateLegacyPrintTemplate(PrintType: Option; SplitJobsBy: Option) TemplateCode: Code[20]
    var
        TemplateHeader: Record "NPR RP Template Header";
        DataItems: Record "NPR RP Data Items";
        PrintTempl: Record "NPR NPRE Print Templ.";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        // A retail print template with a data item, no layout lines and a stand-in pre-processing codeunit. The
        // pre-processor is what these tests observe: it runs once per print job, before the engine renders anything,
        // so the ticket does not have to be printable for the grouping to be measurable - and the grouping, not the
        // ticket's content, is what is under test. The data item is also what the header's "Table ID" is calculated
        // from, and that is what the dispatch branches on to pick the waiter pad line branch.
        TemplateHeader.Init();
        TemplateHeader.Code :=
            CopyStr(
                LibraryUtility.GenerateRandomCode(TemplateHeader.FieldNo(Code), Database::"NPR RP Template Header"),
                1, MaxStrLen(TemplateHeader.Code));
        TemplateHeader."Printer Device" := 'EPSON';
        TemplateHeader."Pre Processing Codeunit" := Codeunit::"NPR NPRE Test RP Preprocess";
        TemplateHeader.Insert();

        DataItems.Init();
        DataItems.Code := TemplateHeader.Code;
        DataItems.Validate("Data Source", 'NPR NPRE Waiter Pad Line');
        DataItems.Insert();

        // "Data Source" validation ends in a bare FindFirst on AllObjWithCaption and leaves "Table ID" at zero when
        // the object name does not match, and the dispatch branches on that same value - a zero would fall through
        // both branches, print nothing, raise nothing, and make every job count below read zero for the wrong reason.
        TemplateHeader.CalcFields("Table ID");
        _Assert.AreEqual(
            Database::"NPR NPRE Waiter Pad Line", TemplateHeader."Table ID",
            'The retail print template should resolve to the waiter pad line table.');

        PrintTempl.Init();
        PrintTempl."Print Type" := PrintType;
        PrintTempl."Restaurant Code" := _Restaurant.Code;
        PrintTempl."Seating Location" := _SeatingLocation.Code;
        PrintTempl."Serving Step" := '';
        PrintTempl."Print Category Code" := '';
        PrintTempl."Template Code" := TemplateHeader.Code;
        PrintTempl."Split Print Jobs By" := SplitJobsBy;
        PrintTempl.Insert(true);
        exit(TemplateHeader.Code);
    end;

    local procedure CreateLegacyWaiterPadTemplate(SplitJobsBy: Option)
    var
        TemplateHeader: Record "NPR RP Template Header";
        DataItems: Record "NPR RP Data Items";
        PrintTempl: Record "NPR NPRE Print Templ.";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        // Same shape as CreateLegacyPrintTemplate, with the data item on the waiter pad rather than its lines. That
        // is the only thing that sends the dispatch down its other branch.
        TemplateHeader.Init();
        TemplateHeader.Code :=
            CopyStr(
                LibraryUtility.GenerateRandomCode(TemplateHeader.FieldNo(Code), Database::"NPR RP Template Header"),
                1, MaxStrLen(TemplateHeader.Code));
        TemplateHeader."Printer Device" := 'EPSON';
        TemplateHeader."Pre Processing Codeunit" := Codeunit::"NPR NPRE Test RP Pre WPad";
        TemplateHeader.Insert();

        DataItems.Init();
        DataItems.Code := TemplateHeader.Code;
        DataItems.Validate("Data Source", 'NPR NPRE Waiter Pad');
        DataItems.Insert();

        TemplateHeader.CalcFields("Table ID");
        _Assert.AreEqual(
            Database::"NPR NPRE Waiter Pad", TemplateHeader."Table ID",
            'The retail print template should resolve to the waiter pad table.');

        PrintTempl.Init();
        PrintTempl."Print Type" := PrintTempl."Print Type"::"Kitchen Order";
        PrintTempl."Restaurant Code" := _Restaurant.Code;
        PrintTempl."Seating Location" := _SeatingLocation.Code;
        PrintTempl."Serving Step" := '';
        PrintTempl."Print Category Code" := '';
        PrintTempl."Template Code" := TemplateHeader.Code;
        PrintTempl."Split Print Jobs By" := SplitJobsBy;
        PrintTempl.Insert(true);
    end;

    local procedure LinkPadToASeatingInAnotherRestaurant(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        OtherRestaurant: Record "NPR NPRE Restaurant";
        OtherSeatingLocation: Record "NPR NPRE Seating Location";
        OtherSeating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        _LibraryRestaurant.CreateRestaurant(OtherRestaurant, _ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(OtherSeatingLocation, OtherRestaurant.Code);
        _LibraryRestaurant.CreateSeating(OtherSeating, OtherSeatingLocation.Code);
        if not WaiterPadMgt.LinkSeatingToWaiterPad(WaiterPad, OtherSeating.Code, SeatingWaiterPadLink) then
            _Assert.Fail('The pad should have been linked to a seating in the second restaurant.');
        Commit();
    end;

    local procedure CreatePadWithRoutedLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10])
    begin
        CreatePadWithRoutedLine(WaiterPad, Item, WaiterPadLine, ServingStep, '');
    end;

    local procedure CreatePadWithRoutedLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10]; PrintCategoryCode: Code[20])
    var
        Seating: Record "NPR NPRE Seating";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        AddRoutedLine(WaiterPad, Item, WaiterPadLine, ServingStep, PrintCategoryCode);
    end;

    local procedure AddRoutedLine(WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10])
    begin
        AddRoutedLine(WaiterPad, Item, WaiterPadLine, ServingStep, '');
    end;

    local procedure AddRoutedLine(WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10]; PrintCategoryCode: Code[20])
    begin
        AddRoutedLine(WaiterPad, Item, WaiterPadLine, ServingStep, PrintCategoryCode, 0);
    end;

    local procedure AddRoutedLine(WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10]; PrintCategoryCode: Code[20]; AttachedToLineNo: Integer)
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, ServingStep);
        if PrintCategoryCode <> '' then
            _LibraryRestaurant.AssignPrintCategoryToRoutingProfile(ItemRoutingProfile, PrintCategoryCode);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, AttachedToLineNo, WaiterPadLine);
    end;

    // No routing profile, so the line has neither a serving step nor a print category of its own.
    local procedure CreateAddOnItem(var Item: Record Item)
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
    end;

    local procedure SendToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
    end;

    local procedure RequestServing(var WaiterPad: Record "NPR NPRE Waiter Pad"; ServingStep: Code[10])
    var
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        // The request modifies the pad, so it has to start from the stored version.
        WaiterPad.Find();
        RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, ServingStep, false);
    end;

    local procedure SetLineQuantity(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal)
    begin
        WaiterPadLine.Find();
        WaiterPadLine.Validate(Quantity, Quantity);
        WaiterPadLine.Modify(true);
    end;

    local procedure KitchenRequestCount(WaiterPadNo: Code[20]): Integer
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        exit(KitchenRequest.Count());
    end;

    local procedure PrintLogCount(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Integer
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPadNo);
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
        WPadLinePrintLogEntry.SetRange("Output Type", WPadLinePrintLogEntry."Output Type"::Print);
        exit(WPadLinePrintLogEntry.Count());
    end;

    local procedure KdsLogCount(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Integer
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPadNo);
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
        WPadLinePrintLogEntry.SetRange("Output Type", WPadLinePrintLogEntry."Output Type"::KDS);
        exit(WPadLinePrintLogEntry.Count());
    end;

    #endregion
}
