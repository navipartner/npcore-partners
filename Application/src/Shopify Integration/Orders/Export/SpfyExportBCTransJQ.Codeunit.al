#if not (BC17 or BC18 or BC19 or BC20)
codeunit 6248624 "NPR Spfy Export BC Trans. JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ScheduleOutstandingPOSEntries(GetParameterStoreFilterValue(Rec));
    end;

    local procedure ScheduleOutstandingPOSEntries(ShopifyStoreFilter: Text): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        SpfyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        LastRowVersion: BigInteger;
        Success: Boolean;
    begin
        if ShopifyStoreFilter <> '' then
            SpfyStore.SetFilter(Code, ShopifyStoreFilter);
        SpfyStore.SetAutoCalcFields("Last POS Entry Row Version");
        if SpfyStore.FindSet() then
            repeat
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"BC Customer Transactions", SpfyStore) then
                    TempSpfyExportPointerBuffer.Add(SpfyStore.Code, SpfyStore."Historical Data Cut-Off Date", SpfyStore."Last POS Entry Row Version");
            until SpfyStore.Next() = 0;
        TempSpfyExportPointerBuffer.CheckIfScopeIsNotEmpty();
        Commit();

        LastRowVersion := TempSpfyExportPointerBuffer.GetMinLastPOSEntryRowVersion();
        POSEntry.SetCurrentKey(SystemRowVersion);
        if LastRowVersion > 0 then
            POSEntry.SetFilter(SystemRowVersion, '>%1', LastRowVersion);

        Clear(SpfyPOSEntryExportMgt);
        SpfyPOSEntryExportMgt.SetExportPointerBuffer(TempSpfyExportPointerBuffer);
        Success := SpfyPOSEntryExportMgt.Run(POSEntry);

        SpfyPOSEntryExportMgt.GetExportPointerBuffer(TempSpfyExportPointerBuffer);
        TempSpfyExportPointerBuffer.FindSet();
        repeat
            SpfyStore.Get(TempSpfyExportPointerBuffer."Shopify Store Code");
            if TempSpfyExportPointerBuffer."New Last POS Entry Row Version" > SpfyStore."Last POS Entry Row Version" then
                SpfyStore.SetLastPOSRowVersion(TempSpfyExportPointerBuffer."New Last POS Entry Row Version");
        until TempSpfyExportPointerBuffer.Next() = 0;
        Commit();

        if not Success then
            Error(GetLastErrorText());
    end;

    local procedure ParamStoreFilterName(): Text
    begin
        exit('store_filter');
    end;

    procedure SetupBCTransExportJobQueues()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        SetupBCTransExportJobQueues(ShopifyStore);
    end;

    procedure SetupBCTransExportJobQueues(var ShopifyStore: Record "NPR Spfy Store")
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        DisableAll: Boolean;
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        DisableAll := ShopifyStore.IsEmpty();
        if not DisableAll then
            DisableAll := not SpfyIntegrationMgt.BCCustomerTransactionSyncIsEnabledForAnyStore();
        if DisableAll then begin
            SetupBCTransExportJobQueues('', false);
            exit;
        end;

        if ShopifyStore.FindSet() then
            repeat
                SetupBCTransExportJobQueues(ShopifyStore.Code, SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"BC Customer Transactions", ShopifyStore));
            until ShopifyStore.Next() = 0;
    end;

    local procedure SetupBCTransExportJobQueues(ShopifyStoreCode: Code[20]; Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        ShopifyStore: Record "NPR Spfy Store";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ParamStoreFilterValue: Text;
        KeepJob: Boolean;
        Found: Boolean;
        ExportBCTransToShopifyLbl: Label 'Schedule POS Entry export to Shopify';
        ParamNameAndValueLbl: Label '%1=%2', Locked = true;
    begin
        case true of
            Enable:
                begin
                    JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, ParamStoreFilterName(), ShopifyStoreCode));
                    if JobQueueMgt.InitRecurringJobQueueEntry(
                        JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId(),
                        JQParamStrMgt.GetParamListAsCSString(), ExportBCTransToShopifyLbl,
                        JobQueueMgt.NowWithDelayInSeconds(300), 60,
                        '', JobQueueEntry)
                    then
                        JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
                    exit;
                end;

            ShopifyStoreCode = '':
                //Disable all job queues for all stores
                JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId());

            else begin
                //Disable job queues for the specified store
                if not JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId()) then
                    exit;
                JobQueueEntry.FindSet(true);
                repeat
                    ShopifyStore.Reset();
                    Found := JobQueueEntry."Parameter String" = '';
                    if not Found then begin
                        ParamStoreFilterValue := GetParameterStoreFilterValue(JobQueueEntry);
                        Found := ParamStoreFilterValue in ['', '*'];
                        if not Found then begin
                            ShopifyStore.SetFilter(Code, ParamStoreFilterValue);
                            ShopifyStore.Code := ShopifyStoreCode;
                            Found := ShopifyStore.Find();
                        end;
                    end;
                    if Found then begin
                        KeepJob := false;
                        if ShopifyStore.FindSet() then
                            repeat
                                if ShopifyStore.Code <> ShopifyStoreCode then
                                    KeepJob := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"BC Customer Transactions", ShopifyStore);
                            until KeepJob or (ShopifyStore.Next() = 0);
                        if not KeepJob then
                            JobQueueMgt.CancelNpManagedJob(JobQueueEntry);
                    end;
                until JobQueueEntry.Next() = 0;
            end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Spfy Export BC Trans. JQ");
    end;

    local procedure GetParameterStoreFilterValue(JobQueueEntry: Record "Job Queue Entry"): Text
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
    begin
        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        exit(JQParamStrMgt.GetParamValueAsText(ParamStoreFilterName()));
    end;

    local procedure IsSubset(var ShopifyStoreSubset: Record "NPR Spfy Store"; var ShopifyStoreSet: Record "NPR Spfy Store"): Boolean
    begin
        if ShopifyStoreSet.GetFilters() = '' then
            exit(true);
        ShopifyStoreSet.SetCurrentKey(Code);
        ShopifyStoreSet.SetLoadFields(Code);
        ShopifyStoreSubset.SetLoadFields(Code);
        if ShopifyStoreSubset.FindSet() then
            repeat
                ShopifyStoreSet.Code := ShopifyStoreSubset.Code;
                if not ShopifyStoreSet.Find() then
                    exit(false);
            until ShopifyStoreSubset.Next() = 0;
        exit(true);
    end;

#if BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnAfterSettingFiltersForJobQueueEntryExists', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnAfterSettingFiltersForJobQueueEntryExists, '', false, false)]
#endif
    local procedure SearchRelevantSpfyExportBCTransJQEntry(var Parameters: Record "Job Queue Entry"; var JobQueueEntry: Record "Job Queue Entry")
    var
        ShopifyStore: Record "NPR Spfy Store";
        ShopifyStoreNew: Record "NPR Spfy Store";
        ParamStoreFilterValue: Text;
        Found: Boolean;
    begin
        if not ((Parameters."Object Type to Run" = Parameters."Object Type to Run"::Codeunit) and (Parameters."Object ID to Run" = CurrCodeunitId())) then
            exit;
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.SetRange("Job Queue Category Code");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.SetRange("Parameter String");
        if not JobQueueEntry.Find('-') then
            exit;

        ParamStoreFilterValue := GetParameterStoreFilterValue(Parameters);
        if ParamStoreFilterValue <> '' then
            ShopifyStoreNew.SetFilter(Code, ParamStoreFilterValue);

        repeat
            if not JobQueueEntry.IsExpired(Parameters."Earliest Start Date/Time") then begin
                Found := JobQueueEntry."Parameter String" = '';
                if not Found then begin
                    ParamStoreFilterValue := GetParameterStoreFilterValue(JobQueueEntry);
                    Found := ParamStoreFilterValue in ['', '*'];
                    if not Found then begin
                        ShopifyStore.SetFilter(Code, ParamStoreFilterValue);
                        Found := IsSubset(ShopifyStoreNew, ShopifyStore);
                    end;
                end;
                if Found then begin
                    JobQueueEntry.SetRecFilter();
                    Parameters."Parameter String" := JobQueueEntry."Parameter String";
                    exit;
                end;
            end;
        until JobQueueEntry.Next() = 0;
    end;

#if BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RefreshJobQueueEntry()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        If ShopifySetup.IsEmpty() then
            exit;
        SetupBCTransExportJobQueues();
    end;
}
#endif