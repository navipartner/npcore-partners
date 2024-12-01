codeunit 6185127 "NPR MM Subs Try Renew Process"
{
    Access = Internal;
    TableNo = "NPR MM Subscr. Request";

    trigger OnRun()
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SubscriptionRequest.ReadIsolation := IsolationLevel::UpdLock;
#else
        SubscriptionRequest.LockTable();
#endif
        SubscriptionRequest := Rec;
        SubscriptionRequest.Find();

        ProcessSubscriptionRenewalResponse(SubscriptionRequest);
    end;

    local procedure ProcessSubscriptionRenewalResponse(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        ProcessingStatusErrorLbl: Label 'Subscription request %1 has already been processed.', Comment = '%1 - subscription request no.';
    begin
        if SubscriptionRequest."Processing Status" = SubscriptionRequest."Processing Status"::Success then
            Error(ProcessingStatusErrorLbl, SubscriptionRequest."Entry No.");

        case SubscriptionRequest.Status of
            SubscriptionRequest.Status::New,
            SubscriptionRequest.Status::Requested:
                exit;  //waiting for the PSP to respond
            SubscriptionRequest.Status::Rejected:
                ProcessRejectedStatus(SubscriptionRequest);
            SubscriptionRequest.Status::Cancelled:
                ProcessCancelStatus(SubscriptionRequest);
            SubscriptionRequest.Status::"Request Error":
                ProcessRequestedErrorStatus(SubscriptionRequest);
            SubscriptionRequest.Status::Confirmed:
                ProcessConfirmedStatus(SubscriptionRequest)
        end;
    end;

    local procedure ProcessRejectedStatus(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        Subscription: Record "NPR MM Subscription";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin
        Subscription.Get(SubscriptionRequest."Subscription Entry No.");
        Subscription.Blocked := true;
        Subscription.Modify(true);

        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Rejected);
        SubscrPaymentRequest.SetLoadFields("Rejected Reason Code", "Rejected Reason Description");
        SubscrPaymentRequest.FindLast();

        MemberNotification.AddMembershipRenewalFailureNotification(Subscription."Membership Entry No.", Subscription."Membership Code", SubscrPaymentRequest."Rejected Reason Code", SubscrPaymentRequest."Rejected Reason Description");

        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest.Modify(true);
    end;

    local procedure ProcessConfirmedStatus(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        Subscription: Record "NPR MM Subscription";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        NewMembershipLedgerEntryNo: Integer;
        ReasonText: Text;
    begin
        Subscription.Get(SubscriptionRequest."Subscription Entry No.");
        CheckNotAlreadyRenewed(Subscription, SubscriptionRequest);
        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, Subscription."Membership Code", SubscriptionRequest."Item No.");
        MembershipAlterationSetup.TestField("Membership Duration");

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Membership Entry No." := Subscription."Membership Entry No.";
        MemberInfoCapture."Membership Code" := Subscription."Membership Code";
        MemberInfoCapture."Item No." := SubscriptionRequest."Item No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::AUTORENEW;
        MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
        if not MembershipMgt.CarryOutMembershipRenewal(SubscriptionRequest, MemberInfoCapture, MembershipAlterationSetup, NewMembershipLedgerEntryNo, ReasonText) then
            Error(ReasonText);

        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest.Modify(true);
    end;

    local procedure ProcessRequestedErrorStatus(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPaymentIHandler: Interface "NPR MM Subscr.Payment IHandler";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Error);
        if not SubscrPaymentRequest.FindLast() then
            exit;

        SubscrPaymentRequest.Validate(Status, SubscrPaymentRequest.Status::New);
        SubscrPaymentRequest.Modify(true);

        SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
        If not SubscrPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, _SkipTryCountUpdate, _Manual) then
            Error(GetLastErrorText());

        //Refresh subscription request
        SubscriptionRequest.Get(SubscriptionRequest.RecordId);
    end;

    local procedure ProcessCancelStatus(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    begin
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest.Modify(true);
    end;

    local procedure CheckNotAlreadyRenewed(Subscription: Record "NPR MM Subscription"; SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        SubscriptionRequest2: Record "NPR MM Subscr. Request";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        PeriodDoesNotMatchErr: Label 'Renewal period does not match for membership entry No. %1. The membership validity period may have been changed after the automatic subscription renewal request was created.', Comment = '%1 - membership entry number';
    begin
        SubscriptionRequest2 := SubscriptionRequest;
        RequestSubscrRenewal.CalculateSubscriptionRenewal(Subscription, SubscriptionRequest2);
        If (SubscriptionRequest."New Valid From Date" <> SubscriptionRequest2."New Valid From Date") or
           (SubscriptionRequest."New Valid Until Date" <> SubscriptionRequest2."New Valid Until Date")
        then
            Error(PeriodDoesNotMatchErr, Subscription."Membership Entry No.");
    end;

    internal procedure SetSkipTryCountUpdate(SkipTryCountUpdate: Boolean)
    begin
        _SkipTryCountUpdate := SkipTryCountUpdate;
    end;

    internal procedure GetSkipTryCountUpdate() SkipTryCountUpdate: Boolean;
    begin
        SkipTryCountUpdate := _SkipTryCountUpdate;
    end;

    internal procedure SetManual(Manual: Boolean)
    begin
        _Manual := Manual;
    end;

    internal procedure GetManual() Manual: Boolean;
    begin
        Manual := _Manual;
    end;

    var
        _SkipTryCountUpdate: Boolean;
        _Manual: Boolean;
}