#if not BC17
codeunit 6248244 "NPR Spfy App Request Parser"
{
    Access = Internal;
    TableNo = "NPR Spfy App Request";

    var
        _RequestPayloadTxt: Text;
        _RequestType: Enum "NPR Spfy App Request Type";

    trigger OnRun()
    var
        RequestTypeNotSetErr: Label 'Request type not set.';
    begin
        case _RequestType of
            _RequestType::UNDEFINED:
                Error(RequestTypeNotSetErr);
            _RequestType::UpsertShopifyStore:
                UpsertShopifyStore(Rec);
        end;
    end;

    local procedure UpsertShopifyStore(var SpfyAppRequest: Record "NPR Spfy App Request")
    var
        Success: Boolean;
    begin
        ClearLastError();
        SpfyAppRequest.Init();
        SpfyAppRequest."Entry No." := 0;
        SpfyAppRequest.Type := _RequestType;
        Success := TryReadRequestData(SpfyAppRequest);
        if not Success then begin
            SpfyAppRequest.Status := SpfyAppRequest.Status::Error;
            SpfyAppRequest.SetErrorMessage(GetLastErrorText());
            SpfyAppRequest."Processed at" := 0DT;
        end;
        SpfyAppRequest.Insert(true);
        Commit();

        if not Success then
            Error(SpfyAppRequest.GetErrorMessage());
    end;

    [TryFunction]
    internal procedure TryReadRequestData(var SpfyAppRequest: Record "NPR Spfy App Request")
    var
        RequestPayload: JsonToken;
    begin
        RequestPayload.ReadFrom(_RequestPayloadTxt);
        SpfyAppRequest.SetPayload(RequestPayload);
    end;

    internal procedure SetRequest(Type: Enum "NPR Spfy App Request Type"; PayloadTxt: Text)
    begin
        _RequestType := Type;
        _RequestPayloadTxt := PayloadTxt;
    end;
}
#endif