codeunit 6185097 "NPR MM Subs Pay Req Log Utils"
{
    Access = Internal;

    internal procedure OpenLogEntries(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
    begin
        SubsPayReqLogEntry.SetRange("Payment Request Entry No.", SubscrPaymentRequest."Entry No.");
        Page.Run(0, SubsPayReqLogEntry);
    end;

    internal procedure LogEntry(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
                                RequestText: Text;
                                SubscriptionsPaymentGatewayCode: Code[10];
                                Manual: Boolean;
                                var SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry")
    begin
        SubsPayReqLogEntry.Init();
        SubsPayReqLogEntry."Payment Request Entry No." := SubscrPaymentRequest."Entry No.";
        SubsPayReqLogEntry."Payment Request Id" := SubscrPaymentRequest.SystemId;
        SubsPayReqLogEntry.Status := SubscrPaymentRequest.Status;
        SubsPayReqLogEntry."Subs. Payment Gateway Code" := SubscriptionsPaymentGatewayCode;
        SubsPayReqLogEntry."Processing Status" := SubsPayReqLogEntry."Processing Status"::Success;
        SubsPayReqLogEntry.Manual := Manual;
        SubsPayReqLogEntry.SetRequest(RequestText);
        SubsPayReqLogEntry.Insert(true);
    end;

    internal procedure UpdateEntry(var SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry"; RequestText: Text; ResponseText: Text; ProcessingStatus: Enum "NPR MM SubsPayReqLogProcStatus"; ErrorMessage: Text; SubscriptionsPaymentGatewayCode: Code[10])
    var
        IsModified: Boolean;
    begin
        if SubsPayReqLogEntry."Processing Status" <> ProcessingStatus then begin
            SubsPayReqLogEntry."Processing Status" := ProcessingStatus;
            IsModified := true;
        end;

        SubsPayReqLogEntry.CalcFields(Request, Response);
        If SubsPayReqLogEntry.GetRequest() <> RequestText then begin
            SubsPayReqLogEntry.SetRequest(RequestText);
            IsModified := true;
        end;

        if SubsPayReqLogEntry.GetResponse() <> ResponseText then begin
            SubsPayReqLogEntry.SetResponse(ResponseText);
            IsModified := true;
        end;

        if SubsPayReqLogEntry."Error Message" <> CopyStr(ErrorMessage, 1, MaxStrLen(SubsPayReqLogEntry."Error Message")) then begin
            SubsPayReqLogEntry."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(SubsPayReqLogEntry."Error Message"));
            IsModified := true;
        end;

        if SubsPayReqLogEntry."Subs. Payment Gateway Code" <> SubscriptionsPaymentGatewayCode then begin
            SubsPayReqLogEntry."Subs. Payment Gateway Code" := SubscriptionsPaymentGatewayCode;
            IsModified := true;
        end;

        if IsModified then
            SubsPayReqLogEntry.Modify(true);
    end;
}