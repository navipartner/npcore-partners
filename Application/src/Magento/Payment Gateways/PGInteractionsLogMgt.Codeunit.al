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

    internal procedure LogOperationFinished(var Log: Record "NPR PG Interaction Log Entry"; Request: Record "NPR PG Payment Request"; Response: Record "NPR PG Payment Response"; Success: Boolean; ErrorText: Text)
    var
        OStr: OutStream;
    begin
        Log."In Progress" := false;
        Log."Operation Success" := Response."Response Success";
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
}