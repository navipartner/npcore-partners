// Microsoft resolves the base user/profile/company areas; NP removes only its own tags according to the
// user's module seats. Every session starts with the modules last applied for the user in this company, which
// match the page metadata BC's web server still caches for that user. A seat change is switched at sign-in,
// after stopping the user's other sessions (README.md).
codeunit 6151309 "NPR License App Area Filter"
{
    Access = Internal;
    SingleInstance = true;

    var
        _ResolvingBaseAreas: Boolean;
        _SessionFiltered: Boolean;
        _SessionFilterDecided: Boolean;
        _SessionModules: List of [Enum "NPR License Module"];
        _SessionModulesKnown: Boolean;
        _SessionModulesTaken: Boolean;
        _AppliedModulesKeyLbl: Label 'NPR.License.AppliedModules', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnBeforeGetApplicationAreas', '', false, false)]
    local procedure OnBeforeGetApplicationAreas(var ApplicationAreas: Text; var IsHandled: Boolean)
    var
        Modules: List of [Enum "NPR License Module"];
        BaseApplicationAreas: Text;
    begin
        // If another subscriber already handled the event we leave its result alone (accepted limit).
        if IsHandled or _ResolvingBaseAreas then
            exit;
        if not IsSessionFiltered() then
            exit;
        if not GetBaseApplicationAreas(BaseApplicationAreas) then
            exit;

        // Fail open: if the seats cannot be read, the user sees Microsoft's areas for the whole session.
        if not GetSessionModules(Modules) then
            exit;
        ApplicationAreas := FilterApplicationAreas(BaseApplicationAreas, Modules);
        IsHandled := true;
    end;

    // Nested call re-raises the event; the flag turns that inner call into a no-op so Microsoft
    // resolves the areas normally (user -> profile -> company) and we only post-process.
    local procedure GetBaseApplicationAreas(var BaseApplicationAreas: Text) Resolved: Boolean
    begin
        _ResolvingBaseAreas := true;
        Resolved := TryGetBaseApplicationAreas(BaseApplicationAreas);
        _ResolvingBaseAreas := false;
    end;

    [TryFunction]
    local procedure TryGetBaseApplicationAreas(var BaseApplicationAreas: Text)
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        BaseApplicationAreas := ApplicationAreaMgmt.GetApplicationAreas();
    end;

    local procedure HasLicensingReadPermission(): Boolean
    var
        Feature: Record "NPR Feature";
        LicenseUser: Record "NPR License User";
    begin
        exit(Feature.ReadPermission() and LicenseUser.ReadPermission());
    end;

    // Whether this session's NP areas are filtered at all: GUI sessions of users who can read the licensing
    // tables, with module access enforced in this company. Switching the feature while users are signed in is not
    // covered here (README.md).
    internal procedure IsSessionFiltered(): Boolean
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        if not _SessionFilterDecided then begin
            _SessionFiltered := false;
            if GuiAllowed() then
                if HasLicensingReadPermission() then
                    _SessionFiltered := LicenseMgt.IsModuleAccessEnforced();
            _SessionFilterDecided := true;
        end;
        exit(_SessionFiltered);
    end;

    // The modules that decide this session's NP areas, the role-center notice and the POS page check: the set
    // last applied for the user in this company; before the first sign-in stored one, the live seats.
    // False when they could not be read; the session then keeps Microsoft's areas.
    internal procedure GetSessionModules(var Modules: List of [Enum "NPR License Module"]): Boolean
    begin
        if not _SessionModulesTaken then begin
            _SessionModulesKnown := GetAppliedModules(_SessionModules);
            if not _SessionModulesKnown then
                _SessionModulesKnown := TryGetModulesCountingForUI(UserSecurityId(), _SessionModules);
            if not _SessionModulesKnown then
                Clear(_SessionModules);
            _SessionModulesTaken := true;
        end;
        CopyModules(_SessionModules, Modules);
        exit(_SessionModulesKnown);
    end;

    // Assignment changes are reported without changing the running session's areas.
    internal procedure LicenseChangePending(): Boolean
    var
        SessionModules: List of [Enum "NPR License Module"];
        LiveModules: List of [Enum "NPR License Module"];
    begin
        if not GetSessionModules(SessionModules) then
            exit(false);
        if not TryGetModulesCountingForUI(UserSecurityId(), LiveModules) then
            exit(false);
        exit(not SameCapabilities(SessionModules, LiveModules));
    end;

    // ----------------------------------------------------------------- Switching to changed seats

    // Setting the areas after company open also clears the page metadata cache that BC's web server shares between
    // all sessions of the user; at sign-in BC sets them without clearing it. OnAfterLogin runs after company open.
    // No restart: this runs before the role center loads, so setting the areas is enough, and a restart requested
    // during a browser refresh left SaaS at "Getting ready" until a second refresh.
    // Startup applied the stored set, so a session that cannot switch stays consistent with the cache.
    // Not covered by tests (it stops sessions): re-check in a browser after any change.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure SwitchChangedModulesAtLogin()
    var
        AppliedModules: List of [Enum "NPR License Module"];
        LiveModules: List of [Enum "NPR License Module"];
        SessionModules: List of [Enum "NPR License Module"];
    begin
        if not IsSessionFiltered() then begin
            // An unfiltered session refills the shared metadata cache: the next filtered sign-in must clear it again.
            if GuiAllowed() then
                ClearAppliedModules();
            exit;
        end;
        if not GetSessionModules(SessionModules) then
            exit;
        // First filtered sign-in: what this session shows becomes the applied set, and setting it clears page
        // metadata cached before the filter. Not in the area resolver: it can run inside a TryFunction, where
        // writes are not allowed.
        if not GetAppliedModules(AppliedModules) then begin
            SwitchModules(SessionModules, false);
            exit;
        end;
        // Another session switched while this one was starting: follow it without the check below, because
        // every other listed session already runs the stored set.
        if not SameCapabilities(SessionModules, AppliedModules) then begin
            SwitchModules(AppliedModules, false);
            exit;
        end;
        if not TryGetModulesCountingForUI(UserSecurityId(), LiveModules) then
            exit;
        if SameCapabilities(SessionModules, LiveModules) then
            exit;
        // Stays pending when a session cannot be stopped; the role-center notice explains it.
        if StopOtherClientSessions() <> '' then
            exit;
        SwitchModules(LiveModules, false);
    end;

    // The pending-change notice action: the same switch from a running session.
    internal procedure SwitchToLiveModulesAndRestart()
    var
        LiveModules: List of [Enum "NPR License Module"];
        Blocker: Text;
        ModuleAccessNotActiveErr: Label 'License-based module access is not active for this session.';
        LicenseReadFailedErr: Label 'Your module licenses could not be read. Try again later.';
    begin
        if not IsSessionFiltered() then
            Error(ModuleAccessNotActiveErr);
        if not TryGetModulesCountingForUI(UserSecurityId(), LiveModules) then
            Error(LicenseReadFailedErr);
        Blocker := StopOtherClientSessions();
        if Blocker <> '' then
            Error(Blocker);
        SwitchModules(LiveModules, true);
    end;

    // The set is stored first: if it cannot be stored, the areas stay unchanged and still match the stored set.
    // Only the notice action restarts: its open pages were loaded with the old areas.
    local procedure SwitchModules(Modules: List of [Enum "NPR License Module"]; Restart: Boolean)
    var
        UserSessionSettings: SessionSettings;
        BaseApplicationAreas: Text;
    begin
        if not GetBaseApplicationAreas(BaseApplicationAreas) then
            exit;
        if not StoreAppliedModules(Modules) then
            exit;
        // Filtering Microsoft's base areas, not the current ones, so that grants are added as well.
        ApplicationArea(FilterApplicationAreas(BaseApplicationAreas, Modules));
        CopyModules(Modules, _SessionModules);
        if not Restart then
            exit;
        UserSessionSettings.Init();
        // Init reads the saved settings, whose company another tab may have changed.
        UserSessionSettings.Company(CompanyName());
        // false: do not save personalization changes.
        UserSessionSettings.RequestSessionUpdate(false);
    end;

    // Another session of the user may still show the old set and would refill the shared cache with old controls
    // after a switch. Active Session cannot tell an open browser from a closed one (SaaS lists closed browsers for
    // hours), so the user's other client sessions are stopped, open or not (also a POS running in another tab).
    // StopSession only reaches sessions on this server instance: if one is listed on another instance, nothing is
    // stopped and the change stays pending. Returns the reason, or '' when the user is alone.
    local procedure StopOtherClientSessions(): Text
    var
        ActiveSession: Record "Active Session";
        SessionIds: List of [Integer];
        OtherSessionId: Integer;
        NoSessionAccessErr: Label 'Your license changes cannot be applied because your user cannot read %1.', Comment = '%1 = table caption';
        OtherSessionErr: Label 'Sign out of your other Business Central sessions, then try again. Another session is still listed: %1 %2, %3 %4. If its browser is already closed, an administrator can cancel the session in the Business Central admin center.', Comment = '%1 = Session ID caption, %2 = session ID, %3 = Server Instance ID caption, %4 = server instance ID';
        StopCommentLbl: Label 'NP module licenses changed: stopped by a new sign-in of the same user.', Locked = true;
    begin
        if not ActiveSession.ReadPermission() then
            exit(StrSubstNo(NoSessionAccessErr, ActiveSession.TableCaption()));
        ActiveSession.SetRange("User SID", UserSecurityId());
        ActiveSession.SetFilter("Client Type", '%1|%2|%3|%4|%5', ActiveSession."Client Type"::"Web Client", ActiveSession."Client Type"::Tablet, ActiveSession."Client Type"::Phone, ActiveSession."Client Type"::Desktop, ActiveSession."Client Type"::Teams);
        ActiveSession.SetFilter("Server Instance ID", '<>%1', ServiceInstanceId());
        if ActiveSession.FindFirst() then
            exit(StrSubstNo(OtherSessionErr, ActiveSession.FieldCaption("Session ID"), ActiveSession."Session ID", ActiveSession.FieldCaption("Server Instance ID"), ActiveSession."Server Instance ID"));

        ActiveSession.SetRange("Server Instance ID", ServiceInstanceId());
        ActiveSession.SetFilter("Session ID", '<>%1', SessionId());
        if ActiveSession.FindSet() then
            repeat
                SessionIds.Add(ActiveSession."Session ID");
            until ActiveSession.Next() = 0;
        foreach OtherSessionId in SessionIds do
            if not StopSession(OtherSessionId, StopCommentLbl) then
                exit(StrSubstNo(OtherSessionErr, ActiveSession.FieldCaption("Session ID"), OtherSessionId, ActiveSession.FieldCaption("Server Instance ID"), ServiceInstanceId()));
    end;

    // Per user and company, like the web server's metadata cache. Stored as enum ordinals; unknown ones are dropped.
    local procedure GetAppliedModules(var Modules: List of [Enum "NPR License Module"]): Boolean
    var
        StoredModules: Text;
        Ordinal: Integer;
    begin
        Clear(Modules);
        if not IsolatedStorage.Get(_AppliedModulesKeyLbl, DataScope::CompanyAndUser, StoredModules) then
            exit(false);
        foreach Ordinal in Enum::"NPR License Module".Ordinals() do
            if (',' + StoredModules + ',').Contains(',' + Format(Ordinal, 0, 9) + ',') then
                Modules.Add(Enum::"NPR License Module".FromInteger(Ordinal));
        exit(true);
    end;

    // Also called by tests, which cannot run the sign-in handler (it stops the user's other sessions).
    internal procedure StoreAppliedModules(Modules: List of [Enum "NPR License Module"]): Boolean
    var
        StoredModules: Text;
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"NPR License Module".Ordinals() do
            if Modules.Contains(Enum::"NPR License Module".FromInteger(Ordinal)) then
                StoredModules := AppendTag(StoredModules, Format(Ordinal, 0, 9));
        exit(IsolatedStorage.Set(_AppliedModulesKeyLbl, StoredModules, DataScope::CompanyAndUser));
    end;

    // Seats that grant the same capabilities give the same areas, notice and POS page check, so a KDS seat or a
    // POS <-> Retail without POS swap stops no session. POS End of Sale is left out: the POS checks it on live seats.
    local procedure SameCapabilities(Modules: List of [Enum "NPR License Module"]; OtherModules: List of [Enum "NPR License Module"]): Boolean
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Capability: Enum "NPR License Capability";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"NPR License Capability".Ordinals() do begin
            Capability := Enum::"NPR License Capability".FromInteger(Ordinal);
            if Capability <> Capability::POSEndOfSale then
                if LicenseCapabilityMgt.AnyModuleGrants(Modules, Capability) <> LicenseCapabilityMgt.AnyModuleGrants(OtherModules, Capability) then
                    exit(false);
        end;
        exit(true);
    end;

    // Test seam: forgets what this session decided, so the next call behaves like a new session's first call.
    // Tests only; Application code must never call it.
    internal procedure ClearSessionModules()
    begin
        Clear(_SessionModules);
        _SessionModulesKnown := false;
        _SessionModulesTaken := false;
        _SessionFiltered := false;
        _SessionFilterDecided := false;
    end;

    // Forgets the set last applied for the user in this company, as before the first filtered session.
    internal procedure ClearAppliedModules()
    begin
        if IsolatedStorage.Contains(_AppliedModulesKeyLbl, DataScope::CompanyAndUser) then
            IsolatedStorage.Delete(_AppliedModulesKeyLbl, DataScope::CompanyAndUser);
    end;

    local procedure CopyModules(Source: List of [Enum "NPR License Module"]; var Target: List of [Enum "NPR License Module"])
    var
        Module: Enum "NPR License Module";
    begin
        Clear(Target);
        foreach Module in Source do
            Target.Add(Module);
    end;

    // ----------------------------------------------------------------- Filtering

    internal procedure FilterApplicationAreas(ApplicationAreas: Text; Modules: List of [Enum "NPR License Module"]) Result: Text
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
        Tag: Text;
    begin
        // Tags are compared case-insensitively and trimmed; surviving tags keep their casing and order.
        foreach Tag in ApplicationAreas.Split(',') do begin
            Tag := Tag.Trim();
            if (Tag <> '') and (not IsNPTag(Tag) or LicenseCapabilityMgt.AnyModuleGrants(Modules, LicenseCapabilityMgt.CapabilityForTag(Tag))) then
                Result := AppendTag(Result, Tag);
        end;
        // Guard: an empty area string switches Microsoft's filtering OFF (everything visible). If
        // stripping emptied a non-empty input, fall back to Microsoft's own resolution instead.
        if (Result = '') and (ApplicationAreas.Trim() <> '') then
            exit(ApplicationAreas);
    end;

    [TryFunction]
    local procedure TryGetModulesCountingForUI(UserSecID: Guid; var Modules: List of [Enum "NPR License Module"])
    var
        LicenseCapabilityMgt: Codeunit "NPR License Capability Mgt.";
    begin
        LicenseCapabilityMgt.GetModulesCountingForUI(UserSecID, Modules);
    end;

    local procedure IsNPTag(Tag: Text): Boolean
    begin
        // Microsoft's and other publishers' tags are never ours to hide. The #NPR namespace is assumed to be ours.
        exit(UpperCase(Tag).StartsWith('#NPR'));
    end;

    local procedure AppendTag(Areas: Text; Tag: Text): Text
    begin
        if Areas = '' then
            exit(Tag);
        exit(Areas + ',' + Tag);
    end;
}
