table 6151503 "NPR Nc Task Field"
{
    Caption = 'Nc Task Field';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(3; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(4; "Previous Value"; Text[250])
        {
            Caption = 'Previous Value';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(5; "New Value"; Text[250])
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(6; "Log Date"; DateTime)
        {
            Caption = 'Log Date';
            DataClassification = CustomerContent;
        }
        field(10; "Task Entry No."; BigInteger)
        {
            Caption = 'Task Entry No.';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
            TableRelation = "NPR Nc Task";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(1000; "Task Exists"; Boolean)
        {
            CalcFormula = Exist("NPR Nc Task" WHERE("Entry No." = FIELD("Task Entry No.")));
            Caption = 'Task Exists';
            Description = 'NC2.05';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Log Date")
        {
        }
        key(Key3; "Task Entry No.")
        {
        }
    }
}

