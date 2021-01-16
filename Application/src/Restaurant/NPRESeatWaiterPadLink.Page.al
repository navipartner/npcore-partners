page 6150662 "NPR NPRE Seat.: WaiterPadLink"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Seating - Waiter Pad Link';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NPRE Seat.: WaiterPadLink";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Seating Code"; "Seating Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Code field';
                }
                field("Waiter Pad No."; "Waiter Pad No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                }
                field("No. Of Waiter Pad For Seating"; "No. Of Waiter Pad For Seating")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Of Waiter Pad For Seating field';
                }
                field("No. Of Seating For Waiter Pad"; "No. Of Seating For Waiter Pad")
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

    local procedure ChangeSeating()
    begin
    end;

    local procedure ChangeWaiterPad()
    begin
    end;
}

