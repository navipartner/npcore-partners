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
        PrintTemplate.Init();
        PrintTemplate."Print Type" := PrintTemplate."Print Type"::"Kitchen Order";
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
        PrintTempl."Print Type" := PrintTempl."Print Type"::"Kitchen Order";
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
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, ServingStep);
        if PrintCategoryCode <> '' then
            _LibraryRestaurant.AssignPrintCategoryToRoutingProfile(ItemRoutingProfile, PrintCategoryCode);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, 0, WaiterPadLine);
    end;

    local procedure SendToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
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
