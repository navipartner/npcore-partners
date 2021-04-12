codeunit 6151535 "NPR Package Assert Error"
{
    TableNo = "NPR AF Arguments - Notific.Hub";

    trigger OnRun()
    var
        JObject: JsonObject;
        MethodNotFoundErr: Label 'Internal error. Method name not provide for "Nc Try Catch". Please, contact your system administrator.';
        Method: Text;
    begin
        if not ReadJsonArgumentsWithMethodName(Rec, Method, JObject) then
            Error(MethodNotFoundErr);
        case Method of
            'C80OnAfterPostSalesDocPakkelabelsDKMgnt':
                begin
                    C80OnAfterPostSalesDocPakkelabelsDKMgnt(Rec, JObject);
                end;
        end;
    end;

    local procedure ReadJsonArgumentsWithMethodName(var Rec: Record "NPR AF Arguments - Notific.Hub"; var Method: Text; var JObject: JsonObject): Boolean
    var
        InStr: InStream;
        Args: Text;
    begin
        Rec."Request Data".CreateInStream(InStr);
        InStr.ReadText(Args);
        if not JObject.ReadFrom(Args) then
            exit(false);
        GetJValueFromArg(JObject, 'Method', Method);
        exit(Method <> '');
    end;

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Text)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsText();
        end;
    end;

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Code[20])
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsCode();
        end;
    end;

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Boolean)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsBoolean();
        end;
    end;

    local procedure GetJValueFromArg(JObject: JsonObject; ParameterName: Text; var ParameterValue: Integer)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if JObject.Get(ParameterName, JToken) then begin
            JValue := JToken.AsValue();
            if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                ParameterValue := JValue.AsInteger();
        end;
    end;

    local procedure C80OnAfterPostSalesDocPakkelabelsDKMgnt(var Rec: Record "NPR AF Arguments - Notific.Hub"; var JObject: JsonObject)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        DummySalesHeader: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        PackageLabelsDKMgt: Codeunit "NPR Pakkelabels.dk Mgnt";
        RecRef: RecordRef;
        SalesShptHdrNo: Code[20];
        IsShipment: Boolean;
        DocTypeAsInteger: Integer;
        ResponseMessage: Text;
    begin
        ReadArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(JObject, IsShipment, DocTypeAsInteger, SalesShptHdrNo);

        if IsShipment then begin
            SalesSetup.get();
            if (DocTypeAsInteger = DummySalesHeader."Document Type"::Order.AsInteger()) or ((DocTypeAsInteger = DummySalesHeader."Document Type"::Invoice.AsInteger()) and SalesSetup."Shipment on Invoice") then
                if SalesShipmentHeader.get(SalesShptHdrNo) then begin
                    RecRef.GetTable(SalesShipmentHeader);
                    PackageLabelsDKMgt.AddEntry(RecRef, false, true, ResponseMessage);
                end;
        end;

        WriteArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(Rec, ResponseMessage);

        Commit();
        Error('');
    end;

    local procedure ReadArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(JObject: JsonObject; var IsShipment: Boolean; var DocType: Integer; var SalesShipmentNo: Code[20])
    begin
        GetJValueFromArg(JObject, 'IsShipment', IsShipment);
        GetJValueFromArg(JObject, 'DocType', DocType);
        GetJValueFromArg(JObject, 'SalesShipmentNo', SalesShipmentNo);
    end;

    local procedure WriteArgsForShipmentDocumentAddEntryDocPakkelabelsDKMgnt(var Rec: Record "NPR AF Arguments - Notific.Hub"; ResponseMessage: Text)
    var
        JObject: JsonObject;
        OutStr: OutStream;
        Args: Text;
    begin
        Clear(Rec);
        JObject.Add('ResponseMesage', ResponseMessage);
        JObject.Add('AssertError', true);
        JObject.WriteTo(Args);

        Rec."Request Data".CreateOutStream(OutStr);
        OutStr.WriteText(Args);
    end;
}