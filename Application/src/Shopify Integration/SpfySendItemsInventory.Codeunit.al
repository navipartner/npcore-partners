#if not BC17
codeunit 6184819 "NPR Spfy Send Items&Inventory"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Store Code");
        case Rec."Table No." of
            Database::Item:
                SendItem(Rec);
            Database::"Item Variant":
                SendItemVariant(Rec);
            Database::"Inventory Buffer":
                SendItemCost(Rec);
            Database::"NPR Spfy Entity Metafield":
                SendMetafields(Rec);
            Database::"NPR Spfy Tag Update Request":
                SendTags(Rec);
            Database::"NPR Spfy Inventory Level":
                SendShopifyInventoryUpdate(Rec);
            Database::"NPR Spfy Item Price":
                SendShopifyItemPrices(Rec);
        end;
    end;

    var
        _LastQueriedSpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _JsonHelper: Codeunit "NPR Json Helper";
        _ShopifyInventoryItemID: Text[30];
        _ShopifyProductID: Text[30];
        _ShopifyVariantID: Text[30];
        _InventoryItemIDNotFoundErr: Label 'Shopify Inventory Item ID could not be found for %1=%2, %3=%4 at Shopify Store %5', Comment = '%1 = Item No. fieldcaption, %2 = Item No., %3 = Variant Code fieldcaption, %4 = Variant Code, %5 = Shopify Store Code';
        _QueryingShopifyLbl: Label 'Querying Shopify...';

    local procedure SendItem(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ShopifyItemID: Text[30];
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        if PrepareItemUpdateRequest(NcTask, ShopifyItemID) then
            case NcTask.Type of
                NcTask.Type::Insert:
                    Success := SpfyCommunicationHandler.SendItemCreateRequest(NcTask, ShopifyResponse);
                NcTask.Type::Modify:
                    Success := SpfyCommunicationHandler.SendItemUpdateRequest(NcTask, ShopifyItemID, ShopifyResponse);
                NcTask.Type::Delete:
                    Success := SpfyCommunicationHandler.SendItemDeleteRequest(NcTask, ShopifyItemID);
            end;
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());

        UpdateItemWithDataFromShopify(NcTask, ShopifyResponse, false);
    end;

    local procedure SendTags(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        TagUpdateErrors: JsonToken;
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        PrepareTagUpdateRequest(NcTask, SendToShopify);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);

        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if ShopifyResponse.SelectToken('data.tagsRemove.userErrors', TagUpdateErrors) then
            if TagUpdateErrors.IsArray() then
                if TagUpdateErrors.AsArray().Count() > 0 then
                    Error('');
        if ShopifyResponse.SelectToken('data.tagsAdd.userErrors', TagUpdateErrors) then
            if TagUpdateErrors.IsArray() then
                if TagUpdateErrors.AsArray().Count() > 0 then
                    Error('');
    end;

    local procedure SendItemVariant(var NcTask: Record "NPR Nc Task")
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        ItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ShopifyItemID: Text[30];
        ShopifyVariantID: Text[30];
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        if PrepareItemVariantUpdateRequest(NcTask, ItemVariant, ShopifyItemID, ShopifyVariantID) then
            case NcTask.Type of
                NcTask.Type::Insert:
                    Success := SpfyCommunicationHandler.SendItemVariantCreateRequest(NcTask, ShopifyItemID, ShopifyResponse);
                NcTask.Type::Modify:
                    Success := SpfyCommunicationHandler.SendItemVariantUpdateRequest(NcTask, ShopifyVariantID, ShopifyResponse);
                NcTask.Type::Delete:
                    Success := SpfyCommunicationHandler.SendItemVariantDeleteRequest(NcTask, ShopifyItemID, ShopifyVariantID);
            end;
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());

        case NcTask.Type of
            NcTask.Type::Insert, NcTask.Type::Modify:
                if Success then
                    UpdateItemVariantWithDataFromShopify(NcTask."Store Code", ShopifyResponse);
            NcTask.Type::Delete:
                begin
                    SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
                    SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
                    SpfyStoreItemVariantLink."Variant Code" := ItemVariant."Code";
                    SpfyStoreItemVariantLink."Shopify Store Code" := NcTask."Store Code";
                    ClearVariantShopifyIDs(SpfyStoreItemVariantLink);
                    InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemVariantLink);
                    ItemPriceMgt.ClearItemPrices(SpfyStoreItemVariantLink);
                end;
        end;
    end;

    local procedure SendItemCost(var NcTask: Record "NPR Nc Task")
    var
        InventoryBuffer: Record "Inventory Buffer";
        Item: Record Item;
        TempItemVariant: Record "Item Variant" temporary;
        TempNcTask: Record "NPR Nc Task" temporary;
        NcTaskOutput: Record "NPR Nc Task Output";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        RecRef: RecordRef;
        ShopifyInventoryItemID: Text[30];
        Success: Boolean;
    begin
        NcTaskOutput.SetRange("Task Entry No.", NcTask."Entry No.");
        if not NcTaskOutput.IsEmpty() then
            NcTaskOutput.DeleteAll();
        Success := false;

        RecRef := NcTask."Record ID".GetRecord();
        RecRef.SetTable(InventoryBuffer);
        Item.get(InventoryBuffer."Item No.");
        GenerateTmpItemVariantList(Item, TempItemVariant);
        if TempItemVariant.FindSet() then
            repeat
                ClearLastError();
                Clear(NcTaskOutput);
                NcTaskOutput."Task Entry No." := NcTask."Entry No.";
                NcTaskOutput."Record ID" := TempItemVariant.RecordId();
                NcTaskOutput.Name := CopyStr(Format(TempItemVariant.RecordId()), 1, MaxStrLen(NcTaskOutput.Name));
                if PrepareItemCostUpdateRequest(NcTask."Store Code", NcTaskOutput, Item, TempItemVariant, ShopifyInventoryItemID) then begin
                    Clear(TempNcTask);
                    TempNcTask."Store Code" := NcTask."Store Code";
                    TempNcTask."Data Output" := NcTaskOutput.Data;
                    TempNcTask."Record Value" := CopyStr(NcTaskOutput.Name, 1, MaxStrLen(TempNcTask."Record Value"));
                    if SpfyCommunicationHandler.SendInvetoryItemUpdateRequest(TempNcTask, ShopifyInventoryItemID) then
                        NcTaskOutput.Status := NcTaskOutput.Status::Success;
                    NcTaskOutput.Response := TempNcTask.Response;
                end;
                if NcTaskOutput.Status = NcTaskOutput.Status::Success then
                    Success := true
                else begin
                    NcTaskOutput.Status := NcTaskOutput.Status::Error;
                    NcTaskOutput."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(NcTaskOutput."Error Message"));
                end;
                NcTaskOutput.Insert();
                Commit();
            until TempItemVariant.Next() = 0;

        if not Success then
            Error(GetLastErrorText());
    end;

    local procedure SendMetafields(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldsSet: JsonToken;
        MetafieldsSetErrors: JsonToken;
        ShopifyResponse: JsonToken;
        ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type";
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        Clear(SpfyMetafieldMgt);
        ClearLastError();

        Success := PrepareMetafieldUpdateRequest(NcTask, SpfyMetafieldMgt, ShopifyOwnerType, SendToShopify);
        if SendToShopify then begin
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
            if Success then
                if ShopifyResponse.SelectToken('data.metafieldsSet.metafields', MetafieldsSet) then
                    SpfyMetafieldMgt.UpdateBCMetafieldData(NcTask."Record ID", ShopifyOwnerType, MetafieldsSet);
        end;

        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if ShopifyResponse.SelectToken('data.metafieldsSet.userErrors', MetafieldsSetErrors) then
            if MetafieldsSetErrors.IsArray() then
                if MetafieldsSetErrors.AsArray().Count() > 0 then
                    Error('');
    end;

    local procedure SendShopifyInventoryUpdate(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        if PrepareInventoryLevelUpdateRequest(NcTask) then
            Success := SpfyCommunicationHandler.SendInvetoryLevelUpdateRequest(NcTask);

        NcTask.Modify();
        Commit();
        if not Success then
            Error(GetLastErrorText());
    end;

    local procedure SendShopifyItemPrices(var NcTask: Record "NPR Nc Task")
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        productVariantsBulkUpdateRequestString: Text;
    begin
        while PrepareItemPriceUpdateRequest(NcTask, TempNcTask) do
            if SetNcTaskPostponed(TempNcTask, productVariantsBulkUpdateRequestString) then
                UpdateNCTasksWithDataFromShopify(TempNcTask, productVariantsBulkUpdateRequestString);
    end;

    local procedure UpdateNCTasksWithDataFromShopify(var NcTaskIn: Record "NPR Nc Task"; productVariantsBulkUpdateRequestString: Text)
    var
        NcTaskParam: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ResponseDictionary: Dictionary of [Text[30], Dictionary of [Text[30], Text]];
        Found: Boolean;
        Success: Boolean;
        NcTaskErrorText: Text;
    begin
        if not NcTaskIn.FindFirst() then
            exit;

        CreateNcTaskParam(NcTaskIn, NcTaskParam, productVariantsBulkUpdateRequestString);

        ClearLastError();
        Clear(ShopifyResponse);

        if (NcTaskParam."Store Code" <> '') and (NcTaskParam."Data Output".HasValue()) then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTaskParam, true, ShopifyResponse);

        if Success then
            Success := PopulateResponseDictionary(ShopifyResponse, ResponseDictionary);
        if not Success then
            NcTaskErrorText := GetLastErrorText();

        NcTaskIn.FindSet();
        repeat
            if Success then
                Found := FindNcTaskInDictionary(NcTaskIn, ResponseDictionary, NcTaskErrorText);
            MarkNcTaskAsCompleted(NcTaskIn."Entry No.", ShopifyResponse, Success and Found, NcTaskErrorText);
        until NcTaskIn.Next() = 0;
    end;

    [TryFunction]
    local procedure PopulateResponseDictionary(ShopifyResponse: JsonToken; var ResponseDictionary: Dictionary of [Text[30], Dictionary of [Text[30], Text]])
    var
        DataJToken: JsonToken;
        ErrorsJToken: JsonToken;
        ErrorText: Text;
        ResponseNcTaskID: Text;
        ProductVariantIDJToken: JsonToken;
        ProductVariantsJToken: JsonToken;
        UserErrorsJToken: JsonToken;
        NcTaskResult: Dictionary of [Text[30], Text];
        UserErrorsDeserialized: Text;
        NoResponseLbl: Label 'No response received from Shopify and Shopify provided no reason.';
    begin
        if not ShopifyResponse.IsObject() then
            Error(NoResponseLbl);

        Clear(ResponseDictionary);

        if not ShopifyResponse.AsObject().Get('data', DataJToken) or not DataJToken.IsObject() then begin
            if ShopifyResponse.AsObject().Get('errors', ErrorsJToken) then begin
                ErrorsJToken.WriteTo(ErrorText);
                Error(ErrorText);
            end;
            Error(NoResponseLbl);
        end;

        foreach ResponseNcTaskID in DataJToken.AsObject().Keys() do begin
            Clear(NcTaskResult);
            DataJToken.AsObject().SelectToken(StrSubstNo('%1.productVariants', ResponseNcTaskID), ProductVariantsJToken);
            if ProductVariantsJToken.IsArray() then begin
                ProductVariantsJToken.AsArray().Get(0, ProductVariantIDJToken);
                ProductVariantIDJToken.AsObject().Get('id', ProductVariantIDJToken);
                NcTaskResult.Add('VariantID', CopyStr(_SpfyIntegrationMgt.RemoveUntil(ProductVariantIDJToken.AsValue().AsText(), '/'), 1, 30));
            end else begin
                DataJToken.SelectToken(StrSubstNo('%1.userErrors', ResponseNcTaskID), UserErrorsJToken);
                UserErrorsJToken.AsArray().Get(0, UserErrorsJToken);
                UserErrorsJToken.WriteTo(UserErrorsDeserialized);
                NcTaskResult.Add('Error', UserErrorsDeserialized);
            end;
            ResponseDictionary.Add(CopyStr(ResponseNcTaskID, 1, 30), NcTaskResult);
        end;
    end;

    local procedure MarkNcTaskAsCompleted(NcTaskInEntryNo: BigInteger; ShopifyResponse: JsonToken; Success: Boolean; ErrorText: Text)
    var
        NcTask: Record "NPR Nc Task";
        OStream: OutStream;
        ShopifyResponseText: Text;
    begin
#if not (BC18 or BC19 or BC20 or BC21)
        NcTask.ReadIsolation := IsolationLevel::UpdLock;
#else
        NcTask.LockTable();
#endif

        if not NcTask.Get(NcTaskInEntryNo) then
            exit;
        if NcTask.Processed then
            exit;

        NcTask."Last Processing Completed at" := CurrentDateTime();
        NcTask."Last Processing Duration" := (NcTask."Last Processing Completed at" - NcTask."Last Processing Started at") / 1000;
        NcTask.Postponed := false;
        NcTask."Postponed At" := 0DT;
        NcTask.Response.CreateOutStream(OStream);
        if ErrorText = '' then begin
            ShopifyResponse.WriteTo(ShopifyResponseText);
            OStream.WriteText(ShopifyResponseText);
        end else
            OStream.WriteText(ErrorText);

        if Success then begin
            NcTask.Processed := true;
            NcTask."Process Error" := false;
        end else
            NcTask."Process Error" := true;

        NcTask.Modify(true);
        Commit();
    end;

    local procedure ValidateProductVariantId(var NcTaskIn: Record "NPR Nc Task"; ShopifyVariantID: Text[30]): Boolean
    var
        ItemPrice: Record "NPR Spfy Item Price";
        RecRef: RecordRef;
        ShopifyVariantIDComparison: Text[30];
    begin
        if not RecRef.Get(NcTaskIn."Record ID") then
            exit;
        RecRef.SetTable(ItemPrice);

        GetProductVariantForItemPrice(ItemPrice, ShopifyVariantIDComparison);
        if ShopifyVariantIDComparison = '' then
            exit;
        if ShopifyVariantID <> ShopifyVariantIDComparison then
            exit;
        exit(true);
    end;

    [TryFunction]
    local procedure PrepareItemUpdateRequest(var NcTask: Record "NPR Nc Task"; var ShopifyItemID: Text[30])
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        ProductJObject: JsonObject;
        ProductVariantsJArray: JsonArray;
        RequestJObject: JsonObject;
        OStream: OutStream;
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
        ShopifyItemIdEmptyErr: Label 'Shopify Product Id must be specified for %1', Comment = '%1 - Item record id';
    begin
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(Item);

        GetStoreItemLink(Item."No.", NcTask."Store Code", SpfyStoreItemLink);

        ShopifyItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyItemID = '' then
            ShopifyItemID := GetShopifyItemID(SpfyStoreItemLink, false);
        if ShopifyItemID = '' then begin
            case NcTask.Type of
                NcTask.Type::Modify:
                    NcTask.Type := NcTask.Type::Insert;
                NcTask.Type::Delete:
                    Error(ShopifyItemIdEmptyErr, Format(Item.RecordId()));
            end;
        end else
            if NcTask.Type = NcTask.Type::Insert then
                NcTask.Type := NcTask.Type::Modify;

        AddItemInfo(SpfyStoreItemLink, Item, NcTask.Type, ShopifyItemID, ProductJObject);
        Clear(VarietyValueDic);
        if GenerateItemVariantCollection(NcTask."Store Code", Item, NcTask.Type = NcTask.Type::Insert, ProductVariantsJArray, VarietyValueDic) then
            ProductJObject.Add('options', GenerateListOfProductOptions(Item, VarietyValueDic))
        else
            AddDefaultVariant(NcTask."Store Code", Item, ProductVariantsJArray);
        ProductJObject.Add('variants', ProductVariantsJArray);

        RequestJObject.Add('product', ProductJObject);
        NcTask."Data Output".CreateOutStream(OStream);
        RequestJObject.WriteTo(OStream);
    end;

    local procedure PrepareTagUpdateRequest(var NcTask: Record "NPR Nc Task"; var SendToShopify: Boolean)
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyTagMgt: Codeunit "NPR Spfy Tag Mgt.";
        QueryStream: OutStream;
        ShopifyProductID: Text[30];
        ShopifyProductIdEmptyErr: Label 'The item has not yet been synced with Shopify. The tags will be sent when the item is synced.';
    begin
        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Entry ID");
        if ShopifyProductID = '' then
            Error(ShopifyProductIdEmptyErr);
        NcTask."Data Output".CreateOutStream(QueryStream);
        SendToShopify := SpfyTagMgt.ShopifyEntityTagsUpdateQuery(NcTask, Enum::"NPR Spfy Tag Owner Type"::PRODUCT, ShopifyProductID, QueryStream);
    end;

    local procedure PrepareItemVariantUpdateRequest(var NcTask: Record "NPR Nc Task"; var ItemVariant: Record "Item Variant"; var ShopifyItemID: Text[30]; var ShopifyVariantID: Text[30]): Boolean
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        VariantJObject: JsonObject;
        RequestJObject: JsonObject;
        OStream: OutStream;
        ItemDoesNotExistErr: Label 'Item %1 has been removed from the system. The variant request is no longer applicable.', Comment = '%1 - Item No.';
        ItemVariantDoesNotExistErr: Label 'The item %1 variant %2 has been removed from the system. The request is no longer applicable.', Comment = '%1 - Item No., %2 - Variant Code';
        ShopifyProductIdEmptyErr: Label 'The item has not yet been synced with Shopify. The variant will be sent with the item.';
        ShopifyVariantIdEmptyErr: Label 'The variant does not exist in Shopify. No need to send a removal request.';
    begin
        RecRef := NcTask."Record ID".GetRecord();
        RecRef.SetTable(ItemVariant);
        if not ItemVariant.Find() and (NcTask.Type <> NcTask.Type::Delete) then begin
            SetResponse(NcTask, StrSubstNo(ItemVariantDoesNotExistErr, ItemVariant."Item No.", ItemVariant.Code));
            exit(false);
        end;
        if not Item.Get(ItemVariant."Item No.") then begin
            SetResponse(NcTask, StrSubstNo(ItemDoesNotExistErr, ItemVariant."Item No."));
            exit(false);
        end;

        GetStoreItemLink(Item."No.", NcTask."Store Code", SpfyStoreItemLink);

        ShopifyItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyItemID = '' then
            ShopifyItemID := GetShopifyItemID(SpfyStoreItemLink, false);
        if ShopifyItemID = '' then begin
            SetResponse(NcTask, ShopifyProductIdEmptyErr);
            exit(false);
        end;

        GenerateVariantJObject(NcTask."Store Code", Item, ItemVariant, NcTask.Type <> NcTask.Type::Delete, ShopifyVariantID, VariantJObject);
        if ShopifyVariantID = '' then begin
            case NcTask.Type of
                NcTask.Type::Modify:
                    NcTask.Type := NcTask.Type::Insert;
                NcTask.Type::Delete:
                    begin
                        SetResponse(NcTask, ShopifyVariantIdEmptyErr);
                        exit(false);
                    end;
            end;
        end else
            if NcTask.Type = NcTask.Type::Insert then
                NcTask.Type := NcTask.Type::Modify;

        if NcTask.Type <> NcTask.Type::Delete then begin
            RequestJObject.Add('variant', VariantJObject);
            NcTask."Data Output".CreateOutStream(OStream);
            RequestJObject.WriteTo(OStream);
        end;
        exit(true);
    end;

    [TryFunction]
    local procedure PrepareItemCostUpdateRequest(ShopifyStoreCode: Code[20]; var NcTaskOutput: Record "NPR Nc Task Output"; Item: Record Item; ItemVariant: Record "Item Variant"; var ShopifyInventoryItemID: Text[30])
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RequestJObject: JsonObject;
        RequestJObjectChild: JsonObject;
        OStream: OutStream;
    begin
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::"Variant";
        SpfyStoreItemLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemLink."Variant Code" := ItemVariant."Code";
        SpfyStoreItemLink."Shopify Store Code" := ShopifyStoreCode;

        ShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        if ShopifyInventoryItemID = '' then
            ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemLink, false);
        if ShopifyInventoryItemID = '' then
            Error(_InventoryItemIDNotFoundErr,
                ItemVariant.FieldCaption("Item No."), Item."No.", StrSubstNo('%1 %2', ItemVariant.TableCaption, ItemVariant.FieldCaption(Code)), ItemVariant.Code, ShopifyStoreCode);

        RequestJObjectChild.Add('id', ShopifyInventoryItemID);
        RequestJObjectChild.Add('cost', Item."Last Direct Cost");
        RequestJObject.Add('inventory_item', RequestJObjectChild);

        NcTaskOutput.Data.CreateOutStream(OStream);
        RequestJObject.WriteTo(OStream);
    end;

    [TryFunction]
    local procedure PrepareMetafieldUpdateRequest(var NcTask: Record "NPR Nc Task"; var SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt."; var ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var SendToShopify: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        QueryStream: OutStream;
        ShopifyOwnerID: Text[30];
    begin
        RecRef := NcTask."Record ID".GetRecord();
        RecRef.SetTable(SpfyStoreItemLink);
        if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Item then
            ShopifyOwnerType := ShopifyOwnerType::PRODUCT
        else
            ShopifyOwnerType := ShopifyOwnerType::PRODUCTVARIANT;
        ShopifyOwnerID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        NcTask."Data Output".CreateOutStream(QueryStream);
        SendToShopify := SpfyMetafieldMgt.ShopifyEntityMetafieldValueUpdateQuery(SpfyStoreItemLink.RecordId(), ShopifyOwnerType, ShopifyOwnerID, SpfyStoreItemLink."Shopify Store Code", QueryStream);
    end;

    local procedure PrepareInventoryLevelUpdateRequest(var NcTask: Record "NPR Nc Task"): Boolean
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
        RequestJObject: JsonObject;
        OStream: OutStream;
        ShopifyInventoryItemID: Text[30];
        ItemVariantDoesNotExistErr: Label 'The item %1 variant %2 is blocked or has been removed from the system. The request is no longer applicable.', Comment = '%1 - Item No., %2 - Variant Code';
        VariantNotAvailErr: Label 'The variant is marked as not available in Shopify. The request is no longer applicable.';
    begin
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(InventoryLevel);

        if InventoryLevel."Variant Code" <> '' then
            if not ItemVariant.Get(InventoryLevel."Item No.", InventoryLevel."Variant Code") or SpfyItemMgt.ItemVariantIsBlocked(ItemVariant) then begin
                SetResponse(NcTask, StrSubstNo(ItemVariantDoesNotExistErr, InventoryLevel."Item No.", InventoryLevel."Variant Code"));
                exit(false);
            end;
        GetStoreItemLink(InventoryLevel."Item No.", InventoryLevel."Shopify Store Code", SpfyStoreItemLink);  //Check integration is enabled for the item

        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::"Variant";
        SpfyStoreItemLink."Item No." := InventoryLevel."Item No.";
        SpfyStoreItemLink."Variant Code" := InventoryLevel."Variant Code";
        SpfyStoreItemLink."Shopify Store Code" := InventoryLevel."Shopify Store Code";
        if SpfyItemMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemLink) then begin
            SetResponse(NcTask, VariantNotAvailErr);
            exit(false);
        end;

        ShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        if ShopifyInventoryItemID = '' then begin
            ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemLink, false);
            if ShopifyInventoryItemID <> '' then begin
                SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
                Commit();
            end;
        end;
        if ShopifyInventoryItemID = '' then
            Error(_InventoryItemIDNotFoundErr,
                InventoryLevel.FieldCaption("Item No."), InventoryLevel."Item No.", InventoryLevel.FieldCaption("Variant Code"), InventoryLevel."Variant Code", InventoryLevel."Shopify Store Code");

        RequestJObject.Add('location_id', InventoryLevel."Shopify Location ID");
        RequestJObject.Add('inventory_item_id', ShopifyInventoryItemID);
        RequestJObject.Add('available', Format(InventoryLevel.AvailableInventory(), 0, 9));

        NcTask."Store Code" := InventoryLevel."Shopify Store Code";
        NcTask."Data Output".CreateOutStream(OStream);
        RequestJObject.WriteTo(OStream);
        exit(true);
    end;

    [TryFunction]
    local procedure PrepareItemPriceUpdateRequest(var NcTaskIn: Record "NPR Nc Task"; var NcTaskOut: Record "NPR Nc Task")
    var
        ItemPrice: Record "NPR Spfy Item Price";
        SpfyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        OStream: OutStream;
        MaxItemPricesPerRequest: Integer;
        IncludedNcTasks: Integer;
        ShopifyItemID: Text[30];
        ShopifyVariantID: Text[30];
        FuturePriceErr: Label 'You cannot send prices that far into the future. The price start date cannot be later than tomorrow.';
        ItemIntegrNotEnabledErr: Label 'Shopify integration is not enabled for the item.';
        ShopifyProductIDIsMissingLbl: Label 'Item %1 does not have a Shopify Product ID assigned.';
        ShopifyVariantIDIsMissingLbl: Label 'Variant %1 of Item %2 does not have a Shopify Variant ID assigned.';
        SourceRecNotFoundErr: Label '%1 Entry No. %2 source record (%3) could not be found.', Comment = '%1 - NcTask tablename, %2 - NcTask entry number, %3 - task source record id';
        UpdateProductVariantsMutationLabel: Label '%1: productVariantsBulkUpdate(productId: "gid://shopify/Product/%2", variants: [ { id: "gid://shopify/ProductVariant/%3", price: %4, compareAtPrice: %5 } ]) { productVariants { id price compareAtPrice } userErrors { field message } }', Locked = true, Comment = '%1 = NcTask ID, %2 = Shopify Product ID, %3 = Shopify Product Variant ID, %4 = Unit Price, %5 = Compare At Price';
    begin
        if not (NcTaskIn.IsTemporary() and NcTaskOut.IsTemporary()) then
            FunctionCallOnNonTempVarErr('PrepareItemPriceUpdateRequest');

        NcTaskOut.DeleteAll();
        NcTaskIn.FindSet();

        SpfyStore.Get(NcTaskIn."Store Code");
        MaxItemPricesPerRequest := SpfyStore.NoOfPriceUpdatesPerRequest();
        IncludedNcTasks := 0;

        repeat
            NcTaskOut := NcTaskIn;
            NcTaskOut."Last Processing Started at" := CurrentDateTime();
            NcTaskOut."Process Error" := not RecRef.Get(NcTaskIn."Record ID");
            if NcTaskOut."Process Error" then
                SetResponse(NcTaskOut, StrSubstNo(SourceRecNotFoundErr, NcTaskIn.TableCaption(), NcTaskIn."Entry No.", NcTaskIn."Record ID"))
            else begin
                RecRef.SetTable(ItemPrice);
                NcTaskOut."Process Error" := ItemPrice."Starting Date" > Today() + 1;
                if NcTaskOut."Process Error" then
                    SetResponse(NcTaskOut, FuturePriceErr)
                else begin
                    NcTaskOut."Process Error" := not GetStoreItemLink(ItemPrice."Item No.", ItemPrice."Shopify Store Code", false, SpfyStoreItemLink);  //Check integration is enabled for the item
                    if NcTaskOut."Process Error" then
                        SetResponse(NcTaskOut, ItemIntegrNotEnabledErr)
                    else begin
                        ShopifyItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        if ShopifyItemID = '' then
                            ShopifyItemID := GetShopifyItemID(SpfyStoreItemLink, false);
                        GetProductVariantForItemPrice(ItemPrice, ShopifyVariantID);
                        NcTaskOut."Process Error" := (ShopifyItemID = '') or (ShopifyVariantID = '');
                        if NcTaskOut."Process Error" then begin
                            case true of
                                ShopifyItemID = '':
                                    SetResponse(NcTaskOut, StrSubstNo(ShopifyProductIDIsMissingLbl, ItemPrice."Item No."));
                                ShopifyVariantID = '':
                                    SetResponse(NcTaskOut, StrSubstNo(ShopifyVariantIDIsMissingLbl, ItemPrice."Variant Code", ItemPrice."Item No."));
                            end;
                        end else begin
                            NcTaskOut."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
                            OStream.WriteText(StrSubstNo(UpdateProductVariantsMutationLabel, 'NCTask' + Format(NcTaskIn."Entry No."), ShopifyItemID, ShopifyVariantID, Format(ItemPrice."Unit Price", 0, 9), Format(ItemPrice."Compare at Price", 0, 9)));
                        end;
                    end;
                end;
            end;
            IncludedNcTasks += 1;
            NcTaskOut.Insert();
            NcTaskIn.Delete();
        until (NcTaskIn.Next() = 0) or (IncludedNcTasks >= MaxItemPricesPerRequest);
    end;

    local procedure SetResponse(var NcTask: Record "NPR Nc Task"; ResponseTxt: Text)
    var
        OutStr: OutStream;
    begin
        NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(ResponseTxt);
        NcTask."Last Processing Started at" := CurrentDateTime();
    end;

    local procedure AddItemInfo(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Item: Record Item; NcTaskType: Integer; ShopifyItemID: Text[30]; var ProductJObject: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
        LongDescription: Text;
    begin
        if ShopifyItemID <> '' then
            ProductJObject.Add('id', ShopifyItemID);
        if _SpfyIntegrationMgt.IsSendShopifyNameAndDescription(SpfyStoreItemLink."Shopify Store Code") or (NcTaskType = NcTask.Type::Insert) then begin
            if SpfyStoreItemLink."Shopify Name" <> '' then
                ProductJObject.Add('title', SpfyStoreItemLink."Shopify Name")
            else
                if NcTaskType = NcTask.Type::Insert then
                    ProductJObject.Add('title', GetItemTitle(Item, SpfyStoreItemLink."Shopify Store Code"));
            if SpfyStoreItemLink."Shopify Description".HasValue() then begin
                SpfyStoreItemLink.CalcFields("Shopify Description");
                SpfyStoreItemLink."Shopify Description".CreateInStream(IStream, TextEncoding::UTF8);
                LongDescription := TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.CRLFSeparator());
                if LongDescription <> '' then
                    ProductJObject.Add('body_html', LongDescription);
            end;
        end;
        case NcTaskType of
            NcTask.Type::Insert:
                begin
                    ProductJObject.Add('product_type', 'new');
                    ProductJObject.Add('published', false);
                    ProductJObject.Add('published_scope', 'web');
                    ProductJObject.Add('status', 'draft');
                end;
            NcTask.Type::Modify:
                if not SpfyItemMgt.TestRequiredFields(Item, false) or not SpfyStoreItemLink."Sync. to this Store" then
                    ProductJObject.Add('status', 'archived');
        end;
    end;

    local procedure GenerateItemVariantCollection(ShopifyStoreCode: Code[20]; Item: Record Item; NewProduct: Boolean; var ProductVariantsJArray: JsonArray; var VarietyValueDic: Dictionary of [Integer, List of [Text]]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", Item."No.");
        if not ItemVariant.FindSet() then
            exit(false);
        repeat
            AddVariant(ShopifyStoreCode, Item, ItemVariant, NewProduct, ProductVariantsJArray, VarietyValueDic);
        until ItemVariant.Next() = 0;
        exit(ProductVariantsJArray.Count() > 0);
    end;

    local procedure AddDefaultVariant(ShopifyStoreCode: Code[20]; Item: Record Item; var ProductVariantsJArray: JsonArray)
    var
        ItemVariant: Record "Item Variant";
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
    begin
        Clear(ItemVariant);
        ItemVariant."Item No." := Item."No.";
        AddVariant(ShopifyStoreCode, Item, ItemVariant, true, ProductVariantsJArray, VarietyValueDic);
    end;

    local procedure AddVariant(ShopifyStoreCode: Code[20]; Item: Record Item; ItemVariant: Record "Item Variant"; NewProduct: Boolean; var ProductVariantsJArray: JsonArray; var VarietyValueDic: Dictionary of [Integer, List of [Text]])
    var
        VariantJObject: JsonObject;
        ShopifyVariantID: Text[30];
    begin
        if GenerateVariantJObject(ShopifyStoreCode, Item, ItemVariant, NewProduct, ShopifyVariantID, VariantJObject, VarietyValueDic) then
            ProductVariantsJArray.Add(VariantJObject);
    end;

    local procedure GenerateVariantJObject(ShopifyStoreCode: Code[20]; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject): Boolean
    var
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
    begin
        exit(GenerateVariantJObject(ShopifyStoreCode, Item, ItemVariant, ProcessNewVariants, ShopifyVariantID, VariantJObject, VarietyValueDic));
    end;

    local procedure GenerateVariantJObject(ShopifyStoreCode: Code[20]; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject; var VarietyValueDic: Dictionary of [Integer, List of [Text]]): Boolean
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        Barcode: Text;
        Title: Text;
        ShopifyOptionNo: Integer;
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant."Code";
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;

        ShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyVariantID = '' then
            ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
        if (ShopifyVariantID = '') and not ProcessNewVariants then
            exit(false);
        if SpfyItemMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemVariantLink) or SpfyItemMgt.ItemVariantIsBlocked(ItemVariant) then
            exit(false);

        SpfyItemMgt.CheckVarieties(Item, ItemVariant);

        if ShopifyVariantID <> '' then
            VariantJObject.Add('id', ShopifyVariantID);
        VariantJObject.Add('sku', SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code));
        VariantJObject.Add('inventory_management', 'shopify');
        Barcode := GetItemReference(ItemVariant);
        if Barcode <> '' then
            VariantJObject.Add('barcode', Barcode);

        if ItemVariant."NPR Variety 1 Value" + ItemVariant."NPR Variety 2 Value" + ItemVariant."NPR Variety 3 Value" + ItemVariant."NPR Variety 4 Value" <> '' then begin
            ShopifyOptionNo := 0;
            if ItemVariant."NPR Variety 1 Value" <> '' then
                AddVariety(1, ItemVariant."NPR Variety 1", ItemVariant."NPR Variety 1 Table", ItemVariant."NPR Variety 1 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
            if ItemVariant."NPR Variety 2 Value" <> '' then
                AddVariety(2, ItemVariant."NPR Variety 2", ItemVariant."NPR Variety 2 Table", ItemVariant."NPR Variety 2 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
            if ItemVariant."NPR Variety 3 Value" <> '' then
                AddVariety(3, ItemVariant."NPR Variety 3", ItemVariant."NPR Variety 3 Table", ItemVariant."NPR Variety 3 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
            if ItemVariant."NPR Variety 4 Value" <> '' then
                AddVariety(4, ItemVariant."NPR Variety 4", ItemVariant."NPR Variety 4 Table", ItemVariant."NPR Variety 4 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
        end else begin
            Title := GetItemVariantTitle(ItemVariant, ShopifyStoreCode);
            if Title <> '' then
                VariantJObject.Add('title', Title);
        end;
        SpfyIntegrationEvents.OnAfterGenerateVariantJObject(ItemVariant, VariantJObject);

        exit(true);
    end;

    procedure AddVariety(VarietyNo: Integer; Variety: Code[20]; VarietyTable: Code[40]; VarietyValue: Code[50]; var ShopifyOptionNo: Integer; var VariantJObject: JsonObject; var VarietyValueDic: Dictionary of [Integer, List of [Text]])
    var
        VarietyDescription: Text;
        ShopifyOptionNoLbl: Label 'option%1', Locked = true, Comment = '%1 - option number';
    begin
        if ShopifyOptionNo >= 3 then  //only 3 varieties are supported on Shopify
            exit;
        if GetVarietyDescription(Variety, VarietyTable, VarietyValue, VarietyDescription) then begin
            ShopifyOptionNo += 1;
            VariantJObject.Add(StrSubstNo(ShopifyOptionNoLbl, ShopifyOptionNo), VarietyDescription);
            AddToVarietyValueDic(VarietyNo, VarietyValueDic, VarietyDescription);
        end;
    end;

    procedure GetVarietyDescription(Variety: Code[20]; VarietyTable: Code[40]; VarietyValue: Code[50]; var VarietyDescription: Text): Boolean
    var
        VRTTable: Record "NPR Variety Table";
        VRTValue: Record "NPR Variety Value";
    begin
        VarietyDescription := '';
        if VarietyValue = '' then
            exit(false);

        VRTTable.Get(Variety, VarietyTable);
        if not VRTTable."Use in Variant Description" then
            exit(false);

        if VRTTable."Use Description field" then begin
            VRTValue.Get(Variety, VarietyTable, VarietyValue);
            VRTValue.testfield(Description);
            VarietyDescription := VRTTable."Pre tag In Variant Description" + VRTValue.Description;
        end else
            VarietyDescription := VRTTable."Pre tag In Variant Description" + VarietyValue;

        exit(VarietyDescription <> '');
    end;

    local procedure AddToVarietyValueDic(VarietyNo: Integer; var VarietyValueDic: Dictionary of [Integer, List of [Text]]; VarietyDescription: Text)
    var
        VarietyValueList: List of [Text];
    begin
        if VarietyDescription = '' then
            exit;
        if not VarietyValueDic.ContainsKey(VarietyNo) then begin
            VarietyValueList.Add(VarietyDescription);
            VarietyValueDic.Add(VarietyNo, VarietyValueList);
        end else
            if not VarietyValueDic.Get(VarietyNo).Contains(VarietyDescription) then
                VarietyValueDic.Get(VarietyNo).Add(VarietyDescription);
    end;

    local procedure GenerateListOfProductOptions(Item: record Item; VarietyValueDic: Dictionary of [Integer, List of [Text]]) ProductOptions: JsonArray
    var
        ProductVarietyJObject: JsonObject;
        VarietyValueList: List of [Text];
    begin
        GetVarietyValueList(1, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 1", Item."NPR Variety 1 Table", VarietyValueList, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);

        GetVarietyValueList(2, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 2", Item."NPR Variety 2 Table", VarietyValueList, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);

        GetVarietyValueList(3, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 3", Item."NPR Variety 3 Table", VarietyValueList, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);

        GetVarietyValueList(4, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 4", Item."NPR Variety 4 Table", VarietyValueList, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);
    end;

    local procedure GetVarietyValueList(VarietyNo: Integer; VarietyValueDic: Dictionary of [Integer, List of [Text]]; var VarietyValueList: List of [Text])
    begin
        if not VarietyValueDic.ContainsKey(VarietyNo) then
            Clear(VarietyValueList)
        else
            VarietyValueList := VarietyValueDic.Get(VarietyNo);
    end;

    local procedure GenerateProductOption(Variety: Code[20]; VarietyTable: Code[40]; VarietyValueList: List of [Text]; var ProductVarietyJObject: JsonObject): Boolean
    var
        VRTTable: Record "NPR Variety Table";
    begin
        Clear(ProductVarietyJObject);
        If (Variety = '') or (VarietyTable = '') then
            exit(false);
        if VarietyValueList.Count() = 0 then
            exit(false);
        VRTTable.Get(Variety, VarietyTable);
        VRTTable.TestField(Description);
        ProductVarietyJObject.Add('name', VRTTable.Description);
        ProductVarietyJObject.Add('values', AddProductOptionValues(VarietyValueList));
        exit(true);
    end;

    local procedure AddProductOptionValues(VarietyValueList: List of [Text]) ProductOptionValues: JsonArray
    var
        VarietyValue: Text;
    begin
        foreach VarietyValue in VarietyValueList do
            ProductOptionValues.Add(VarietyValue);
    end;

    local procedure GetItemReference(ItemVariant: Record "Item Variant"): Code[50]
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Item No.", ItemVariant."Item No.");
        ItemReference.SetRange("Variant Code", ItemVariant.Code);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("NPR Discontinued Barcode", false);
        if ItemReference.FindFirst() then
            exit(ItemReference."Reference No.");
        exit('');
    end;

    internal procedure GetStoreItemLink(ItemNo: Code[20]; ShopifyStoreCode: Code[20]; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    begin
        GetStoreItemLink(ItemNo, ShopifyStoreCode, true, SpfyStoreItemLink);
    end;

    internal procedure GetStoreItemLink(ItemNo: Code[20]; ShopifyStoreCode: Code[20]; WithCheck: Boolean; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link") SyncEnabled: Boolean
    begin
        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
        SpfyStoreItemLink."Item No." := ItemNo;
        SpfyStoreItemLink."Variant Code" := '';
        SpfyStoreItemLink."Shopify Store Code" := ShopifyStoreCode;
        if not WithCheck then begin
            if not SpfyStoreItemLink.Find() then
                exit;
        end else
            SpfyStoreItemLink.Find();
        SyncEnabled := SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled";
        if not SyncEnabled and WithCheck then
            SpfyStoreItemLink.TestField("Sync. to this Store");
    end;

    local procedure GetItemTitle(Item: Record Item; ShopifyStoreCode: Code[20]): Text
    var
        ItemTranslation: Record "Item Translation";
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if not ShopifyStore.Get(ShopifyStoreCode) then
            ShopifyStore."Language Code" := '';
        if ShopifyStore."Language Code" <> '' then
            if ItemTranslation.Get(Item."No.", '', ShopifyStore."Language Code") then
                if ItemTranslation.Description + ' ' + ItemTranslation."Description 2" <> '' then
                    exit(ItemTranslation.Description + ' ' + ItemTranslation."Description 2");
        exit(Item.Description);
    end;

    local procedure GetItemVariantTitle(ItemVariant: Record "Item Variant"; ShopifyStoreCode: Code[20]): Text
    var
        ItemTranslation: Record "Item Translation";
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if not ShopifyStore.Get(ShopifyStoreCode) then
            ShopifyStore."Language Code" := '';
        if ShopifyStore."Language Code" <> '' then
            if ItemTranslation.Get(ItemVariant."Item No.", ItemVariant.Code, ShopifyStore."Language Code") then
                if ItemTranslation.Description + ' ' + ItemTranslation."Description 2" <> '' then
                    exit(ItemTranslation.Description + ' ' + ItemTranslation."Description 2");

        case true of
            ItemVariant.Description <> '':
                exit(ItemVariant.Description);
            ItemVariant."Description 2" <> '':
                exit(ItemVariant."Description 2");
        end;
        exit(ItemVariant.Code);
    end;

    internal procedure UpdateItemWithDataFromShopify(NcTask: Record "NPR Nc Task"; ShopifyResponse: JsonToken; CalledByWebhook: Boolean)
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        ShopifyVariant: JsonToken;
        ShopifyVariants: JsonToken;
        ShopifyItemID: Text[30];
        xShopifyItemID: Text[30];
        ShopifyProductDetailedDescr: Text;
        ShopifyProductStatus: Text;
        ShopifyProductTitle: Text;
        VariantSku: Text;
        FirstVariant: Boolean;
        BCIsNameDescriptionMaster: Boolean;
        LinkExists: Boolean;
        xSyncEnabled: Boolean;
    begin
#pragma warning disable AA0139
        ShopifyItemID := _JsonHelper.GetJText(ShopifyResponse, 'product.id', MaxStrLen(ShopifyItemID), true);
#pragma warning restore AA0139
        if not (ShopifyResponse.SelectToken('product.variants', ShopifyVariants) and ShopifyVariants.IsArray()) then begin
            if NcTask.Type = NcTask.Type::Delete then begin  //Shopify webhook notification for a deleted product contains nothing but the deleted product ID
                if SpfyItemMgt.FindItemByShopifyProductID(ShopifyItemID, SpfyStoreItemLink) then begin
                    SpfyStoreItemLink.FindSet();
                    repeat
                        DisableIntegrationForItem(SpfyStoreItemLink);
                        ModifySpfyStoreItemLink(SpfyStoreItemLink, true);
                    until SpfyStoreItemLink.Next() = 0;
                end;
                exit;
            end else
                ShopifyResponse.SelectToken('product.variants', ShopifyVariants);  //Raise error
        end;
        ShopifyProductTitle := _JsonHelper.GetJText(ShopifyResponse, 'product.title', MaxStrLen(SpfyStoreItemLink."Shopify Name"), false);
        ShopifyProductDetailedDescr := _JsonHelper.GetJText(ShopifyResponse, 'product.descriptionHtml', false);
        if ShopifyProductDetailedDescr = '' then
            ShopifyProductDetailedDescr := _JsonHelper.GetJText(ShopifyResponse, 'product.body_html', false);
        ShopifyProductStatus := _JsonHelper.GetJText(ShopifyResponse, 'product.status', false);
        BCIsNameDescriptionMaster := _SpfyIntegrationMgt.IsSendShopifyNameAndDescription(NcTask."Store Code");

        FirstVariant := true;
        foreach ShopifyVariant in ShopifyVariants.AsArray() do begin
            SpfyItemMgt.ParseItem(ShopifyVariant, ItemVariant, VariantSku);
            if FirstVariant or (ItemVariant.Code = '') then begin
                SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
                SpfyStoreItemLink."Item No." := ItemVariant."Item No.";
                SpfyStoreItemLink."Variant Code" := '';
                SpfyStoreItemLink."Shopify Store Code" := NcTask."Store Code";
                LinkExists := SpfyStoreItemLink.Find();
                if NcTask.Type = NcTask.Type::Delete then begin
                    DisableIntegrationForItem(SpfyStoreItemLink);
                    if LinkExists then
                        ModifySpfyStoreItemLink(SpfyStoreItemLink, true);
                    exit;
                end;
                if not LinkExists then begin
                    SpfyStoreItemLink.Init();
                    SpfyStoreItemLink.Insert();
                end;
                if CalledByWebhook then
                    SpfyStoreItemLink."Sync. to this Store" := true;
                xSyncEnabled := SpfyStoreItemLink."Synchronization Is Enabled";
                SpfyStoreItemLink."Synchronization Is Enabled" := SpfyStoreItemLink."Sync. to this Store";

                if ShopifyProductStatus <> '' then
                    if Evaluate(SpfyStoreItemLink."Shopify Status", UpperCase(ShopifyProductStatus)) then;
                if ((ShopifyProductTitle <> '') or not BCIsNameDescriptionMaster) and (SpfyStoreItemLink."Shopify Name" <> ShopifyProductTitle) then
                    SpfyStoreItemLink."Shopify Name" := CopyStr(ShopifyProductTitle, 1, MaxStrLen(SpfyStoreItemLink."Shopify Name"));
                if (ShopifyProductDetailedDescr <> '') or not BCIsNameDescriptionMaster then
                    SpfyStoreItemLink.SetShopifyDescription(ShopifyProductDetailedDescr);

                ModifySpfyStoreItemLink(SpfyStoreItemLink, true);
                xShopifyItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyItemID, false);
                UpdateMetafieldsFromShopify(SpfyStoreItemLink, ShopifyItemID);

                if (CalledByWebhook and not xSyncEnabled) or ((xShopifyItemID <> '') and (ShopifyItemID <> xShopifyItemID)) then begin
                    RecalculateInventoryLevels(SpfyStoreItemLink);
                    RecalculatePrices(SpfyStoreItemLink);
                end;
                FirstVariant := false;
            end;
            UpdateItemVariant(NcTask."Store Code", ShopifyVariant, ItemVariant);
        end;
    end;

    local procedure UpdateItemVariantWithDataFromShopify(ShopifyStoreCode: Code[20]; ShopifyResponse: JsonToken)
    var
        ItemVariant: Record "Item Variant";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        ShopifyVariant: JsonToken;
        VariantSku: Text;
    begin
        ShopifyResponse.SelectToken('variant', ShopifyVariant);
        SpfyItemMgt.ParseItem(ShopifyVariant, ItemVariant, VariantSku);
        UpdateItemVariant(ShopifyStoreCode, ShopifyVariant, ItemVariant);
    end;

    local procedure UpdateItemVariant(ShopifyStoreCode: Code[20]; ShopifyVariant: JsonToken; ItemVariant: Record "Item Variant")
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyInventoryItemID: Text[30];
        xShopifyInventoryItemID: Text[30];
        ShopifyVariantID: Text[30];
        xShopifyVariantID: Text[30];
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;

#pragma warning disable AA0139
        ShopifyVariantID := _JsonHelper.GetJText(ShopifyVariant, 'id', MaxStrLen(ShopifyVariantID), true);
        ShopifyInventoryItemID := _JsonHelper.GetJText(ShopifyVariant, 'inventory_item_id', MaxStrLen(ShopifyVariantID), true);
#pragma warning restore AA0139
        xShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        xShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);

        if ((xShopifyVariantID <> '') and (ShopifyVariantID <> xShopifyVariantID)) or
           ((xShopifyInventoryItemID <> '') and (ShopifyInventoryItemID <> xShopifyInventoryItemID))
        then begin
            RecalculateInventoryLevels(SpfyStoreItemVariantLink);
            RecalculatePrices(SpfyStoreItemVariantLink);
        end;

        if ShopifyVariantID <> '' then
            UpdateMetafieldsFromShopify(SpfyStoreItemVariantLink, ShopifyVariantID);
    end;

    local procedure UpdateMetafieldsFromShopify(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ShopifyOwnerID: Text[30])
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type";
    begin
        case SpfyStoreItemLink.Type of
            SpfyStoreItemLink.Type::Item:
                ShopifyOwnerType := ShopifyOwnerType::PRODUCT;
            SpfyStoreItemLink.Type::"Variant":
                ShopifyOwnerType := ShopifyOwnerType::PRODUCTVARIANT;
            else
                exit;
        end;
        SpfyMetafieldMgt.RequestMetafieldValuesFromShopifyAndUpdateBCData(SpfyStoreItemLink.RecordId(), ShopifyOwnerType, ShopifyOwnerID, SpfyStoreItemLink."Shopify Store Code");
    end;

    local procedure RecalculateInventoryLevels(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        Item: Record Item;
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
    begin
        Item.SetRange("No.", SpfyStoreItemLink."Item No.");
        if SpfyStoreItemLink."Variant Code" <> '' then
            Item.SetRange("Variant Filter", SpfyStoreItemLink."Variant Code");
        InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemLink);
        InventoryLevelMgt.InitializeInventoryLevels(SpfyStoreItemLink."Shopify Store Code", Item, true);
    end;

    local procedure RecalculatePrices(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        SpfyItemMgt.UpdateItemPrices(SpfyStoreItemLink);
    end;

    procedure SelectShopifyLocation(ShopifyStoreCode: Code[20]; var SelectedLocationID: Text[30]): Boolean
    var
        TempShopifyLocation: Record "NPR Spfy Location" temporary;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ReceivedShopifyLocations: JsonArray;
        ReceivedShopifyLocation: JsonToken;
        ShopifyResponse: JsonToken;
        Window: Dialog;
    begin
        Window.Open(_QueryingShopifyLbl);
        ClearLastError();
        if not SpfyCommunicationHandler.GetShopifyLocations(ShopifyStoreCode, ShopifyResponse) then
            Error(GetLastErrorText());
        ShopifyResponse.AsObject().Get('locations', ShopifyResponse);
        ReceivedShopifyLocations := ShopifyResponse.AsArray();
        foreach ReceivedShopifyLocation in ReceivedShopifyLocations do begin
            TempShopifyLocation.Init();
#pragma warning disable AA0139
            TempShopifyLocation.ID := _JsonHelper.GetJText(ReceivedShopifyLocation, 'id', MaxStrLen(TempShopifyLocation.ID), true);
            if not TempShopifyLocation.Find() then begin
                TempShopifyLocation.Name := _JsonHelper.GetJText(ReceivedShopifyLocation, 'name', MaxStrLen(TempShopifyLocation.Name), false);
                TempShopifyLocation.Address := _JsonHelper.GetJText(ReceivedShopifyLocation, 'address1', MaxStrLen(TempShopifyLocation.Address), false);
                TempShopifyLocation."Address 2" := _JsonHelper.GetJText(ReceivedShopifyLocation, 'address2', MaxStrLen(TempShopifyLocation."Address 2"), false);
                TempShopifyLocation.City := _JsonHelper.GetJText(ReceivedShopifyLocation, 'city', MaxStrLen(TempShopifyLocation.City), false);
                TempShopifyLocation."Post Code" := _JsonHelper.GetJText(ReceivedShopifyLocation, 'zip', MaxStrLen(TempShopifyLocation."Post Code"), false);
                TempShopifyLocation."Country/Region Code" := _JsonHelper.GetJText(ReceivedShopifyLocation, 'country_code', MaxStrLen(TempShopifyLocation."Country/Region Code"), false);
#pragma warning restore AA0139
                TempShopifyLocation.Active := _JsonHelper.GetJBoolean(ReceivedShopifyLocation, 'active', false);
                TempShopifyLocation.Insert();
            end;
        end;
        Window.Close();
        if Page.RunModal(Page::"NPR Spfy Locations", TempShopifyLocation) = Action::LookupOK then begin
            SelectedLocationID := TempShopifyLocation.ID;
            exit(true);
        end;
        exit(false);
    end;

    procedure GetShopifyItemID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyVariantIDs(SpfyStoreItemLink, WithDialog, _ShopifyProductID, _ShopifyVariantID, _ShopifyInventoryItemID) then
            exit(_ShopifyProductID);
        Error(GetLastErrorText());
    end;

    procedure GetShopifyVariantID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyVariantIDs(SpfyStoreItemLink, WithDialog, _ShopifyProductID, _ShopifyVariantID, _ShopifyInventoryItemID) then
            exit(_ShopifyVariantID);
        Error(GetLastErrorText());
    end;

    procedure GetShopifyInventoryItemID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyVariantIDs(SpfyStoreItemLink, WithDialog, _ShopifyProductID, _ShopifyVariantID, _ShopifyInventoryItemID) then
            exit(_ShopifyInventoryItemID);
        Error(GetLastErrorText());
    end;

    local procedure TryGetShopifyVariantIDs(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean; var ShopifyProductID: Text[30]; var ShopifyVariantID: Text[30]; var ShopifyInventoryItemID: Text[30]): Boolean
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OStream: OutStream;
        ShopifyResponse: JsonToken;
        RequestJson: JsonObject;
        Window: Dialog;
        ReceivedShopifyID: Text;
        SkuFilterString: Text;
        Success: Boolean;
        ProductGraphQLQueryTok: Label '{ products(first: 1, query: "%1") {edges{node{id}}}}', Locked = true;
        ProductVariantGraphQLQueryTok: Label '{ productVariants(first: 1, query: "sku:%1") {edges{node{id product{id} inventoryItem{id}}}}}', Locked = true;
    begin
        if (SpfyStoreItemLink."Item No." = _LastQueriedSpfyStoreItemLink."Item No.") and
           (SpfyStoreItemLink."Variant Code" = _LastQueriedSpfyStoreItemLink."Variant Code") and
           (SpfyStoreItemLink."Shopify Store Code" = _LastQueriedSpfyStoreItemLink."Shopify Store Code")
        then
            exit(true);
        if WithDialog then
            Window.Open(_QueryingShopifyLbl);
        RequestJson.Add('query', StrSubstNo(ProductVariantGraphQLQueryTok, SpfyItemMgt.GetProductVariantSku(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Variant Code")));

        TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        TempNcTask."Data Output".CreateOutStream(OStream);
        RequestJson.WriteTo(OStream);

        ClearLastError();
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, true, ShopifyResponse);
        if Success then begin
            ReceivedShopifyID :=
                _JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''productVariants''].[''edges''][0].[''node''].[''product''].[''id'']', false);
            ShopifyProductID := CopyStr(_SpfyIntegrationMgt.RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyProductID));

            ReceivedShopifyID :=
                _JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''productVariants''].[''edges''][0].[''node''].[''id'']', false);
            ShopifyVariantID := CopyStr(_SpfyIntegrationMgt.RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyVariantID));

            ReceivedShopifyID :=
                _JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''productVariants''].[''edges''][0].[''node''].[''inventoryItem''].[''id'']', false);
            ShopifyInventoryItemID := CopyStr(_SpfyIntegrationMgt.RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyInventoryItemID));

            if (ShopifyProductID = '') and (SpfyStoreItemLink."Variant Code" = '') then begin
                SkuFilterString := GenerateItemVariantSKUsGraphQLFilter(SpfyStoreItemLink."Item No.");
                if SkuFilterString <> '' then begin
                    Clear(RequestJson);
                    RequestJson.Add('query', StrSubstNo(ProductGraphQLQueryTok, SkuFilterString));
                    Clear(TempNcTask);
                    TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
                    TempNcTask."Data Output".CreateOutStream(OStream);
                    RequestJson.WriteTo(OStream);

                    ClearLastError();
                    Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, true, ShopifyResponse);
                    if Success then begin
                        ReceivedShopifyID :=
                            _JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''products''].[''edges''][0].[''node''].[''id'']', false);
                        ShopifyProductID := CopyStr(_SpfyIntegrationMgt.RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyProductID));
                    end;
                end;
            end;

            _LastQueriedSpfyStoreItemLink := SpfyStoreItemLink;
        end;

        if WithDialog then
            Window.Close();
        exit(Success);
    end;

    local procedure GenerateItemVariantSKUsGraphQLFilter(ItemNo: Code[20]) FilterString: Text
    var
        ItemVariant: Record "Item Variant";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        MaxNumberOfVariants: Integer;
        NumberOfVariantsIncluded: Integer;
        OrClauseTok: Label ' OR ', Locked = true;
        SkuTok: Label 'sku:%1', Locked = true;
    begin
        FilterString := '';
        MaxNumberOfVariants := 10;
        NumberOfVariantsIncluded := 0;
        ItemVariant.SetRange("Item No.", ItemNo);
#IF BC18 or BC19 or BC20 or BC21 or BC22
        ItemVariant.SetRange("NPR Blocked", false);
#ELSE
        ItemVariant.SetRange(Blocked, false);
#ENDIF
        if ItemVariant.FindSet() then
            repeat
                if FilterString <> '' then
                    FilterString := FilterString + OrClauseTok;
                FilterString := FilterString + StrSubstNo(SkuTok, SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code));
                NumberOfVariantsIncluded += 1;
            until (ItemVariant.Next() = 0) or (NumberOfVariantsIncluded >= MaxNumberOfVariants);
    end;

    local procedure RequestAndUpdateAuxiliaryProductData(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ShopifyProductID: Text[30])
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        OStream: OutStream;
        ShopifyResponse: JsonToken;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        ReceivedShopifyString: Text;
        Success: Boolean;
        QueryTok: Label 'query GetProduct($productID: ID!) {product(id: $productID) {id title status descriptionHtml}}', Locked = true;
    begin
        VariablesJson.Add('productID', StrSubstNo('gid://shopify/Product/%1', ShopifyProductID));
        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);

        TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        TempNcTask."Data Output".CreateOutStream(OStream);
        RequestJson.WriteTo(OStream);

        ClearLastError();
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, true, ShopifyResponse);
        if not Success then
            exit;

        ReceivedShopifyString := _JsonHelper.GetJText(ShopifyResponse, 'data.product.title', false);
        if ReceivedShopifyString <> '' then
            SpfyStoreItemLink."Shopify Name" := CopyStr(ReceivedShopifyString, 1, MaxStrLen(SpfyStoreItemLink."Shopify Name"));
        ReceivedShopifyString := _JsonHelper.GetJText(ShopifyResponse, 'data.product.descriptionHtml', false);
        if ReceivedShopifyString <> '' then
            SpfyStoreItemLink.SetShopifyDescription(ReceivedShopifyString);
        ReceivedShopifyString := _JsonHelper.GetJText(ShopifyResponse, 'data.product.status', false);
        if ReceivedShopifyString <> '' then
            if Evaluate(SpfyStoreItemLink."Shopify Status", UpperCase(ReceivedShopifyString)) then;
    end;

    local procedure GenerateTmpItemVariantList(Item: Record Item; var ItemVariantOut: Record "Item Variant")
    var
        ItemVariant: Record "Item Variant";
    begin
        if not ItemVariantOut.IsTemporary() then
            FunctionCallOnNonTempVarErr('GenerateTmpItemVariantList()');

        ItemVariantOut.Reset();
        ItemVariantOut.DeleteAll();

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then
            repeat
                ItemVariantOut := ItemVariant;
                ItemVariantOut.Insert();
            until ItemVariant.Next() = 0;

        ItemVariantOut.Init();
        ItemVariantOut."Item No." := Item."No.";
        ItemVariantOut.Code := '';
        if ItemVariantOut.Insert() then;
    end;

    procedure EnableIntegrationForItemsAlreadyOnShopify(ShopifyStoreCode: Code[20]; WithDialog: Boolean)
    var
        ItemResycnOptions: Report "NPR Spfy Item Re-sycn Options";
    begin
        Clear(ItemResycnOptions);
        ItemResycnOptions.SetOptions(ShopifyStoreCode, WithDialog);
        ItemResycnOptions.UseRequestPage(WithDialog);
        ItemResycnOptions.Run();
    end;

    procedure MarkItemAlreadyOnShopify(Item: Record Item; var ShopifyStore: Record "NPR Spfy Store"; DisableDataLog: Boolean; CreateAtShopify: Boolean; WithDialog: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyIDFound: Boolean;
    begin
        if CreateAtShopify then
            DisableDataLog := false;

        if ShopifyStore.FindSet() then
            repeat
                UpdateIntegrationStatusForItem(ShopifyStore.Code, Item, DisableDataLog, CreateAtShopify, WithDialog);
            until ShopifyStore.Next() = 0;
        if CreateAtShopify then
            exit;

        SpfyStoreItemLink.SetCurrentKey(Type, "Item No.", "Variant Code", "Synchronization Is Enabled");
        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Item No.", Item."No.");
        SpfyStoreItemLink.SetRange("Variant Code", '');
        SpfyStoreItemLink.SetRange("Synchronization Is Enabled", true);
        if not SpfyStoreItemLink.IsEmpty() then
            exit;
        SpfyStoreItemLink.SetRange("Synchronization Is Enabled");
        if not SpfyStoreItemLink.FindSet() then
            exit;

        ShopifyIDFound := false;
        repeat
            ShopifyIDFound := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '';
            if not ShopifyIDFound then begin
                SpfyStoreItemVariantLink := SpfyStoreItemLink;
                SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
                ShopifyIDFound := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '';
                if not ShopifyIDFound then
                    ShopifyIDFound := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID") <> '';
            end;
        until ShopifyIDFound or (SpfyStoreItemLink.Next() = 0);

        if not ShopifyIDFound then
            SpfyStoreItemLink.DeleteAll(true);
    end;

    local procedure UpdateIntegrationStatusForItem(ShopifyStoreCode: Code[20]; Item: Record Item; DisableDataLog: Boolean; CreateAtShopify: Boolean; WithDialog: Boolean)
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        ShopifyInventoryItemID: Text[30];
        ShopifyProductID: Text[30];
        xShopifyProductID: Text[30];
        ShopifyVariantID: Text[30];
        LinkExists: Boolean;
    begin
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
        SpfyStoreItemLink."Item No." := Item."No.";
        SpfyStoreItemLink."Variant Code" := '';
        SpfyStoreItemLink."Shopify Store Code" := ShopifyStoreCode;
        LinkExists := SpfyStoreItemLink.Find();
        if not LinkExists then
            SpfyStoreItemLink.Init();

        ShopifyProductID := GetShopifyItemID(SpfyStoreItemLink, WithDialog);
        if ShopifyProductID = '' then begin
            if not LinkExists and CreateAtShopify then begin
                SpfyStoreLinkMgt.UpdateStoreItemLinks(Item);
                LinkExists := SpfyStoreItemLink.Find();
            end;
            if LinkExists and (SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled" or CreateAtShopify) then begin
                if SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled" then begin
                    DisableIntegrationForItem(SpfyStoreItemLink);
                    ModifySpfyStoreItemLink(SpfyStoreItemLink, DisableDataLog or CreateAtShopify);
                end;
                if CreateAtShopify then begin
                    SpfyStoreItemLink."Sync. to this Store" := true;
                    ModifySpfyStoreItemLink(SpfyStoreItemLink, false);
                end;
            end;
            exit;
        end;

        SpfyStoreLinkMgt.UpdateStoreItemLinks(Item);
        SpfyStoreItemLink.Find();
        xShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        SpfyStoreItemVariantLink := SpfyStoreItemLink;
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;

        //TODO: refactor for Shopify item integration with master/slave item approach
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyProductID, false);
        RequestAndUpdateAuxiliaryProductData(SpfyStoreItemLink, ShopifyProductID);
        SpfyMetafieldMgt.RequestMetafieldValuesFromShopifyAndUpdateBCData(SpfyStoreItemLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCT, ShopifyProductID, SpfyStoreItemLink."Shopify Store Code");

        ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
        if ShopifyVariantID <> '' then
            SpfyMetafieldMgt.RequestMetafieldValuesFromShopifyAndUpdateBCData(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCTVARIANT, ShopifyVariantID, SpfyStoreItemVariantLink."Shopify Store Code");

        ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemVariantLink, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then
            repeat
                SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
                SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
                if ShopifyVariantID <> '' then
                    SpfyMetafieldMgt.RequestMetafieldValuesFromShopifyAndUpdateBCData(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCTVARIANT, ShopifyVariantID, SpfyStoreItemVariantLink."Shopify Store Code");

                ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemVariantLink, false);
                SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
            until ItemVariant.Next() = 0;

        SpfyStoreItemLink."Sync. to this Store" := true;
        SpfyStoreItemLink."Synchronization Is Enabled" := true;
        ModifySpfyStoreItemLink(SpfyStoreItemLink, DisableDataLog);

        if (xShopifyProductID <> '') and (ShopifyProductID <> xShopifyProductID) then begin
            RecalculateInventoryLevels(SpfyStoreItemLink);
            RecalculatePrices(SpfyStoreItemLink);
        end;
        if not DisableDataLog then
            SpfyItemMgt.ScheduleTagsSync(SpfyStoreItemLink, Item."Item Category Code", '');
    end;

    local procedure ModifySpfyStoreItemLink(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; DisableDataLog: Boolean)
    var
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        if DisableDataLog then
            DataLogMgt.DisableDataLog(true);
        SpfyStoreItemLink.Modify(true);
        if DisableDataLog then
            DataLogMgt.DisableDataLog(false);
    end;

    local procedure DisableIntegrationForItem(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        ItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
    begin
        SpfyStoreItemVariantLink := SpfyStoreItemLink;
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;

        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        ClearVariantsShopifyIDs(SpfyStoreItemLink);
        InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemLink);
        ItemPriceMgt.ClearItemPrices(SpfyStoreItemLink);

        SpfyStoreItemLink."Sync. to this Store" := false;
        SpfyStoreItemLink."Synchronization Is Enabled" := false;
        SpfyStoreItemLink."Shopify Status" := SpfyStoreItemLink."Shopify Status"::" ";
        SpfyStoreItemLink."Shopify Name" := '';
        Clear(SpfyStoreItemLink."Shopify Description");
    end;

    local procedure ClearVariantsShopifyIDs(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
    begin
        SpfyStoreItemVariantLink := SpfyStoreItemLink;
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;

        ItemVariant.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if ItemVariant.FindSet() then
            repeat
                SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                ClearVariantShopifyIDs(SpfyStoreItemVariantLink);
            until ItemVariant.Next() = 0;
    end;

    internal procedure ClearVariantShopifyIDs(SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    begin
        _SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Send Items&Inventory(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy Send Items&Inventory");
    end;

    local procedure SetNcTaskPostponed(var NcTaskIn: Record "NPR Nc Task"; var RequestString: Text) Success: Boolean
    var
        NcTask: Record "NPR Nc Task";
        MutationQueryRequestLabel: Label 'mutation UpdateProductVariants { %1 }', Locked = true, Comment = '%1 = Update Product Variants Array';
        IStream: InStream;
        productVariantsBulkUpdateRequestStringPart: Text;
        productVariantsBulkUpdateRequestStringTextBuilder: TextBuilder;
    begin
        if not NcTaskIn.IsTemporary() then
            FunctionCallOnNonTempVarErr('SetNcTaskPostponed');
        if not NcTaskIn.FindSet() then
            exit;

#if not (BC18 or BC19 or BC20 or BC21)
        NcTask.ReadIsolation := IsolationLevel::UpdLock;
#else
        NcTask.LockTable();
#endif

        productVariantsBulkUpdateRequestStringTextBuilder.Clear();
        repeat
            if NcTask.Get(NcTaskIn."Entry No.") and (not NcTaskIn.Processed and not NcTaskIn.Postponed) then begin
                if NcTaskIn."Process Error" then begin
                    NcTaskIn.CalcFields(Response);
                    NcTask.Response := NcTaskIn.Response;
                    NcTask."Process Error" := true;
                    NcTask."Last Processing Completed at" := CurrentDateTime();
                    NcTaskIn.Delete();
                end else begin
                    NcTask.Postponed := true;
                    NcTask."Postponed At" := CurrentDateTime();
                    NcTask."Last Processing Completed at" := 0DT;
                    NcTaskIn.CalcFields("Data Output");
                    NcTask."Data Output" := NcTaskIn."Data Output";
                    NcTask."Data Output".CreateInStream(IStream, TextEncoding::UTF8);
                    IStream.ReadText(productVariantsBulkUpdateRequestStringPart);
                    productVariantsBulkUpdateRequestStringTextBuilder.Append(productVariantsBulkUpdateRequestStringPart);
                    Success := true;
                end;
                NcTask."Last Processing Started at" := NcTaskIn."Last Processing Started at";
                NcTask."Last Processing Duration" := 0;
                NcTask."Process Count" += 1;

                NcTask.Modify();
            end else
                NcTaskIn.Delete();
        until NcTaskIn.Next() = 0;
        Commit();
        RequestString := StrSubstNo(MutationQueryRequestLabel, productVariantsBulkUpdateRequestStringTextBuilder.ToText());
    end;

    local procedure CreateNcTaskParam(var NcTaskIn: Record "NPR Nc Task"; var NcTaskParam: Record "NPR Nc Task"; productVariantsBulkUpdateRequest: Text)
    var
        OStream: OutStream;
        RequestJObject: JsonObject;
    begin
        Clear(NcTaskParam);
        if not NcTaskIn.FindFirst() then
            exit;
        if productVariantsBulkUpdateRequest = '' then
            exit;

        NcTaskParam."Entry No." := 0;
        NcTaskParam."Task Processor Code" := NcTaskIn."Task Processor Code";
        NcTaskParam.Type := NcTaskIn.Type;
        NcTaskParam."Company Name" := NcTaskIn."Company Name";
        NcTaskParam."Table No." := NcTaskIn."Table No.";
        NcTaskParam."Table Name" := NcTaskIn."Table Name";
        NcTaskParam."Store Code" := NcTaskIn."Store Code";
        NcTaskParam."Not Before Date-Time" := NcTaskIn."Not Before Date-Time";
        RequestJObject.Add('query', productVariantsBulkUpdateRequest);
        NcTaskParam."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        RequestJObject.WriteTo(OStream);
    end;

    local procedure GetProductVariantForItemPrice(var ItemPrice: Record "NPR Spfy Item Price"; var ShopifyVariantID: Text[30])
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::"Variant";
        SpfyStoreItemLink."Item No." := ItemPrice."Item No.";
        SpfyStoreItemLink."Variant Code" := ItemPrice."Variant Code";
        SpfyStoreItemLink."Shopify Store Code" := ItemPrice."Shopify Store Code";

        ShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyVariantID = '' then
            ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemLink, false);
    end;

    local procedure FindNcTaskInDictionary(var NcTaskIn: Record "NPR Nc Task"; ResponseDictionary: Dictionary of [Text[30], Dictionary of [Text[30], Text]]; var NcTaskErrorText: Text): Boolean
    var
        NcTaskNotFoundLbl: Label 'Nc Task %1 was not found in the Shopify response.';
        InvalidProductVariantIDLbl: Label 'Product Variant ID %1 could not be validated.';
        NcTaskResultDictionary: Dictionary of [Text[30], Text];
    begin
        Clear(NcTaskErrorText);
        if not ResponseDictionary.ContainsKey(StrSubstNo('NCTask%1', Format(NcTaskIn."Entry No."))) then begin
            NcTaskErrorText := StrSubstNo(NcTaskNotFoundLbl, Format(NcTaskIn."Entry No."));
            exit;
        end;

        NcTaskResultDictionary := ResponseDictionary.Get(StrSubstNo('NCTask%1', Format(NcTaskIn."Entry No.")));
        case true of
            NcTaskResultDictionary.ContainsKey('VariantID'):
                begin
                    if not ValidateProductVariantId(NcTaskIn, CopyStr(NcTaskResultDictionary.Get('VariantID'), 1, 30)) then begin
                        NcTaskErrorText := StrSubstNo(InvalidProductVariantIDLbl, NcTaskResultDictionary.Get('VariantID'));
                        exit;
                    end;
                    exit(true);
                end;
            NcTaskResultDictionary.ContainsKey('Error'):
                begin
                    NcTaskErrorText := NcTaskResultDictionary.Get('Error');
                    exit;
                end;
        end;
    end;
}
#endif