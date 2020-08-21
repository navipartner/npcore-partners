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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Cashed Date"; "Cashed Date")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
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

