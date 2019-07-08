page 6014572 "Tax Free Voucher Sale Links"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Voucher Sale Links';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Tax Free Voucher Sale Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                    Editable = false;
                }
                field("Voucher External No.";"Voucher External No.")
                {
                    Caption = 'Linked to Voucher';
                    Editable = false;
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
    }
}

