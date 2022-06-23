page 6059887 "NPR Main Item Variations"
{
    Extensible = false;
    Caption = 'Main Item Variations';
    PageType = List;
    SourceTable = "NPR Main Item Variation";
    UsageCategory = None;
    DataCaptionFields = "Main Item No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Main Item No."; Rec."Main Item No.")
                {
                    ToolTip = 'Specifies the number of the main item. This is the item for which variations can be set up.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the related item (variation).';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description linked to the item for the item number you entered in Item No. field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            systempart(NotesFactBox; Notes)
            {
                ApplicationArea = NPRRetail;
                Visible = false;
            }
        }
    }
}