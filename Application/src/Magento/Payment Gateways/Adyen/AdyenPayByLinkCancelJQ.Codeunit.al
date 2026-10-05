codeunit 6248237 "NPR Adyen PayByLink Cancel JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        CursorText: Text;
        Cursor: BigInteger;
        ProcessedCount: Integer;
        StartedAt: DateTime;
        CursorKeyLbl: Label 'MM-Expired-PayByLink-Cursor', Locked = true;
    begin
        StartedAt := CurrentDateTime();
        if IsolatedStorage.Get(CursorKeyLbl, DataScope::Company, CursorText) then
            if not Evaluate(Cursor, CursorText) then
                Clear(Cursor);
        MMSubscrPaymentRequest.SetCurrentKey("Entry No.");
        MMSubscrPaymentRequest.SetFilter("Entry No.", '>%1', Cursor);
        MMSubscrPaymentRequest.SetRange(Type, MMSubscrPaymentRequest.Type::PayByLink);
        MMSubscrPaymentRequest.SetFilter(Status, '%1|%2', MMSubscrPaymentRequest.Status::New, MMSubscrPaymentRequest.Status::Requested);
        MMSubscrPaymentRequest.SetFilter("Pay By Link Expires At", '<>%1&<%2', 0DT, CurrentDateTime());
        if MMSubscrPaymentRequest.FindSet() then
            repeat
                IsolatedStorage.Set(CursorKeyLbl, Format(MMSubscrPaymentRequest."Entry No."), DataScope::Company);
                CancelExpiredLink(MMSubscrPaymentRequest);
                ProcessedCount += 1;
                if (ProcessedCount >= 100) or (CurrentDateTime() - StartedAt >= 120 * 1000) then
                    exit;
            until MMSubscrPaymentRequest.Next() = 0;
        IsolatedStorage.Set(CursorKeyLbl, '0', DataScope::Company);
    end;

    internal procedure CancelExpiredLink(var PaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        ResolvePayByLink: Codeunit "NPR MM Subscr. Resolve PBL";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
    begin
        if (PaymentRequest."Pay By Link Expires At" = 0DT) or (PaymentRequest."Pay By Link Expires At" >= CurrentDateTime()) then
            exit;
        if PaymentRequest.PSP <> PaymentRequest.PSP::Adyen then begin
            SetCancelRequest(PaymentRequest);
            exit;
        end;
        Commit();
        ResolvePayByLink.SetOnlyIfExpired();
        if not ResolvePayByLink.Run(PaymentRequest) then
            RenewalMgt.LogPayByLinkError(PaymentRequest, GetLastErrorText());
    end;

    local procedure SetCancelRequest(var MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
    begin
        MMSubscrPaymentRequest.Validate(Status, MMSubscrPaymentRequest.Status::Cancelled);
        MMSubscrPaymentRequest.Modify(true);

        SubsPayReqLogUtils.LogEntry(MMSubscrPaymentRequest,
                                    '',
                                    '',
                                    false,
                                    SubsPayReqLogEntry);
    end;

}
