pageextension 6014470 "NPR Posted Service Shipment" extends "Posted Service Shipment"
{
    // PN1.03/MH/20140814  NAV-AddOn: PDF2NAV
    //   - Added Menu Items on Function-button: "E-mail Log" and "Send as PDF".
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    actions
    {
        addafter("&Navigate")
        {
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea=All;
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea=All;
                }
            }
        }
    }
}

