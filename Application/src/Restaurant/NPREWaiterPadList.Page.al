page 6150663 "NPR NPRE Waiter Pad List"
{
    Caption = 'Waiter Pad List';
    CardPageID = "NPR NPRE Waiter Pad";
    PageType = List;
    SourceTable = "NPR NPRE Waiter Pad";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Current Seating Description"; Rec."Current Seating Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Description field';
                }
                field("Current Seating FF"; Rec."Current Seating FF")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Current Seating field';
                }
                field("Multiple Seating FF"; Rec."Multiple Seating FF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Multiple Seating field';
                }
                field("Pre-receipt Printed"; Rec."Pre-receipt Printed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pre-receipt Printed field';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closed field';
                }
                field("Close Date"; Rec."Close Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Close Date field';
                }
                field("Close Time"; Rec."Close Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Close Time field';
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Pre Receipt action';

                    trigger OnAction()
                    begin
                        HospitalityPrint.PrintWaiterPadPreReceiptPressed(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.UpdateCurrentSeatingDescription;
    end;

    var
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
}