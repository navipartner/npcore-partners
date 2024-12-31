page 6184924 "NPR CRO Fiscal E-Mail Logs"
{
    Caption = 'CRO Fiscal E-Mail Logs';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR CRO Fiscal E-Mail Log";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Sender E-mail"; Rec."Sender E-mail")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Sender''s E-mail address.';
                }
                field("Recipient E-mail"; Rec."Recipient E-mail")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the E-mail address of the Recipient.';
                }
                field(Successful; Rec.Successful)
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies whether the receipt mailing was successful.';
                }
                field("Sending Date"; Rec."Sending Date")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Date of the recipt mailing.';
                }
                field("Sending Time"; Rec."Sending Time")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the time when the reciept was sent.';
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Filename of the attachment.';
                }
                field("E-mail Subject"; Rec."E-mail Subject")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Subject of an E-mail.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = NPRCROFiscal;
                    Caption = 'Error Message';
                    Style = Attention;
                    StyleExpr = 'Attention';
                    ToolTip = 'Specifies the Error Message for any found errors.';
                }
                field("Sent by"; Rec."Sent by")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Username of the user who sent the E-mail.';
                }
            }
        }
    }
}