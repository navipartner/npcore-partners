page 6151140 "Audit Roll - OData"
{
    // NPR5.47/TJ  /20181015 CASE 331725 New object
    // NPR5.48/TJ  /20181129 CASE 338110 Added field "Posted Doc. No."
    // NPR5.48/TJ  /20181204 CASE 338606 Added fields "Shortcut Dimension 1 Code" and "Shortcut Dimension 2 Code"
    // NPR5.48/TJ  /20181206 CASE 338983 Added field "Unit Cost"
    // NPR5.48/TJ  /20181218 CASE 340302 Added field "Unit Price"

    Caption = 'Audit Roll - OData';
    PageType = List;
    SourceTable = "Audit Roll";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                }
                field("Item Entry Posted"; "Item Entry Posted")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field(Offline; Offline)
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Posted Doc. No."; "Posted Doc. No.")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

