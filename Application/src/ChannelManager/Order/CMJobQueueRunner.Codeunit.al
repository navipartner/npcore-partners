codeunit 6150986 "NPR CMJobQueueRunner"
{
    Access = Internal;

    trigger OnRun()
    begin
        RecoverStaleScheduled();
        RecoverStaleProcessing();
        DispatchSubmittedOrders();
    end;

    local procedure RecoverStaleScheduled()
    var
        Order, Order2 : Record "NPR CMOrder";
        StaleThreshold: DateTime;
    begin
        // 5 minutes is comfortably longer than the normal Scheduled→Processing transition
        // (sub-second in practice — just temp hydration + entering IssueForOrder). If a JQ
        // instance is still actively transitioning, SystemModifiedAt is recent → row skipped.
        StaleThreshold := CurrentDateTime() - StaleScheduledThresholdMs();
        Order.SetCurrentKey(Status);
        Order.SetFilter(Status, '=%1', Order.Status::Scheduled);
        Order.SetFilter(SystemModifiedAt, '<%1', StaleThreshold);
        if (not Order.FindSet()) then
            exit;

        repeat
            Order2.Get(Order.OrderId); // re-read with default isolation to avoid update conflicts with the active JQ instance that may be transitioning this order
            Order2.Status := Order.Status::Submitted;
            Order2.Modify();
            Commit();
        until (Order.Next() = 0);
    end;

    local procedure RecoverStaleProcessing()
    var
        Order, Order2 : Record "NPR CMOrder";
        Sentry: Codeunit "NPR Sentry";
        StaleThreshold: DateTime;
        StuckMsg: Label 'Order was stuck in Processing for over 1 hour and was automatically marked as Error. Inspect and either re-Process or Delete.';
        SentryMsg: Label 'OTA Channel Manager order ''%1'' was stuck in Processing past the 1-hour threshold and was flipped to Error by the sweeper. The original session likely died mid-IssueForOrder; JobId / wallet / coupon state may be partial.', Locked = true;
    begin
        // 1 hour is far beyond the normal Processing duration
        // Flip to Error so the order leaves the live set and an operator can inspect / re-Process / Delete.
        StaleThreshold := CurrentDateTime() - StaleProcessingThresholdMs();
        Order.SetCurrentKey(Status);
        Order.SetFilter(Status, '=%1', Order.Status::Processing);
        Order.SetFilter(SystemModifiedAt, '<%1', StaleThreshold);
        if (not Order.FindSet()) then
            exit;

        repeat
            Order2.Get(Order.OrderId); // re-read with default isolation to avoid update conflicts with the active JQ instance that may be processing this order
            Order2.Status := Order.Status::Error;
            Order2.StatusMessage := CopyStr(StuckMsg, 1, MaxStrLen(Order2.StatusMessage));
            Order2.Modify();
            Commit();

            Sentry.AddError(StrSubstNo(SentryMsg, Format(Order.OrderId, 0, 4)));
        until (Order.Next() = 0);
    end;

    internal procedure ReProcessSingleOrder(var Order: Record "NPR CMOrder")
    var
        WrongStatusErr: Label 'Order status %1 is not eligible for manual processing — only Submitted (initial) or Error (retry) are.', Comment = '%1 = current status';
    begin
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        Order.ReadIsolation := IsolationLevel::UpdLock;
#else
        Order.LockTable(true);
#endif
        if (not Order.Find()) then
            exit;

        if (not (Order.Status in [Order.Status::Submitted, Order.Status::Error])) then
            Error(WrongStatusErr, Order.Status);

        Order.Status := Order.Status::Processing;
        Order.Modify();
        Commit();

        ProcessOneOrder(Order);
        Commit();
    end;

    local procedure DispatchSubmittedOrders()
    var
        Order: Record "NPR CMOrder";
    begin
        while (FindNextSubmitted(Order)) do begin
            Order.Status := Order.Status::Scheduled;
            Order.Modify();

            // releases the UpdLock; allow multiple JQ instances to claim in parallel, but only one will win the row lock and proceed to ProcessOneOrder
            Commit();
            ProcessOneOrder(Order);

            // commit the order's new status and send webhooks
            Commit();
        end;
    end;

    local procedure FindNextSubmitted(var Order: Record "NPR CMOrder"): Boolean
    begin
        Order.Reset();
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        Order.ReadIsolation := IsolationLevel::UpdLock;
#else
        Order.LockTable(true);
#endif
        Order.SetCurrentKey(Status);
        Order.SetFilter(Status, '=%1', Order.Status::Submitted);
        exit(Order.FindFirst());
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
    local procedure ProcessOneOrder(Order: Record "NPR CMOrder")
    var
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        Webhooks: Codeunit "NPR CMOrderWebhooks";
        ErrorMessage: Text;
    begin
        Sentry.StartSpan(Span, 'bc.ota-channel-manager-jq.process-order');

        ClearLastError();
        if (Codeunit.Run(Codeunit::"NPR CMOrderIssuer", Order)) then
            Webhooks.SendOrderCompletionHook(Order.OrderId)
        else begin
            Sentry.AddLastErrorIfProgrammingBug();
            ErrorMessage := GetLastErrorText();
            if (Order.Get(Order.OrderId)) then begin
                Order.Status := Order.Status::Error;
                Order.StatusMessage := CopyStr(ErrorMessage, 1, MaxStrLen(Order.StatusMessage));
                Order.Modify();
                Webhooks.SendOrderCompletionHook(Order.OrderId);
            end;
        end;

        Span.Finish();
    end;

#else
    local procedure ProcessOneOrder(Order: Record "NPR CMOrder")
    var
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        ErrorMessage: Text;
    begin
        Sentry.StartSpan(Span, 'bc.ota-channel-manager-jq.process-order');

        ClearLastError();
        if (not Codeunit.Run(Codeunit::"NPR CMOrderIssuer", Order)) then begin
            Sentry.AddLastErrorIfProgrammingBug();
            ErrorMessage := GetLastErrorText();
            if (Order.Get(Order.OrderId)) then begin
                Order.Status := Order.Status::Error;
                Order.StatusMessage := CopyStr(ErrorMessage, 1, MaxStrLen(Order.StatusMessage));
                Order.Modify();
            end;
        end;

        Span.Finish();
    end;
#endif

    local procedure StaleScheduledThresholdMs(): Integer
    begin
        exit(5 * 60 * 1000);   // 5 minutes
    end;

    local procedure StaleProcessingThresholdMs(): Integer
    begin
        exit(60 * 60 * 1000);   // 1 hour
    end;
}
