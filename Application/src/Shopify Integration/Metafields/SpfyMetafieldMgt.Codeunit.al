#if not BC17
codeunit 6185065 "NPR Spfy Metafield Mgt."
{
    Access = Internal;

    var
        _TempSpfyMetafieldDef: Record "NPR Spfy Metafield Definition";

    internal procedure SelectShopifyMetafield(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var SelectedMetafieldID: Text[30]): Boolean
    begin
        GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, true);
        if SelectedMetafieldID <> '' then begin
            _TempSpfyMetafieldDef.ID := SelectedMetafieldID;
            if _TempSpfyMetafieldDef.Find('=><') then;
        end;
        if Page.RunModal(Page::"NPR Spfy Metafields", _TempSpfyMetafieldDef) = Action::LookupOK then begin
            SelectedMetafieldID := _TempSpfyMetafieldDef.ID;
            exit(true);
        end;
        exit(false);
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

        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("No.", SpfyStoreItemLink."Item No.");
        if ItemAttributeValueMapping.FindSet() then
            repeat
                ProcessItemAttributeMappingChange(ItemAttributeValueMapping, SpfyStoreItemLink."Shopify Store Code", false);
            until ItemAttributeValueMapping.Next() = 0;
    end;

    internal procedure ProcessMetafieldMappingChange(var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; xMetafieldID: Text[30]; Removed: Boolean; Silent: Boolean)
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        LinkRegenerationCnf: Label 'The item attribute has already been mapped to one or more items. Changing the Shopify metafield ID may require recreating the links between BC item attributes and Shopify product metafields. This can take a significant amount of time. Are you sure you want to continue?';
    begin
        if (SpfyMetafieldMapping."Metafield ID" = '') and (xMetafieldID = '') then
            exit;
        if (SpfyMetafieldMapping."Metafield ID" = xMetafieldID) and not Removed then
            exit;
        if SpfyMetafieldMapping."BC Record ID".TableNo() <> Database::"Item Attribute" then
            exit;  // only item attribute based metafields are currently supported
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

        if xMetafieldID <> '' then begin
            if not SpfyEntityMetafield.IsEmpty() then begin
                SpfyEntityMetafield.ModifyAll("Metafield Key", '');
                SpfyEntityMetafield.ModifyAll("Metafield Value Version ID", '');
                SpfyEntityMetafield.ModifyAll("Metafield ID", SpfyMetafieldMapping."Metafield ID");
            end;
        end;

        ItemAttributeValueMapping.FindSet();
        repeat
            ProcessItemAttributeMappingChange(ItemAttributeValueMapping, '', Removed);
        until ItemAttributeValueMapping.Next() = 0;
    end;

    internal procedure ShopifyEntityMetafieldValueUpdateQuery(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20]; var QueryStream: OutStream) SendToShopify: Boolean
    var
        MetafieldsSet: JsonObject;
        RequestJson: JsonObject;
        QueryTok: Label 'mutation MetafieldsSet($metafields: [MetafieldsSetInput!]!) { metafieldsSet(metafields: $metafields) { metafields { id key namespace value compareDigest definition { id }} userErrors { field message code }}}', Locked = true;
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
                UpdateBCMetafieldData(EntityRecID, ShopifyOwnerType, MetafieldsSet);
    end;

    internal procedure UpdateBCMetafieldData(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; MetafieldsSet: JsonToken)
    var
        ItemAttribute: Record "Item Attribute";
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        MappedToRecRef: RecordRef;
        RecRef: RecordRef;
        Metafield: JsonToken;
        ItemNo: Code[20];
    begin
        if not MetafieldsSet.IsArray() then
            exit;
        RecRef := EntityRecID.GetRecord();
        case RecRef.Number() of
            Database::"NPR Spfy Store-Item Link":
                begin
                    RecRef.SetTable(SpfyStoreItemLink);
                    SpfyMetafieldMapping.SetRange("Shopify Store Code", SpfyStoreItemLink."Shopify Store Code");
                    ItemNo := SpfyStoreItemLink."Item No.";
                end;
            else
                exit;
        end;

        SpfyEntityMetafieldParam."BC Record ID" := EntityRecID;
        SpfyEntityMetafieldParam."Owner Type" := ShopifyOwnerType;

        foreach Metafield in MetafieldsSet.AsArray() do begin
            if Metafield.AsObject().Contains('node') then
                Metafield.SelectToken('node', Metafield);
            SpfyEntityMetafieldParam."Metafield ID" := CopyStr(SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(Metafield, 'definition.id', true), '/'), 1, MaxStrLen(SpfyEntityMetafieldParam."Metafield ID"));
            SpfyEntityMetafieldParam."Metafield Key" := CopyStr(JsonHelper.GetJText(Metafield, 'key', false), 1, MaxStrLen(SpfyEntityMetafieldParam."Metafield Key"));
            SpfyEntityMetafieldParam."Metafield Value" := CopyStr(JsonHelper.GetJText(Metafield, 'value', false), 1, MaxStrLen(SpfyEntityMetafieldParam."Metafield Value"));
            SpfyEntityMetafieldParam."Metafield Value Version ID" := CopyStr(JsonHelper.GetJText(Metafield, 'compareDigest', false), 1, MaxStrLen(SpfyEntityMetafieldParam."Metafield Value Version ID"));

            SpfyMetafieldMapping.SetRange("Owner Type", SpfyEntityMetafieldParam."Owner Type");
            SpfyMetafieldMapping.SetRange("Metafield ID", SpfyEntityMetafieldParam."Metafield ID");
            if SpfyMetafieldMapping.FindFirst() then begin
                case SpfyMetafieldMapping."Table No." of
                    Database::"Item Attribute":
                        if MappedToRecRef.Get(SpfyMetafieldMapping."BC Record ID") then begin
                            MappedToRecRef.SetTable(ItemAttribute);
                            if ItemNo <> '' then begin
                                SetEntityMetafieldValue(SpfyEntityMetafieldParam, true, true);
                                SetItemAttributeValue(ItemAttribute, ItemNo, SpfyIntegrationMgt.GetLanguageCode(SpfyMetafieldMapping."Shopify Store Code"), SpfyEntityMetafieldParam."Metafield Value");
                            end;
                        end;
                end;
            end;
        end;
    end;

    local procedure GetShopifyMetafieldDefinitions(ShopifyStoreCode: Code[20]; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; WithDialog: Boolean)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ReceivedShopifyMetafields: JsonArray;
        ReceivedShopifyMetafield: JsonToken;
        ShopifyResponse: JsonToken;
        Window: Dialog;
        QueryingShopifyLbl: Label 'Querying Shopify...';
        CouldNotGetMetafieldDefinitionsErr: Label 'Could not get metafield definitions from Shopify. The following error occured: %1', Comment = '%1 - Shopify returned error text.';
    begin
        _TempSpfyMetafieldDef.DeleteAll();
        if WithDialog then
            WithDialog := GuiAllowed;
        if WithDialog then
            Window.Open(QueryingShopifyLbl);
        ClearLastError();
        if not GetShopifyMetafieldDefinitions(ShopifyStoreCode, ShopifyOwnerType, ShopifyResponse) then
            Error(CouldNotGetMetafieldDefinitionsErr, GetLastErrorText());
        ShopifyResponse.SelectToken('data.metafieldDefinitions.edges', ShopifyResponse);
        ReceivedShopifyMetafields := ShopifyResponse.AsArray();
        foreach ReceivedShopifyMetafield in ReceivedShopifyMetafields do begin
            _TempSpfyMetafieldDef.Init();
            _TempSpfyMetafieldDef.ID := CopyStr(SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.id', true), '/'), 1, MaxStrLen(_TempSpfyMetafieldDef.ID));
            if not _TempSpfyMetafieldDef.Find() then begin
#pragma warning disable AA0139
                _TempSpfyMetafieldDef."Key" := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.key', MaxStrLen(_TempSpfyMetafieldDef."Key"), true);
                _TempSpfyMetafieldDef.Name := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.name', MaxStrLen(_TempSpfyMetafieldDef.Name), false);
                _TempSpfyMetafieldDef.Type := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.type.name', MaxStrLen(_TempSpfyMetafieldDef.Type), false);
                _TempSpfyMetafieldDef.Description := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.description', MaxStrLen(_TempSpfyMetafieldDef.Description), false);
                _TempSpfyMetafieldDef.Namespace := JsonHelper.GetJText(ReceivedShopifyMetafield, 'node.namespace', MaxStrLen(_TempSpfyMetafieldDef.Namespace), true);
#pragma warning restore AA0139
                _TempSpfyMetafieldDef."Owner Type" := ShopifyOwnerType;
                _TempSpfyMetafieldDef.Insert();
            end;
        end;
        if WithDialog then
            Window.Close();
    end;

    local procedure GetShopifyMetafieldDefinitions(ShopifyStoreCode: Code[20]; OwnerType: Enum "NPR Spfy Metafield Owner Type"; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        RequestJson: JsonObject;
        QueryTok: Label 'query { metafieldDefinitions(first: 250, ownerType: %1) { edges { node { id  key name type {name} description namespace } } } }', Locked = true;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        RequestJson.Add('query', StrSubstNo(QueryTok, OwnerTypeEnumValueName(OwnerType)));
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);

        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    local procedure GenerateMetafieldsSet(EntityRecID: RecordId; ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20]; var MetafieldsSet: JsonObject): Boolean
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        Metafield: JsonObject;
        Metafields: JsonArray;
        NullJsonValue: JsonValue;
    begin
        Clear(MetafieldsSet);
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
                    Metafield.Add('ownerId', StrSubstNo('gid://shopify/%1/%2', GetOwnerTypeAsText(ShopifyOwnerType), ShopifyOwnerID));
                    Metafield.Add('type', _TempSpfyMetafieldDef.Type);
                    Metafield.Add('value', SpfyEntityMetafield."Metafield Value");
                    //TODO: doesn't seem to work when the field is included. will be handled in Linear issue ISV2-515
                    /*if SpfyEntityMetafield."Metafield Value Version ID" <> '' then
                        Metafield.Add('compareDigest', SpfyEntityMetafield."Metafield Value Version ID")
                    else
                        Metafield.Add('compareDigest', NullJsonValue);*/
                    Metafields.Add(Metafield);
                end;
            until SpfyEntityMetafield.Next() = 0;

        MetafieldsSet.Add('metafields', Metafields);
        exit(Metafields.Count() > 0);
    end;

    local procedure ProcessItemAttributeMappingChange(ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyMetafieldValue: Text[250];
        ValueAsInteger: Integer;
    begin
        if not (ItemAttributeValueMapping."Table ID" in [Database::Item]) then
            exit;
        ItemAttribute.Get(ItemAttributeValueMapping."Item Attribute ID");
        FilterMetafieldMapping(ItemAttribute.RecordId(), ShopifyStoreCode, SpfyMetafieldMapping);
        if SpfyMetafieldMapping.IsEmpty() then
            exit;
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
                SpfyEntityMetafieldParam."Metafield Value" := ShopifyMetafieldValue;
                SetEntityMetafieldValue(SpfyEntityMetafieldParam, false, false);
            end;
        until SpfyMetafieldMapping.Next() = 0;
    end;

    local procedure SetEntityMetafieldValue(Params: Record "NPR Spfy Entity Metafield"; DeleteEmpty: Boolean; DisableDataLog: Boolean)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        FilterSpfyEntityMetafields(Params."BC Record ID", Params."Owner Type", SpfyEntityMetafield);
        SpfyEntityMetafield.SetRange("Metafield ID", Params."Metafield ID");
        if not SpfyEntityMetafield.FindFirst() then begin
            if Params."Metafield Value" = '' then
                exit;

            SpfyEntityMetafield.Init();
            SpfyEntityMetafield."Entry No." := 0;
            SpfyEntityMetafield.Insert();

            SpfyEntityMetafield."Table No." := Params."BC Record ID".TableNo();
            SpfyEntityMetafield."BC Record ID" := Params."BC Record ID";
            SpfyEntityMetafield."Owner Type" := Params."Owner Type";
            SpfyEntityMetafield."Metafield ID" := Params."Metafield ID";
            SpfyEntityMetafield."Metafield Key" := Params."Metafield Key";
            SpfyEntityMetafield."Metafield Value" := Params."Metafield Value";
            SpfyEntityMetafield."Metafield Value Version ID" := Params."Metafield Value Version ID";
            if DisableDataLog then
                DataLogMgt.DisableDataLog(true);
            SpfyEntityMetafield.Modify(true);
            if DisableDataLog then
                DataLogMgt.DisableDataLog(false);
            exit;
        end;

        if (Params."Metafield Value" = '') and DeleteEmpty then begin
            if DisableDataLog then
                DataLogMgt.DisableDataLog(true);
            SpfyEntityMetafield.Delete(true);
            if DisableDataLog then
                DataLogMgt.DisableDataLog(false);
            exit;
        end;

        if (Params."Metafield Value" = SpfyEntityMetafield."Metafield Value") and
           (Params."Metafield Key" in ['', SpfyEntityMetafield."Metafield Key"]) and
           (Params."Metafield Value Version ID" in ['', SpfyEntityMetafield."Metafield Value Version ID"])
        then
            exit;

        SpfyEntityMetafield."Metafield Value" := Params."Metafield Value";
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

    internal procedure SetItemAttributeValue(ItemAttribute: Record "Item Attribute"; ItemNo: Code[20]; LanguageCode: Code[10]; NewAttributeValueTxt: Text[250])
    var
        ItemAttributeValue: Record "Item Attribute Value";
        xItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttrValueTranslation: Record "Item Attr. Value Translation";
        TempItemAttributeValueSelection: Record "Item Attribute Value Selection" temporary;
        IntegerValue: Integer;
        DecimalValue: Decimal;
        DateValue: Date;
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
                    ItemAttrValueTranslation.SetRange("Attribute ID", ItemAttribute.ID);
                    ItemAttrValueTranslation.SetRange("Language Code", LanguageCode);
                    ItemAttrValueTranslation.SetFilter(Name, StrSubstNo('@%1', NewAttributeValueTxt));
                    if ItemAttrValueTranslation.FindFirst() then
                        ItemAttribValueFound := ItemAttributeValue.Get(ItemAttrValueTranslation."Attribute ID", ItemAttrValueTranslation.ID)
                    else begin
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetFilter(Value, StrSubstNo('@%1', NewAttributeValueTxt));
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
            TempItemAttributeValueSelection.Value := NewAttributeValueTxt;
            if not TempItemAttributeValueSelection.FindAttributeValue(ItemAttributeValue) then
                TempItemAttributeValueSelection.InsertItemAttributeValue(ItemAttributeValue, TempItemAttributeValueSelection);
        end;
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

    local procedure FilterMetafieldMapping(RecID: RecordId; ShopifyStoreCode: Code[20]; var SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping")
    begin
        SpfyMetafieldMapping.Reset();
        SpfyMetafieldMapping.SetRange("Table No.", RecID.TableNo());
        SpfyMetafieldMapping.SetRange("BC Record ID", RecID);
        if ShopifyStoreCode <> '' then
            SpfyMetafieldMapping.SetRange("Shopify Store Code", ShopifyStoreCode)
        else
            SpfyMetafieldMapping.SetFilter("Shopify Store Code", '<>%1', '');
        SpfyMetafieldMapping.SetFilter("Metafield ID", '<>%1', '');
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
        ProcessItemAttributeMappingChange(Rec, '', false);
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
        ProcessItemAttributeMappingChange(Rec, '', false);
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
        ProcessItemAttributeMappingChange(Rec, '', true);
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
}
#endif