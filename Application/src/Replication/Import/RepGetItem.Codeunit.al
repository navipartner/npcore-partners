codeunit 6014623 "NPR Rep. Get Item" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetItems_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetItems(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetItems(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        Item: Record Item;
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        ItemNo: Code[20];
        ItemId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        ItemNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.number'), 1, MaxStrLen(ItemNo));
        ItemId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF ItemId <> '' then
            IF Item.GetBySystemId(ItemId) then begin
                RecFoundBySystemId := true;
                If Item."No." <> ItemNo then // rename!
                    if NOT Item.Rename(ItemNo) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT Item.Get(ItemNo) then
                InsertNewRec(Item, ItemNo, ItemId);

        IF CheckFieldsChanged(Item, JToken) then
            Item.Modify(true);
    end;

    local procedure CheckFieldsChanged(var Item: Record Item; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(Item, Item.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("Description 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("Item Category Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemCategoryCode'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo(Type), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.type'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Allow Invoice Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowInvoiceDisc'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Price/Profit Calculation"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceProfitCalculation'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Vendor No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vendorNo'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Vendor item No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vendorItemNo'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo(Blocked), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blocked'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo(GTIN), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.gtin'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Unit Price"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitPrice'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Unit List Price"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitListPrice'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Price Includes VAT"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceIncludesTax'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Tax Group Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.taxGroupCode'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Tariff No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.tariffNo'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Base Unit of Measure"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.baseUnitOfMeasureCode'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Sales Unit of Measure"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.salesUnitofMeasure'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Purch. Unit of Measure"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.purchUnitofMeasure'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Costing Method"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.costingMethod'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo(Reserve), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.reserve'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Manufacturer Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.manufacturerCode'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Shelf No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.shelfNo'), false) then
            FieldsChanged := true;

        IF Item."Costing Method" = Item."Costing Method"::Specific Then
            If CheckFieldValue(Item, Item.FieldNo("Unit Cost"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitCost'), false) then
                FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Standard Cost"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.standardCost'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Last Direct Cost"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lastDirectCost'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Gen. Prod. Posting Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.genProdPostingGroup'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("VAT Prod. Posting Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatProdPostingGroup'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("VAT Bus. Posting Gr. (Price)"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatBusPostingGrPrice'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Inventory Posting Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.inventoryPostingGroup'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Global Dimension 1 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension1Code'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Global Dimension 2 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension2Code'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Default Deferral Template Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.defaultDeferralTemplate'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("Item Disc. Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemDiscGroup'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Group sale"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprGroupSale'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Explode BOM auto"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprExplodeBomAuto'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Guarantee voucher"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprGuaranteeVoucher'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Item Brand"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprItemBrand'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Ticket Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprTicketType'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Item AddOn No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprItemAddOnNo'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Magento Item"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoItem'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Magento Status"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoStatus'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Attribute Set ID"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprAttributeSetID'), false) then
            FieldsChanged := true;

        // TO DO: handle BLOB NPR Magento Description + Magento Short Description

        If CheckFieldValue(Item, Item.FieldNo("NPR Magento Name"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoName'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Magento Brand"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoBrand'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Seo Link"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprSeoLink'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Meta Title"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMetaTitle'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Meta Description"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMetaDescription'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Product New From"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprProductNewFrom'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Product New To"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprProductNewTo'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Special Price"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprSpecialPrice'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Special Price From"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprSpecialPricenprFrom'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Special Price To"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprSpecialPriceTo'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Featured From"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprFeaturedFrom'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Featured To"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprFeaturedTo'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Backorder"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprBackorder'), false) then
            FieldsChanged := true;

        If CheckFieldValue(Item, Item.FieldNo("NPR Display Only"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprDisplayOnly'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVarietyGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 1"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety1'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 1 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety1Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 2 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety2Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 3"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety3'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 3 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety3Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 4"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety4'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Item, Item.FieldNo("NPR Variety 4 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprVariety4Table'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var Item: Record Item; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(Item, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(Item);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var Item: Record Item; ItemNo: Code[20]; ItemId: text)
    begin
        Item.Init();
        Item."No." := ItemNo;
        IF ItemId <> '' THEN begin
            IF Evaluate(Item.SystemId, ItemId) Then
                Item.Insert(false, true)
            Else
                Item.Insert(false);
        end else
            Item.Insert(false);
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