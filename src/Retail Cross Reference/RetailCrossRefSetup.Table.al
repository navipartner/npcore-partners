table 6151181 "NPR Retail Cross Ref. Setup"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created

    Caption = 'Retail Cross Reference Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Retail Cross Ref. Setup";
    LookupPageID = "NPR Retail Cross Ref. Setup";

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

