page 6151043 "NPR POS Paym. View Log Entries"
{

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
                field("Log Date"; Rec."Log Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("POS Store"; Rec."POS Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store field';
                }
                field("POS Unit"; Rec."POS Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit field';
                }
                field("POS Sales No."; Rec."POS Sales No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sales No. field';
                }
                field("Post Code Popup"; Rec."Post Code Popup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code Popup field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }
}

