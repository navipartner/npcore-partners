table 6151181 "Retail Cross Reference Setup"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created

    Caption = 'Retail Cross Reference Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "Retail Cross Reference Setup";
    LookupPageID = "Retail Cross Reference Setup";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(5; "Reference No. Pattern"; Code[50])
        {
            Caption = 'Reference No. Pattern';
            DataClassification = CustomerContent;
        }
        field(10; "Pattern Guide"; Text[250])
        {
            Caption = 'Pattern Guide';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
        }
    }

    fieldgroups
    {
    }
}

