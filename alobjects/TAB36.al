tableextension 6014432 tableextension6014432 extends "Sales Header"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                         Added fields : 6014400..6060009
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //                     - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV
    //                     - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting
    // MAG1.01/MH/20150201   CASE 204133 Added Field 6059800 "External Customer No.".
    // PS1.00/LS/20141201    CASE 200150 : Field 6014420 to be used for pacsoft
    // MAG1.02/HSK/20150202  CASE 201683 Add/Update NaviConnect Order Status
    // MAG1.03/MH/20150205   CASE 199932 Renamed field 6059795 from "Payment Line Amount" to "NaviConnect Payment Amount"
    // NPR4.14/RMT/20150826  CASE 216519 Added field 6014425 "Order Type"
    // PN1.08/MHA/20151214   CASE 228859 Pdf2Nav (New Version List)
    // NPR5.22/TJ/20160406   CASE 238572 Moving custom code from standard places to a subscriber codeunit
    // MAG1.22/MHA/20160427  CASE 240257 MagentoHooks removed and converted to EventSubscriber: OnInsert() and OnDelete()
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.34/BHR/20170720  CASE 283061 Cleared property MinValue of  field Kolli
    // NPR5.36/BHR/20170919  CASE 290780 Field Delivery Instructions for Pakkelabels
    // NPR5.39/THRO/20180222 CASE 304256 Moved code on OnAfterValidate "Bill-to Customer No." to subscriber
    // NPR5.43/BHR /20180615 CASE 318441 Rename field from 6014451 to 6014452
    // NPR5.53/MHA /20191211 CASE 380837 Added fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    // NPR5.54/MHA /20200311  CASE 390380 Removed fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    fields
    {
        field(6014400; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014401; "Buy-From Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014402; "Sale Total"; Decimal)
        {
            CalcFormula = Sum ("Sales Line"."Outstanding Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                       "Document No." = FIELD("No.")));
            Caption = 'Sale Total';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014406; "Document Time"; Time)
        {
            Caption = 'Document Time';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014407; "Bill-to Company"; Text[30])
        {
            Caption = 'Bill-to Company (IC)';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = Company;
        }
        field(6014408; "Bill-To Vendor No."; Code[10])
        {
            Caption = 'Bill-to Vendor No. (IC)';
            DataClassification = CustomerContent;
        }
        field(6014414; "Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
        }
        field(6014415; "Document Processing"; Option)
        {
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014420; "Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
        }
        field(6014425; "Order Type"; Option)
        {
            Caption = 'Order Type';
            DataClassification = CustomerContent;
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
        }
        field(6014450; Kolli; Integer)
        {
            Caption = 'Number of packages';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            InitValue = 1;
        }
        field(6014452; "Delivery Instructions"; Text[50])
        {
            Caption = 'Delivery Instructions';
            DataClassification = CustomerContent;
        }
        field(6151400; "Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum ("Magento Payment Line".Amount WHERE("Document Table No." = CONST(36),
                                                                   "Document Type" = FIELD("Document Type"),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151405; "External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151415; "Payment No."; Text[50])
        {
            Caption = 'Payment No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
    }
}

