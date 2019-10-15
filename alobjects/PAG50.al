pageextension 6014445 pageextension6014445 extends "Purchase Order" 
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Purch. Doc. Posting (Billing-page).
    // NPR4.15/TS/20151013 CASE 224751 Added NpAttribute Factbox
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR4.18/MMV/20160105 CASE 229221 Unify how label printing of lines are handled.
    // NPR4.18/TS/20151211  CASE 228030 Added field Posting Description
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.22/MMV/20160420 CASE 237743 Updated references to label library CU.
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.24/JDH/20160720 CASE 241848 Added a Name to Posting Description, so Powershell didnt triggered a mergeConflicts in databases where its already used standard
    // NPR5.30/TJ  /20170202 CASE 262533 Removed actions Labels and Invert selection. Instead added actions Retail Print and Price Label
    // NPR5.31/BR  /20170424 CASE 272843 Added Action Insert Line with Vendor Item
    // NPR5.33/BR  /20170615 CASE 272843 Added shortcut key Ctrl+I to Insert Line with Vendor Item action
    // NPR5.38/TS  /20171128 CASE 296801 Added Action Import From Scanner
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.44/BHR/20180709 CASE 321560 Add New fields "Sell-to" 6014420 to 6014430
    // NPR5.45/TS  /20180824  CASE 325688 Removed Extra Space in Insert Line with Vendor Item action
    // NPR5.48/TS  /20181220  CASE 338609 Added Shortcut to Price Label
    // NPR5.48/TS  /20190104  CASE 340491 Added Item Availability Factbox
    layout
    {
        addafter("Job Queue Status")
        {
            field(PostingDescription;"Posting Description")
            {
            }
        }
        addafter(Control71)
        {
            field("Pay-to E-mail";"Pay-to E-mail")
            {
            }
            field("Document Processing";"Document Processing")
            {
            }
            field("Sell-to Customer Name";"Sell-to Customer Name")
            {
                Editable = false;
            }
            field("Sell-to Customer Name 2";"Sell-to Customer Name 2")
            {
                Editable = false;
            }
            field("Sell-to Address";"Sell-to Address")
            {
                Editable = false;
            }
            field("Sell-to Address 2";"Sell-to Address 2")
            {
                Editable = false;
            }
            field("Sell-to City";"Sell-to City")
            {
                Editable = false;
            }
            field("Sell-to Post Code";"Sell-to Post Code")
            {
                Editable = false;
            }
            field("Sell-to Phone No.";"Sell-to Phone No.")
            {
                Editable = false;
            }
        }
        addafter(Control3)
        {
            part(Control6150621;"NP Attributes FactBox")
            {
                Provider = PurchLines;
                SubPageLink = "No."=FIELD("No.");
                Visible = true;
            }
        }
        addafter(Control1905767507)
        {
            part("Item Availability FactBox";"NPR Item Availability FactBox")
            {
                Caption = 'Item Availability FactBox';
                SubPageLink = "No."=FIELD("No.");
            }
        }
    }
    actions
    {
        addafter(MoveNegativeLines)
        {
            action(InsertLineVendorItem)
            {
                Caption = 'Insert Line with Vendor Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';
            }
            action(ImportFromScanner)
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;

                trigger OnAction()
                begin
                    //-NPR5.38 [296801]
                    //+NPR5.38 [296801]
                end;
            }
        }
        addafter("&Print")
        {
            action(RetailPrint)
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
            }
            action(PriceLabel)
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+L';
            }
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

