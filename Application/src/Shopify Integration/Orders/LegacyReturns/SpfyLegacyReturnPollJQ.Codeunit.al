codeunit 6151173 "NPR Spfy Legacy Return Poll JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        PollAllStores();
    end;

    var
        _SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        _JsonHelper: Codeunit "NPR Json Helper";
        _OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _SpfyOrderApiHelper.SetGraphQLClient(GraphQLClient);
    end;

    internal procedure PollAllStores()
    var
        ShopifyStore: Record "NPR Spfy Store";
        TempQueueRow: Record "NPR Spfy NC Return Queue" temporary;
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StartedAt: DateTime;
        MaxRunDuration: Duration;
        FailedStores: Text;
        TruncatedOrders: Text;
        PollFailedTransactionLbl: Label 'Shopify legacy return poll failed: %1', Comment = '%1 = Shopify store code', Locked = true;
        PollFailedErr: Label 'Polling Shopify for closed returns and refunds failed for the following stores: %1', Comment = '%1 = store codes with their errors, one per line';
        RefundsTruncatedErr: Label 'Shopify returned %2 refunds for order(s) %1, the most one request reads, so further refunds of these orders may be missing from the queue. Check the orders in Shopify and handle any missing refund manually.', Comment = '%1 = Shopify order names, %2 = number of refunds read per order';
        StartDateMissingErr: Label '%1 is blank on %2 %3, so its returns and refunds are not polled. Set it to the date the import should start from.', Comment = '%1 = Get Returns Starting From field caption, %2 = Shopify Store table caption, %3 = Shopify store code';
    begin
        // The Ecommerce engine owns returns while its feature is on; a job entry recreated in a refresh race must not poll.
        if ShopifyEcommOrderExp.IsFeatureEnabled() then
            exit;
        StartedAt := CurrentDateTime();
        MaxRunDuration := 15 * 60 * 1000;
        ShopifyStore.SetRange(Enabled, true);
        if ShopifyStore.FindSet() then
            repeat
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Returns", ShopifyStore) then begin
                    ClearLastError();
                    TruncatedOrders := '';
                    // A blank start date would widen the window to the whole lookback, returns credited before go-live included.
                    if ShopifyStore."Get Returns Starting From" = 0DT then
                        AppendFailure(FailedStores, ShopifyStore.Code, StrSubstNo(StartDateMissingErr, ShopifyStore.FieldCaption("Get Returns Starting From"), ShopifyStore.TableCaption(), ShopifyStore.Code))
                    else
                        if TryListClosedReturns(ShopifyStore, TempQueueRow, TruncatedOrders) then begin
                            InsertNewRows(TempQueueRow);
                            if TruncatedOrders <> '' then
                                AppendFailure(FailedStores, ShopifyStore.Code, StrSubstNo(RefundsTruncatedErr, TruncatedOrders, RefundListSize()));
                        end else begin
                            AppendFailure(FailedStores, ShopifyStore.Code, GetLastErrorText());
                            if _SpfyLegacyReturnMgt.ReportProgrammingBugToSentry(ShopifyStore.Code, '', StrSubstNo(PollFailedTransactionLbl, ShopifyStore.Code), 'bc.shopify.legacyreturn.poll.error') then;
                        end;
                    Commit();
                end;
            until (ShopifyStore.Next() = 0) or (CurrentDateTime() - StartedAt > MaxRunDuration) or ShopifyEcommOrderExp.IsFeatureEnabled();
        if FailedStores <> '' then
            Error(PollFailedErr, FailedStores);
    end;

    [TryFunction]
    local procedure TryListClosedReturns(ShopifyStore: Record "NPR Spfy Store"; var TempQueueRow: Record "NPR Spfy NC Return Queue" temporary; var TruncatedOrders: Text)
    var
        RefundsToken: JsonToken;
        ShopifyResponse: JsonToken;
        OrdersArr: JsonArray;
        ReturnsArr: JsonArray;
        OrderTkn: JsonToken;
        OrderNode: JsonToken;
        ReturnsEdges: JsonToken;
        QueryFilters: Text;
        Cursor: Text;
        PreviousCursor: Text;
        ReturnsCursor: Text;
        PreviousReturnsCursor: Text;
        OrderGID: Text;
        HasNext: Boolean;
        MoreReturns: Boolean;
        PageCount: Integer;
        TooManyPagesErr: Label 'Polling %1 %2 for closed returns and refunds did not finish after %3 pages and was stopped. Shorten %4 or move %5 forward so that fewer orders fall in the window.', Comment = '%1 = Shopify Store table caption, %2 = Shopify store code, %3 = page limit, %4 = Return Poll Lookback (Days) field caption, %5 = Get Returns Starting From field caption';
        CursorStuckErr: Label 'Polling Shopify store %1 for closed returns received page cursor %2 twice in a row, so the paging would never end. This is a programming bug.', Locked = true;
        StatusAnyTok: Label ' status:any', Locked = true;
    begin
        TempQueueRow.Reset();
        TempQueueRow.DeleteAll();
        QueryFilters := _SpfyOrderApiHelper.ReturnListFilter(WindowStart(ShopifyStore)) + StatusAnyTok;
        Cursor := '';
        HasNext := true;
        repeat
            PageCount += 1;
            if PageCount > 1000 then
                Error(TooManyPagesErr, ShopifyStore.TableCaption(), ShopifyStore.Code, 1000, ShopifyStore.FieldCaption("Return Poll Lookback (Days)"), ShopifyStore.FieldCaption("Get Returns Starting From"));
            PreviousCursor := Cursor;
            if not _SpfyOrderApiHelper.GetReturnAndRefundList(HasNext, ShopifyResponse, ShopifyStore, OrdersArr, Cursor, QueryFilters) then
                Error(GetLastErrorText());
            // A cursor that does not move is the paging defect the page cap guards against; the cap itself is sizing.
            if HasNext and (Cursor = PreviousCursor) then
                Error(CursorStuckErr, ShopifyStore.Code, Cursor);
            foreach OrderTkn in OrdersArr do begin
                OrderTkn.SelectToken('node', OrderNode);
                OrderGID := _JsonHelper.GetJText(OrderNode, 'id', true);
                if OrderNode.SelectToken('returns.edges', ReturnsEdges) then
                    AddClosedReturns(ShopifyStore, OrderGID, ReturnsEdges.AsArray(), TempQueueRow);
                if _JsonHelper.GetJBoolean(OrderNode, 'returns.pageInfo.hasNextPage', false) then begin
                    ReturnsCursor := _JsonHelper.GetJText(OrderNode, 'returns.pageInfo.endCursor', false);
                    MoreReturns := true;
                    repeat
                        PageCount += 1;
                        if PageCount > 1000 then
                            Error(TooManyPagesErr, ShopifyStore.TableCaption(), ShopifyStore.Code, 1000, ShopifyStore.FieldCaption("Return Poll Lookback (Days)"), ShopifyStore.FieldCaption("Get Returns Starting From"));
                        PreviousReturnsCursor := ReturnsCursor;
                        if not _SpfyOrderApiHelper.GetOrderReturns(ShopifyStore, OrderGID, ReturnsCursor, MoreReturns, ReturnsArr) then
                            Error(GetLastErrorText());
                        if MoreReturns and (ReturnsCursor = PreviousReturnsCursor) then
                            Error(CursorStuckErr, ShopifyStore.Code, ReturnsCursor);
                        AddClosedReturns(ShopifyStore, OrderGID, ReturnsArr, TempQueueRow);
                    until not MoreReturns;
                end;
                if OrderNode.SelectToken('refunds', RefundsToken) then
                    if RefundsToken.IsArray() then
                        AddRefundsWithoutReturn(ShopifyStore, OrderGID, _JsonHelper.GetJText(OrderNode, 'name', false), RefundsToken.AsArray(), TempQueueRow, TruncatedOrders);
            end;
        until not HasNext;
    end;

    local procedure AddClosedReturns(ShopifyStore: Record "NPR Spfy Store"; OrderGID: Text; ReturnsArr: JsonArray; var TempQueueRow: Record "NPR Spfy NC Return Queue" temporary)
    var
        ReturnEdge: JsonToken;
        ClosedAt: DateTime;
    begin
        foreach ReturnEdge in ReturnsArr do
            if _JsonHelper.GetJText(ReturnEdge, 'node.status', false).ToUpper() = 'CLOSED' then begin
                // Skip returns closed before the start date, even when refunded after it: those stay with manual handling.
                ClosedAt := _JsonHelper.GetJDT(ReturnEdge, 'node.closedAt', false);
                if (ClosedAt = 0DT) or (ClosedAt >= ShopifyStore."Get Returns Starting From") then
                    AddQueueRow(ShopifyStore.Code, OrderGID, ReturnEdge, TempQueueRow);
            end;
    end;

    local procedure AddQueueRow(ShopifyStoreCode: Code[20]; OrderGID: Text; ReturnEdge: JsonToken; var TempQueueRow: Record "NPR Spfy NC Return Queue" temporary)
    var
        Candidate: Record "NPR Spfy NC Return Queue";
    begin
        Candidate.Init();
        Candidate."Shopify Store Code" := ShopifyStoreCode;
        Candidate."Source Doc. Type" := Candidate."Source Doc. Type"::Return;
        Candidate."Source Doc. ID" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(ReturnEdge, 'node.id', true));
        Candidate."Source Doc. Name" := CopyStr(_JsonHelper.GetJText(ReturnEdge, 'node.name', false), 1, MaxStrLen(Candidate."Source Doc. Name"));
        Candidate."Order Id" := _OrderMgt.GetNumericId(OrderGID);
        Candidate.Status := Candidate.Status::New;
        AddToBuffer(Candidate, TempQueueRow);
    end;

    /// <summary>
    /// Adds a candidate once per Shopify document; a temporary record does not auto-increment, so the buffer numbers its own rows.
    /// </summary>
    local procedure AddToBuffer(Candidate: Record "NPR Spfy NC Return Queue"; var TempQueueRow: Record "NPR Spfy NC Return Queue" temporary)
    var
        EntryNo: BigInteger;
    begin
        if TempQueueRow.FindSourceDoc(Candidate."Shopify Store Code", Candidate."Source Doc. Type", Candidate."Source Doc. ID") then
            exit;
        TempQueueRow.Reset();
        if TempQueueRow.FindLast() then
            EntryNo := TempQueueRow."Entry No.";
        TempQueueRow := Candidate;
        TempQueueRow."Entry No." := EntryNo + 1;
        TempQueueRow.Insert();
    end;

    local procedure AddRefundsWithoutReturn(ShopifyStore: Record "NPR Spfy Store"; OrderGID: Text; OrderName: Text; RefundsArr: JsonArray; var TempQueueRow: Record "NPR Spfy NC Return Queue" temporary; var TruncatedOrders: Text)
    var
        RefundToken: JsonToken;
        CreatedAt: DateTime;
        StartingFrom: DateTime;
    begin
        // Refunds made before refunds were imported were credited by hand; the upgrade sets their own start date.
        StartingFrom := ShopifyStore."Get Returns Starting From";
        if ShopifyStore."Get Refunds Starting From" > StartingFrom then
            StartingFrom := ShopifyStore."Get Refunds Starting From";
        foreach RefundToken in RefundsArr do
            // A refund that belongs to a return is left to the return path, not queued as a refund.
            if not RefundHasReturn(RefundToken) then begin
                CreatedAt := _JsonHelper.GetJDT(RefundToken, 'createdAt', false);
                if (CreatedAt = 0DT) or (CreatedAt >= StartingFrom) then
                    AddRefundQueueRow(ShopifyStore.Code, OrderGID, OrderName, RefundToken, TempQueueRow);
            end;
        if RefundsArr.Count() >= RefundListSize() then begin
            if TruncatedOrders <> '' then
                TruncatedOrders += ', ';
            TruncatedOrders += OrderName;
        end;
    end;

    local procedure RefundHasReturn(RefundToken: JsonToken): Boolean
    var
        ReturnToken: JsonToken;
    begin
        if not RefundToken.SelectToken('return', ReturnToken) then
            exit(false);
        exit(ReturnToken.IsObject());
    end;

    local procedure AddRefundQueueRow(ShopifyStoreCode: Code[20]; OrderGID: Text; OrderName: Text; RefundToken: JsonToken; var TempQueueRow: Record "NPR Spfy NC Return Queue" temporary)
    var
        Candidate: Record "NPR Spfy NC Return Queue";
    begin
        Candidate.Init();
        Candidate."Shopify Store Code" := ShopifyStoreCode;
        Candidate."Source Doc. Type" := Candidate."Source Doc. Type"::Refund;
        Candidate."Source Doc. ID" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(RefundToken, 'id', true));
        // A refund has no name of its own in Shopify; it goes by its order's.
        Candidate."Source Doc. Name" := CopyStr(OrderName, 1, MaxStrLen(Candidate."Source Doc. Name"));
        // The waiting note names the order before any Shopify call fills it from the detail.
        Candidate."Order No." := CopyStr(OrderName, 1, MaxStrLen(Candidate."Order No."));
        Candidate."Order Id" := _OrderMgt.GetNumericId(OrderGID);
        Candidate.Status := Candidate.Status::New;
        AddToBuffer(Candidate, TempQueueRow);
    end;

    /// <summary>
    /// The refunds the list query reads per order; as many back means more may exist.
    /// </summary>
    local procedure RefundListSize(): Integer
    begin
        exit(50);
    end;

    internal procedure InsertNewRows(var TempQueueRow: Record "NPR Spfy NC Return Queue" temporary)
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
    begin
        // The feature may have been switched on during the listing; read under the switch's lock, since its guard could not see this buffer.
        if _SpfyLegacyReturnMgt.FeatureSwitchedOn() then
            exit;
        TempQueueRow.Reset();
        if not TempQueueRow.FindSet() then
            exit;
        // A store deleted while its returns were listed gets no rows (they would be orphans); the lock waits for a delete in flight.
        ShopifyStore.LockTable();
        repeat
            if ShopifyStore.Get(TempQueueRow."Shopify Store Code") then
                // The job and Poll Shopify Now may run at once; the store lock makes the later one wait, so it sees the row the other committed.
                if not QueueRow.FindSourceDoc(TempQueueRow."Shopify Store Code", TempQueueRow."Source Doc. Type", TempQueueRow."Source Doc. ID") then begin
                    QueueRow := TempQueueRow;
                    QueueRow."Entry No." := 0;
                    QueueRow."Detected At" := 0DT;
                    QueueRow.Insert(true);
                end;
        until TempQueueRow.Next() = 0;
    end;

    /// <summary>
    /// The later of now minus the lookback and the store's start date.
    /// </summary>
    internal procedure WindowStart(ShopifyStore: Record "NPR Spfy Store"): DateTime
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        LookbackDays: Integer;
        WindowStartDT: DateTime;
    begin
        LookbackDays := ShopifyStore."Return Poll Lookback (Days)";
        if LookbackDays <= 0 then
            LookbackDays := 30;
        WindowStartDT := CurrentDateTime() - JobQueueMgt.DaysToDuration(LookbackDays);
        if ShopifyStore."Get Returns Starting From" > WindowStartDT then
            WindowStartDT := ShopifyStore."Get Returns Starting From";
        exit(WindowStartDT);
    end;

    local procedure AppendFailure(var FailedStores: Text; ShopifyStoreCode: Code[20]; ErrorText: Text)
    var
        StoreFailureLbl: Label '%1: %2', Locked = true;
    begin
        if FailedStores <> '' then
            FailedStores += '\';
        FailedStores += StrSubstNo(StoreFailureLbl, ShopifyStoreCode, ErrorText);
    end;

    internal procedure SetupJobQueues()
    var
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        SetupJobQueues(ShopifyEcommOrderExp.IsFeatureEnabled());
    end;

    /// <summary>
    /// Takes the feature state for callers that run before the feature row is saved.
    /// </summary>
    internal procedure SetupJobQueues(EcommerceFeatureEnabled: Boolean)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        RegisterOrCancelJobs(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns") and not EcommerceFeatureEnabled);
    end;

    /// <summary>
    /// Ignores the given stores, for a store that is being deleted but is still readable.
    /// </summary>
    internal procedure SetupJobQueues(EcommerceFeatureEnabled: Boolean; ExcludedStoreSystemIds: List of [Guid])
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        RegisterOrCancelJobs(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns", ExcludedStoreSystemIds) and not EcommerceFeatureEnabled);
    end;

    local procedure RegisterOrCancelJobs(Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        PollJobDescriptionLbl: Label 'Get closed Shopify returns and refunds (legacy order import)';
        ProcessJobDescriptionLbl: Label 'Import queued Shopify returns and refunds (legacy order import)';
    begin
        if not Enable then begin
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Spfy Legacy Return Poll JQ");
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Spfy Legacy Return Proc JQ");
            exit;
        end;
        // One failing store must not park the job at Error for every store. BC itself reruns a failed entry up to five times
        // three minutes apart; once it reaches Error, the job restarts after its own interval instead of staying parked.
        JobQueueMgt.SetProtected(true);
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 15 * 60, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Spfy Legacy Return Poll JQ",
            '', PollJobDescriptionLbl, JobQueueMgt.NowWithDelayInSeconds(300), 15, '', JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        Clear(JobQueueEntry);
        JobQueueMgt.SetProtected(true);
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 5 * 60, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Spfy Legacy Return Proc JQ",
            '', ProcessJobDescriptionLbl, JobQueueMgt.NowWithDelayInSeconds(600), _SpfyLegacyReturnMgt.DefaultProcessJobIntervalMinutes(), '', JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure JobQueueEntryExists(CodeunitId: Integer): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        exit(not JobQueueEntry.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntries()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        if ShopifySetup.IsEmpty() then
            exit;
        SetupJobQueues();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNprCustomizableJob', '', false, false)]
    local procedure SetAsNprCustomizableJob(JobQueueEntry: Record "Job Queue Entry"; var NprCustomizableJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit;
        if not (JobQueueEntry."Object ID to Run" in [Codeunit::"NPR Spfy Legacy Return Poll JQ", Codeunit::"NPR Spfy Legacy Return Proc JQ"]) then
            exit;
        NprCustomizableJob := true;
        Handled := true;
    end;
}
