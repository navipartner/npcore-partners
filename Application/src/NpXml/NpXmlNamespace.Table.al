table 6151561 "NPR NpXml Namespace"
{
    Access = Internal;
    Caption = 'NpXml Namespace';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            TableRelation = "NPR NpXml Template";

            ValidateTableRelation = false;
        }
        field(5; Alias; Text[50])
        {
            Caption = 'Alias';
            DataClassification = CustomerContent;
        }
        field(10; Namespace; Text[250])
        {
            Caption = 'Namespace';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Xml Template Code", Alias)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Alias, Namespace)
        {
        }
    }
}

