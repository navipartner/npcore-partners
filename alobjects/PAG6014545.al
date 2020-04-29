page 6014545 "Touch Screen - Gift Vouchers"
{
    // NPR4.18/RMT/20150813 Case 219872 set properties for page
    //                                  InsertAllowed = No
    //                                  ModifyAllowed = No
    //                                  DeleteAllowed = No
    //                                  DelayedInsert = No
    //                                  Editable      = No
    //                                  CardPageID    = <Undefined>
    //                                  PageType      = ListPlus

    Caption = 'Gift voucher';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    SourceTable = "Gift Voucher";

    layout
    {
        area(content)
        {
            repeater(Control6150621)
            {
                Editable = false;
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Issue Date";"Issue Date")
                {
                }
                field(Status;Status)
                {
                }
                field("Cashed Date";"Cashed Date")
                {
                }
                field(Amount;Amount)
                {
                }
            }
        }
    }

    actions
    {
    }
}

