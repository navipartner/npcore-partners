codeunit 6151415 "NPR Magento Nc Task Card Mgt."
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", 'RunSourceCardEvent', '', true, true)]
    local procedure RunSourceCardEvent(var RecRef: RecordRef; var RunCardExecuted: Boolean)
    var
        PageMgt: Codeunit "Page Management";
        RecRefRelated: RecordRef;
    begin
        if RunCardExecuted then
            exit;

        if not GetRelatedRecRef(RecRef, RecRefRelated) then
            exit;

        RunCardExecuted := true;
        PageMgt.PageRun(RecRefRelated);
    end;

    local procedure GetRelatedRecRef(var RecRef: RecordRef; var RecRefRelated: RecordRef): Boolean
    var
        Item: Record Item;
        MagentoAttribute: Record "NPR Magento Attribute";
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        MagentoCustomOption: Record "NPR Magento Custom Option";
        MagentoCustomOptionValue: Record "NPR Magento Custom Optn. Value";
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        MagentoItemAttributeValue: Record "NPR Magento Item Attr. Value";
        MagentoItemCustomOption: Record "NPR Magento Item Custom Option";
        MagentoItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoProductRelation: Record "NPR Magento Product Relation";
        MagentoStoreItem: Record "NPR Magento Store Item";
        MagentoWebsiteLink: Record "NPR Magento Website Link";
    begin
        case RecRef.Number of
            DATABASE::"NPR Magento Attr. Label":
                begin
                    RecRef.SetTable(MagentoAttributeLabel);
                    if not MagentoAttribute.Get(MagentoAttributeLabel."Attribute ID") then
                        exit(false);
                    RecRefRelated.GetTable(MagentoAttribute);
                    exit(true);
                end;
            DATABASE::"NPR Magento Attr. Set Value":
                begin
                    RecRef.SetTable(MagentoAttributeSetValue);
                    if not MagentoAttributeSet.Get(MagentoAttributeSetValue."Attribute Set ID") then
                        exit(false);
                    RecRefRelated.GetTable(MagentoAttributeSet);
                    exit(true);
                end;
            DATABASE::"NPR Magento Item Attr.":
                begin
                    RecRef.SetTable(MagentoItemAttribute);
                    if not Item.Get(MagentoItemAttribute."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Item Attr. Value":
                begin
                    RecRef.SetTable(MagentoItemAttributeValue);
                    if not Item.Get(MagentoItemAttributeValue."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Itm Cstm Opt.Value":
                begin
                    RecRef.SetTable(MagentoItemCustomOptValue);
                    if not Item.Get(MagentoItemCustomOptValue."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Item Custom Option":
                begin
                    RecRef.SetTable(MagentoItemCustomOption);
                    if not Item.Get(MagentoItemCustomOption."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Picture Link":
                begin
                    RecRef.SetTable(MagentoPictureLink);
                    if not Item.Get(MagentoPictureLink."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Product Relation":
                begin
                    RecRef.SetTable(MagentoProductRelation);
                    if not Item.Get(MagentoProductRelation."From Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Store Item":
                begin
                    RecRef.SetTable(MagentoStoreItem);
                    if not Item.Get(MagentoStoreItem."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Website Link":
                begin
                    RecRef.SetTable(MagentoWebsiteLink);
                    if not Item.Get(MagentoWebsiteLink."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
            DATABASE::"NPR Magento Custom Optn. Value":
                begin
                    RecRef.SetTable(MagentoCustomOptionValue);
                    if not MagentoCustomOption.Get(MagentoCustomOptionValue) then
                        exit(false);
                    RecRefRelated.GetTable(MagentoCustomOption);
                    exit(true);
                end;
            DATABASE::"NPR Magento Category Link":
                begin
                    RecRef.SetTable(MagentoCategoryLink);
                    if not Item.Get(MagentoCategoryLink."Item No.") then
                        exit(false);
                    RecRefRelated.GetTable(Item);
                    exit(true);
                end;
        end;

        exit(false);
    end;
}
