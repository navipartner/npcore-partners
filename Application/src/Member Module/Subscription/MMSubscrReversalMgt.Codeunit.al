codeunit 6248187 "NPR MM Subscr. Reversal Mgt."
{
    Access = Internal;

    internal procedure RequestRefundWithConfirmation(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        ConfirmManagement: Codeunit "Confirm Management";
        CreateRefundConfirmationLbl: Label 'Are you sure you want to request a refund for subscription payment No. %1?', Comment = '%1 - subscription payment request entry no.';
    begin
        CheckIsReversible(SubscrPaymentRequest);
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(CreateRefundConfirmationLbl, SubscrPaymentRequest."Entry No."), true) then
            exit;

        SubscrPaymentRequest.TestField("Subscr. Request Entry No.");
        SubscriptionRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");
        RequestRefund(SubscriptionRequest, SubscrPaymentRequest, false, SubscrPmtReversalRequest);
    end;

    internal procedure RequestRefund(var SubscriptionRequest: Record "NPR MM Subscr. Request"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; IgnoreStatus: Boolean; var SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request")
    var
        SubscrReversalRequest: Record "NPR MM Subscr. Request";
        MustBeCapturedErr: Label 'In order to request a refund, the status of subscription payment request No. %1 must be "Captured".', Comment = '%1 - subscription payment request entry no.';
    begin
        CheckIsReversible(SubscrPaymentRequest);
        if not IgnoreStatus then
            if not (SubscrPaymentRequest.Status in [SubscrPaymentRequest.Status::Authorized, SubscrPaymentRequest.Status::Captured]) then
                Error(MustBeCapturedErr, SubscrPaymentRequest."Entry No.");

        InitReversalRequest(SubscriptionRequest, SubscrPaymentRequest, Enum::"NPR MM Payment Request Type"::Refund, SubscrReversalRequest, SubscrPmtReversalRequest);
        InsertReversalRequest(SubscriptionRequest, SubscrPaymentRequest, SubscrReversalRequest, SubscrPmtReversalRequest);
    end;

    internal procedure RequestPartialRefund(Subscription: Record "NPR MM Subscription"; Membership: Record "NPR MM Membership"; RefundWithItemNo: Code[20]; RefundAtDate: Date; RefundPrice: Decimal)
    var
        SubscriptionRequestFound: Boolean;
        SubscriptionRequest, SubscrReversalRequest : Record "NPR MM Subscr. Request";
        OriginalSubscrPmtRequest, SubscrReversalPmtRequest : Record "NPR MM Subscr. Payment Request";
        NewValidFromDate: Date;
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipEntry: Record "NPR MM Membership Entry";
        DescrLbl: Label 'Partial refund from date %1', Comment = '%1 = date refund is effective from';
        RefundPricePositiveErr: Label 'The provided refund price "%1" is positive, but should be negative to be refunded.', Comment = '%1 = refund price';
        CantFindAnEntryToCancelErr: Label 'The provided membership (%1) does not have an entry to cancel';
    begin
        if (RefundPrice > 0) then
            Error(RefundPricePositiveErr, RefundPrice);

#if (BC17 or BC18 or BC19 or B20 or BC21)
        SubscriptionRequest.LockTable();
#else
        SubscriptionRequest.ReadIsolation := IsolationLevel::UpdLock;
#endif
        SubscriptionRequest.SetCurrentKey("Subscription Entry No.");
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, Enum::"NPR MM Subscr. Request Type"::Renew);
        SubscriptionRequest.SetRange(Reversed, false);
        SubscriptionRequestFound := SubscriptionRequest.FindLast();

        if (SubscriptionRequestFound) then
            NewValidFromDate := SubscriptionRequest."New Valid From Date"
        else
            NewValidFromDate := Subscription."Valid From Date";

        PaymentMethodMgt.TryGetMemberPaymentMethod(Subscription, false, MemberPaymentMethod);
        MemberPaymentMethod.TestField(PSP);
        MemberPaymentMethod.TestField("Payment Token");

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.SetLoadFields("Entry No.");
        if (not MembershipEntry.FindLast()) then
            Error(CantFindAnEntryToCancelErr, Membership."External Membership No.");

        SubscrReversalRequest.Init();
        SubscrReversalRequest."Entry No." := 0;
        SubscrReversalRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscrReversalRequest."Membership Code" := Membership."Membership Code";
        SubscrReversalRequest.Type := SubscrReversalRequest.Type::"Partial Regret";
        SubscrReversalRequest.Status := SubscrReversalRequest.Status::New;
        SubscrReversalRequest."Processing Status" := SubscrReversalRequest."Processing Status"::Pending;
        SubscrReversalRequest.Description := CopyStr(StrSubstNo(DescrLbl, RefundAtDate), 1, MaxStrLen(SubscrReversalRequest.Description));
        SubscrReversalRequest."New Valid From Date" := NewValidFromDate;
        SubscrReversalRequest."New Valid Until Date" := RefundAtDate;
        SubscrReversalRequest."Terminate At" := GetTerminationRequestTerminateAt(Subscription);
        SubscrReversalRequest.Amount := RefundPrice;
        SubscrReversalRequest."Currency Code" := SubscriptionRequest."Currency Code";
        SubscrReversalRequest."Item No." := RefundWithItemNo;
        SubscrReversalRequest."Membership Entry To Cancel" := MembershipEntry."Entry No.";
        SubscrReversalRequest.Insert(true);

        SubscrReversalPmtRequest.Init();
        SubscrReversalPmtRequest."Entry No." := 0;
        SubscrReversalPmtRequest.Type := Enum::"NPR MM Payment Request Type"::Refund;
        SubscrReversalPmtRequest.Status := SubscrReversalPmtRequest.Status::New;
        SubscrReversalPmtRequest."Subscr. Request Entry No." := SubscrReversalRequest."Entry No.";
        SubscrReversalPmtRequest."Payment Method Entry No." := MemberPaymentMethod."Entry No.";
        SubscrReversalPmtRequest.PSP := MemberPaymentMethod.PSP;
        SubscrReversalPmtRequest."Payment Token" := MemberPaymentMethod."Payment Token";
        SubscrReversalPmtRequest.Amount := RefundPrice;
        SubscrReversalPmtRequest."Currency Code" := SubscrReversalRequest."Currency Code";
        SubscrReversalPmtRequest.Description := CopyStr(SubscrReversalRequest.Description, 1, MaxStrLen(SubscrReversalPmtRequest.Description));
        SubscrReversalPmtRequest.Insert(true);

        if (SubscriptionRequestFound) then begin
            SubscriptionRequest.Reversed := true;
            SubscriptionRequest."Reversed by Entry No." := SubscrReversalRequest."Entry No.";
            SubscriptionRequest.Modify(true);

#if (BC17 or BC18 or BC19 or BC20 or BC21)
            OriginalSubscrPmtRequest.LockTable();
#else
            OriginalSubscrPmtRequest.ReadIsolation := IsolationLevel::UpdLock;
#endif
            OriginalSubscrPmtRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
            OriginalSubscrPmtRequest.SetRange(Reversed, false);
            OriginalSubscrPmtRequest.SetRange(Status, OriginalSubscrPmtRequest.Status::Captured);
            if (OriginalSubscrPmtRequest.FindLast()) then begin
                OriginalSubscrPmtRequest.Reversed := true;
                OriginalSubscrPmtRequest."Reversed by Entry No." := SubscrReversalPmtRequest."Entry No.";
                OriginalSubscrPmtRequest.Modify(true);
            end;
        end
    end;

    local procedure GetTerminationRequestTerminateAt(Subscription: Record "NPR MM Subscription"): Date
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionRequest.SetLoadFields("Terminate At");
        SubscriptionRequest.SetCurrentKey("Subscription Entry No.", Type);
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Terminate);
        if SubscriptionRequest.FindLast() then
            exit(SubscriptionRequest."Terminate At");
    end;

    internal procedure InitReversalRequest(SubscriptionRequest: Record "NPR MM Subscr. Request"; SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; ReversalType: Enum "NPR MM Payment Request Type"; var SubscrReversalRequest: Record "NPR MM Subscr. Request"; var SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request")
    var
        DescrLbl: Label 'Reversed %1', Comment = '%1 - original subscription or payment request description';
    begin
        SubscrReversalRequest.Init();
        SubscrReversalRequest."Entry No." := 0;
        SubscrReversalRequest."Subscription Entry No." := SubscriptionRequest."Subscription Entry No.";
        SubscrReversalRequest."Membership Code" := SubscriptionRequest."Membership Code";
        SubscrReversalRequest.Type := SubscrReversalRequest.Type::Regret;
        SubscrReversalRequest.Status := SubscrReversalRequest.Status::New;
        SubscrReversalRequest."Processing Status" := SubscrReversalRequest."Processing Status"::Pending;
        SubscrReversalRequest.Description := CopyStr(StrSubstNo(DescrLbl, SubscriptionRequest.Description), 1, MaxStrLen(SubscrReversalRequest.Description));
        SubscrReversalRequest."New Valid From Date" := SubscriptionRequest."New Valid From Date";
        SubscrReversalRequest."New Valid Until Date" := SubscriptionRequest."New Valid Until Date";
        SubscrReversalRequest.Amount := -SubscriptionRequest.Amount;
        SubscrReversalRequest."Currency Code" := SubscriptionRequest."Currency Code";
        SubscrReversalRequest."Item No." := SubscriptionRequest."Item No.";
        SubscrReversalRequest."Created from Entry No." := SubscrPaymentRequest."Entry No.";

        SubscrPmtReversalRequest.Init();
        SubscrPmtReversalRequest."Entry No." := 0;
        SubscrPmtReversalRequest."Subscr. Request Entry No." := 0;
        SubscrPmtReversalRequest.Type := ReversalType;
        SubscrPmtReversalRequest.Status := SubscrPmtReversalRequest.Status::New;
        SubscrPmtReversalRequest.PSP := SubscrPaymentRequest.PSP;
        SubscrPmtReversalRequest."Payment Token" := SubscrPaymentRequest."Payment Token";
        SubscrPmtReversalRequest.Amount := -SubscrPaymentRequest.Amount;
        SubscrPmtReversalRequest."Currency Code" := SubscrPaymentRequest."Currency Code";
        SubscrPmtReversalRequest.Description := CopyStr(StrSubstNo(DescrLbl, SubscrPaymentRequest.Description), 1, MaxStrLen(SubscrPmtReversalRequest.Description));
    end;

    internal procedure InsertReversalRequest(var SubscriptionRequest: Record "NPR MM Subscr. Request"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var SubscrReversalRequest: Record "NPR MM Subscr. Request"; var SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request")
    begin
        SubscrReversalRequest.Insert(true);

        SubscriptionRequest.Reversed := true;
        SubscriptionRequest."Reversed by Entry No." := SubscrReversalRequest."Entry No.";
        SubscriptionRequest.Modify(true);

        SubscrPmtReversalRequest."Subscr. Request Entry No." := SubscrReversalRequest."Entry No.";
        SubscrPmtReversalRequest.Insert(true);

        SubscrPaymentRequest.Reversed := true;
        SubscrPaymentRequest."Reversed by Entry No." := SubscrPmtReversalRequest."Entry No.";
        SubscrPaymentRequest.Modify(true);
    end;

    local procedure CheckIsReversible(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    begin
        if not (SubscrPaymentRequest.Type in [SubscrPaymentRequest.Type::Payment, SubscrPaymentRequest.Type::PayByLink, SubscrPaymentRequest.Type::ChargebackReversed]) then
            SubscrPaymentRequest.FieldError(Type);
        SubscrPaymentRequest.TestField(Reversed, false);
    end;

    internal procedure CancelReversal(SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPaymentRequest2: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrPmtReversalRequest.TestField(Status, SubscrPmtReversalRequest.Status::Cancelled);

        SubscrPaymentRequest.SetRange("Reversed by Entry No.", SubscrPmtReversalRequest."Entry No.");
        SubscrPaymentRequest.SetFilter("Entry No.", '<>%1', SubscrPmtReversalRequest."Entry No.");
        if SubscrPaymentRequest.Find('-') then
            repeat
                SubscrPaymentRequest2 := SubscrPaymentRequest;
                SubscrPaymentRequest2.Reversed := false;
                SubscrPaymentRequest2."Reversed by Entry No." := 0;
                SubscrPaymentRequest2.Modify(true);
            until SubscrPaymentRequest.Next() = 0;
    end;

    internal procedure CancelReversal(SubscrReversalRequest: Record "NPR MM Subscr. Request")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionRequest2: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request";
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        SubscrReversalRequest.TestField(Status, SubscrReversalRequest.Status::Cancelled);

        SubscriptionRequest.SetRange("Reversed by Entry No.", SubscrReversalRequest."Entry No.");
        SubscriptionRequest.SetFilter("Entry No.", '<>%1', SubscrReversalRequest."Entry No.");
        if SubscriptionRequest.Find('-') then
            repeat
                SubscriptionRequest2 := SubscriptionRequest;
                SubscriptionRequest2.Reversed := false;
                SubscriptionRequest2."Reversed by Entry No." := 0;
                SubscriptionRequest2.Modify(true);
            until SubscriptionRequest.Next() = 0;

        SubscrPmtReversalRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        SubscrPmtReversalRequest.SetRange("Subscr. Request Entry No.", SubscrReversalRequest."Entry No.");
        SubscrPmtReversalRequest.SetFilter(Status, '<>%1&<>%2', SubscrPmtReversalRequest.Status::Requested, SubscrPmtReversalRequest.Status::Captured);
        if SubscrPmtReversalRequest.Find('-') then
            repeat
                SubscrPaymentRequest.SetRange("Reversed by Entry No.", SubscrPmtReversalRequest."Entry No.");
                SubscrPaymentRequest.SetFilter("Entry No.", '<>%1', SubscrPmtReversalRequest."Entry No.");
                if not SubscrPaymentRequest.IsEmpty() then
                    SubsPayRequestUtils.SetSubscrPaymentRequestStatus(SubscrPmtReversalRequest, Enum::"NPR MM Payment Request Status"::Cancelled, false);
            until SubscrPmtReversalRequest.Next() = 0;
    end;
}