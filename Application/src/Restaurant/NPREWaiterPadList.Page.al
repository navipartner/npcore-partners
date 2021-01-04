page 6150663 "NPR NPRE Waiter Pad List"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.50/TJ  /20190502 CASE 346387 Added print pre receipt action
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Waiter Pad List';
    CardPageID = "NPR NPRE Waiter Pad";
    PageType = List;
    SourceTable = "NPR NPRE Waiter Pad";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Current Seating Description"; "Current Seating Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Description field';
                }
                field("Current Seating FF"; "Current Seating FF")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Current Seating field';
                }
                field("Multiple Seating FF"; "Multiple Seating FF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Multiple Seating field';
                }
                field("Pre-receipt Printed"; "Pre-receipt Printed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pre-receipt Printed field';
                }
                field(Closed; Closed)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closed field';
                }
                field("Close Date"; "Close Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Close Date field';
                }
                field("Close Time"; "Close Time")
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
        UpdateCurrentSeatingDescription;
    end;

    var
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
}

