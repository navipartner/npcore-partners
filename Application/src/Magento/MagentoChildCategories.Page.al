﻿page 6151417 "NPR Magento Child Categories"
{
    Extensible = False;
    Caption = 'Magento Child Categories';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Category";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Id; Rec.Id)
                {

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRMagento;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRMagento;
                }
                field(Picture; Rec.Picture)
                {

                    ToolTip = 'Specifies the value of the Picture field';
                    ApplicationArea = NPRMagento;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRMagento;
                }
                field("Item Count"; Rec."Item Count")
                {

                    ToolTip = 'Specifies the value of the Item Count field';
                    ApplicationArea = NPRMagento;

                    trigger OnDrillDown()
                    begin
                        MagentoCategoryMgt.ItemCountDrillDown(Rec);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Id := ParentMagentoCategory.GetNewChildGroupNo();
        Rec."Parent Category Id" := ParentMagentoCategory.Id;
        Rec.Level := ParentMagentoCategory.Level + 1;
    end;

    var
        ParentMagentoCategory: Record "NPR Magento Category";
        MagentoCategoryMgt: Codeunit "NPR Magento Category Mgt.";

    internal procedure SetParentItemGroup(NewParentMagentoCategory: Record "NPR Magento Category")
    begin
        ParentMagentoCategory := NewParentMagentoCategory;
    end;
}
