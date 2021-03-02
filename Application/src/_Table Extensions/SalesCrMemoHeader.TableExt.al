tableextension 6014407 "NPR Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Field 6014400
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //                     - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV.
    //                     - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting.
    // MAG1.01/MH/20150201  CASE 204133 Added Field 6059800 "External Customer No."
    // NPR4.14/RMT/20150826 CASE 216519 Added field 6014425 "Order Type"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR5.33/BR /20170420 CASE 266527 Added new fields for Document Exchange Framework integration: 6059931..6059935
    // NPR5.39/BHR/20181202 CASE 305071 Change field size of field 6014400 (Sales Ticket No.) from 10 to 20
    // MAG2.12/MHA /20180425  CASE 309647 Added fields 6151400 "Magento Payment Amount",6151405 "External Order No."
    // NPR5.53/MHA /20191211  CASE 380837 Added fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    // NPR5.54/MHA /20200311  CASE 390380 Removed fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Document Sending Profile from Customer is used.';
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
            DataClassification = CustomerContent;
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
            DataClassification = CustomerContent;
        }
        field(6059931; "NPR Doc.Exch. F.work Status"; Option)
        {
            Caption = 'Doc. Exch. Framework Status';
            Description = 'NPR5.33';
            OptionCaption = ' ,Exported to Folder,Setup Changed,Delivered to Recepient,File Validation Error';
            OptionMembers = " ","Exported to Folder","Setup Changed","Delivered to Recepient","File Validation Error";
            DataClassification = CustomerContent;
        }
        field(6059932; "NPR Doc. Exch. Exported"; Boolean)
        {
            Caption = 'Doc. Exch. Exported';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
        }
        field(6059933; "NPR Doc.Exch.Setup Path Used"; RecordID)
        {
            Caption = 'Doc. Exch. Setup Path Used';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
        }
        field(6059934; "NPR Doc. Exch. Exported to"; Text[250])
        {
            Caption = 'Doc. Exch. Exported to';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
        }
        field(6059935; "NPR Doc. Exch. File Exists"; Boolean)
        {
            Caption = 'Doc. Exch. File Exists';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
        }
        field(6151400; "NPR Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum ("NPR Magento Payment Line".Amount WHERE("Document Table No." = CONST(114),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Description = 'MAG2.12';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.12';
            DataClassification = CustomerContent;
        }

        field(6151420; "NPR Magento Coupon"; Text[20])
        {
            Caption = 'Magento Coupon';
            DataClassification = CustomerContent;           
        }
    }
}

