pageextension 6014405 "NPR Posted Sales Invoice" extends "Posted Sales Invoice"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    // 
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //                     - Added Action Items: EmailLog and SendAsPDF
    //                     - Added Permission for Modify
    //                     - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page)
    //                     - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page)
    // NC1.03/MH/20150205  CASE 199932 Added NaviConnect Payment Amount
    // VRT1.00/JDH/20150304 CASE 201022 Added call to Variety Matrix
    // NPR4.10/TS/20150602 CASE 213397 Added field "Sell-to Customer Name 2" ,"Bill-to Name 2","Ship-to Name 2"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.22/RA/20160329  CASE 237639 Added Action Action6150625
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.30/TJ /20170224  CASE 262797 Removed unused local variable from action Consignor Label
    // NPR5.33/BR /20170323  CASE 266527 Added Doc. Exchange Actions
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; "Sell-to Customer Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Magento Payment Amount"; "NPR Magento Payment Amount")
            {
                ApplicationArea = All;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; "Bill-to Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Bill-to")
        {
            field("NPR Bill-to E-mail"; "NPR Bill-to E-mail")
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
        addafter(ActivityLog)
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
            group("NPR DocExchFramework")
            {
                Caption = 'Doc. Exch. Framework';
                action("NPR Export")
                {
                    Caption = 'Export';
                    Image = ExportFile;
                    ApplicationArea = All;
                }
                action("NPR UpdateStatus")
                {
                    Caption = 'Update Status';
                    Image = ChangeStatus;
                    ApplicationArea = All;
                }
            }
            action("NPR Consignor Label")
            {
                Caption = 'Consignor Label';
                ApplicationArea = All;
            }
        }
    }
}

