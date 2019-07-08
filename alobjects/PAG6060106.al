page 6060106 "MM Loyalty Points Setup"
{
    // MM1.17/TSA /20161214  CASE 243075 Member Point System
    // MM1.28/TSA /20180426  CASE 307048 Dynamic Coupons
    // MM1.37/TSA /20190301 CASE 343053 Added field "Consume Available Points"

    AutoSplitKey = true;
    Caption = 'Loyalty Points Setup';
    PageType = List;
    SourceTable = "MM Loyalty Points Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                    Visible = false;
                }
                field(Description;Description)
                {
                }
                field("Coupon Type Code";"Coupon Type Code")
                {
                }
                field("Value Assignment";"Value Assignment")
                {
                }
                field("Points Threshold";"Points Threshold")
                {
                }
                field("Amount LCY";"Amount LCY")
                {
                }
                field("Point Rate";"Point Rate")
                {
                }
                field("Minimum Coupon Amount";"Minimum Coupon Amount")
                {
                }
                field("Consume Available Points";"Consume Available Points")
                {
                }
            }
        }
    }

    actions
    {
    }
}

