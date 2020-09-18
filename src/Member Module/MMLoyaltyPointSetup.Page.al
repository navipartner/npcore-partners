page 6060106 "NPR MM Loyalty Point Setup"
{
    // MM1.17/TSA /20161214  CASE 243075 Member Point System
    // MM1.28/TSA /20180426  CASE 307048 Dynamic Coupons
    // MM1.37/TSA /20190301 CASE 343053 Added field "Consume Available Points"

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

