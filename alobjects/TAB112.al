tableextension 6014405 tableextension6014405 extends "Sales Invoice Header" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014400..6060004
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //                     - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV
    //                     - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting
    // MAG1.01/MH/20150201  CASE 204133 Added Field 6059800 "External Customer No.".
    // PS1.00/LS/20141201  CASE 200150 : Field 6014420 to be used for pacsoft
    // PS1.01/LS/20141223  CASE 200974 Added field 6014470
    // MAG1.03/MH/20150205  CASE 199932 Renamed field 6059795 from "Payment Line Amount" to "NaviConnect Payment Amount"
    // NPR4.14/RMT/20150826 CASE 216519 Added field 6014425 "Order Type"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.26/TJ/20160816 CASE 248831 Added new fields for Document Exchange Framework integration: 6059931..6059935
    // NPR5.34/BHR/20170720  CASE 283061 Cleared property MinValue of field Kolli
    fields
    {
        field(6014400;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
        }
        field(6014414;"Bill-to E-mail";Text[80])
        {
            Caption = 'Bill-to E-mail';
            Description = 'PN1.00';
        }
        field(6014415;"Document Processing";Option)
        {
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014420;"Delivery Location";Code[10])
        {
            Caption = 'Delivery Location';
            Description = 'PS1.00';
        }
        field(6014425;"Order Type";Option)
        {
            Caption = 'Order Type';
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
        }
        field(6014450;Kolli;Integer)
        {
            Caption = 'Number of packages';
            Description = 'NPR7.100.000';
            InitValue = 1;
        }
        field(6014451;"Shipping Agent Service Code";Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            Description = 'NPR7.100.000';
            TableRelation = "Shipping Agent Services".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));
        }
        field(6014470;"Pacsoft Shipment Not Created";Boolean)
        {
            Caption = 'Pacsoft Shipment Not Created';
            Description = 'PS1.01';
        }
        field(6059931;"Doc. Exch. Framework Status";Option)
        {
            Caption = 'Doc. Exch. Framework Status';
            Description = 'NPR5.26';
            OptionCaption = ' ,Exported to Folder,Setup Changed,Delivered to Recepient,File Validation Error';
            OptionMembers = " ","Exported to Folder","Setup Changed","Delivered to Recepient","File Validation Error";
        }
        field(6059932;"Doc. Exch. Exported";Boolean)
        {
            Caption = 'Doc. Exch. Exported';
            Description = 'NPR5.26';
        }
        field(6059933;"Doc. Exch. Setup Path Used";RecordID)
        {
            Caption = 'Doc. Exch. Setup Path Used';
            Description = 'NPR5.26';
        }
        field(6059934;"Doc. Exch. Exported to";Text[250])
        {
            Caption = 'Doc. Exch. Exported to';
            Description = 'NPR5.26';
        }
        field(6059935;"Doc. Exch. File Exists";Boolean)
        {
            Caption = 'Doc. Exch. File Exists';
            Description = 'NPR5.26';
        }
        field(6151400;"Magento Payment Amount";Decimal)
        {
            CalcFormula = Sum("Magento Payment Line".Amount WHERE ("Document Table No."=CONST(112),
                                                                   "Document No."=FIELD("No.")));
            Caption = 'Payment Amount';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151405;"External Order No.";Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.00';
        }
        field(6151415;"Payment No.";Text[50])
        {
            Caption = 'Payment No.';
            Description = 'MAG2.00';
        }
    }
}

