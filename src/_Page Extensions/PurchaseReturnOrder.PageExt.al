pageextension 6014473 "NPR Purchase Return Order" extends "Purchase Return Order"
{
    // NPR5.38/TS  /20171120  CASE 296906 Added Action PDF2NAV
    //                                    Added field Document Processing.
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    layout
    {
        addafter("Expected Receipt Date")
        {
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("P&osting")
        {
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                }
            }
        }
    }
}

