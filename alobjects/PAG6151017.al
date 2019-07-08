page 6151017 "NpRv Sale Line POS Vouchers"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher

    Caption = 'Sale Line POS Retail Vouchers';
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Sale Line POS Voucher";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sale Date";"Sale Date")
                {
                }
                field("Sale Line No.";"Sale Line No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Voucher Type";"Voucher Type")
                {
                }
                field("Voucher No.";"Voucher No.")
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

