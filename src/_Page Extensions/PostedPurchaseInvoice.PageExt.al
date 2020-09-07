pageextension 6014411 "NPR Posted Purchase Invoice" extends "Posted Purchase Invoice"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    // 
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Permission for Modify.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.51/BHR /20190614 CASE 357407 Add action For RetailPrint and Price Label
    // NPR5.55/CLVA/20200610 CASE Added Action "Show Imported File"

    //Unsupported feature: Property Insertion (Permissions) on ""Posted Purchase Invoice"(Page 138)".

    layout
    {
        addafter("Pay-to")
        {
            field("NPR Pay-to E-mail"; "NPR Pay-to E-mail")
            {
                ApplicationArea = All;
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
    actions
    {
        addafter("&Navigate")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+L';
                ApplicationArea=All;
            }
            action("NPR Show Imported File")
            {
                Caption = 'Show Imported File';
                Image = DocInBrowser;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    //-366790 [366790]
                    NcImportListPg.ShowFormattedDocByDocNo("Vendor Invoice No.");
                    //+366790 [366790]
                end;
            }
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

