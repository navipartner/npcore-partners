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

                    ToolTip = 'Specifies the value of the Seating Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {

                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Of Waiter Pad For Seating"; Rec."No. Of Waiter Pad For Seating")
                {

                    ToolTip = 'Specifies the value of the No. Of Waiter Pad For Seating field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Of Seating For Waiter Pad"; Rec."No. Of Seating For Waiter Pad")
                {

                    ToolTip = 'Specifies the value of the No. Of Seating For Waiter Pad field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Change Seating action';
                ApplicationArea = NPRRetail;
            }
            action("Change Waiter Pad")
            {
                Caption = 'Change Waiter Pad';
                Image = View;

                ToolTip = 'Executes the Change Waiter Pad action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}