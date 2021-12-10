page 6151437 "NPR Magento Item Attr. Values"
{
    Caption = 'Item Attribute Values';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR Magento Item Attr. Value";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Selected; Rec.Selected)
                {

                    ToolTip = 'Specifies the value of the Selected field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        MagentoAttribute: Record "NPR Magento Attribute";
                    begin
                        MagentoAttribute.Get(Rec."Attribute ID");
                        if Rec.Selected then begin
                            if MagentoAttribute.Type in [MagentoAttribute.Type::Single, MagentoAttribute.Type::"Text Area (single)"] then begin
                                Rec.ModifyAll(Selected, false);
                                CurrPage.Update(false);
                                DeleteItemAttrValues();
                                Rec.Find();
                                Rec.Selected := true;
                                Rec.Modify(true);
                            end;
                        end;
                        CurrPage.Update();
                    end;
                }
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        OnModifyTrigger();
    end;

    local procedure OnModifyTrigger()
    var
        MagentoItemAttrValue: Record "NPR Magento Item Attr. Value";
    begin
        if not Rec.Selected then begin
            if MagentoItemAttrValue.Get(Rec."Attribute ID", Rec."Item No.", Rec."Variant Code", Rec."Attribute Label Line No.") then
                MagentoItemAttrValue.Delete(true);
            exit;
        end;

        if MagentoItemAttrValue.Get(Rec."Attribute ID", Rec."Item No.", Rec."Variant Code", Rec."Attribute Label Line No.") then begin
            MagentoItemAttrValue.TransferFields(Rec);
            MagentoItemAttrValue.Modify(true);
            exit;
        end;

        MagentoItemAttrValue.Init();
        MagentoItemAttrValue := Rec;
        MagentoItemAttrValue.Insert(true);
    end;

    local procedure DeleteItemAttrValues()
    var
        MagentoItemAttrValue: Record "NPR Magento Item Attr. Value";
    begin
        MagentoItemAttrValue.SetCurrentKey("Attribute ID", "Item No.", "Variant Code");
        MagentoItemAttrValue.SetRange("Attribute ID", rec."Attribute ID");
        MagentoItemAttrValue.SetRange("Item No.", Rec."Item No.");
        MagentoItemAttrValue.SetRange("Variant Code", Rec."Variant Code");
        MagentoItemAttrValue.DeleteAll();
    end;

    procedure SetSourceTable(AttributeSetId: Integer; AttributeId: Integer; ItemNo: Code[20]; VariantCode: Code[10])
    var
        MagentoItemAttr: Record "NPR Magento Item Attr.";
        MagentoAttribute: Record "NPR Magento Attribute";
        MagentoAttrLabel: Record "NPR Magento Attr. Label";
        MagentoItemAttrValue: Record "NPR Magento Item Attr. Value";
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if not MagentoItemAttr.Get(AttributeSetId, AttributeId, ItemNo, VariantCode) then begin
            CurrPage.Update(false);
            exit;
        end;

        if MagentoAttribute.Get(AttributeId) then begin
            MagentoAttrLabel.SetRange("Attribute ID", AttributeId);
            if MagentoAttrLabel.FindSet() then
                repeat
                    Rec.Init();
                    if MagentoItemAttrValue.Get(AttributeId, ItemNo, VariantCode, MagentoAttrLabel."Line No.") then
                        Rec := MagentoItemAttrValue
                    else begin
                        Rec.Init();
                        Rec."Attribute ID" := AttributeId;
                        Rec."Item No." := ItemNo;
                        Rec."Variant Code" := VariantCode;
                        Rec."Attribute Label Line No." := MagentoAttrLabel."Line No.";
                        Rec.Type := MagentoAttribute.Type;
                        Rec."Attribute Set ID" := AttributeSetId;
                        Rec.Picture := MagentoAttrLabel.Image;
                        Rec.Selected := false;
                    end;
                    Rec.Insert();
                until MagentoAttrLabel.Next() = 0;
        end;

        CurrPage.Update(false);
    end;
}