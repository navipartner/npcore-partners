codeunit 6014681 "NPR Rep. Get Salespers/Purch" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetSalespersonsPurchasers_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetSalespersonsPurchasers(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetSalespersonsPurchasers(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        SPCode: Code[20];
        SPId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        SPCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(SPCode));
        SPId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF SPId <> '' then
            IF SalespersonPurchaser.GetBySystemId(SPId) then begin
                RecFoundBySystemId := true;
                If SalespersonPurchaser.Code <> SPCode then // rename!
                    if NOT SalespersonPurchaser.Rename(SPCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT SalespersonPurchaser.Get(SPCode) then
                InsertNewRec(SalespersonPurchaser, SPCode, SPId);

        IF CheckFieldsChanged(SalespersonPurchaser, JToken) then
            SalespersonPurchaser.Modify(true);
    end;

    local procedure CheckFieldsChanged(var SalespersonPurchaser: Record "Salesperson/Purchaser"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo(Name), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("Commission %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.commission'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("Phone No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.phoneNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("E-Mail"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.eMail'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("E-Mail 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.eMail2'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("Privacy Blocked"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.privacyBlocked'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("Global Dimension 1 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension1Code'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("Global Dimension 2 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension2Code'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("Job Title"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.jobTitle'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("Search E-Mail"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.searchEMail'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("NPR Register Password"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprRegisterPassword'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("NPR Locked-to Register No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprLockedToRegisterNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("NPR Maximum Cash Returnsale"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMaximumCashReturnsale'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(SalespersonPurchaser, SalespersonPurchaser.FieldNo("NPR Supervisor POS"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprSupervisorPOS'), true) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var SalespersonPurchaser: Record "Salesperson/Purchaser"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(SalespersonPurchaser, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(SalespersonPurchaser);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var SalespersonPurchaser: Record "Salesperson/Purchaser"; SPCode: Code[20]; SPId: text)
    begin
        SalespersonPurchaser.Init();
        SalespersonPurchaser.Code := SPCode;
        IF SPId <> '' THEN begin
            IF Evaluate(SalespersonPurchaser.SystemId, SPId) Then
                SalespersonPurchaser.Insert(false, true)
            Else
                SalespersonPurchaser.Insert(false);
        end else
            SalespersonPurchaser.Insert(false);
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