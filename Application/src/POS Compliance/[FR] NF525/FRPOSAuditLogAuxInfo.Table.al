table 6184852 "NPR FR POS Audit Log Aux. Info"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object

    Caption = 'FR POS Audit Log Aux. Info';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(2; "NPR Version"; Text[250])
        {
            Caption = 'NPR Version';
            DataClassification = CustomerContent;
        }
        field(3; "Store Name"; Text[50])
        {
            Caption = 'Store Name';
            DataClassification = CustomerContent;
        }
        field(4; "Store Name 2"; Text[50])
        {
            Caption = 'Store Name 2';
            DataClassification = CustomerContent;
        }
        field(5; "Store Address"; Text[50])
        {
            Caption = 'Store Address';
            DataClassification = CustomerContent;
        }
        field(6; "Store Address 2"; Text[50])
        {
            Caption = 'Store Address 2';
            DataClassification = CustomerContent;
        }
        field(7; "Store Post Code"; Code[20])
        {
            Caption = 'Store Post Code';
            DataClassification = CustomerContent;
        }
        field(8; "Store City"; Text[30])
        {
            Caption = 'Store City';
            DataClassification = CustomerContent;
        }
        field(9; "Store Siret"; Text[20])
        {
            Caption = 'Store Siret';
            DataClassification = CustomerContent;
        }
        field(10; APE; Code[10])
        {
            Caption = 'APE';
            DataClassification = CustomerContent;
        }
        field(11; "Intra-comm. VAT ID"; Text[20])
        {
            Caption = 'Intra-comm. VAT ID';
            DataClassification = CustomerContent;
        }
        field(12; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            DataClassification = CustomerContent;
        }
        field(13; "Store Country/Region Code"; Code[10])
        {
            Caption = 'Store Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
    }

    keys
    {
        key(Key1; "POS Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

