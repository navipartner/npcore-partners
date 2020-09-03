page 6151430 "NPR Magento Attr. List"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.19/LS  /2019020  CASE 344251 Added field Visible

    AutoSplitKey = true;
    Caption = 'Attributes';
    CardPageID = "NPR Magento Attributes";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Magento Attribute";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                }
                field(Filterable; Filterable)
                {
                    ApplicationArea = All;
                }
                field("Use in Product Listing"; "Use in Product Listing")
                {
                    ApplicationArea = All;
                }
                field("Show Option Images Is Frontend"; "Show Option Images Is Frontend")
                {
                    ApplicationArea = All;
                }
                field("Used by Items"; "Used by Items")
                {
                    ApplicationArea = All;
                }
                field("Used by Attribute Set"; "Used by Attribute Set")
                {
                    ApplicationArea = All;
                }
                field(Visible; Visible)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

