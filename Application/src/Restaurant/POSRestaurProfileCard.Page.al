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
            group(SelfService)
            {
                Caption = 'Self-Service';
                field("Dine-in VAT Bus. Post. Group"; Rec."Dine-in VAT Bus. Post. Group")
                {
                    ToolTip = 'Specifies the VAT business posting group the self-service apps use for dine-in orders. Leave blank if dine-in is not offered.';
                    ApplicationArea = NPRRetail;
                }
                field("Take-away VAT Bus. Post. Group"; Rec."Take-away VAT Bus. Post. Group")
                {
                    ToolTip = 'Specifies the VAT business posting group the self-service apps use for take-away orders. Leave blank if take-away is not offered.';
                    ApplicationArea = NPRRetail;
                }
                field("Dine-in Seating Code"; Rec."Dine-in Seating Code")
                {
                    ToolTip = 'Specifies the seating that self-service dine-in orders are placed on when the guest does not choose a table.';
                    ApplicationArea = NPRRetail;
                }
                field("Take-away Seating Code"; Rec."Take-away Seating Code")
                {
                    ToolTip = 'Specifies the seating that self-service take-away orders are placed on.';
                    ApplicationArea = NPRRetail;
                }
                field("Pick-up Seating Code"; Rec."Pick-up Seating Code")
                {
                    ToolTip = 'Specifies the seating that self-service pick-up orders are placed on.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
