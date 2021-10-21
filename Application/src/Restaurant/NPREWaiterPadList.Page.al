page 6150663 "NPR NPRE Waiter Pad List"
{
    Caption = 'Waiter Pad List';
    CardPageID = "NPR NPRE Waiter Pad";
    PageType = List;
    SourceTable = "NPR NPRE Waiter Pad";
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
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {
                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Seating Code"; Rec."Current Seating FF")
                {
                    Caption = 'Seating Code';
                    ToolTip = 'Specifies internal unique Id of the first seating currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Current Seating No."; Seating."Seating No.")
                {
                    Caption = 'Seating No.';
                    ToolTip = 'Specifies a user friendly id (table number) of the first seating currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                }
                field("Current Seating Description"; Seating.Description)
                {
                    Caption = 'Seating Description';
                    ToolTip = 'Specifies description of the first seating currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                }
                field("Multiple Seating FF"; Rec."Multiple Seating FF")
                {
                    Caption = 'Assigned Seatings';
                    ToolTip = 'Specifies the total number of seatings currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                }
                field("Pre-receipt Printed"; Rec."Pre-receipt Printed")
                {
                    ToolTip = 'Specifies the value of the Pre-receipt Printed field';
                    ApplicationArea = NPRRetail;
                }
                field(Closed; Rec.Closed)
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closed field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Date"; Rec."Close Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Close Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Time"; Rec."Close Time")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Close Time field';
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
                    ToolTip = 'Executes the Print Pre Receipt action';
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
                    ToolTip = 'Executes the Close waiter pad action';
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
