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
                    ToolTip = 'Specifies the seating code assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {
                    ToolTip = 'Specifies the waiter pad No. the seating is assigned to';
                    ApplicationArea = NPRRetail;
                }
                field("No. Of Waiter Pads For Seating"; Rec."No. Of Waiter Pads For Seating")
                {
                    ToolTip = 'Specifies the total number of waiter pads the seating is currently assigned to';
                    ApplicationArea = NPRRetail;
                }
                field("No. Of Seatings For Waiter Pad"; Rec."No. Of Seatings For Waiter Pad")
                {
                    ToolTip = 'Specifies the total number of seatings currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}