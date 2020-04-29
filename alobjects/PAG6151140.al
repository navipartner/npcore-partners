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
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Sale Type";"Sale Type")
                {
                }
                field(Type;Type)
                {
                }
                field("Sale Date";"Sale Date")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Closing Time";"Closing Time")
                {
                }
                field("No.";"No.")
                {
                }
                field(Amount;Amount)
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(Posted;Posted)
                {
                }
                field("Item Entry Posted";"Item Entry Posted")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field("Line Discount %";"Line Discount %")
                {
                }
                field("Line Discount Amount";"Line Discount Amount")
                {
                }
                field("VAT %";"VAT %")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field(Offline;Offline)
                {
                }
                field("Gen. Bus. Posting Group";"Gen. Bus. Posting Group")
                {
                }
                field("Discount Authorised by";"Discount Authorised by")
                {
                }
                field("Reason Code";"Reason Code")
                {
                }
                field("Posted Doc. No.";"Posted Doc. No.")
                {
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                }
                field("Unit Cost";"Unit Cost")
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
            }
        }
    }

    actions
    {
    }
}

