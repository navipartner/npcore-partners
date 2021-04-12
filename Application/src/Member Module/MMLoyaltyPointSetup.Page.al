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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Coupon Type Code"; Rec."Coupon Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type Code field';
                }
                field("Value Assignment"; Rec."Value Assignment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value Assignment field';
                }
                field("Points Threshold"; Rec."Points Threshold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Threshold field';
                }
                field("Amount LCY"; Rec."Amount LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount LCY field';
                }
                field("Point Rate"; Rec."Point Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Point Rate field';
                }
                field("Minimum Coupon Amount"; Rec."Minimum Coupon Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Coupon Amount field';
                }
                field("Consume Available Points"; Rec."Consume Available Points")
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

