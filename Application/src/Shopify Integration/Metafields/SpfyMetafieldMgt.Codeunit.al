#if not BC17
codeunit 6185065 "NPR Spfy Metafield Mgt."
{
    Access = Internal;
    TableNo = "NPR Data Log Record";

    var
        _TempSpfyMetafieldDef: Record "NPR Spfy Metafield Definition";
        _UnexpectedResponseErr: Label '%1. Shopify returned the following response:\%2', Comment = '%1 - Error descrition, %2 - Shopify returned response.';

    procedure ProcessDataLogRecord(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    begin
        case DataLogEntry."Table ID" of
            Database::"NPR Spfy Entity Metafield":
                begin
                    TaskCreated := ProcessMetafield(DataLogEntry);
                end;
            else
                exit;
        end;
        Commit();
    end;

    internal procedure ProcessMetafield(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyMetafieldMgtPublic: Codeunit "NPR Spfy Metafield Mgt. Public";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        ShopifyStoreCode: Code[20];
        TaskRecordValue: Text;
        ProcessRecord: Boolean;
    begin
        if DataLogEntry."Type of Change" <> DataLogEntry."Type of Change"::Modify then
            exit;

        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SpfyEntityMetafield);
        if not SpfyEntityMetafield.Find() then
            exit;

        SpfyMetafieldMgtPublic.OnProcessMetafieldEntityDataLogEntry(SpfyEntityMetafield, ShopifyStoreCode, TaskRecordValue, ProcessRecord);
        if not ProcessRecord then
            case SpfyEntityMetafield."Table No." of
                Database::"NPR Spfy Store-Item Link":
                    ProcessRecord := SpfyItemMgt.ProcessMetafield(SpfyEntityMetafield, ShopifyStoreCode, TaskRecordValue);
                Database::"NPR Spfy Store-Customer Link":
                    ProcessRecord := SpfyCustomerMgt.ProcessMetafield(SpfyEntityMetafield, ShopifyStoreCode, TaskRecordValue);
            end;

        if not ProcessRecord or (ShopifyStoreCode = '') then
            exit;
        if TaskRecordValue = '' then
            TaskRecordValue := Format(SpfyEntityMetafield."BC Record ID");

        clear(NcTask);
        NcTask.Type := NcTask.Type::Modify;
        exit(SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, SpfyEntityMetafield."BC Record ID", TaskRecordValue, NcTask.Type, 0DT, 0DT, NcTask));
    end;

    internal procedure SelectShopifyMetafield(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var SelectedMetafieldID: Text[30]): Boolean
    begin
        exit(SelectShopifyMetafield(ShopifyStoreCode, ShopifyOwnerType, '', SelectedMetafieldID));
    end;

    internal procedure SelectShopifyMetafield(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; MetafieldTypeFilter: Text; var SelectedMetafieldID: Text[30]) Selected: Boolean
    begin
        GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, true);
        if MetafieldTypeFilter <> '' then begin
            _TempSpfyMetafieldDef.FilterGroup(2);
            _TempSpfyMetafieldDef.SetFilter(Type, MetafieldTypeFilter);
            _TempSpfyMetafieldDef.FilterGroup(0);
        end;

        if SelectedMetafieldID <> '' then begin
            _TempSpfyMetafieldDef.ID := SelectedMetafieldID;
            if _TempSpfyMetafieldDef.Find('=><') then;
        end;
        Selected := Page.RunModal(Page::"NPR Spfy Metafields", _TempSpfyMetafieldDef) = Action::LookupOK;
        if Selected then
            SelectedMetafieldID := _TempSpfyMetafieldDef.ID;

        if MetafieldTypeFilter <> '' then begin
            _TempSpfyMetafieldDef.FilterGroup(2);
            _TempSpfyMetafieldDef.SetRange(Type);
            _TempSpfyMetafieldDef.FilterGroup(0);
        end;
    end;

    internal procedure SyncedEntityMetafieldCount(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"): Integer
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        FilterSpfyEntityMetafields(EntityRecID, ShopifyOwnerType, SpfyEntityMetafield);
        exit(SpfyEntityMetafield.Count());
    end;

    internal procedure ShowEntitySyncedMetafields(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type")
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        FilterSpfyEntityMetafields(EntityRecID, ShopifyOwnerType, SpfyEntityMetafield);
        Page.Run(0, SpfyEntityMetafield);
    end;

    internal procedure InitStoreItemLinkMetafields(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        DataLogMgt: Codeunit "NPR Data Log Management";
        SpfyMetafieldMgtPublic: Codeunit "NPR Spfy Metafield Mgt. Public";
        SpfyMFHdlItemAttrib: Codeunit "NPR Spfy M/F Hdl.-Item Attrib.";
        SpfyMFHdlItemCateg: Codeunit "NPR Spfy M/F Hdl.-Item Categ.";
    begin
#if not (BC18 or BC19 or BC20 or BC21)
        SpfyEntityMetafield.ReadIsolation := IsolationLevel::UpdLock;
#else
        SpfyEntityMetafield.LockTable();
#endif
        SpfyEntityMetafield.SetRange("Table No.", Database::"NPR Spfy Store-Item Link");
        SpfyEntityMetafield.SetRange("BC Record ID", SpfyStoreItemLink.RecordId());
        if not SpfyEntityMetafield.IsEmpty() then begin
            DataLogMgt.DisableDataLog(true);
            SpfyEntityMetafield.DeleteAll();
            DataLogMgt.DisableDataLog(false);
        end;

        SpfyMFHdlItemAttrib.InitStoreItemLinkMetafields(SpfyStoreItemLink);
        SpfyMFHdlItemCateg.InitStoreItemLinkMetafields(SpfyStoreItemLink);
        SpfyMetafieldMgtPublic.OnInitStoreItemLinkMetafields(SpfyStoreItemLink);
    end;

    internal procedure InitStoreCustomerLinkMetafields(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        DataLogMgt: Codeunit "NPR Data Log Management";
        SpfyMetafieldMgtPublic: Codeunit "NPR Spfy Metafield Mgt. Public";
        SpfyMFHdlClntAttrib: Codeunit "NPR Spfy M/F Hdl.-Clnt Attrib.";
        SpfyMFHdlLoyaltyPts: Codeunit "NPR Spfy M/F Hdl.-Loyalty Pts";
    begin
#if not (BC18 or BC19 or BC20 or BC21)
        SpfyEntityMetafield.ReadIsolation := IsolationLevel::UpdLock;
#else
        SpfyEntityMetafield.LockTable();
#endif
        SpfyEntityMetafield.SetRange("Table No.", Database::"NPR Spfy Store-Customer Link");
        SpfyEntityMetafield.SetRange("BC Record ID", SpfyStoreCustomerLink.RecordId());
        if not SpfyEntityMetafield.IsEmpty() then begin
            DataLogMgt.DisableDataLog(true);
            SpfyEntityMetafield.DeleteAll();
            DataLogMgt.DisableDataLog(false);
        end;

        SpfyMFHdlClntAttrib.InitStoreCustomerLinkMetafields(SpfyStoreCustomerLink);
        SpfyMFHdlLoyaltyPts.InitStoreCustomerLinkMetafields(SpfyStoreCustomerLink);
        SpfyMetafieldMgtPublic.OnInitStoreCustomerLinkMetafields(SpfyStoreCustomerLink);
    end;

    internal procedure ProcessMetafieldMappingChange(var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; xMetafieldID: Text[30]; Removed: Boolean; Silent: Boolean)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMgtPublic: Codeunit "NPR Spfy Metafield Mgt. Public";
        SpfyMFHdlClntAttrib: Codeunit "NPR Spfy M/F Hdl.-Clnt Attrib.";
        SpfyMFHdlItemAttrib: Codeunit "NPR Spfy M/F Hdl.-Item Attrib.";
        SpfyMFHdlItemCateg: Codeunit "NPR Spfy M/F Hdl.-Item Categ.";
        SpfyMFHdlLoyaltyPts: Codeunit "NPR Spfy M/F Hdl.-Loyalty Pts";
        Window: Dialog;
        LinkRegenerationCnf: Label 'Changing the Shopify metafield ID may take a significant amount of time, as the system may need to resend information about the metafield to Shopify for all affected Business Central entities. Are you sure you want to continue?';
        ProcessingLbl: Label 'Processing metafield mapping change...';
    begin
        if (SpfyMetafieldMapping."Metafield ID" = '') and (xMetafieldID = '') then
            exit;
        if (SpfyMetafieldMapping."Metafield ID" = xMetafieldID) and not Removed then
            exit;
        if (SpfyMetafieldMapping."Metafield ID" = '') and not Removed then
            Removed := true;
        if not GuiAllowed() then
            Silent := true;

        if not Silent then begin
            if not Confirm(LinkRegenerationCnf, true) then
                Error('');
            Window.Open(ProcessingLbl);
        end;

        SpfyMetafieldMapping.Modify(true);

        //Metafield mapping removed. Clear all stored entity metafield values
        SpfyEntityMetafield.SetRange("Owner Type", SpfyMetafieldMapping."Owner Type");
        SpfyEntityMetafield.SetRange("Metafield ID", xMetafieldID);
        if Removed then begin
            if xMetafieldID <> '' then
                if not SpfyEntityMetafield.IsEmpty() then
                    SpfyEntityMetafield.DeleteAll();
            if not Silent then
                Window.Close();
            exit;
        end;

        SpfyMFHdlItemAttrib.ProcessMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
        SpfyMFHdlItemCateg.ProcessMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
        SpfyMFHdlClntAttrib.ProcessMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
        SpfyMFHdlLoyaltyPts.ProcessMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
        SpfyMetafieldMgtPublic.OnProcessMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed, Silent);
        if not Silent then
            Window.Close();
    end;

    internal procedure UpdateMetafieldIDInExistingSpfyEntityMetafieldEntries(var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; NewMetafieldID: Text[30])
    var
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        if SpfyEntityMetafield.IsEmpty() then
            exit;
        DataLogMgt.DisableDataLog(true);
        SpfyEntityMetafield.ModifyAll("Metafield Key", '');
        SpfyEntityMetafield.ModifyAll("Metafield Value Version ID", '');
        DataLogMgt.DisableDataLog(false);
        SpfyEntityMetafield.ModifyAll("Metafield ID", NewMetafieldID);
    end;

    internal procedure ShopifyEntityMetafieldValueUpdateQuery(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20]; var QueryStream: OutStream) SendToShopify: Boolean
    var
        MetafieldsSet: JsonObject;
        RequestJson: JsonObject;
        QueryTok: Label 'mutation UpdateObjectMetafields($updateMetafields: [MetafieldsSetInput!]!, $deleteMetafields: [MetafieldIdentifierInput!]!) {metafieldsSet(metafields: $updateMetafields) {metafields {id key namespace value compareDigest definition {id}} userErrors {field message code}} metafieldsDelete(metafields: $deleteMetafields) {deletedMetafields {key namespace ownerId} userErrors {field message}}}', Locked = true;
    begin
        GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, false);
        SendToShopify := GenerateMetafieldsSet(EntityRecID, ShopifyOwnerType, ShopifyOwnerID, ShopifyStoreCode, MetafieldsSet);

        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', MetafieldsSet);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure ShopifyEntityMetafieldsSetRequestQuery(ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyOwnerID: Text[30]; var OwnerTypeTxt: Text; var QueryStream: OutStream)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'query GetMetafieldsSet($ownerID: ID!) {%1(id: $ownerID) {id metafields(first: 250){edges{node{id namespace key value compareDigest type definition{id}}}}}}', Locked = true;
    begin
        OwnerTypeTxt := GetOwnerTypeAsText(ShopifyOwnerType);
        VariablesJson.Add('ownerID', StrSubstNo('gid://shopify/%1/%2', OwnerTypeTxt, ShopifyOwnerID));

        RequestJson.Add('query', StrSubstNo(QueryTok, SpfyIntegrationMgt.LowerFirstLetter(OwnerTypeTxt)));
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    internal procedure RequestMetafieldValuesFromShopifyAndUpdateBCData(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20])
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        QueryStream: OutStream;
        MetafieldsSet: JsonToken;
        ShopifyResponse: JsonToken;
        OwnerTypeTxt: Text;
    begin
        if not MetafieldMappingExist(ShopifyStoreCode, ShopifyOwnerType) then
            exit;
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyEntityMetafieldsSetRequestQuery(ShopifyOwnerType, ShopifyOwnerID, OwnerTypeTxt, QueryStream);
        if SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse) then
            if ShopifyResponse.SelectToken(StrSubstNo('data.%1.metafields.edges', SpfyIntegrationMgt.LowerFirstLetter(OwnerTypeTxt)), MetafieldsSet) then
                UpdateBCMetafieldData(EntityRecID, ShopifyOwnerType, ShopifyStoreCode, MetafieldsSet);
    end;

    internal procedure UpdateBCMetafieldData(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyStoreCode: Code[20]; MetafieldsSet: JsonToken)
    var
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        RecRef: RecordRef;
        Metafield: JsonToken;
        ProcessedMetafields: List of [BigInteger];
        OwnerNo: Code[20];
    begin
        if not MetafieldsSet.IsArray() then
            exit;
        RecRef := EntityRecID.GetRecord();
        case RecRef.Number() of
            Database::"NPR Spfy Store-Item Link":
                begin
                    RecRef.SetTable(SpfyStoreItemLink);
                    OwnerNo := SpfyStoreItemLink."Item No.";
                end;
            Database::"NPR Spfy Store-Customer Link":
                begin
                    RecRef.SetTable(SpfyStoreCustomerLink);
                    if SpfyStoreCustomerLink.Type = SpfyStoreCustomerLink.Type::Customer then
                        OwnerNo := SpfyStoreCustomerLink."No.";
                end;
            else
                exit;
        end;
        SpfyMetafieldMapping.SetRange("Shopify Store Code", ShopifyStoreCode);
        SpfyMetafieldMapping.SetRange("Owner Type", ShopifyOwnerType);

        SpfyEntityMetafieldParam."BC Record ID" := EntityRecID;
        SpfyEntityMetafieldParam."Owner Type" := ShopifyOwnerType;

        foreach Metafield in MetafieldsSet.AsArray() do
            if Metafield.IsObject() then begin
                if Metafield.AsObject().Contains('node') then
                    Metafield.SelectToken('node', Metafield);
                SpfyEntityMetafieldParam."Metafield Key" := CopyStr(JsonHelper.GetJText(Metafield, 'key', false), 1, MaxStrLen(SpfyEntityMetafieldParam."Metafield Key"));
                SpfyEntityMetafieldParam.SetMetafieldValue(JsonHelper.GetJText(Metafield, 'value', false));
                SpfyEntityMetafieldParam."Metafield Value Version ID" := CopyStr(JsonHelper.GetJText(Metafield, 'compareDigest', false), 1, MaxStrLen(SpfyEntityMetafieldParam."Metafield Value Version ID"));
#pragma warning disable AA0139
                SpfyEntityMetafieldParam."Metafield ID" := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(Metafield, 'definition.id', false), '/');
#pragma warning restore AA0139
                if SpfyEntityMetafieldParam."Metafield ID" = '' then
                    SpfyEntityMetafieldParam."Metafield ID" := GetMetafiledIDFromMetafieldDefinitions(
                        ShopifyStoreCode, ShopifyOwnerType, SpfyEntityMetafieldParam."Metafield Key",
                        CopyStr(JsonHelper.GetJText(Metafield, 'namespace', false), 1, MaxStrLen(_TempSpfyMetafieldDef.Namespace)));

                if SpfyEntityMetafieldParam."Metafield ID" <> '' then begin
                    SpfyMetafieldMapping.SetRange("Metafield ID", SpfyEntityMetafieldParam."Metafield ID");
                    if SpfyMetafieldMapping.FindFirst() then
                        if DoBCMetafieldUpdate(SpfyMetafieldMapping, SpfyEntityMetafieldParam, OwnerNo) then
                            if not ProcessedMetafields.Contains(SpfyMetafieldMapping."Entry No.") then
                                ProcessedMetafields.Add(SpfyMetafieldMapping."Entry No.");
                end;
            end;

        // Remove entity metafields and related BC records for which no Shopify metafield was returned
        Clear(SpfyEntityMetafieldParam);
        SpfyEntityMetafieldParam."BC Record ID" := EntityRecID;
        SpfyEntityMetafieldParam."Owner Type" := ShopifyOwnerType;

        SpfyMetafieldMapping.SetFilter("Metafield ID", '<>%1', '');
        if SpfyMetafieldMapping.FindSet() then
            repeat
                if not ProcessedMetafields.Contains(SpfyMetafieldMapping."Entry No.") then begin
                    SpfyEntityMetafieldParam."Metafield ID" := SpfyMetafieldMapping."Metafield ID";
                    SpfyEntityMetafieldParam."Metafield Key" := GetMetafiledKeyFromMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, SpfyEntityMetafieldParam."Metafield ID");
                    if SpfyEntityMetafieldParam."Metafield Key" <> '' then
                        DoBCMetafieldUpdate(SpfyMetafieldMapping, SpfyEntityMetafieldParam, OwnerNo);
                end;
            until SpfyMetafieldMapping.Next() = 0;
    end;

    local procedure DoBCMetafieldUpdate(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield"; OwnerNo: Code[20]) Updated: Boolean
    var
        SpfyMetafieldMgtPublic: Codeunit "NPR Spfy Metafield Mgt. Public";
        SpfyMFHdlClntAttrib: Codeunit "NPR Spfy M/F Hdl.-Clnt Attrib.";
        SpfyMFHdlItemAttrib: Codeunit "NPR Spfy M/F Hdl.-Item Attrib.";
        SpfyMFHdlItemCateg: Codeunit "NPR Spfy M/F Hdl.-Item Categ.";
    begin
        SpfyMFHdlItemAttrib.DoBCMetafieldUpdate(SpfyMetafieldMapping, SpfyEntityMetafieldParam, OwnerNo, Updated);
        SpfyMFHdlItemCateg.DoBCMetafieldUpdate(SpfyMetafieldMapping, SpfyEntityMetafieldParam, OwnerNo, Updated);
        SpfyMFHdlClntAttrib.DoBCMetafieldUpdate(SpfyMetafieldMapping, SpfyEntityMetafieldParam, OwnerNo, Updated);
        SpfyMetafieldMgtPublic.OnDoBCMetafieldUpdate(SpfyMetafieldMapping, SpfyEntityMetafieldParam, OwnerNo, Updated);
        exit(Updated);
    end;

    local procedure GetMetafiledIDFromMetafieldDefinitions(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; MetafieldKey: Text[80]; MetafieldNamespace: Text[255]) MetafieldID: Text[30]
    begin
        if _TempSpfyMetafieldDef.IsEmpty() then
            GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, false);
        _TempSpfyMetafieldDef.SetRange("Owner Type", ShopifyOwnerType);
        _TempSpfyMetafieldDef.SetRange("Key", MetafieldKey);
        _TempSpfyMetafieldDef.SetRange("Namespace", MetafieldNamespace);
        if _TempSpfyMetafieldDef.FindFirst() then
            MetafieldID := _TempSpfyMetafieldDef.ID;
        _TempSpfyMetafieldDef.Reset();
    end;

    local procedure GetMetafiledKeyFromMetafieldDefinitions(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; MetafieldID: Text[30]) MetafieldKey: Text[80]
    begin
        if _TempSpfyMetafieldDef.IsEmpty() then
            GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, false);
        if _TempSpfyMetafieldDef.Get(MetafieldID) then
            MetafieldKey := _TempSpfyMetafieldDef."Key";
    end;

    local procedure GetShopifyMetafieldDefinitions(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; WithDialog: Boolean)
    begin
        GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, '', WithDialog);
    end;

    local procedure GetShopifyMetafieldDefinitions(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; QueryFilters: Text; WithDialog: Boolean)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ReceivedShopifyMetafields: JsonArray;
        ReceivedShopifyMetafield: JsonToken;
        ValidationRule: JsonToken;
        ValidationRules: JsonToken;
        ShopifyResponse: JsonToken;
        Window: Dialog;
        Cursor: Text;
        CouldNotGetMetafieldDefinitionsErr: Label 'Could not get metafield definitions from Shopify. The following error occured: %1', Comment = '%1 - Shopify returned error text.';
    begin
        if WithDialog then
            WithDialog := GuiAllowed();
        if WithDialog then
            Window.Open(QueryingShopifyLbl());

        ClearTempSpfyMetafieldDefinitions();
        ClearLastError();
        Cursor := '';

        repeat
            if not GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, QueryFilters, Cursor, ShopifyResponse) then
                Error(CouldNotGetMetafieldDefinitionsErr, GetLastErrorText());
            ShopifyResponse.SelectToken('data.metafieldDefinitions.edges', ShopifyResponse);
            ReceivedShopifyMetafields := ShopifyResponse.AsArray();
            foreach ReceivedShopifyMetafield in ReceivedShopifyMetafields do begin
                Cursor := JsonHelper.GetJText(ReceivedShopifyMetafield, 'cursor', false);
                _TempSpfyMetafieldDef.Init();
#pragma warning disable AA0139
                _TempSpfyMetafieldDef.ID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.id', true), '/');
                if not _TempSpfyMetafieldDef.Find() then begin
                    _TempSpfyMetafieldDef."Key" := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.key', MaxStrLen(_TempSpfyMetafieldDef."Key"), true);
                    _TempSpfyMetafieldDef.Name := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.name', MaxStrLen(_TempSpfyMetafieldDef.Name), false);
                    _TempSpfyMetafieldDef.Type := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.type.name', MaxStrLen(_TempSpfyMetafieldDef.Type), false);
                    _TempSpfyMetafieldDef.Description := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.description', MaxStrLen(_TempSpfyMetafieldDef.Description), false);
                    _TempSpfyMetafieldDef.Namespace := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.namespace', MaxStrLen(_TempSpfyMetafieldDef.Namespace), true);
#pragma warning restore AA0139
                    if ReceivedShopifyMetafield.SelectToken('node.validations', ValidationRules) and ValidationRules.IsArray() then
                        foreach ValidationRule in ValidationRules.AsArray() do
                            if JsonHelper.GetJText(ValidationRule, 'name', false) = 'metaobject_definition_id' then begin
#pragma warning disable AA0139
                                _TempSpfyMetafieldDef."Validation Definition GID" := JsonHelper.GetJText(ValidationRule, 'value', false);
#pragma warning restore AA0139
                                break;
                            end;
                    _TempSpfyMetafieldDef."Owner Type" := ShopifyOwnerType;
                    _TempSpfyMetafieldDef.Insert();
                end;
            end;
        until not JsonHelper.GetJBoolean(ShopifyResponse, 'data.metafieldDefinitions.pageInfo.hasNextPage', false) or (Cursor = '');
        if WithDialog then
            Window.Close();
    end;

    local procedure GetShopifyMetafieldDefinitions(ShopifyStoreCode: Code[20]; OwnerType: Enum "NPR Spfy Metafield Owner Type"; QueryFilters: Text; Cursor: Text; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        FirstPageQueryTok: Label 'query($ownerType: MetafieldOwnerType!, $queryFilters: String!) {metafieldDefinitions(first: 25, ownerType: $ownerType, query: $queryFilters) {edges{cursor node{id key type{name category} name description namespace validations{name type value}}} pageInfo{hasNextPage}}}', Locked = true;
        SubsequentPageQueryTok: Label 'query($ownerType: MetafieldOwnerType!, $queryFilters: String!, $afterCursor: String!) {metafieldDefinitions(first: 25, after: $afterCursor, ownerType: $ownerType, query: $queryFilters) {edges{cursor node{id key type{name category} name description namespace validations{name type value}}} pageInfo{hasNextPage}}}', Locked = true;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        VariablesJson.Add('ownerType', OwnerTypeEnumValueName(OwnerType));
        VariablesJson.Add('queryFilters', QueryFilters);
        if Cursor = '' then
            RequestJson.Add('query', FirstPageQueryTok)
        else begin
            RequestJson.Add('query', SubsequentPageQueryTok);
            VariablesJson.Add('afterCursor', Cursor);
        end;
        RequestJson.Add('variables', VariablesJson);
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);

        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    local procedure GenerateMetafieldsSet(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20]; var MetafieldsSet: JsonObject): Boolean
    var
        RemoveMetafields: JsonArray;
        UpdateMetafields: JsonArray;
    begin
        Clear(MetafieldsSet);
        GenerateMetafieldUpdateArrays(EntityRecID, ShopifyOwnerType, ShopifyOwnerID, ShopifyStoreCode, UpdateMetafields, RemoveMetafields);

        MetafieldsSet.Add('updateMetafields', UpdateMetafields);
        MetafieldsSet.Add('deleteMetafields', RemoveMetafields);
        exit(UpdateMetafields.Count() + RemoveMetafields.Count() > 0);
    end;

    internal procedure GenerateMetafieldUpdateArrays(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20]; var UpdateMetafields: JsonArray; var RemoveMetafields: JsonArray)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        Metafield: JsonObject;
        NullJsonValue: JsonValue;
        MetafieldValue: Text;
        MetafieldVersionCheck: Boolean;
    begin
        Clear(UpdateMetafields);
        Clear(RemoveMetafields);
        MetafieldVersionCheck := IsMetafieldVersionCheckEnabled();
        if MetafieldVersionCheck then
            NullJsonValue.SetValueToNull();
        if _TempSpfyMetafieldDef.IsEmpty() then
            GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, false);

        FilterSpfyEntityMetafields(EntityRecID, ShopifyOwnerType, SpfyEntityMetafield);
        SpfyEntityMetafield.SetFilter("Metafield ID", '<>%1', '');
        if SpfyEntityMetafield.FindSet() then
            repeat
                if _TempSpfyMetafieldDef.Get(SpfyEntityMetafield."Metafield ID") then begin
                    Clear(Metafield);
                    Metafield.Add('key', _TempSpfyMetafieldDef."Key");
                    Metafield.Add('namespace', _TempSpfyMetafieldDef.Namespace);
                    if ShopifyOwnerID <> '' then
                        Metafield.Add('ownerId', StrSubstNo('gid://shopify/%1/%2', GetOwnerTypeAsText(ShopifyOwnerType), ShopifyOwnerID));
                    MetafieldValue := SpfyEntityMetafield.GetMetafieldValue(true);
                    if MetafieldValue <> '' then begin
                        Metafield.Add('type', _TempSpfyMetafieldDef.Type);
                        Metafield.Add('value', MetafieldValue);
                        if MetafieldVersionCheck then begin
                            if SpfyEntityMetafield."Metafield Value Version ID" <> '' then
                                Metafield.Add('compareDigest', SpfyEntityMetafield."Metafield Value Version ID")
                            else
                                Metafield.Add('compareDigest', NullJsonValue);
                        end;
                        UpdateMetafields.Add(Metafield);
                    end else
                        RemoveMetafields.Add(Metafield);
                end;
            until SpfyEntityMetafield.Next() = 0;
    end;

    local procedure IsMetafieldVersionCheckEnabled(): Boolean
    begin
        //Disabling compareDigest (version check), as it does not seem to be really useful and only adds unnecessary complexity and errors.
        exit(false);
    end;

    internal procedure GetMetaobjectRelatedMetafieldDefinitionID(ShopifyStoreCode: Code[20]; MetaobjectDefinitionGID: Text; var MetafieldID: Text[30])
    begin
        GetShopifyMetafieldDefinitions(ShopifyStoreCode, Enum::"NPR Spfy Metafield Owner Type"::PRODUCT, StrSubstNo('type:%1', MetaobjectReferenceShopifyMetafieldType()), false);
        _TempSpfyMetafieldDef.SetRange("Validation Definition GID", MetaobjectDefinitionGID);
        if MetafieldID <> '' then begin
            _TempSpfyMetafieldDef.ID := MetafieldID;
            if not _TempSpfyMetafieldDef.Find() then
                MetafieldID := '';
        end;
        if MetafieldID = '' then
            if _TempSpfyMetafieldDef.FindFirst() then
                MetafieldID := _TempSpfyMetafieldDef.ID;
        ClearTempSpfyMetafieldDefinitions();
    end;

    internal procedure CreateMetafieldDefinition(ShopifyStoreCode: Code[20]; ShopifyMetafieldDefinitionCreateQuery: JsonObject) NewMetafieldID: Text[30]
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        QueryStream: OutStream;
        MetafieldDefinition: JsonToken;
        ShopifyResponse: JsonToken;
        CouldNotCreateMetafieldDefinitionErr: Label 'Could not create metafield definition in Shopify.';
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyMetafieldDefinitionCreateQuery.WriteTo(QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotCreateMetafieldDefinitionErr, GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotCreateMetafieldDefinitionErr, ShopifyResponse);
        if ShopifyResponse.SelectToken('data.metafieldDefinitionCreate.createdDefinition', MetafieldDefinition) and MetafieldDefinition.IsObject() then
#pragma warning disable AA0139
            NewMetafieldID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(MetafieldDefinition, 'id', true), '/');
#pragma warning restore AA0139
        if NewMetafieldID = '' then
            Error(_UnexpectedResponseErr, CouldNotCreateMetafieldDefinitionErr, ShopifyResponse);
    end;

    internal procedure GetMetaobjectDefinitionGID(ShopifyStoreCode: Code[20]; ShopifyMetaobjectDefinitionGetByTypeQuery: JsonObject): Text
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        MetaobjectDefinition: JsonToken;
        ShopifyResponse: JsonToken;
        QueryStream: OutStream;
        CouldNotGetMetaobjectDefinitionErr: Label 'Could not obtain metaobject definition from Shopify.';
    begin
        ClearLastError();
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyMetaobjectDefinitionGetByTypeQuery.WriteTo(QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotGetMetaobjectDefinitionErr, GetLastErrorText());
        if ShopifyResponse.SelectToken('data.metaobjectDefinitionByType', MetaobjectDefinition) and MetaobjectDefinition.IsObject() then
            exit(JsonHelper.GetJText(MetaobjectDefinition, 'id', true));
    end;

    internal procedure CreateMetaobjectDefinition(ShopifyStoreCode: Code[20]; ShopifyMetaobjectDefinitionCreateQuery: JsonObject): Text
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        MetaobjectDefinition: JsonToken;
        ShopifyResponse: JsonToken;
        QueryStream: OutStream;
        MetaobjectDefinitionGID: Text;
        CouldNotCreateMetaobjectDefinitionErr: Label 'Could not create metaobject definition in Shopify.';
    begin
        ClearLastError();
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyMetaobjectDefinitionCreateQuery.WriteTo(QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotCreateMetaobjectDefinitionErr, GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotCreateMetaobjectDefinitionErr, ShopifyResponse);
        if ShopifyResponse.SelectToken('data.metaobjectDefinitionCreate.metaobjectDefinition', MetaobjectDefinition) and MetaobjectDefinition.IsObject() then
            MetaobjectDefinitionGID := JsonHelper.GetJText(MetaobjectDefinition, 'id', true);
        if MetaobjectDefinitionGID = '' then
            Error(_UnexpectedResponseErr, CouldNotCreateMetaobjectDefinitionErr, ShopifyResponse);
        exit(MetaobjectDefinitionGID);
    end;

    internal procedure UpdateMetaobjectDefinition(ShopifyStoreCode: Code[20]; ShopifyMetaobjectDefinitionUpdateQuery: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        QueryStream: OutStream;
        CouldNotUpdateMetaobjectDefinitionErr: Label 'Could not update metaobject definition in Shopify.';
    begin
        ClearLastError();
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyMetaobjectDefinitionUpdateQuery.WriteTo(QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotUpdateMetaobjectDefinitionErr, GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotUpdateMetaobjectDefinitionErr, ShopifyResponse);
    end;

    internal procedure UpsertMetaobject(ShopifyStoreCode: Code[20]; MetaobjectBCEntity: Text; ShopifyMetaobjectUpsertQuery: JsonObject) MetaobjectValueID: Text[30]
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        QueryStream: OutStream;
        MetafieldDefinition: JsonToken;
        ShopifyResponse: JsonToken;
        CouldNotUpsertMetaobjectErr: Label 'Could not upsert %1 metaobject in Shopify store "%2".', Comment = '%1 - BC entity mapped to the metaobject, %2 - Shopify store code';
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyMetaobjectUpsertQuery.WriteTo(QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, StrSubstNo(CouldNotUpsertMetaobjectErr, MetaobjectBCEntity, ShopifyStoreCode), GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error(_UnexpectedResponseErr, StrSubstNo(CouldNotUpsertMetaobjectErr, MetaobjectBCEntity, ShopifyStoreCode), ShopifyResponse);
        if ShopifyResponse.SelectToken('data.metaobjectUpsert.metaobject', MetafieldDefinition) and MetafieldDefinition.IsObject() then
#pragma warning disable AA0139
            MetaobjectValueID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(MetafieldDefinition, 'id', true), '/');
#pragma warning restore AA0139
        if MetaobjectValueID = '' then
            Error(_UnexpectedResponseErr, StrSubstNo(CouldNotUpsertMetaobjectErr, MetaobjectBCEntity, ShopifyStoreCode), ShopifyResponse);
    end;

    internal procedure MetaobjectReferenceShopifyMetafieldType(): Text
    begin
        exit('list.metaobject_reference');
    end;

    local procedure ClearTempSpfyMetafieldDefinitions()
    begin
        _TempSpfyMetafieldDef.Reset();
        _TempSpfyMetafieldDef.DeleteAll();
    end;

    internal procedure SetEntityMetafieldValue(Params: Record "NPR Spfy Entity Metafield"; DeleteEmpty: Boolean; DisableDataLog: Boolean)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        FilterSpfyEntityMetafields(Params."BC Record ID", Params."Owner Type", SpfyEntityMetafield);
        SpfyEntityMetafield.SetRange("Metafield ID", Params."Metafield ID");
        if not SpfyEntityMetafield.FindFirst() then begin
            if not Params."Metafield Raw Value".HasValue() then
                exit;

            SpfyEntityMetafield.Init();
            SpfyEntityMetafield."Entry No." := 0;
            SpfyEntityMetafield.Insert();

            SpfyEntityMetafield."Table No." := Params."BC Record ID".TableNo();
            SpfyEntityMetafield."BC Record ID" := Params."BC Record ID";
            SpfyEntityMetafield."Owner Type" := Params."Owner Type";
            SpfyEntityMetafield."Metafield ID" := Params."Metafield ID";
            SpfyEntityMetafield."Metafield Key" := Params."Metafield Key";
            SpfyEntityMetafield."Metafield Raw Value" := Params."Metafield Raw Value";
            SpfyEntityMetafield."Metafield Value Version ID" := Params."Metafield Value Version ID";
            if DisableDataLog then
                DataLogMgt.DisableDataLog(true);
            SpfyEntityMetafield.Modify(true);
            if DisableDataLog then
                DataLogMgt.DisableDataLog(false);
            exit;
        end;

        if not Params."Metafield Raw Value".HasValue() and DeleteEmpty then begin
            if DisableDataLog then
                DataLogMgt.DisableDataLog(true);
            SpfyEntityMetafield.Delete(true);
            if DisableDataLog then
                DataLogMgt.DisableDataLog(false);
            exit;
        end;

        if (Params.GetMetafieldValue(false) = SpfyEntityMetafield.GetMetafieldValue(true)) and
           (Params."Metafield Key" in ['', SpfyEntityMetafield."Metafield Key"]) and
           (Params."Metafield Value Version ID" in ['', SpfyEntityMetafield."Metafield Value Version ID"])
        then
            exit;

        SpfyEntityMetafield."Metafield Raw Value" := Params."Metafield Raw Value";
        if Params."Metafield Key" <> '' then
            SpfyEntityMetafield."Metafield Key" := Params."Metafield Key";
        if Params."Metafield Value Version ID" <> '' then
            SpfyEntityMetafield."Metafield Value Version ID" := Params."Metafield Value Version ID";
        if DisableDataLog then
            DataLogMgt.DisableDataLog(true);
        SpfyEntityMetafield.Modify(true);
        if DisableDataLog then
            DataLogMgt.DisableDataLog(false);
    end;

    local procedure MetafieldMappingExist(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"): Boolean
    var
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
    begin
        SpfyMetafieldMapping.SetRange("Shopify Store Code", ShopifyStoreCode);
        SpfyMetafieldMapping.SetRange("Owner Type", ShopifyOwnerType);
        exit(not SpfyMetafieldMapping.IsEmpty());
    end;

    internal procedure FilterMetafieldMapping(TableNo: Integer; FieldNo: Integer; ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping")
    begin
        SpfyMetafieldMapping.Reset();
        SpfyMetafieldMapping.SetCurrentKey("Table No.", "Field No.", "BC Record ID", "Shopify Store Code", "Owner Type", "Metafield ID");
        SpfyMetafieldMapping.SetRange("Table No.", TableNo);
        FinishMetafieldMappingFiltering(FieldNo, ShopifyStoreCode, ShopifyOwnerType, SpfyMetafieldMapping);
    end;

    internal procedure FilterMetafieldMapping(RecID: RecordId; FieldNo: Integer; ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping")
    begin
        SpfyMetafieldMapping.Reset();
        SpfyMetafieldMapping.SetCurrentKey("Table No.", "Field No.", "BC Record ID", "Shopify Store Code", "Owner Type", "Metafield ID");
        SpfyMetafieldMapping.SetRange("Table No.", RecID.TableNo());
        SpfyMetafieldMapping.SetRange("BC Record ID", RecID);
        FinishMetafieldMappingFiltering(FieldNo, ShopifyStoreCode, ShopifyOwnerType, SpfyMetafieldMapping);
    end;

    local procedure FinishMetafieldMappingFiltering(FieldNo: Integer; ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping")
    begin
        SpfyMetafieldMapping.SetRange("Field No.", FieldNo);
        if ShopifyStoreCode <> '' then
            SpfyMetafieldMapping.SetRange("Shopify Store Code", ShopifyStoreCode)
        else
            SpfyMetafieldMapping.SetFilter("Shopify Store Code", '<>%1', '');
        if ShopifyOwnerType <> ShopifyOwnerType::" " then
            SpfyMetafieldMapping.SetRange("Owner Type", ShopifyOwnerType);
        SpfyMetafieldMapping.SetFilter("Metafield ID", '<>%1', '');
    end;

    internal procedure SaveMetafieldMapping(RecID: RecordId; FieldNo: Integer; ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; MetafieldID: Text[30])
    var
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
    begin
        FilterMetafieldMapping(RecID, FieldNo, ShopifyStoreCode, ShopifyOwnerType, SpfyMetafieldMapping);
        SpfyMetafieldMapping.SetRange("Metafield ID");
        if SpfyMetafieldMapping.FindFirst() then begin
            if MetafieldID = '' then
                SpfyMetafieldMapping.Delete(true)
            else begin
                SpfyMetafieldMapping."Metafield ID" := MetafieldID;
                SpfyMetafieldMapping.Modify(true);
            end;
            exit;
        end;
        if MetafieldID = '' then
            exit;
        SpfyMetafieldMapping.Init();
        SpfyMetafieldMapping."Table No." := RecID.TableNo();
        SpfyMetafieldMapping."Field No." := FieldNo;
        SpfyMetafieldMapping."BC Record ID" := RecID;
        SpfyMetafieldMapping."Shopify Store Code" := ShopifyStoreCode;
        SpfyMetafieldMapping."Owner Type" := ShopifyOwnerType;
        SpfyMetafieldMapping."Metafield ID" := MetafieldID;
        SpfyMetafieldMapping.Insert(true);
    end;

    internal procedure FilterSpfyEntityMetafields(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield")
    begin
        SpfyEntityMetafield.Reset();
        SpfyEntityMetafield.SetRange("Table No.", EntityRecID.TableNo());
        SpfyEntityMetafield.SetRange("BC Record ID", EntityRecID);
        SpfyEntityMetafield.SetRange("Owner Type", ShopifyOwnerType);
    end;

    local procedure GetOwnerTypeAsText(ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type") Result: Text
    var
        SpfyMetafieldMgtPublic: Codeunit "NPR Spfy Metafield Mgt. Public";
        Handled: Boolean;
        ShopifyOwnerTypesTxt: Label 'Product,ProductVariant,Customer', Locked = true;
        UndefinedOwnerTypeErr: Label 'Shopify metafield owner type was not set or is not supported (owner type = "%1"). This is a programming bug, not a user error. Please contact system vendor.';
    begin
        SpfyMetafieldMgtPublic.OnGetOwnerTypeAsText(ShopifyOwnerType, Result, Handled);
        if Handled then
            exit;
        if not (ShopifyOwnerType in [ShopifyOwnerType::PRODUCT, ShopifyOwnerType::PRODUCTVARIANT, ShopifyOwnerType::CUSTOMER]) then
            Error(UndefinedOwnerTypeErr, ShopifyOwnerType);
        Result := SelectStr(ShopifyOwnerType.AsInteger(), ShopifyOwnerTypesTxt);
    end;

    internal procedure OwnerTypeEnumValueName(OwnerType: Enum "NPR Spfy Metafield Owner Type") Result: Text
    begin
        OwnerType.Names().Get(OwnerType.Ordinals().IndexOf(OwnerType.AsInteger()), Result);
    end;

    internal procedure QueryingShopifyLbl(): Text
    var
        Lbl: Label 'Querying Shopify...';
    begin
        exit(Lbl);
    end;

}
#endif