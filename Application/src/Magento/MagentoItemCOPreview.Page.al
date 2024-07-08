page 6150803 "NPR Magento Item CO Preview"
{
    Caption = 'Items with Magento Custom Option';
    Extensible = false;
    Editable = false;
    PageType = List;
    SourceTable = "NPR Magento Item Custom Option";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    TableRelation = Item;
                    ToolTip = 'Specifies a number to identify the item. You can use ranges of item numbers to logically group products or to imply information about them. Or use simple numbers and item categories to group items.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a default text to describe the item on related documents such as orders or invoices. You can translate the descriptions so that they show up in the language of the customer or vendor.';
                }
            }
        }
    }
}