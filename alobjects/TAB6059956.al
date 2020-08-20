table 6059956 "MCS Person Groups Setup"
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 1

    Caption = 'MCS Person Groups Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(11; "Person Groups Id"; Integer)
        {
            Caption = 'Person Groups Id';
            DataClassification = CustomerContent;
            TableRelation = "MCS Person Groups";
        }
        field(12; "Person Groups Name"; Text[128])
        {
            CalcFormula = Lookup ("MCS Person Groups".Name WHERE(Id = FIELD("Person Groups Id")));
            Caption = 'Person Groups Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Table Id")
        {
        }
    }

    fieldgroups
    {
    }
}

