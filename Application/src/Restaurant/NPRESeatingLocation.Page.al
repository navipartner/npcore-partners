page 6150667 "NPR NPRE Seating Location"
{
    Extensible = False;
    Caption = 'Seating Locations';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Layout';
    SourceTable = "NPR NPRE Seating Location";
    UsageCategory = Administration;
    PopulateAllFields = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this seating location.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the seating location.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant this seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field(Control6014404; Rec.Seatings)
                {
                    Editable = false;
                    ToolTip = 'Specifies the total number of seatings (tables) created at the seating location.';
                    ApplicationArea = NPRRetail;
                }
                field(Seats; Rec.Seats)
                {
                    Editable = false;
                    ToolTip = 'Specifies the total number of guests that can be simultaneously seated at the seating location.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store"; Rec."POS Store")
                {
                    ToolTip = 'Specifies the POS store this seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies if system should automatically create or update kitchen orders as soon as new products are saved to waiter pads.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Layout)
            {
                Caption = 'Layout';
                Image = ServiceZones;
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Image = Lot;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Seating List";
                    RunPageLink = "Seating Location" = FIELD(Code);
                    ToolTip = 'View seatings defined at the location.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
