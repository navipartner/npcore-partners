table 6151378 "NPR CS Field Defaults"
{

    Caption = 'CS Field Defaults';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';



    fields
    {
        field(1; Id; Code[10])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Use Case Code"; Code[20])
        {
            Caption = 'Use Case Code';
            DataClassification = CustomerContent;
        }
        field(3; "Field No"; Integer)
        {
            Caption = 'Field No';
            DataClassification = CustomerContent;
        }
        field(10; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id, "Use Case Code", "Field No")
        {
        }
    }

    fieldgroups
    {
    }
}

