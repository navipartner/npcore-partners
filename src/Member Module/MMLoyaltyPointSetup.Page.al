page 6060106 "NPR MM Loyalty Point Setup"
{

    AutoSplitKey = true;
    Caption = 'Loyalty Points Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Loyalty Point Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Coupon Type Code"; "Coupon Type Code")
                {
                    ApplicationArea = All;
                }
                field("Value Assignment"; "Value Assignment")
                {
                    ApplicationArea = All;
                }
                field("Points Threshold"; "Points Threshold")
                {
                    ApplicationArea = All;
                }
                field("Amount LCY"; "Amount LCY")
                {
                    ApplicationArea = All;
                }
                field("Point Rate"; "Point Rate")
                {
                    ApplicationArea = All;
                }
                field("Minimum Coupon Amount"; "Minimum Coupon Amount")
                {
                    ApplicationArea = All;
                }
                field("Consume Available Points"; "Consume Available Points")
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

