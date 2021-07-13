page 6151043 "NPR POS Paym. View Log Entries"
{

    Caption = 'POS Payment View Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Paym. View Log Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; Rec."Log Date")
                {

                    ToolTip = 'Specifies the value of the Log Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store"; Rec."POS Store")
                {

                    ToolTip = 'Specifies the value of the POS Store field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit"; Rec."POS Unit")
                {

                    ToolTip = 'Specifies the value of the POS Unit field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Sales No."; Rec."POS Sales No.")
                {

                    ToolTip = 'Specifies the value of the POS Sales No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code Popup"; Rec."Post Code Popup")
                {

                    ToolTip = 'Specifies the value of the Post Code Popup field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

