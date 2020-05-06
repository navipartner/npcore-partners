codeunit 6151448 "Magento NpXml Gen. Child Mgt."
{
    // MAG2.25/MHA /20200416  CASE 395915 Object created


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151551, 'OnSetupGenericChildTable', '', true, true)]
    local procedure SetupVariantTranslation(NpXmlElement: Record "NpXml Element";ParentRecRef: RecordRef;var ChildRecRef: RecordRef;var Handled: Boolean)
    var
        MagentoStoreItem: Record "Magento Store Item";
        ItemTranslation: Record "Item Translation";
        ItemVariant: Record "Item Variant";
        TempItemVariant: Record "Item Variant" temporary;
        MagentoStore: Record "Magento Store";
    begin
        if Handled then
          exit;

        if not IsElementSubscriber(NpXmlElement,'SetupVariantTranslation') then
          exit;
        Handled := true;
        Clear(ChildRecRef);
        case ParentRecRef.Number of
          DATABASE::"Magento Store Item":
            begin
              ParentRecRef.SetTable(MagentoStoreItem);
              ItemVariant.SetFilter(ItemVariant."Item No.",MagentoStoreItem."Item No.");
              if ItemVariant.FindSet then
                repeat
                  if not MagentoStore.Get(MagentoStoreItem."Store Code") then
                    exit;

                  TempItemVariant.Init;
                  TempItemVariant := ItemVariant;
                  if ItemTranslation.Get(ItemVariant."Item No.",ItemVariant.Code,MagentoStore."Language Code") then begin
                    TempItemVariant.Description := ItemTranslation.Description;
                    TempItemVariant."Description 2" := ItemTranslation."Description 2";
                  end;
                  TempItemVariant.Insert;
                until ItemVariant.Next = 0;
            end;
        end;
        ChildRecRef.GetTable(TempItemVariant);
    end;

    local procedure IsElementSubscriber(NpXmlElement: Record "NpXml Element";GenericTableFunction: Text): Boolean
    begin
        if NpXmlElement."Generic Child Codeunit ID" <> CurrCodeunitId() then
          exit(false);
        if NpXmlElement."Generic Child Function" <> GenericTableFunction then
          exit(false);

        exit(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Magento NpXml Gen. Child Mgt.");
    end;
}

