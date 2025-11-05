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
                BulkSendItemVariants(Rec);
            Database::"Inventory Buffer":
                SendItemCost(Rec);
            Database::"NPR Spfy Entity Metafield":
                SendMetafields();
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
        _InventoryIntegrIsEnabled, _ItemPriceIntegrIsEnabled : Boolean;
        _InventoryItemIDNotFoundErr: Label 'Shopify Inventory Item ID could not be found for %1=%2, %3=%4 at Shopify Store %5', Comment = '%1 = Item No. fieldcaption, %2 = Item No., %3 = Variant Code fieldcaption, %4 = Variant Code, %5 = Shopify Store Code';
        _ItemIntegrNotEnabledErr: Label 'Shopify integration is not enabled for the item.';
        _QueryingShopifyLbl: Label 'Querying Shopify...';


    local procedure SendItem(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ShopifyProductID: Text[30];
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := true;

        PrepareItemUpdateRequest(NcTask);
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');  //The system will record Shopify response as the error message

#pragma warning disable AA0139
        case NcTask.Type of
            NcTask.Type::Insert:
                ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.productSet.product.id', true), '/');
            NcTask.Type::Modify:
                ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.productUpdate.product.id', true), '/');
            NcTask.Type::Delete:
                ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.productDelete.deletedProductId', true), '/');
        end;
#pragma warning restore AA0139
        RetrieveShopifyProductAndUpdateItemWithDataFromShopify(NcTask, ShopifyProductID, false, false);
    end;

    local procedure SendTags(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
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
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');  //The system will record Shopify response as the error message
    end;

    local procedure BulkSendItemVariants(var NcTask: Record "NPR Nc Task")
    var
        TempIncomingNcTasks: Record "NPR Nc Task" temporary;
        TempNcTaskToProcess: Record "NPR Nc Task" temporary;
        TempRequestedVariantBuffer: Record "NPR Spfy ID/Task Buffer" temporary;
        ShopifyRequest: JsonObject;
        ShopifyProductID: Text[30];
        RequestType: Integer;
    begin
        if not NcTask.FindSet() then
            exit;
        RefreshIntegrationStatus(NcTask."Store Code");
        repeat
            TempIncomingNcTasks := NcTask;
            TempIncomingNcTasks.Insert();
        until NcTask.Next() = 0;

        while PrepareBulkItemVariantUpdateRequest(TempIncomingNcTasks, TempNcTaskToProcess, ShopifyProductID) do
            for RequestType := NcTask.Type::Insert to NcTask.Type::Delete do begin
                TempNcTaskToProcess.SetRange(Type, RequestType);
                if not TempNcTaskToProcess.IsEmpty() then
                    if GenerateRequestAndSetNcTaskPostponed(TempNcTaskToProcess, ShopifyProductID, TempRequestedVariantBuffer, ShopifyRequest) then
                        ProcessAndUpdateNCTasksWithDataFromShopify(TempNcTaskToProcess, TempRequestedVariantBuffer, ShopifyRequest);
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

    local procedure SendMetafields()
    var
        WrongCodeunitErr: Label 'The codeunit specified in the NaviConnect Task Setup for Metafield updates (table 6150951 "NPR Spfy Entity Metafield") is incorrect. Please change it from codeunit 6184819 "NPR Spfy Send Items&Inventory" to codeunit 6248554 "NPR Spfy Send Metafields".';
    begin
        Error(WrongCodeunitErr);
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
        TempIncomingNcTasks: Record "NPR Nc Task" temporary;
        TempNcTask: Record "NPR Nc Task" temporary;
        productVariantsBulkUpdateRequestString: Text;
    begin
        if not NcTask.FindSet() then
            exit;
        repeat
            TempIncomingNcTasks := NcTask;
            TempIncomingNcTasks.Insert();
        until NcTask.Next() = 0;

        while PrepareItemPriceUpdateRequest(TempIncomingNcTasks, TempNcTask) do
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
        if not NcTaskIn.FindSet() then
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

        repeat
            if Success then
                Found := FindNcTaskInDictionary(NcTaskIn, ResponseDictionary, NcTaskErrorText);
            MarkNcTaskAsCompleted(NcTaskIn."Entry No.", ShopifyResponse, Success and Found, NcTaskErrorText);
        until NcTaskIn.Next() = 0;
    end;

    local procedure ProcessAndUpdateNCTasksWithDataFromShopify(var NcTaskIn: Record "NPR Nc Task"; var RequestedVariantBuffer: Record "NPR Spfy ID/Task Buffer"; ShopifyRequest: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ResponseDataSet: JsonToken;
        ShopifyResponse: JsonToken;
        ShopifyResponseUserErrors: JsonToken;
        ShopifyResponseVariants: JsonToken;
        UserError: JsonToken;
        VariantJToken: JsonToken;
        OStream: OutStream;
        VariantNo: Integer;
        DataKey: Text;
        RequestErrorText: Text;
        Success: Boolean;
    begin
        if not NcTaskIn.FindFirst() then
            exit;

        NcTask."Store Code" := NcTaskIn."Store Code";
        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyRequest.WriteTo(OStream);

        ClearLastError();
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);
        if not Success then
            RequestErrorText := GetLastErrorText();

        if Success then
            if ShopifyResponse.SelectToken('data', ResponseDataSet) and ResponseDataSet.IsObject() then
                foreach DataKey in ResponseDataSet.AsObject().Keys() do begin
                    if ResponseDataSet.SelectToken(DataKey + '.userErrors', ShopifyResponseUserErrors) and ShopifyResponseUserErrors.IsArray() then
                        if ShopifyResponseUserErrors.AsArray().Count() > 0 then
                            foreach UserError in ShopifyResponseUserErrors.AsArray() do
                                if _JsonHelper.GetJText(UserError, 'field[0]', false) in ['variants', 'variantsIds'] then
                                    if Evaluate(VariantNo, _JsonHelper.GetJText(UserError, 'field[1]', false)) then
                                        if RequestedVariantBuffer.Get(VariantNo) then
                                            if NcTaskIn.Get(RequestedVariantBuffer."Nc Task Entry No.") then begin
                                                MarkNcTaskAsCompleted(NcTaskIn."Entry No.", UserError, false, _JsonHelper.GetJText(UserError, 'message', false));
                                                NcTaskIn.Delete();
                                            end;

                    if ResponseDataSet.SelectToken(DataKey + '.productVariants', ShopifyResponseVariants) and ShopifyResponseVariants.IsArray() then
                        if ShopifyResponseVariants.AsArray().Count() > 0 then
                            foreach VariantJToken in ShopifyResponseVariants.AsArray() do
#pragma warning disable AA0139
                                if RequestedVariantBuffer.RecordValueExists(_SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(VariantJToken, 'sku', true), '/')) then
#pragma warning restore AA0139
                                    if NcTaskIn.Get(RequestedVariantBuffer."Nc Task Entry No.") then begin
                                        MarkNcTaskAsCompleted(NcTaskIn."Entry No.", VariantJToken, true, '');
                                        NcTaskIn.Delete();
                                    end;
                end;

        //Variants not in response
        if NcTaskIn.FindSet() then
            repeat
                MarkNcTaskAsCompleted(NcTaskIn."Entry No.", ShopifyResponse, Success, RequestErrorText);
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
#pragma warning disable AA0139
                NcTaskResult.Add('VariantID', _SpfyIntegrationMgt.RemoveUntil(ProductVariantIDJToken.AsValue().AsText(), '/'));
#pragma warning restore AA0139
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
        ItemVariant: Record "Item Variant";
        NcTask: Record "NPR Nc Task";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        ItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
        RecRef: RecordRef;
        OStream: OutStream;
    begin
#if not (BC18 or BC19 or BC20 or BC21)
        NcTask.ReadIsolation := IsolationLevel::UpdLock;
#else
        NcTask.LockTable();
#endif
        if not NcTask.Get(NcTaskInEntryNo) or NcTask.Processed then
            exit;

        NcTask."Last Processing Completed at" := CurrentDateTime();
        NcTask."Last Processing Duration" := (NcTask."Last Processing Completed at" - NcTask."Last Processing Started at") / 1000;
        NcTask.Postponed := false;
        NcTask."Postponed At" := 0DT;
        NcTask.Processed := Success;
        NcTask."Process Error" := not Success;

        NcTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        if ErrorText = '' then
            ShopifyResponse.WriteTo(OStream)
        else
            OStream.WriteText(ErrorText);
        NcTask.Modify(true);

        if Success and (NcTask."Table No." = Database::"Item Variant") then
            case NcTask.Type of
                NcTask.Type::Insert, NcTask.Type::Modify:
                    UpdateItemVariantWithDataFromShopify(NcTask."Store Code", ShopifyResponse);
                NcTask.Type::Delete:
                    begin
                        RecRef := NcTask."Record ID".GetRecord();
                        RecRef.SetTable(ItemVariant);
                        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
                        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
                        SpfyStoreItemVariantLink."Variant Code" := ItemVariant."Code";
                        SpfyStoreItemVariantLink."Shopify Store Code" := NcTask."Store Code";
                        ClearVariantShopifyIDs(SpfyStoreItemVariantLink);
                        InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemVariantLink);
                        ItemPriceMgt.ClearItemPrices(SpfyStoreItemVariantLink);
                    end;
            end;

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

        ShopifyVariantIDComparison := GetProductVariantForItemPrice(ItemPrice);
        if ShopifyVariantIDComparison = '' then
            exit;
        if ShopifyVariantID <> ShopifyVariantIDComparison then
            exit;
        exit(true);
    end;

    local procedure PrepareItemUpdateRequest(var NcTask: Record "NPR Nc Task")
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        ProductVariantsJArray: JsonArray;
        ProductJObject: JsonObject;
        Request: JsonObject;
        Variables: JsonObject;
        OStream: OutStream;
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
        ShopifyProductID: Text[30];
        ShopifyProductIDEmptyErr: Label 'Shopify Product Id must be specified for %1', Comment = '%1 - Item record id';
        ProductDelete_QueryTok: Label 'mutation DeleteProduct($productSet: ProductDeleteInput!) {productDelete(input: $productSet) {deletedProductId userErrors{field message}}}', Locked = true;
        ProductInsert_QueryTok: Label 'mutation CreateProduct($productSet: ProductSetInput!, $synchronous: Boolean!) {productSet(synchronous: $synchronous, input: $productSet) {product{id} userErrors{field message}}}', Locked = true;
        ProductUpdate_QueryTok: Label 'mutation UpdateProduct($productSet: ProductUpdateInput!) {productUpdate(product: $productSet) {product{id} userErrors{field message}}}', Locked = true;
        ProductWithDefaultVariantUpdate_QueryTok: Label 'mutation UpdateProductWithDefaultVariant($productSet: ProductUpdateInput!, $productId: ID!, $variants: [ProductVariantsBulkInput!]!) {productUpdate(product: $productSet) {product{id} userErrors{field message}} productVariantsBulkUpdate(productId: $productId, variants: $variants) {productVariants{id inventoryItem{id}} userErrors{field message}}}', Locked = true;
    begin
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(Item);

        GetStoreItemLink(Item."No.", NcTask."Store Code", SpfyStoreItemLink);

        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyProductID = '' then
            ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, false);
        if ShopifyProductID = '' then begin
            case NcTask.Type of
                NcTask.Type::Modify:
                    NcTask.Type := NcTask.Type::Insert;
                NcTask.Type::Delete:
                    Error(ShopifyProductIDEmptyErr, Format(Item.RecordId()));
            end;
        end else
            if NcTask.Type = NcTask.Type::Insert then
                NcTask.Type := NcTask.Type::Modify;

        AddItemInfo(SpfyStoreItemLink, Item, NcTask.Type, ShopifyProductID, ProductJObject);
        Clear(VarietyValueDic);
        case NcTask.Type of
            NcTask.Type::Insert:
                begin
                    if not GenerateItemVariantCollection(NcTask, Item, NcTask.Type = NcTask.Type::Insert, ProductVariantsJArray, VarietyValueDic) then
                        AddDefaultVariant(NcTask, Item, true, ProductVariantsJArray);
                    ProductJObject.Add('productOptions', GenerateListOfProductOptions(Item, VarietyValueDic));
                    ProductJObject.Add('variants', ProductVariantsJArray);
                    Request.Add('query', ProductInsert_QueryTok);
                    Variables.Add('synchronous', true);
                end;

            NcTask.Type::Modify:
                begin
                    if AddDefaultVariant(NcTask, Item, false, ProductVariantsJArray) then begin
                        Variables.Add('productId', 'gid://shopify/Product/' + ShopifyProductID);
                        Variables.Add('variants', ProductVariantsJArray);
                        Request.Add('query', ProductWithDefaultVariantUpdate_QueryTok);
                    end else
                        Request.Add('query', ProductUpdate_QueryTok);
                end;

            NcTask.Type::Delete:
                Request.Add('query', ProductDelete_QueryTok);
        end;
        Variables.Add('productSet', ProductJObject);

        Request.Add('variables', Variables);
        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        Request.WriteTo(OStream);
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
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        SendToShopify := SpfyTagMgt.ShopifyEntityTagsUpdateQuery(NcTask, Enum::"NPR Spfy Tag Owner Type"::PRODUCT, ShopifyProductID, QueryStream);
    end;

    [TryFunction]
    local procedure PrepareBulkItemVariantUpdateRequest(var NcTaskIn: Record "NPR Nc Task"; var NcTaskOut: Record "NPR Nc Task"; var ShopifyProductID: Text[30])
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
        VariantJObject: JsonObject;
        OStream: OutStream;
        ShopifyVariantID: Text[30];
        ResponseTxt: Text;
        MaxNoOfVariantsPerRequest: Integer;
        NoOfVariants: Integer;
        SetBatchProcessed: Boolean;
        SetBatchError: Boolean;
        SkipEntry: Boolean;
        ItemDoesNotExistErr: Label 'Item %1 has been removed from the system. The variant request is no longer applicable.', Comment = '%1 - Item No.';
        ItemVariantDoesNotExistErr: Label 'The item %1 variant %2 has been removed from the system. The request is no longer applicable.', Comment = '%1 - Item No., %2 - Variant Code';
        ShopifyProductIdEmptyErr: Label 'The item has not yet been synced with Shopify. The variant will be sent with the item.';
        ShopifyVariantIdEmptyErr: Label 'The variant does not exist in Shopify. No need to send a removal request.';
    begin
        if not (NcTaskIn.IsTemporary() and NcTaskOut.IsTemporary()) then
            FunctionCallOnNonTempVarErr('PrepareBulkItemVariantUpdateRequest');

        NcTaskOut.Reset();
        if not NcTaskOut.IsEmpty() then
            NcTaskOut.DeleteAll();

        NcTaskIn.FindSet();
        RecRef := NcTaskIn."Record ID".GetRecord();
        RecRef.SetTable(ItemVariant);
        if ItemVariant.Code = '' then
            NcTaskIn.SetRange("Record Value", NcTaskIn."Record Value")
        else
            NcTaskIn.SetFilter("Record Value", StrSubstNo('%1_*', ItemVariant."Item No."));
        MaxNoOfVariantsPerRequest := 50;

        SetBatchProcessed := not Item.Get(ItemVariant."Item No.");
        if SetBatchProcessed then
            ResponseTxt := StrSubstNo(ItemDoesNotExistErr, ItemVariant."Item No.")
        else begin
            SetBatchError := not GetStoreItemLink(Item."No.", NcTaskIn."Store Code", false, SpfyStoreItemLink);
            if SetBatchError then
                ResponseTxt := _ItemIntegrNotEnabledErr
            else begin
                ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                if ShopifyProductID = '' then begin
                    ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, false);
                    if ShopifyProductID = '' then begin
                        ResponseTxt := ShopifyProductIdEmptyErr;
                        SetBatchProcessed := true;
                    end;
                end;
            end;
        end;

        repeat
            NcTaskOut := NcTaskIn;
            if SetBatchProcessed or SetBatchError then begin
                _SpfyIntegrationMgt.SetResponse(NcTaskOut, ResponseTxt);
                NcTaskOut.Processed := SetBatchProcessed;
                NcTaskOut."Process Error" := SetBatchError;
            end else begin
                ClearLastError();
                SkipEntry := false;

                RecRef := NcTaskOut."Record ID".GetRecord();
                RecRef.SetTable(ItemVariant);
                if not ItemVariant.Find() and (NcTaskOut.Type <> NcTaskOut.Type::Delete) then begin
                    _SpfyIntegrationMgt.SetResponse(NcTaskOut, StrSubstNo(ItemVariantDoesNotExistErr, ItemVariant."Item No.", ItemVariant.Code));
                    NcTaskOut.Processed := true;
                    SkipEntry := true;
                end;

                if not SkipEntry then begin
                    NcTaskOut."Process Error" := not SpfyItemMgt.TryCheckVarieties(Item, ItemVariant);
                    if NcTaskOut."Process Error" then begin
                        _SpfyIntegrationMgt.SetResponse(NcTaskOut, GetLastErrorText());
                        SkipEntry := true;
                    end;
                end;

                if not SkipEntry then
                    if not GenerateVariantJObject(NcTaskOut, Item, ItemVariant, NcTaskOut.Type <> NcTaskOut.Type::Delete, ShopifyVariantID, VariantJObject) then begin
                        _SpfyIntegrationMgt.SetResponse(NcTaskOut, GetLastErrorText());
                        NcTaskOut.Processed := true;
                        SkipEntry := true;
                    end;

                if not SkipEntry then begin
                    if ShopifyVariantID = '' then begin
                        case NcTaskOut.Type of
                            NcTaskOut.Type::Modify:
                                NcTaskOut.Type := NcTaskOut.Type::Insert;
                            NcTaskOut.Type::Delete:
                                begin
                                    _SpfyIntegrationMgt.SetResponse(NcTaskOut, ShopifyVariantIdEmptyErr);
                                    NcTaskOut.Processed := true;
                                    SkipEntry := true;
                                end;
                        end;
                    end else
                        if NcTaskOut.Type = NcTaskOut.Type::Insert then
                            NcTaskOut.Type := NcTaskOut.Type::Modify;

                    NcTaskOut."Last Processing Started at" := CurrentDateTime();
                    NcTaskOut."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
                    VariantJObject.WriteTo(OStream);
                end;
                if not SkipEntry then
                    NoOfVariants += 1;
            end;

            NcTaskOut.Insert();
            NcTaskIn.Delete();
        until (NcTaskIn.Next() = 0) or (NoOfVariants >= MaxNoOfVariantsPerRequest);
        NcTaskIn.SetRange("Record Value");
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

        NcTaskOutput.Data.CreateOutStream(OStream, TextEncoding::UTF8);
        RequestJObject.WriteTo(OStream);
    end;

    local procedure PrepareInventoryLevelUpdateRequest(var NcTask: Record "NPR Nc Task"): Boolean
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
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
                _SpfyIntegrationMgt.SetResponse(NcTask, StrSubstNo(ItemVariantDoesNotExistErr, InventoryLevel."Item No.", InventoryLevel."Variant Code"));
                exit(false);
            end;
        GetStoreItemLink(InventoryLevel."Item No.", InventoryLevel."Shopify Store Code", SpfyStoreItemLink);  //Check integration is enabled for the item

        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::"Variant";
        SpfyStoreItemLink."Item No." := InventoryLevel."Item No.";
        SpfyStoreItemLink."Variant Code" := InventoryLevel."Variant Code";
        SpfyStoreItemLink."Shopify Store Code" := InventoryLevel."Shopify Store Code";
        if SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemLink) then begin
            _SpfyIntegrationMgt.SetResponse(NcTask, VariantNotAvailErr);
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
        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
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
        ShopifyProductID: Text[30];
        ShopifyVariantID: Text[30];
        FuturePriceErr: Label 'You cannot send prices that far into the future. The price start date cannot be later than tomorrow.';
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
                _SpfyIntegrationMgt.SetResponse(NcTaskOut, StrSubstNo(SourceRecNotFoundErr, NcTaskIn.TableCaption(), NcTaskIn."Entry No.", NcTaskIn."Record ID"))
            else begin
                RecRef.SetTable(ItemPrice);
                NcTaskOut."Process Error" := ItemPrice."Starting Date" > Today() + 1;
                if NcTaskOut."Process Error" then
                    _SpfyIntegrationMgt.SetResponse(NcTaskOut, FuturePriceErr)
                else begin
                    NcTaskOut."Process Error" := not GetStoreItemLink(ItemPrice."Item No.", ItemPrice."Shopify Store Code", false, SpfyStoreItemLink);  //Check integration is enabled for the item
                    if NcTaskOut."Process Error" then
                        _SpfyIntegrationMgt.SetResponse(NcTaskOut, _ItemIntegrNotEnabledErr)
                    else begin
                        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        if ShopifyProductID = '' then
                            ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, false);
                        ShopifyVariantID := GetProductVariantForItemPrice(ItemPrice);
                        NcTaskOut."Process Error" := (ShopifyProductID = '') or (ShopifyVariantID = '');
                        if NcTaskOut."Process Error" then begin
                            case true of
                                ShopifyProductID = '':
                                    _SpfyIntegrationMgt.SetResponse(NcTaskOut, StrSubstNo(ShopifyProductIDIsMissingLbl, ItemPrice."Item No."));
                                ShopifyVariantID = '':
                                    _SpfyIntegrationMgt.SetResponse(NcTaskOut, StrSubstNo(ShopifyVariantIDIsMissingLbl, ItemPrice."Variant Code", ItemPrice."Item No."));
                            end;
                        end else begin
                            NcTaskOut."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
                            OStream.WriteText(StrSubstNo(UpdateProductVariantsMutationLabel, 'NCTask' + Format(NcTaskIn."Entry No."), ShopifyProductID, ShopifyVariantID, Format(ItemPrice."Unit Price", 0, 9), GetCompareAtPrice(ItemPrice)));
                        end;
                    end;
                end;
            end;
            IncludedNcTasks += 1;
            NcTaskOut.Insert();
            NcTaskIn.Delete();
        until (NcTaskIn.Next() = 0) or (IncludedNcTasks >= MaxItemPricesPerRequest);
    end;

    local procedure GetCompareAtPrice(ItemPrice: Record "NPR Spfy Item Price"): Text
    var
        NullJsonValue: JsonValue;
    begin
        if ItemPrice."Unit Price" < ItemPrice."Compare at Price" then
            exit(Format(ItemPrice."Compare at Price", 0, 9));
        NullJsonValue.SetValueToNull();
        exit(Format(NullJsonValue));
    end;

    local procedure AddItemInfo(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Item: Record Item; NcTaskType: Integer; ShopifyProductID: Text[30]; var ProductJObject: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        TypeHelper: Codeunit "Type Helper";
        RemoveMetafields: JsonArray;
        UpdateMetafields: JsonArray;
        IStream: InStream;
        LongDescription: Text;
    begin
        if ShopifyProductID <> '' then
            ProductJObject.Add('id', 'gid://shopify/Product/' + ShopifyProductID);
        if NcTaskType = NcTask.Type::Delete then
            exit;

        if _SpfyIntegrationMgt.IsSendShopifyNameAndDescription(SpfyStoreItemLink."Shopify Store Code") or (NcTaskType = NcTask.Type::Insert) then begin
            if SpfyStoreItemLink."Shopify Name" <> '' then
                ProductJObject.Add('title', SpfyStoreItemLink."Shopify Name")
            else
                if NcTaskType = NcTask.Type::Insert then
                    ProductJObject.Add('title', GetItemTitle(Item, SpfyStoreItemLink."Shopify Store Code"));
            if SpfyStoreItemLink."Shopify Description".HasValue() then begin
                SpfyStoreItemLink.CalcFields("Shopify Description");
                SpfyStoreItemLink."Shopify Description".CreateInStream(IStream);
                LongDescription := TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.CRLFSeparator());
                if LongDescription <> '' then
                    ProductJObject.Add('descriptionHtml', LongDescription);
            end;
        end;
        if SpfyStoreItemLink.Vendor = '' then
            SpfyStoreItemLink.Vendor := GetItemVendor(Item);
        if SpfyStoreItemLink.Vendor <> '' then
            ProductJObject.Add('vendor', SpfyStoreItemLink.Vendor);
        case NcTaskType of
            NcTask.Type::Insert:
                begin
                    ProductJObject.Add('productType', 'new');
                    ProductJObject.Add('status', ProductStatusEnumValueName(_SpfyIntegrationMgt.DefaultNewProductStatus(SpfyStoreItemLink."Shopify Store Code")));
                end;
            NcTask.Type::Modify:
                if not SpfyItemMgt.TestRequiredFields(Item, false) or not SpfyStoreItemLink."Sync. to this Store" then
                    ProductJObject.Add('status', 'ARCHIVED');
        end;
        SpfyMetafieldMgt.GenerateMetafieldUpdateArrays(SpfyStoreItemLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCT, '', SpfyStoreItemLink."Shopify Store Code", UpdateMetafields, RemoveMetafields);
        if UpdateMetafields.Count() > 0 then
            ProductJObject.Add('metafields', UpdateMetafields);
    end;

    local procedure GenerateItemVariantCollection(NcTask: Record "NPR Nc Task"; Item: Record Item; NewProduct: Boolean; var ProductVariantsJArray: JsonArray; var VarietyValueDic: Dictionary of [Integer, List of [Text]]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", Item."No.");
        if not ItemVariant.FindSet() then
            exit(false);
        repeat
            AddVariant(NcTask, Item, ItemVariant, NewProduct, ProductVariantsJArray, VarietyValueDic);
        until ItemVariant.Next() = 0;
        exit(ProductVariantsJArray.Count() > 0);
    end;

    local procedure AddDefaultVariant(NcTask: Record "NPR Nc Task"; Item: Record Item; NewProduct: Boolean; var ProductVariantsJArray: JsonArray): Boolean
    var
        ItemVariant: Record "Item Variant";
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
    begin
        Clear(ItemVariant);
        ItemVariant."Item No." := Item."No.";
        exit(AddVariant(NcTask, Item, ItemVariant, NewProduct, ProductVariantsJArray, VarietyValueDic));
    end;

    local procedure AddVariant(NcTask: Record "NPR Nc Task"; Item: Record Item; ItemVariant: Record "Item Variant"; NewProduct: Boolean; var ProductVariantsJArray: JsonArray; var VarietyValueDic: Dictionary of [Integer, List of [Text]]): Boolean
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        VariantJObject: JsonObject;
        ShopifyVariantID: Text[30];
    begin
        SpfyItemMgt.CheckVarieties(Item, ItemVariant);
        if not GenerateVariantJObject(NcTask, Item, ItemVariant, NewProduct, ShopifyVariantID, VariantJObject, VarietyValueDic) then
            exit(false);
        ProductVariantsJArray.Add(VariantJObject);
        exit(true);
    end;

    local procedure GenerateVariantJObject(NcTask: Record "NPR Nc Task"; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject): Boolean
    var
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
    begin
        exit(GenerateVariantJObject(NcTask, Item, ItemVariant, ProcessNewVariants, ShopifyVariantID, VariantJObject, VarietyValueDic));
    end;

    [TryFunction]
    local procedure GenerateVariantJObject(NcTask: Record "NPR Nc Task"; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject; var VarietyValueDic: Dictionary of [Integer, List of [Text]])
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        InventoryItemJObject: JsonObject;
        VariantOptionValues: JsonArray;
        Barcode: Text;
        ShopifyOptionNo: Integer;
        ItemVariantIsBlockedOrNotAvailableErr: Label 'The item variant %1 of item %2 is blocked or set as not available in Shopify.';
        ItemVariantIsNotSyncedErr: Label 'The item variant %1 of item %2 is not synced with Shopify.';
    begin
        VariantJObject.ReadFrom('{}');
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant."Code";
        SpfyStoreItemVariantLink."Shopify Store Code" := NcTask."Store Code";

        ShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyVariantID = '' then begin
            ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
            if (ShopifyVariantID = '') and (not ProcessNewVariants or (NcTask.Type = NcTask.Type::Delete)) then
                Error(ItemVariantIsNotSyncedErr, ItemVariant.Code, ItemVariant."Item No.");
        end;
        if not ((ShopifyVariantID <> '') and (NcTask.Type = NcTask.Type::Delete)) then
            if SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemVariantLink) or SpfyItemMgt.ItemVariantIsBlocked(ItemVariant) then
                Error(ItemVariantIsBlockedOrNotAvailableErr, ItemVariant.Code, ItemVariant."Item No.");

        if ShopifyVariantID <> '' then
            VariantJObject.Add('id', 'gid://shopify/ProductVariant/' + ShopifyVariantID);
        if NcTask.Type <> NcTask.Type::Delete then begin
            Barcode := GetItemReference(ItemVariant);
            if Barcode <> '' then
                VariantJObject.Add('barcode', Barcode);
            VariantJObject.Add('inventoryPolicy', GetInventoryPolicy(SpfyStoreItemVariantLink));

            InventoryItemJObject.Add('sku', SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code));
            InventoryItemJObject.Add('tracked', not SpfyItemVariantModifMgt.DoNotTrackInventory(SpfyStoreItemVariantLink));
            if Item."Country/Region of Origin Code" <> '' then
                InventoryItemJObject.Add('countryCodeOfOrigin', Item."Country/Region of Origin Code");
            if Item."Tariff No." <> '' then
                InventoryItemJObject.Add('harmonizedSystemCode', Item."Tariff No.");
            VariantJObject.Add('inventoryItem', InventoryItemJObject);

            if ItemVariant."NPR Variety 1 Value" + ItemVariant."NPR Variety 2 Value" + ItemVariant."NPR Variety 3 Value" + ItemVariant."NPR Variety 4 Value" <> '' then begin
                ShopifyOptionNo := 0;
                if ItemVariant."NPR Variety 1 Value" <> '' then
                    AddVariety(1, ItemVariant."NPR Variety 1", ItemVariant."NPR Variety 1 Table", ItemVariant."NPR Variety 1 Value", ShopifyOptionNo, VariantOptionValues, VarietyValueDic);
                if ItemVariant."NPR Variety 2 Value" <> '' then
                    AddVariety(2, ItemVariant."NPR Variety 2", ItemVariant."NPR Variety 2 Table", ItemVariant."NPR Variety 2 Value", ShopifyOptionNo, VariantOptionValues, VarietyValueDic);
                if ItemVariant."NPR Variety 3 Value" <> '' then
                    AddVariety(3, ItemVariant."NPR Variety 3", ItemVariant."NPR Variety 3 Table", ItemVariant."NPR Variety 3 Value", ShopifyOptionNo, VariantOptionValues, VarietyValueDic);
                if ItemVariant."NPR Variety 4 Value" <> '' then
                    AddVariety(4, ItemVariant."NPR Variety 4", ItemVariant."NPR Variety 4 Table", ItemVariant."NPR Variety 4 Value", ShopifyOptionNo, VariantOptionValues, VarietyValueDic);
                VariantJObject.Add('optionValues', VariantOptionValues);
            end else begin
                SpfyItemMgt.CheckItemVariantHasVarieties(ItemVariant);
                if ShopifyVariantID = '' then begin
                    AddDefaultProductOptionValue(VariantOptionValues);  //Default variant for an item without variants
                    VariantJObject.Add('optionValues', VariantOptionValues);
                end;
            end;
        end;
        SpfyIntegrationEvents.OnAfterGenerateVariantJObject(ItemVariant, VariantJObject);
    end;

    procedure AddVariety(VarietyNo: Integer; Variety: Code[20]; VarietyTable: Code[40]; VarietyValue: Code[50]; var ShopifyOptionNo: Integer; var VariantOptionValues: JsonArray; var VarietyValueDic: Dictionary of [Integer, List of [Text]])
    var
        VarietyOption: JsonObject;
        VarietyDescription: Text;
        VarietyName: Text;
    begin
        if ShopifyOptionNo >= 3 then  //only 3 varieties are supported on Shopify
            exit;
        if GetVarietyDescription(Variety, VarietyTable, VarietyValue, VarietyName, VarietyDescription) then begin
            ShopifyOptionNo += 1;
            Clear(VarietyOption);
            VarietyOption.Add('optionName', VarietyName);
            VarietyOption.Add('name', VarietyDescription);
            VariantOptionValues.Add(VarietyOption);
            AddToVarietyValueDic(VarietyNo, VarietyValueDic, VarietyDescription);
        end;
    end;

    local procedure AddDefaultProductOptionValue(var VariantOptionValues: JsonArray)
    var
        VarietyOption: JsonObject;
    begin
        VarietyOption.Add('optionName', 'Title');
        VarietyOption.Add('name', 'Default Title');
        VariantOptionValues.Add(VarietyOption);
    end;

    procedure GetVarietyDescription(Variety: Code[20]; VarietyTable: Code[40]; VarietyValue: Code[50]; var VarietyName: Text; var VarietyDescription: Text): Boolean
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

        VRTTable.TestField(Description);
        VarietyName := VRTTable.Description;

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
        ShopifyOptionNo: Integer;
    begin
        if VarietyValueDic.Count() = 0 then begin
            ProductOptions.ReadFrom('[{"name":"Title","values":[{"name":"Default Title"}]}]');
            exit;
        end;

        GetVarietyValueList(1, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 1", Item."NPR Variety 1 Table", VarietyValueList, ShopifyOptionNo, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);

        GetVarietyValueList(2, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 2", Item."NPR Variety 2 Table", VarietyValueList, ShopifyOptionNo, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);

        GetVarietyValueList(3, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 3", Item."NPR Variety 3 Table", VarietyValueList, ShopifyOptionNo, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);

        GetVarietyValueList(4, VarietyValueDic, VarietyValueList);
        if GenerateProductOption(Item."NPR Variety 4", Item."NPR Variety 4 Table", VarietyValueList, ShopifyOptionNo, ProductVarietyJObject) then
            ProductOptions.Add(ProductVarietyJObject);
    end;

    local procedure GetVarietyValueList(VarietyNo: Integer; VarietyValueDic: Dictionary of [Integer, List of [Text]]; var VarietyValueList: List of [Text])
    begin
        if not VarietyValueDic.ContainsKey(VarietyNo) then
            Clear(VarietyValueList)
        else
            VarietyValueList := VarietyValueDic.Get(VarietyNo);
    end;

    local procedure GenerateProductOption(Variety: Code[20]; VarietyTable: Code[40]; VarietyValueList: List of [Text]; var ShopifyOptionNo: Integer; var ProductVarietyJObject: JsonObject): Boolean
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
        ShopifyOptionNo += 1;
        ProductVarietyJObject.Add('name', VRTTable.Description);
        ProductVarietyJObject.Add('position', ShopifyOptionNo);
        ProductVarietyJObject.Add('values', AddProductOptionValues(VarietyValueList));
        exit(true);
    end;

    local procedure AddProductOptionValues(VarietyValueList: List of [Text]) ProductOptionValues: JsonArray
    var
        VarietyValue: Text;
    begin
        foreach VarietyValue in VarietyValueList do
            ProductOptionValues.Add(ProductOptionValue(VarietyValue));
    end;

    local procedure ProductOptionValue(VarietyValue: Text) Result: JsonObject
    begin
        Result.Add('name', VarietyValue);
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

    local procedure GetItemVendor(Item: Record Item): Text[100]
    var
        Vendor: Record Vendor;
    begin
        if Item."Vendor No." <> '' then
            if Vendor.Get(Item."Vendor No.") then
                exit(Vendor.Name);
        exit('');
    end;

    local procedure GetInventoryPolicy(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Text
    var
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        if SpfyItemVariantModifMgt.AllowBackorder(SpfyStoreItemLink) then
            exit('CONTINUE');
        exit('DENY');
    end;

    internal procedure RetrieveShopifyProductAndUpdateItemWithDataFromShopify(NcTask: Record "NPR Nc Task"; ShopifyProductID: Text[30]; TriggeredExternally: Boolean; WithDialog: Boolean)
    var
        Window: Dialog;
        ProductJToken: JsonToken;
        ShopifyResponse: JsonToken;
        Cursor: Text;
        CouldNotGetProductErr: Label 'Could not get product from Shopify. The following error occured: %1', Comment = '%1 - Shopify returned error text.';
        QueryingShopifyLbl: Label 'Querying Shopify...';
    begin
        if WithDialog then
            WithDialog := GuiAllowed;
        if WithDialog then
            Window.Open(QueryingShopifyLbl);

        Cursor := '';
        repeat
            if NcTask.Type = NcTask.Type::Delete then
                ShopifyResponse.ReadFrom(StrSubstNo('{"data":{"product":{"id":"gid://shopify/Product/%1"}}}', ShopifyProductID))
            else
                if not GetProductDataFromShopify(ShopifyProductID, NcTask."Store Code", Cursor, ShopifyResponse) then
                    Error(CouldNotGetProductErr, GetLastErrorText());
            if _JsonHelper.GetJsonToken(ShopifyResponse, 'data', ProductJToken) then
                UpdateItemWithDataFromShopify(NcTask, ProductJToken, TriggeredExternally, Cursor);
        until not _JsonHelper.GetJBoolean(ShopifyResponse, 'data.product.variants.pageInfo.hasNextPage', false) or (Cursor = '');

        if WithDialog then
            Window.Close();
    end;

    local procedure GetProductDataFromShopify(ShopifyProductID: Text[30]; ShopifyStoreCode: Code[20]; Cursor: Text; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        Request: JsonObject;
        Variables: JsonObject;
        FirstPageQueryTok: Label 'query GetProduct($productID: ID!) {product(id: $productID) {id title status descriptionHtml vendor hasOnlyDefaultVariant variants(first:25){pageInfo{hasNextPage} edges{cursor node{id sku barcode selectedOptions{name value optionValue{id name}} inventoryPolicy inventoryItem{id tracked measurement{id weight{unit value}}}}}}}}', Locked = true;
        SubsequentPageQueryTok: Label 'query GetProduct($productID: ID!, $afterCursor: String!) {product(id: $productID) {id title status descriptionHtml vendor hasOnlyDefaultVariant variants(first:25, after: $afterCursor){pageInfo{hasNextPage} edges{cursor node{id sku barcode selectedOptions{name value optionValue{id name}} inventoryPolicy inventoryItem{id tracked measurement{id weight{unit value}}}}}}}}', Locked = true;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        Variables.Add('productID', 'gid://shopify/Product/' + ShopifyProductID);
        if Cursor = '' then
            Request.Add('query', FirstPageQueryTok)
        else begin
            Request.Add('query', SubsequentPageQueryTok);
            Variables.Add('afterCursor', Cursor);
        end;
        Request.Add('variables', Variables);
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        Request.WriteTo(QueryStream);

        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    local procedure UpdateItemWithDataFromShopify(NcTask: Record "NPR Nc Task"; ShopifyResponse: JsonToken; TriggeredExternally: Boolean; var Cursor: Text)
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        xSpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        SpfySalesChannelMgt: Codeunit "NPR Spfy Sales Channel Mgt.";
        ShopifyVariant: JsonToken;
        ShopifyVariants: JsonToken;
        ShopifyProductID: Text[30];
        xShopifyProductID: Text[30];
        ShopifyProductDetailedDescr: Text;
        ShopifyProductStatus: Text;
        ShopifyProductTitle: Text;
        ShopifyProductVendor: Text;
        VariantSku: Text;
        FirstPage: Boolean;
        FirstVariant: Boolean;
        BCIsNameDescriptionMaster: Boolean;
        LinkExists: Boolean;
        SkipRecalc: Boolean;
    begin
        FirstPage := Cursor = '';
#pragma warning disable AA0139
        ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'product.id', true), '/');
#pragma warning restore AA0139
        if not (ShopifyResponse.SelectToken('product.variants.edges', ShopifyVariants) and ShopifyVariants.IsArray()) then begin
            if NcTask.Type = NcTask.Type::Delete then begin
                if SpfyItemMgt.FindItemByShopifyProductID(NcTask."Store Code", ShopifyProductID, SpfyStoreItemLink) then begin
                    SpfyStoreItemLink.FindSet();
                    repeat
                        DisableIntegrationForItem(SpfyStoreItemLink);
                        ModifySpfyStoreItemLink(SpfyStoreItemLink, true);
                    until SpfyStoreItemLink.Next() = 0;
                end;
                exit;
            end else
                ShopifyResponse.SelectToken('product.variants.edges', ShopifyVariants);  //Raise error
        end;
        if NcTask.Type = NcTask.Type::Insert then
            SpfySalesChannelMgt.PublishProductToSalesChannels(NcTask."Store Code", ShopifyProductID);

        ShopifyProductTitle := _JsonHelper.GetJText(ShopifyResponse, 'product.title', MaxStrLen(SpfyStoreItemLink."Shopify Name"), false);
        ShopifyProductDetailedDescr := _JsonHelper.GetJText(ShopifyResponse, 'product.descriptionHtml', false);
        ShopifyProductStatus := _JsonHelper.GetJText(ShopifyResponse, 'product.status', false);
        ShopifyProductVendor := _JsonHelper.GetJText(ShopifyResponse, 'product.vendor', false);

        BCIsNameDescriptionMaster := _SpfyIntegrationMgt.IsSendShopifyNameAndDescription(NcTask."Store Code");
        RefreshIntegrationStatus(NcTask."Store Code");

        FirstVariant := true;
        foreach ShopifyVariant in ShopifyVariants.AsArray() do begin
            Cursor := _JsonHelper.GetJText(ShopifyVariant, 'cursor', false);
            if ShopifyVariant.SelectToken('node', ShopifyVariant) then begin
                SpfyItemMgt.ParseItem(ShopifyVariant, ItemVariant, VariantSku);
                if (FirstPage and FirstVariant) or (ItemVariant.Code = '') then begin
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
                    xSpfyStoreItemLink := SpfyStoreItemLink;
                    if TriggeredExternally then
                        SpfyStoreItemLink."Sync. to this Store" := true;
                    SpfyStoreItemLink."Synchronization Is Enabled" := SpfyStoreItemLink."Sync. to this Store";

                    if ShopifyProductStatus <> '' then
                        if Evaluate(SpfyStoreItemLink."Shopify Status", UpperCase(ShopifyProductStatus)) then;
                    if ((ShopifyProductTitle <> '') or not BCIsNameDescriptionMaster) and (SpfyStoreItemLink."Shopify Name" <> ShopifyProductTitle) then
                        SpfyStoreItemLink."Shopify Name" := CopyStr(ShopifyProductTitle, 1, MaxStrLen(SpfyStoreItemLink."Shopify Name"));
                    if (ShopifyProductDetailedDescr <> '') or not BCIsNameDescriptionMaster then
                        SpfyStoreItemLink.SetShopifyDescription(ShopifyProductDetailedDescr);
                    SpfyStoreItemLink.Vendor := CopyStr(ShopifyProductVendor, 1, MaxStrLen(SpfyStoreItemLink.Vendor));

                    ModifySpfyStoreItemLink(SpfyStoreItemLink, true);
                    xShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                    SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyProductID, false);
                    if TriggeredExternally and not xSpfyStoreItemLink."Sync. to this Store" then
                        SpfyMetafieldMgt.InitStoreItemLinkMetafields(SpfyStoreItemLink);
                    UpdateMetafieldsFromShopify(SpfyStoreItemLink, ShopifyProductID);

                    if (TriggeredExternally and not xSpfyStoreItemLink."Synchronization Is Enabled") or ((xShopifyProductID <> '') and (ShopifyProductID <> xShopifyProductID)) then begin
                        RecalculateInventoryLevels(SpfyStoreItemLink);
                        RecalculatePrices(SpfyStoreItemLink);
                        SkipRecalc := true;
                    end else
                        SkipRecalc := false;
                    FirstVariant := false;
                end;
                UpdateItemVariant(NcTask."Store Code", ShopifyVariant, ItemVariant, TriggeredExternally, SkipRecalc);
            end;
        end;
    end;

    local procedure UpdateItemVariantWithDataFromShopify(ShopifyStoreCode: Code[20]; ShopifyVariant: JsonToken)
    var
        ItemVariant: Record "Item Variant";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        VariantSku: Text;
    begin
        SpfyItemMgt.ParseItem(ShopifyVariant, ItemVariant, VariantSku);
        UpdateItemVariant(ShopifyStoreCode, ShopifyVariant, ItemVariant, false, false);
    end;

    local procedure UpdateItemVariant(ShopifyStoreCode: Code[20]; ShopifyVariant: JsonToken; ItemVariant: Record "Item Variant"; TriggeredExternally: Boolean; SkipRecalc: Boolean)
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        ShopifyInventoryItemID: Text[30];
        xShopifyInventoryItemID: Text[30];
        ShopifyVariantID: Text[30];
        xShopifyVariantID: Text[30];
        xDoNotTrackInventory: Boolean;
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;
        xDoNotTrackInventory := SpfyItemVariantModifMgt.DoNotTrackInventory(SpfyStoreItemVariantLink);

        SpfyItemVariantModifMgt.SetAllowBackorder(SpfyStoreItemVariantLink, _JsonHelper.GetJText(ShopifyVariant, 'inventoryPolicy', false).ToUpper() = 'CONTINUE', true);
        if _JsonHelper.TokenExists(ShopifyVariant, 'inventoryItem.tracked') then
            SpfyItemVariantModifMgt.SetDoNotTrackInventory(SpfyStoreItemVariantLink, not _JsonHelper.GetJBoolean(ShopifyVariant, 'inventoryItem.tracked', true), true);

#pragma warning disable AA0139
        ShopifyVariantID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyVariant, 'id', true), '/');
        ShopifyInventoryItemID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyVariant, 'inventoryItem.id', true), '/');
#pragma warning restore AA0139
        xShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        xShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
        SpfyItemVariantModifMgt.SetItemVariantAsNotAvailableInShopify(SpfyStoreItemVariantLink, false);

        if TriggeredExternally and not SkipRecalc and ((ShopifyVariantID <> xShopifyVariantID) or (ShopifyInventoryItemID <> xShopifyInventoryItemID)) then begin
            RecalculateInventoryLevels(SpfyStoreItemVariantLink);
            RecalculatePrices(SpfyStoreItemVariantLink);
        end else
            if xDoNotTrackInventory then
                if not SpfyItemVariantModifMgt.DoNotTrackInventory(SpfyStoreItemVariantLink) then
                    RecalculateInventoryLevels(SpfyStoreItemVariantLink);

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
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        if not _InventoryIntegrIsEnabled then
            exit;
        InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemLink);
        SpfyItemMgt.UpdateInventoryLevels(SpfyStoreItemLink);
    end;

    local procedure RecalculatePrices(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        if not _ItemPriceIntegrIsEnabled then
            exit;
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

    procedure GetShopifyProductID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyProductVariantRelatedIDs(SpfyStoreItemLink, WithDialog, _ShopifyProductID, _ShopifyVariantID, _ShopifyInventoryItemID) then
            exit(_ShopifyProductID);
        Error(GetLastErrorText());
    end;

    procedure GetShopifyVariantID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyProductVariantRelatedIDs(SpfyStoreItemLink, WithDialog, _ShopifyProductID, _ShopifyVariantID, _ShopifyInventoryItemID) then
            exit(_ShopifyVariantID);
        Error(GetLastErrorText());
    end;

    procedure GetShopifyInventoryItemID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyProductVariantRelatedIDs(SpfyStoreItemLink, WithDialog, _ShopifyProductID, _ShopifyVariantID, _ShopifyInventoryItemID) then
            exit(_ShopifyInventoryItemID);
        Error(GetLastErrorText());
    end;

    local procedure TryGetShopifyProductVariantRelatedIDs(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean; var ShopifyProductID: Text[30]; var ShopifyVariantID: Text[30]; var ShopifyInventoryItemID: Text[30]): Boolean
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OStream: OutStream;
        ShopifyResponse: JsonToken;
        Request: JsonObject;
        Variables: JsonObject;
        Window: Dialog;
        Success: Boolean;
        ProductVariantGraphQLQueryTok: Label 'query FindProductVariantBySku($skuFilter: String!) {productVariants(first: 1, query: $skuFilter) {edges{node{id product{id} inventoryItem{id}}}}}', Locked = true;
    begin
        if (SpfyStoreItemLink."Item No." = _LastQueriedSpfyStoreItemLink."Item No.") and
           (SpfyStoreItemLink."Variant Code" = _LastQueriedSpfyStoreItemLink."Variant Code") and
           (SpfyStoreItemLink."Shopify Store Code" = _LastQueriedSpfyStoreItemLink."Shopify Store Code")
        then
            exit(true);
        if WithDialog then
            Window.Open(_QueryingShopifyLbl);
        Variables.Add('skuFilter', 'sku:' + SpfyItemMgt.GetProductVariantSku(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Variant Code"));
        Request.Add('query', ProductVariantGraphQLQueryTok);
        Request.Add('variables', Variables);

        TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        TempNcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        Request.WriteTo(OStream);

        ClearLastError();
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, true, ShopifyResponse);
        if Success then begin
#pragma warning disable AA0139
            ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, '$.data.productVariants.edges[0].node.product.id', false), '/');
            ShopifyVariantID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, '$.data.productVariants.edges[0].node.id', false), '/');
            ShopifyInventoryItemID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, '$.data.productVariants.edges[0].node.inventoryItem.id', false), '/');
#pragma warning restore AA0139

            if (ShopifyProductID = '') and (SpfyStoreItemLink."Variant Code" = '') then begin
                Clear(Request);
                Clear(Variables);
                Variables.Add('skuFilter', StrSubstNo('sku:%1_*', SpfyStoreItemLink."Item No."));
                Request.Add('query', ProductVariantGraphQLQueryTok);
                Request.Add('variables', Variables);
                Clear(TempNcTask);
                TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
                TempNcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
                Request.WriteTo(OStream);

                ClearLastError();
                Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, true, ShopifyResponse);
                if Success then
#pragma warning disable AA0139
                    ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, '$.data.productVariants.edges[0].node.product.id', false), '/');
#pragma warning restore AA0139
            end;

            _LastQueriedSpfyStoreItemLink := SpfyStoreItemLink;
        end;

        if WithDialog then
            Window.Close();
        exit(Success);
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
    begin
        if CreateAtShopify then
            DisableDataLog := false;

        if ShopifyStore.FindSet() then
            repeat
                UpdateIntegrationStatusForItem(ShopifyStore.Code, Item, DisableDataLog, CreateAtShopify, WithDialog);
            until ShopifyStore.Next() = 0;
    end;

    local procedure UpdateIntegrationStatusForItem(ShopifyStoreCode: Code[20]; Item: Record Item; DisableDataLog: Boolean; CreateAtShopify: Boolean; WithDialog: Boolean)
    var
        NcTask: Record "NPR Nc Task";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        ShopifyProductID: Text[30];
        ItemIntegrIsEnabled: Boolean;
        LinkExists: Boolean;
    begin
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
        SpfyStoreItemLink."Item No." := Item."No.";
        SpfyStoreItemLink."Variant Code" := '';
        SpfyStoreItemLink."Shopify Store Code" := ShopifyStoreCode;
        LinkExists := SpfyStoreItemLink.Find();
        if not LinkExists then
            SpfyStoreItemLink.Init();
        ItemIntegrIsEnabled := _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code");
        if not ItemIntegrIsEnabled then
            CreateAtShopify := false;

        ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, WithDialog);
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
                    SpfyMetafieldMgt.InitStoreItemLinkMetafields(SpfyStoreItemLink);
                end;
            end;
            exit;
        end;

        SpfyStoreLinkMgt.UpdateStoreItemLinks(Item);
        SpfyStoreItemLink.Find();
        ClearAllItemVariantsShopifyIDs(SpfyStoreItemLink);
        NcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        NcTask.Type := NcTask.Type::Modify;
        RetrieveShopifyProductAndUpdateItemWithDataFromShopify(NcTask, ShopifyProductID, true, false);
        if not DisableDataLog then begin
            SpfyItemMgt.ScheduleMissingVariantSync(SpfyStoreItemLink, ItemIntegrIsEnabled, _InventoryIntegrIsEnabled, _ItemPriceIntegrIsEnabled);
            if ItemIntegrIsEnabled then
                if not _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyStoreItemLink."Shopify Store Code") then
                    SpfyItemMgt.ScheduleTagsSync(SpfyStoreItemLink, Item."Item Category Code", '');
        end;
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
        ClearAllItemVariantsShopifyIDs(SpfyStoreItemLink);
        InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemLink);
        ItemPriceMgt.ClearItemPrices(SpfyStoreItemLink);

        SpfyStoreItemLink."Sync. to this Store" := false;
        SpfyStoreItemLink."Synchronization Is Enabled" := false;
        SpfyStoreItemLink."Shopify Status" := SpfyStoreItemLink."Shopify Status"::" ";
    end;

    local procedure ClearAllItemVariantsShopifyIDs(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
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

    local procedure ProductStatusEnumValueName(ProductStatus: Enum "NPR Spfy Product Status") Result: Text
    begin
        ProductStatus.Names().Get(ProductStatus.Ordinals().IndexOf(ProductStatus.AsInteger()), Result);
    end;

    local procedure GenerateRequestAndSetNcTaskPostponed(var NcTaskIn: Record "NPR Nc Task"; ShopifyProductID: Text[30]; var RequestedVariantBuffer: Record "NPR Spfy ID/Task Buffer"; var Request: JsonObject) Success: Boolean
    var
        NcTask: Record "NPR Nc Task";
        IStream: InStream;
        VariantsJArray: JsonArray;
        Variables: JsonObject;
        VariantJObject: JsonObject;
        DuplicateTaskMgt: Label 'This task is a duplicate of another task (Entry No. %1). The requested update will be handled there.', Comment = '%1 - NaviConnect Task Entry No.';
        VariantBulkDelete_QueryTok: Label 'mutation DeleteProductVariants($productId: ID!, $variants: [ID!]!) {productVariantsBulkDelete(productId: $productId, variantsIds : $variants) {product{id} userErrors{field message}}}', Locked = true;
        VariantBulkInsert_QueryTok: Label 'mutation CreateProductVariants($productId: ID!, $variants: [ProductVariantsBulkInput!]!) {productVariantsBulkCreate(productId: $productId, variants : $variants) {product{id} productVariants{id sku inventoryPolicy selectedOptions{name value optionValue{id name}} inventoryItem{id tracked}} userErrors{field message}}}', Locked = true;
        VariantBulkUpdate_QueryTok: Label 'mutation UpdateProductVariants($productId: ID!, $variants: [ProductVariantsBulkInput!]!, $allowPartialUpdates: Boolean) {productVariantsBulkUpdate(productId: $productId, variants : $variants, allowPartialUpdates: $allowPartialUpdates) {product{id} productVariants{id sku inventoryPolicy selectedOptions{name value optionValue{id name}} inventoryItem{id tracked}} userErrors{field message}}}', Locked = true;
    begin
        if not NcTaskIn.IsTemporary() then
            FunctionCallOnNonTempVarErr('SetNcTaskPostponed');
        Clear(Request);
        Clear(VariantsJArray);
        RequestedVariantBuffer.Reset();
        RequestedVariantBuffer.DeleteAll();
        if not NcTaskIn.FindSet() then
            exit;

#if not (BC18 or BC19 or BC20 or BC21)
        NcTask.ReadIsolation := IsolationLevel::UpdLock;
#else
        NcTask.LockTable();
#endif
        case
            NcTaskIn.Type of
            NcTaskIn.Type::Insert:
                Request.Add('query', VariantBulkInsert_QueryTok);
            NcTaskIn.Type::Modify:
                begin
                    Request.Add('query', VariantBulkUpdate_QueryTok);
                    Variables.Add('allowPartialUpdates', true);
                end;
            NcTaskIn.Type::Delete:
                Request.Add('query', VariantBulkDelete_QueryTok);
        end;
        Variables.Add('productId', 'gid://shopify/Product/' + ShopifyProductID);

        repeat
            if NcTask.Get(NcTaskIn."Entry No.") and not (NcTask.Processed or NcTask.Postponed) then begin
                NcTask.Type := NcTaskIn.Type;
                NcTask."Last Processing Started at" := NcTaskIn."Last Processing Started at";
                NcTask."Last Processing Duration" := 0;
                NcTask."Process Count" += 1;
                if NcTaskIn."Process Error" or NcTaskIn.Processed then begin
                    NcTaskIn.CalcFields(Response);
                    NcTask.Response := NcTaskIn.Response;
                    NcTask."Process Error" := NcTaskIn."Process Error";
                    NcTask.Processed := NcTaskIn.Processed;
                    NcTask."Last Processing Completed at" := CurrentDateTime();
                    NcTaskIn.Delete();
                end else begin
                    if RequestedVariantBuffer.RecordValueExists(NcTask."Record Value") then begin
                        _SpfyIntegrationMgt.SetResponse(NcTask, 0DT, CurrentDateTime(), StrSubstNo(DuplicateTaskMgt, RequestedVariantBuffer."Nc Task Entry No."));
                        NcTask."Process Error" := false;
                        NcTask.Processed := true;
                        NcTaskIn.Delete();
                    end else begin
                        NcTaskIn.CalcFields("Data Output");
                        NcTask."Data Output" := NcTaskIn."Data Output";
                        NcTask."Data Output".CreateInStream(IStream, TextEncoding::UTF8);
                        VariantJObject.ReadFrom(IStream);
                        NcTask.Postponed := true;
                        NcTask."Postponed At" := CurrentDateTime();
                        NcTask."Last Processing Completed at" := 0DT;
                        if NcTask.Type = NcTask.Type::Delete then
                            VariantsJArray.Add(_JsonHelper.GetJText(VariantJObject.AsToken(), 'id', true))
                        else
                            VariantsJArray.Add(VariantJObject);
                        RequestedVariantBuffer.AddEntry(NcTask."Record Value", NcTask."Entry No.", NcTask."Record ID");
                        Success := true;
                    end;
                end;
                NcTask.Modify();
            end else
                NcTaskIn.Delete();
        until NcTaskIn.Next() = 0;
        Variables.Add('variants', VariantsJArray);
        Request.Add('variables', Variables);
        Commit();
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
            if NcTask.Get(NcTaskIn."Entry No.") and not (NcTask.Processed or NcTask.Postponed) then begin
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

    local procedure GetProductVariantForItemPrice(var ItemPrice: Record "NPR Spfy Item Price"): Text[30]
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        exit(SpfyItemMgt.GetAssignedShopifyVariantID(ItemPrice."Item No.", ItemPrice."Variant Code", ItemPrice."Shopify Store Code", true));
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

    internal procedure RefreshIntegrationStatus(ShopifyStoreCode: Code[20])
    begin
        _InventoryIntegrIsEnabled := _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", ShopifyStoreCode);
        _ItemPriceIntegrIsEnabled := _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", ShopifyStoreCode);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", 'RunSourceCardEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", RunSourceCardEvent, '', false, false)]
#endif
    local procedure OpenRelatedPage(var RecRef: RecordRef; var RunCardExecuted: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        if RunCardExecuted or (RecRef.Number() <> Database::"NPR Spfy Store-Item Link") then
            exit;
        RunCardExecuted := true;

        RecRef.SetTable(SpfyStoreItemLink);
        case SpfyStoreItemLink.Type of
            SpfyStoreItemLink.Type::Item:
                begin
                    Item.Get(SpfyStoreItemLink."Item No.");
                    Item.SetRecFilter();
                    Page.Run(Page::"Item Card", Item);
                end;
            SpfyStoreItemLink.Type::Variant:
                begin
                    ItemVariant.Get(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Variant Code");
                    ItemVariant.SetRecFilter();
#if BC18 or BC19 or BC20 or BC21 or BC22
                    Page.Run(Page::"Item Variants", ItemVariant);
#else
                    Page.Run(Page::"Item Variant Card", ItemVariant);
#endif
                end;
        end;
    end;
}
#endif