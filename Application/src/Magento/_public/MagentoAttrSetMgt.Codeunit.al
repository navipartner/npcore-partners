﻿codeunit 6151412 "NPR Magento Attr. Set Mgt."
{
    var
        Text00001: Label 'Attribute Set ID %1 and Attribute Group Name %2 already exist.';

    internal procedure EditItemAttributes(ItemNo: Code[20]; VariantCode: Code[10])
    var
        Item: Record Item;
        AuxItem: Record "NPR Aux Item";
        MagentoItemAttributes: Page "NPR Magento Item Attr.";
    begin
        Item.Get(ItemNo);
        Item.NPR_GetAuxItem(AuxItem);
        Commit();
        MagentoItemAttributes.SetValues(Item."No.", AuxItem."Attribute Set ID", VariantCode);
        MagentoItemAttributes.RunModal();
    end;

    procedure SetupItemAttributes(var Item: Record Item; VariantCode: Code[10])
    var
        AuxItem: Record "NPR Aux Item";
        MagentoAttribute: Record "NPR Magento Attribute";
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
        MagentoItemAttributeValue: Record "NPR Magento Item Attr. Value";
    begin
        Item.NPR_GetAuxItem(AuxItem);
        AuxItem.TestField("Attribute Set ID");

        MagentoAttributeSetValue.SetRange("Attribute Set ID", AuxItem."Attribute Set ID");
        if MagentoAttributeSetValue.FindSet() then
            repeat
                MagentoAttribute.Get(MagentoAttributeSetValue."Attribute ID");
                if not MagentoItemAttribute.Get(MagentoAttributeSetValue."Attribute Set ID", MagentoAttributeSetValue."Attribute ID", Item."No.", VariantCode) then begin
                    MagentoItemAttribute.Init();
                    MagentoItemAttribute."Attribute Set ID" := AuxItem."Attribute Set ID";
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

    internal procedure HasProducts(RecRef: RecordRef): Boolean
    var
        AuxItem: Record "NPR Aux Item";
        MagentoAttributeSet: Record "NPR Magento Attribute Set";
    begin
        case RecRef.Number of
            DATABASE::"NPR Magento Attribute Set":
                begin
                    RecRef.SetTable(MagentoAttributeSet);
                    MagentoAttributeSet.Find();
                    AuxItem.SetRange("Attribute Set ID", MagentoAttributeSet."Attribute Set ID");
                    exit(not AuxItem.IsEmpty());
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
            Error(Text00001, Rec."Attribute Set ID", Rec.Description);
    end;
}
