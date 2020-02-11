pageextension 6014445 pageextension6014445 extends "Purchase Quote" 
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Purch. Doc. Posting (Billing-page).
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.45/TS  /20180829 CASE 324592 Added Action Import from Scanner
    layout
    {
        addafter(Control51)
        {
            field("Pay-to E-mail";"Pay-to E-mail")
            {
            }
            field("Document Processing";"Document Processing")
            {
            }
        }
    }
    actions
    {
        addafter("Archive Document")
        {
            action(ImportFromScanner)
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;

                trigger OnAction()
                begin
                    //-NPR5.45 [324592]
                    //+NPR5.45 [324592]
                end;
            }
        }
        addafter("Make Order")
        {
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                }
            }
        }
    }
}

