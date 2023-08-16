page 6150663 "NPR NPRE Waiter Pad List"
{
    Extensible = False;
    Caption = 'Waiter Pad List';
    CardPageID = "NPR NPRE Waiter Pad";
    PageType = List;
    SourceTable = "NPR NPRE Waiter Pad";
    SourceTableView = order(descending);
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the waiter pad unique number, assigned by the system according to the specified number series.';
                    ApplicationArea = NPRRetail;
                }
                field(openedDateTime; Rec.SystemCreatedAt)
                {
                    Caption = 'Opened Date-Time';
                    ToolTip = 'Specifies the date-time the waiter pad was opened at.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies additional optional description of the waiter pad. You can use it to specify main guest name or other information, which can help you distinguish this waiter pad from other ones created for the same seating.';
                    ApplicationArea = NPRRetail;
                }
                field("Current Seating Code"; Rec."Current Seating FF")
                {
                    Caption = 'Seating Code';
                    ToolTip = 'Specifies the internal unique Id of the primary seating currently assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Current Seating No."; Seating."Seating No.")
                {
                    Caption = 'Seating No.';
                    ToolTip = 'Specifies the user friendly id (table number) of the primary seating currently assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                }
                field("Current Seating Description"; Seating.Description)
                {
                    Caption = 'Seating Description';
                    ToolTip = 'Specifies description of the primary seating currently assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                }
                field("Multiple Seating FF"; Rec."Multiple Seating FF")
                {
                    Caption = 'Assigned Seatings';
                    ToolTip = 'Specifies the total number of seatings currently assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                }
                field("Pre-receipt Printed"; Rec."Pre-receipt Printed")
                {
                    ToolTip = 'Specifies if pre-receipt has already been printed for the waiter pad.';
                    ApplicationArea = NPRRetail;
                }
                field(Closed; Rec.Closed)
                {
                    Visible = false;
                    ToolTip = 'Specifies if the waiter pad has been already finished and closed.';
                    ApplicationArea = NPRRetail;
                }
                field("Close Date"; Rec."Close Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the date when the waiter pad was closed on.';
                    ApplicationArea = NPRRetail;
                }
                field("Close Time"; Rec."Close Time")
                {
                    Visible = false;
                    ToolTip = 'Specifies the time when the waiter pad was closed at.';
                    ApplicationArea = NPRRetail;
                }
                field("Close Reason"; Rec."Close Reason")
                {
                    Visible = false;
                    ToolTip = 'Specifies a reason or process context for the waiter pad closure.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                action("Print Pre Receipt")
                {
                    Caption = 'Print Pre Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Print pre-receipt for the waiter pad.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        HospitalityPrint.PrintWaiterPadPreReceiptPressed(Rec);
                    end;
                }
            }
            group(Status)
            {
                Caption = 'Status';
                action(CloseWaiterPad)
                {
                    Caption = 'Close waiter pad';
                    Image = CloseDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Close the waiter pad. Please note that once closed, you won’t be able to reopen the waiter pad again.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.CloseWaiterPad();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.GetCurrentSeating(Seating);
    end;

    var
        Seating: Record "NPR NPRE Seating";
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
}
