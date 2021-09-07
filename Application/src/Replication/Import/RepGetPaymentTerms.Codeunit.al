codeunit 6014690 "NPR Rep. Get Payment Terms" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetPaymentTerms_%1', Comment = '%1=Current Date and Time';

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
        PaymentTerms: Record "Payment Terms";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        PaymentTermsCode: Code[10];
        PaymentTermsId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        PaymentTermsCode := CopyStr(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(PaymentTermsCode));
        PaymentTermsId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF PaymentTermsId <> '' then
            IF PaymentTerms.GetBySystemId(PaymentTermsId) then begin
                RecFoundBySystemId := true;
                If PaymentTerms."Code" <> PaymentTermsCode then // rename!
                    if NOT PaymentTerms.Rename(PaymentTermsCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT PaymentTerms.Get(PaymentTermsCode) then
                InsertNewRec(PaymentTerms, PaymentTermsCode, PaymentTermsId);

        IF CheckFieldsChanged(PaymentTerms, JToken) then
            PaymentTerms.Modify(true);
    end;

    local procedure CheckFieldsChanged(var PaymentTerms: Record "Payment Terms"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(PaymentTerms, PaymentTerms.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentTerms, PaymentTerms.FieldNo("Discount %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discount'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentTerms, PaymentTerms.FieldNo("Calc. Pmt. Disc. on Cr. Memos"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.calcPmtDiscOnCrMemos'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentTerms, PaymentTerms.FieldNo("Discount Date Calculation"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discountDateCalculation'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PaymentTerms, PaymentTerms.FieldNo("Due Date Calculation"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.dueDateCalculation'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var PaymentTerms: Record "Payment Terms"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(PaymentTerms, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(PaymentTerms);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var PaymentTerms: Record "Payment Terms"; PaymentTermsCode: Code[10]; PaymentTermsId: text)
    begin
        PaymentTerms.Init();
        PaymentTerms.Code := PaymentTermsCode;
        IF PaymentTermsId <> '' THEN begin
            IF Evaluate(PaymentTerms.SystemId, PaymentTermsId) Then
                PaymentTerms.Insert(false, true)
            Else
                PaymentTerms.Insert(false);
        end else
            PaymentTerms.Insert(false);
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