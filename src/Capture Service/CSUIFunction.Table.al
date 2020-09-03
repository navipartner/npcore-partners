table 6151376 "NPR CS UI Function"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS UI Function';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "UI Code"; Code[20])
        {
            Caption = 'UI Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR CS UI Header".Code;
        }
        field(2; "Function Code"; Code[20])
        {
            Caption = 'Function Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR CS UI Function Group".Code;
        }
    }

    keys
    {
        key(Key1; "UI Code", "Function Code")
        {
        }
    }

    fieldgroups
    {
    }
}

