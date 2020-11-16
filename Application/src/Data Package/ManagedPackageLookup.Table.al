table 6014598 "NPR Managed Package Lookup"
{
    // NPR5.26/MMV /20160915 Created table for temp use.
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions

    Caption = 'Managed Package Lookup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Index; Integer)
        {
            Caption = 'Index';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Version; Text[30])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; Status; Text[50])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(6; Tags; Text[250])
        {
            Caption = 'Tags';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Index)
        {
        }
    }

    fieldgroups
    {
    }
}

