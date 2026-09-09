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
        _FlagAtEntry: Boolean;
        _FlagCaptured: Boolean;
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;

    // SCOPE. Template resolution and dispatch are covered for the new print experience only. The legacy path has no
    // equivalent seam - it resolves an "NPR RP Template Header" and branches on that template's Table ID - so a
    // faithful fixture would need a retail print template built against the waiter pad tables, which the test
    // libraries do not provide. Covering it was weighed against the fact that stage 2b unifies the two output
    // buffers and collapses this code, and deliberately deferred - see this PR description for the reasoning.

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

        // Templates and routing both leak between tests, so both start empty.
        PrintTemplateAll.DeleteAll();
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
