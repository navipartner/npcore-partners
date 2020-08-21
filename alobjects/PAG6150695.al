page 6150695 "NPRE Service Flow Profile Card"
{
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Rest. Service Flow Profile Card';
    PageType = Card;
    SourceTable = "NPRE Service Flow Profile";

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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Close Waiter Pad On"; "Close Waiter Pad On")
                {
                    ApplicationArea = All;
                }
                field("Clear Seating On"; "Clear Seating On")
                {
                    ApplicationArea = All;
                }
                field("Seating Status after Clearing"; "Seating Status after Clearing")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
            }
            systempart(Control6014408; Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

