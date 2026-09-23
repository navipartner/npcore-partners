// Native sibling of frozen codeunit "NPR Spfy Send Items&Inventory": only sanctioned legacy defect fixes are dual-applied, new-queue behavior changes are not.
codeunit 6151253 "NPR Spfy Task Send Items&Inv"
{
    Access = Internal;
    TableNo = "NPR Spfy Task";

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
            Database::"NPR Spfy Tag Update Request":
                SendTags(Rec);
            Database::"NPR Spfy Inventory Level":
                BulkSendShopifyInventoryUpdate(Rec);
            Database::"NPR Spfy Item Price":
                SendShopifyItemPrices(Rec);
            Database::"NPR Spfy Inv Item Location":
                SendShopifyActivateInventoryItemAtLocation(Rec);
        end;
    end;

    var
        _LastQueriedSpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _JsonHelper: Codeunit "NPR Json Helper";
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _ShopifyInventoryItemID: Text[30];
        _ShopifyProductID: Text[30];
        _ShopifyVariantID: Text[30];
        _InventoryIntegrIsEnabled, _ItemPriceIntegrIsEnabled : Boolean;
        _GraphQLClientSet: Boolean;
        _InventoryItemIDNotFoundErr: Label 'Shopify Inventory Item ID could not be found for %1=%2, %3=%4 at Shopify Store %5', Comment = '%1 = Item No. fieldcaption, %2 = Item No., %3 = Variant Code fieldcaption, %4 = Variant Code, %5 = Shopify Store Code';
        _ItemIntegrNotEnabledErr: Label 'Shopify integration is not enabled for the item.';
        _ItemVariantBlockedOrDoesNotExistErr: Label 'The item %1 variant %2 is blocked or has been removed from the system. The request is no longer applicable.', Comment = '%1 - Item No., %2 - Variant Code';
        _QueryingShopifyLbl: Label 'Querying Shopify...';

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
    begin
        if not _GraphQLClientSet then begin
            _GraphQLClient := DefaultGraphQLClient;
            _GraphQLClientSet := true;
        end;
        exit(_GraphQLClient);
    end;

    local procedure SendItem(var SpfyTask: Record "NPR Spfy Task")
    var
        Item: Record Item;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ShopifyProductID: Text[30];
        Success: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();
        Success := true;

        PrepareItemUpdateRequest(SpfyTask, Item);
        Success := GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse);
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');  //The system will record Shopify response as the error message

#pragma warning disable AA0139
        case SpfyTask.Type of
            SpfyTask.Type::Insert:
                ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.productSet.product.id', true), '/');
            SpfyTask.Type::Modify:
                ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.productUpdate.product.id', true), '/');
            SpfyTask.Type::Delete:
                ShopifyProductID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.productDelete.deletedProductId', true), '/');
        end;
#pragma warning restore AA0139
        RetrieveShopifyProductAndUpdateItemWithDataFromShopify(SpfyTask, ShopifyProductID, false, false);

        if SpfyTask.Type = SpfyTask.Type::Insert then
            if _SpfyIntegrationMgt.ProductVariantSortingEnabled() then
                ReorderProductVariantsBestEffort(Item, SpfyTask."Store Code", ShopifyProductID);
    end;

    local procedure SendTags(var SpfyTask: Record "NPR Spfy Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();
        Success := true;

        PrepareTagUpdateRequest(SpfyTask, SendToShopify);
        if SendToShopify then
            Success := GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse);

        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');  //The system will record Shopify response as the error message
    end;

    local procedure BulkSendItemVariants(var SpfyTask: Record "NPR Spfy Task")
    var
        Item: Record Item;
        TempIncomingSpfyTasks: Record "NPR Spfy Task" temporary;
        TempSpfyTaskToProcess: Record "NPR Spfy Task" temporary;
        TempRequestedVariantBuffer: Record "NPR Spfy ID/Task Buffer" temporary;
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        ShopifyRequest: JsonObject;
        ItemsToReorder: Dictionary of [Code[20], Text[30]];
        ItemNoToReorder: Code[20];
        ShopifyStoreCode: Code[20];
        ShopifyProductID: Text[30];
        RequestType: Enum "NPR Spfy Task Op";
        RequestTypeOrdinal: Integer;
        PrepareReturnedFalse: Boolean;
        StopForDeadline: Boolean;
        VariantInsertProcessed: Boolean;
    begin
        if not SpfyTask.IsTemporary() then
            FunctionCallOnNonTempVarErr('BulkSendItemVariants');
        if not SpfyTask.FindSet() then
            exit;
        ShopifyStoreCode := SpfyTask."Store Code";
        RefreshIntegrationStatus(ShopifyStoreCode);
        repeat
            TempIncomingSpfyTasks := SpfyTask;
            TempIncomingSpfyTasks.Insert();
        until SpfyTask.Next() = 0;

        StopForDeadline := false;
        PrepareReturnedFalse := false;
        while not (StopForDeadline or PrepareReturnedFalse) do
            if SpfyTaskRunContext.DeadlineExpired() then
                StopForDeadline := true
            else
                if not PrepareBulkItemVariantUpdateRequest(TempIncomingSpfyTasks, TempSpfyTaskToProcess, ShopifyProductID, Item) then
                    PrepareReturnedFalse := true
                else begin
                    VariantInsertProcessed := false;
                    foreach RequestTypeOrdinal in Enum::"NPR Spfy Task Op".Ordinals() do begin
                        RequestType := Enum::"NPR Spfy Task Op".FromInteger(RequestTypeOrdinal);
                        TempSpfyTaskToProcess.SetRange(Type, RequestType);
                        if not TempSpfyTaskToProcess.IsEmpty() then
                            if GenerateRequestAndSetSpfyTaskClaimed(TempSpfyTaskToProcess, ShopifyProductID, TempRequestedVariantBuffer, ShopifyRequest) then begin
                                ProcessAndUpdateNCTasksWithDataFromShopify(TempSpfyTaskToProcess, TempRequestedVariantBuffer, ShopifyRequest);
                                if RequestType = RequestType::Insert then
                                    VariantInsertProcessed := true;
                            end;
                    end;
                    if VariantInsertProcessed and (ShopifyProductID <> '') and (Item."No." <> '') then
                        if not ItemsToReorder.ContainsKey(Item."No.") then
                            ItemsToReorder.Add(Item."No.", ShopifyProductID);
                end;

        if PrepareReturnedFalse then
            FailAbortedPrepareRow(TempIncomingSpfyTasks);

        if not _SpfyIntegrationMgt.ProductVariantSortingEnabled() then
            exit;
        foreach ItemNoToReorder in ItemsToReorder.Keys() do
            if Item.Get(ItemNoToReorder) then
                ReorderProductVariantsBestEffort(Item, ShopifyStoreCode, ItemsToReorder.Get(ItemNoToReorder));
    end;

    local procedure BulkSendShopifyInventoryUpdate(var SpfyTask: Record "NPR Spfy Task")
    var
        TempIncomingSpfyTasks: Record "NPR Spfy Task" temporary;
        TempSpfyTask: Record "NPR Spfy Task" temporary;
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        BulkUpdateRequest: JsonObject;
        PrepareReturnedFalse: Boolean;
        StopForDeadline: Boolean;
    begin
        if not SpfyTask.IsTemporary() then
            FunctionCallOnNonTempVarErr('BulkSendShopifyInventoryUpdate');
        if not SpfyTask.FindSet() then
            exit;
        RefreshIntegrationStatus(SpfyTask."Store Code");
        repeat
            TempIncomingSpfyTasks := SpfyTask;
            TempIncomingSpfyTasks.Insert();
        until SpfyTask.Next() = 0;

        StopForDeadline := false;
        PrepareReturnedFalse := false;
        while not (StopForDeadline or PrepareReturnedFalse) do
            if SpfyTaskRunContext.DeadlineExpired() then
                StopForDeadline := true
            else begin
                if not PrepareItemUpdateRequest(TempIncomingSpfyTasks, TempSpfyTask) then
                    PrepareReturnedFalse := true
                else
                    if GenerateBulkRequestAndSetSpfyTaskClaimed(TempSpfyTask, BulkUpdateRequest) then
                        ProcessShopifyResponseAndUpdateSpfyTask(TempSpfyTask, BulkUpdateRequest);
            end;

        if PrepareReturnedFalse then
            FailAbortedPrepareRow(TempIncomingSpfyTasks);
    end;

    [TryFunction]
    local procedure PrepareItemUpdateRequest(var SpfyTaskIn: Record "NPR Spfy Task"; var SpfyTaskOut: Record "NPR Spfy Task")
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        ItemVariant: Record "Item Variant";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyInvLocationAct: Codeunit "NPR Spfy Inv. Location Act.";
        OStream: OutStream;
        IncludedSpfyTasks: Integer;
        MaxPerRequest: Integer;
        UpdateLevelItemRequest: Text;
        ShopifyInventoryItemID: Text[30];
        PrepareError: Boolean;
        AutoActivationDisabledLbl: Label 'Auto-activation is disabled for %1 %2 / %3 %4 at Shopify Location ID %5 (%6 store). The inventory update was skipped so the manual Shopify deactivation is preserved.', Comment = '%1 = Item No. caption, %2 = Item No., %3 = Variant Code caption, %4 = Variant Code, %5 = Shopify Location ID, %6 = Shopify Store Code';
        LocInvItemNotActivatedErr: Label 'The specified Shopify Inventory Item ID %1 is not stocked at Shopify Location ID %2 at Shopify Store %3. Awaiting the activation task to complete.', Comment = '%1 =ShopifyInventoryItemID;%2=InventoryLevel."Shopify Location ID";%3=InventoryLevel."Shopify Store Code"';
        UpdateLevelItemRequestLegacy: Label '%1: inventorySetQuantities(input:{reason:"correction",name:"available",ignoreCompareQuantity:true,quantities:[{inventoryItemId:"gid://shopify/InventoryItem/%2",locationId:"gid://shopify/Location/%3",quantity:%4}]}){userErrors{field message}}', Locked = true;
        UpdateLevelItemRequest202604: Label '%1: inventorySetQuantities(input:{reason:"correction",name:"available",quantities:[{inventoryItemId:"gid://shopify/InventoryItem/%2",locationId:"gid://shopify/Location/%3",quantity:%4,changeFromQuantity:null}]}) @idempotent(key: "%5") {userErrors{field message}}', Locked = true;
        VariantNotAvailErr: Label 'The variant is marked as not available in Shopify. The request is no longer applicable.';
    begin
        if not (SpfyTaskIn.IsTemporary() and SpfyTaskOut.IsTemporary()) then
            FunctionCallOnNonTempVarErr('PrepareItemUpdateUpdateRequest');

        SpfyTaskOut.DeleteAll();
        SpfyTaskIn.FindSet();
        SpfyStore.Get(SpfyTaskIn."Store Code");
        MaxPerRequest := SpfyStore.InventoryLevelUpdateRequestBatchSize();
        IncludedSpfyTasks := 0;
        if _SpfyIntegrationMgt.ShopifyApiVersionIsAtLeast('2026-04') then
            UpdateLevelItemRequest := UpdateLevelItemRequest202604
        else
            UpdateLevelItemRequest := UpdateLevelItemRequestLegacy;

        repeat
            Clear(ShopifyInventoryItemID);
            ClearLastError();
            SpfyTaskOut := SpfyTaskIn;
            SpfyTaskOut."Last Processing Started at" := CurrentDateTime();
            if not TryLoadInventoryLevel(InventoryLevel, SpfyTaskOut."Record ID") then begin
                SpfyTaskOut.State := SpfyTaskOut.State::Completed;
                _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, GetLastErrorText());
            end else begin
                if InventoryLevel."Variant Code" <> '' then
                    if not ItemVariant.Get(InventoryLevel."Item No.", InventoryLevel."Variant Code") or SpfyItemMgt.ItemVariantIsBlocked(ItemVariant) then begin
                        SpfyTaskOut.State := SpfyTaskOut.State::Completed;
                        _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, StrSubstNo(_ItemVariantBlockedOrDoesNotExistErr, InventoryLevel."Item No.", InventoryLevel."Variant Code"));
                    end;
                if SpfyTaskOut.State <> SpfyTaskOut.State::Completed then begin
                    PrepareError := not GetStoreItemLink(InventoryLevel."Item No.", InventoryLevel."Shopify Store Code", false, SpfyStoreItemLink);  //Check integration is enabled for the item
                    if PrepareError then
                        _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, _ItemIntegrNotEnabledErr)
                    else begin
                        PrepareError := ItemVariantNotAvailableInShopify(SpfyStoreItemLink, InventoryLevel."Item No.", InventoryLevel."Variant Code", InventoryLevel."Shopify Store Code");
                        if PrepareError then
                            _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, VariantNotAvailErr)
                        else begin
                            ShopifyInventoryItemID := FindShopifyInventoryItemID(SpfyStoreItemLink);
                            PrepareError := ShopifyInventoryItemID = '';
                            if PrepareError then
                                _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, StrSubstNo(_InventoryItemIDNotFoundErr,
                                    InventoryLevel.FieldCaption("Item No."), InventoryLevel."Item No.", InventoryLevel.FieldCaption("Variant Code"), InventoryLevel."Variant Code", InventoryLevel."Shopify Store Code"))
                            else begin
                                if SpfyInvLocationAct.FindLocationRecord(LocationInvItem, InventoryLevel) and LocationInvItem."Auto-Activation Disabled" then begin
                                    SpfyTaskOut.State := SpfyTaskOut.State::Completed;
                                    _SpfyIntegrationMgt.SetResponse(SpfyTaskOut,
                                        StrSubstNo(AutoActivationDisabledLbl,
                                            InventoryLevel.FieldCaption("Item No."), InventoryLevel."Item No.",
                                            InventoryLevel.FieldCaption("Variant Code"), InventoryLevel."Variant Code",
                                            InventoryLevel."Shopify Location ID", InventoryLevel."Shopify Store Code"));
                                end else begin
                                    PrepareError := not LocationInvItem.Activated;
                                    if PrepareError then begin
                                        SpfyInvLocationAct.CreateNcTaskActivateInvLocation(InventoryLevel, false);
                                        _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, StrSubstNo(LocInvItemNotActivatedErr, ShopifyInventoryItemID, InventoryLevel."Shopify Location ID", InventoryLevel."Shopify Store Code"));
                                    end else begin
                                        IncludedSpfyTasks += 1;
                                        SpfyTaskOut."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
                                        OStream.WriteText(StrSubstNo(UpdateLevelItemRequest, 'SpfyTask' + Format(SpfyTaskIn."Entry No."), ShopifyInventoryItemID, InventoryLevel."Shopify Location ID", InventoryLevel.AvailableInventory(), Format(SpfyTaskIn."Dispatch Id", 0, 4)));
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            SpfyTaskOut.Insert();
            SpfyTaskIn.Delete();
        until (SpfyTaskIn.Next() = 0) or (IncludedSpfyTasks >= MaxPerRequest);
    end;

    [TryFunction]
    local procedure TryLoadInventoryLevel(var InventoryLevel: Record "NPR Spfy Inventory Level"; RecID: RecordID)
    begin
        InventoryLevel.Get(RecID);  // fails if record missing
    end;

    local procedure SendItemCost(var SpfyTask: Record "NPR Spfy Task")
    var
        InventoryBuffer: Record "Inventory Buffer";
        Item: Record Item;
        TempItemVariant: Record "Item Variant" temporary;
        TempSpfyTask: Record "NPR Spfy Task" temporary;
        TypeHelper: Codeunit "Type Helper";
        RecRef: RecordRef;
        RequestsJObject: JsonObject;
        ResponsesJObject: JsonObject;
        VariantRequestJObject: JsonObject;
        IStream: InStream;
        OStream: OutStream;
        AggregatedResponses: Text;
        VariantOutcome: Text;
        ShopifyInventoryItemID: Text[30];
        Success: Boolean;
        VariantSuccess: Boolean;
    begin
        Success := false;

        RecRef := SpfyTask."Record ID".GetRecord();
        RecRef.SetTable(InventoryBuffer);
        Item.get(InventoryBuffer."Item No.");
        GenerateTmpItemVariantList(Item, TempItemVariant);
        if TempItemVariant.FindSet() then
            repeat
                ClearLastError();
                Clear(TempSpfyTask);
                TempSpfyTask."Store Code" := SpfyTask."Store Code";
                TempSpfyTask."Record Value" := CopyStr(Format(TempItemVariant.RecordId()), 1, MaxStrLen(TempSpfyTask."Record Value"));
                VariantSuccess := false;
                if PrepareItemCostUpdateRequest(SpfyTask."Store Code", TempSpfyTask, Item, TempItemVariant, ShopifyInventoryItemID) then begin
                    Clear(VariantRequestJObject);
                    TempSpfyTask."Data Output".CreateInStream(IStream, TextEncoding::UTF8);
                    VariantRequestJObject.ReadFrom(IStream);
                    RequestsJObject.Add(TempSpfyTask."Record Value", VariantRequestJObject);
                    VariantSuccess := SendInvetoryItemUpdateRequest(TempSpfyTask);
                end;
                if VariantSuccess then
                    Success := true;
                Clear(VariantOutcome);
                if TempSpfyTask.Response.HasValue() then begin
                    TempSpfyTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
                    VariantOutcome := TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.LFSeparator());
                end;
                if VariantOutcome = '' then
                    VariantOutcome := GetLastErrorText();
                ResponsesJObject.Add(TempSpfyTask."Record Value", VariantOutcome);
                Commit();
            until TempItemVariant.Next() = 0;

        ResponsesJObject.WriteTo(AggregatedResponses);
        _SpfyIntegrationMgt.SetResponse(SpfyTask, AggregatedResponses);
        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        RequestsJObject.WriteTo(OStream);
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error('');  //The system will record Shopify response as the error message
    end;

    [TryFunction]
    procedure SendInvetoryItemUpdateRequest(var SpfyTask: Record "NPR Spfy Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        Success: Boolean;
    begin
        SpfyCommunicationHandler.CheckRequestContent(SpfyTask);
        Success := GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse);
        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
    end;

    local procedure SendShopifyItemPrices(var SpfyTask: Record "NPR Spfy Task")
    var
        TempIncomingSpfyTasks: Record "NPR Spfy Task" temporary;
        TempSpfyTask: Record "NPR Spfy Task" temporary;
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        productVariantsBulkUpdateRequestString: Text;
        PrepareReturnedFalse: Boolean;
        StopForDeadline: Boolean;
    begin
        if not SpfyTask.IsTemporary() then
            FunctionCallOnNonTempVarErr('SendShopifyItemPrices');
        if not SpfyTask.FindSet() then
            exit;
        repeat
            TempIncomingSpfyTasks := SpfyTask;
            TempIncomingSpfyTasks.Insert();
        until SpfyTask.Next() = 0;

        StopForDeadline := false;
        PrepareReturnedFalse := false;
        while not (StopForDeadline or PrepareReturnedFalse) do
            if SpfyTaskRunContext.DeadlineExpired() then
                StopForDeadline := true
            else begin
                if not PrepareItemPriceUpdateRequest(TempIncomingSpfyTasks, TempSpfyTask) then
                    PrepareReturnedFalse := true
                else
                    if SetSpfyTaskClaimed(TempSpfyTask, productVariantsBulkUpdateRequestString) then
                        UpdateNCTasksWithDataFromShopify(TempSpfyTask, productVariantsBulkUpdateRequestString);
            end;

        if PrepareReturnedFalse then
            FailAbortedPrepareRow(TempIncomingSpfyTasks);
    end;

    // A preparation that raised leaves its own row unconsumed, so only that row is charged and its group mates stay pending.
    local procedure FailAbortedPrepareRow(var SpfyTaskIn: Record "NPR Spfy Task")
    var
        SpfyTaskToFail: Record "NPR Spfy Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        AbortErrorText: Text;
        PrepareAbortedNoTextLbl: Label 'The update was not sent: the request preparation was interrupted without an error message.';
    begin
        AbortErrorText := GetLastErrorText();
        if not SpfyTaskIn.IsTemporary() then
            FunctionCallOnNonTempVarErr('FailAbortedPrepareRow');
        // Read under the filters the aborted preparation left in place, or a row of another entity could be blamed.
        if not SpfyTaskIn.FindFirst() then
            exit;
        if AbortErrorText = '' then
            AbortErrorText := PrepareAbortedNoTextLbl;
        Clear(SpfyTaskToFail);
        SpfyTaskToFail."Entry No." := SpfyTaskIn."Entry No.";
        if SpfyTaskQueue.ClaimSingle(SpfyTaskToFail) then
            SpfyTaskQueue.CompleteSingle(SpfyTaskToFail, false, AbortErrorText);
    end;

    local procedure UpdateNCTasksWithDataFromShopify(var SpfyTaskIn: Record "NPR Spfy Task"; productVariantsBulkUpdateRequestString: Text)
    var
        SpfyTaskParam: Record "NPR Spfy Task";
        ShopifyResponse: JsonToken;
        ResponseDictionary: Dictionary of [Text[30], Dictionary of [Text[30], Text]];
        Found: Boolean;
        Success: Boolean;
        SpfyTaskErrorText: Text;
    begin
        if not SpfyTaskIn.FindSet() then
            exit;

        CreateSpfyTaskParam(SpfyTaskIn, SpfyTaskParam, productVariantsBulkUpdateRequestString);

        ClearLastError();
        Clear(ShopifyResponse);

        if (SpfyTaskParam."Store Code" <> '') and (SpfyTaskParam."Data Output".HasValue()) then
            Success := GetGraphQLClient().ExecuteRequest(SpfyTaskParam, true, ShopifyResponse);

        if Success then
            Success := PopulateResponseDictionary(ShopifyResponse, ResponseDictionary);
        if not Success then
            SpfyTaskErrorText := GetLastErrorText();

        repeat
            if Success then
                Found := FindSpfyTaskInDictionary(SpfyTaskIn, ResponseDictionary, SpfyTaskErrorText);
            MarkSpfyTaskAsCompleted(SpfyTaskIn."Entry No.", ShopifyResponse, Success and Found, SpfyTaskErrorText);
        until SpfyTaskIn.Next() = 0;
    end;

    local procedure ProcessShopifyResponseAndUpdateSpfyTask(var SpfyTaskIn: Record "NPR Spfy Task"; ShopifyRequest: JsonObject)
    var
        SpfyTask: Record "NPR Spfy Task";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyInvLocationAct: Codeunit "NPR Spfy Inv. Location Act.";
        ResponseDictionary: Dictionary of [BigInteger, Text];
        RecRef: RecordRef;
        ResponseDataSet: JsonToken;
        ShopifyResponse: JsonToken;
        ShopifyResponseUserErrors: JsonToken;
        UserError: JsonToken;
        StringTextBuilder: TextBuilder;
        OStream: OutStream;
        TaskEntryNo: BigInteger;
        DataKey: Text;
        ErrPart: Text;
        RequestErrorText: Text;
        ManualDeactivationDetected: Boolean;
        Success: Boolean;
        AutoActivationDisabledByShopifyLbl: Label 'Shopify reports %1 %2 / %3 %4 as not stocked at Shopify Location ID %5 (%6 store), but it was previously activated by Business Central. Assuming a manual deactivation in Shopify Admin: auto-activation has been disabled for this item at this location and the inventory update was skipped.', Comment = '%1 = Item No. caption, %2 = Item No., %3 = Variant Code caption, %4 = Variant Code, %5 = Shopify Location ID, %6 = Shopify Store Code';
        SpfyTaskNotFoundLbl: Label 'Task %1 was not found in the Shopify response.';
    begin
        if not SpfyTaskIn.FindSet() then
            exit;
        SpfyTask."Store Code" := SpfyTaskIn."Store Code";
        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyRequest.WriteTo(OStream);
        ClearLastError();
        Success := GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse);

        if not Success then begin
            repeat
                MarkSpfyTaskAsCompleted(SpfyTaskIn."Entry No.", ShopifyResponse, Success, GetLastErrorText());
            until SpfyTaskIn.Next() = 0;
        end else begin
            if ShopifyResponse.SelectToken('data', ResponseDataSet) and ResponseDataSet.IsObject() then
                foreach DataKey in ResponseDataSet.AsObject().Keys() do begin
                    Clear(RequestErrorText);
                    if GetSpfyTaskFromResponse(DataKey, TaskEntryNo) then begin
                        Clear(StringTextBuilder);
                        if ResponseDataSet.SelectToken(DataKey + '.userErrors', ShopifyResponseUserErrors) and ShopifyResponseUserErrors.IsArray() then
                            if ShopifyResponseUserErrors.AsArray().Count() > 0 then
                                foreach UserError in ShopifyResponseUserErrors.AsArray() do begin
                                    ErrPart := _JsonHelper.GetJText(UserError, 'message', false);
                                    if ErrPart <> '' then
                                        StringTextBuilder.AppendLine(ErrPart);
                                end;
                        if StringTextBuilder.Length > 0 then
                            RequestErrorText := StringTextBuilder.ToText();
                        if not ResponseDictionary.ContainsKey(TaskEntryNo) then
                            ResponseDictionary.Add(TaskEntryNo, RequestErrorText);
                    end;
                end;

            repeat
                Clear(RequestErrorText);
                if not ResponseDictionary.Get(SpfyTaskIn."Entry No.", RequestErrorText) then
                    MarkSpfyTaskAsCompleted(SpfyTaskIn."Entry No.", ShopifyResponse, false, StrSubstNo(SpfyTaskNotFoundLbl, SpfyTaskIn."Entry No."))
                else begin
                    ManualDeactivationDetected := false;
                    if RequestErrorText <> '' then
                        if SpfyInvLocationAct.IsNotStockedAtLocationErr(RequestErrorText) then begin
                            RecRef.Get(SpfyTaskIn."Record ID");
                            RecRef.SetTable(InventoryLevel);
                            if SpfyInvLocationAct.HandleNotStockedAtLocation(InventoryLevel) then begin
                                ManualDeactivationDetected := true;
                                RequestErrorText := StrSubstNo(AutoActivationDisabledByShopifyLbl,
                                    InventoryLevel.FieldCaption("Item No."), InventoryLevel."Item No.",
                                    InventoryLevel.FieldCaption("Variant Code"), InventoryLevel."Variant Code",
                                    InventoryLevel."Shopify Location ID", InventoryLevel."Shopify Store Code");
                            end;
                        end;
                    MarkSpfyTaskAsCompleted(SpfyTaskIn."Entry No.", ShopifyResponse, (RequestErrorText = '') or ManualDeactivationDetected, RequestErrorText);
                end;
            until SpfyTaskIn.Next() = 0;
        end;
    end;

    [TryFunction]
    local procedure GetSpfyTaskFromResponse(DataKey: Text; var TaskEntryNo: biginteger)
    begin
        if StrPos(DataKey, 'SpfyTask') = 0 then
            Error('');
        Evaluate(TaskEntryNo, CopyStr(DataKey, StrLen('SpfyTask') + 1));
    end;

    local procedure ProcessAndUpdateNCTasksWithDataFromShopify(var SpfyTaskIn: Record "NPR Spfy Task"; var RequestedVariantBuffer: Record "NPR Spfy ID/Task Buffer"; ShopifyRequest: JsonObject)
    var
        SpfyTask: Record "NPR Spfy Task";
        ResponseDataSet: JsonToken;
        ShopifyResponse: JsonToken;
        ShopifyResponseUserErrors: JsonToken;
        ShopifyResponseVariants: JsonToken;
        UserError: JsonToken;
        VariantJToken: JsonToken;
        MutationUserErrors: TextBuilder;
        OStream: OutStream;
        VariantNo: Integer;
        DataKey: Text;
        ErrPart: Text;
        RequestErrorText: Text;
        Success: Boolean;
        BatchNotAppliedErrLbl: Label 'The variant was not confirmed by Shopify because the request failed with the following error(s):\%1', Comment = '%1 = the error messages returned by Shopify for the request';
    begin
        if not SpfyTaskIn.FindFirst() then
            exit;

        SpfyTask."Store Code" := SpfyTaskIn."Store Code";
        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        ShopifyRequest.WriteTo(OStream);

        ClearLastError();
        Success := GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse);
        if not Success then
            RequestErrorText := GetLastErrorText();

        if Success then
            if ShopifyResponse.SelectToken('data', ResponseDataSet) and ResponseDataSet.IsObject() then
                foreach DataKey in ResponseDataSet.AsObject().Keys() do begin
                    if ResponseDataSet.SelectToken(DataKey + '.userErrors', ShopifyResponseUserErrors) and ShopifyResponseUserErrors.IsArray() then
                        if ShopifyResponseUserErrors.AsArray().Count() > 0 then
                            foreach UserError in ShopifyResponseUserErrors.AsArray() do begin
                                ErrPart := _JsonHelper.GetJText(UserError, 'message', false);
                                if ErrPart <> '' then
                                    MutationUserErrors.AppendLine(ErrPart);
                                if _JsonHelper.GetJText(UserError, 'field[0]', false) in ['variants', 'variantsIds'] then
                                    if Evaluate(VariantNo, _JsonHelper.GetJText(UserError, 'field[1]', false)) then
                                        if RequestedVariantBuffer.Get(VariantNo) then
                                            if SpfyTaskIn.Get(RequestedVariantBuffer."Nc Task Entry No.") then begin
                                                MarkSpfyTaskAsCompleted(SpfyTaskIn."Entry No.", UserError, false, ErrPart);
                                                SpfyTaskIn.Delete();
                                            end;
                            end;

                    if ResponseDataSet.SelectToken(DataKey + '.productVariants', ShopifyResponseVariants) and ShopifyResponseVariants.IsArray() then
                        if ShopifyResponseVariants.AsArray().Count() > 0 then
                            foreach VariantJToken in ShopifyResponseVariants.AsArray() do
#pragma warning disable AA0139
                                if RequestedVariantBuffer.RecordValueExists(_SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(VariantJToken, 'sku', true), '/')) then
#pragma warning restore AA0139
                                    if SpfyTaskIn.Get(RequestedVariantBuffer."Nc Task Entry No.") then begin
                                        MarkSpfyTaskAsCompleted(SpfyTaskIn."Entry No.", VariantJToken, true, '');
                                        SpfyTaskIn.Delete();
                                    end;
                end;

        //Variants not in response
        if not SpfyTaskIn.FindSet() then
            exit;
        // A create/update that returned user errors did not apply the variants it left unconfirmed, so completing them would strand rows as sent-but-absent in Shopify.
        if Success and (MutationUserErrors.Length() > 0) and (SpfyTaskIn.Type <> SpfyTaskIn.Type::Delete) then begin
            Success := false;
            RequestErrorText := StrSubstNo(BatchNotAppliedErrLbl, MutationUserErrors.ToText());
        end;
        repeat
            MarkSpfyTaskAsCompleted(SpfyTaskIn."Entry No.", ShopifyResponse, Success, RequestErrorText);
        until SpfyTaskIn.Next() = 0;
    end;

    [TryFunction]
    local procedure PopulateResponseDictionary(ShopifyResponse: JsonToken; var ResponseDictionary: Dictionary of [Text[30], Dictionary of [Text[30], Text]])
    var
        DataJToken: JsonToken;
        ErrorsJToken: JsonToken;
        ErrorText: Text;
        ResponseSpfyTaskID: Text;
        ProductVariantIDJToken: JsonToken;
        ProductVariantsJToken: JsonToken;
        UserErrorsJToken: JsonToken;
        SpfyTaskResult: Dictionary of [Text[30], Text];
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

        foreach ResponseSpfyTaskID in DataJToken.AsObject().Keys() do begin
            Clear(SpfyTaskResult);
            DataJToken.AsObject().SelectToken(StrSubstNo('%1.productVariants', ResponseSpfyTaskID), ProductVariantsJToken);
            if ProductVariantsJToken.IsArray() then begin
                ProductVariantsJToken.AsArray().Get(0, ProductVariantIDJToken);
                ProductVariantIDJToken.AsObject().Get('id', ProductVariantIDJToken);
#pragma warning disable AA0139
                SpfyTaskResult.Add('VariantID', _SpfyIntegrationMgt.RemoveUntil(ProductVariantIDJToken.AsValue().AsText(), '/'));
#pragma warning restore AA0139
            end else begin
                DataJToken.SelectToken(StrSubstNo('%1.userErrors', ResponseSpfyTaskID), UserErrorsJToken);
                UserErrorsJToken.AsArray().Get(0, UserErrorsJToken);
                UserErrorsJToken.WriteTo(UserErrorsDeserialized);
                SpfyTaskResult.Add('Error', UserErrorsDeserialized);
            end;
            ResponseDictionary.Add(CopyStr(ResponseSpfyTaskID, 1, 30), SpfyTaskResult);
        end;
    end;

    local procedure MarkSpfyTaskAsCompleted(SpfyTaskInEntryNo: BigInteger; ShopifyResponse: JsonToken; Success: Boolean; ErrorText: Text)
    var
        ItemVariant: Record "Item Variant";
        CompletedTask: Record "NPR Spfy Task";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        ItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        RecRef: RecordRef;
    begin
        if not SpfyTaskQueue.CompleteFromBatch(SpfyTaskInEntryNo, ShopifyResponse, Success, ErrorText, CompletedTask) then
            exit;

        if Success and (CompletedTask."Table No." = Database::"Item Variant") then begin
            RecRef := CompletedTask."Record ID".GetRecord();
            RecRef.SetTable(ItemVariant);
            SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
            SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
            SpfyStoreItemVariantLink."Variant Code" := ItemVariant."Code";
            SpfyStoreItemVariantLink."Shopify Store Code" := CompletedTask."Store Code";
            case CompletedTask.Type of
                CompletedTask.Type::Insert, CompletedTask.Type::Modify:
                    UpdateItemVariantWithDataFromShopify(CompletedTask."Store Code", ShopifyResponse);
                CompletedTask.Type::Delete:
                    begin
                        ClearVariantShopifyIDs(SpfyStoreItemVariantLink);
                        ClearLocationActivations(SpfyStoreItemVariantLink);
                        InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemVariantLink);
                        ItemPriceMgt.ClearItemPrices(SpfyStoreItemVariantLink);
                    end;
            end;
        end;

        Commit();
    end;

    local procedure ValidateProductVariantId(var SpfyTaskIn: Record "NPR Spfy Task"; ShopifyVariantID: Text[30]): Boolean
    var
        ItemPrice: Record "NPR Spfy Item Price";
        RecRef: RecordRef;
        ShopifyVariantIDComparison: Text[30];
    begin
        if not RecRef.Get(SpfyTaskIn."Record ID") then
            exit;
        RecRef.SetTable(ItemPrice);

        ShopifyVariantIDComparison := GetProductVariantForItemPrice(ItemPrice);
        if ShopifyVariantIDComparison = '' then
            exit;
        if ShopifyVariantID <> ShopifyVariantIDComparison then
            exit;
        exit(true);
    end;

    local procedure PrepareItemUpdateRequest(var SpfyTask: Record "NPR Spfy Task"; var Item: Record Item)
    var
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
        RecRef.Get(SpfyTask."Record ID");
        RecRef.SetTable(Item);

        GetStoreItemLink(Item."No.", SpfyTask."Store Code", SpfyStoreItemLink);

        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyProductID = '' then
            ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, false);
        if ShopifyProductID = '' then begin
            case SpfyTask.Type of
                SpfyTask.Type::Modify:
                    SpfyTask.Type := SpfyTask.Type::Insert;
                SpfyTask.Type::Delete:
                    Error(ShopifyProductIDEmptyErr, Format(Item.RecordId()));
            end;
        end else
            if SpfyTask.Type = SpfyTask.Type::Insert then
                SpfyTask.Type := SpfyTask.Type::Modify;

        AddItemInfo(SpfyStoreItemLink, Item, SpfyTask.Type, ShopifyProductID, ProductJObject);
        Clear(VarietyValueDic);
        case SpfyTask.Type of
            SpfyTask.Type::Insert:
                begin
                    if not GenerateItemVariantCollection(SpfyTask, Item, SpfyTask.Type = SpfyTask.Type::Insert, ProductVariantsJArray, VarietyValueDic) then
                        AddDefaultVariant(SpfyTask, Item, true, ProductVariantsJArray);
                    ProductJObject.Add('productOptions', GenerateListOfProductOptions(Item, VarietyValueDic));
                    ProductJObject.Add('variants', ProductVariantsJArray);
                    Request.Add('query', ProductInsert_QueryTok);
                    Variables.Add('synchronous', true);
                end;

            SpfyTask.Type::Modify:
                begin
                    if AddDefaultVariant(SpfyTask, Item, false, ProductVariantsJArray) then begin
                        Variables.Add('productId', 'gid://shopify/Product/' + ShopifyProductID);
                        Variables.Add('variants', ProductVariantsJArray);
                        Request.Add('query', ProductWithDefaultVariantUpdate_QueryTok);
                    end else
                        Request.Add('query', ProductUpdate_QueryTok);
                end;

            SpfyTask.Type::Delete:
                Request.Add('query', ProductDelete_QueryTok);
        end;
        Variables.Add('productSet', ProductJObject);

        Request.Add('variables', Variables);
        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        Request.WriteTo(OStream);
    end;

    local procedure PrepareTagUpdateRequest(var SpfyTask: Record "NPR Spfy Task"; var SendToShopify: Boolean)
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyTagMgt: Codeunit "NPR Spfy Tag Mgt.";
        QueryStream: OutStream;
        ShopifyProductID: Text[30];
        ShopifyProductIdEmptyErr: Label 'The item has not yet been synced with Shopify. The tags will be sent when the item is synced.';
    begin
        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyTask."Record ID", "NPR Spfy ID Type"::"Entry ID");
        if ShopifyProductID = '' then
            Error(ShopifyProductIdEmptyErr);
        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        SendToShopify := SpfyTagMgt.ShopifyEntityTagsUpdateQuery(SpfyTask, Enum::"NPR Spfy Tag Owner Type"::PRODUCT, ShopifyProductID, QueryStream);
    end;

    [TryFunction]
    local procedure PrepareBulkItemVariantUpdateRequest(var SpfyTaskIn: Record "NPR Spfy Task"; var SpfyTaskOut: Record "NPR Spfy Task"; var ShopifyProductID: Text[30]; var Item: Record Item)
    var
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
        NoOfRowsProcessed: Integer;
        NoOfVariants: Integer;
        PrepareError: Boolean;
        SetBatchProcessed: Boolean;
        SetBatchError: Boolean;
        SkipEntry: Boolean;
        ItemDoesNotExistErr: Label 'Item %1 has been removed from the system. The variant request is no longer applicable.', Comment = '%1 - Item No.';
        ItemVariantDoesNotExistErr: Label 'The item %1 variant %2 has been removed from the system. The request is no longer applicable.', Comment = '%1 - Item No., %2 - Variant Code';
        ProductLookupFailedNoTextLbl: Label 'The Shopify product lookup for item %1 failed without an error message.', Comment = '%1 - Item No.';
        ShopifyProductIdEmptyErr: Label 'The item has not yet been synced with Shopify. The variant will be sent with the item.';
        ShopifyVariantIdEmptyErr: Label 'The variant does not exist in Shopify. No need to send a removal request.';
    begin
        if not (SpfyTaskIn.IsTemporary() and SpfyTaskOut.IsTemporary()) then
            FunctionCallOnNonTempVarErr('PrepareBulkItemVariantUpdateRequest');

        Clear(Item);
        SpfyTaskOut.Reset();
        if not SpfyTaskOut.IsEmpty() then
            SpfyTaskOut.DeleteAll();

        SpfyTaskIn.FindSet();
        RecRef := SpfyTaskIn."Record ID".GetRecord();
        RecRef.SetTable(ItemVariant);
        if ItemVariant.Code = '' then
            SpfyTaskIn.SetRange("Record Value", SpfyTaskIn."Record Value")
        else
            SpfyTaskIn.SetFilter("Record Value", StrSubstNo('%1_*', ItemVariant."Item No."));
        MaxNoOfVariantsPerRequest := 50;

        SetBatchProcessed := not Item.Get(ItemVariant."Item No.");
        if SetBatchProcessed then
            ResponseTxt := StrSubstNo(ItemDoesNotExistErr, ItemVariant."Item No.")
        else begin
            SetBatchError := not GetStoreItemLink(Item."No.", SpfyTaskIn."Store Code", false, SpfyStoreItemLink);
            if SetBatchError then
                ResponseTxt := _ItemIntegrNotEnabledErr
            else begin
                ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                if ShopifyProductID = '' then
                    if not TryGetShopifyProductVariantRelatedIDs(SpfyStoreItemLink, false, _ShopifyProductID, _ShopifyVariantID, _ShopifyInventoryItemID) then begin
                        ResponseTxt := GetLastErrorText();
                        if ResponseTxt = '' then
                            ResponseTxt := StrSubstNo(ProductLookupFailedNoTextLbl, Item."No.");
                        SetBatchError := true;
                    end else begin
                        ShopifyProductID := _ShopifyProductID;
                        if ShopifyProductID = '' then begin
                            ResponseTxt := ShopifyProductIdEmptyErr;
                            SetBatchProcessed := true;
                        end;
                    end;
            end;
        end;

        repeat
            SpfyTaskOut := SpfyTaskIn;
            if SetBatchProcessed or SetBatchError then begin
                _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, ResponseTxt);
                if SetBatchProcessed then
                    SpfyTaskOut.State := SpfyTaskOut.State::Completed;
            end else begin
                ClearLastError();
                SkipEntry := false;

                RecRef := SpfyTaskOut."Record ID".GetRecord();
                RecRef.SetTable(ItemVariant);
                if not ItemVariant.Find() and (SpfyTaskOut.Type <> SpfyTaskOut.Type::Delete) then begin
                    _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, StrSubstNo(ItemVariantDoesNotExistErr, ItemVariant."Item No.", ItemVariant.Code));
                    SpfyTaskOut.State := SpfyTaskOut.State::Completed;
                    SkipEntry := true;
                end;

                if not SkipEntry then begin
                    PrepareError := not SpfyItemMgt.TryCheckVarieties(Item, ItemVariant);
                    if PrepareError then begin
                        _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, GetLastErrorText());
                        SkipEntry := true;
                    end;
                end;

                if not SkipEntry then
                    if not GenerateVariantJObject(SpfyTaskOut, Item, ItemVariant, SpfyTaskOut.Type <> SpfyTaskOut.Type::Delete, ShopifyVariantID, VariantJObject) then begin
                        _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, GetLastErrorText());
                        SpfyTaskOut.State := SpfyTaskOut.State::Completed;
                        SkipEntry := true;
                    end;

                if not SkipEntry then begin
                    if ShopifyVariantID = '' then begin
                        case SpfyTaskOut.Type of
                            SpfyTaskOut.Type::Modify:
                                SpfyTaskOut.Type := SpfyTaskOut.Type::Insert;
                            SpfyTaskOut.Type::Delete:
                                begin
                                    _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, ShopifyVariantIdEmptyErr);
                                    SpfyTaskOut.State := SpfyTaskOut.State::Completed;
                                    SkipEntry := true;
                                end;
                        end;
                    end else
                        if SpfyTaskOut.Type = SpfyTaskOut.Type::Insert then
                            SpfyTaskOut.Type := SpfyTaskOut.Type::Modify;

                    SpfyTaskOut."Last Processing Started at" := CurrentDateTime();
                    SpfyTaskOut."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
                    VariantJObject.WriteTo(OStream);
                end;
                if not SkipEntry then
                    NoOfVariants += 1;
            end;

            SpfyTaskOut.Insert();
            SpfyTaskIn.Delete();
            NoOfRowsProcessed += 1;
        until (SpfyTaskIn.Next() = 0) or (NoOfVariants >= MaxNoOfVariantsPerRequest) or (NoOfRowsProcessed >= MaxNoOfVariantsPerRequest);
        SpfyTaskIn.SetRange("Record Value");
    end;

    [TryFunction]
    local procedure PrepareItemCostUpdateRequest(ShopifyStoreCode: Code[20]; var SpfyTaskOut: Record "NPR Spfy Task"; Item: Record Item; ItemVariant: Record "Item Variant"; var ShopifyInventoryItemID: Text[30])
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        InputObj: JsonObject;
        RequestJObject: JsonObject;
        Variables: JsonObject;
        OStream: OutStream;
        InventoryItemUpdateRequest: Label 'mutation UpdateInventoryItem($id: ID!,$input: InventoryItemInput!) { inventoryItemUpdate(id: $id, input: $input) { inventoryItem { id unitCost { amount } } userErrors { message } } }', Locked = true;
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

        InputObj.Add('cost', Item."Last Direct Cost");
        Variables.Add('id', StrSubstNo('gid://shopify/InventoryItem/%1', ShopifyInventoryItemID));
        Variables.Add('input', InputObj);

        RequestJObject.Add('query', InventoryItemUpdateRequest);
        RequestJObject.Add('variables', Variables);

        SpfyTaskOut."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        RequestJObject.WriteTo(OStream);
    end;

    local procedure ItemVariantNotAvailableInShopify(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]): Boolean
    var
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::"Variant";
        SpfyStoreItemLink."Item No." := ItemNo;
        SpfyStoreItemLink."Variant Code" := VariantCode;
        SpfyStoreItemLink."Shopify Store Code" := StoreCode;
        exit(SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemLink));
    end;

    [TryFunction]
    local procedure PrepareItemPriceUpdateRequest(var SpfyTaskIn: Record "NPR Spfy Task"; var SpfyTaskOut: Record "NPR Spfy Task")
    var
        SpfyStore: Record "NPR Spfy Store";
        MaxItemPricesPerRequest: Integer;
        IncludedSpfyTasks: Integer;
    begin
        if not (SpfyTaskIn.IsTemporary() and SpfyTaskOut.IsTemporary()) then
            FunctionCallOnNonTempVarErr('PrepareItemPriceUpdateRequest');

        SpfyTaskOut.DeleteAll();
        // Unguarded on purpose: a drained set must raise so this try function reports false and the caller's chunk loop ends. A guarded exit would return true and loop forever.
        SpfyTaskIn.FindSet();

        SpfyStore.Get(SpfyTaskIn."Store Code");
        MaxItemPricesPerRequest := SpfyStore.NoOfPriceUpdatesPerRequest();
        IncludedSpfyTasks := 0;

        repeat
            SpfyTaskOut := SpfyTaskIn;
            SpfyTaskOut."Last Processing Started at" := CurrentDateTime();
            StageItemPriceRequest(SpfyTaskIn, SpfyTaskOut);
            IncludedSpfyTasks += 1;
            SpfyTaskOut.Insert();
            SpfyTaskIn.Delete();
        until (SpfyTaskIn.Next() = 0) or (IncludedSpfyTasks >= MaxItemPricesPerRequest);
    end;

    local procedure StageItemPriceRequest(var SpfyTaskIn: Record "NPR Spfy Task"; var SpfyTaskOut: Record "NPR Spfy Task")
    var
        ItemPrice: Record "NPR Spfy Item Price";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        OStream: OutStream;
        ShopifyProductID: Text[30];
        ShopifyVariantID: Text[30];
        FuturePriceErr: Label 'You cannot send prices that far into the future. The price start date cannot be later than tomorrow.';
        ShopifyProductIDIsMissingLbl: Label 'Item %1 does not have a Shopify Product ID assigned.';
        ShopifyVariantIDIsMissingLbl: Label 'Variant %1 of Item %2 does not have a Shopify Variant ID assigned.';
        SourceRecNotFoundErr: Label '%1 Entry No. %2 source record (%3) could not be found.', Comment = '%1 - SpfyTask tablename, %2 - SpfyTask entry number, %3 - task source record id';
        UpdateProductVariantsMutationLabel: Label '%1: productVariantsBulkUpdate(productId: "gid://shopify/Product/%2", variants: [ { id: "gid://shopify/ProductVariant/%3", price: %4, compareAtPrice: %5 } ]) { productVariants { id price compareAtPrice } userErrors { field message } }', Locked = true, Comment = '%1 = SpfyTask ID, %2 = Shopify Product ID, %3 = Shopify Product Variant ID, %4 = Unit Price, %5 = Compare At Price';
    begin
        if not RecRef.Get(SpfyTaskIn."Record ID") then begin
            // A source row deleted before the send is no longer applicable, so the task completes instead of retrying.
            SpfyTaskOut.State := SpfyTaskOut.State::Completed;
            _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, StrSubstNo(SourceRecNotFoundErr, SpfyTaskIn.TableCaption(), SpfyTaskIn."Entry No.", SpfyTaskIn."Record ID"));
            exit;
        end;
        RecRef.SetTable(ItemPrice);

        if ItemPrice."Starting Date" > Today() + 1 then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, FuturePriceErr);
            exit;
        end;

        if not GetStoreItemLink(ItemPrice."Item No.", ItemPrice."Shopify Store Code", false, SpfyStoreItemLink) then begin  //Check integration is enabled for the item
            _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, _ItemIntegrNotEnabledErr);
            exit;
        end;

        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyProductID = '' then
            ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, false);
        if ShopifyProductID = '' then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, StrSubstNo(ShopifyProductIDIsMissingLbl, ItemPrice."Item No."));
            exit;
        end;

        ShopifyVariantID := GetProductVariantForItemPrice(ItemPrice);
        if ShopifyVariantID = '' then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTaskOut, StrSubstNo(ShopifyVariantIDIsMissingLbl, ItemPrice."Variant Code", ItemPrice."Item No."));
            exit;
        end;

        SpfyTaskOut."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(StrSubstNo(UpdateProductVariantsMutationLabel, 'SpfyTask' + Format(SpfyTaskIn."Entry No."), ShopifyProductID, ShopifyVariantID, Format(ItemPrice."Unit Price", 0, 9), GetCompareAtPrice(ItemPrice)));
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

    local procedure AddItemInfo(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Item: Record Item; SpfyTaskType: Enum "NPR Spfy Task Op"; ShopifyProductID: Text[30]; var ProductJObject: JsonObject)
    var
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
        if SpfyTaskType = SpfyTaskType::Delete then
            exit;

        if _SpfyIntegrationMgt.IsSendShopifyNameAndDescription(SpfyStoreItemLink."Shopify Store Code") or (SpfyTaskType = SpfyTaskType::Insert) then begin
            if SpfyStoreItemLink."Shopify Name" <> '' then
                ProductJObject.Add('title', SpfyStoreItemLink."Shopify Name")
            else
                if SpfyTaskType = SpfyTaskType::Insert then
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
        case SpfyTaskType of
            SpfyTaskType::Insert:
                begin
                    ProductJObject.Add('productType', 'new');
                    ProductJObject.Add('status', ProductStatusEnumValueName(_SpfyIntegrationMgt.DefaultNewProductStatus(SpfyStoreItemLink."Shopify Store Code")));
                end;
            SpfyTaskType::Modify:
                if not SpfyItemMgt.TestRequiredFields(Item, false) or not SpfyStoreItemLink."Sync. to this Store" then
                    ProductJObject.Add('status', 'ARCHIVED');
        end;
        SpfyMetafieldMgt.GenerateMetafieldUpdateArrays(SpfyStoreItemLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCT, '', SpfyStoreItemLink."Shopify Store Code", UpdateMetafields, RemoveMetafields);
        if UpdateMetafields.Count() > 0 then
            ProductJObject.Add('metafields', UpdateMetafields);
    end;

    local procedure GenerateItemVariantCollection(SpfyTask: Record "NPR Spfy Task"; Item: Record Item; NewProduct: Boolean; var ProductVariantsJArray: JsonArray; var VarietyValueDic: Dictionary of [Integer, List of [Text]]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", Item."No.");
        if not ItemVariant.FindSet() then
            exit(false);
        repeat
            AddVariant(SpfyTask, Item, ItemVariant, NewProduct, ProductVariantsJArray, VarietyValueDic);
        until ItemVariant.Next() = 0;
        exit(ProductVariantsJArray.Count() > 0);
    end;

    local procedure AddDefaultVariant(SpfyTask: Record "NPR Spfy Task"; Item: Record Item; NewProduct: Boolean; var ProductVariantsJArray: JsonArray): Boolean
    var
        ItemVariant: Record "Item Variant";
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
    begin
        Clear(ItemVariant);
        ItemVariant."Item No." := Item."No.";
        exit(AddVariant(SpfyTask, Item, ItemVariant, NewProduct, ProductVariantsJArray, VarietyValueDic));
    end;

    local procedure AddVariant(SpfyTask: Record "NPR Spfy Task"; Item: Record Item; ItemVariant: Record "Item Variant"; NewProduct: Boolean; var ProductVariantsJArray: JsonArray; var VarietyValueDic: Dictionary of [Integer, List of [Text]]): Boolean
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        VariantJObject: JsonObject;
        ShopifyVariantID: Text[30];
    begin
        SpfyItemMgt.CheckVarieties(Item, ItemVariant);
        if not GenerateVariantJObject(SpfyTask, Item, ItemVariant, NewProduct, ShopifyVariantID, VariantJObject, VarietyValueDic) then
            exit(false);
        ProductVariantsJArray.Add(VariantJObject);
        exit(true);
    end;

    local procedure GenerateVariantJObject(SpfyTask: Record "NPR Spfy Task"; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject): Boolean
    var
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
    begin
        exit(GenerateVariantJObject(SpfyTask, Item, ItemVariant, ProcessNewVariants, ShopifyVariantID, VariantJObject, VarietyValueDic));
    end;

    [TryFunction]
    local procedure GenerateVariantJObject(SpfyTask: Record "NPR Spfy Task"; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject; var VarietyValueDic: Dictionary of [Integer, List of [Text]])
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
        SpfyStoreItemVariantLink."Shopify Store Code" := SpfyTask."Store Code";

        ShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyVariantID = '' then begin
            ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
            if (ShopifyVariantID = '') and (not ProcessNewVariants or (SpfyTask.Type = SpfyTask.Type::Delete)) then
                Error(ItemVariantIsNotSyncedErr, ItemVariant.Code, ItemVariant."Item No.");
        end;
        if not ((ShopifyVariantID <> '') and (SpfyTask.Type = SpfyTask.Type::Delete)) then
            if SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemVariantLink) or SpfyItemMgt.ItemVariantIsBlocked(ItemVariant) then
                Error(ItemVariantIsBlockedOrNotAvailableErr, ItemVariant.Code, ItemVariant."Item No.");

        if ShopifyVariantID <> '' then
            VariantJObject.Add('id', 'gid://shopify/ProductVariant/' + ShopifyVariantID);
        if SpfyTask.Type <> SpfyTask.Type::Delete then begin
            Barcode := GetItemReference(ItemVariant);
            if Barcode <> '' then
                VariantJObject.Add('barcode', Barcode);
            VariantJObject.Add('inventoryPolicy', GetInventoryPolicy(SpfyStoreItemVariantLink));

            InventoryItemJObject.Add('sku', SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code));
            InventoryItemJObject.Add('tracked', not SpfyItemVariantModifMgt.DoNotTrackInventory(SpfyStoreItemVariantLink));
            if Item."Country/Region of Origin Code" <> '' then
                InventoryItemJObject.Add('countryCodeOfOrigin', _SpfyIntegrationMgt.CountryISOCode(Item."Country/Region of Origin Code"));
            if Item."Tariff No." <> '' then
                InventoryItemJObject.Add('harmonizedSystemCode', Item."Tariff No.");
            AddWeightToInventoryItem(SpfyStoreItemVariantLink, InventoryItemJObject);
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

    local procedure AddWeightToInventoryItem(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var InventoryItemJObject: JsonObject)
    var
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        MeasurementJObject: JsonObject;
        WeightJObject: JsonObject;
        WeightValue: Decimal;
        WeightUnit: Enum "NPR Spfy Weight Unit";
    begin
        if not SpfyItemVariantModifMgt.GetVariantWeightWithDefaults(SpfyStoreItemLink, WeightValue, WeightUnit) then
            exit;

        // Build the JSON structure: measurement { weight { value, unit } }
        WeightJObject.Add('value', WeightValue);
        WeightJObject.Add('unit', WeightUnitEnumValueName(WeightUnit));
        MeasurementJObject.Add('weight', WeightJObject);

        InventoryItemJObject.Add('measurement', MeasurementJObject);
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

    internal procedure ReorderVariantsInShopify(Item: Record Item; ShopifyStoreCode: Code[20])
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyProductID: Text[30];
        Reordered: Boolean;
        NotSyncedErr: Label 'Item %1 has not been synced with Shopify store %2 yet. The variant sorting order can only be updated after the product exists in Shopify.', Comment = '%1 - Item No., %2 - Shopify Store Code';
        SortingDisabledErr: Label 'Product variant sorting is disabled. Enable "%1" in the %2 to use this function.', Comment = '%1 - field caption, %2 - setup table caption';
        ReorderedMsg: Label 'The variant sorting order in Shopify has been updated to match the variety value sort order in Business Central.';
        AlreadyInOrderMsg: Label 'The variant sorting order in Shopify already matches the variety value sort order in Business Central.';
    begin
        if not _SpfyIntegrationMgt.ProductVariantSortingEnabled() then
            Error(SortingDisabledErr, SpfyIntegrationSetup.FieldCaption("Enable Product Variant Sorting"), SpfyIntegrationSetup.TableCaption());
        GetStoreItemLink(Item."No.", ShopifyStoreCode, SpfyStoreItemLink);
        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyProductID = '' then
            ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, false);
        if ShopifyProductID = '' then
            Error(NotSyncedErr, Item."No.", ShopifyStoreCode);

        Reordered := ReorderProductVariants(Item, ShopifyStoreCode, ShopifyProductID);
        if not GuiAllowed() then
            exit;
        if Reordered then
            Message(ReorderedMsg)
        else
            Message(AlreadyInOrderMsg);
    end;

    local procedure ReorderProductVariantsBestEffort(Item: Record Item; ShopifyStoreCode: Code[20]; ShopifyProductID: Text[30])
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        if TryReorderProductVariants(Item, ShopifyStoreCode, ShopifyProductID) then
            exit;
        Sentry.AddLastErrorIfProgrammingBug();
        ClearLastError();
    end;

    [TryFunction]
    local procedure TryReorderProductVariants(Item: Record Item; ShopifyStoreCode: Code[20]; ShopifyProductID: Text[30])
    begin
        ReorderProductVariants(Item, ShopifyStoreCode, ShopifyProductID);
    end;

    local procedure ReorderProductVariants(Item: Record Item; ShopifyStoreCode: Code[20]; ShopifyProductID: Text[30]): Boolean
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        OptionReorderJObject: JsonObject;
        OptionValueJObject: JsonObject;
        OptionsJArray: JsonArray;
        ValuesJArray: JsonArray;
        CurrentValuesToken: JsonToken;
        OptionsToken: JsonToken;
        OptionToken: JsonToken;
        ShopifyResponse: JsonToken;
        UserErrors: JsonToken;
        ValueToken: JsonToken;
        CurrentValueIDs: List of [Text];
        OrderedValueIDs: List of [Text];
        OptionID: Text;
        OptionName: Text;
        UserErrorsTxt: Text;
        ValueID: Text;
        ChangedAny: Boolean;
        ReorderFailedErr: Label 'Shopify could not reorder the product options: %1', Comment = '%1 - Shopify user error text';
        ProductOptionsNotFoundErr: Label 'The product with Shopify Product ID %1 could not be found in Shopify, or it has no options. The variant sorting order was not updated.', Comment = '%1 - Shopify Product ID';
    begin
        if ShopifyProductID = '' then
            exit(false);
        if not GetProductOptionsFromShopify(ShopifyProductID, ShopifyStoreCode, ShopifyResponse) then
            Error(GetLastErrorText());
        if not (ShopifyResponse.SelectToken('data.product.options', OptionsToken) and OptionsToken.IsArray()) then
            Error(ProductOptionsNotFoundErr, ShopifyProductID);

        foreach OptionToken in OptionsToken.AsArray() do begin
            OptionID := _JsonHelper.GetJText(OptionToken, 'id', true);
            OptionName := _JsonHelper.GetJText(OptionToken, 'name', false);

            Clear(OptionReorderJObject);
            OptionReorderJObject.Add('id', OptionID);

            if OptionToken.SelectToken('optionValues', CurrentValuesToken) and CurrentValuesToken.IsArray() then begin
                Clear(CurrentValueIDs);
                foreach ValueToken in CurrentValuesToken.AsArray() do
                    CurrentValueIDs.Add(_JsonHelper.GetJText(ValueToken, 'id', true));

                if BuildReorderedOptionValueIDs(Item, OptionName, CurrentValuesToken.AsArray(), OrderedValueIDs) then
                    if not SameStringList(CurrentValueIDs, OrderedValueIDs) then begin
                        Clear(ValuesJArray);
                        foreach ValueID in OrderedValueIDs do begin
                            Clear(OptionValueJObject);
                            OptionValueJObject.Add('id', ValueID);
                            ValuesJArray.Add(OptionValueJObject);
                        end;
                        OptionReorderJObject.Add('values', ValuesJArray);
                        ChangedAny := true;
                    end;
            end;
            OptionsJArray.Add(OptionReorderJObject);
        end;

        if not ChangedAny then
            exit(false);

        Clear(ShopifyResponse);
        if not SendProductOptionsReorder(ShopifyProductID, ShopifyStoreCode, OptionsJArray, ShopifyResponse) then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse, UserErrors) then begin
            UserErrors.WriteTo(UserErrorsTxt);
            Error(ReorderFailedErr, UserErrorsTxt);
        end;
        exit(true);
    end;

    local procedure BuildReorderedOptionValueIDs(Item: Record Item; OptionName: Text; CurrentValues: JsonArray; var OrderedValueIDs: List of [Text]): Boolean
    var
        VRTValue: Record "NPR Variety Value";
        NameToID: Dictionary of [Text, Text];
        AddedIDs: Dictionary of [Text, Boolean];
        ValueToken: JsonToken;
        Variety: Code[20];
        VarietyTable: Code[40];
        ValueID: Text;
        ValueName: Text;
        VarietyDescription: Text;
        VarietyName: Text;
    begin
        Clear(OrderedValueIDs);
        if not FindItemVarietyByOptionName(Item, OptionName, Variety, VarietyTable) then
            exit(false);

        foreach ValueToken in CurrentValues do begin
            ValueName := _JsonHelper.GetJText(ValueToken, 'name', false);
            ValueID := _JsonHelper.GetJText(ValueToken, 'id', true);
            if (ValueName <> '') and not NameToID.ContainsKey(ValueName) then
                NameToID.Add(ValueName, ValueID);
        end;

        VRTValue.SetCurrentKey(Type, "Table", "Sort Order");
        VRTValue.SetRange(Type, Variety);
        VRTValue.SetRange("Table", VarietyTable);
        if VRTValue.FindSet() then
            repeat
                if GetVarietyDescription(Variety, VarietyTable, VRTValue.Value, VarietyName, VarietyDescription) then
                    if NameToID.ContainsKey(VarietyDescription) then begin
                        ValueID := NameToID.Get(VarietyDescription);
                        if not AddedIDs.ContainsKey(ValueID) then begin
                            OrderedValueIDs.Add(ValueID);
                            AddedIDs.Add(ValueID, true);
                        end;
                    end;
            until VRTValue.Next() = 0;

        foreach ValueToken in CurrentValues do begin
            ValueID := _JsonHelper.GetJText(ValueToken, 'id', true);
            if not AddedIDs.ContainsKey(ValueID) then begin
                OrderedValueIDs.Add(ValueID);
                AddedIDs.Add(ValueID, true);
            end;
        end;
        exit(true);
    end;

    local procedure FindItemVarietyByOptionName(Item: Record Item; OptionName: Text; var Variety: Code[20]; var VarietyTable: Code[40]): Boolean
    begin
        // If the option is renamed in Shopify admin so it no longer resembles the variety description, it becomes
        // unmappable and its value order is left untouched (graceful degradation) - re-syncing the item restores
        // the expected name.
        if MatchVarietyOptionName(Item."NPR Variety 1", Item."NPR Variety 1 Table", OptionName, Variety, VarietyTable) then
            exit(true);
        if MatchVarietyOptionName(Item."NPR Variety 2", Item."NPR Variety 2 Table", OptionName, Variety, VarietyTable) then
            exit(true);
        if MatchVarietyOptionName(Item."NPR Variety 3", Item."NPR Variety 3 Table", OptionName, Variety, VarietyTable) then
            exit(true);
        if MatchVarietyOptionName(Item."NPR Variety 4", Item."NPR Variety 4 Table", OptionName, Variety, VarietyTable) then
            exit(true);
        exit(false);
    end;

    local procedure MatchVarietyOptionName(VarietyParam: Code[20]; VarietyTableParam: Code[40]; OptionName: Text; var Variety: Code[20]; var VarietyTable: Code[40]): Boolean
    var
        VRTTable: Record "NPR Variety Table";
    begin
        if (VarietyParam = '') or (VarietyTableParam = '') then
            exit(false);
        if not VRTTable.Get(VarietyParam, VarietyTableParam) then
            exit(false);
        if not SameOptionName(VRTTable.Description, OptionName) then
            exit(false);
        Variety := VarietyParam;
        VarietyTable := VarietyTableParam;
        exit(true);
    end;

    local procedure SameOptionName(VarietyDescription: Text; OptionName: Text): Boolean
    begin
        exit(UpperCase(DelChr(VarietyDescription, '<>', ' ')) = UpperCase(DelChr(OptionName, '<>', ' ')));
    end;

    local procedure SameStringList(ListA: List of [Text]; ListB: List of [Text]): Boolean
    var
        Index: Integer;
    begin
        if ListA.Count() <> ListB.Count() then
            exit(false);
        for Index := 1 to ListA.Count() do
            if ListA.Get(Index) <> ListB.Get(Index) then
                exit(false);
        exit(true);
    end;

    local procedure GetProductOptionsFromShopify(ShopifyProductID: Text[30]; ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        QueryStream: OutStream;
        Request: JsonObject;
        Variables: JsonObject;
        QueryTok: Label 'query GetProductOptions($productID: ID!) {product(id: $productID) {id options{id name optionValues{id name}}}}', Locked = true;
    begin
        SpfyTask."Store Code" := ShopifyStoreCode;
        Variables.Add('productID', 'gid://shopify/Product/' + ShopifyProductID);
        Request.Add('query', QueryTok);
        Request.Add('variables', Variables);
        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        Request.WriteTo(QueryStream);
        exit(GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse));
    end;

    local procedure SendProductOptionsReorder(ShopifyProductID: Text[30]; ShopifyStoreCode: Code[20]; OptionsJArray: JsonArray; var ShopifyResponse: JsonToken): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        QueryStream: OutStream;
        Request: JsonObject;
        Variables: JsonObject;
        QueryTok: Label 'mutation ReorderProductOptions($productId: ID!, $options: [OptionReorderInput!]!) {productOptionsReorder(productId: $productId, options: $options) {userErrors{field message}}}', Locked = true;
    begin
        SpfyTask."Store Code" := ShopifyStoreCode;
        Variables.Add('productId', 'gid://shopify/Product/' + ShopifyProductID);
        Variables.Add('options', OptionsJArray);
        Request.Add('query', QueryTok);
        Request.Add('variables', Variables);
        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        Request.WriteTo(QueryStream);
        exit(GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse));
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

    internal procedure RetrieveShopifyProductAndUpdateItemWithDataFromShopify(SpfyTask: Record "NPR Spfy Task"; ShopifyProductID: Text[30]; TriggeredExternally: Boolean; WithDialog: Boolean)
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
            if SpfyTask.Type = SpfyTask.Type::Delete then
                ShopifyResponse.ReadFrom(StrSubstNo('{"data":{"product":{"id":"gid://shopify/Product/%1"}}}', ShopifyProductID))
            else
                if not GetProductDataFromShopify(ShopifyProductID, SpfyTask."Store Code", Cursor, ShopifyResponse) then
                    Error(CouldNotGetProductErr, GetLastErrorText());
            if _JsonHelper.GetJsonToken(ShopifyResponse, 'data', ProductJToken) then
                UpdateItemWithDataFromShopify(SpfyTask, ProductJToken, TriggeredExternally, Cursor);
        until not _JsonHelper.GetJBoolean(ShopifyResponse, 'data.product.variants.pageInfo.hasNextPage', false) or (Cursor = '');

        if WithDialog then
            Window.Close();
    end;

    local procedure GetProductDataFromShopify(ShopifyProductID: Text[30]; ShopifyStoreCode: Code[20]; Cursor: Text; var ShopifyResponse: JsonToken): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        QueryStream: OutStream;
        Request: JsonObject;
        Variables: JsonObject;
        FirstPageQueryTok: Label 'query GetProduct($productID: ID!) {product(id: $productID) {id title status descriptionHtml vendor hasOnlyDefaultVariant variants(first:25){pageInfo{hasNextPage} edges{cursor node{id sku barcode selectedOptions{name value optionValue{id name}} inventoryPolicy inventoryItem{id tracked measurement{id weight{unit value}}}}}}}}', Locked = true;
        SubsequentPageQueryTok: Label 'query GetProduct($productID: ID!, $afterCursor: String!) {product(id: $productID) {id title status descriptionHtml vendor hasOnlyDefaultVariant variants(first:25, after: $afterCursor){pageInfo{hasNextPage} edges{cursor node{id sku barcode selectedOptions{name value optionValue{id name}} inventoryPolicy inventoryItem{id tracked measurement{id weight{unit value}}}}}}}}', Locked = true;
    begin
        SpfyTask."Store Code" := ShopifyStoreCode;
        Variables.Add('productID', 'gid://shopify/Product/' + ShopifyProductID);
        if Cursor = '' then
            Request.Add('query', FirstPageQueryTok)
        else begin
            Request.Add('query', SubsequentPageQueryTok);
            Variables.Add('afterCursor', Cursor);
        end;
        Request.Add('variables', Variables);
        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        Request.WriteTo(QueryStream);

        exit(GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse));
    end;

    local procedure UpdateItemWithDataFromShopify(SpfyTask: Record "NPR Spfy Task"; ShopifyResponse: JsonToken; TriggeredExternally: Boolean; var Cursor: Text)
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
            if SpfyTask.Type = SpfyTask.Type::Delete then begin
                if SpfyItemMgt.FindItemByShopifyProductID(SpfyTask."Store Code", ShopifyProductID, SpfyStoreItemLink) then begin
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
        if SpfyTask.Type = SpfyTask.Type::Insert then
            SpfySalesChannelMgt.PublishProductToSalesChannels(SpfyTask."Store Code", ShopifyProductID);

        ShopifyProductTitle := _JsonHelper.GetJText(ShopifyResponse, 'product.title', MaxStrLen(SpfyStoreItemLink."Shopify Name"), false);
        ShopifyProductDetailedDescr := _JsonHelper.GetJText(ShopifyResponse, 'product.descriptionHtml', false);
        ShopifyProductStatus := _JsonHelper.GetJText(ShopifyResponse, 'product.status', false);
        ShopifyProductVendor := _JsonHelper.GetJText(ShopifyResponse, 'product.vendor', false);

        BCIsNameDescriptionMaster := _SpfyIntegrationMgt.IsSendShopifyNameAndDescription(SpfyTask."Store Code");
        RefreshIntegrationStatus(SpfyTask."Store Code");

        FirstVariant := true;
        foreach ShopifyVariant in ShopifyVariants.AsArray() do begin
            Cursor := _JsonHelper.GetJText(ShopifyVariant, 'cursor', false);
            if ShopifyVariant.SelectToken('node', ShopifyVariant) then
                if SpfyItemMgt.ParseItem(SpfyTask."Store Code", ShopifyVariant, ItemVariant, VariantSku) then begin
                    if (FirstPage and FirstVariant) or (ItemVariant.Code = '') then begin
                        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
                        SpfyStoreItemLink."Item No." := ItemVariant."Item No.";
                        SpfyStoreItemLink."Variant Code" := '';
                        SpfyStoreItemLink."Shopify Store Code" := SpfyTask."Store Code";
                        LinkExists := SpfyStoreItemLink.Find();
                        if SpfyTask.Type = SpfyTask.Type::Delete then begin
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
                    UpdateItemVariant(SpfyTask."Store Code", ShopifyVariant, ItemVariant, TriggeredExternally, SkipRecalc);
                end;
        end;
    end;

    local procedure UpdateItemVariantWithDataFromShopify(ShopifyStoreCode: Code[20]; ShopifyVariant: JsonToken)
    var
        ItemVariant: Record "Item Variant";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        VariantSku: Text;
    begin
        if SpfyItemMgt.ParseItem(ShopifyStoreCode, ShopifyVariant, ItemVariant, VariantSku) then
            UpdateItemVariant(ShopifyStoreCode, ShopifyVariant, ItemVariant, false, false);
    end;

    local procedure UpdateItemVariant(ShopifyStoreCode: Code[20]; ShopifyVariant: JsonToken; ItemVariant: Record "Item Variant"; TriggeredExternally: Boolean; SkipRecalc: Boolean)
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        ShopifyInventoryItemID: Text[30];
        xShopifyInventoryItemID: Text[30];
        ShopifyVariantID: Text[30];
        xShopifyVariantID: Text[30];
        WeightUnitText: Text;
        WeightUnit: Enum "NPR Spfy Weight Unit";
        WeightValue: Decimal;
        xDoNotTrackInventory: Boolean;
        SkipNotAvailableReset: Boolean;
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;
        xDoNotTrackInventory := SpfyItemVariantModifMgt.DoNotTrackInventory(SpfyStoreItemVariantLink);

        SpfyItemVariantModifMgt.SetAllowBackorder(SpfyStoreItemVariantLink, _JsonHelper.GetJText(ShopifyVariant, 'inventoryPolicy', false).ToUpper() = 'CONTINUE', true);
        if _JsonHelper.TokenExists(ShopifyVariant, 'inventoryItem.tracked') then
            SpfyItemVariantModifMgt.SetDoNotTrackInventory(SpfyStoreItemVariantLink, not _JsonHelper.GetJBoolean(ShopifyVariant, 'inventoryItem.tracked', true), true);

        if _JsonHelper.TokenExists(ShopifyVariant, 'inventoryItem.measurement.weight.value') then begin
            WeightValue := _JsonHelper.GetJDecimal(ShopifyVariant, 'inventoryItem.measurement.weight.value', false);
            WeightUnitText := _JsonHelper.GetJText(ShopifyVariant, 'inventoryItem.measurement.weight.unit', false);
            if (WeightValue > 0) and (WeightUnitText <> '') then
                if Evaluate(WeightUnit, WeightUnitText) then
                    SpfyItemVariantModifMgt.SetVariantWeight(SpfyStoreItemVariantLink, WeightValue, WeightUnit, true);
        end;

#pragma warning disable AA0139
        ShopifyVariantID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyVariant, 'id', true), '/');
        ShopifyInventoryItemID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyVariant, 'inventoryItem.id', true), '/');
#pragma warning restore AA0139
        xShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        xShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
        // A successful (re)send means the variant is live in Shopify → clear Not Available. BUT skip this when the variant
        // has an OUTSTANDING rowversion-outbox delete: the read-back returned it only because that delete hasn't sent yet,
        // and resetting the flag would spuriously cancel the user's pending delete (CORE-433). NESTED (AL has no
        // short-circuit) so the Deletion Log lookup never runs on the legacy Data Log path; user re-enable uses the page setter.
        SkipNotAvailableReset := false;
        if SpfyRowVersionFeature.IsFeatureEnabled() then
            SkipNotAvailableReset := SpfyDeletionLogMgt.HasOutstandingDelete(Database::"Item Variant", ShopifyStoreCode, "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID);
        if not SkipNotAvailableReset then
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
        Window: Dialog;
    begin
        Window.Open(_QueryingShopifyLbl);
        ClearLastError();
        GetShopifyLocations(ShopifyStoreCode, TempShopifyLocation);
        Window.Close();
        if Page.RunModal(Page::"NPR Spfy Locations", TempShopifyLocation) = Action::LookupOK then begin
            SelectedLocationID := TempShopifyLocation.ID;
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetShopifyLocations(ShopifyStoreCode: Code[20]; var TempShopifyLocation: Record "NPR Spfy Location" temporary)
    var
        SpfyTask: Record "NPR Spfy Task";
        Cursor: Text;
        HasNext: Boolean;
        ShopifyResponse: JsonToken;
        LocationRequest: Label 'query GetLocations($afterCursor: String) { locations(first:100, after: $afterCursor) { pageInfo{endCursor hasNextPage} edges { node { id name address { address1 address2 city zip countryCode } isActive } } } }', Locked = true;
    begin
        Cursor := '';
        HasNext := true;
        repeat
            CreateRequest(SpfyTask, Cursor, ShopifyStoreCode, LocationRequest);
            if not GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse) then
                Error(GetLastErrorText());
            Cursor := _JsonHelper.GetJText(ShopifyResponse, 'data.locations.pageInfo.endCursor', false);
            HasNext := _JsonHelper.GetJBoolean(ShopifyResponse, 'data.locations.pageInfo.hasNextPage', true);

            HandleGetLocationsResponse(ShopifyResponse, TempShopifyLocation);
        until not HasNext;
        TempShopifyLocation.Reset();
    end;

    local procedure HandleGetLocationsResponse(var ShopifyResponse: JsonToken; var TempShopifyLocation: Record "NPR Spfy Location" temporary)
    var
        ReceivedShopifyLocations: JsonToken;
        ReceivedShopifyLocation: JsonToken;
        ReceivedShopifyLocationsErr: Label 'Invalid GraphQL response: missing "data.locations" node.', Locked = true;
    begin
        ReceivedShopifyLocations := _JsonHelper.GetJsonToken(ShopifyResponse, 'data.locations.edges');
        if (not ReceivedShopifyLocations.IsArray()) then
            Error(ReceivedShopifyLocationsErr);

        foreach ReceivedShopifyLocation in ReceivedShopifyLocations.AsArray() do begin
            TempShopifyLocation.Init();
#pragma warning disable AA0139
            TempShopifyLocation.ID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ReceivedShopifyLocation, 'node.id', true), '/');
            if not TempShopifyLocation.Find() then begin
                TempShopifyLocation.Name := _JsonHelper.GetJText(ReceivedShopifyLocation, 'node.name', MaxStrLen(TempShopifyLocation.Name), false);
                TempShopifyLocation.Address := _JsonHelper.GetJText(ReceivedShopifyLocation, 'node.address.address1', MaxStrLen(TempShopifyLocation.Address), false);
                TempShopifyLocation."Address 2" := _JsonHelper.GetJText(ReceivedShopifyLocation, 'node.address.address2', MaxStrLen(TempShopifyLocation."Address 2"), false);
                TempShopifyLocation.City := _JsonHelper.GetJText(ReceivedShopifyLocation, 'node.address.city', MaxStrLen(TempShopifyLocation.City), false);
                TempShopifyLocation."Post Code" := _JsonHelper.GetJText(ReceivedShopifyLocation, 'node.address.zip', MaxStrLen(TempShopifyLocation."Post Code"), false);
                TempShopifyLocation."Country/Region Code" := _SpfyIntegrationMgt.TranslateCountryCode(_JsonHelper.GetJText(ReceivedShopifyLocation, 'node.address.countryCode', false));
#pragma warning restore AA0139
                TempShopifyLocation.Active := _JsonHelper.GetJBoolean(ReceivedShopifyLocation, 'node.isActive', false);
                TempShopifyLocation.Insert();
            end;
        end;
    end;

    local procedure CreateRequest(var SpfyTask: Record "NPR Spfy Task"; Cursor: Text; ShopifyStoreCode: code[20]; RequestString: text)
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        VariablesJson: JsonObject;
    begin
        Clear(SpfyTask);
        SpfyTask."Store Code" := ShopifyStoreCode;
        SpfyCommunicationHandler.AddGraphQLCursor(VariablesJson, Cursor);
        CompleteRequest(RequestString, VariablesJson, SpfyTask);
    end;

    local procedure CompleteRequest(RequestString: text; VariablesJson: JsonObject; var SpfyTask: Record "NPR Spfy Task")
    var
        QueryStream: OutStream;
        RequestJson: JsonObject;
    begin
        RequestJson.Add('query', RequestString);
        RequestJson.Add('variables', VariablesJson);
        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);
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
        TempSpfyTask: Record "NPR Spfy Task" temporary;
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

        TempSpfyTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        TempSpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        Request.WriteTo(OStream);

        ClearLastError();
        Success := GetGraphQLClient().ExecuteRequest(TempSpfyTask, true, ShopifyResponse);
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
                Clear(TempSpfyTask);
                TempSpfyTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
                TempSpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
                Request.WriteTo(OStream);

                ClearLastError();
                Success := GetGraphQLClient().ExecuteRequest(TempSpfyTask, true, ShopifyResponse);
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
        SpfyTask: Record "NPR Spfy Task";
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
        SpfyTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        SpfyTask.Type := SpfyTask.Type::Modify;
        RetrieveShopifyProductAndUpdateItemWithDataFromShopify(SpfyTask, ShopifyProductID, true, false);
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
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
    begin
        if DisableDataLog then
            DataLogMgt.DisableDataLog(true);
        SpfyStoreItemLink.Modify(true);
        if DisableDataLog then begin
            DataLogMgt.DisableDataLog(false);
            // Self-write convergence (CORE-433): advance the rowversion-poll baseline to this post-writeback state so
            // mirroring Shopify's product response (Name/Description/Vendor) back here doesn't re-trigger a sync.
            // No-op when the RowVersion feature is off; user edits come in with DisableDataLog=false → still detected.
            SpfySyncStateMgt.AdvanceStoreItemLinkBaseline(SpfyStoreItemLink);
        end;
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
        ClearLocationActivations(SpfyStoreItemLink);
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

    // Only when the Shopify inventory item is gone: an id re-map on a live product must keep the merchant's Auto-Activation Disabled.
    // A row that is neither activated nor disabled just says "activate me" and may already belong to the re-created variant, so it stays.
    internal procedure ClearLocationActivations(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        LocationInvItem.SetCurrentKey("Shopify Store Code", "Item No.", "Variant Code");
        LocationInvItem.SetRange("Shopify Store Code", SpfyStoreItemLink."Shopify Store Code");
        LocationInvItem.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if SpfyStoreItemLink."Variant Code" <> '' then
            LocationInvItem.SetRange("Variant Code", SpfyStoreItemLink."Variant Code");
        LocationInvItem.SetRange(Activated, true);
        if not LocationInvItem.IsEmpty() then
            LocationInvItem.DeleteAll();
        LocationInvItem.SetRange(Activated);
        LocationInvItem.SetRange("Auto-Activation Disabled", true);
        if not LocationInvItem.IsEmpty() then
            LocationInvItem.DeleteAll();
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    begin
        _SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Task Send Items&Inv(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy Task Send Items&Inv");
    end;

    local procedure ProductStatusEnumValueName(ProductStatus: Enum "NPR Spfy Product Status") Result: Text
    begin
        ProductStatus.Names().Get(ProductStatus.Ordinals().IndexOf(ProductStatus.AsInteger()), Result);
    end;

    local procedure WeightUnitEnumValueName(WeightUnit: Enum "NPR Spfy Weight Unit") Result: Text
    begin
        WeightUnit.Names().Get(WeightUnit.Ordinals().IndexOf(WeightUnit.AsInteger()), Result);
    end;

    local procedure GenerateRequestAndSetSpfyTaskClaimed(var SpfyTaskIn: Record "NPR Spfy Task"; ShopifyProductID: Text[30]; var RequestedVariantBuffer: Record "NPR Spfy ID/Task Buffer"; var Request: JsonObject) Success: Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        IStream: InStream;
        VariantsJArray: JsonArray;
        Variables: JsonObject;
        VariantJObject: JsonObject;
        EmptyResponseJson: JsonToken;
        PrestagedState: Enum "NPR Spfy Task State";
        NoPreparedRequestLbl: Label 'The update was not sent: no request payload was prepared for this task.';
        VariantBulkDelete_QueryTok: Label 'mutation DeleteProductVariants($productId: ID!, $variants: [ID!]!) {productVariantsBulkDelete(productId: $productId, variantsIds : $variants) {product{id} userErrors{field message}}}', Locked = true;
        VariantBulkInsert_QueryTok: Label 'mutation CreateProductVariants($productId: ID!, $variants: [ProductVariantsBulkInput!]!) {productVariantsBulkCreate(productId: $productId, variants : $variants) {product{id} productVariants{id sku inventoryPolicy selectedOptions{name value optionValue{id name}} inventoryItem{id tracked}} userErrors{field message}}}', Locked = true;
        VariantBulkUpdate_QueryTok: Label 'mutation UpdateProductVariants($productId: ID!, $variants: [ProductVariantsBulkInput!]!, $allowPartialUpdates: Boolean) {productVariantsBulkUpdate(productId: $productId, variants : $variants, allowPartialUpdates: $allowPartialUpdates) {product{id} productVariants{id sku inventoryPolicy selectedOptions{name value optionValue{id name}} inventoryItem{id tracked}} userErrors{field message}}}', Locked = true;
    begin
        if not SpfyTaskIn.IsTemporary() then
            FunctionCallOnNonTempVarErr('SetSpfyTaskClaimed');
        Clear(Request);
        Clear(VariantsJArray);
        RequestedVariantBuffer.Reset();
        RequestedVariantBuffer.DeleteAll();
        if not SpfyTaskIn.FindSet() then
            exit;

        case
            SpfyTaskIn.Type of
            SpfyTaskIn.Type::Insert:
                Request.Add('query', VariantBulkInsert_QueryTok);
            SpfyTaskIn.Type::Modify:
                begin
                    Request.Add('query', VariantBulkUpdate_QueryTok);
                    Variables.Add('allowPartialUpdates', true);
                end;
            SpfyTaskIn.Type::Delete:
                Request.Add('query', VariantBulkDelete_QueryTok);
        end;
        Variables.Add('productId', 'gid://shopify/Product/' + ShopifyProductID);

        repeat
            PrestagedState := SpfyTaskIn.State;
            SpfyTaskIn.CalcFields(Response);
            if (PrestagedState = PrestagedState::Completed) or (SpfyTaskIn.Response.Length() > 0) then begin
                SpfyTaskQueue.TransferPrestagedOutcome(SpfyTaskIn."Entry No.", SpfyTaskIn, PrestagedState, SpfyTask);
                SpfyTaskIn.Delete();
            end else
                if RequestedVariantBuffer.RecordValueExists(SpfyTaskIn."Record Value") then begin
                    SpfyTaskQueue.CompleteAsDuplicate(SpfyTaskIn, RequestedVariantBuffer."Nc Task Entry No.");
                    SpfyTaskIn.Delete();
                end else
                    if SpfyTaskQueue.ClaimForBatch(SpfyTaskIn) then begin
                        SpfyTaskIn.CalcFields("Data Output");
                        Clear(VariantJObject);
                        SpfyTaskIn."Data Output".CreateInStream(IStream, TextEncoding::UTF8);
                        if not VariantJObject.ReadFrom(IStream) then begin
                            SpfyTaskQueue.CompleteFromBatch(SpfyTaskIn."Entry No.", EmptyResponseJson, false, NoPreparedRequestLbl, SpfyTask);
                            SpfyTaskIn.Delete();
                        end else begin
                            if SpfyTaskIn.Type = SpfyTaskIn.Type::Delete then
                                VariantsJArray.Add(_JsonHelper.GetJText(VariantJObject.AsToken(), 'id', true))
                            else
                                VariantsJArray.Add(VariantJObject);
                            RequestedVariantBuffer.AddEntry(SpfyTaskIn."Record Value", SpfyTaskIn."Entry No.", SpfyTaskIn."Record ID");
                            Success := true;
                        end;
                    end else
                        SpfyTaskIn.Delete();
        until SpfyTaskIn.Next() = 0;
        Variables.Add('variants', VariantsJArray);
        Request.Add('variables', Variables);
        Commit();
    end;

    local procedure SetSpfyTaskClaimed(var SpfyTaskIn: Record "NPR Spfy Task"; var RequestString: Text) Success: Boolean
    var
        MutationQueryRequestLabel: Label 'mutation UpdateProductVariants { %1 }', Locked = true, Comment = '%1 = Update Product Variants Array';
        productVariantsBulkUpdateRequestStringTextBuilder: TextBuilder;
    begin
        if not SpfyTaskIn.IsTemporary() then
            FunctionCallOnNonTempVarErr('SetSpfyTaskClaimed');

        Success := GenerateBulkRequest(SpfyTaskIn, productVariantsBulkUpdateRequestStringTextBuilder);

        RequestString := StrSubstNo(MutationQueryRequestLabel, productVariantsBulkUpdateRequestStringTextBuilder.ToText());
    end;

    local procedure GenerateBulkRequestAndSetSpfyTaskClaimed(var SpfyTaskIn: Record "NPR Spfy Task"; var RequestJObject: JsonObject) Success: Boolean
    var
        RequestStringTextBuilder: TextBuilder;
        Request: Text;
    begin
        Clear(RequestJObject);
        if not SpfyTaskIn.IsTemporary() then
            FunctionCallOnNonTempVarErr('GenerateBulkRequestAndSetSpfyTaskClaimed');

        Success := GenerateBulkRequest(SpfyTaskIn, RequestStringTextBuilder);

        Request := RequestStringTextBuilder.ToText();
        if Request <> '' then
            RequestJObject.Add('query', StrSubstNo('mutation {%1}', Request));
    end;

    local procedure GenerateBulkRequest(var SpfyTaskIn: Record "NPR Spfy Task"; var RequestStringTextBuilder: TextBuilder) Success: Boolean
    begin
        if not SpfyTaskIn.FindSet() then
            exit(false);

        RequestStringTextBuilder.Clear();
        repeat
            UpdateSpfyTaskBatchProcessing(SpfyTaskIn, Success, RequestStringTextBuilder)
        until SpfyTaskIn.Next() = 0;
        Commit();
    end;

    local procedure UpdateSpfyTaskBatchProcessing(var SpfyTaskIn: Record "NPR Spfy Task"; var Success: Boolean; var RequestStringTextBuilder: TextBuilder)
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        IStream: InStream;
        BulkUpdateRequestStringPart: Text;
        PrestagedState: Enum "NPR Spfy Task State";
    begin
        PrestagedState := SpfyTaskIn.State;
        SpfyTaskIn.CalcFields(Response);
        if (PrestagedState = PrestagedState::Completed) or (SpfyTaskIn.Response.Length() > 0) then begin
            SpfyTaskQueue.TransferPrestagedOutcome(SpfyTaskIn."Entry No.", SpfyTaskIn, PrestagedState, SpfyTask);
            SpfyTaskIn.Delete();
        end else
            if SpfyTaskQueue.ClaimForBatch(SpfyTaskIn) then begin
                SpfyTaskIn.CalcFields("Data Output");
                SpfyTaskIn."Data Output".CreateInStream(IStream, TextEncoding::UTF8);
                IStream.ReadText(BulkUpdateRequestStringPart);
                RequestStringTextBuilder.Append(BulkUpdateRequestStringPart);
                Success := true;
            end else
                SpfyTaskIn.Delete();
    end;

    local procedure CreateSpfyTaskParam(var SpfyTaskIn: Record "NPR Spfy Task"; var SpfyTaskParam: Record "NPR Spfy Task"; productVariantsBulkUpdateRequest: Text)
    var
        OStream: OutStream;
        RequestJObject: JsonObject;
    begin
        Clear(SpfyTaskParam);
        if productVariantsBulkUpdateRequest = '' then
            exit;

        SpfyTaskParam."Entry No." := 0;
        SpfyTaskParam.Type := SpfyTaskIn.Type;
        SpfyTaskParam."Table No." := SpfyTaskIn."Table No.";
        SpfyTaskParam."Table Name" := SpfyTaskIn."Table Name";
        SpfyTaskParam."Store Code" := SpfyTaskIn."Store Code";
        SpfyTaskParam."Not Before Date-Time" := SpfyTaskIn."Not Before Date-Time";
        RequestJObject.Add('query', productVariantsBulkUpdateRequest);
        SpfyTaskParam."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        RequestJObject.WriteTo(OStream);
    end;

    local procedure GetProductVariantForItemPrice(var ItemPrice: Record "NPR Spfy Item Price"): Text[30]
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        exit(SpfyItemMgt.GetAssignedShopifyVariantID(ItemPrice."Item No.", ItemPrice."Variant Code", ItemPrice."Shopify Store Code", true));
    end;

    local procedure FindSpfyTaskInDictionary(var SpfyTaskIn: Record "NPR Spfy Task"; ResponseDictionary: Dictionary of [Text[30], Dictionary of [Text[30], Text]]; var SpfyTaskErrorText: Text): Boolean
    var
        SpfyTaskNotFoundLbl: Label 'Task %1 was not found in the Shopify response.';
        InvalidProductVariantIDLbl: Label 'Product Variant ID %1 could not be validated.';
        SpfyTaskResultDictionary: Dictionary of [Text[30], Text];
    begin
        Clear(SpfyTaskErrorText);
        if not ResponseDictionary.ContainsKey(StrSubstNo('SpfyTask%1', Format(SpfyTaskIn."Entry No."))) then begin
            SpfyTaskErrorText := StrSubstNo(SpfyTaskNotFoundLbl, Format(SpfyTaskIn."Entry No."));
            exit;
        end;

        SpfyTaskResultDictionary := ResponseDictionary.Get(StrSubstNo('SpfyTask%1', Format(SpfyTaskIn."Entry No.")));
        case true of
            SpfyTaskResultDictionary.ContainsKey('VariantID'):
                begin
                    if not ValidateProductVariantId(SpfyTaskIn, CopyStr(SpfyTaskResultDictionary.Get('VariantID'), 1, 30)) then begin
                        SpfyTaskErrorText := StrSubstNo(InvalidProductVariantIDLbl, SpfyTaskResultDictionary.Get('VariantID'));
                        exit;
                    end;
                    exit(true);
                end;
            SpfyTaskResultDictionary.ContainsKey('Error'):
                begin
                    SpfyTaskErrorText := SpfyTaskResultDictionary.Get('Error');
                    exit;
                end;
        end;
    end;

    local procedure SendShopifyActivateInventoryItemAtLocation(var SpfyTask: Record "NPR Spfy Task")
    var
        InventoryLocation: Record "NPR Spfy Inv Item Location";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        RecRef: RecordRef;
        RequestPrepared: Boolean;
        Success: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();
        Success := true;

        RecRef.Get(SpfyTask."Record ID");
        RecRef.SetTable(InventoryLocation);
        RequestPrepared := PrepareActivateInventoryItemAtLocationRequest(SpfyTask, InventoryLocation);
        if RequestPrepared then
            Success := GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse);
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
        // A skipped preparation completes the task with its reason, but must never mark an activation Shopify was not asked for.
        if not RequestPrepared then
            exit;
        InventoryLocation.Activated := Success;
        InventoryLocation.Modify();
    end;

    local procedure PrepareActivateInventoryItemAtLocationRequest(var SpfyTask: Record "NPR Spfy Task"; InventoryLocation: Record "NPR Spfy Inv Item Location"): Boolean
    var
        RequestJObject: JsonObject;
        VariablesJObject: JsonObject;
        OStream: OutStream;
        ShopifyInventoryItemID: Text[30];
        ActivateItemRequestLegacy: Label 'mutation ActivateInventoryItem($inventoryItemId: ID!, $locationId: ID!, $available: Int) {inventoryActivate(inventoryItemId: $inventoryItemId, locationId: $locationId, available: $available) {userErrors {message}}}', Locked = true;
        ActivateItemRequest202604: Label 'mutation ActivateInventoryItem($inventoryItemId: ID!, $locationId: ID!, $available: Int, $idempotencyKey: String!) {inventoryActivate(inventoryItemId: $inventoryItemId, locationId: $locationId, available: $available) @idempotent(key: $idempotencyKey) {userErrors {message}}}', Locked = true;
    begin
        If not ValidateInventoryItem(SpfyTask, InventoryLocation, ShopifyInventoryItemID) then
            exit(false);
        VariablesJObject.Add('inventoryItemId', StrSubstNo('gid://shopify/InventoryItem/%1', ShopifyInventoryItemID));
        VariablesJObject.Add('locationId', StrSubstNo('gid://shopify/Location/%1', InventoryLocation."Shopify Location ID"));
        if _SpfyIntegrationMgt.ShopifyApiVersionIsAtLeast('2026-04') then begin
            VariablesJObject.Add('idempotencyKey', Format(SpfyTask."Dispatch Id", 0, 4));
            RequestJObject.Add('query', ActivateItemRequest202604);
        end else
            RequestJObject.Add('query', ActivateItemRequestLegacy);
        RequestJObject.Add('variables', VariablesJObject);
        SpfyTask."Store Code" := InventoryLocation."Shopify Store Code";
        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        RequestJObject.WriteTo(OStream);
        exit(true);
    end;

    internal procedure ValidateInventoryItem(var SpfyTask: Record "NPR Spfy Task"; InventoryLocation: Record "NPR Spfy Inv Item Location"; var ShopifyInventoryItemID: Text[30]): Boolean
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        VariantNotAvailErr: Label 'The variant is marked as not available in Shopify. The request is no longer applicable.';
    begin
        Clear(ShopifyInventoryItemID);
        if InventoryLocation."Variant Code" <> '' then
            if not ItemVariant.Get(InventoryLocation."Item No.", InventoryLocation."Variant Code") or SpfyItemMgt.ItemVariantIsBlocked(ItemVariant) then begin
                _SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(_ItemVariantBlockedOrDoesNotExistErr, InventoryLocation."Item No.", InventoryLocation."Variant Code"));
                exit(false);
            end;

        GetStoreItemLink(InventoryLocation."Item No.", InventoryLocation."Shopify Store Code", SpfyStoreItemLink);  //Check integration is enabled for the item
        If ItemVariantNotAvailableInShopify(SpfyStoreItemLink, InventoryLocation."Item No.", InventoryLocation."Variant Code", InventoryLocation."Shopify Store Code") then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTask, VariantNotAvailErr);
            exit(false);
        end;

        ShopifyInventoryItemID := FindShopifyInventoryItemID(SpfyStoreItemLink);
        if ShopifyInventoryItemID = '' then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(_InventoryItemIDNotFoundErr, InventoryLocation.FieldCaption("Item No."), InventoryLocation."Item No.", InventoryLocation.FieldCaption("Variant Code"), InventoryLocation."Variant Code", InventoryLocation."Shopify Store Code"));
            exit(false);
        end;
        exit(true);
    end;

    local procedure FindShopifyInventoryItemID(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link") ShopifyInventoryItemID: Text[30]
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        if ShopifyInventoryItemID <> '' then
            exit(ShopifyInventoryItemID);
        ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemLink, false);
        if ShopifyInventoryItemID <> '' then begin
            SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
            Commit();
        end;
    end;

    internal procedure RefreshIntegrationStatus(ShopifyStoreCode: Code[20])
    begin
        _InventoryIntegrIsEnabled := _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", ShopifyStoreCode);
        _ItemPriceIntegrIsEnabled := _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", ShopifyStoreCode);
    end;

    internal procedure TryFindShopifyProductID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var ShopifyProductID: Text[30]): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ShopifyProductID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyProductID = '' then
            ShopifyProductID := GetShopifyProductID(SpfyStoreItemLink, false);
        exit(ShopifyProductID <> '');
    end;

    internal procedure AssignShopifyProductID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ShopifyProductID: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyProductID, false);
        Commit();
    end;

    internal procedure TryFindShopifyInventoryItemID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var ShopifyInventoryItemID: Text[30]): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        if ShopifyInventoryItemID = '' then
            ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemLink, false);
        exit(ShopifyInventoryItemID <> '');
    end;

    internal procedure AssignShopifyInventoryItemID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ShopifyInventoryItemID: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
        Commit();
    end;

    internal procedure TryFindShopifyVariantID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var ShopifyVariantID: Text[30]): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyVariantID = '' then
            ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemLink, false);
        exit(ShopifyVariantID <> '');
    end;

    internal procedure AssignShopifyVariantID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ShopifyVariantID: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
        Commit();
    end;
}
