pageextension 50008 pageextension50008 extends "Posted Sales Credit Memo" 
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Permission for Modify.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // OU1.00/MH/20140714  NP-AddOn: OIOUBL (DK) - Added Fields "Electronic Invoice Created"
    // NPR4.10/TS/20150602 CASE 213397 Added field "Sell-to Customer Name 2" ,"Bill-to Name 2","Ship-to Name 2"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.33/BR /20170323  CASE 266527 Added Doc. Exchange Actions
    // MAG2.12/MHA /20180425  CASE 309647 Added fields 6151400 "Magento Payment Amount" under Invoicing Tab
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.43/JDH /20180712 CASE        Indentation Not correctly done on Bill-To Email and Document Processing
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2";"Sell-to Customer Name 2")
            {
            }
        }
        addafter("EU 3-Party Trade")
        {
            field("Magento Payment Amount";"Magento Payment Amount")
            {
            }
        }
        addafter("Ship-to Name")
        {
            field("Ship-to Name 2";"Ship-to Name 2")
            {
            }
        }
        addafter("Bill-to Name")
        {
            field("Bill-to Name 2";"Bill-to Name 2")
            {
            }
        }
        addafter("Bill-to Contact")
        {
            field("Bill-to E-mail";"Bill-to E-mail")
            {
            }
            field("Document Processing";"Document Processing")
            {
                Editable = false;
            }
        }
    }
    actions
    {
        addafter(ActivityLog)
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
            group(DocExchFramework)
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

