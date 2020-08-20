tableextension 6014437 tableextension6014437 extends Contact
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014400..6060150
    // MAG1.05/MH/20150220  CASE 206395 Table modifications:
    //                                     - Deleted field 6060000 "Internet Number"
    //                                     - Deleted field 6060150 "Webshop Address ID"
    //                                     - Added field 6059810 "Webshop Administrator"
    //                                     - Added field 6059820 "Webshop Customer Group"
    //                                     - Renamed field 6060030 "Internet Customer" to "Webshop Contact"
    // MAG1.06/MH/20150224  CASE 206395 Added Magento Hooks
    // MAG1.07/MH/20150309  CASE 206395 Added Field 6059825 "Webshop Display Group"
    // MAG1.08/MH/20150311  CASE 206395 Removed Field 6059825 "Webshop Display Group"
    // MAG1.22/MHA/20160427 CASE 240257 Removed unused MagentoHooks OnInsert(), OnModify() and OnDelete()
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.26/MHA /20160922 CASE 253099 Removed Field 6014413 Balanced
    // NPR5.33/JDH /20170612 CASE 280329 Removed NPR Fields
    // NPR5.48/TSA /20181218 CASE 320424 Added Field 6151435 "Magento Account Status" and 6151440 "Magento Price Visibility"
    // MAG2.19/TSA /20190305 CASE 347894 Changed length of field 6151410 to 80
    // MAG2.20/MHA /20190426 CASE 320423 Added Validation and Lookup to Field "Magento Customer Group"
    // NPR5.52/ZESO/20190925 CASE 358656 Added Fields Anonymized and Anonymized Date
    fields
    {
        field(6151060; Anonymized; Boolean)
        {
            Caption = 'Anonymized';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            Editable = false;
        }
        field(6151061; "Anonymized Date"; DateTime)
        {
            Caption = 'Anonymized Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            Editable = false;
        }
        field(6151400; "Magento Contact"; Boolean)
        {
            Caption = 'Magento Contact';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151405; "Magento Password"; Text[80])
        {
            Caption = 'Magento Password';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151410; "Magento Password (Md5)"; Text[80])
        {
            Caption = 'Magento Password (Encrypted)';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151415; "Magento Administrator"; Boolean)
        {
            Caption = 'Magento Administrator';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151420; "Magento Customer Group"; Text[30])
        {
            Caption = 'Magento Customer Group';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            TableRelation = "Magento Customer Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.LookupCustomerGroup(Rec);
                //+MAG2.20 [320423]
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "M2 Account Lookup Mgt.";
            begin
                //-MAG2.20 [320423]
                M2AccountLookupMgt.ValidateCustomerGroup(Rec);
                //+MAG2.20 [320423]
            end;
        }
        field(6151425; "Magento Payment Methods"; Integer)
        {
            CalcFormula = Count ("Magento Contact Pmt. Method" WHERE("Contact No." = FIELD("No.")));
            Caption = 'Magento Payment Methods';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151430; "Magento Shipment Methods"; Integer)
        {
            CalcFormula = Count ("Magento Contact Shpt. Method" WHERE("Contact No." = FIELD("No.")));
            Caption = 'Magento Shipment Methods';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151435; "Magento Account Status"; Option)
        {
            Caption = 'Magento Account Status';
            DataClassification = CustomerContent;
            Description = '//-NPR5.48 [320424]';
            OptionCaption = 'Active,Blocked,Checkout Blocked';
            OptionMembers = ACTIVE,BLOCKED,CHECKOUT_BLOCKED;
        }
        field(6151440; "Magento Price Visibility"; Option)
        {
            Caption = 'Magento Price Visibility';
            DataClassification = CustomerContent;
            Description = '//-NPR5.48 [320424]';
            OptionCaption = 'Visible,Hidden';
            OptionMembers = VISIBLE,HIDDEN;
        }
    }
}

