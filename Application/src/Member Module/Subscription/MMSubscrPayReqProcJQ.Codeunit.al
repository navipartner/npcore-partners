codeunit 6185111 "NPR MM Subscr. Pay Req Proc JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        ProcessSubscriptionPaymentRequests();
        RetryPayByLinkCancellation();
    end;

    internal procedure RetryPayByLinkCancellation()
    var
        PayByLinkPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        ResolvePayByLink: Codeunit "NPR MM Subscr. Resolve PBL";
        SubsRenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        ScheduleModes: Dictionary of [Code[20], Boolean];
        CursorText: Text;
        Cursor: BigInteger;
        ProcessedCount: Integer;
        StartedAt: DateTime;
        CursorKeyLbl: Label 'MM-PayByLink-Cleanup-Cursor', Locked = true;
    begin
        StartedAt := CurrentDateTime();
        if IsolatedStorage.Get(CursorKeyLbl, DataScope::Company, CursorText) then
            if not Evaluate(Cursor, CursorText) then
                Clear(Cursor);
        PayByLinkPaymentRequest.SetCurrentKey(Type, Status, PSP, "Entry No.");
        PayByLinkPaymentRequest.SetRange(Type, PayByLinkPaymentRequest.Type::PayByLink);
        PayByLinkPaymentRequest.SetRange(Status, PayByLinkPaymentRequest.Status::Requested);
        PayByLinkPaymentRequest.SetRange(PSP, PayByLinkPaymentRequest.PSP::Adyen);
        PayByLinkPaymentRequest.SetFilter("Entry No.", '>%1', Cursor);
        if PayByLinkPaymentRequest.FindSet() then
            repeat
                IsolatedStorage.Set(CursorKeyLbl, Format(PayByLinkPaymentRequest."Entry No."), DataScope::Company);
                ProcessedCount += 1;
                if SubscrRequestUtils.HasCapturedTokenPayment(PayByLinkPaymentRequest, ScheduleModes) then begin
                    Commit();
                    Clear(ResolvePayByLink);
                    ResolvePayByLink.SetAfterTokenSuccess(true);
                    if not ResolvePayByLink.Run(PayByLinkPaymentRequest) then
                        SubsRenewalMgt.LogPayByLinkError(PayByLinkPaymentRequest, GetLastErrorText());
                end;
                if (ProcessedCount >= 100) or (CurrentDateTime() - StartedAt >= 120 * 1000) then
                    exit;
            until PayByLinkPaymentRequest.Next() = 0;
        IsolatedStorage.Set(CursorKeyLbl, '0', DataScope::Company);
    end;

    local procedure ProcessSubscriptionPaymentRequests()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPayReqTryProcess: Codeunit "NPR MM Subscr.PayReqTryProcess";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::New);
        if not SubscrPaymentRequest.FindSet() then
            exit;

        repeat
            ClearLastError();
            if not SubscrPayReqTryProcess.Run(SubscrPaymentRequest) then
                HandlePaymentRequestError(SubscrPaymentRequest);
        until SubscrPaymentRequest.Next() = 0;
    end;

    local procedure HandlePaymentRequestError(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        SubscrPmtRequest: Record "NPR MM Subscr. Payment Request";
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        Sentry: Codeunit "NPR Sentry";
        ErrorText: Text;
        SentryCauseText: Text;
        SentryCauseCallStack: Text;
        MaxProcessTryCount: Integer;
        UpdatedStatus: Enum "NPR MM Payment Request Status";
    begin
        ErrorText := GetLastErrorText();
        if ErrorText = '' then
            exit;

        // Snapshot the crash cause (in English) now: the TryGetRecurringPaymentSetup call below is a TryFunction, and if it fails it replaces the last error with its own.
        Sentry.GetLastErrorInEnglish(SentryCauseText, SentryCauseCallStack);

        if not SubscrPmtRequest.Get(SubscrPaymentRequest."Entry No.") then
            exit;

        if SubscrPmtRequest.Status = SubscrPmtRequest.Status::Error then
            exit;

        SubsPayReqLogUtils.LogEntry(SubscrPmtRequest, '', '', false, SubsPayReqLogEntry);

        if TryGetRecurringPaymentSetup(SubscrPmtRequest, RecurPaymSetup) then
            MaxProcessTryCount := RecurPaymSetup."Max. Pay. Process Try Count";

        SubscrPmtRequest."Process Try Count" += 1;

        UpdatedStatus := SubscrPmtRequest.Status::Error;
        if SubscrPmtRequest."Process Try Count" < MaxProcessTryCount then
            UpdatedStatus := SubscrPmtRequest.Status;

        if SubscrPmtRequest.Status <> UpdatedStatus then
            SubscrPmtRequest.Validate(Status, UpdatedStatus);

        SubscrPmtRequest.Modify(true);

        SubsPayReqLogUtils.UpdateEntry(SubsPayReqLogEntry,
                                       '',
                                       '',
                                       SubsPayReqLogEntry."Processing Status"::Error,
                                       ErrorText,
                                       '',
                                       0);

        Commit();

        if UpdatedStatus = SubscrPmtRequest.Status::Error then
            SubscriptionMgtImpl.ReportPaymentRequestTerminalError(SubscrPmtRequest, SentryCauseText, SentryCauseCallStack);
    end;

    [TryFunction]
    local procedure TryGetRecurringPaymentSetup(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var RecurPaymSetup: Record "NPR MM Recur. Paym. Setup")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        SubscriptionRequest.SetLoadFields("Subscription Entry No.", "Membership Code");
        SubscriptionRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");

        MembershipSetup.SetLoadFields("Recurring Payment Code");
        MembershipSetup.Get(SubscriptionRequest."Membership Code");
        MembershipSetup.TestField("Recurring Payment Code");

        RecurPaymSetup.SetLoadFields("Max. Pay. Process Try Count");
        RecurPaymSetup.Get(MembershipSetup."Recurring Payment Code");
    end;
}
