tableextension 50024 tableextension50024 extends Customer 
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
    fields
    {
        field(6014400;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Cash';
            OptionMembers = Customer,Cash;
        }
        field(6014402;"Internal y/n";Boolean)
        {
            Caption = 'Internal';
        }
        field(6014403;Auto;Boolean)
        {
            Caption = 'Auto';
        }
        field(6014404;"Record on Debitsale";Option)
        {
            Caption = 'Record on Debitsale';
            OptionCaption = ' ,Invoice,Shipping Note,Ask';
            OptionMembers = " ",Invoice,"Shipping Note",Ask;
        }
        field(6014405;"Record on negative Debitsale";Option)
        {
            Caption = 'Record on negative Debitsale';
            OptionCaption = ' ,Return Order,Credit Memo,Ask';
            OptionMembers = " ","Return Order","Credit Memo",Ask;
        }
        field(6014407;"Primary Key Length";Integer)
        {
            Caption = 'Primary Key Length';
        }
        field(6014408;"Sales invoice Report No.";Integer)
        {
            Caption = 'Sales invoice Report No.';
        }
        field(6014409;"Change-to No.";Code[20])
        {
            Caption = 'Change-to No.';
        }
        field(6014415;"Document Processing";Option)
        {
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014416;"Bill-to Company";Text[30])
        {
            Caption = 'Bill-to Company (IC)';
        }
        field(6014417;"Bill-to Vendor No.";Code[20])
        {
            Caption = 'Bill-to Vendor No. (IC)';
        }
        field(6059771;"Loyalty Customer";Boolean)
        {
            Caption = 'Loyalty Customer';
        }
        field(6151450;"External Customer No.";Code[20])
        {
            Caption = 'External Customer No.';
            Description = 'MAG2.00';
        }
        field(6151455;"Magento Display Group";Code[20])
        {
            Caption = 'Magento Display Group';
            Description = 'MAG2.00,MAG2.20';
            TableRelation = "Magento Display Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupDisplayGroup(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidateDisplayGroup(Rec);
                //+MAG2.20 [320423]
            end;
        }
        field(6151460;"Magento Shipping Group";Text[30])
        {
            Caption = 'Magento Shipping Group';
            Description = 'NPR5.48,MAG2.20';

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupShippingGroup(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidateShippingGroup(Rec);
                //+MAG2.20 [320423]
            end;
        }
        field(6151465;"Magento Payment Group";Text[30])
        {
            Caption = 'Magento Payment Group';
            Description = 'NPR5.48,MAG2.20';

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupPaymentGroup(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidatePaymentGroup(Rec);
                //+MAG2.20 [320423]
            end;
        }
        field(6151470;"Magento Store Code";Text[30])
        {
            Caption = 'Magento Store Code';
            Description = 'NPR5.48,MAG2.20';
            TableRelation = "Magento Store";

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupMagentoStore(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidateMagentoStore(Rec);
                //+MAG2.20 [320423]
            end;
        }
    }
}

