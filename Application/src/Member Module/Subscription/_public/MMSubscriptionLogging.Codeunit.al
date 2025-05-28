codeunit 6248464 "NPR MM Subscription Logging"
{
    procedure InsertPaymentLogEntry(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; RequestText: Text; SubscriptionsPaymentGatewayCode: Code[10]; Manual: Boolean; var SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry")
    var
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
    begin
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest, RequestText, SubscriptionsPaymentGatewayCode, Manual, SubsPayReqLogEntry);
    end;

    procedure UpdatePaymentLogEntry(var SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry"; RequestText: Text; ResponseText: Text; ProcessingStatus: Enum "NPR MM SubsPayReqLogProcStatus"; ErrorMessage: Text; SubscriptionsPaymentGatewayCode: Code[10])
    var
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
    begin
        SubsPayReqLogUtils.UpdateEntry(SubsPayReqLogEntry, RequestText, ResponseText, ProcessingStatus, ErrorMessage, SubscriptionsPaymentGatewayCode, 0);
    end;
}