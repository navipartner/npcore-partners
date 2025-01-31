codeunit 6248237 "NPR Adyen PayByLink Cancel JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        MMSubscrPaymentRequest.SetRange(Type, MMSubscrPaymentRequest.Type::PayByLink);
        MMSubscrPaymentRequest.SetFilter(Status, '%1|%2', MMSubscrPaymentRequest.Status::New, MMSubscrPaymentRequest.Status::Requested);
        MMSubscrPaymentRequest.SetFilter("Pay By Link Expires At", '<%1', CurrentDateTime);
        if MMSubscrPaymentRequest.FindSet(true) then
            repeat
                SetCancelRequest(MMSubscrPaymentRequest);
            until MMSubscrPaymentRequest.Next() = 0;
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