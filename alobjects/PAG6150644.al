page 6150644 "POS Info Audit Roll"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Audit Roll';
    Editable = false;
    PageType = List;
    SourceTable = "POS Info Audit Roll";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("Sale Date";"Sale Date")
                {
                }
                field("Receipt Type";"Receipt Type")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
                field("POS Info Code";"POS Info Code")
                {
                }
                field("POS Info";"POS Info")
                {
                }
                field("No.";"No.")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field(Price;Price)
                {
                }
                field("Net Amount";"Net Amount")
                {
                }
                field("Gross Amount";"Gross Amount")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
            }
        }
    }

    actions
    {
    }
}

