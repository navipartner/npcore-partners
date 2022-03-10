﻿page 6151431 "NPR Magento Attributes"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Attributes';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Magento Attribute";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            grid(Attributes)
            {
                Caption = 'Attributes';
                group(Control6150627)
                {
                    ShowCaption = false;
                    repeater(Control6150613)
                    {
                        ShowCaption = false;
                        field(Description; Rec.Description)
                        {

                            ToolTip = 'Specifies the value of the Description field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Type; Rec.Type)
                        {

                            Editable = TypeEditable;
                            ToolTip = 'Specifies the value of the Type field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Position; Rec.Position)
                        {

                            ToolTip = 'Specifies the value of the Position field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Filterable; Rec.Filterable)
                        {

                            ToolTip = 'Specifies the value of the Filterable field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Use in Product Listing"; Rec."Use in Product Listing")
                        {

                            ToolTip = 'Specifies the value of the Use in Product Listing field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Used by Attribute Set"; Rec."Used by Attribute Set")
                        {

                            ToolTip = 'Specifies the value of the Used by Attribute Set field';
                            ApplicationArea = NPRRetail;

                            trigger OnDrillDown()
                            begin
                                UsedByAttributeSetDrillDown();
                            end;
                        }
                        field("Used by Items"; Rec."Used by Items")
                        {

                            ToolTip = 'Specifies the value of the Used by Items field';
                            ApplicationArea = NPRRetail;

                            trigger OnDrillDown()
                            begin
                                UsedByItemDrillDown();
                            end;
                        }
                        field(Visible; Rec.Visible)
                        {

                            ToolTip = 'Specifies the value of the Visible field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field(WidthControl; '')
                    {

                        Caption = '                                                                                                                                                             ';
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6150623)
                {
                    ShowCaption = false;
                    part(AttributeLabels; "NPR Magento Attr. Labels")
                    {
                        Caption = 'Labels';
                        ShowFilter = false;
                        SubPageLink = "Attribute ID" = FIELD("Attribute ID");
                        ApplicationArea = NPRRetail;

                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MagentoAttribute: Record "NPR Magento Attribute";
    begin
        TypeEditable := not MagentoAttribute.Get(Rec."Attribute ID");
        CurrPage.AttributeLabels.PAGE.SetTextFieldVisible(Rec.Type = Rec.Type::"Text Area (single)");
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField(Description);
        if not Confirm(StrSubstNo(Text001, Format(Rec.Type)), false) then
            exit(false);
    end;

    trigger OnOpenPage()
    begin
        MagentoSetup.Get();
        MagentoSetup.TestField("Attributes Enabled", true);
        SetVisible();
    end;

    var
        MagentoSetup: Record "NPR Magento Setup";
        Text001: Label 'The Type is: %1\\Type can not be changed after Creation\\Create Attribute?';
        TypeEditable: Boolean;

    internal procedure UsedByAttributeSetDrillDown()
    var
        AttributeSet: Record "NPR Magento Attribute Set";
        MagentoAttributeSetValue: Record "NPR Magento Attr. Set Value";
        TempAttributeSet: Record "NPR Magento Attribute Set" temporary;
    begin
        TempAttributeSet.DeleteAll();
        MagentoAttributeSetValue.SetRange("Attribute ID", Rec."Attribute ID");
        if MagentoAttributeSetValue.FindSet() then
            repeat
                if AttributeSet.Get(MagentoAttributeSetValue."Attribute Set ID") then begin
                    TempAttributeSet.Init();
                    TempAttributeSet := AttributeSet;
                    TempAttributeSet.Insert();
                end;
            until MagentoAttributeSetValue.Next() = 0;
        PAGE.Run(PAGE::"NPR Magento Attribute Set List", TempAttributeSet);
    end;

    internal procedure UsedByItemDrillDown()
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        MagentoItemAttribute: Record "NPR Magento Item Attr.";
    begin
        TempItem.DeleteAll();
        MagentoItemAttribute.SetRange("Attribute ID", Rec."Attribute ID");
        MagentoItemAttribute.SetFilter("Variant Code", '=%1', '');
        if MagentoItemAttribute.FindSet() then
            repeat
                if not TempItem.Get(MagentoItemAttribute."Item No.") then begin
                    if Item.Get(MagentoItemAttribute."Item No.") then begin
                        TempItem.Init();
                        TempItem := Item;
                        TempItem.Insert();
                    end;
                end;
            until MagentoItemAttribute.Next() = 0;
        PAGE.Run(PAGE::"Item List", TempItem);
    end;

    internal procedure SetVisible()
    begin
    end;
}
