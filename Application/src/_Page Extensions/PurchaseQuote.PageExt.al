pageextension 6014450 "NPR Purchase Quote" extends "Purchase Quote"
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
            field("NPR Pay-to E-mail"; "NPR Pay-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Pay-to E-mail field';
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Document Processing field';
            }
        }
    }
    actions
    {
        addafter("Archive Document")
        {
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import from scanner action';

                trigger OnAction()
                begin
                    //-NPR5.45 [324592]
                    //+NPR5.45 [324592]
                end;
            }
        }
        addafter("Make Order")
        {
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send as PDF action';
                }
            }
        }
    }
}

