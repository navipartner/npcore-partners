page 6150695 "NPR NPRE Serv. Flow Prof. Card"
{
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Rest. Service Flow Profile Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NPRE Serv.Flow Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Close Waiter Pad On"; "Close Waiter Pad On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Close Waiter Pad On field';
                }
                field("Clear Seating On"; "Clear Seating On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Clear Seating On field';
                }
                field("Seating Status after Clearing"; "Seating Status after Clearing")
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

    actions
    {
    }
}

