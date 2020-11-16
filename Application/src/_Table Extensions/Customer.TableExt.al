tableextension 6014423 "NPR Customer" extends Customer
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                           Added Fields : 6014400..6060150
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting.
    // NPR70.00.02.00/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // MAG1.04/MH/20150216  CASE 199932 Added field 6059800 "External Customer No."
    // MAG1.08/MH/20150311  CASE 206395 Added Field 6059825 "Webshop Display Group"
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.48/TSA /20181219 CASE 320424 Added Fields "Magento Shipping Group", "Magento Payment Group", "Magento Store Code"
    // MAG2.20/MHA /20190426 CASE 320423 Added Validation and Lookup to Fields "Magento Display Group", "Magento Shipping Group", "Magento Payment Group"
    // NPR5.52/ZESO/20190925 CASE 358656 Added Fields Anonymized,Anonymized Date and To Anonymize
    // NPR5.53/ZESO/20200115 CASE 358656 Added Field To Anonymize On
    fields
    {
        field(6014400; "NPR Type"; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Cash';
            OptionMembers = Customer,Cash;
        }
        field(6014402; "NPR Internal y/n"; Boolean)
        {
            Caption = 'Internal';
            DataClassification = CustomerContent;
        }
        field(6014403; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
        }
        field(6014404; "NPR Record on Debitsale"; Option)
        {
            Caption = 'Record on Debitsale';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Invoice,Shipping Note,Ask';
            OptionMembers = " ",Invoice,"Shipping Note",Ask;
        }
        field(6014405; "NPR Record on neg. Debitsale"; Option)
        {
            Caption = 'Record on negative Debitsale';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Return Order,Credit Memo,Ask';
            OptionMembers = " ","Return Order","Credit Memo",Ask;
        }
        field(6014407; "NPR Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
        }
        field(6014408; "NPR Sales invoice Report No."; Integer)
        {
            Caption = 'Sales invoice Report No.';
            DataClassification = CustomerContent;
        }
        field(6014409; "NPR Change-to No."; Code[20])
        {
            Caption = 'Change-to No.';
            DataClassification = CustomerContent;
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014416; "NPR Bill-to Company"; Text[30])
        {
            Caption = 'Bill-to Company (IC)';
            DataClassification = CustomerContent;
        }
        field(6014417; "NPR Bill-to Vendor No."; Code[20])
        {
            Caption = 'Bill-to Vendor No. (IC)';
            DataClassification = CustomerContent;
        }
        field(6059771; "NPR Loyalty Customer"; Boolean)
        {
            Caption = 'Loyalty Customer';
            DataClassification = CustomerContent;
        }
        field(6151060; "NPR Anonymized"; Boolean)
        {
            Caption = 'Anonymized';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            Editable = false;
        }
        field(6151061; "NPR Anonymized Date"; DateTime)
        {
            Caption = 'Anonymized Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            Editable = false;
        }
        field(6151062; "NPR To Anonymize"; Boolean)
        {
            Caption = 'To Anomymize';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
        field(6151063; "NPR To Anonymize On"; Date)
        {
            Caption = 'To Anonymize On';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(6151450; "NPR External Customer No."; Code[20])
        {
            Caption = 'External Customer No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151455; "NPR Magento Display Group"; Code[20])
        {
            Caption = 'Magento Display Group';
            DataClassification = CustomerContent;
            Description = 'MAG2.00,MAG2.20';
            TableRelation = "NPR Magento Display Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupDisplayGroup(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidateDisplayGroup(Rec);
                //+MAG2.20 [320423]
            end;
        }
        field(6151460; "NPR Magento Shipping Group"; Text[30])
        {
            Caption = 'Magento Shipping Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48,MAG2.20';

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupShippingGroup(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidateShippingGroup(Rec);
                //+MAG2.20 [320423]
            end;
        }
        field(6151465; "NPR Magento Payment Group"; Text[30])
        {
            Caption = 'Magento Payment Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48,MAG2.20';

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupPaymentGroup(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidatePaymentGroup(Rec);
                //+MAG2.20 [320423]
            end;
        }
        field(6151470; "NPR Magento Store Code"; Text[30])
        {
            Caption = 'Magento Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48,MAG2.20';
            TableRelation = "NPR Magento Store";

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupMagentoStore(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidateMagentoStore(Rec);
                //+MAG2.20 [320423]
            end;
        }
    }
}

