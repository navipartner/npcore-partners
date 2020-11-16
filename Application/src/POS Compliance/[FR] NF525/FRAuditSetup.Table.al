table 6184850 "NPR FR Audit Setup"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.51/MMV /20190611 CASE 356076 Added field 35, 60

    Caption = 'FR Audit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Certification No."; Text[30])
        {
            Caption = 'Certification No.';
            DataClassification = CustomerContent;
        }
        field(3; "Certification Category"; Text[30])
        {
            Caption = 'Certification Category';
            DataClassification = CustomerContent;
        }
        field(4; "Signing Certificate"; BLOB)
        {
            Caption = 'Signing Certificate';
            DataClassification = CustomerContent;
        }
        field(5; "Signing Certificate Password"; Text[250])
        {
            Caption = 'Signing Certificate Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(6; "Signing Certificate Thumbprint"; Text[250])
        {
            Caption = 'Signing Certificate Thumbprint';
            DataClassification = CustomerContent;
        }
        field(30; "Monthly Workshift Duration"; DateFormula)
        {
            Caption = 'Monthly Workshift Duration';
            DataClassification = CustomerContent;
        }
        field(35; "Yearly Workshift Duration"; DateFormula)
        {
            Caption = 'Yearly Workshift Duration';
            DataClassification = CustomerContent;
        }
        field(40; "Last Auto Archived Workshift"; Integer)
        {
            Caption = 'Last Auto Archived Workshift';
            DataClassification = CustomerContent;
        }
        field(50; "Auto Archive URL"; Text[250])
        {
            Caption = 'Auto Archive URL';
            DataClassification = CustomerContent;
        }
        field(51; "Auto Archive API Key"; Text[250])
        {
            Caption = 'Auto Archive API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(52; "Auto Archive SAS"; Text[250])
        {
            Caption = 'Auto Archive SAS';
            DataClassification = CustomerContent;
        }
        field(60; "Item VAT Identifier Filter"; Text[250])
        {
            Caption = 'Item VAT Identifier Filter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

