page 6150743 "NPR POS Restaur. Profile Card"
{
    Extensible = False;
    Caption = 'POS Restaur. Profile';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS NPRE Rest. Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant code, which is selected by default on POS Restaurant View for POS units with this profile assigned.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Seating Location"; Rec."Default Seating Location")
                {
                    ToolTip = 'Specifies the seating location, which is selected by default on POS Restaurant View for POS units with this profile assigned.';
                    ApplicationArea = NPRRetail;
                }
                field("After End-of-Sale"; Rec."After End-of-Sale")
                {
                    ToolTip = 'Specifies whether the next open waiter pad should be loaded in POS after End of Sale.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
