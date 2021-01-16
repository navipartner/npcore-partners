page 6060106 "NPR MM Loyalty Point Setup"
{

    AutoSplitKey = true;
    Caption = 'Loyalty Points Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Coupon Type Code"; "Coupon Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type Code field';
                }
                field("Value Assignment"; "Value Assignment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value Assignment field';
                }
                field("Points Threshold"; "Points Threshold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Threshold field';
                }
                field("Amount LCY"; "Amount LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount LCY field';
                }
                field("Point Rate"; "Point Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Point Rate field';
                }
                field("Minimum Coupon Amount"; "Minimum Coupon Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Coupon Amount field';
                }
                field("Consume Available Points"; "Consume Available Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Consume Available Points field';
                }
            }
        }
    }

    actions
    {
    }
}

