page 6150700 "NPR RS Fiscal E-Mail Logs"
{
    Caption = 'RS Fiscal E-Mail Logs';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS Fiscal E-Mail Log";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("From E-mail"; Rec."From E-mail")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the E-mail address from which recipt was sent.';
                }
                field("Recipient E-mail"; Rec."Recipient E-mail")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the E-mail address of the Recipient.';
                }
                field(Successful; Rec.Successful)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies whether the receipt mailing was successful.';
                }
                field("Sent Date"; Rec."Sent Date")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Date of the recipt mailing.';
                }
                field("Sent Time"; Rec."Sent Time")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the time when the reciept was sent.';
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Filename of the reciept.';
                }
                field("E-mail subject"; Rec."E-mail subject")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the subject of an E-mail.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Error Message';
                    Style = Attention;
                    StyleExpr = 'Attention';
                    ToolTip = 'Specifies the Error Message for any found errors.';
                }
                field("Sent Username"; Rec."Sent Username")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Username from which reciept was sent.';
                }
            }
        }
    }
}