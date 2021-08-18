codeunit 6014671 "NPR Rep. Get Cust Price Groups" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetCustomerPriceGroups_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetCustomerPriceGroups(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetCustomerPriceGroups(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        CustomerPriceGroup: Record "Customer Price Group";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        GroupCode: Code[10];
        GroupId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        GroupCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(GroupCode));
        GroupId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF GroupId <> '' then
            IF CustomerPriceGroup.GetBySystemId(GroupId) then begin
                RecFoundBySystemId := true;
                If CustomerPriceGroup.Code <> GroupCode then // rename!
                    if NOT CustomerPriceGroup.Rename(GroupCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT CustomerPriceGroup.Get(GroupCode) then
                InsertNewRec(CustomerPriceGroup, GroupCode, GroupId);

        IF CheckFieldsChanged(CustomerPriceGroup, JToken) then
            CustomerPriceGroup.Modify(true);
    end;

    local procedure CheckFieldsChanged(var CustomerPriceGroup: Record "Customer Price Group"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(CustomerPriceGroup, CustomerPriceGroup.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPriceGroup, CustomerPriceGroup.FieldNo("Allow Invoice Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowInvoiceDisc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPriceGroup, CustomerPriceGroup.FieldNo("Allow Line Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowLineDisc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPriceGroup, CustomerPriceGroup.FieldNo("Price Calculation Method"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceCalculationMethod'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPriceGroup, CustomerPriceGroup.FieldNo("Price Includes VAT"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceIncludesVAT'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(CustomerPriceGroup, CustomerPriceGroup.FieldNo("VAT Bus. Posting Gr. (Price)"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatBusPostingGrPrice'), true) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var CustomerPriceGroup: Record "Customer Price Group"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(CustomerPriceGroup, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(CustomerPriceGroup);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var CustomerPriceGroup: Record "Customer Price Group"; GroupCode: Code[10]; GroupId: text)
    begin
        CustomerPriceGroup.Init();
        CustomerPriceGroup.Code := GroupCode;
        IF GroupId <> '' THEN begin
            IF Evaluate(CustomerPriceGroup.SystemId, GroupId) Then
                CustomerPriceGroup.Insert(false, true)
            Else
                CustomerPriceGroup.Insert(false);
        end else
            CustomerPriceGroup.Insert(false);
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