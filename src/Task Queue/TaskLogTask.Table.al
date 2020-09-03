table 6059904 "NPR Task Log (Task)"
{
    // TQ1.17/JDH/20141015 CASE 179044 Added function to log a Message (must be used in relation to a commit, hence it locks the table)
    // TQ1.24/JDH/20150320 CASE 208247 Added Captions
    // TQ1.27/MH/20150727  CASE 219319 Added option 0 (#blank) to Option string of field 15 Status
    // TQ1.28/RMT/20150807 CASE 219795 "Entry No." set to Autoincrement = YES and insert code changed acordingly
    // TQ1.29/JDH /20161101 CASE 242044 Update "Task Duration" when done
    // TQ1.33/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 41

    Caption = 'Task Log';
    DrillDownPageID = "NPR Task Log (Task)";
    LookupPageID = "NPR Task Log (Task)";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "NPR Task Template";
        }
        field(3; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "NPR Task Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(9; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Task,Login,Logout,Change Company,Login Tread,Logout Tread';
            OptionMembers = Task,Login,Logout,ChangeComp,LoginTread,LogoutTread;
        }
        field(10; "Starting Time"; DateTime)
        {
            Caption = 'Starting Time';
        }
        field(11; "Ending Time"; DateTime)
        {
            Caption = 'Ending Time';
        }
        field(12; "Expected Ending Time"; DateTime)
        {
            Caption = 'Expected Ending Time';
        }
        field(13; "Task Duration"; Duration)
        {
            Caption = 'Task Duration';
        }
        field(15; Status; Option)
        {
            Caption = 'Status';
            Description = 'TQ1.27';
            OptionCaption = ',Started,Error,Succes,Message';
            OptionMembers = " ",Started,Error,Succes,Message;
        }
        field(16; "Last Error Message"; Text[250])
        {
            Caption = 'Last Error Message';

            trigger OnLookup()
            var
                Text: Text[1024];
                InStream: InStream;
            begin
                CalcFields("Last Error Message BLOB");
                if "Last Error Message BLOB".HasValue then begin
                    "Last Error Message BLOB".CreateInStream(InStream);
                    while not InStream.EOS do begin
                        InStream.ReadText(Text);
                        Message(Text);
                    end;
                end;
            end;
        }
        field(17; "Last Error Message BLOB"; BLOB)
        {
            Caption = 'Last Error Message BLOB';
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(21; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            TableRelation = "NPR Task Worker Group";
        }
        field(22; "Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
        }
        field(23; "Session ID"; Integer)
        {
            Caption = 'Session ID';
        }
        field(40; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = ' ,Report,Codeunit';
            OptionMembers = " ","Report","Codeunit";
        }
        field(41; "Object No."; Integer)
        {
            Caption = 'Object No.';
            TableRelation = IF ("Object Type" = CONST(Report)) AllObj."Object ID" WHERE("Object Type" = CONST(Report))
            ELSE
            IF ("Object Type" = CONST(Codeunit)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnValidate()
            var
                "Object": Record "Object";
            begin
            end;
        }
        field(42; "No. of Output Log Entries"; Integer)
        {
            CalcFormula = Count ("NPR Task Output Log" WHERE("Task Log Entry No." = FIELD("Entry No.")));
            Caption = 'No. of Output Log Entries';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
        Text001: Label 'Moved Execution Time due to invalid date / Time scheduling';

    procedure AddLogInit(TaskQueue: Record "NPR Task Queue"; TaskLine: Record "NPR Task Line") AddedEntryNo: Integer
    begin
        //-TQ1.28
        //TaskLog.LOCKTABLE;
        //IF TaskLog.FINDLAST THEN;
        //+TQ1.28

        Init;
        //-TQ1.28
        //"Entry No." := TaskLog."Entry No." + 1;
        "Entry No." := 0;
        //+TQ1.28
        "Journal Template Name" := TaskQueue."Task Template";
        "Journal Batch Name" := TaskQueue."Task Batch";
        "Line No." := TaskQueue."Task Line No.";
        "Entry Type" := "Entry Type"::Task;
        "Starting Time" := CurrentDateTime;
        Status := Status::Started;
        "User ID" := UserId;
        "Task Worker Group" := TaskQueue."Task Worker Group";
        "Object Type" := TaskLine."Object Type";
        "Object No." := TaskLine."Object No.";
        "Expected Ending Time" := "Starting Time" + TaskLine.GetExpectedDuration;
        "Server Instance ID" := ServiceInstanceId;
        "Session ID" := SessionId;

        Insert;
        //-TQ1.29
        TaskQueueAdd2Log.SetCurrentLogEntryNo("Entry No.");
        //+TQ1.29
        exit("Entry No.");
    end;

    procedure AddLogFinal(TaskQueue: Record "NPR Task Queue"; WithSucces: Boolean; OrgEntryNo: Integer)
    var
        TaskLog: Record "NPR Task Log (Task)";
        OutStream: OutStream;
        TMPText: Text[1024];
    begin
        TaskLog.LockTable;
        //-TQ1.28
        //TaskLog.GET(TaskQueueManager.GetCurrentLogEntryNo);
        Get(OrgEntryNo);
        //+TQ1.28

        "Ending Time" := CurrentDateTime;
        "Task Duration" := "Ending Time" - "Starting Time";
        if WithSucces then
            Status := Status::Succes
        else
            Status := Status::Error;
        "User ID" := UserId;
        "Task Worker Group" := TaskQueue."Task Worker Group";
        if Status = Status::Error then begin
            TMPText := GetLastErrorText;
            TMPText := ConvertCarrigeReturn(TMPText);
            "Last Error Message BLOB".CreateOutStream(OutStream);
            OutStream.WriteText(TMPText);
            "Last Error Message" := CopyStr(TMPText, 1, MaxStrLen("Last Error Message"));
            ClearLastError;
        end;
        Modify;
    end;

    procedure AddLogOtherFailure(TaskQueue: Record "NPR Task Queue"; TaskLine: Record "NPR Task Line") AddedEntryNo: Integer
    var
        TaskLog: Record "NPR Task Log (Task)";
        TMPText: Text[1024];
        OutStream: OutStream;
    begin
        //-TQ1.28
        //TaskLog.LOCKTABLE;
        //IF TaskLog.FINDLAST THEN;
        //+TQ1.28

        Init;
        //-TQ1.28
        //"Entry No." := TaskLog."Entry No." + 1;
        "Entry No." := 0;
        //+TQ1.28
        "Journal Template Name" := TaskQueue."Task Template";
        "Journal Batch Name" := TaskQueue."Task Batch";
        "Line No." := TaskQueue."Task Line No.";
        "Entry Type" := "Entry Type"::Task;
        "Starting Time" := CurrentDateTime;
        Status := Status::Error;
        "User ID" := UserId;
        "Task Worker Group" := TaskQueue."Task Worker Group";
        "Object Type" := TaskLine."Object Type";
        "Object No." := TaskLine."Object No.";
        //-TQ1.17
        //"Last Error Message" := COPYSTR(GETLASTERRORTEXT,1,MAXSTRLEN("Last Error Message"));
        TMPText := GetLastErrorText;
        TMPText := ConvertCarrigeReturn(TMPText);
        "Last Error Message BLOB".CreateOutStream(OutStream);
        OutStream.WriteText(TMPText);
        "Last Error Message" := CopyStr(TMPText, 1, MaxStrLen("Last Error Message"));
        //+TQ1.17

        "Server Instance ID" := ServiceInstanceId;
        "Session ID" := SessionId;

        Insert;
        ClearLastError;
        exit("Entry No.");
    end;

    procedure AddMovedTask(TaskQueue: Record "NPR Task Queue"; TaskLine: Record "NPR Task Line")
    var
        TaskLog: Record "NPR Task Log (Task)";
    begin
        //-TQ1.28
        //TaskLog.LOCKTABLE;
        //IF TaskLog.FINDLAST THEN;
        //+TQ1.28

        Init;
        //-TQ1.28
        //"Entry No." := TaskLog."Entry No." + 1;
        "Entry No." := 0;
        //+TQ1.28
        "Journal Template Name" := TaskQueue."Task Template";
        "Journal Batch Name" := TaskQueue."Task Batch";
        "Line No." := TaskQueue."Task Line No.";
        "Entry Type" := "Entry Type"::Task;
        "Starting Time" := CurrentDateTime;
        Status := Status::Error;
        "User ID" := UserId;
        "Task Worker Group" := TaskQueue."Task Worker Group";
        "Object Type" := TaskLine."Object Type";
        "Object No." := TaskLine."Object No.";
        "Last Error Message" := Text001;
        "Server Instance ID" := ServiceInstanceId;
        "Session ID" := SessionId;

        Insert;
    end;

    procedure AddMessage(TaskLine: Record "NPR Task Line"; MessageText: Text[1024])
    var
        TaskLog: Record "NPR Task Log (Task)";
        TMPText: Text[1024];
        OutStream: OutStream;
    begin
        //-TQ1.17
        //-TQ1.28
        //TaskLog.LOCKTABLE;
        //IF TaskLog.FINDLAST THEN;
        //+TQ1.28

        Init;
        //-TQ1.28
        //"Entry No." := TaskLog."Entry No." + 1;
        "Entry No." := 0;
        //+TQ1.28
        "Journal Template Name" := TaskLine."Journal Template Name";
        "Journal Batch Name" := TaskLine."Journal Batch Name";
        "Line No." := TaskLine."Line No.";
        "Entry Type" := "Entry Type"::Task;
        "Starting Time" := CurrentDateTime;
        Status := Status::Message;
        "User ID" := UserId;
        "Task Worker Group" := TaskLine."Task Worker Group";
        "Object Type" := TaskLine."Object Type";
        "Object No." := TaskLine."Object No.";
        TMPText := ConvertCarrigeReturn(MessageText);
        "Last Error Message BLOB".CreateOutStream(OutStream);
        OutStream.WriteText(TMPText);
        "Last Error Message" := CopyStr(TMPText, 1, MaxStrLen("Last Error Message"));
        Insert;
        //+TQ1.17
    end;

    local procedure ConvertCarrigeReturn(ErrorString: Text[1024]): Text[1024]
    var
        CR: Char;
    begin
        CR := 13;
        exit(ConvertStr(ErrorString, Format(CR), '\'));
    end;
}

