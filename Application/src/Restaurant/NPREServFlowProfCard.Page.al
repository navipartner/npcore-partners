page 6150695 "NPR NPRE Serv. Flow Prof. Card"
{
    Caption = 'Rest. Service Flow Profile Card';
    PageType = Card;
    SourceTable = "NPR NPRE Serv.Flow Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Close Waiter Pad On"; Rec."Close Waiter Pad On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Close Waiter Pad On field';
                }
                field("Clear Seating On"; Rec."Clear Seating On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Clear Seating On field';
                }
                field("Seating Status after Clearing"; Rec."Seating Status after Clearing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Status after Clearing field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control6014408; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }
}