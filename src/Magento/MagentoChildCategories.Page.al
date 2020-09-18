page 6151417 "NPR Magento Child Categories"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH/20150217  CASE 199932 Added function SetParentCategory() which is used when for defining parent on Insert
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.09/TS  /20180108  CASE 300893 Removed Caption on Control Container
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Magento Child Categories';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Category";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                }
                field("Sorting"; Sorting)
                {
                    ApplicationArea = All;
                }
                field("Item Count"; "Item Count")
                {
                    ApplicationArea = All;

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
        Id := ParentMagentoCategory.GetNewChildGroupNo();
        "Parent Category Id" := ParentMagentoCategory.Id;
        Level := ParentMagentoCategory.Level + 1;
    end;

    var
        MagentoCategoryMgt: Codeunit "NPR Magento Category Mgt.";
        ParentMagentoCategory: Record "NPR Magento Category";

    procedure SetParentItemGroup(NewParentMagentoCategory: Record "NPR Magento Category")
    begin
        ParentMagentoCategory := NewParentMagentoCategory;
    end;
}

