tableextension 6014437 "NPR Contact" extends Contact
{
    fields
    {
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
        field(6151400; "NPR Magento Contact"; Boolean)
        {
            Caption = 'Magento Contact';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151405; "NPR Magento Password"; Text[80])
        {
            Caption = 'Magento Password';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151410; "NPR Magento Password (Md5)"; Text[80])
        {
            Caption = 'Magento Password (Encrypted)';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151420; "NPR Magento Customer Group"; Text[30])
        {
            Caption = 'Magento Customer Group';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            TableRelation = "NPR Magento Customer Group";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.LookupCustomerGroup(Rec);
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.ValidateCustomerGroup(Rec);
            end;
        }
        field(6151425; "NPR Magento Payment Methods"; Integer)
        {
            CalcFormula = Count("NPR Magento Contact Pmt.Meth." WHERE("Contact No." = FIELD("No.")));
            Caption = 'Magento Payment Methods';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151430; "NPR Magento Shipment Methods"; Integer)
        {
            CalcFormula = Count("NPR Magento Contact Shpt.Meth." WHERE("Contact No." = FIELD("No.")));
            Caption = 'Magento Shipment Methods';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151435; "NPR Magento Account Status"; Option)
        {
            Caption = 'Magento Account Status';
            DataClassification = CustomerContent;
            Description = '//-NPR5.48 [320424]';
            OptionCaption = 'Active,Blocked,Checkout Blocked';
            OptionMembers = ACTIVE,BLOCKED,CHECKOUT_BLOCKED;
        }
        field(6151440; "NPR Magento Price Visibility"; Option)
        {
            Caption = 'Magento Price Visibility';
            DataClassification = CustomerContent;
            Description = '//-NPR5.48 [320424]';
            OptionCaption = 'Visible,Hidden';
            OptionMembers = VISIBLE,HIDDEN;
        }
    }
}

