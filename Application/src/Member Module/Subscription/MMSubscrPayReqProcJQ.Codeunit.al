codeunit 6185111 "NPR MM Subscr. Pay Req Proc JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        ProcessSubscriptionPaymentRequests();
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
        ErrorText: Text;
        MaxProcessTryCount: Integer;
        UpdatedStatus: Enum "NPR MM Payment Request Status";
    begin
        ErrorText := GetLastErrorText();
        if ErrorText = '' then
            exit;

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