pageextension 50016 pageextension50016 extends "Posted Sales Invoices" 
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR4.18/TS/20150105  CASE 230115 Added External Document No.
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.26/TJ/20160817 CASE 248831 Added new field "Doc. Exch. Framework Status", new action group Doc. Exch. Framework and 2 new actions Export and UpdateStatus
    // NPR5.38/TS  /20180115  CASE 301895 Removed field "Doc. Exch. Framework Status"
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action EmailLog
    // NPR5.43/TS  /20180522 CASE 318388 Action Print has been promoted.
    layout
    {

        //Unsupported feature: Property Deletion (StyleExpr) on ""Document Exchange Status"(Control 11)".

        addafter("Shipment Date")
        {
            field("Bill-to E-mail";"Bill-to E-mail")
            {
                Visible = false;
            }
            field("Document Processing";"Document Processing")
            {
                Editable = false;
                Visible = false;
            }
        }
    }
    actions
    {
        addafter(Navigate)
        {
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action(SendSelectedAsPDF)
                {
                    Caption = 'Send Selected as PDF';
                    Image = SendEmailPDF;
                    ToolTip = 'Send Selected as PDF';

                    trigger OnAction()
                    var
                        EmailDocMgt: Codeunit "E-mail Document Management";
                        SalesInvHeader: Record "Sales Invoice Header";
                    begin
                        //-PN1.00
                        CurrPage.SetSelectionFilter(SalesInvHeader);
                        if SalesInvHeader.FindSet then
                          repeat
                            //-PN1.10
                            //EmailDocMgt.SendReportSalesInvHdr(SalesInvHeader,TRUE);
                            EmailDocMgt.SendReport(SalesInvHeader,true);
                            //+PN1.10
                          until SalesInvHeader.Next = 0;
                        CurrPage.Update(false);
                        //+PN1.00
                    end;
                }
            }
            group("Doc. Exch. Framework")
            {
                Caption = 'Doc. Exch. Framework';
                action(Export)
                {
                    Caption = 'Export';
                    Image = ExportFile;
                }
                action(UpdateStatus)
                {
                    Caption = 'Update Status';
                    Image = ChangeStatus;
                }
            }
        }
    }
}

