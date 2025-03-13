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
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        MemberNotification: Codeunit "NPR MM Member Notification";
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
        PaymentLinkUrl: Text[2048];
    begin
        Subscription.Get(SubscriptionRequest."Subscription Entry No.");
        Membership.Get(Subscription."Membership Entry No.");
        Membership."Auto-Renew" := Membership."Auto-Renew"::NO;
        Membership.Modify(true);

        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Rejected);
        SubscrPaymentRequest.FindLast();

        SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
        if not SubscrPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, false, false) then
            Error(GetLastErrorText());

        SubscriptionRequest.Validate("Processing Status", SubscriptionRequest."Processing Status"::Success);
        SubscriptionRequest.Modify(true);

        PaymentLinkUrl := FindPayByLink(SubscrPaymentRequest);
        MemberNotification.AddMembershipRenewalFailureNotification(Subscription."Membership Entry No.", Subscription."Membership Code", SubscrPaymentRequest."Rejected Reason Code", SubscrPaymentRequest."Rejected Reason Description", PaymentLinkUrl);
    end;

    local procedure ProcessConfirmedStatus(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    begin
        case SubscriptionRequest.Type of
            SubscriptionRequest.Type::Renew:
                RenewMembership(SubscriptionRequest);

            SubscriptionRequest.Type::Regret:
                RegretMembershipAction(SubscriptionRequest);
        end;
    end;

    local procedure RenewMembership(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Subscription: Record "NPR MM Subscription";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        NewMembershipLedgerEntryNo: Integer;
        ReasonText: Text;
    begin
        SubscriptionRequest.TestField(Type, SubscriptionRequest.Type::Renew);
        Subscription.Get(SubscriptionRequest."Subscription Entry No.");
        CheckHasntBeenChanged(Subscription, SubscriptionRequest);
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

        SubscriptionRequest."Posted M/ship Ledg. Entry No." := NewMembershipLedgerEntryNo;
        SubscriptionRequest.Validate("Processing Status", SubscriptionRequest."Processing Status"::Success);
        SubscriptionRequest.Modify(true);
    end;

    local procedure RegretMembershipAction(var SubscrReversalRequest: Record "NPR MM Subscr. Request")
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        OriginalSubscriptionRequest: Record "NPR MM Subscr. Request";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        SubscrRenewPost: Codeunit "NPR MM Subscr. Renew: Post";
        OriginalSubscRequestFound: Boolean;
        OriginalSubscRequestNotFoundErr: Label 'Original subscription request for reversal request number %1 could not be found.';
    begin
        SubscrReversalRequest.TestField(Type, SubscrReversalRequest.Type::Regret);
        OriginalSubscriptionRequest := SubscrReversalRequest;
        repeat
            OriginalSubscriptionRequest.SetRange("Reversed by Entry No.", OriginalSubscriptionRequest."Entry No.");
            if OriginalSubscriptionRequest.IsEmpty() then
                OriginalSubscRequestFound := OriginalSubscriptionRequest."Entry No." <> SubscrReversalRequest."Entry No."
            else
                OriginalSubscriptionRequest.FindLast();
        until OriginalSubscRequestFound;
        if not OriginalSubscRequestFound then
            Error(OriginalSubscRequestNotFoundErr, SubscrReversalRequest);

        if OriginalSubscriptionRequest."Processing Status" in [OriginalSubscriptionRequest."Processing Status"::Pending, OriginalSubscriptionRequest."Processing Status"::Error] then
            if OriginalSubscriptionRequest."Posted M/ship Ledg. Entry No." = 0 then begin
                CloseSubscriptionRequestChain(OriginalSubscriptionRequest);
                exit;
            end;

        OriginalSubscriptionRequest.TestField("Posted M/ship Ledg. Entry No.");
        GetAndCheckMembershipEntry(SubscrReversalRequest, OriginalSubscriptionRequest."Posted M/ship Ledg. Entry No.", MembershipEntry);
        Membership.Get(MembershipEntry."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");

        MembershipMgt.CarryOutMembershipRegret(MembershipEntry);
        SubscrRenewPost.PostInvoiceToGL(SubscrReversalRequest, Membership, MembershipSetup);
        if SubscrReversalRequest.Posted then
            SubscrRenewPost.PostPaymentsToGL(SubscrReversalRequest, '');

        SubscrReversalRequest.Validate("Processing Status", SubscrReversalRequest."Processing Status"::Success);
        SubscrReversalRequest.Modify(true);
    end;

    local procedure ProcessRequestedErrorStatus(var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
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
        SubscriptionRequest.Validate("Processing Status", SubscriptionRequest."Processing Status"::Success);
        SubscriptionRequest.Modify(true);
    end;

    local procedure CheckHasntBeenChanged(Subscription: Record "NPR MM Subscription"; SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        SubscriptionRequest2: Record "NPR MM Subscr. Request";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        MMMembership: Record "NPR MM Membership";
        PeriodDoesNotMatchErr: Label 'Renewal period does not match for membership entry No. %1. The membership validity period may have been changed after the automatic subscription renewal request was created.', Comment = '%1 - membership entry number';
        PriceDoesNotMatchErr: Label 'The renewal amount does not match for membership entry No. %1. The membership type may have been changed after the automatic subscription renewal request was created.', Comment = '%1 - membership entry number';
        MembershipBlockedErr: Label 'Membership entry No. %1 is blocked. The renewal process cannot continue.', Comment = '%1 - membership entry number';
    begin
        SubscriptionRequest2 := SubscriptionRequest;
        RequestSubscrRenewal.CalculateSubscriptionRenewal(Subscription, SubscriptionRequest2);
        If (SubscriptionRequest."New Valid From Date" <> SubscriptionRequest2."New Valid From Date") or
           (SubscriptionRequest."New Valid Until Date" <> SubscriptionRequest2."New Valid Until Date")
        then
            Error(PeriodDoesNotMatchErr, Subscription."Membership Entry No.");
        If SubscriptionRequest.Amount <> SubscriptionRequest2.Amount then
            Error(PriceDoesNotMatchErr, Subscription."Membership Entry No.");

        If MMMembership.Get(Subscription."Membership Entry No.") then
            if MMMembership.Blocked then
                Error(MembershipBlockedErr, Subscription."Membership Entry No.");
    end;

    local procedure CloseSubscriptionRequestChain(SubscriptionRequest: Record "NPR MM Subscr. Request")
    begin
        repeat
            if SubscriptionRequest.Mark() then
                exit;  //avoid possible endless loop due to subscription request circular references
            CloseSubscriptionRequest(SubscriptionRequest);
            SubscriptionRequest.Mark(true);
        until not SubscriptionRequest.Get(SubscriptionRequest."Reversed by Entry No.");
    end;

    local procedure CloseSubscriptionRequest(SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup";
        SubscrRenewPost: Codeunit "NPR MM Subscr. Renew: Post";
        PostingDocumentNo: Code[20];
    begin
        if not (SubscriptionRequest."Processing Status" in [SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status"::Error]) then
            SubscriptionRequest.FieldError("Processing Status");
        SubscriptionRequest.TestField(Status, SubscriptionRequest.Status::Confirmed);

        if SubscriptionRequest."Posting Document No." <> '' then
            PostingDocumentNo := SubscriptionRequest."Posting Document No."
        else begin
            MembershipSetup.SetLoadFields("Recurring Payment Code");
            MembershipSetup.Get(SubscriptionRequest."Membership Code");
            RecurringPaymentSetup.SetLoadFields("Document No. Series");
            RecurringPaymentSetup.Get(MembershipSetup."Recurring Payment Code");
            PostingDocumentNo := SubscrRenewPost.GetPostingDocumentNo(RecurringPaymentSetup);
        end;

        SubscrRenewPost.PostPaymentsToGL(SubscriptionRequest, PostingDocumentNo);

        SubscriptionRequest.Validate("Processing Status", SubscriptionRequest."Processing Status"::Success);
        SubscriptionRequest.Modify(true);
    end;

    local procedure GetAndCheckMembershipEntry(SubscrReversalRequest: Record "NPR MM Subscr. Request"; MembershipEntryEntryNo: Integer; var MembershipEntry: Record "NPR MM Membership Entry")
    var
        MembershipEntry2: Record "NPR MM Membership Entry";
        SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request";
        MustBeTheLastErr: Label 'You cannot change (regret) membership ledger entry %1, because it is not the last entry posted for the membership. You must first regret all subsequent entries before proceeding with the change.', Comment = '%1 - membership ledger entry number';
        TransMismatchErr: Label 'Subscription request number %1 cannot be posted at this time, because the membership ledger entry %2 to which it is related does not have the correct context. You may be trying to post transactions in the wrong order. Transactions must be posted in chronological order.', Comment = '%1 - subscription request entry number, %2 - membership ledger entry number';
    begin
        MembershipEntry.Get(MembershipEntryEntryNo);
        SubscrPmtReversalRequest.SetRange("Subscr. Request Entry No.", SubscrReversalRequest."Entry No.");
        SubscrPmtReversalRequest.SetRange(Status, SubscrPmtReversalRequest.Status::Captured);
        SubscrPmtReversalRequest.SetLoadFields(Type);
        SubscrPmtReversalRequest.FindLast();
        if ((MembershipEntry.Context = MembershipEntry.Context::REGRET) and
            (SubscrPmtReversalRequest.Type in [SubscrPmtReversalRequest.Type::Refund, SubscrPmtReversalRequest.Type::Chargeback]))
           or
           ((MembershipEntry.Context <> MembershipEntry.Context::REGRET) and
            (SubscrPmtReversalRequest.Type in [SubscrPmtReversalRequest.Type::Payment, SubscrPmtReversalRequest.Type::RefundRefersed, SubscrPmtReversalRequest.Type::ChargebackReversed]))
        then
            Error(TransMismatchErr, SubscrReversalRequest."Entry No.", MembershipEntry."Entry No.");

        MembershipEntry.SetRange("Membership Entry No.", MembershipEntry."Membership Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry2.Context::REGRET);
        MembershipEntry2.CopyFilters(MembershipEntry);
        MembershipEntry2.SetLoadFields("Entry No.");
        if MembershipEntry2.FindLast() then
            if MembershipEntry2."Entry No." > MembershipEntry."Entry No." then
                Error(MustBeTheLastErr, MembershipEntry."Entry No.");
    end;

    local procedure FindPayByLink(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") PayByLinkUrl: Text[2048]
    var
        PayByLinkSubscriptionRequest: Record "NPR MM Subscr. Request";
        PayByLinkSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        PayByLinkSubscriptionRequest.Reset();
        PayByLinkSubscriptionRequest.SetRange("Created from Entry No.", SubscrPaymentRequest."Entry No.");
        PayByLinkSubscriptionRequest.SetRange(Type, PayByLinkSubscriptionRequest.Type::Renew);
        PayByLinkSubscriptionRequest.SetLoadFields("Entry No.");
        if not PayByLinkSubscriptionRequest.FindLast() then
            exit;

        PayByLinkSubscrPaymentRequest.Reset();
        PayByLinkSubscrPaymentRequest.SetRange("Subscr. Request Entry No.", PayByLinkSubscriptionRequest."Entry No.");
        PayByLinkSubscrPaymentRequest.SetRange(Type, PayByLinkSubscrPaymentRequest.Type::PayByLink);
        PayByLinkSubscrPaymentRequest.SetLoadFields("Pay by Link URL");
        if not PayByLinkSubscrPaymentRequest.FindLast() then
            exit;

        PayByLinkUrl := PayByLinkSubscrPaymentRequest."Pay by Link URL";
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