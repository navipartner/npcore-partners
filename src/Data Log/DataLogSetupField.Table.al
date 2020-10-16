table 6059895 "NPR Data Log Setup (Field)"
{
    Caption = 'Data Log Setup (Ignored Field)';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = "NPR Data Log Setup (Table)";
            DataClassification = CustomerContent;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table ID"));
            DataClassification = CustomerContent;
        }
        field(3; "Field Caption"; Text[100])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table ID"), "No." = FIELD("Field No.")));
            Caption = 'Field Caption';
            FieldClass = FlowField;
        }
        field(5; "Ignore Modification"; Boolean)
        {
            Caption = 'Ignore Modification';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Field No.")
        {
            Clustered = true;
        }
    }
}