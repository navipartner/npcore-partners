codeunit 6014692 "NPR Rep. Get Locations" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetLocations_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetLocations(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetLocations(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        Location: Record Location;
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        LocationCode: Code[10];
        LocationId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        LocationCode := CopyStr(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(LocationCode));
        LocationId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF LocationId <> '' then
            IF Location.GetBySystemId(LocationId) then begin
                RecFoundBySystemId := true;
                If Location."Code" <> LocationCode then // rename!
                    if NOT Location.Rename(LocationCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT Location.Get(LocationCode) then
                InsertNewRec(Location, LocationCode, LocationId);

        IF CheckFieldsChanged(Location, JToken) then
            Location.Modify(true);
    end;

    local procedure CheckFieldsChanged(var Location: Record Location; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(Location, Location.FieldNo(Name), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Name 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName2'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo(Address), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.address'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Address 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.address2'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Adjustment Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.adjustmentBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Allow Breakbulk"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowBreakbulk'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Always Create Pick Line"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.alwaysCreatePickLine'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Always Create Put-away Line"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.alwaysCreatePutAwayLine'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Asm.-to-Order Shpt. Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.asmToOrderShptBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Base Calendar Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.baseCalendarCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Bin Capacity Policy"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.binCapacityPolicy'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Bin Mandatory"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.binMandatory'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo(City), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.city'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo(Contact), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.contact'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Country/Region Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.countryRegionCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo(County), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.county'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Cross-Dock Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.crossDockBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Cross-Dock Due Date Calc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.crossDockDueDateCalc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Default Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.defaultBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Default Bin Selection"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.defaultBinSelection'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Directed Put-away and Pick"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.directedPutAwayAndPick'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("E-Mail"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.eMail'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Fax No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.faxNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("From-Assembly Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.fromAssemblyBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("From-Production Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.fromProductionBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Home Page"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.homePage'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Inbound Whse. Handling Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.inboundWhseHandlingTime'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("NPR Store Group Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprStoreGroupCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Open Shop Floor Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.openShopFloorBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Outbound Whse. Handling Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.outboundWhseHandlingTime'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Phone No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.phoneNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Phone No. 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.phoneNo2'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Pick According to FEFO"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.pickAccordingToFEFO'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Post Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.postCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Put-away Template Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.putAwayTemplateCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Receipt Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.receiptBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Require Pick"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.requirePick'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Require Put-away"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.requirePutAway'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Require Receive"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.requireReceive'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Require Shipment"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.requireShipment'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Shipment Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.shipmentBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Special Equipment"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.specialEquipment'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Telex No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.telexNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("To-Assembly Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.toAssemblyBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("To-Production Bin Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.toProductionBinCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Use ADCS"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.useADCS'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Use As In-Transit"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.useAsInTransit'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Use Cross-Docking"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.useCrossDocking'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Location, Location.FieldNo("Use Put-away Worksheet"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.usePutAwayWorksheet'), true) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var Location: Record Location; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(Location, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(Location);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var Location: Record Location; LocationCode: Code[10]; LocationId: text)
    begin
        Location.Init();
        Location.Code := LocationCode;
        IF LocationId <> '' THEN begin
            IF Evaluate(Location.SystemId, LocationId) Then
                Location.Insert(false, true)
            Else
                Location.Insert(false);
        end else
            Location.Insert(false);
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