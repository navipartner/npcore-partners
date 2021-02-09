page 6151430 "NPR Magento Attr. List"
{
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field(Filterable; Rec.Filterable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filterable field';
                }
                field("Use in Product Listing"; Rec."Use in Product Listing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use in Product Listing field';
                }
                field("Show Option Images Is Frontend"; Rec."Show Option Images Is Frontend")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Option Images Is Frontend field';
                }
                field("Used by Items"; Rec."Used by Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used by Items field';
                }
                field("Used by Attribute Set"; Rec."Used by Attribute Set")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used by Attribute Set field';
                }
                field(Visible; Rec.Visible)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Visible field';
                }
            }
        }
    }
}