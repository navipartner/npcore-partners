table 6059812 "NPR RS Allowed Tax Rates"
{
    Access = Internal;
    Caption = 'RS Allowed Tax Rates';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS Allowed Tax Rates List";
    LookupPageId = "NPR RS Allowed Tax Rates List";

    fields
    {
        field(1; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(2; "Valid From Time"; Time)
        {
            Caption = 'Valid From Time';
            DataClassification = CustomerContent;
        }
        field(3; "Group ID"; Integer)
        {
            Caption = 'Group ID';
            DataClassification = CustomerContent;
        }
        field(10; "Tax Category Name"; Text[20])
        {
            Caption = 'Tax Category Name';
            DataClassification = CustomerContent;
        }
        field(11; "Tax Category Type"; Integer)
        {
            Caption = 'Tax Category Type';
            DataClassification = CustomerContent;
        }
        field(12; "Tax Category Rate"; Decimal)
        {
            Caption = 'Tax Category Rate';
            DataClassification = CustomerContent;
        }
        field(13; "Tax Category Rate Label"; Text[5])
        {
            Caption = 'Tax Category Rate Label';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tax Category Name", "Tax Category Rate Label")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Tax Category Name", "Tax Category Rate", "Tax Category Rate Label")
        {
        }
    }
}