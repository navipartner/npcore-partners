page 6014545 "NPR TouchScreen: Gift Vouchers"
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
    UsageCategory = Administration;
    SourceTable = "NPR Gift Voucher";

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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Date field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Cashed Date"; "Cashed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashed Date field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
            }
        }
    }

    actions
    {
    }
}

