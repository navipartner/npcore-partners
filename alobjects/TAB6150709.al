table 6150709 ".NET Dependency Map"
{
    Caption = '.NET Dependency Map';
    DataClassification = CustomerContent;
    DrillDownPageID = "POS Action Parameters";
    LookupPageID = "POS Action Parameters";

    fields
    {
        field(1; "Type Name"; Text[250])
        {
            Caption = 'Type Name';
            DataClassification = CustomerContent;
        }
        field(2; "Instantiate From Assembly Name"; Text[250])
        {
            Caption = 'Instantiate From Assembly Name';
            DataClassification = CustomerContent;
        }
        field(3; "Instantiate From Type Name"; Text[250])
        {
            Caption = 'Instantiate From Type Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Type Name")
        {
        }
    }

    fieldgroups
    {
    }
}

