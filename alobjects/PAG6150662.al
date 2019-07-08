page 6150662 "NPRE Seating - Waiter Pad Link"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Seating - Waiter Pad Link';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPRE Seating - Waiter Pad Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Seating Code";"Seating Code")
                {
                }
                field("Waiter Pad No.";"Waiter Pad No.")
                {
                }
                field("No. Of Waiter Pad For Seating";"No. Of Waiter Pad For Seating")
                {
                }
                field("No. Of Seating For Waiter Pad";"No. Of Seating For Waiter Pad")
                {
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
            }
            action("Change Waiter Pad")
            {
                Caption = 'Change Waiter Pad';
                Image = View;
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

