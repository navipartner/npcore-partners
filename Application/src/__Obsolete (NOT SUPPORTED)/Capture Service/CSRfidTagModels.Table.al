table 6151385 "NPR CS Rfid Tag Models"
{
    Access = Internal;

    Caption = 'CS Rfid Tag Models';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; Family; Code[10])
        {
            Caption = 'Family';
            DataClassification = CustomerContent;
        }
        field(2; Model; Code[10])
        {
            Caption = 'Model';
            DataClassification = CustomerContent;
        }
        field(10; Discontinued; Boolean)
        {
            Caption = 'Discontinue';
            DataClassification = CustomerContent;
        }
        field(11; "Tag Chip"; Code[10])
        {
            Caption = 'Tag Chip';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Family, Model)
        {
        }
    }

    fieldgroups
    {
    }
}

