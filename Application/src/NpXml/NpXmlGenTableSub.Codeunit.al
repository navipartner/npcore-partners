codeunit 6151561 "NPR NpXml Gen. Table Sub."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Mgt.", 'OnSetupGenericChildTable', '', true, true)]
    local procedure SetupStockkeepingUnit(NpXmlElement: Record "NPR NpXml Element"; ParentRecRef: RecordRef; var ChildRecRef: RecordRef; var Handled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        StockkeepingUnit: Record "Stockkeeping Unit";
        TempStockkeepingUnit: Record "Stockkeeping Unit" temporary;
    begin
        if Handled then
            exit;
        if not IsElementSubscriber(NpXmlElement, 'SetupStockkeepingUnit') then
            exit;

        Handled := true;

        Clear(ChildRecRef);
        case ParentRecRef.Number of
            DATABASE::Item:
                begin
                    ParentRecRef.SetTable(Item);
                    if Location.FindSet() then
                        repeat
                            if StockkeepingUnit.Get(Location.Code, Item."No.", '') then begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit := StockkeepingUnit;
                                TempStockkeepingUnit.Insert();
                            end else begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit."Location Code" := Location.Code;
                                TempStockkeepingUnit."Item No." := Item."No.";
                                TempStockkeepingUnit."Variant Code" := '';
                                TempStockkeepingUnit.Insert();
                            end;
                        until Location.Next() = 0;
                end;
            DATABASE::"Item Variant":
                begin
                    ParentRecRef.SetTable(ItemVariant);
                    if Location.FindSet() then
                        repeat
                            if StockkeepingUnit.Get(Location.Code, ItemVariant."Item No.", ItemVariant.Code) then begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit := StockkeepingUnit;
                                TempStockkeepingUnit.Insert();
                            end else begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit."Location Code" := Location.Code;
                                TempStockkeepingUnit."Item No." := Item."No.";
                                TempStockkeepingUnit."Variant Code" := ItemVariant.Code;
                                TempStockkeepingUnit.Insert();
                            end;
                        until Location.Next() = 0;
                end;
        end;

        ChildRecRef.GetTable(TempStockkeepingUnit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Mgt.", 'OnSetupGenericChildTable', '', true, true)]
    local procedure SetupVariantTranslation(NpXmlElement: Record "NPR NpXml Element"; ParentRecRef: RecordRef; var ChildRecRef: RecordRef; var Handled: Boolean)
    var
        MagentoStoreItem: Record "NPR Magento Store Item";
        ItemTranslation: Record "Item Translation";
        ItemVariant: Record "Item Variant";
        TempItemVariant: Record "Item Variant" temporary;
        MagentoStore: Record "NPR Magento Store";
    begin
        if Handled then
            exit;

        if not IsElementSubscriber(NpXmlElement, 'SetupVariantTranslation') then
            exit;
        Handled := true;
        Clear(ChildRecRef);
        case ParentRecRef.Number of
            DATABASE::"NPR Magento Store Item":
                begin
                    ParentRecRef.SetTable(MagentoStoreItem);
                    ItemVariant.SetFilter(ItemVariant."Item No.", MagentoStoreItem."Item No.");
                    if ItemVariant.FindSet() then
                        repeat
                            if not MagentoStore.Get(MagentoStoreItem."Store Code") then
                                exit;

                            TempItemVariant.Init();
                            TempItemVariant := ItemVariant;
                            if ItemTranslation.Get(ItemVariant."Item No.", ItemVariant.Code, MagentoStore."Language Code") then
                                TempItemVariant.Description := ItemTranslation.Description;
                            TempItemVariant.Insert();
                        until ItemVariant.Next() = 0;
                end;
        end;
        ChildRecRef.GetTable(TempItemVariant);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Trigger Mgt.", 'OnSetupGenericParentTable', '', true, true)]
    local procedure SetupLinkStockkeepingUnit(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; ChildLinkRecRef: RecordRef; var ParentRecRef: RecordRef; var Handled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        StockkeepingUnit: Record "Stockkeeping Unit";
        TempStockkeepingUnit: Record "Stockkeeping Unit" temporary;
    begin
        if Handled then
            exit;
        if not IsLinkSubscriber(NpXmlTemplateTrigger, 'SetupLinkStockkeepingUnit') then
            exit;

        Handled := true;

        Clear(ParentRecRef);
        case ChildLinkRecRef.Number of
            DATABASE::Item:
                begin
                    ChildLinkRecRef.SetTable(Item);
                    if Location.FindSet() then
                        repeat
                            if StockkeepingUnit.Get(Location.Code, Item."No.", '') then begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit := StockkeepingUnit;
                                TempStockkeepingUnit.Insert();
                            end else begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit."Location Code" := Location.Code;
                                TempStockkeepingUnit."Item No." := Item."No.";
                                TempStockkeepingUnit."Variant Code" := '';
                                TempStockkeepingUnit.Insert();
                            end;
                        until Location.Next() = 0;
                end;
            DATABASE::"Item Variant":
                begin
                    ChildLinkRecRef.SetTable(ItemVariant);
                    if Location.FindSet() then
                        repeat
                            if StockkeepingUnit.Get(Location.Code, ItemVariant."Item No.", ItemVariant.Code) then begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit := StockkeepingUnit;
                                TempStockkeepingUnit.Insert();
                            end else begin
                                TempStockkeepingUnit.Init();
                                TempStockkeepingUnit."Location Code" := Location.Code;
                                TempStockkeepingUnit."Item No." := Item."No.";
                                TempStockkeepingUnit."Variant Code" := ItemVariant.Code;
                                TempStockkeepingUnit.Insert();
                            end;
                        until Location.Next() = 0;
                end;
        end;

        ParentRecRef.GetTable(TempStockkeepingUnit);
    end;

    local procedure IsElementSubscriber(NpXmlElement: Record "NPR NpXml Element"; GenericTableFunction: Text): Boolean
    begin
        if NpXmlElement."Generic Child Codeunit ID" <> CurrCodeunitId() then
            exit(false);
        if NpXmlElement."Generic Child Function" <> GenericTableFunction then
            exit(false);

        exit(true);
    end;

    local procedure IsLinkSubscriber(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger"; GenericTableFunction: Text): Boolean
    begin
        if NpXmlTemplateTrigger."Generic Parent Codeunit ID" <> CurrCodeunitId() then
            exit(false);
        if NpXmlTemplateTrigger."Generic Parent Function" <> GenericTableFunction then
            exit(false);

        exit(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpXml Gen. Table Sub.");
    end;
}

