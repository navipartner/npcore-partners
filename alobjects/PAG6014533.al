page 6014533 "Touch Screen - Credit Vouchers"
{
    // NPR4.14/RMT/20150818 Case 219872 set properties for page
    //                                  InsertAllowed = No
    //                                  ModifyAllowed = No
    //                                  DeleteAllowed = No
    //                                  DelayedInsert = No
    //                                  Editable      = No
    //                                  CardPageID    = <Undefined>
    //                                  PageType      = ListPlus

    Caption = 'Credit Vouchers';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    SourceTable = "Credit Voucher";

    layout
    {
        area(content)
        {
            grid(Control6150622)
            {
                GridLayout = Columns;
                ShowCaption = false;
                repeater(Control6150614)
                {
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
                }
            }
        }
    }

    actions
    {
    }
}

