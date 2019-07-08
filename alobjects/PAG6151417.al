page 6151417 "Magento Item Group Subform"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH/20150217  CASE 199932 Added function SetParentItemGroup() which is used when for defining parent on Insert
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.09/TS  /20180108  CASE 300893 Removed Caption on Control Container

    Caption = 'Magento Item Group Subform';
    DelayedInsert = true;
    PageType = CardPart;
    SourceTable = "Magento Item Group";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field(Picture;Picture)
                {
                }
                field(Sorting;Sorting)
                {
                }
                field("Item Count";"Item Count")
                {

                    trigger OnDrillDown()
                    begin
                        MagentoItemGroupMgt.ItemCountDrillDown("No.");
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
        "No." := ParentItemGroup.GetNewChildGroupNo();
        "Parent Item Group No." := ParentItemGroup."No.";
        Level := ParentItemGroup.Level + 1;
    end;

    var
        MagentoItemGroupMgt: Codeunit "Magento Item Group Mgt.";
        ParentItemGroup: Record "Magento Item Group";

    procedure SetParentItemGroup(NewParentItemGroup: Record "Magento Item Group")
    begin
        ParentItemGroup := NewParentItemGroup;
    end;
}

