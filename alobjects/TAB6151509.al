table 6151509 "Nc Unique Task Buffer"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - Buffer Table for checking Unique Task

    Caption = 'Nc Unique Task Buffer';

    fields
    {
        field(1;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(5;"Task Processor Code";Code[20])
        {
            Caption = 'Task Processor Code';
            Editable = false;
            TableRelation = "Nc Task Processor";
        }
        field(10;"Record Position";Text[250])
        {
            Caption = 'Record Position';
        }
        field(15;"Codeunit ID";Integer)
        {
            Caption = 'Codeunit ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(20;"Processing Code";Code[20])
        {
            Caption = 'Processing Code';
        }
    }

    keys
    {
        key(Key1;"Table No.","Task Processor Code","Record Position","Codeunit ID","Processing Code")
        {
        }
    }

    fieldgroups
    {
    }
}

