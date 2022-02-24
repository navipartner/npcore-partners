page 6059850 "NPR POS Inventory Profiles"
{
    Extensible = False;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Inventory Profile";
    Caption = 'POS Inventory Profiles';
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the profile.';
                    ApplicationArea = NPRRetail;
                }
                field("Stockout Warning"; Rec."Stockout Warning")
                {
                    ToolTip = 'Specifies if a warning is displayed when you enter a quantity on a POS sale line that brings the item''s inventory level below zero.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Notes; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Links; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }
}
