codeunit 6151415 "Magento Nc Task Card Mgt."
{

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151501, 'RunSourceCardEvent', '', true, true)]
    local procedure RunSourceCardEvent(var RecRef: RecordRef;var RunCardExecuted: Boolean)
    var
        PageMgt: Codeunit "Page Management";
        RecRefRelated: RecordRef;
    begin
        if RunCardExecuted then
          exit;

        if not GetRelatedRecRef(RecRef,RecRefRelated) then
          exit;

        RunCardExecuted := true;
        PageMgt.PageRun(RecRefRelated);
    end;

    local procedure GetRelatedRecRef(var RecRef: RecordRef;var RecRefRelated: RecordRef): Boolean
    var
        Item: Record Item;
        MagentoAttribute: Record "Magento Attribute";
        MagentoAttributeLabel: Record "Magento Attribute Label";
        MagentoAttributeSet: Record "Magento Attribute Set";
        MagentoAttributeSetValue: Record "Magento Attribute Set Value";
        MagentoCustomOption: Record "Magento Custom Option";
        MagentoCustomOptionValue: Record "Magento Custom Option Value";
        MagentoItemAttribute: Record "Magento Item Attribute";
        MagentoItemAttributeValue: Record "Magento Item Attribute Value";
        MagentoItemCustomOption: Record "Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "Magento Item Custom Opt. Value";
        MagentoItemGroup: Record "Magento Item Group";
        MagentoItemGroupLink: Record "Magento Item Group Link";
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoProductRelation: Record "Magento Product Relation";
        MagentoStoreItem: Record "Magento Store Item";
        MagentoStoreItemGroup: Record "Magento Store Item Group";
        MagentoWebsiteLink: Record "Magento Website Link";
    begin
        case RecRef.Number of
          DATABASE::"Magento Attribute Label":
            begin
              RecRef.SetTable(MagentoAttributeLabel);
              if not MagentoAttribute.Get(MagentoAttributeLabel."Attribute ID") then
                exit(false);
              RecRefRelated.GetTable(MagentoAttribute);
              exit(true);
            end;
          DATABASE::"Magento Attribute Set Value":
            begin
              RecRef.SetTable(MagentoAttributeSetValue);
              if not MagentoAttributeSet.Get(MagentoAttributeSetValue."Attribute Set ID") then
                exit(false);
              RecRefRelated.GetTable(MagentoAttributeSet);
              exit(true);
            end;
          DATABASE::"Magento Item Attribute" :
            begin
              RecRef.SetTable(MagentoItemAttribute);
              if not Item.Get(MagentoItemAttribute."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Item Attribute Value" :
            begin
              RecRef.SetTable(MagentoItemAttributeValue);
              if not Item.Get(MagentoItemAttributeValue."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Item Custom Opt. Value":
            begin
              RecRef.SetTable(MagentoItemCustomOptValue);
              if not Item.Get(MagentoItemCustomOptValue."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Item Custom Option":
            begin
              RecRef.SetTable(MagentoItemCustomOption);
              if not Item.Get(MagentoItemCustomOption."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Item Group Link":
            begin
              RecRef.SetTable(MagentoItemGroupLink);
              if not Item.Get(MagentoItemGroupLink."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Picture Link" :
            begin
              RecRef.SetTable(MagentoPictureLink);
              if not Item.Get(MagentoPictureLink."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Product Relation" :
            begin
              RecRef.SetTable(MagentoProductRelation);
              if not Item.Get(MagentoProductRelation."From Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Store Item":
            begin
              RecRef.SetTable(MagentoStoreItem);
              if not Item.Get(MagentoStoreItem."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Store Item Group":
            begin
              RecRef.SetTable(MagentoStoreItemGroup);
              if not MagentoItemGroup.Get(MagentoStoreItemGroup."No.") then
                exit(false);
              RecRefRelated.GetTable(MagentoItemGroup);
              exit(true);
            end;
          DATABASE::"Magento Website Link":
            begin
              RecRef.SetTable(MagentoWebsiteLink);
              if not Item.Get(MagentoWebsiteLink."Item No.") then
                exit(false);
              RecRefRelated.GetTable(Item);
              exit(true);
            end;
          DATABASE::"Magento Custom Option Value":
            begin
              RecRef.SetTable(MagentoCustomOptionValue);
              if not MagentoCustomOption.Get(MagentoCustomOptionValue) then
                exit(false);
              RecRefRelated.GetTable(MagentoCustomOption);
              exit(true);
            end;
        end;

        exit(false);
    end;
}

