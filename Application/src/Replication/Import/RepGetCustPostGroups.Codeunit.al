codeunit 6014687 "NPR Rep. Get Cust Post. Groups" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetCustomerPostingGroups_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetCustomerPostingGroups(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetCustomerPostingGroups(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        CustomerPostingGroup: Record "Customer Posting Group";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        GroupCode: Code[20];
        GroupId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        GroupCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(GroupCode));
        GroupId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF GroupId <> '' then
            IF CustomerPostingGroup.GetBySystemId(GroupId) then begin
                RecFoundBySystemId := true;
                If CustomerPostingGroup.Code <> GroupCode then // rename!
                    if NOT CustomerPostingGroup.Rename(GroupCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT CustomerPostingGroup.Get(GroupCode) then
                InsertNewRec(CustomerPostingGroup, GroupCode, GroupId);

        IF CheckFieldsChanged(CustomerPostingGroup, JToken) then
            CustomerPostingGroup.Modify(true);
    end;

    local procedure CheckFieldsChanged(var CustomerPostingGroup: Record "Customer Posting Group"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Receivables Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.receivablesAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Service Charge Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.serviceChargeAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Payment Disc. Debit Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.paymentDiscDebitAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Invoice Rounding Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.invoiceRoundingAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Additional Fee Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.additionalFeeAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Interest Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.interestAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Debit Curr. Appln. Rndg. Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.debitCurrApplnRndgAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Credit Curr. Appln. Rndg. Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.creditCurrApplnRndgAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Debit Rounding Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.debitRoundingAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Credit Rounding Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.creditRoundingAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Payment Disc. Credit Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.paymentDiscCreditAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Payment Tolerance Debit Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.paymentToleranceDebitAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Payment Tolerance Credit Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.paymentToleranceCreditAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("Add. Fee per Line Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.addFeePerLineAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPostingGroup, CustomerPostingGroup.FieldNo("View All Accounts on Lookup"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.viewAllAccountsOnLookup'), true) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var CustomerPostingGroup: Record "Customer Posting Group"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(CustomerPostingGroup, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(CustomerPostingGroup);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var CustomerPostingGroup: Record "Customer Posting Group"; GroupCode: Code[20]; GroupId: text)
    begin
        CustomerPostingGroup.Init();
        CustomerPostingGroup.Code := GroupCode;
        IF GroupId <> '' THEN begin
            IF Evaluate(CustomerPostingGroup.SystemId, GroupId) Then
                CustomerPostingGroup.Insert(false, true)
            Else
                CustomerPostingGroup.Insert(false);
        end else
            CustomerPostingGroup.Insert(false);
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