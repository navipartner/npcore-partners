table 6151509 "NPR Nc Unique Task Buffer"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - Buffer Table for checking Unique Task

    Caption = 'Nc Unique Task Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(5; "Task Processor Code"; Code[20])
        {
            Caption = 'Task Processor Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR Nc Task Processor";
        }
        field(10; "Record Position"; Text[250])
        {
            Caption = 'Record Position';
            DataClassification = CustomerContent;
        }
        field(15; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(20; "Processing Code"; Code[20])
        {
            Caption = 'Processing Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Task Processor Code", "Record Position", "Codeunit ID", "Processing Code")
        {
        }
    }

    fieldgroups
    {
    }
}

