table 6151442 "NPR Magento Contact ShipToAdr."
{
    Access = Internal;
    Caption = 'Magento Contact Ship-to Adrs.';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Customer;
        }
        field(2; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Customer No."));
        }
        field(3; "Created By Contact No."; Code[20])
        {
            Caption = 'Created By Contact No.';
            DataClassification = CustomerContent;
        }
        field(10; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(15; Visibility; Enum "NPR Mag. Contact ShToAdr. Vis.")
        {
            Caption = 'Visibility';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Ship-to Code", "Created By Contact No.")
        {
        }
        key(Key2; "Created By Contact No.")
        {
        }
    }
}
