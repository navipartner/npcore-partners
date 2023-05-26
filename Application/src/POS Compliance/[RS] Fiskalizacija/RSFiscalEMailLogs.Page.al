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
                    ToolTip = 'Specifies the value of the From E-mail field.';
                }
                field("Recipient E-mail"; Rec."Recipient E-mail")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Recipient E-mail field.';
                }
                field(Successful; Rec.Successful)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Successful field.';
                }
                field("Sent Date"; Rec."Sent Date")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Sent Date field.';
                }
                field("Sent Time"; Rec."Sent Time")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Sent time field.';
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Filename field.';
                }
                field("E-mail subject"; Rec."E-mail subject")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the E-mail subject field.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Error Message';
                    Style = Attention;
                    StyleExpr = 'Attention';
                    ToolTip = 'Specifies the value of the Error Message field.';
                }
                field("Sent Username"; Rec."Sent Username")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Sent by Username field.';
                }
            }
        }
    }
}