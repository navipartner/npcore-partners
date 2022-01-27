page 6151430 "NPR Magento Attr. List"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Attributes';
    CardPageID = "NPR Magento Attributes";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Attribute";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
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
                field("Show Option Images Is Frontend"; Rec."Show Option Images Is Frontend")
                {

                    ToolTip = 'Specifies the value of the Show Option Images Is Frontend field';
                    ApplicationArea = NPRRetail;
                }
                field("Used by Items"; Rec."Used by Items")
                {

                    ToolTip = 'Specifies the value of the Used by Items field';
                    ApplicationArea = NPRRetail;
                }
                field("Used by Attribute Set"; Rec."Used by Attribute Set")
                {

                    ToolTip = 'Specifies the value of the Used by Attribute Set field';
                    ApplicationArea = NPRRetail;
                }
                field(Visible; Rec.Visible)
                {

                    ToolTip = 'Specifies the value of the Visible field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
