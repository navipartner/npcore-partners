page 6014533 "NPR TouchScreen: Credit Vouch."
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
    UsageCategory = Administration;
    SourceTable = "NPR Credit Voucher";

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
                }
            }
        }
    }

    actions
    {
    }
}

