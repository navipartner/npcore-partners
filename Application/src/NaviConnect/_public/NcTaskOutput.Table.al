﻿table 6151508 "NPR Nc Task Output"
{
    Access = Public;
    Caption = 'Nc Task Output';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Task Output List";
    LookupPageID = "NPR Nc Task Output List";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Task Entry No."; BigInteger)
        {
            Caption = 'Task Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task";

            ValidateTableRelation = false;
        }
        field(10; Data; BLOB)
        {
            Caption = 'Data';
            DataClassification = CustomerContent;
        }
        field(15; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(20; "Last Modified at"; DateTime)
        {
            Caption = 'Last Modified at';
            DataClassification = CustomerContent;
        }
        field(25; "Process Count"; Integer)
        {
            Caption = 'Process Count';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; Response; BLOB)
        {
            Caption = 'Response';
            DataClassification = CustomerContent;
        }
        field(200; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(210; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = " ",Success,Error;
            OptionCaption = ' ,Success,Error';
            DataClassification = CustomerContent;
        }
        field(220; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(1000; "Task Exists"; Boolean)
        {
            CalcFormula = Exist("NPR Nc Task" WHERE("Entry No." = FIELD("Task Entry No.")));
            Caption = 'Task Exists';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
        NcTask: Record "NPR Nc Task";
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

