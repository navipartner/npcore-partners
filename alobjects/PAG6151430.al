page 6151430 "Magento Attribute List"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.19/LS  /2019020  CASE 344251 Added field Visible

    AutoSplitKey = true;
    Caption = 'Attributes';
    CardPageID = "Magento Attributes";
    Editable = false;
    PageType = List;
    SourceTable = "Magento Attribute";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Description;Description)
                {
                }
                field(Position;Position)
                {
                }
                field(Filterable;Filterable)
                {
                }
                field("Use in Product Listing";"Use in Product Listing")
                {
                }
                field("Show Option Images Is Frontend";"Show Option Images Is Frontend")
                {
                }
                field("Used by Items";"Used by Items")
                {
                }
                field("Used by Attribute Set";"Used by Attribute Set")
                {
                }
                field(Visible;Visible)
                {
                }
            }
        }
    }

    actions
    {
    }
}

