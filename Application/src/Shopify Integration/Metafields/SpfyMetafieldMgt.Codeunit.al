#if not BC17
codeunit 6185065 "NPR Spfy Metafield Mgt."
{
    Access = Internal;

    var
        _TempSpfyMetafieldDef: Record "NPR Spfy Metafield Definition";
        _QueryingShopifyLbl: Label 'Querying Shopify...';
        _UnexpectedResponseErr: Label '%1. Shopify returned the following response:\%2', Comment = '%1 - Error descrition, %2 - Shopify returned response.';

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
        Item: Record Item;
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        DataLogMgt: Codeunit "NPR Data Log Management";
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

        //TODO: replace with an interface
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("No.", SpfyStoreItemLink."Item No.");
        if ItemAttributeValueMapping.FindSet() then
            repeat
                ProcessItemAttributeValueChange(ItemAttributeValueMapping, SpfyStoreItemLink."Shopify Store Code", false);
            until ItemAttributeValueMapping.Next() = 0;

        if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Item then begin
            Item.SetLoadFields("Item Category Code");
            if Item.Get(SpfyStoreItemLink."Item No.") then
                ProcessItemCategoryChange(Item, SpfyStoreItemLink."Shopify Store Code", false);
        end;
    end;

    internal procedure ProcessMetafieldMappingChange(var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; xMetafieldID: Text[30]; Removed: Boolean; Silent: Boolean)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        if (SpfyMetafieldMapping."Metafield ID" = '') and (xMetafieldID = '') then
            exit;
        if (SpfyMetafieldMapping."Metafield ID" = xMetafieldID) and not Removed then
            exit;
        if not (SpfyMetafieldMapping."BC Record ID".TableNo() in [Database::"NPR Spfy Store", Database::"Item Attribute"]) then
            exit;
        if (SpfyMetafieldMapping."Metafield ID" = '') and not Removed then
            Removed := true;

        SpfyEntityMetafield.SetRange("Owner Type", SpfyMetafieldMapping."Owner Type");
        SpfyEntityMetafield.SetRange("Metafield ID", xMetafieldID);
        SpfyEntityMetafield.SetRange("Table No.", Database::"NPR Spfy Store-Item Link");
        if Removed then begin
            if xMetafieldID <> '' then
                if not SpfyEntityMetafield.IsEmpty() then
                    SpfyEntityMetafield.DeleteAll();
            exit;
        end;

        //TODO: replace with an interface
        case SpfyMetafieldMapping."BC Record ID".TableNo() of
            Database::"NPR Spfy Store":
                ProcessItemCategoryMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed, Silent);

            Database::"Item Attribute":
                ProcessItemAttributeMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed, Silent);
        end;
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
        QueryTok: Label 'query GetMetafieldsSet { %1(id: "gid://shopify/%2/%3") { id title metafields(first: 250) { edges { node { id namespace key value compareDigest type definition { id }}}}}}', Locked = true;
    begin
        OwnerTypeTxt := GetOwnerTypeAsText(ShopifyOwnerType);
        RequestJson.Add('query', StrSubstNo(QueryTok, SpfyIntegrationMgt.LowerFirstLetter(OwnerTypeTxt), OwnerTypeTxt, ShopifyOwnerID));
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

        // Remove entity metafields and item attributes for which no Shopify metafield was returned
        Clear(SpfyEntityMetafieldParam);
        SpfyEntityMetafieldParam."BC Record ID" := EntityRecID;
        SpfyEntityMetafieldParam."Owner Type" := ShopifyOwnerType;

        SpfyMetafieldMapping.SetFilter("Metafield ID", '<>%1', '');
        SpfyMetafieldMapping.SetFilter("Table No.", '%1|%2', Database::"Item Attribute", Database::"NPR Spfy Store");
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

    local procedure DoBCMetafieldUpdate(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield"; OwnerNo: Code[20]): Boolean
    var
        ItemAttribute: Record "Item Attribute";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        //TODO: replace with an interface
        case SpfyMetafieldMapping."Table No." of
            Database::"NPR Spfy Store":
                begin
                    SetEntityMetafieldValue(SpfyEntityMetafieldParam, true, true);
                    //TODO: Do we need to update the item category on the item card?
                    exit(true);
                end;

            Database::"Item Attribute":
                begin
                    if OwnerNo = '' then
                        exit;
                    if not ItemAttribute.Get(SpfyMetafieldMapping."BC Record ID") then
                        exit;
                    SetEntityMetafieldValue(SpfyEntityMetafieldParam, true, true);
                    SetItemAttributeValue(ItemAttribute, OwnerNo, SpfyIntegrationMgt.GetLanguageCode(SpfyMetafieldMapping."Shopify Store Code"), SpfyEntityMetafieldParam.GetMetafieldValue(false));
                    exit(true);
                end;
        end;
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
            Window.Open(_QueryingShopifyLbl);

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

    internal procedure GetItemCategoryMetafieldDefinitionID(ShopifyStoreCode: Code[20]; WithDialog: Boolean; var ItemCategoryMetafieldID: Text[30])
    var
        Window: Dialog;
        MetaobjectDefinitionGID: Text;
    begin
        if WithDialog then
            WithDialog := GuiAllowed();
        if WithDialog then
            Window.Open(_QueryingShopifyLbl);

        MetaobjectDefinitionGID := GetMetaobjectDefinitionGID(ShopifyStoreCode);
        GetShopifyMetafieldDefinitions(ShopifyStoreCode, Enum::"NPR Spfy Metafield Owner Type"::PRODUCT, StrSubstNo('type:%1', MetaobjectReferenceShopifyMetafieldType()), false);
        _TempSpfyMetafieldDef.SetRange("Validation Definition GID", MetaobjectDefinitionGID);
        if ItemCategoryMetafieldID <> '' then begin
            _TempSpfyMetafieldDef.ID := ItemCategoryMetafieldID;
            if not _TempSpfyMetafieldDef.Find() then
                ItemCategoryMetafieldID := '';
        end;
        if ItemCategoryMetafieldID = '' then
            if _TempSpfyMetafieldDef.FindFirst() then
                ItemCategoryMetafieldID := _TempSpfyMetafieldDef.ID;
        ClearTempSpfyMetafieldDefinitions();

        if ItemCategoryMetafieldID = '' then
            ItemCategoryMetafieldID := CreateItemCategoryMetafieldDefinition(ShopifyStoreCode, MetaobjectDefinitionGID);
        if WithDialog then
            Window.Close();
    end;

    local procedure GetMetaobjectDefinitionGID(ShopifyStoreCode: Code[20]): Text
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        MetaobjectDefinition: JsonToken;
        ShopifyResponse: JsonToken;
        QueryStream: OutStream;
        MetaobjectDefinitionGID: Text;
        CouldNotGetMetaobjectDefinitionErr: Label 'Could not obtain metaobject definition from Shopify.';
        CouldNotCreateMetaobjectDefinitionErr: Label 'Could not create metaobject definition in Shopify.';
        CouldNotUpdateMetaobjectDefinitionErr: Label 'Could not update metaobject definition in Shopify.';
    begin
        ClearLastError();
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ItemCategoryShopifyMetaobjectDefinitionGetByTypeQuery(QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotGetMetaobjectDefinitionErr, GetLastErrorText());
        if ShopifyResponse.SelectToken('data.metaobjectDefinitionByType', MetaobjectDefinition) and MetaobjectDefinition.IsObject() then
            exit(JsonHelper.GetJText(MetaobjectDefinition, 'id', true));

        Clear(NcTask);
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ItemCategoryShopifyMetaobjectDefinitionCreateQuery(QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotCreateMetaobjectDefinitionErr, GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotCreateMetaobjectDefinitionErr, ShopifyResponse);
        if ShopifyResponse.SelectToken('data.metaobjectDefinitionCreate.metaobjectDefinition', MetaobjectDefinition) and MetaobjectDefinition.IsObject() then
            MetaobjectDefinitionGID := JsonHelper.GetJText(MetaobjectDefinition, 'id', true);
        if MetaobjectDefinitionGID = '' then
            Error(_UnexpectedResponseErr, CouldNotCreateMetaobjectDefinitionErr, ShopifyResponse);

        Clear(NcTask);
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ItemCategoryShopifyMetaobjectDefinitionUpdateQuery(MetaobjectDefinitionGID, QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotUpdateMetaobjectDefinitionErr, GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error(_UnexpectedResponseErr, CouldNotUpdateMetaobjectDefinitionErr, ShopifyResponse);
        exit(MetaobjectDefinitionGID);
    end;

    local procedure ItemCategoryShopifyMetaobjectDefinitionGetByTypeQuery(var QueryStream: OutStream)
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'query GetMetaobjectDefinition($type: String!){metaobjectDefinitionByType(type: $type){id}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .AddProperty('type', ItemCategoryShopifyMetaobjectType())
            .EndObject()
        .EndObject();

        JsonBuilder.Build().WriteTo(QueryStream);
    end;

    local procedure ItemCategoryShopifyMetaobjectDefinitionCreateQuery(var QueryStream: OutStream)
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation CreateMetaobjectDefinition($definition: MetaobjectDefinitionCreateInput!) {metaobjectDefinitionCreate(definition: $definition) {metaobjectDefinition{id} userErrors {field message code}}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .StartObject('definition')
                    .AddProperty('name', 'BC Item Category')
                    .AddProperty('description', 'The item category from Business Central')
                    .AddProperty('type', ItemCategoryShopifyMetaobjectType())
                    .AddProperty('displayNameKey', 'name')
                    .StartObject('access')
                        .AddProperty('admin', 'MERCHANT_READ_WRITE')
                        .AddProperty('storefront', 'PUBLIC_READ')
                    .EndObject()
                    .StartObject('capabilities')
                        .StartObject('publishable')
                            .AddProperty('enabled', true)
                        .EndObject()
                        .StartObject('translatable')
                            .AddProperty('enabled', true)
                        .EndObject()
                    .EndObject()
                    .StartArray('fieldDefinitions')
                        .StartObject()
                            .AddProperty('key', 'category_id')
                            .AddProperty('name', 'UID')
                            .AddProperty('description', 'BC item category unique ID')
                            .AddProperty('type', 'single_line_text_field')
                            .AddProperty('required', true)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'name')
                            .AddProperty('name', 'Name')
                            .AddProperty('description', 'BC item category name')
                            .AddProperty('type', 'single_line_text_field')
                            .AddProperty('required', true)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'description')
                            .AddProperty('name', 'Description')
                            .AddProperty('description', 'BC item category detailed description')
                            .AddProperty('type', 'multi_line_text_field')
                            .AddProperty('required', false)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'position')
                            .AddProperty('name', 'Position')
                            .AddProperty('description', 'Position of the BC item category in the list')
                            .AddProperty('type', 'number_integer')
                            .AddProperty('required', true)
                            .StartArray('validations')
                                .StartObject()
                                    .AddProperty('name', 'min')
                                    .AddProperty('value', '1')
                                .EndObject()
                            .EndArray()
                        .EndObject()
                    .EndArray()
                .EndObject()
            .EndObject()
        .EndObject();

        JsonBuilder.Build().WriteTo(QueryStream);
    end;

    local procedure ItemCategoryShopifyMetaobjectDefinitionUpdateQuery(MetaobjectDefinitionGID: Text; var QueryStream: OutStream)
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation UpdateMetaobjectDefinition($id: ID!, $definition: MetaobjectDefinitionUpdateInput!) {metaobjectDefinitionUpdate(id: $id, definition : $definition) {metaobjectDefinition{id} userErrors {field message code}}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .AddProperty('id', MetaobjectDefinitionGID)
                .StartObject('definition')
                    .StartArray('fieldDefinitions')
                        .StartObject()
                            .StartObject('create')
                                .AddProperty('key', 'parent_id')
                                .AddProperty('name', 'Parent ID')
                                .AddProperty('description', 'ID of the parent BC item category')
                                .AddProperty('type', 'metaobject_reference')
                                .AddProperty('required', false)
                                .StartArray('validations')
                                    .StartObject()
                                        .AddProperty('name', 'metaobject_definition_id')
                                        .AddProperty('value', MetaobjectDefinitionGID)
                                    .EndObject()
                                .EndArray()
                            .EndObject()
                        .EndObject()
                    .EndArray()
                .EndObject()
            .EndObject()
        .EndObject();

        JsonBuilder.Build().WriteTo(QueryStream);
    end;

    local procedure CreateItemCategoryMetafieldDefinition(ShopifyStoreCode: Code[20]; MetaobjectDefinitionGID: Text) NewMetafieldID: Text[30]
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
        ItemCategoryShopifyMetafieldDefinitionCreateQuery(MetaobjectDefinitionGID, QueryStream);
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

    local procedure ItemCategoryShopifyMetafieldDefinitionCreateQuery(MetaobjectDefinitionGID: Text; var QueryStream: OutStream)
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation CreateMetafieldDefinition($definition: MetafieldDefinitionInput!) {metafieldDefinitionCreate(definition: $definition) {createdDefinition {id name} userErrors {field message code}}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .StartObject('definition')
                    .AddProperty('name', 'BC Item Category')
                    .AddProperty('description', 'Item categories from Business Central')
                    .AddProperty('namespace', '$app')
                    .AddProperty('key', 'bc_item_category')
                    .AddProperty('type', MetaobjectReferenceShopifyMetafieldType())
                    .AddProperty('ownerType', OwnerTypeEnumValueName(Enum::"NPR Spfy Metafield Owner Type"::PRODUCT))
                    .AddProperty('pin', true)
                    .StartArray('validations')
                        .StartObject()
                            .AddProperty('name', 'metaobject_definition_id')
                            .AddProperty('value', MetaobjectDefinitionGID)
                        .EndObject()
                    .EndArray()
                    .StartObject('access')
                        .AddProperty('admin', 'MERCHANT_READ_WRITE')
                        .AddProperty('storefront', 'PUBLIC_READ')
                        .AddProperty('customerAccount', 'READ')
                    .EndObject()
                    .StartObject('capabilities')
                        .StartObject('smartCollectionCondition')
                            .AddProperty('enabled', true)
                        .EndObject()
                        .StartObject('adminFilterable')
                            .AddProperty('enabled', true)
                        .EndObject()
                    .EndObject()
                .EndObject()
            .EndObject()
        .EndObject();

        JsonBuilder.Build().WriteTo(QueryStream);
    end;

    internal procedure SyncItemCategories(var ItemCategory: Record "Item Category"; var ShopifyStore: Record "NPR Spfy Store"; ResyncExisting: Boolean; Silent: Boolean)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SyncedCategories: List of [Code[20]];
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        IntegrationNotEnabledMsg: Label 'Item category integration has not been enabled for Shopify store "%1". The sync process has been skipped for this store.', Comment = '%1 - Shopify store code';
        NothingToDoErr: Label 'The supplied filters do not include any item categories or Shopify stores.\Shopify store filters: %1.\Item category filters: %2.', Comment = '%1 - Shopify store table filters, %2 - Item category table filters';
        SuccessMsg: Label 'Item category synchronization completed successfully.\Shopify store filters: %1.\Item category filters: %2.', Comment = '%1 - Shopify store table filters, %2 - Item category table filters';
        WindowTxt01: Label 'Sending item categories to Shopify...\\';
        WindowTxt02: Label 'Shopify Store #1#######\';
        WindowTxt03: Label 'Progress      @2@@@@@@@';
    begin
        if ItemCategory.IsEmpty() or ShopifyStore.IsEmpty() then
            Error(NothingToDoErr, ShopifyStore.GetFilters(), ItemCategory.GetFilters());
        if not Silent then begin
            Window.Open(WindowTxt01 + WindowTxt02 + WindowTxt03);
            TotalRecNo := ItemCategory.Count();
        end;

        ShopifyStore.SetLoadFields(Code);
        ShopifyStore.FindSet();
        repeat
            if not Silent then begin
                Window.Update(1, ShopifyStore.Code);
                Window.Update(2, 0);
                RecNo := 0;
            end;

            if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", ShopifyStore.Code) then begin
                Clear(SyncedCategories);
                ItemCategory.FindSet();
                repeat
                    SyncItemCategory(ItemCategory, ShopifyStore.Code, ResyncExisting, 1, SyncedCategories);
                    Commit();
                    if not Silent then begin
                        RecNo += 1;
                        Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                    end;
                until ItemCategory.Next() = 0;
            end else
                if not Silent then
                    Message(IntegrationNotEnabledMsg, ShopifyStore.Code);
        until ShopifyStore.Next() = 0;

        if not Silent then begin
            Window.Close();
            Message(SuccessMsg, ShopifyStore.GetFilters(), ItemCategory.GetFilters());
        end;
    end;

    local procedure SyncItemCategory(ItemCategory: Record "Item Category"; ShopifyStoreCode: Code[20]; ResyncExisting: Boolean; CallLevel: Integer; var SyncedCategories: List of [Code[20]])
    var
        ParentItemCategory: Record "Item Category";
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SyncRec: Boolean;
        PossibleCircularReferenceErr: Label 'The number of parent category levels reached 50 at the item category "%1". Further processing has been stopped due to a possible circular reference.', Comment = '%1 - Item category code';
    begin
        if SyncedCategories.Contains(ItemCategory.Code) then
            exit;
        SyncedCategories.Add(ItemCategory.Code);

        if ItemCategory."Parent Category" <> '' then begin
            if CallLevel >= 50 then
                Error(PossibleCircularReferenceErr, ItemCategory.Code);
            ParentItemCategory.Get(ItemCategory."Parent Category");
            SyncItemCategory(ParentItemCategory, ShopifyStoreCode, ResyncExisting, CallLevel + 1, SyncedCategories);
        end;

        SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
        SpfyStoreItemCatLink."Shopify Store Code" := ShopifyStoreCode;
        if not ResyncExisting then
            SyncRec := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") = '';
        if SyncRec or ResyncExisting then
            UpsertItemCategoryMetaobject(ItemCategory, ShopifyStoreCode);
    end;

    local procedure UpsertItemCategoryMetaobject(ItemCategory: Record "Item Category"; ShopifyStoreCode: Code[20]) MetaobjectValueID: Text[30]
    var
        NcTask: Record "NPR Nc Task";
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        QueryStream: OutStream;
        MetafieldDefinition: JsonToken;
        ShopifyResponse: JsonToken;
        CouldNotUpsertMetaobjectErr: Label 'Could not upsert item category "%1" metaobject in Shopify store "%2".', Comment = '%1 - Item category code, %2 - Shopify store code';
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ItemCategoryShopifyMetaobjectUpsertQuery(ItemCategory, ShopifyStoreCode, QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(_UnexpectedResponseErr, StrSubstNo(CouldNotUpsertMetaobjectErr, ItemCategory.Code, ShopifyStoreCode), GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error(_UnexpectedResponseErr, StrSubstNo(CouldNotUpsertMetaobjectErr, ItemCategory.Code, ShopifyStoreCode), ShopifyResponse);
        if ShopifyResponse.SelectToken('data.metaobjectUpsert.metaobject', MetafieldDefinition) and MetafieldDefinition.IsObject() then
#pragma warning disable AA0139
            MetaobjectValueID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(MetafieldDefinition, 'id', true), '/');
#pragma warning restore AA0139
        if MetaobjectValueID = '' then
            Error(_UnexpectedResponseErr, StrSubstNo(CouldNotUpsertMetaobjectErr, ItemCategory.Code, ShopifyStoreCode), ShopifyResponse);

        SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
        SpfyStoreItemCatLink."Shopify Store Code" := ShopifyStoreCode;
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", MetaobjectValueID, false);
    end;

    local procedure ItemCategoryShopifyMetaobjectUpsertQuery(ItemCategory: Record "Item Category"; ShopifyStoreCode: Code[20]; var QueryStream: OutStream)
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation metaobjectUpsert($handle: MetaobjectHandleInput!, $metaobject: MetaobjectUpsertInput!) {metaobjectUpsert(handle: $handle, metaobject: $metaobject) {metaobject {id handle} userErrors {field message code}}}', Locked = true;
    begin
        if ItemCategory."Presentation Order" < 1 then
            ItemCategory."Presentation Order" := 1;

        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .StartObject('handle')
                    .AddProperty('type', ItemCategoryShopifyMetaobjectType())
                    .AddProperty('handle', CalculateItemCategoryHandle(ItemCategory))
                .EndObject()
                .StartObject('metaobject')
                    .StartArray('fields')
                        .StartObject()
                            .AddProperty('key', 'category_id')
                            .AddProperty('value', ItemCategory.Code)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'name')
                            .AddProperty('value', StrSubstNo('%1:%2', ItemCategory.Code, ItemCategory.Description))
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'description')
                            .AddProperty('value', ItemCategory.Description)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'position')
                            .AddProperty('value', Format(ItemCategory."Presentation Order", 0, 9))
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'parent_id')
                            .AddProperty('value', ItemCategory.NPRGetSpfyParentGID(ShopifyStoreCode))
                        .EndObject()
                    .EndArray()
                    .StartObject('capabilities')
                        .StartObject('publishable')
                            .AddProperty('status', 'ACTIVE')
                        .EndObject()
                    .EndObject()
                .EndObject()
            .EndObject()
        .EndObject();

        JsonBuilder.Build().WriteTo(QueryStream);
    end;

    local procedure CalculateItemCategoryHandle(ItemCategory: Record "Item Category") Handle: Text
    begin
        Handle := '';
        if ItemCategory.Code = '' then
            exit;
        repeat
            if ItemCategory."NPR Spfy Handle" = '' then begin
                ItemCategory."NPR Spfy Handle" := LowerCase(ItemCategory.Code);
                ItemCategory.Modify(true);
            end;
            if Handle <> '' then
                Handle := '-' + Handle;
            Handle := ItemCategory."NPR Spfy Handle" + Handle;
            ItemCategory.Mark(true);  //prevent infinite loop
        until not ItemCategory.Get(ItemCategory."Parent Category") or ItemCategory.Mark();
    end;

    local procedure ItemCategoryShopifyMetaobjectType(): Text
    begin
        exit('$app:bc-item-category');
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

    local procedure ProcessItemAttributeMetafieldMappingChange(var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean; Silent: Boolean)
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        LinkRegenerationCnf: Label 'The item attribute has already been mapped to one or more items. Changing the Shopify metafield ID may require recreating the links between BC item attributes and Shopify product metafields. This can take a significant amount of time. Are you sure you want to continue?';
    begin
        ItemAttribute.Get(SpfyMetafieldMapping."BC Record ID");
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("Item Attribute ID", ItemAttribute.ID);
        if ItemAttributeValueMapping.IsEmpty() then begin
            if xMetafieldID <> '' then
                if not SpfyEntityMetafield.IsEmpty() then
                    SpfyEntityMetafield.DeleteAll();
            exit;
        end;

        if not Silent then
            if not Confirm(LinkRegenerationCnf, true) then
                Error('');

        SpfyMetafieldMapping.Modify(true);

        if xMetafieldID <> '' then
            if not SpfyEntityMetafield.IsEmpty() then begin
                SpfyEntityMetafield.ModifyAll("Metafield Key", '');
                SpfyEntityMetafield.ModifyAll("Metafield Value Version ID", '');
                SpfyEntityMetafield.ModifyAll("Metafield ID", SpfyMetafieldMapping."Metafield ID");
            end;

        ItemAttributeValueMapping.FindSet();
        repeat
            ProcessItemAttributeValueChange(ItemAttributeValueMapping, '', Removed);
        until ItemAttributeValueMapping.Next() = 0;
    end;

    local procedure ProcessItemAttributeValueChange(ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyMetafieldValue: Text;
        ValueAsInteger: Integer;
    begin
        if not (ItemAttributeValueMapping."Table ID" in [Database::Item]) then
            exit;
        ItemAttribute.ID := ItemAttributeValueMapping."Item Attribute ID";
        FilterMetafieldMapping(ItemAttribute.RecordId(), 0, ShopifyStoreCode, SpfyMetafieldMapping."Owner Type"::" ", SpfyMetafieldMapping);
        if SpfyMetafieldMapping.IsEmpty() then
            exit;
        ItemAttribute.Find();
        SpfyMetafieldMapping.FindSet();
        repeat
            if SendItemAndInventory.GetStoreItemLink(ItemAttributeValueMapping."No.", SpfyMetafieldMapping."Shopify Store Code", false, SpfyStoreItemLink) then begin
                if Removed then
                    ShopifyMetafieldValue := ''
                else
                    if ItemAttributeValueMapping."Item Attribute Value ID" <> 0 then begin
                        ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
                        case ItemAttribute.Type of
                            ItemAttribute.Type::Date:
                                ShopifyMetafieldValue := Format(ItemAttributeValue."Date Value", 0, 9);
                            ItemAttribute.Type::Decimal:
                                if ItemAttributeValue.Value <> '' then
                                    ShopifyMetafieldValue := Format(ItemAttributeValue."Numeric Value", 0, 9);
                            ItemAttribute.Type::Integer:
                                if ItemAttributeValue.Value <> '' then
                                    if Evaluate(ValueAsInteger, ItemAttributeValue.Value) then
                                        ShopifyMetafieldValue := Format(ValueAsInteger, 0, 9);
                            else
                                ShopifyMetafieldValue := ItemAttributeValue.GetTranslatedNameByLanguageCode(SpfyIntegrationMgt.GetLanguageCode(SpfyStoreItemLink."Shopify Store Code"));
                        end;
                        if ShopifyMetafieldValue = '' then
                            ShopifyMetafieldValue := ItemAttributeValue.Value;
                    end else
                        ShopifyMetafieldValue := '';

                SpfyEntityMetafieldParam."BC Record ID" := SpfyStoreItemLink.RecordId();
                SpfyEntityMetafieldParam."Owner Type" := SpfyMetafieldMapping."Owner Type";
                SpfyEntityMetafieldParam."Metafield ID" := SpfyMetafieldMapping."Metafield ID";
                SpfyEntityMetafieldParam.SetMetafieldValue(ShopifyMetafieldValue);
                SetEntityMetafieldValue(SpfyEntityMetafieldParam, false, false);
            end;
        until SpfyMetafieldMapping.Next() = 0;
    end;

    local procedure ProcessItemCategoryMetafieldMappingChange(var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean; Silent: Boolean)
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        LinkRegenerationCnf: Label 'Changing the Shopify metafield ID may require recreating the links between BC item categories and Shopify product metafields. This can take a significant amount of time. Are you sure you want to continue?';
    begin
        if not Silent then
            if not Confirm(LinkRegenerationCnf, true) then
                Error('');

        ShopifyAssignedID.SetRange("Table No.", Database::"NPR Spfy Store-Item Cat. Link");
        ShopifyAssignedID.SetRange("Shopify ID Type", "NPR Spfy ID Type"::"Entry ID");
        if not ShopifyAssignedID.IsEmpty() then begin
            ItemCategory.SetLoadFields(Code);
            if ItemCategory.FindSet() then
                repeat
                    SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
                    SpfyStoreItemCatLink."Shopify Store Code" := SpfyMetafieldMapping."Shopify Store Code";
                    SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                until ItemCategory.Next() = 0;
        end;

        Item.SetFilter("Item Category Code", '<>%1', '');
        if Item.IsEmpty() then begin
            if xMetafieldID <> '' then
                if not SpfyEntityMetafield.IsEmpty() then
                    SpfyEntityMetafield.DeleteAll();
            exit;
        end;

        SpfyMetafieldMapping.Modify(true);

        if xMetafieldID <> '' then
            if not SpfyEntityMetafield.IsEmpty() then begin
                SpfyEntityMetafield.ModifyAll("Metafield Key", '');
                SpfyEntityMetafield.ModifyAll("Metafield Value Version ID", '');
                SpfyEntityMetafield.ModifyAll("Metafield ID", SpfyMetafieldMapping."Metafield ID");
            end;

        Item.FindSet();
        repeat
            ProcessItemCategoryChange(Item, '', Removed);
        until Item.Next() = 0;
    end;

    local procedure ProcessItemCategoryChange(Item: Record Item; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyMetafieldValue: Text;
    begin
        FilterMetafieldMapping(Database::"NPR Spfy Store", SpfyStore.FieldNo("Item Category as Metafield"), ShopifyStoreCode, SpfyMetafieldMapping."Owner Type"::PRODUCT, SpfyMetafieldMapping);
        if SpfyMetafieldMapping.IsEmpty() then
            exit;
        SpfyMetafieldMapping.FindSet();
        repeat
            if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyMetafieldMapping."Shopify Store Code") then begin
                if SendItemAndInventory.GetStoreItemLink(Item."No.", SpfyMetafieldMapping."Shopify Store Code", false, SpfyStoreItemLink) then begin
                    if Removed then
                        ShopifyMetafieldValue := ''
                    else
                        GenerateItemCategoryMetafieldValueArray(Item."Item Category Code", SpfyMetafieldMapping."Shopify Store Code").WriteTo(ShopifyMetafieldValue);

                    SpfyEntityMetafieldParam."BC Record ID" := SpfyStoreItemLink.RecordId();
                    SpfyEntityMetafieldParam."Owner Type" := SpfyMetafieldMapping."Owner Type";
                    SpfyEntityMetafieldParam."Metafield ID" := SpfyMetafieldMapping."Metafield ID";
                    SpfyEntityMetafieldParam.SetMetafieldValue(ShopifyMetafieldValue);
                    SetEntityMetafieldValue(SpfyEntityMetafieldParam, false, false);
                end;
            end;
        until SpfyMetafieldMapping.Next() = 0;
    end;

    local procedure GenerateItemCategoryMetafieldValueArray(ItemCategoryCode: Code[20]; ShopifyStoreCode: Code[20]) ItemCategories: JsonArray
    var
        ItemCategory: Record "Item Category";
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        AssignedID: Text[30];
        NoIDAssignedErr: Label 'No Shopify metaobject ID has been assigned to the item category %1 from Shopify store %2. Please ensure that the item category has been synchronized with the Shopify store.', Comment = '%1 - item category code, %2 - Shopify store code';
    begin
        ItemCategories.ReadFrom('[]');
        if ItemCategoryCode = '' then
            exit;
        if not ItemCategory.Get(ItemCategoryCode) then
            exit;
        repeat
            SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
            SpfyStoreItemCatLink."Shopify Store Code" := ShopifyStoreCode;
            AssignedID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
            If AssignedID = '' then
                AssignedID := UpsertItemCategoryMetaobject(ItemCategory, ShopifyStoreCode);
            If AssignedID = '' then
                Error(NoIDAssignedErr, ItemCategory.Code, ShopifyStoreCode);
            ItemCategories.Add(StrSubstNo('gid://shopify/Metaobject/%1', AssignedID));
            ItemCategory.Mark(true);  //prevent infinite loop
        until not ItemCategory.Get(ItemCategory."Parent Category") or ItemCategory.Mark();
    end;

    local procedure SetEntityMetafieldValue(Params: Record "NPR Spfy Entity Metafield"; DeleteEmpty: Boolean; DisableDataLog: Boolean)
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

    internal procedure SetItemAttributeValue(ItemAttribute: Record "Item Attribute"; ItemNo: Code[20]; LanguageCode: Code[10]; NewAttributeValueTxt: Text)
    var
        ItemAttributeValue: Record "Item Attribute Value";
        xItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttrValueTranslation: Record "Item Attr. Value Translation";
        TempItemAttributeValueSelection: Record "Item Attribute Value Selection" temporary;
        IntegerValue: Integer;
        DecimalValue: Decimal;
        DateValue: Date;
        NewAttributeValueFilter: Text;
        ItemAttribValueFound: Boolean;
        xItemAttribValueFound: Boolean;
        ItemAttribValueMappingExists: Boolean;
    begin
        ItemAttributeValueMapping."Table ID" := Database::Item;
        ItemAttributeValueMapping."No." := ItemNo;
        ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
        ItemAttribValueMappingExists := ItemAttributeValueMapping.Find();
        if ItemAttribValueMappingExists then begin
            xItemAttribValueFound := xItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
        end else begin
            if NewAttributeValueTxt = '' then
                exit;
            ItemAttributeValueMapping.Init();
        end;

        if NewAttributeValueTxt <> '' then begin
            TempItemAttributeValueSelection."Attribute ID" := ItemAttribute.ID;
            TempItemAttributeValueSelection."Attribute Name" := ItemAttribute.Name;
            TempItemAttributeValueSelection."Attribute Type" := ItemAttribute.Type;
            TempItemAttributeValueSelection."Unit of Measure" := ItemAttribute."Unit of Measure";
            TempItemAttributeValueSelection."Inherited-From Table ID" := Database::Item;
            TempItemAttributeValueSelection."Inherited-From Key Value" := ItemNo;

#if not (BC18 or BC19 or BC20 or BC21)
            ItemAttributeValue.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
            case ItemAttribute.Type of
                ItemAttribute.Type::Date:
                    if Evaluate(DateValue, NewAttributeValueTxt, 9) then begin
                        NewAttributeValueTxt := Format(DateValue);
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetRange("Date Value", DateValue);
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end else
                        NewAttributeValueTxt := '';
                ItemAttribute.Type::Decimal:
                    if Evaluate(DecimalValue, NewAttributeValueTxt, 9) then begin
                        NewAttributeValueTxt := Format(DecimalValue);
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetRange("Numeric Value", DecimalValue);
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end else
                        NewAttributeValueTxt := '';
                ItemAttribute.Type::Integer:
                    if Evaluate(IntegerValue, NewAttributeValueTxt, 9) then begin
                        NewAttributeValueTxt := Format(IntegerValue);
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetRange("Numeric Value", DecimalValue);
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end else
                        NewAttributeValueTxt := '';
                else begin
                    NewAttributeValueFilter := NewAttributeValueTxt.Replace('''', '?');
#if not (BC18 or BC19 or BC20 or BC21)
                    ItemAttrValueTranslation.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
                    ItemAttrValueTranslation.SetRange("Attribute ID", ItemAttribute.ID);
                    ItemAttrValueTranslation.SetRange("Language Code", LanguageCode);
                    ItemAttrValueTranslation.SetFilter(Name, StrSubstNo('''%1''', NewAttributeValueFilter));
                    if ItemAttrValueTranslation.IsEmpty() then
                        ItemAttrValueTranslation.SetFilter(Name, StrSubstNo('''@%1''', NewAttributeValueFilter));
                    if ItemAttrValueTranslation.FindFirst() then
                        ItemAttribValueFound := ItemAttributeValue.Get(ItemAttrValueTranslation."Attribute ID", ItemAttrValueTranslation.ID)
                    else begin
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetFilter(Value, StrSubstNo('''%1''', NewAttributeValueFilter));
                        if ItemAttributeValue.IsEmpty() then
                            ItemAttributeValue.SetFilter(Value, StrSubstNo('''@%1''', NewAttributeValueFilter));
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end;
                end;
            end;
        end;
        if not ItemAttribValueFound then begin
            if NewAttributeValueTxt = '' then begin
                if ItemAttribValueMappingExists then begin
                    ItemAttributeValueMapping.Delete();
                    if xItemAttribValueFound then
                        if not xItemAttributeValue.HasBeenUsed() then
                            xItemAttributeValue.Delete();
                end;
                exit;
            end;
            TempItemAttributeValueSelection.Value := CopyStr(NewAttributeValueTxt, 1, MaxStrLen(TempItemAttributeValueSelection.Value));
            if not TempItemAttributeValueSelection.FindAttributeValue(ItemAttributeValue) then
                TempItemAttributeValueSelection.InsertItemAttributeValue(ItemAttributeValue, TempItemAttributeValueSelection);
        end;
        if ItemAttribValueMappingExists and (ItemAttributeValueMapping."Item Attribute Value ID" = ItemAttributeValue.ID) then
            exit;
        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
        if not ItemAttribValueMappingExists then
            ItemAttributeValueMapping.Insert()
        else
            ItemAttributeValueMapping.Modify();
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
        ShopifyOwnerTypesTxt: Label 'Product,ProductVariant', Locked = true;
        UndefinedOwnerTypeErr: Label 'Shopify metafield owner type was not set or is not supported (owner type = "%1"). This is a programming bug, not a user error. Please contact system vendor.';
    begin
        SpfyMetafieldMgtPublic.OnGetOwnerTypeAsText(ShopifyOwnerType, Result, Handled);
        if Handled then
            exit;
        if not (ShopifyOwnerType in [ShopifyOwnerType::PRODUCT, ShopifyOwnerType::PRODUCTVARIANT]) then
            Error(UndefinedOwnerTypeErr, ShopifyOwnerType);
        Result := SelectStr(ShopifyOwnerType.AsInteger(), ShopifyOwnerTypesTxt);
    end;

    local procedure OwnerTypeEnumValueName(OwnerType: Enum "NPR Spfy Metafield Owner Type") Result: Text
    begin
        OwnerType.Names().Get(OwnerType.Ordinals().IndexOf(OwnerType.AsInteger()), Result);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnItemAttributeMappingAssign(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessItemAttributeValueChange(Rec, '', false);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnItemAttributeMappingChange(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessItemAttributeValueChange(Rec, '', false);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnItemAttributeMappingRemove(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessItemAttributeValueChange(Rec, '', true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure DeleteMetafieldMappings(var Rec: Record "Item Attribute"; RunTrigger: Boolean)
    var
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        SpfyMetafieldMapping.SetRange("Table No.", Database::"Item Attribute");
        SpfyMetafieldMapping.SetRange("BC Record ID", Rec.RecordId());
        if not SpfyMetafieldMapping.IsEmpty() then
            SpfyMetafieldMapping.DeleteAll(true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure RefreshxRec(var Rec: Record Item; var xRec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;

#if not (BC18 or BC19 or BC20 or BC21)
        xRec.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        if not xRec.Find() then
            Clear(xRec);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterModifyEvent, '', false, false)]
#endif
    local procedure RecalcItemCategoryMetafieldValueOnItemModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Item Category Code" = xRec."Item Category Code" then
            exit;
        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Item No.", Rec."No.");
        if not SpfyStoreItemLink.FindSet() then
            exit;
        repeat
            ProcessItemCategoryChange(Rec, SpfyStoreItemLink."Shopify Store Code", Rec."Item Category Code" = '');
        until SpfyStoreItemLink.Next() = 0;
    end;
}
#endif