table 6150709 ".NET Dependency Map"
{
    Caption = '.NET Dependency Map';
    DrillDownPageID = "POS Action Parameters";
    LookupPageID = "POS Action Parameters";

    fields
    {
        field(1;"Type Name";Text[250])
        {
            Caption = 'Type Name';
        }
        field(2;"Instantiate From Assembly Name";Text[250])
        {
            Caption = 'Instantiate From Assembly Name';
        }
        field(3;"Instantiate From Type Name";Text[250])
        {
            Caption = 'Instantiate From Type Name';
        }
    }

    keys
    {
        key(Key1;"Type Name")
        {
        }
    }

    fieldgroups
    {
    }
}

