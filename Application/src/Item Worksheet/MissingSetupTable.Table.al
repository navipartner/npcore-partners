table 6060049 "NPR Missing Setup Table"
{
    Access = Internal;
    Caption = 'Missing Setup Table';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(20; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(30; "No. of records"; Integer)
        {
            Caption = 'No. of records';
            DataClassification = CustomerContent;
        }
        field(40; "Create New"; Boolean)
        {
            Caption = 'Create New';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(50; "Related Table ID"; Integer)
        {
            Caption = 'Related Table ID';
            DataClassification = CustomerContent;
        }
        field(60; "Related Field No."; Integer)
        {
            Caption = 'Related Field No.';
            DataClassification = CustomerContent;
        }
        field(70; "Missing Records"; Integer)
        {
            CalcFormula = Count("NPR Missing Setup Record" WHERE("Table ID" = FIELD("Table ID"),
                                                              "Field No." = FIELD("Field No.")));
            Caption = 'Missing Records';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Field Name"; Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Table ID"),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Related Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Related Table ID")));
            Caption = 'Related Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Related Field Name"; Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Related Table ID"),
                                                        "No." = FIELD("Related Field No.")));
            Caption = 'Related Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Field No.")
        {
        }
    }
}

