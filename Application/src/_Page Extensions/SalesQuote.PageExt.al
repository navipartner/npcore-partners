pageextension 6014439 "NPR Sales Quote" extends "Sales Quote"
{
    // NPR7.100.000/LS/220114  : Retail Merge :
    //                                        Adddedactions : Matrix, E-Mail Log, Send AsPDF
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.22/TJ/20160412 CASE 238601 Removed unused variable ApplicationManagement
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.30/THRO/20170203 CASE 263182 Added action SendSMS
    // NPR5.42/THRO/20180516 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    layout
    {
        addafter(Control49)
        {
            field("NPR Bill-to E-mail"; "NPR Bill-to E-mail")
            {
                ApplicationArea = All;
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Request Approval")
        {
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                }
            }
            group("NPR SMS")
            {
                Caption = 'SMS';
                action("NPR SendSMS")
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                    ApplicationArea = All;
                }
            }
        }
    }
}

