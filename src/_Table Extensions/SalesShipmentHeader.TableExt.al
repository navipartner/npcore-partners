tableextension 6014403 "NPR Sales Shipment Header" extends "Sales Shipment Header"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added fields 6014400..6014450
    // 
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //                     - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV
    //                     - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting
    // MAG1.01/MH/20150201  CASE 204133 Added Field 6059800 "External Customer No."
    // PS1.01/LS/20141201  CASE 200150 : Field 6014420 to be used for pacsoft
    // NPR4.14/RMT/20150826 Case 216519 Added field 6014425 "Order Type"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.34/BHR/20170720  CASE 283061 Cleared property MinValue of  field Kolli
    // NPR5.36/BHR/20170919  CASE 290780 Fiels Delivery Instructions for Pakkelabels
    // NPR5.43/BHR /20180615 CASE 318441 Rename field from 6014451 to 6014452
    // NPR5.53/MHA /20191211 CASE 380837 Added fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    // NPR5.54/MHA /20200311  CASE 390380 Removed fields 6151300 "NpEc Store Code", 6151305 "NpEc Document No."
    fields
    {
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
        }
        field(6014414; "NPR Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            Description = 'PN1.00';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014420; "NPR Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            Description = 'PS1.01';
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
        }
        field(6014450; "NPR Kolli"; Integer)
        {
            Caption = 'Number of packages';
            Description = 'NPR7.100.000';
            InitValue = 1;
        }
        field(6014452; "NPR Delivery Instructions"; Text[50])
        {
            Caption = 'Delivery Instructions';
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.00';
        }
    }
}

