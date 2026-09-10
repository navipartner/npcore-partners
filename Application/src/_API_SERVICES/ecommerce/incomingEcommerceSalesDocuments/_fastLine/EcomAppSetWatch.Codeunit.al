/// <summary>
/// Detects that an extension was published, upgraded, installed or uninstalled while this
/// background session was running.
/// </summary>
codeunit 6248742 "NPR Ecom App Set Watch"
{
    Access = Internal;
    SingleInstance = true;
    Permissions = tabledata "NAV App Installed App" = r;
    /// <summary>
    /// True once the set of installed extensions differs from what this session started with.
    /// </summary>
    internal procedure ApplicationChanged(): Boolean
    var
        CurrentApps: Dictionary of [Guid, Guid];
        CurrentNames: Dictionary of [Guid, Text];
        ChangeDetail: Text;
    begin
        if _Changed then
            exit(true);

        if not TryCollectInstalledApps(CurrentApps, CurrentNames) then begin
            EmitReadFailure();
            _Changed := true;
            exit(true);
        end;

        // The first ask establishes what this session started from. In the job queues that ask comes
        // from the loop-top check, before any record is touched, so the baseline is the app set as
        // the session began - the only reading it is useful to compare against.
        if not _BaselineTaken then begin
            CopyApps(CurrentApps, _BaselineApps);
            CopyNames(CurrentNames, _BaselineNames);
            _BaselineTaken := true;
            exit(false);
        end;

        _Changed := DiffersFromBaseline(CurrentApps, CurrentNames, ChangeDetail);
        if _Changed then
            EmitChangeDetected(ChangeDetail);
        exit(_Changed);
    end;

    local procedure EmitChangeDetected(ChangeDetail: Text)
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        if _ChangeReported then
            exit;
        _ChangeReported := true;

        Sentry.InitScopeAndTransaction('E-com App Set Watch', 'bc.e-com.appsetwatch');
        Sentry.AddTransactionTag('appSetChanged', 'E-com job queues detected changes while this background session was running.');
        Sentry.AddTransactionTag('appChange', CopyStr(ChangeDetail, 1, 200));
        Sentry.FinalizeScope();
    end;

    local procedure EmitReadFailure()
    var
        Sentry: Codeunit "NPR Sentry";
        ReadFailedBeforeBaselineErrLbl: Label 'The ecommerce job queues cannot read NAV App Installed App, and this session never established a baseline, so it cannot tell whether an extension changed under it. It stops instead of processing records against an app set it cannot verify. Symptom to expect: the loops process nothing and the job queues retry on their next scheduled run until the read succeeds again. Cause: %1. This is a programming bug.', Locked = true;
        ReadFailedAfterBaselineErrLbl: Label 'The ecommerce job queues can no longer read NAV App Installed App, so this session cannot tell whether an extension changed under the baseline it holds. It stops instead of processing further records against an app set it can no longer verify. Symptom to expect: the loops process nothing and the job queues retry on their next scheduled run until the read succeeds again. Cause: %1. This is a programming bug.', Locked = true;
        ErrorText: Text;
        ErrorCallStack: Text;
        MessageTxt: Text;
    begin
        if _ReadFailureReported then
            exit;
        _ReadFailureReported := true;

        //This message is addressed to an developer, so it must not arrive in the job queue session's language.
        Sentry.GetLastErrorInEnglish(ErrorText, ErrorCallStack);

        if _BaselineTaken then
            MessageTxt := StrSubstNo(ReadFailedAfterBaselineErrLbl, ErrorText)
        else
            MessageTxt := StrSubstNo(ReadFailedBeforeBaselineErrLbl, ErrorText);

        Sentry.InitScopeAndTransaction('E-com App Set Watch', 'bc.e-com.appsetwatch');
        Sentry.AddError(MessageTxt, ErrorCallStack);
        Sentry.FinalizeScope();
    end;

    internal procedure DiffersFromBaseline(var CurrentApps: Dictionary of [Guid, Guid]; var CurrentNames: Dictionary of [Guid, Text]; var ChangeDetail: Text): Boolean
    var
        AppId: Guid;
        Details: Text;
        ChangeCount: Integer;
        AddedLbl: Label 'app %1.', Locked = true;
        RemovedLbl: Label 'app %1.', Locked = true;
        RepublishedLbl: Label 'app %1 package %2 -> %3', Locked = true;
        SummaryLbl: Label '%1 change(s): %2', Locked = true;
    begin
        Clear(ChangeDetail);

        foreach AppId in CurrentApps.Keys() do begin
            if not _BaselineApps.ContainsKey(AppId) then
                AddChange(Details, ChangeCount, StrSubstNo(AddedLbl, AppLabel(AppId, CurrentNames)))
            else
                if _BaselineApps.Get(AppId) <> CurrentApps.Get(AppId) then
                    AddChange(Details, ChangeCount, StrSubstNo(RepublishedLbl,
                        AppLabel(AppId, CurrentNames),
                        Format(_BaselineApps.Get(AppId), 0, 4),
                        Format(CurrentApps.Get(AppId), 0, 4)));
        end;

        foreach AppId in _BaselineApps.Keys() do
            if not CurrentApps.ContainsKey(AppId) then
                AddChange(Details, ChangeCount, StrSubstNo(RemovedLbl, AppLabel(AppId, CurrentNames)));

        if ChangeCount = 0 then
            exit(false);

        ChangeDetail := StrSubstNo(SummaryLbl, ChangeCount, Details);
        exit(true);
    end;

    local procedure AddChange(var Details: Text; var ChangeCount: Integer; Change: Text)
    begin
        ChangeCount += 1;
        if Details <> '' then
            Details += ' ';
        Details += Change;
    end;

    local procedure AppLabel(AppId: Guid; var CurrentNames: Dictionary of [Guid, Text]): Text
    begin
        if CurrentNames.ContainsKey(AppId) then
            exit(StrSubstNo('%1 [%2]', CurrentNames.Get(AppId), Format(AppId, 0, 4)));
        if _BaselineNames.ContainsKey(AppId) then
            exit(StrSubstNo('%1 [%2]', _BaselineNames.Get(AppId), Format(AppId, 0, 4)));
        exit(Format(AppId, 0, 4));
    end;

    internal procedure SetBaselineForTest(var Baseline: Dictionary of [Guid, Guid]; var BaselineNames: Dictionary of [Guid, Text])
    begin
        CopyApps(Baseline, _BaselineApps);
        CopyNames(BaselineNames, _BaselineNames);
        _BaselineTaken := true;
    end;

    internal procedure SetChangedForTest()
    begin
        _Changed := true;
    end;

    /// <summary>
    /// Test seam. Returns the SingleInstance to the state a fresh session starts in, so no test
    /// inherits a baseline, a latch or a report-once flag from the one before it.
    /// </summary>
    internal procedure ResetForTest()
    begin
        Clear(_BaselineApps);
        Clear(_BaselineNames);
        _BaselineTaken := false;
        _Changed := false;
        _ChangeReported := false;
        _ReadFailureReported := false;
    end;

    local procedure CopyApps(var FromApps: Dictionary of [Guid, Guid]; var ToApps: Dictionary of [Guid, Guid])
    var
        AppId: Guid;
    begin
        Clear(ToApps);
        foreach AppId in FromApps.Keys() do
            ToApps.Add(AppId, FromApps.Get(AppId));
    end;

    local procedure CopyNames(var FromNames: Dictionary of [Guid, Text]; var ToNames: Dictionary of [Guid, Text])
    var
        AppId: Guid;
    begin
        Clear(ToNames);
        foreach AppId in FromNames.Keys() do
            ToNames.Add(AppId, FromNames.Get(AppId));
    end;

    [TryFunction]
    local procedure TryCollectInstalledApps(var CurrentApps: Dictionary of [Guid, Guid]; var CurrentNames: Dictionary of [Guid, Text])
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        EmptyReadingErrLbl: Label 'NAV App Installed App came back with no rows at all, which cannot be a real app set while this app is running. This is a programming bug.', Locked = true;
    begin
        Clear(CurrentApps);
        Clear(CurrentNames);
        NAVAppInstalledApp.SetLoadFields("App ID", "Package ID", Name);
        if NAVAppInstalledApp.FindSet() then
            repeat
                CurrentApps.Set(NAVAppInstalledApp."App ID", NAVAppInstalledApp."Package ID");
                CurrentNames.Set(NAVAppInstalledApp."App ID", NAVAppInstalledApp.Name);
            until NAVAppInstalledApp.Next() = 0;

        // Only a completely empty reading counts as a failed read here. A reading that is missing this
        // app but holds the rest is a change, and ApplicationChanged reports it as one.
        if CurrentApps.Count() = 0 then
            Error(EmptyReadingErrLbl);
    end;

    var
        _BaselineApps: Dictionary of [Guid, Guid];
        _BaselineNames: Dictionary of [Guid, Text];
        _BaselineTaken: Boolean;
        _Changed: Boolean;
        _ChangeReported: Boolean;
        _ReadFailureReported: Boolean;
}
