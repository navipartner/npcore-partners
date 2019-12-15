table 6151508 "Nc Task Output"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - Multi Output per Nc Task

    Caption = 'Nc Task Output';
    DrillDownPageID = "Nc Task Output List";
    LookupPageID = "Nc Task Output List";

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Task Entry No.";BigInteger)
        {
            Caption = 'Task Entry No.';
            TableRelation = "Nc Task";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10;Data;BLOB)
        {
            Caption = 'Data';
        }
        field(15;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(20;"Last Modified at";DateTime)
        {
            Caption = 'Last Modified at';
        }
        field(25;"Process Count";Integer)
        {
            Caption = 'Process Count';
            Editable = false;
        }
        field(30;Response;BLOB)
        {
            Caption = 'Response';
        }
        field(1000;"Task Exists";Boolean)
        {
            CalcFormula = Exist("Nc Task" WHERE ("Entry No."=FIELD("Task Entry No.")));
            Caption = 'Task Exists';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        NcTask: Record "Nc Task";
    begin
        "Last Modified at" := CurrentDateTime;
        if "Process Count" = 0 then begin
          NcTask.Get("Task Entry No.");
          "Process Count" := NcTask."Process Count";
        end;
    end;

    trigger OnModify()
    begin
        "Last Modified at" := CurrentDateTime;
    end;
}

