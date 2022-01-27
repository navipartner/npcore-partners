page 6059776 "NPR External POS Sales"
{
    Extensible = False;

    ApplicationArea = NPRRetail;
    Caption = 'External POS Sales List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR External POS Sale";
    UsageCategory = Administration;
    CardPageId = "NPR External POS Sale Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {
                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Converted To POS Entry"; Rec."Converted To POS Entry")
                {
                    ToolTip = 'Specifies the value of the Converted To POS Entry field';
                    ApplicationArea = NPRRetail;
                }

                field("Has Conversion Error"; Rec."Has Conversion Error")
                {
                    ToolTip = 'Specifies the value of the Has Conversion Error field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
