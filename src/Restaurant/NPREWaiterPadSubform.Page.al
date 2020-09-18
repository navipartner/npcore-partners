page 6150661 "NPR NPRE Waiter Pad Subform"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.54/ALPO/20200217 CASE 390995 Block quantity change on waiterpad line: fields Quantity, "Amount Excl. VAT", "Amount Incl. VAT" set to not editable
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Lines';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NPRE Waiter Pad Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LineIsMarked; LineIsMarked)
                {
                    ApplicationArea = All;
                    Caption = 'Select';

                    trigger OnValidate()
                    begin
                        Mark(not Mark);  //NPR5.53 [360258]
                    end;
                }
                field("Waiter Pad No."; "Waiter Pad No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Billed Quantity"; "Billed Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Order No. from Web"; "Order No. from Web")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Order Line No. from Web"; "Order Line No. from Web")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Allow Invoice Discount"; "Allow Invoice Discount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Allow Line Discount"; "Allow Line Discount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Invoice Discount Amount"; "Invoice Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Amount Excl. VAT"; "Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Amount Incl. VAT"; "Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Meal Flow"; "Meal Flow")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Meal Flow Description"; "Meal Flow Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Line Status"; "Line Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line Status Description"; "Line Status Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(AssignedFlowStatuses; AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {
                    ApplicationArea = All;
                    Caption = 'Serving Steps';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);  //NPR5.55 [382428]
                    end;
                }
                field(AssignedPrintCategories; AssignedPrintCategoriesAsString())
                {
                    ApplicationArea = All;
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowPrintCategories();  //NPR5.53 [360258]
                    end;
                }
                field("Kitchen Order Sent"; "Kitchen Order Sent")
                {
                    ApplicationArea = All;
                }
                field("Serving Requested"; "Serving Requested")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Change Quantiy")
            {
                Enabled = false;
                Visible = false;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Message('Qty');
                end;
            }
            action("Delete Line")
            {
                Enabled = false;
                Visible = false;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Message('DL');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LineIsMarked := Mark;  //NPR5.53 [360258]
    end;

    var
        FlowStatus: Record "NPR NPRE Flow Status";
        LineIsMarked: Boolean;

    procedure GetSelection(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        //-NPR5.53 [360258]
        WaiterPadLine.Copy(Rec);
        //+NPR5.53 [360258]
    end;

    procedure ClearMarkedLines()
    begin
        //-NPR5.53 [360258]
        ClearMarks;
        //+NPR5.53 [360258]
    end;
}

