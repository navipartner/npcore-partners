// Sessions use the modules last applied for the user in this company; a seat change stays pending until a
// session switches it (StoreAppliedModules stands in for that switch, which also stops the user's other sessions).
codeunit 85560 "NPR License UI Session Tests"
{
    // [FEATURE] Module licensing: the module set a session's application areas are built from, and when a seat change applies

    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure Grant_TakesEffectAfterSwitch()
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
    begin
        // [SCENARIO] A new seat stays pending, in the running and in new sessions, until a session switches it.
        // [GIVEN] A first sign-in without seats
        Initialize();
        _Assert.AreEqual('', FirstSignInModules(), 'No assignments must give an empty module set.');

        // [WHEN] A Retail POS seat is assigned
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);

        // [THEN] The running and new sessions keep the empty set and report the grant as pending
        _Assert.AreEqual('', SessionModules(), 'A grant must not change the running session.');
        _Assert.IsTrue(LicenseAppAreaFilter.LicenseChangePending(), 'The new assignment must be reported as pending.');
        _Assert.AreEqual('', NewSessionModules(), 'A new session must keep the applied empty set until the switch.');
        _Assert.IsTrue(LicenseAppAreaFilter.LicenseChangePending(), 'The grant must stay pending in a new session.');
        // [THEN] After the switch a new session uses the seat and nothing is pending
        SwitchModules("NPR License Module"::POS);
        _Assert.AreEqual('Retail POS', NewSessionModules(), 'After the switch a new session must use the POS assignment.');
        _Assert.IsFalse(LicenseAppAreaFilter.LicenseChangePending(), 'Nothing is pending after the switch.');

        // [THEN] Replacing it with seats that grant the same UI capabilities is not a pending change
        DeleteSeats();
        SeedSeat("NPR License Module"::RetailWithoutPOS, "NPR License User Status"::Active);
        SeedSeat("NPR License Module"::KDS, "NPR License User Status"::Active);
        _Assert.IsFalse(LicenseAppAreaFilter.LicenseChangePending(), 'Seats that grant the same UI capabilities must not be pending.');
    end;

    [Test]
    procedure Revocation_TakesEffectAfterSwitch()
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        NoModules: List of [Enum "NPR License Module"];
    begin
        // [SCENARIO] A removed seat stays pending, in the running and in new sessions, until a session switches it.
        // [GIVEN] A first sign-in with a Retail POS seat
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        _Assert.AreEqual('Retail POS', FirstSignInModules(), 'The first session must start with its live assignment.');

        // [WHEN] The seat is removed
        DeleteSeats();

        // [THEN] The running and new sessions keep Retail POS and report the revocation as pending
        _Assert.AreEqual('Retail POS', SessionModules(), 'A revocation must not change the running layout.');
        _Assert.IsTrue(LicenseAppAreaFilter.LicenseChangePending(), 'The revoked assignment must be reported as pending.');
        _Assert.AreEqual('Retail POS', NewSessionModules(), 'A new session must keep the applied set until the switch.');
        _Assert.IsTrue(LicenseAppAreaFilter.LicenseChangePending(), 'The revocation must stay pending in a new session.');
        // [THEN] After the switch a new session has no modules and nothing is pending
        LicenseAppAreaFilter.StoreAppliedModules(NoModules);
        _Assert.AreEqual('', NewSessionModules(), 'After the switch a new session must have no modules.');
        _Assert.IsFalse(LicenseAppAreaFilter.LicenseChangePending(), 'Nothing is pending after the switch.');
    end;

    [Test]
    procedure RepeatedNativeAreaResolution_KeepsSessionModules()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        OriginalApplicationAreaSetup: Record "Application Area Setup";
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        LicenseModuleAccessFeat: Codeunit "NPR License Module Access Feat";
        NoModules: List of [Enum "NPR License Module"];
        HadUserSetup: Boolean;
        FeatureWasEnabled: Boolean;
        InitialResolved: Boolean;
        RepeatedResolved: Boolean;
        FreshResolved: Boolean;
        InitialAreas: Text;
        RepeatedAreas: Text;
        FreshAreas: Text;
    begin
        // [SCENARIO] Microsoft's area lookup, called again in the same session after a revocation, keeps the session's
        // modules; only a new session after the switch shows the revocation.
        // [GIVEN] A Retail POS seat; feature on; enforcement on; a user-level area setup with Basic, NP Retail and NP Ticket Essential
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        LicenseModuleAccessFeat.AddFeature();
        FeatureWasEnabled := LicenseModuleAccessFeat.IsFeatureEnabled();
        LicenseModuleAccessFeat.SetFeatureEnabled(true);
        BindSubscription(LicenseEnforcementMock);

        // A user override makes Microsoft's real lookup independent of the runner's profile/company setup.
        HadUserSetup := ApplicationAreaSetup.Get('', '', UserId());
        OriginalApplicationAreaSetup := ApplicationAreaSetup;
        ApplicationAreaSetup.Init();
        ApplicationAreaSetup."Company Name" := '';
        ApplicationAreaSetup."Profile ID" := '';
        ApplicationAreaSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(ApplicationAreaSetup."User ID"));
        ApplicationAreaSetup.Basic := true;
        ApplicationAreaSetup."NPR Retail" := true;
        ApplicationAreaSetup."NPR Ticket Essential" := true;
        if HadUserSetup then
            ApplicationAreaSetup.Modify(true)
        else
            ApplicationAreaSetup.Insert(true);

        // [WHEN] Resolving the areas, again after removing the seat, and once more in a new session after the switch
        // Exercise the native facade and recursive subscriber, without changing the session's applied areas.
        InitialResolved := TryResolveNativeAreas(InitialAreas);
        DeleteSeats();
        RepeatedResolved := TryResolveNativeAreas(RepeatedAreas);
        LicenseAppAreaFilter.StoreAppliedModules(NoModules);
        LicenseAppAreaFilter.ClearSessionModules();
        FreshResolved := TryResolveNativeAreas(FreshAreas);

        // Restore the row before assertions; its table event also invalidates Microsoft's SingleInstance cache.
        if HadUserSetup then begin
            ApplicationAreaSetup := OriginalApplicationAreaSetup;
            ApplicationAreaSetup.Modify(true);
        end else
            ApplicationAreaSetup.Delete(true);
        LicenseModuleAccessFeat.SetFeatureEnabled(FeatureWasEnabled);
        LicenseAppAreaFilter.ClearSessionModules();

        // [THEN] The first two lookups keep NP Retail and drop ticketing; the new session drops every NP area
        _Assert.IsTrue(InitialResolved and RepeatedResolved and FreshResolved, 'All native getter calls must succeed.');
        _Assert.AreEqual('#Basic,#NPRRetail', InitialAreas, 'The native getter must preserve base areas and apply the POS capability filter.');
        _Assert.AreEqual(InitialAreas, RepeatedAreas, 'Re-entering the native getter after revocation must keep the pinned modules.');
        _Assert.AreEqual('#Basic', FreshAreas, 'A new session after the switch must expose the revoked assignment through the native getter.');
    end;

    [Test]
    procedure Replacement_TakesEffectAfterSwitch()
    begin
        // [SCENARIO] A seat replaced by another applies only after the switch.
        // [GIVEN] A first sign-in with a Retail POS seat
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        _Assert.AreEqual('Retail POS', FirstSignInModules(), 'The session must start with POS.');

        // [WHEN] The Retail POS seat is replaced by a scanner seat
        DeleteSeats();
        SeedSeat("NPR License Module"::Scanner, "NPR License User Status"::Active);

        // [THEN] The running session keeps Retail POS; after the switch a new session uses the scanner seat
        _Assert.AreEqual('Retail POS', SessionModules(), 'The current session must keep its original modules.');
        SwitchModules("NPR License Module"::Scanner);
        _Assert.AreEqual('Scanner', NewSessionModules(), 'After the switch a new session must use the replacement assignment.');
    end;

    [Test]
    procedure SessionModules_ReturnsIndependentCopy()
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        Modules: List of [Enum "NPR License Module"];
    begin
        // [SCENARIO] GetSessionModules returns a copy: changing it does not change the session's modules.
        // [GIVEN] A Retail POS seat and the session's module list read by a caller
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        _Assert.IsTrue(LicenseAppAreaFilter.GetSessionModules(Modules), 'The assignment read must succeed.');

        // [WHEN] The caller changes the returned list
        Modules.Remove("NPR License Module"::POS);
        Modules.Add("NPR License Module"::Scanner);

        // [THEN] The session still has Retail POS and nothing is pending
        _Assert.AreEqual('Retail POS', SessionModules(), 'A caller must not be able to change the session module list.');
        _Assert.IsFalse(LicenseAppAreaFilter.LicenseChangePending(), 'Changing a returned copy must not affect pending detection.');
    end;

    [Test]
    procedure SessionFiltered_DecidedOncePerSession()
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        LicenseModuleAccessFeat: Codeunit "NPR License Module Access Feat";
    begin
        // [SCENARIO] Whether a session's areas are filtered is decided once, when the session starts; switching the
        // feature applies to new sessions only.
        // [GIVEN] A GUI session started with the feature off; enforcement on
        Initialize();
        _Assert.IsTrue(GuiAllowed(), 'Precondition: filtering applies to GUI sessions.');
        LicenseModuleAccessFeat.AddFeature();
        LicenseModuleAccessFeat.SetFeatureEnabled(false);
        BindSubscription(LicenseEnforcementMock);
        _Assert.IsFalse(LicenseAppAreaFilter.IsSessionFiltered(), 'A session started with the feature off must not be filtered.');

        // [WHEN] The feature is switched on
        LicenseModuleAccessFeat.SetFeatureEnabled(true);

        // [THEN] The running session stays unfiltered and a new session is filtered
        _Assert.IsFalse(LicenseAppAreaFilter.IsSessionFiltered(), 'Enabling the feature must not change the running session.');
        LicenseAppAreaFilter.ClearSessionModules();
        _Assert.IsTrue(LicenseAppAreaFilter.IsSessionFiltered(), 'A new session must use the enabled feature.');
        // [THEN] Switching the feature off again does not change that session
        LicenseModuleAccessFeat.SetFeatureEnabled(false);
        _Assert.IsTrue(LicenseAppAreaFilter.IsSessionFiltered(), 'Disabling the feature must not change the running session.');
        LicenseAppAreaFilter.ClearSessionModules();
    end;

    [Test]
    procedure FilterApplicationAreas_UsesPassedModules()
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        Modules: List of [Enum "NPR License Module"];
    begin
        // [SCENARIO] FilterApplicationAreas uses the modules it is given, not the user's live seats.
        // [GIVEN] A live Attraction POS seat
        Initialize();
        SeedSeat("NPR License Module"::AttractionPOS, "NPR License User Status"::Active);

        // [WHEN] Filtering with Retail without POS passed in
        // [THEN] Ticketing is removed; NP Retail, Microsoft and other publishers' areas are kept
        Modules.Add("NPR License Module"::RetailWithoutPOS);
        _Assert.AreEqual('#NPRRetail,#Basic,#OtherPublisher', LicenseAppAreaFilter.FilterApplicationAreas('#NPRRetail,#NPRTicketEssential,#Basic,#OtherPublisher', Modules), 'Passed Retail modules must remove ticketing and preserve other publishers.');
    end;

    [TryFunction]
    local procedure TryResolveNativeAreas(var Areas: Text)
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        Areas := ApplicationAreaMgmtFacade.GetApplicationAreaSetup();
    end;

    local procedure SessionModules() Result: Text
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        Modules: List of [Enum "NPR License Module"];
        Module: Enum "NPR License Module";
    begin
        _Assert.IsTrue(LicenseAppAreaFilter.GetSessionModules(Modules), 'Reading session modules must succeed.');
        foreach Module in Modules do
            if Result = '' then
                Result := Format(Module)
            else
                Result += ',' + Format(Module);
    end;

    // Simulate a fresh SingleInstance lifetime without ending the AL test runner's own session.
    local procedure NewSessionModules(): Text
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
    begin
        LicenseAppAreaFilter.ClearSessionModules();
        exit(SessionModules());
    end;

    // As the sign-in handler does when nothing is stored yet: the first session's modules become the applied set.
    local procedure FirstSignInModules(): Text
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        Modules: List of [Enum "NPR License Module"];
    begin
        _Assert.IsTrue(LicenseAppAreaFilter.GetSessionModules(Modules), 'Reading session modules must succeed.');
        _Assert.IsTrue(LicenseAppAreaFilter.StoreAppliedModules(Modules), 'Storing the applied modules must succeed.');
        exit(SessionModules());
    end;

    local procedure SwitchModules(Module: Enum "NPR License Module")
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
        Modules: List of [Enum "NPR License Module"];
    begin
        Modules.Add(Module);
        _Assert.IsTrue(LicenseAppAreaFilter.StoreAppliedModules(Modules), 'Storing the applied modules must succeed.');
    end;

    local procedure SeedSeat(Module: Enum "NPR License Module"; Status: Enum "NPR License User Status")
    var
        LicenseUser: Record "NPR License User";
    begin
        LicenseUser.Init();
        LicenseUser."User Security ID" := UserSecurityId();
        LicenseUser.Module := Module;
        LicenseUser."License Term" := "NPR License Term"::months12;
        LicenseUser.Status := Status;
        LicenseUser."Status Changed At" := CurrentDateTime();
        LicenseUser.Insert(false);
    end;

    local procedure DeleteSeats()
    var
        LicenseUser: Record "NPR License User";
    begin
        LicenseUser.SetRange("User Security ID", UserSecurityId());
        LicenseUser.DeleteAll(false);
    end;

    local procedure Initialize()
    var
        LicenseAppAreaFilter: Codeunit "NPR License App Area Filter";
    begin
        DeleteSeats();
        LicenseAppAreaFilter.ClearSessionModules();
        LicenseAppAreaFilter.ClearAppliedModules();
    end;
}
