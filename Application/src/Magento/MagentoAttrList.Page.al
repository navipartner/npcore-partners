page 6151430 "NPR Magento Attr. List"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Attributes';
    CardPageID = "NPR Magento Attributes";
    Editable = false;
    PageType = List;
    UsageCategory = None;

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

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRMagento;
                }
                field(Filterable; Rec.Filterable)
                {

                    ToolTip = 'Specifies the value of the Filterable field';
                    ApplicationArea = NPRMagento;
                }
                field("Use in Product Listing"; Rec."Use in Product Listing")
                {

                    ToolTip = 'Specifies the value of the Use in Product Listing field';
                    ApplicationArea = NPRMagento;
                }
                field("Show Option Images Is Frontend"; Rec."Show Option Images Is Frontend")
                {

                    ToolTip = 'Specifies the value of the Show Option Images Is Frontend field';
                    ApplicationArea = NPRMagento;
                }
                field("Used by Items"; Rec."Used by Items")
                {

                    ToolTip = 'Specifies the value of the Used by Items field';
                    ApplicationArea = NPRMagento;
                }
                field("Used by Attribute Set"; Rec."Used by Attribute Set")
                {

                    ToolTip = 'Specifies the value of the Used by Attribute Set field';
                    ApplicationArea = NPRMagento;
                }
                field(Visible; Rec.Visible)
                {

                    ToolTip = 'Specifies the value of the Visible field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
