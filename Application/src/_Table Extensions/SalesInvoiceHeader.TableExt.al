tableextension 6014405 "NPR Sales Invoice Header" extends "Sales Invoice Header"
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
    // NPR5.53/MHA /20191211 CASE 380837 Added fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    // NPR5.54/MHA /20200311  CASE 390380 Disabled fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No.".
    //                                    Can be removed in the next release.
    fields
    {
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
        }
        field(6014414; "NPR Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            Description = 'PN1.00';
            DataClassification = CustomerContent;
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
            DataClassification = CustomerContent;
        }
        field(6014420; "NPR Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            Description = 'PS1.00';
            DataClassification = CustomerContent;
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
            DataClassification = CustomerContent;
        }
        field(6014450; "NPR Kolli"; Integer)
        {
            Caption = 'Number of packages';
            Description = 'NPR7.100.000';
            InitValue = 1;
            DataClassification = CustomerContent;
        }
        field(6014451; "NPR Ship. Agent Serv. Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            Description = 'NPR7.100.000';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
            DataClassification = CustomerContent;
        }
        field(6014470; "NPR Pacsoft Ship. Not Created"; Boolean)
        {
            Caption = 'Pacsoft Shipment Not Created';
            Description = 'PS1.01';
            DataClassification = CustomerContent;
        }
        field(6059931; "NPR Doc. Exch. Fr.work Status"; Option)
        {
            Caption = 'Doc. Exch. Framework Status';
            Description = 'NPR5.26';
            OptionCaption = ' ,Exported to Folder,Setup Changed,Delivered to Recepient,File Validation Error';
            OptionMembers = " ","Exported to Folder","Setup Changed","Delivered to Recepient","File Validation Error";
            DataClassification = CustomerContent;
        }
        field(6059932; "NPR Doc. Exch. Exported"; Boolean)
        {
            Caption = 'Doc. Exch. Exported';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(6059933; "NPR Doc. Exch. Setup Path Used"; RecordID)
        {
            Caption = 'Doc. Exch. Setup Path Used';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(6059934; "NPR Doc. Exch. Export. to"; Text[250])
        {
            Caption = 'Doc. Exch. Exported to';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(6059935; "NPR Doc. Exch. File Exists"; Boolean)
        {
            Caption = 'Doc. Exch. File Exists';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(6151300; "NPR NpEc Store Code"; Code[20])
        {
            Caption = 'NpEc Store Code';
            Description = 'NPR5.53,NPR5.54';
            Enabled = false;
            DataClassification = CustomerContent;
        }
        field(6151305; "NPR NpEc Document No."; Code[50])
        {
            Caption = 'NpEc Document No.';
            Description = 'NPR5.53,NPR5.54';
            Enabled = false;
            DataClassification = CustomerContent;
        }
        field(6151400; "NPR Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Magento Payment Line".Amount WHERE("Document Table No." = CONST(112),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.00';
            DataClassification = CustomerContent;
        }
        field(6151415; "NPR Payment No."; Text[50])
        {
            Caption = 'Payment No.';
            Description = 'MAG2.00';
            DataClassification = CustomerContent;
        }

        field(6151420; "NPR Magento Coupon"; Text[20])
        {
            Caption = 'Magento Coupon';
            DataClassification = CustomerContent;
        }
    }
}

