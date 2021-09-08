table 6059905 "NPR Task Output Log"
{

    Caption = 'Task Output Log';
    DrillDownPageID = "NPR Task Output Log";
    LookupPageID = "NPR Task Output Log";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Task Log Entry No."; Integer)
        {
            Caption = 'Task Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "NPR Task Template";
            DataClassification = CustomerContent;
        }
        field(11; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "NPR Task Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
            DataClassification = CustomerContent;
        }
        field(12; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "File"; BLOB)
        {
            Caption = 'File';
            DataClassification = CustomerContent;
        }
        field(21; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(30; "Import DateTime"; DateTime)
        {
            Caption = 'Import DateTime';
            DataClassification = CustomerContent;
        }
        field(40; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                InStream: InStream;
                Text: Text;
            begin
                CalcFields(File);
                if File.HasValue() then begin
                    File.CreateInStream(InStream);
                    InStream.ReadText(Text);
                    Message(Text);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Task Log Entry No.")
        {
        }
        key(Key3; "Journal Template Name", "Journal Batch Name", "Journal Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure InitRecord(TaskLine: Record "NPR Task Line")
    var
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
    begin
        Init();
        "Entry No." := 0;
        "Journal Template Name" := TaskLine."Journal Template Name";
        "Journal Batch Name" := TaskLine."Journal Batch Name";
        "Journal Line No." := TaskLine."Line No.";
        "Import DateTime" := CurrentDateTime;
        "Task Log Entry No." := TaskQueueAdd2Log.GetCurrentLogEntryNo();
    end;

    procedure AddDescription(TaskLine: Record "NPR Task Line"; MessageText: Text[1024])
    var
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
        TMPText: Text[1024];
        OutStream: OutStream;
    begin
        if MessageText = '' then
            exit;

        Init();
        "Entry No." := 0;
        "Journal Template Name" := TaskLine."Journal Template Name";
        "Journal Batch Name" := TaskLine."Journal Batch Name";
        "Journal Line No." := TaskLine."Line No.";
        "Import DateTime" := CurrentDateTime;
        TMPText := ConvertCarrigeReturn(MessageText);
        File.CreateOutStream(OutStream);
        OutStream.WriteText(TMPText);
        Description := CopyStr(TMPText, 1, MaxStrLen(Description));
        "Task Log Entry No." := TaskQueueAdd2Log.GetCurrentLogEntryNo();
        Insert();
    end;

    local procedure ConvertCarrigeReturn(ErrorString: Text[1024]): Text[1024]
    var
        CR: Char;
        LF: Char;
    begin
        CR := 13;
        LF := 10;
        exit(ConvertStr(ErrorString, Format(CR) + Format(LF), '\\'));
    end;

}

