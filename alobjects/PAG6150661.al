page 6150661 "NPRE Waiter Pad Subform"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'Lines';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPRE Waiter Pad Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LineIsMarked;LineIsMarked)
                {
                    Caption = 'Select';

                    trigger OnValidate()
                    begin
                        Mark(not Mark);  //NPR5.53 [360258]
                    end;
                }
                field("Waiter Pad No.";"Waiter Pad No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Register No.";"Register No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Start Date";"Start Date")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Start Time";"Start Time")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Type;Type)
                {
                    Editable = false;
                    Visible = false;
                }
                field("No.";"No.")
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                }
                field(Quantity;Quantity)
                {
                }
                field("Sale Type";"Sale Type")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Description 2";"Description 2")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Variant Code";"Variant Code")
                {
                    Editable = false;
                }
                field("Order No. from Web";"Order No. from Web")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Order Line No. from Web";"Order Line No. from Web")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Unit Price";"Unit Price")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Discount Type";"Discount Type")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Discount Code";"Discount Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Allow Invoice Discount";"Allow Invoice Discount")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Allow Line Discount";"Allow Line Discount")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Discount %";"Discount %")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Discount Amount";"Discount Amount")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Invoice Discount Amount";"Invoice Discount Amount")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Currency Code";"Currency Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Amount Excl. VAT";"Amount Excl. VAT")
                {
                    Visible = false;
                }
                field("Amount Incl. VAT";"Amount Incl. VAT")
                {
                    Visible = false;
                }
                field("Meal Flow";"Meal Flow")
                {
                    Visible = false;
                }
                field("Meal Flow Description";"Meal Flow Description")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Line Status";"Line Status")
                {
                    Visible = false;
                }
                field("Line Status Description";"Line Status Description")
                {
                    Editable = false;
                    Visible = false;
                }
                field("AssignedPrintCategoriesAsString()";AssignedPrintCategoriesAsString())
                {
                    Caption = 'Print Categories';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ShowPrintCategories();  //NPR5.53 [360258]
                    end;
                }
                field("Kitchen Order Sent";"Kitchen Order Sent")
                {
                }
                field("Serving Requested";"Serving Requested")
                {
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

                trigger OnAction()
                begin
                    Message('Qty');
                end;
            }
            action("Delete Line")
            {
                Enabled = false;
                Visible = false;

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
        LineIsMarked: Boolean;

    procedure GetSelection(var WaiterPadLine: Record "NPRE Waiter Pad Line")
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

