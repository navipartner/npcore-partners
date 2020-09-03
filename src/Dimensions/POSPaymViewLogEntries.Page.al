page 6151043 "NPR POS Paym. View Log Entries"
{
    // NPR5.51/MHA /20190723  CASE 351688 Object created

    Caption = 'POS Payment View Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Paym. View Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; "Log Date")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("POS Store"; "POS Store")
                {
                    ApplicationArea = All;
                }
                field("POS Unit"; "POS Unit")
                {
                    ApplicationArea = All;
                }
                field("POS Sales No."; "POS Sales No.")
                {
                    ApplicationArea = All;
                }
                field("Post Code Popup"; "Post Code Popup")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
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

