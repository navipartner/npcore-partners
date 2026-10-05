codeunit 6150959 "NPR MM Subscr. Resolve PBL"
{
    Access = Internal;
    TableNo = "NPR MM Subscr. Payment Request";

    var
        _SkipRenewal: Boolean;
        _AfterTokenSuccess: Boolean;
        _OnlyIfExpired: Boolean;

    trigger OnRun()
    var
        SubsRenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        SubscrPmtAdyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
    begin
        _SkipRenewal := true;
        if _OnlyIfExpired then begin
            _SkipRenewal := SubscrPmtAdyen.ResolveOutstandingPayByLink(Rec, false, true);
            exit;
        end;
        if _AfterTokenSuccess then begin
            _SkipRenewal := SubscrPmtAdyen.ResolveOutstandingPayByLink(Rec, true);
            exit;
        end;
        _SkipRenewal := SubsRenewalMgt.ResolveOutstandingPayByLink(Rec);
    end;

    internal procedure SetAfterTokenSuccess(AfterTokenSuccess: Boolean)
    begin
        _AfterTokenSuccess := AfterTokenSuccess;
    end;

    internal procedure SetOnlyIfExpired()
    begin
        _OnlyIfExpired := true;
    end;

    internal procedure SkipRenewal(): Boolean
    begin
        exit(_SkipRenewal);
    end;
}
