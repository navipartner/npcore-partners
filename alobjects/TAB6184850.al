table 6184850 "FR Audit Setup"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.51/MMV /20190611 CASE 356076 Added field 35, 60

    Caption = 'FR Audit Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Certification No.";Text[30])
        {
            Caption = 'Certification No.';
        }
        field(3;"Certification Category";Text[30])
        {
            Caption = 'Certification Category';
        }
        field(4;"Signing Certificate";BLOB)
        {
            Caption = 'Signing Certificate';
        }
        field(5;"Signing Certificate Password";Text[250])
        {
            Caption = 'Signing Certificate Password';
            ExtendedDatatype = Masked;
        }
        field(6;"Signing Certificate Thumbprint";Text[250])
        {
            Caption = 'Signing Certificate Thumbprint';
        }
        field(30;"Monthly Workshift Duration";DateFormula)
        {
            Caption = 'Monthly Workshift Duration';
        }
        field(35;"Yearly Workshift Duration";DateFormula)
        {
            Caption = 'Yearly Workshift Duration';
        }
        field(40;"Last Auto Archived Workshift";Integer)
        {
            Caption = 'Last Auto Archived Workshift';
        }
        field(50;"Auto Archive URL";Text[250])
        {
            Caption = 'Auto Archive URL';
        }
        field(51;"Auto Archive API Key";Text[250])
        {
            Caption = 'Auto Archive API Key';
            ExtendedDatatype = Masked;
        }
        field(52;"Auto Archive SAS";Text[250])
        {
            Caption = 'Auto Archive SAS';
        }
        field(60;"Item VAT Identifier Filter";Text[250])
        {
            Caption = 'Item VAT Identifier Filter';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

