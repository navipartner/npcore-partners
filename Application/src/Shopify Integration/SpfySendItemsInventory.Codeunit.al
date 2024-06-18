#if not BC17
codeunit 6184819 "NPR Spfy Send Items&Inventory"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        Rec.TestField("Store Code");
        case Rec."Table No." of
            Database::Item:
                SendItem(Rec);
            Database::"Item Variant":
                SendItemVariant(Rec);
            Database::"Inventory Buffer":
                SendItemCost(Rec);
            Database::"NPR Spfy Inventory Level":
                SendShopifyInventoryUpdate(Rec);
        end;
    end;

    var
        LastQueriedSpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        GlobalShopifyInventoryItemID: Text[30];
        GlobalShopifyItemID: Text[30];
        GlobalShopifyVariantID: Text[30];
        InventoryItemIDNotFoundErr: Label 'Shopify Inventory Item ID could not be found for %1=%2, %3=%4 at Shopify Store %5', Comment = '%1 = Item No. fieldcaption, %2 = Item No., %3 = Variant Code fieldcaption, %4 = Variant Code, %5 = Shopify Store Code';
        QueryingShopifyLbl: Label 'Querying Shopify...';

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
            Error(GetLastErrorText);

        UpdateItemWithDataFromShopify(NcTask, ShopifyResponse);
    end;

    local procedure SendItemVariant(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ShopifyItemID: Text[30];
        ShopifyVariantID: Text[30];
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        if PrepareItemVariantUpdateRequest(NcTask, ShopifyItemID, ShopifyVariantID) then
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

        if Success and (NcTask.Type in [NcTask.Type::Insert, NcTask.Type::Modify]) then
            UpdateItemVariantWithDataFromShopify(NcTask."Store Code", ShopifyResponse);
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

    local procedure SendShopifyInventoryUpdate(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        if PrepareInventoryLevelUpdateRequest(NcTask) then
            Success := SpfyCommunicationHandler.SendInvetoryLevelUpdateRequest(NcTask);

        NcTask.Modify();
        Commit();
        if not Success then
            Error(GetLastErrorText);
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

    [TryFunction]
    local procedure PrepareItemVariantUpdateRequest(var NcTask: Record "NPR Nc Task"; var ShopifyItemID: Text[30]; var ShopifyVariantID: Text[30])
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        VariantJObject: JsonObject;
        RequestJObject: JsonObject;
        OStream: OutStream;
        ShopifyVariantIdEmptyErr: Label 'Shopify Variant Id must be specified for %1', Comment = '%1 - Item Variant record id';
    begin
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(ItemVariant);
        Item.Get(ItemVariant."Item No.");

        GetStoreItemLink(Item."No.", NcTask."Store Code", SpfyStoreItemLink);

        ShopifyItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyItemID = '' then
            ShopifyItemID := GetShopifyItemID(SpfyStoreItemLink, false);
        if ShopifyItemID = '' then
            Error('');  //Will be sent together with item

        GenerateVariantJObject2(NcTask."Store Code", Item, ItemVariant, true, ShopifyVariantID, VariantJObject);
        if ShopifyVariantID = '' then begin
            case NcTask.Type of
                NcTask.Type::Modify:
                    NcTask.Type := NcTask.Type::Insert;
                NcTask.Type::Delete:
                    Error(ShopifyVariantIdEmptyErr, Format(ItemVariant.RecordId()));
            end;
        end else
            if NcTask.Type = NcTask.Type::Insert then
                NcTask.Type := NcTask.Type::Modify;

        RequestJObject.Add('variant', VariantJObject);
        NcTask."Data Output".CreateOutStream(OStream);
        RequestJObject.WriteTo(OStream);
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
            Error(InventoryItemIDNotFoundErr,
                ItemVariant.FieldCaption("Item No."), Item."No.", StrSubstNo('%1 %2', ItemVariant.TableCaption, ItemVariant.FieldCaption(Code)), ItemVariant.Code, ShopifyStoreCode);

        RequestJObjectChild.Add('id', ShopifyInventoryItemID);
        RequestJObjectChild.Add('cost', Item."Last Direct Cost");
        RequestJObject.Add('inventory_item', RequestJObjectChild);

        NcTaskOutput.Data.CreateOutStream(OStream);
        RequestJObject.WriteTo(OStream);
    end;

    [TryFunction]
    local procedure PrepareInventoryLevelUpdateRequest(var NcTask: Record "NPR Nc Task")
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        RequestJObject: JsonObject;
        OStream: OutStream;
        ShopifyInventoryItemID: Text[30];
    begin
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(InventoryLevel);

        GetStoreItemLink(InventoryLevel."Item No.", InventoryLevel."Shopify Store Code", SpfyStoreItemLink);  //Check integration is enabled for the item

        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::"Variant";
        SpfyStoreItemLink."Item No." := InventoryLevel."Item No.";
        SpfyStoreItemLink."Variant Code" := InventoryLevel."Variant Code";
        SpfyStoreItemLink."Shopify Store Code" := InventoryLevel."Shopify Store Code";

        ShopifyInventoryItemID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        if ShopifyInventoryItemID = '' then begin
            ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemLink, false);
            if ShopifyInventoryItemID <> '' then begin
                SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
                Commit();
            end;
        end;
        if ShopifyInventoryItemID = '' then
            Error(InventoryItemIDNotFoundErr,
                InventoryLevel.FieldCaption("Item No."), InventoryLevel."Item No.", InventoryLevel.FieldCaption("Variant Code"), InventoryLevel."Variant Code", InventoryLevel."Shopify Store Code");

        RequestJObject.Add('location_id', InventoryLevel."Shopify Location ID");
        RequestJObject.Add('inventory_item_id', ShopifyInventoryItemID);
        RequestJObject.Add('available', Format(InventoryLevel.AvailableInventory(), 0, 9));

        NcTask."Store Code" := InventoryLevel."Shopify Store Code";
        NcTask."Data Output".CreateOutStream(OStream);
        RequestJObject.WriteTo(OStream);
    end;

    local procedure AddItemInfo(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Item: Record Item; NcTaskType: Integer; ShopifyItemID: Text[30]; var ProductJObject: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        IStream: InStream;
        Line: Text;
        LongDescription: Text;
    begin
        if ShopifyItemID <> '' then
            ProductJObject.Add('id', ShopifyItemID);
        if SpfyIntegrationMgt.IsSendShopifyNameAndDescription() or (NcTaskType = NcTask.Type::Insert) then begin
            if SpfyStoreItemLink."Shopify Name" <> '' then
                ProductJObject.Add('title', SpfyStoreItemLink."Shopify Name")
            else
                if NcTaskType = NcTask.Type::Insert then
                    ProductJObject.Add('title', Item.Description);
            if SpfyStoreItemLink."Shopify Description".HasValue then begin
                SpfyStoreItemLink.CalcFields("Shopify Description");
                SpfyStoreItemLink."Shopify Description".CreateInStream(IStream);
                while not IStream.EOS do begin
                    IStream.ReadText(Line);
                    LongDescription += Line;
                end;
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

    local procedure GenerateVariantJObject2(ShopifyStoreCode: Code[20]; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject): Boolean
    var
        VarietyValueDic: Dictionary of [Integer, List of [Text]];
    begin
        exit(GenerateVariantJObject(ShopifyStoreCode, Item, ItemVariant, ProcessNewVariants, ShopifyVariantID, VariantJObject, VarietyValueDic));
    end;

    local procedure GenerateVariantJObject(ShopifyStoreCode: Code[20]; Item: Record Item; ItemVariant: Record "Item Variant"; ProcessNewVariants: Boolean; var ShopifyVariantID: Text[30]; var VariantJObject: JsonObject; var VarietyValueDic: Dictionary of [Integer, List of [Text]]): Boolean
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        Barcode: Text;
        ShopifyOptionNo: Integer;
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant."Code";
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;

        ShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(ItemVariant.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyVariantID = '' then
            ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
        if (ShopifyVariantID = '') and not ProcessNewVariants then
            exit(false);

        SpfyItemMgt.CheckVarieties(Item, ItemVariant);

        if ShopifyVariantID <> '' then
            VariantJObject.Add('id', ShopifyVariantID);
        VariantJObject.Add('sku', SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code));
        if SpfyIntegrationMgt.IsSendSalesPrices() then
            VariantJObject.Add('price', Item."Unit Price");
        VariantJObject.Add('inventory_management', 'shopify');
        Barcode := GetItemReference(ItemVariant);
        if Barcode <> '' then
            VariantJObject.Add('barcode', Barcode);

        case true of
            ItemVariant."NPR Variety 1 Value" + ItemVariant."NPR Variety 2 Value" + ItemVariant."NPR Variety 3 Value" + ItemVariant."NPR Variety 4 Value" <> '':
                begin
                    ShopifyOptionNo := 0;
                    if ItemVariant."NPR Variety 1 Value" <> '' then
                        AddVariety(1, ItemVariant."NPR Variety 1", ItemVariant."NPR Variety 1 Table", ItemVariant."NPR Variety 1 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
                    if ItemVariant."NPR Variety 2 Value" <> '' then
                        AddVariety(2, ItemVariant."NPR Variety 2", ItemVariant."NPR Variety 2 Table", ItemVariant."NPR Variety 2 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
                    if ItemVariant."NPR Variety 3 Value" <> '' then
                        AddVariety(3, ItemVariant."NPR Variety 3", ItemVariant."NPR Variety 3 Table", ItemVariant."NPR Variety 3 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
                    if ItemVariant."NPR Variety 4 Value" <> '' then
                        AddVariety(4, ItemVariant."NPR Variety 4", ItemVariant."NPR Variety 4 Table", ItemVariant."NPR Variety 4 Value", ShopifyOptionNo, VariantJObject, VarietyValueDic);
                end;
            ItemVariant.Description <> '':
                VariantJObject.Add('title', ItemVariant.Description);
            ItemVariant."Description 2" <> '':
                VariantJObject.Add('title', ItemVariant."Description 2");
            ItemVariant.Code <> '':
                VariantJObject.Add('title', ItemVariant.Code)
        end;

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

    local procedure GetStoreItemLink(ItemNo: Code[20]; ShopifyStoreCode: Code[20]; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    begin
        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
        SpfyStoreItemLink."Item No." := ItemNo;
        SpfyStoreItemLink."Variant Code" := '';
        SpfyStoreItemLink."Shopify Store Code" := ShopifyStoreCode;
        SpfyStoreItemLink.Find();
        if not (SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled") then
            SpfyStoreItemLink.TestField("Sync. to this Store");
    end;

    local procedure UpdateItemWithDataFromShopify(NcTask: Record "NPR Nc Task"; ShopifyResponse: JsonToken)
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        xSpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DataLogMgt: Codeunit "NPR Data Log Management";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        ShopifyVariant: JsonToken;
        ShopifyVariants: JsonArray;
        OStream: OutStream;
        ShopifyItemID: Text[30];
        ShopifyProductDetailedDescr: Text;
        ShopifyProductTitle: Text;
        VariantSku: Text;
        FirstVariant: Boolean;
        BCIsNameDescriptionMaster: Boolean;
    begin
#pragma warning disable AA0139
        ShopifyItemID := JsonHelper.GetJText(ShopifyResponse, 'product.id', MaxStrLen(ShopifyItemID), true);
#pragma warning restore AA0139
        ShopifyProductTitle := JsonHelper.GetJText(ShopifyResponse, 'product.title', MaxStrLen(SpfyStoreItemLink."Shopify Name"), false);
        ShopifyProductDetailedDescr := JsonHelper.GetJText(ShopifyResponse, 'product.body_html', false);
        ShopifyResponse.SelectToken('product.variants', ShopifyResponse);
        ShopifyVariants := ShopifyResponse.AsArray();
        BCIsNameDescriptionMaster := SpfyIntegrationMgt.IsSendShopifyNameAndDescription();

        FirstVariant := true;
        foreach ShopifyVariant in ShopifyVariants do begin
            SpfyItemMgt.ParseItem(ShopifyVariant, ItemVariant, VariantSku);
            if FirstVariant then begin
                SpfyStoreItemLink.Get(SpfyStoreItemLink.Type::Item, ItemVariant."Item No.", '', NcTask."Store Code");
                xSpfyStoreItemLink := SpfyStoreItemLink;
                if NcTask.Type = NcTask.Type::Delete then begin
                    SpfyStoreItemLink."Synchronization Is Enabled" := false;
                    SpfyStoreItemLink."Sync. to this Store" := false;
                end else
                    SpfyStoreItemLink."Synchronization Is Enabled" := SpfyStoreItemLink."Sync. to this Store";

                if ((ShopifyProductTitle <> '') or not BCIsNameDescriptionMaster) and (SpfyStoreItemLink."Shopify Name" <> ShopifyProductTitle) then
                    SpfyStoreItemLink."Shopify Name" := CopyStr(ShopifyProductTitle, 1, MaxStrLen(SpfyStoreItemLink."Shopify Name"));
                if (ShopifyProductDetailedDescr <> '') or not BCIsNameDescriptionMaster then begin
                    if SpfyStoreItemLink."Shopify Description".HasValue then
                        Clear(SpfyStoreItemLink."Shopify Description");
                    SpfyStoreItemLink."Shopify Description".CreateOutStream(OStream);
                    OStream.WriteText(ShopifyProductDetailedDescr);
                end;

                DataLogMgt.DisableDataLog(true);
                SpfyStoreItemLink.Modify();
                DataLogMgt.DisableDataLog(false);
                SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyItemID, false);
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
        ShopifyVariantID: Text[30];
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;

#pragma warning disable AA0139
        ShopifyVariantID := JsonHelper.GetJText(ShopifyVariant, 'id', MaxStrLen(ShopifyVariantID), true);
        ShopifyInventoryItemID := JsonHelper.GetJText(ShopifyVariant, 'inventory_item_id', MaxStrLen(ShopifyVariantID), true);
#pragma warning restore AA0139
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
    end;

    procedure SelectShopifyLocation(ShopifyStoreCode: Code[20]; var SelectedLocation: Text): Boolean
    var
        TempShopifyLocation: Record "NPR Spfy Location" temporary;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ReceivedShopifyLocations: JsonArray;
        ReceivedShopifyLocation: JsonToken;
        ShopifyResponse: JsonToken;
        Window: Dialog;
    begin
        Window.Open(QueryingShopifyLbl);
        ClearLastError();
        if not SpfyCommunicationHandler.GetShopifyLocations(ShopifyStoreCode, ShopifyResponse) then
            Error(GetLastErrorText());
        ShopifyResponse.AsObject().Get('locations', ShopifyResponse);
        ReceivedShopifyLocations := ShopifyResponse.AsArray();
        foreach ReceivedShopifyLocation in ReceivedShopifyLocations do begin
            TempShopifyLocation.Init();
#pragma warning disable AA0139
            TempShopifyLocation.ID := JsonHelper.GetJText(ReceivedShopifyLocation, 'id', MaxStrLen(TempShopifyLocation.ID), true);
            if not TempShopifyLocation.Find() then begin
                TempShopifyLocation.Name := JsonHelper.GetJText(ReceivedShopifyLocation, 'name', MaxStrLen(TempShopifyLocation.Name), false);
                TempShopifyLocation.Address := JsonHelper.GetJText(ReceivedShopifyLocation, 'address1', MaxStrLen(TempShopifyLocation.Address), false);
                TempShopifyLocation."Address 2" := JsonHelper.GetJText(ReceivedShopifyLocation, 'address2', MaxStrLen(TempShopifyLocation."Address 2"), false);
                TempShopifyLocation.City := JsonHelper.GetJText(ReceivedShopifyLocation, 'city', MaxStrLen(TempShopifyLocation.City), false);
                TempShopifyLocation."Post Code" := JsonHelper.GetJText(ReceivedShopifyLocation, 'zip', MaxStrLen(TempShopifyLocation."Post Code"), false);
                TempShopifyLocation."Country/Region Code" := JsonHelper.GetJText(ReceivedShopifyLocation, 'country_code', MaxStrLen(TempShopifyLocation."Country/Region Code"), false);
#pragma warning restore AA0139
                TempShopifyLocation.Active := JsonHelper.GetJBoolean(ReceivedShopifyLocation, 'active', false);
                TempShopifyLocation.Insert();
            end;
        end;
        Window.Close();
        if Page.RunModal(Page::"NPR Spfy Locations", TempShopifyLocation) = Action::LookupOK then begin
            SelectedLocation := TempShopifyLocation.ID;
            exit(true);
        end;
        exit(false);
    end;

    procedure GetShopifyItemID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyVariantIDs(SpfyStoreItemLink, WithDialog, GlobalShopifyItemID, GlobalShopifyVariantID, GlobalShopifyInventoryItemID) then
            exit(GlobalShopifyItemID);
        if WithDialog then
            Error(GetLastErrorText());
        exit('');
    end;

    procedure GetShopifyVariantID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyVariantIDs(SpfyStoreItemLink, WithDialog, GlobalShopifyItemID, GlobalShopifyVariantID, GlobalShopifyInventoryItemID) then
            exit(GlobalShopifyVariantID);
        if WithDialog then
            Error(GetLastErrorText());
        exit('');
    end;

    procedure GetShopifyInventoryItemID(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean): Text[30]
    begin
        if TryGetShopifyVariantIDs(SpfyStoreItemLink, WithDialog, GlobalShopifyItemID, GlobalShopifyVariantID, GlobalShopifyInventoryItemID) then
            exit(GlobalShopifyInventoryItemID);
        if WithDialog then
            Error(GetLastErrorText());
        exit('');
    end;

    local procedure TryGetShopifyVariantIDs(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; WithDialog: Boolean; var ShopifyItemID: Text[30]; var ShopifyVariantID: Text[30]; var ShopifyInventoryItemID: Text[30]): Boolean
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
    begin
        if (SpfyStoreItemLink."Item No." = LastQueriedSpfyStoreItemLink."Item No.") and
           (SpfyStoreItemLink."Variant Code" = LastQueriedSpfyStoreItemLink."Variant Code") and
           (SpfyStoreItemLink."Shopify Store Code" = LastQueriedSpfyStoreItemLink."Shopify Store Code")
        then
            exit(true);
        if WithDialog then
            Window.Open(QueryingShopifyLbl);
        RequestJson.Add('query',
            '{ productVariants(first: 1, query: "sku:' + SpfyItemMgt.GetProductVariantSku(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Variant Code") +
            '") { edges { node { id sku title product { id title } inventoryItem { id tracked inventoryLevels(first:10) { edges { node { id available location { id name }}}}}}}}}');

        TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        TempNcTask."Data Output".CreateOutStream(OStream);
        RequestJson.WriteTo(OStream);

        ClearLastError();
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, ShopifyResponse);
        if Success then begin
            ReceivedShopifyID :=
                JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''productVariants''].[''edges''][0].[''node''].[''product''].[''id'']', false);
            ShopifyItemID := CopyStr(RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyItemID));

            ReceivedShopifyID :=
                JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''productVariants''].[''edges''][0].[''node''].[''id'']', false);
            ShopifyVariantID := CopyStr(RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyVariantID));

            ReceivedShopifyID :=
                JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''productVariants''].[''edges''][0].[''node''].[''inventoryItem''].[''id'']', false);
            ShopifyInventoryItemID := CopyStr(RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyInventoryItemID));

            if (ShopifyItemID = '') and (SpfyStoreItemLink."Variant Code" = '') then begin
                SkuFilterString := GenerateItemVariantSKUsGraphQLFilter(SpfyStoreItemLink."Item No.");
                if SkuFilterString <> '' then begin
                    Clear(RequestJson);
                    RequestJson.Add('query', '{ products(first: 1, query: "' + SkuFilterString + '") { edges { node { id title }}}}');
                    Clear(TempNcTask);
                    TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
                    TempNcTask."Data Output".CreateOutStream(OStream);
                    RequestJson.WriteTo(OStream);

                    ClearLastError();
                    Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, ShopifyResponse);
                    if Success then begin
                        ReceivedShopifyID :=
                            JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''products''].[''edges''][0].[''node''].[''id'']', false);
                        ShopifyItemID := CopyStr(RemoveUntil(ReceivedShopifyID, '/'), 1, MaxStrLen(ShopifyItemID));
                    end;
                end;
            end;

            LastQueriedSpfyStoreItemLink := SpfyStoreItemLink;
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

    local procedure RemoveUntil(Input: Text; UntilChr: Char) Output: Text
    var
        Position: Integer;
    begin
        Position := LastIndexOf(Input, UntilChr);
        if Position <= 0 then
            exit(Input);

        Output := DelStr(Input, 1, Position);
        exit(Output);
    end;

    local procedure LastIndexOf(Input: Text; UntilChr: Char): Integer
    var
        Position: Integer;
    begin
        Position := StrPos(Input, UntilChr);
        if Position <= 0 then
            exit(0)
        else
            exit(Position + LastIndexOf(CopyStr(Input, Position + 1), UntilChr));
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

    procedure MarkItemAlreadyOnShopify(Item: Record Item; var ShopifyStore: Record "NPR Spfy Store"; DisableDataLog: Boolean; CreateAtShopify: Boolean)
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
                UpdateIntegrationStatusForItem(ShopifyStore.Code, Item, DisableDataLog, CreateAtShopify);
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

    local procedure UpdateIntegrationStatusForItem(ShopifyStoreCode: Code[20]; Item: Record Item; DisableDataLog: Boolean; CreateAtShopify: Boolean)
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        ShopifyInventoryItemID: Text[30];
        ShopifyItemID: Text[30];
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

        SpfyStoreItemVariantLink := SpfyStoreItemLink;
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;

        ShopifyItemID := GetShopifyItemID(SpfyStoreItemLink, false);

        if ShopifyItemID = '' then begin
            if LinkExists and (SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled") then begin
                SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
                ClearVariantsShopifyIDs(SpfyStoreItemLink);
                InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemLink);

                SpfyStoreItemLink."Sync. to this Store" := false;
                SpfyStoreItemLink."Synchronization Is Enabled" := false;
                if CreateAtShopify then begin
                    ModifySpfyStoreItemLink(SpfyStoreItemLink, true);
                    SpfyStoreItemLink."Sync. to this Store" := true;
                end;
                ModifySpfyStoreItemLink(SpfyStoreItemLink, DisableDataLog);
            end;
            exit;
        end;

        SpfyStoreLinkMgt.UpdateStoreItemLinks(Item);
        SpfyStoreItemLink.Find();
        //TODO: refactor for Shopify item integration with master/slave item approach
        //SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyItemID, false);
        ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
        ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemVariantLink, false);
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then
            repeat
                SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                ShopifyVariantID := GetShopifyVariantID(SpfyStoreItemVariantLink, false);
                SpfyAssignedIDMgt.AssignShopifyID(ItemVariant.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID, false);
                ShopifyInventoryItemID := GetShopifyInventoryItemID(SpfyStoreItemVariantLink, false);
                SpfyAssignedIDMgt.AssignShopifyID(ItemVariant.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemID, false);
            until ItemVariant.Next() = 0;

        SpfyStoreItemLink."Sync. to this Store" := true;
        SpfyStoreItemLink."Synchronization Is Enabled" := true;
        ModifySpfyStoreItemLink(SpfyStoreItemLink, DisableDataLog);
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

    local procedure ClearVariantsShopifyIDs(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyStoreItemVariantLink := SpfyStoreItemLink;
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;

        ItemVariant.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if ItemVariant.FindSet() then
            repeat
                SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
            until ItemVariant.Next() = 0;
    end;

    procedure EnableIntegrationForMagentoItems(ShopifyStoreCode: Code[20]; WithDialog: Boolean)
    begin
        //TODO
        Error('Not implemented yet.')
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    begin
        SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Send Items&Inventory(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy Send Items&Inventory");
    end;
}
#endif