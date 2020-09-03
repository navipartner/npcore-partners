table 6060050 "NPR Missing Setup Record"
{
    // NPR4.19\BR\20160216  CASE 182391 Object Created
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj fields 120 , 100

    Caption = 'Missing Setup Record';
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
        field(30; Value; Text[100])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(40; "Related Table ID"; Integer)
        {
            Caption = 'Related Table ID';
            DataClassification = CustomerContent;
        }
        field(50; "Related Field No."; Integer)
        {
            Caption = 'Related Field No.';
            DataClassification = CustomerContent;
        }
        field(90; "Create New"; Boolean)
        {
            Caption = 'Create New';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(100; "Table Name"; Text[50])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Table ID"),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Related Table Name"; Text[50])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Related Table ID")));
            Caption = 'Related Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Related Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Related Table ID"),
                                                        "No." = FIELD("Related Field No.")));
            Caption = 'Related Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Field No.", Value)
        {
        }
    }

    fieldgroups
    {
    }
}

