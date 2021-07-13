page 6150663 "NPR NPRE Waiter Pad List"
{
    Caption = 'Waiter Pad List';
    CardPageID = "NPR NPRE Waiter Pad";
    PageType = List;
    SourceTable = "NPR NPRE Waiter Pad";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


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
                field("Current Seating Description"; Rec."Current Seating Description")
                {

                    ToolTip = 'Specifies the value of the Seating Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Seating FF"; Rec."Current Seating FF")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Current Seating field';
                    ApplicationArea = NPRRetail;
                }
                field("Multiple Seating FF"; Rec."Multiple Seating FF")
                {

                    ToolTip = 'Specifies the value of the Multiple Seating field';
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
        Rec.UpdateCurrentSeatingDescription();
    end;

    var
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
}
