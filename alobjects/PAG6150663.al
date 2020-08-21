page 6150663 "NPRE Waiter Pad List"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.50/TJ  /20190502 CASE 346387 Added print pre receipt action
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Waiter Pad List';
    CardPageID = "NPRE Waiter Pad";
    PageType = List;
    SourceTable = "NPRE Waiter Pad";
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
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Current Seating Description"; "Current Seating Description")
                {
                    ApplicationArea = All;
                }
                field("Current Seating FF"; "Current Seating FF")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Multiple Seating FF"; "Multiple Seating FF")
                {
                    ApplicationArea = All;
                }
                field("Pre-receipt Printed"; "Pre-receipt Printed")
                {
                    ApplicationArea = All;
                }
                field(Closed; Closed)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Close Date"; "Close Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Close Time"; "Close Time")
                {
                    ApplicationArea = All;
                    Visible = false;
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
        HospitalityPrint: Codeunit "NPRE Restaurant Print";
}

