codeunit 6151448 "NPR Magento NpXml Gen.ChildMgt"
{
    Access = Internal;
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
                            if ItemTranslation.Get(ItemVariant."Item No.", ItemVariant.Code, MagentoStore."Language Code") then begin
                                TempItemVariant.Description := ItemTranslation.Description;
                                TempItemVariant."Description 2" := ItemTranslation."Description 2";
                            end;
                            TempItemVariant.Insert();
                        until ItemVariant.Next() = 0;
                end;
        end;
        ChildRecRef.GetTable(TempItemVariant);
    end;

    local procedure IsElementSubscriber(NpXmlElement: Record "NPR NpXml Element"; GenericTableFunction: Text): Boolean
    begin
        if NpXmlElement."Generic Child Codeunit ID" <> CurrCodeunitId() then
            exit(false);
        if NpXmlElement."Generic Child Function" <> GenericTableFunction then
            exit(false);

        exit(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento NpXml Gen.ChildMgt");
    end;
}
