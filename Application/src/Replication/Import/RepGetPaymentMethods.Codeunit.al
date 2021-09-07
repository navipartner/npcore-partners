codeunit 6014689 "NPR Rep. Get Payment Methods" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetPaymentMethods_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetPaymentTerms(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetPaymentTerms(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        // each entity can have it's own 'Get' logic, but mostly should be the same, so code stays in Replication API codeunit
        URI := ReplicationAPI.CreateURI(ReplicationSetup, ReplicationEndPoint, NextLinkURI);
        ReplicationAPI.GetBCAPIResponse(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ReplicationEndPoint: Record "NPR Replication Endpoint"): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
        JTokenEntity: JsonToken;
        i: integer;
    begin
        // each entity can have it's own 'Process' logic, but mostly should be the same, so part of code stays in Replication API codeunit
        IF Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) THEN
            exit;

        IF NOT ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit;

        for i := 0 to JArrayValues.Count - 1 do begin
            JArrayValues.Get(i, JTokenEntity);
            HandleArrayElementEntity(JTokenEntity, ReplicationEndPoint);
        end;

        ReplicationAPI.UpdateReplicationCounter(JTokenEntity, ReplicationEndPoint);
    end;

    local procedure HandleArrayElementEntity(JToken: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint")
    var
        PaymentMethod: Record "Payment Method";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        PaymentMethodCode: Code[10];
        PaymentMethodId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        PaymentMethodCode := CopyStr(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(PaymentMethodCode));
        PaymentMethodId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF PaymentMethodId <> '' then
            IF PaymentMethod.GetBySystemId(PaymentMethodId) then begin
                RecFoundBySystemId := true;
                If PaymentMethod."Code" <> PaymentMethodCode then // rename!
                    if NOT PaymentMethod.Rename(PaymentMethodCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT PaymentMethod.Get(PaymentMethodCode) then
                InsertNewRec(PaymentMethod, PaymentMethodCode, PaymentMethodId);

        IF CheckFieldsChanged(PaymentMethod, JToken) then
            PaymentMethod.Modify(true);
    end;

    local procedure CheckFieldsChanged(var PaymentMethod: Record "Payment Method"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(PaymentMethod, PaymentMethod.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentMethod, PaymentMethod.FieldNo("Bal. Account No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.balAccountNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentMethod, PaymentMethod.FieldNo("Bal. Account Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.balAccountNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentMethod, PaymentMethod.FieldNo("Direct Debit"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.directDebit'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentMethod, PaymentMethod.FieldNo("Direct Debit Pmt. Terms Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.directDebitPmtTermsCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentMethod, PaymentMethod.FieldNo("Pmt. Export Line Definition"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.pmtExportLineDefinition'), false) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var PaymentMethod: Record "Payment Method"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(PaymentMethod, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(PaymentMethod);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var PaymentMethod: Record "Payment Method"; PaymentMethodCode: Code[10]; PaymentMethodid: text)
    begin
        PaymentMethod.Init();
        PaymentMethod.Code := PaymentMethodCode;
        IF PaymentMethodId <> '' THEN begin
            IF Evaluate(PaymentMethod.SystemId, PaymentMethodId) Then
                PaymentMethod.Insert(false, true)
            Else
                PaymentMethod.Insert(false);
        end else
            PaymentMethod.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    procedure CheckResponseContainsData(Content: Codeunit "Temp Blob"): Boolean;
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
    begin
        IF Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) THEN
            exit(false);

        IF NOT ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit(false);

        Exit(JArrayValues.Count > 0);
    end;

}