page 6150749 "NPR POS Ticket Rcpt. Text"
{
    Extensible = False;
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

                    Visible = false;
                    ToolTip = 'Specifies POS Unit Sales Receipt Text Profile Code';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies line number of sales receipt text';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Text"; Rec."Receipt Text")
                {
                    Caption = 'Sales Ticket Receipt - Preview';
                    ToolTip = 'Specifies Receipt Text';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
