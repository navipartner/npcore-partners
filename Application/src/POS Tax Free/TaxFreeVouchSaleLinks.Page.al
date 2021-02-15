page 6014572 "NPR Tax Free Vouch. Sale Links"
{
    Caption = 'Tax Free Voucher Sale Links';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free Voucher Sale Link";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Voucher External No."; Rec."Voucher External No.")
                {
                    ApplicationArea = All;
                    Caption = 'Linked to Voucher';
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Linked to Voucher field';
                }
            }
        }
    }
}

