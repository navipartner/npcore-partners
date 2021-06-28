table 6059905 "NPR Task Output Log"
{
    // TQ1.09/LS/20140730 CASE 188358 : Added Fx AddDescription
    // TQ1.17/JDH/20141015 CASE 179044 Possible to stores descriptions of up to 1024 characters
    // TQ1.21/JDH/20141219 CASE 202183 Added keys for deleting entries + performance on calculating the numbers from the Task Line
    // TQ1.28/RMT/20150807 CASE 219795 "Entry No." set to Autoincrement = YES and insert code changed acordingly
    // TQ1.29/JDH /20161101 CASE 242044 Added InitRecord function + AppendFile Function

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
                Text: Text[1024];
            begin
                //-TQ1.17
                CalcFields(File);
                if File.HasValue() then begin
                    File.CreateInStream(InStream);
                    InStream.ReadText(Text);
                    Message(Text);
                end;
                //+TQ1.17
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

    procedure AddFile(TaskLine: Record "NPR Task Line"; FileName: Text[250])
    var
        IStream: InStream;
    begin
        if not Exists(FileName) then
            exit;

        //-TQ1.29
        //-TQ1.28
        //LOCKTABLE;
        //IF FINDLAST THEN;
        //+TQ1.28
        //Init();
        //-TQ1.28
        //"Entry No." := "Entry No." + 1;
        //"Entry No." := 0;
        //+TQ1.28
        //"Journal Template Name" := TaskLine."Journal Template Name";
        //"Journal Batch Name" := TaskLine."Journal Batch Name";
        //"Journal Line No." := TaskLine."Line No.";
        //"Import DateTime" := CURRENTDATETIME;
        //"File Name" := FileName;
        //"Task Log Entry No." := TaskQueueAdd2Log.GetCurrentLogEntryNo;
        InitRecord(TaskLine);
        "File Name" := FileName;
        //+TQ1.29
        Rec.File.CreateInStream(IStream);
        IStream.Read(FileName);
        //File.IMPORT(FileName, FALSE);
        Insert();
    end;

    procedure InitRecord(TaskLine: Record "NPR Task Line")
    var
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
    begin
        //-TQ1.29
        Init();
        "Entry No." := 0;
        "Journal Template Name" := TaskLine."Journal Template Name";
        "Journal Batch Name" := TaskLine."Journal Batch Name";
        "Journal Line No." := TaskLine."Line No.";
        "Import DateTime" := CurrentDateTime;
        "Task Log Entry No." := TaskQueueAdd2Log.GetCurrentLogEntryNo();
        //+TQ1.29
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
        //-TQ1.29
        "Task Log Entry No." := TaskQueueAdd2Log.GetCurrentLogEntryNo();
        //+TQ1.29
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

