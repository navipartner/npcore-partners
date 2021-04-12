codeunit 6151412 "NPR Magento Attr. Set Mgt."
{
    var
        Text00001: Label 'Attribute Set ID %1 and Attribute Group Name %2 already exist.';

    procedure EditItemAttributes(ItemNo: Code[20]; VariantCode: Code[10])
    var
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        Item: Record Item;
        MagentoItemAttributes: Page "NPR Magento Item Attr.";
    begin
        Item.Get(ItemNo);

        SetupItemAttributes(Item, VariantCode);
        Commit();
        Clear(MagentoItemAttribute);
        MagentoItemAttribute.FilterGroup(2);
        MagentoItemAttribute.SetRange("Item No.", Item."No.");
        MagentoItemAttribute.SetFilter("Variant Code", '=%1', VariantCode);
        MagentoItemAttribute.SetRange("Attribute Set ID", Item."NPR Attribute Set ID");
        MagentoItemAttribute.FilterGroup(0);
        Clear(MagentoItemAttributes);
        MagentoItemAttributes.SetTableView(MagentoItemAttribute);
        MagentoItemAttributes.RunModal();
    end;

    procedure SetupItemAttributes(var Item: Record Item; VariantCode: Code[10])
    var
        MagentoAttribute: Record "NPR Magento Attribute";
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        MagentoItemAttributeValue: Record "NPR Magento Item Attr. Value";
    begin
        Item.TestField("NPR Attribute Set ID");

        MagentoAttributeSetValue.SetRange("Attribute Set ID", Item."NPR Attribute Set ID");
        if MagentoAttributeSetValue.FindSet() then
            repeat
                MagentoAttribute.Get(MagentoAttributeSetValue."Attribute ID");
                if not MagentoItemAttribute.Get(MagentoAttributeSetValue."Attribute Set ID", MagentoAttributeSetValue."Attribute ID", Item."No.", VariantCode) then begin
                    MagentoItemAttribute.Init();
                    MagentoItemAttribute."Attribute Set ID" := Item."NPR Attribute Set ID";
                    MagentoItemAttribute."Attribute ID" := MagentoAttributeSetValue."Attribute ID";
                    MagentoItemAttribute."Item No." := Item."No.";
                    MagentoItemAttribute."Variant Code" := VariantCode;
                    MagentoItemAttribute.Insert(true);
                end;

                MagentoAttributeLabel.SetRange("Attribute ID", MagentoAttributeSetValue."Attribute ID");
                if MagentoAttributeLabel.FindSet() then
                    repeat
                        if not MagentoItemAttributeValue.Get(MagentoItemAttribute."Attribute ID", Item."No.", VariantCode, MagentoAttributeLabel."Line No.") then begin
                            MagentoItemAttributeValue.Init();
                            MagentoItemAttributeValue."Attribute ID" := MagentoItemAttribute."Attribute ID";
                            MagentoItemAttributeValue."Item No." := Item."No.";
                            MagentoItemAttributeValue."Variant Code" := VariantCode;
                            MagentoItemAttributeValue."Attribute Label Line No." := MagentoAttributeLabel."Line No.";
                            MagentoItemAttributeValue.Type := MagentoAttribute.Type;
                            MagentoItemAttributeValue."Attribute Set ID" := MagentoAttributeSetValue."Attribute Set ID";
                            MagentoItemAttributeValue.Picture := MagentoAttributeLabel.Image;
                            MagentoItemAttributeValue.Selected := false;
                            MagentoItemAttributeValue.Insert();
                        end else
                            if MagentoItemAttributeValue."Attribute Set ID" <> MagentoAttributeSetValue."Attribute Set ID" then begin
                                MagentoItemAttributeValue."Attribute Set ID" := MagentoAttributeSetValue."Attribute Set ID";
                                MagentoItemAttributeValue.Modify(true);
                            end;
                    until MagentoAttributeLabel.Next() = 0;
            until MagentoAttributeSetValue.Next() = 0;
    end;

    procedure HasProducts(RecRef: RecordRef): Boolean
    var
        Item: Record Item;
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        case RecRef.Number of
            DATABASE::"NPR Magento Attribute Set":
                begin
                    RecRef.SetTable(MagentoAttributeSet);
                    MagentoAttributeSet.Find();
                    Item.SetRange("NPR Attribute Set ID", MagentoAttributeSet."Attribute Set ID");
                    exit(Item.FindFirst());
                end;
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute Group", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnInsertCheckAttributeGroupDuplicate(var Rec: Record "NPR Magento Attribute Group"; RunTrigger: Boolean)
    var
        MagentoAttributeGroup: Record "NPR Magento Attribute Group";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Description = '' then
            exit;
        MagentoAttributeGroup.SetFilter(Description, '%1', Rec.Description);
        MagentoAttributeGroup.SetRange("Attribute Set ID", Rec."Attribute Set ID");
        if MagentoAttributeGroup.FindFirst() then
            Error(StrSubstNo(Text00001, Rec."Attribute Set ID", Rec.Description));
    end;
}