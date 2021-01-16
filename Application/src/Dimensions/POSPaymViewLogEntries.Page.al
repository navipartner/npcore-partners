page 6151043 "NPR POS Paym. View Log Entries"
{
    // NPR5.51/MHA /20190723  CASE 351688 Object created

    Caption = 'POS Payment View Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("POS Store"; "POS Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store field';
                }
                field("POS Unit"; "POS Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit field';
                }
                field("POS Sales No."; "POS Sales No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sales No. field';
                }
                field("Post Code Popup"; "Post Code Popup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code Popup field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
    }
}

