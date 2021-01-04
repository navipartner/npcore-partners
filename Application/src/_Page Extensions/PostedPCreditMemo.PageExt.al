pageextension 6014414 "NPR Posted P.Credit Memo" extends "Posted Purchase Credit Memo"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Permission for Modify.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.29/TJ/20170113 CASE 262797 Restored Permission property to standard value (from: TableData Purch. Cr. Memo Hdr.=m)
    //                                 Also restored TooltipML property of some actions to standard values
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.55/CLVA/20200610 CASE Added Action "Show Imported File"
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
        addafter(IncomingDocAttachFile)
        {
            action("NPR Show Imported File")
            {
                Caption = 'Show Imported File';
                Image = DocInBrowser;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Imported File action';

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    //-366790 [366790]
                    NcImportListPg.ShowFormattedDocByDocNo("Vendor Cr. Memo No.");
                    //+366790 [366790]
                end;
            }
        }
    }
}

