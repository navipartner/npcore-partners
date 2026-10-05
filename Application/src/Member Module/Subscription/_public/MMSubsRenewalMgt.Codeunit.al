codeunit 6151293 "NPR MM Subs. Renewal Mgt."
{
    procedure ResolveOutstandingPayByLink(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") SkipRenewal: Boolean
    begin
        CheckProviderSupported(SubscrPaymentRequest);
        SkipRenewal := true;
        OnResolveOutstandingPayByLink(SubscrPaymentRequest, SkipRenewal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnResolveOutstandingPayByLink(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var SkipRenewal: Boolean)
    begin
    end;

    procedure TryIsOutstandingPayByLinkPaid(SubscriptionEntryNo: Integer; var IsPaid: Boolean) CheckSucceeded: Boolean
    var
        ErrorMessage: Text;
    begin
        exit(TryIsOutstandingPayByLinkPaid(SubscriptionEntryNo, IsPaid, ErrorMessage));
    end;

    internal procedure TryIsOutstandingPayByLinkPaid(SubscriptionEntryNo: Integer; var IsPaid: Boolean; var ErrorMessage: Text) CheckSucceeded: Boolean
    var
        OutstandingPayByLink: Record "NPR MM Subscr. Payment Request";
        TempPayment: Record "NPR MM Subscr. Payment Request" temporary;
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        UnhandledPSPErr: Label 'The payment provider could not determine the outstanding payment link status.';
    begin
        IsPaid := false;
        Clear(ErrorMessage);
        SubscrRequestUtils.CollectPayByLinksToResolve(SubscriptionEntryNo, TempPayment);
        if TempPayment.FindSet() then
            repeat
                OutstandingPayByLink.Get(TempPayment."Entry No.");
                CheckProviderSupported(OutstandingPayByLink);
                ErrorMessage := UnhandledPSPErr;
                CheckSucceeded := false;
                OnCheckOutstandingPayByLinkPaid(OutstandingPayByLink, IsPaid, CheckSucceeded, ErrorMessage);
                if not CheckSucceeded then begin
                    LogPayByLinkError(OutstandingPayByLink, ErrorMessage);
                    exit(false);
                end;
                if IsPaid then begin
                    Clear(ErrorMessage);
                    exit(true);
                end;
            until TempPayment.Next() = 0;
        Clear(ErrorMessage);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckOutstandingPayByLinkPaid(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var IsPaid: Boolean; var CheckSucceeded: Boolean; var ErrorMessage: Text)
    begin
    end;

    internal procedure LogPayByLinkError(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; ErrorMessage: Text)
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
    begin
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest, '', '', false, SubsPayReqLogEntry);
        SubsPayReqLogUtils.UpdateEntry(SubsPayReqLogEntry, '', '', SubsPayReqLogEntry."Processing Status"::Error, ErrorMessage, '', 0);
    end;

    procedure IsCustomerActionableDecline(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") IsActionable: Boolean
    var
        IsTechnicalError: Boolean;
        Supported: Boolean;
    begin
        Supported := IsProviderSupported(SubscrPaymentRequest);
        if not Supported then
            exit(false);
        OnCheckPaymentTechnicalError(SubscrPaymentRequest, IsTechnicalError);
        exit(not IsTechnicalError);
    end;

    local procedure CheckProviderSupported(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        UnsupportedProviderErr: Label 'Payment provider %1 does not support checking outstanding payment links. Configure the provider integration before retrying.', Comment = '%1 = payment provider';
    begin
        if not IsProviderSupported(SubscrPaymentRequest) then
            Error(UnsupportedProviderErr, SubscrPaymentRequest.PSP);
    end;

    local procedure IsProviderSupported(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") Supported: Boolean
    begin
        Supported := SubscrPaymentRequest.PSP = SubscrPaymentRequest.PSP::Adyen;
        OnCheckRenewalProviderSupported(SubscrPaymentRequest.PSP, Supported);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckRenewalProviderSupported(PSP: Enum "NPR MM Subscription PSP"; var Supported: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPaymentTechnicalError(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var IsTechnicalError: Boolean)
    begin
    end;
}
