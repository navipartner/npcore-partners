#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6150987 "NPR Entria Integration Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        _EntriaSetup: Record "NPR Entria Integration Setup";
        _EntriaStore: Record "NPR Entria Store";
        _HasEnabledStoreCache: Boolean;
        _HasEnabledStoreCached: Boolean;

    internal procedure CheckIsEnabled(EntriaStoreCode: Code[20])
    var
        IntegrationDisabledErr: Label 'NaviPartner BC-Entria integration is disabled. Please open the "Entria Integration Setup" page and enable the integration.';
        IntegrationDisabledAllStoresErr: Label 'NaviPartner BC-Entria integration must be enabled for at least one Entria store. Please open the "Entria Store" page and enable the integration.';
        IntegrationDisabledStoreErr: Label 'NaviPartner BC-Entria integration is disabled for the "%1" Entria store. Please open the "Entria Store" page and enable the integration.', Comment = '%1 - Entria store code';
    begin
        _EntriaSetup.GetRecordOnce(false);
        if not _EntriaSetup."Enable Integration" then
            Error(IntegrationDisabledErr);

        if EntriaStoreCode = '' then begin
            if HasEnabledStoreCached() then
                exit;
            Error(IntegrationDisabledAllStoresErr);
        end;

        if IsEnabled(EntriaStoreCode) then
            exit;
        Error(IntegrationDisabledStoreErr, EntriaStoreCode);
    end;

    internal procedure IsEnabled(EntriaStoreCode: Code[20]): Boolean
    begin
        GetStore(EntriaStoreCode);
        exit(IsStoreEnabled(_EntriaStore));
    end;

    internal procedure HasEnabledStore(): Boolean
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        if ReadySetup() then begin
            EntriaStore.SetRange(Enabled, true);
            exit(not EntriaStore.IsEmpty());
        end;

        exit(false);
    end;

    // Per-session cache; safe only for CheckIsEnabled (JQ-gated lifecycle).
    // Other callers must use HasEnabledStore() to avoid cross-session staleness.
    local procedure HasEnabledStoreCached(): Boolean
    begin
        if not _HasEnabledStoreCached then begin
            _HasEnabledStoreCache := HasEnabledStore();
            _HasEnabledStoreCached := true;
        end;
        exit(_HasEnabledStoreCache);
    end;

    internal procedure HasEnabledSalesOrderIntegrationStore(): Boolean
    var
        NoExclusions: List of [Code[20]];
    begin
        exit(HasEnabledSalesOrderIntegrationStore(NoExclusions));
    end;

    /// <summary>
    /// Tells whether any enabled Entria store imports sales orders - "Enable Integration" on the Entria setup,
    /// plus at least one store with both Enabled and "Sales Order Integration" ticked - optionally ignoring some
    /// of them. Comments in this module call that condition the master switch: it decides whether the order
    /// import job queue entry exists at all.
    /// </summary>
    /// <param name="ExcludedStoreCodes">
    /// Stores to leave out of the scan; empty to consider all of them. Needed because the store's OnDelete runs
    /// before the row is removed, so a store being deleted would otherwise still count towards the master switch.
    /// </param>
    internal procedure HasEnabledSalesOrderIntegrationStore(ExcludedStoreCodes: List of [Code[20]]): Boolean
    var
        EntriaStore: Record "NPR Entria Store";
        ExclusionFilter: Text;
    begin
        if not ReadySetup() then
            exit(false);

        ExclusionFilter := ExcludedStoresFilter(ExcludedStoreCodes);
        EntriaStore.SetRange(Enabled, true);
        EntriaStore.SetRange("Sales Order Integration", true);
        if ExclusionFilter <> '' then
            EntriaStore.SetFilter(SystemId, ExclusionFilter);
        exit(not EntriaStore.IsEmpty());
    end;

    /// <summary>
    /// Builds a "none of these" filter expression over SystemId for the given store codes.
    /// </summary>
    /// <remarks>
    /// Over SystemId, not Code: measured on BC 28.2 that '*' and '?' in a substituted value are filter wildcards
    /// even inside single quotes (quoting covers only '&', '(', ')', '=', '|'), so a filter over the admin-typed
    /// Code excludes 'NORTHEAST' along with 'NORTH*' and tears the import job down. A GUID cannot carry syntax.
    /// </remarks>
    local procedure ExcludedStoresFilter(ExcludedStoreCodes: List of [Code[20]]) FilterExpression: Text
    var
        EntriaStore: Record "NPR Entria Store";
        StoreCode: Code[20];
        NotEqualToLbl: Label '<>%1', Locked = true;
        AndLbl: Label '&', Locked = true;
    begin
        //Code is the only ordinary field needed here; SystemId travels with every partial record.
        EntriaStore.SetLoadFields(Code);
        foreach StoreCode in ExcludedStoreCodes do
            if EntriaStore.Get(StoreCode) then begin
                if FilterExpression <> '' then
                    FilterExpression += AndLbl;
                FilterExpression += StrSubstNo(NotEqualToLbl, EntriaStore.SystemId);
            end;
    end;

    local procedure ReadySetup(): Boolean
    begin
        if _EntriaSetup.IsEmpty() then
            exit(false);

        _EntriaSetup.GetRecordOnce(false);
        exit(_EntriaSetup."Enable Integration");
    end;

    internal procedure SetRereadSetup()
    begin
        Clear(_EntriaSetup);
        Clear(_EntriaStore);
        _HasEnabledStoreCached := false;
        SelectLatestVersion();
    end;

    local procedure GetStore(EntriaStoreCode: Code[20])
    begin
        if EntriaStoreCode = _EntriaStore.Code then
            exit;
        if EntriaStoreCode = '' then
            Clear(_EntriaStore)
        else
            _EntriaStore.Get(EntriaStoreCode);
    end;

    local procedure IsStoreEnabled(EntriaStore: Record "NPR Entria Store"): Boolean
    begin
        if not ReadySetup() then
            exit(false);

        if EntriaStore.Code = '' then
            exit(false);

        exit(EntriaStore.Enabled);
    end;

    internal procedure UpsertConnectionParams(var Rec: Record "NPR Entria Store")
    var
        InputDialog: Page "NPR Input Dialog";
        NewUrl: Text;
        NewKey: Text;
        MaskedKey: Text;
        MaskedLbl: Label '***', Locked = true;
        BaseUrlLbl: Label 'Entria Base Url';
        ParamsSavedMsg: Label 'Connection Parameters saved successfully.';
        SecretKeyLbl: Label 'Secret API Key';
    begin
        if Rec.HasAPIKey() then
            MaskedKey := MaskedLbl;

        NewUrl := Rec."Entria Url";
        InputDialog.SetInput(1, NewUrl, BaseUrlLbl);
        InputDialog.SetInput(2, MaskedKey, SecretKeyLbl);
        if not (InputDialog.RunModal() = Action::OK) then
            exit;

        InputDialog.InputText(1, NewUrl);
        if NewUrl <> Rec."Entria Url" then
#pragma warning disable AA0139
            Rec.Validate("Entria Url", NewUrl);
#pragma warning restore AA0139

        InputDialog.InputText(2, NewKey);
        if NewKey = '' then begin
            if Rec.HasAPIKey() then
                Rec.DeleteAPIKey();
        end else
            if NewKey <> MaskedLbl then
                Rec.SetAPIKey(NewKey);

        Rec.Modify();
        Message(ParamsSavedMsg);
    end;

    internal procedure ValidateEntriaUrl(var Rec: Record "NPR Entria Store")
    var
        EntriaAPIHandler: Codeunit "NPR Entria API Handler";
        InvalidEntriaUrlErr: Label 'The URL must be a valid Entria store URL.';
    begin
        if (Rec."Entria URL" = '') then
            exit;
#pragma warning disable AA0139
        if not Rec."Entria URL".ToLower().StartsWith('https://') and not Rec."Entria URL".ToLower().StartsWith('http://') then
            Rec."Entria URL" := CopyStr('https://' + Rec."Entria URL", 1, MaxStrLen(Rec."Entria URL"));
        if Rec."Entria URL".ToLower().EndsWith('/admin/') then
            Rec."Entria URL" := CopyStr(Rec."Entria URL", 1, StrLen(Rec."Entria URL") - 7)
        else
            if Rec."Entria URL".ToLower().EndsWith('/admin') then
                Rec."Entria URL" := CopyStr(Rec."Entria URL", 1, StrLen(Rec."Entria URL") - 6);
        if Rec."Entria URL".EndsWith('/') then
            Rec."Entria URL" := CopyStr(Rec."Entria URL", 1, StrLen(Rec."Entria URL") - 1);
#pragma warning restore
        if not EntriaAPIHandler.IsValidEntriaUrl(Rec."Entria URL") then
            Error(InvalidEntriaUrlErr);
    end;

    internal procedure TestEntriaStoreConnection(EntriaStore: Record "NPR Entria Store")
    var
        EntriaAPIHandler: Codeunit "NPR Entria API Handler";
        EntriaResponse: JsonToken;
        Window: Dialog;
        QueryingEntriaLbl: Label 'Testing connection to Entria...';
        SuccessMsg: Label 'Connection successful! Entria backend is reachable and API authentication is working.';
        NoAPIKeyErr: Label 'Please configure the Entria API Key before testing connectivity.';
    begin
        EntriaStore.TestField("Entria Url");
        if not EntriaStore.HasAPIKey() then
            Error(NoAPIKeyErr);

        Window.Open(QueryingEntriaLbl);
        ClearLastError();
        if not EntriaAPIHandler.GetEntriaStoreList(EntriaStore.Code, EntriaResponse) then begin
            Window.Close();
            Error(GetLastErrorText());
        end;
        Window.Close();

        if GuiAllowed() then
            Message(SuccessMsg);
    end;

    internal procedure SetupJobQueues()
    var
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
        MasterSwitch: Boolean;
    begin
        SetRereadSetup();
        MasterSwitch := HasEnabledSalesOrderIntegrationStore();
        EntriaOrderImportJQ.SetupJobQueue(MasterSwitch);
    end;

    internal procedure SetupJobQueuesOnStoreDeletion(DeletedStoreCode: Code[20])
    var
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
        ExcludedStoreCodes: List of [Code[20]];
    begin
        //Called from the store's OnDelete trigger, where the row being deleted is still readable, so the master
        //switch has to be evaluated as if the store were already gone. Without this the job survives deletion of
        //the last store importing sales orders, and - now that it is monitored - the refresher keeps it alive with
        //no store left to import from. Note that such a job does NOT fail fast: CheckIsEnabled() only errors when
        //the integration is off or no store is Enabled at all - it never consults "Sales Order Integration" - so a
        //leftover job passes its own gate rather than erroring out.
        ExcludedStoreCodes.Add(DeletedStoreCode);
        SetRereadSetup();
        EntriaOrderImportJQ.SetupJobQueue(HasEnabledSalesOrderIntegrationStore(ExcludedStoreCodes));
    end;

    internal procedure SetupJobQueuesWithConfirmation()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
        ConfigureJobQueuesQst: Label 'This function will create the job queue entry that imports sales orders from Entria, if it is missing, and register it as a monitored job, so that the job queue refresher recreates it if it is deleted. Recreation only happens while the job queue refresher itself is enabled.\\If the Entria sales order integration is switched off, any existing job queue entry for it is removed instead.\\Do you want to continue?';
        JobQueueConfiguredMsg: Label 'The "%1" job queue entry has been configured and registered as a monitored job.', Comment = '%1 - job queue entry description';
        IntegrationDisabledMsg: Label 'The Entria integration is switched off, so no job queue entry was created, and any existing one has been removed. Enable "%1" on this page and run this action again.', Comment = '%1 - the "Enable Integration" field caption';
        NoJobQueueCreatedMsg: Label 'No Entria store has the sales order integration enabled, so no job queue entry was created, and any existing one has been removed. Please open the "Entria Store" page and enable the integration for at least one store.';
        JobQueueNotReadyMsg: Label 'The Entria sales order integration is enabled, but the "%1" job queue entry is not ready to run, so no sales orders will be imported yet. Please open the "Job Queue Entries" page and set the status of the entry to Ready.', Comment = '%1 - job queue entry description';
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfigureJobQueuesQst, true) then
            exit;

        //Routed through SetupJobQueues() rather than SetupJobQueue(true) on purpose, so the master switch decides:
        //creating the job while the integration is off would produce an entry that fails on its first run.
        SetupJobQueues();

        if not GuiAllowed() then
            exit;

        //Reported after the work rather than disclosed in the question above, because the no-store case is not a
        //no-op - it is the branch that also cleans up an orphaned monitored row - and because the precondition
        //may live on another page, so the user needs to be told where to go rather than warned in the abstract.
        //
        //Read back from the entry, never from the master switch: the switch says what was asked for, not what runs.
        if EntriaOrderImportJQ.IsJobQueueReadyToRun() then begin
            Message(JobQueueConfiguredMsg, EntriaOrderImportJQ.GetJQDescription());
            exit;
        end;

        //The two "nothing was created" causes are reported separately, the way CheckIsEnabled() already separates
        //them: HasEnabledSalesOrderIntegrationStore() is false both when the master switch is off and when no
        //enabled store imports sales orders, and those need opposite instructions - the master switch is the field
        //on this very page, the store flag lives on the Entria Store page. Reporting the store message for a
        //switched-off integration sends the admin to enable something that is already enabled.
        if not ReadySetup() then begin
            Message(IntegrationDisabledMsg, _EntriaSetup.FieldCaption("Enable Integration"));
            exit;
        end;

        if not HasEnabledSalesOrderIntegrationStore() then begin
            Message(NoJobQueueCreatedMsg);
            exit;
        end;

        Message(JobQueueNotReadyMsg, EntriaOrderImportJQ.GetJQDescription());
    end;

    internal procedure GetOrderImportBlockedReasons(EntriaStoreCode: Code[20]) Reasons: Text
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
        EntriaStore: Record "NPR Entria Store";
        JobQueueEntry: Record "Job Queue Entry";
        IntegrationDisabledLbl: Label '%1: %2 is not enabled.', Comment = '%1 = Entria Integration Setup table caption, %2 = Enable Integration field caption';
        JobQueueNotActiveLbl: Label 'The %1 that imports Entria orders is not active.', Comment = '%1 = Job Queue Entry table caption';
        StoreMissingLbl: Label '%1 %2 no longer exists.', Comment = '%1 = Entria Store table caption, %2 = Entria store code';
        StoreDisabledLbl: Label '%1 %2 is not enabled.', Comment = '%1 = Entria Store table caption, %2 = Entria store code';
        StoreSettingDisabledLbl: Label '%1 is not enabled on %2 %3.', Comment = '%1 = caption of the store setting that is off, %2 = Entria Store table caption, %3 = Entria store code';
    begin
        if (not EntriaSetup.Get()) or (not EntriaSetup."Enable Integration") then
            AddReason(Reasons, StrSubstNo(IntegrationDisabledLbl, EntriaSetup.TableCaption(), EntriaSetup.FieldCaption("Enable Integration")));

        if not EntriaStore.Get(EntriaStoreCode) then
            AddReason(Reasons, StrSubstNo(StoreMissingLbl, EntriaStore.TableCaption(), EntriaStoreCode))
        else begin
            if not EntriaStore.Enabled then
                AddReason(Reasons, StrSubstNo(StoreDisabledLbl, EntriaStore.TableCaption(), EntriaStoreCode));
            if not EntriaStore."Sales Order Integration" then
                AddReason(Reasons, StrSubstNo(StoreSettingDisabledLbl, EntriaStore.FieldCaption("Sales Order Integration"), EntriaStore.TableCaption(), EntriaStoreCode));
        end;

        // SetupJobQueues creates the import job when the integration or store is enabled.
        // Only report the job queue state when the setup itself does not block importing.
        if Reasons <> '' then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Entria Order Import JQ");
        JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
        if JobQueueEntry.IsEmpty() then
            AddReason(Reasons, StrSubstNo(JobQueueNotActiveLbl, JobQueueEntry.TableCaption()));
    end;

    local procedure AddReason(var Reasons: Text; Reason: Text)
    begin
        if Reasons <> '' then
            Reasons += '\';
        Reasons += Reason;
    end;

    internal procedure DeleteRelatedRecords(StoreCode: Code[20])
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaStoreSyncState.SetRange("Store Code", StoreCode);
        EntriaStoreSyncState.DeleteAll();

        EntriaOrderImpFailure.SetRange("Store Code", StoreCode);
        EntriaOrderImpFailure.DeleteAll();
    end;
}
#endif