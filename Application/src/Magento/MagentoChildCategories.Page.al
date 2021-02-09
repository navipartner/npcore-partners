page 6151417 "NPR Magento Child Categories"
{
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Sorting"; Rec.Sorting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sorting field';
                }
                field("Item Count"; Rec."Item Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Count field';

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
        MagentoCategoryMgt: Codeunit "NPR Magento Category Mgt.";
        ParentMagentoCategory: Record "NPR Magento Category";

    procedure SetParentItemGroup(NewParentMagentoCategory: Record "NPR Magento Category")
    begin
        ParentMagentoCategory := NewParentMagentoCategory;
    end;
}