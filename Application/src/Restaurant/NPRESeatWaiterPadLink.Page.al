page 6150662 "NPR NPRE Seat.: WaiterPadLink"
{
    Caption = 'Seating - Waiter Pad Link';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR NPRE Seat.: WaiterPadLink";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Seating Code"; Rec."Seating Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Code field';
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                }
                field("No. Of Waiter Pad For Seating"; Rec."No. Of Waiter Pad For Seating")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Of Waiter Pad For Seating field';
                }
                field("No. Of Seating For Waiter Pad"; Rec."No. Of Seating For Waiter Pad")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Of Seating For Waiter Pad field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Change Seating")
            {
                Caption = 'Change Seating';
                Image = "Action";
                ApplicationArea = All;
                ToolTip = 'Executes the Change Seating action';
            }
            action("Change Waiter Pad")
            {
                Caption = 'Change Waiter Pad';
                Image = View;
                ApplicationArea = All;
                ToolTip = 'Executes the Change Waiter Pad action';
            }
        }
    }
}