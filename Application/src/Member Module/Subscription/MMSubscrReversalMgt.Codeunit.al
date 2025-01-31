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
        SubscrReversalRequest."Created from Entry No." := SubscriptionRequest."Entry No.";

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