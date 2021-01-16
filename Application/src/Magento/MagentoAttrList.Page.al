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
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field(Filterable; Filterable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filterable field';
                }
                field("Use in Product Listing"; "Use in Product Listing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use in Product Listing field';
                }
                field("Show Option Images Is Frontend"; "Show Option Images Is Frontend")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Option Images Is Frontend field';
                }
                field("Used by Items"; "Used by Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used by Items field';
                }
                field("Used by Attribute Set"; "Used by Attribute Set")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used by Attribute Set field';
                }
                field(Visible; Visible)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Visible field';
                }
            }
        }
    }

    actions
    {
    }
}

