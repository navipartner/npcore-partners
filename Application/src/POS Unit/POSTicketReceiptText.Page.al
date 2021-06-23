page 6150749 "NPR POS Ticket Rcpt. Text"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Ticket Rcpt. Text";
    Caption = 'POS Sales Ticket Receipt Text';
    AutoSplitKey = true;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Rcpt. Txt. Profile Code"; Rec."Rcpt. Txt. Profile Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies POS Unit Sales Receipt Text Profile Code';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies line number of sales receipt text';
                }
                field("Receipt Text"; Rec."Receipt Text")
                {
                    Caption = 'Sales Ticket Receipt - Preview';
                    ApplicationArea = All;
                    ToolTip = 'Specifies Receipt Text';
                }
            }
        }
    }
}