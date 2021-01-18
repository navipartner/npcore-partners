pageextension 6014403 "NPR Posted Sales Shipment" extends "Posted Sales Shipment"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    // 
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Action Items: EmailLog and SendAsPDF.
    //   - Added Permission for Modify.
    //   - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page).
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page).
    // PS1.00/LS/20140509  CASE 190533 Pacsoft Module Added field Delivery Location on Shipping tab
    //                                 Added menu on Print -> Create Pacsoft Shipment Document
    // NPR4.10/TS/20150602 CASE 213397 Added field "Sell-to Customer Name 2" ,"Bill-to Name 2","Ship-to Name 2"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.00/RA/20160329  CASE 237639 Added Action Action6150627
    // NPR5.22/TJ/20160411 CASE 238601 Moved code from action Create Pacsoft Shipment Document to NPR Event Subscriber codeunit
    // NPR5.26/BHR/20160921 CASE 248912 Added action to Generate Pakkelabels document
    // NPR5.29/BHR/20161209 CASE 258936 Change action name 'Generate Pakkelabels document'  TO 'PrintShipmentDocument'
    // NPR5.30/TJ /20170224 CASE 262797 Removed unused local variable from action Consignor Label
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; "Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
            }
        }
        addafter("Ship-to Contact")
        {
            field("NPR Kolli"; "NPR Kolli")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the value of the NPR Kolli field';
            }
        }
        addafter("Shipment Date")
        {
            field("NPR Delivery Location"; "NPR Delivery Location")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Delivery Location field';
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; "Bill-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
            }
        }
        addafter("Bill-to Contact")
        {
            field("NPR Bill-to E-mail"; "NPR Bill-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the NPR Document Processing field';
            }
        }
    }
    actions
    {
        addafter("&Navigate")
        {
            action("NPR Consignor Label")
            {
                Caption = 'Consignor Label';
                ApplicationArea = All;
                ToolTip = 'Executes the Consignor Label action';
                Image = Print;
            }
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
            group("NPR Pacsoft")
            {
                Caption = 'Pacsoft';
                action("NPR CreatePacsoftDocument")
                {
                    Caption = 'Create Pacsoft Shipment Document';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Pacsoft Shipment Document action';
                    Image = CreateDocument; 
                }
                action("NPR PrintShipmentDocument")
                {
                    Caption = 'Print Shipment Document';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Shipment Document action';
                    Image = Print; 
                }
            }
        }
    }
}

