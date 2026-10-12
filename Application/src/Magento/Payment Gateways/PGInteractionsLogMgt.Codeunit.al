codeunit 6151473 "NPR PG Interactions Log Mgt."
{
    Access = Internal;

    internal procedure LogCaptureStart(var Log: Record "NPR PG Interaction Log Entry"; PaymentLineSystemId: Guid)
    begin
        Clear(Log);
        LogStart(Log, PaymentLineSystemId, Log."Interaction Type"::Capture);
    end;

    internal procedure LogRefundStart(var Log: Record "NPR PG Interaction Log Entry"; PaymentLineSystemId: Guid)
    begin
        Clear(Log);
        LogStart(Log, PaymentLineSystemId, Log."Interaction Type"::Refund);
    end;

    internal procedure LogCancelStart(var Log: Record "NPR PG Interaction Log Entry"; PaymentLineSystemId: Guid)
    begin
        Clear(Log);
        LogStart(Log, PaymentLineSystemId, Log."Interaction Type"::Cancel);
    end;

    internal procedure LogPayByLinkStart(var Log: Record "NPR PG Interaction Log Entry"; PaymentLineSystemId: Guid)
    begin
        Clear(Log);
        LogStart(Log, PaymentLineSystemId, Log."Interaction Type"::"Issue Pay by Link");
    end;

    internal procedure LogPayByLinkCancelStart(var Log: Record "NPR PG Interaction Log Entry"; PaymentLineSystemId: Guid)
    begin
        Clear(Log);
        LogStart(Log, PaymentLineSystemId, Log."Interaction Type"::"Cancel Pay by Link");
    end;

    local procedure LogStart(var Log: Record "NPR PG Interaction Log Entry"; PaymentLineSystemId: Guid; OperationType: Option)
    begin
        Log.Init();
        Log."Interaction Type" := OperationType;
        Log."In Progress" := true;
        Log."Payment Line System Id" := PaymentLineSystemId;
        Log.Insert(true);
    end;

    internal procedure MoveOpenCaptureLog(FromPaymentLineSystemId: Guid; ToPaymentLineSystemId: Guid)
    var
        Log: Record "NPR PG Interaction Log Entry";
    begin
        Log.SetRange("Payment Line System Id", FromPaymentLineSystemId);
        Log.SetRange("Interaction Type", Log."Interaction Type"::Capture);
        Log.SetRange("In Progress", true);
        Log.ModifyAll("Payment Line System Id", ToPaymentLineSystemId, true);
    end;

    internal procedure LogOperationFinished(var Log: Record "NPR PG Interaction Log Entry"; Request: Record "NPR PG Payment Request"; Response: Record "NPR PG Payment Response"; Success: Boolean; ErrorText: Text)
    var
        OStr: OutStream;
    begin
        Log."In Progress" := Success and Response."Async Processing";
        Log."Operation Success" := Response."Response Success" and not Response."Async Processing";
        Log."Ran With Error" := (not Success);

        Log."Request Object".CreateOutStream(OStr);
        OStr.WriteText(Request.ToJson());

        Log."Response Object".CreateOutStream(OStr);
        OStr.WriteText(Response.ToJson());

        if (ErrorText <> '') then begin
            Log."Error Message".CreateOutStream(OStr);
            OStr.WriteText(ErrorText);
        end;

        Log.Modify(true);
    end;

    internal procedure CompleteAsyncOperation(var Log: Record "NPR PG Interaction Log Entry"; Success: Boolean; ErrorText: Text)
    var
        OStr: OutStream;
        IStr: InStream;
        ResponseJObject: JsonObject;
        UpdatedResponse: Text;
        StatusText: Text;
        SuccessStatusTok: Label 'Success', Locked = true;
        FailureStatusTok: Label 'Failure', Locked = true;
    begin
        Log."In Progress" := false;
        Log."Operation Success" := Success;
        Log."Ran With Error" := not Success;
        Log.CalcFields("Response Object");
        if Log."Response Object".HasValue() then begin
            Log."Response Object".CreateInStream(IStr);
            if ResponseJObject.ReadFrom(IStr) then begin
                if Success then
                    StatusText := SuccessStatusTok
                else
                    StatusText := FailureStatusTok;
                if ResponseJObject.Contains('operation_status') then
                    ResponseJObject.Replace('operation_status', StatusText);
                ResponseJObject.WriteTo(UpdatedResponse);
                Log."Response Object".CreateOutStream(OStr);
                OStr.WriteText(UpdatedResponse);
            end;
        end;

        if ErrorText <> '' then begin
            Log."Error Message".CreateOutStream(OStr);
            OStr.WriteText(ErrorText);
        end;

        Log.Modify(true);
    end;
}