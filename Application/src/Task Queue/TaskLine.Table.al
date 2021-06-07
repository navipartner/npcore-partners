table 6059902 "NPR Task Line"
{
    Caption = 'Task Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "NPR Task Template";
            DataClassification = CustomerContent;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "NPR Task Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(8; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TaskQueue: Record "NPR Task Queue";
                RunTask: Codeunit "NPR Task Queue Processor";
                DummyEnabled: Boolean;
            begin
                if Enabled and (not xRec.Enabled) and
                   ("Error Counter" <> 0) and ("Max No. Of Retries (On Error)" <> 0) and
                   ("Action After Max. No. of Retri" = "Action After Max. No. of Retri"::StopTask) then begin
                    if GuiAllowed then
                        Message(Text001);
                    "Error Counter" := 0;
                end;

                if Enabled and (not TaskQueue.Get(CompanyName, "Journal Template Name", "Journal Batch Name", "Line No.")) then begin
                    //decide if a Task Queue line should be created
                    if (Indentation > 0) then
                        exit;
                    TaskQueue.SetupNewLine(Rec, false);
                    TaskQueue.Insert();
                    RunTask.CalculateNextRunTime(Rec, true, DummyEnabled);
                end;
                UpdateTaskQueue();
            end;
        }
        field(10; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = ' ,Report,Codeunit';
            OptionMembers = " ","Report","Codeunit";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateTaskQueue();
            end;
        }
        field(11; "Object No."; Integer)
        {
            Caption = 'Object No.';
            TableRelation = IF ("Object Type" = CONST(Report)) AllObj."Object ID" WHERE("Object Type" = CONST(Report))
            ELSE
            IF ("Object Type" = CONST(Codeunit)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AllObj: Record AllObj;
            begin
                TestField("Object Type");
                case "Object Type" of
                    "Object Type"::Report:
                        AllObj.Get(AllObj."Object Type"::Report, "Object No.");
                    "Object Type"::Codeunit:
                        AllObj.Get(AllObj."Object Type"::Codeunit, "Object No.");
                end;

                if Description = '' then
                    Description := AllObj."Object Name";
                UpdateTaskQueue();
            end;
        }
        field(12; "Call Object With Task Record"; Boolean)
        {
            Caption = 'Call Object With Task Record';
            DataClassification = CustomerContent;
        }
        field(13; "Report Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Object No.")));
            Caption = 'Report Name';
            FieldClass = FlowField;
        }
        field(15; Priority; Option)
        {
            Caption = 'Priority';
            OptionCaption = 'Low,,Medium,,High';
            OptionMembers = Low,,Medium,,High;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateTaskQueue();
            end;
        }
        field(16; "Estimated Duration"; Duration)
        {
            Caption = 'Estimated Duration';
            DataClassification = CustomerContent;
        }
        field(19; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            TableRelation = "NPR Task Worker Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateTaskQueue();
            end;
        }
        field(20; Recurrence; Option)
        {
            Caption = 'Recurrence';
            OptionCaption = ' ,Hourly,Daily,Weekly,Custom,DateFormula,None';
            OptionMembers = " ",Hourly,Daily,Weekly,Custom,DateFormula,"None";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case Recurrence of
                    Recurrence::" ":
                        "Recurrence Interval" := 0;
                    Recurrence::Hourly:
                        "Recurrence Interval" := 1000 * 60 * 60;
                    Recurrence::Daily:
                        "Recurrence Interval" := 1000 * 60 * 60 * 24;
                    Recurrence::Weekly:
                        "Recurrence Interval" := 1000 * 60 * 60 * 24 * 7;
                end;

                case Recurrence of
                    Recurrence::" ":
                        "Recurrence Calc. Interval" := 0;
                    Recurrence::Hourly:
                        "Recurrence Calc. Interval" := 1000 * 60;
                    Recurrence::Daily:
                        "Recurrence Calc. Interval" := 1000 * 60 * 60;
                    Recurrence::Weekly:
                        "Recurrence Calc. Interval" := 1000 * 60 * 60 * 24;
                    Recurrence::Custom:
                        "Recurrence Calc. Interval" := 1000 * 60;
                end;
            end;
        }
        field(21; "Recurrence Interval"; Duration)
        {
            Caption = 'Recurrence Interval';
            DataClassification = CustomerContent;
        }
        field(22; "Recurrence Method"; Option)
        {
            Caption = 'Recurrence Method';
            OptionCaption = 'Static,Dynamic';
            OptionMembers = Static,Dynamic;
            DataClassification = CustomerContent;
        }
        field(23; "Recurrence Calc. Interval"; Duration)
        {
            Caption = 'Recurrence Calculation Interval';
            DataClassification = CustomerContent;
        }
        field(25; "Recurrence Formula"; DateFormula)
        {
            Caption = 'Recurrence Formula';
            DataClassification = CustomerContent;
        }
        field(26; "Recurrence Time"; Time)
        {
            Caption = 'Recurrence Time';
            DataClassification = CustomerContent;
        }
        field(30; "Run on Monday"; Boolean)
        {
            Caption = 'Run on Monday';
            DataClassification = CustomerContent;
        }
        field(31; "Run on Tuesday"; Boolean)
        {
            Caption = 'Run on Tuesday';
            DataClassification = CustomerContent;
        }
        field(32; "Run on Wednesday"; Boolean)
        {
            Caption = 'Run on Wednesday';
            DataClassification = CustomerContent;
        }
        field(33; "Run on Thursday"; Boolean)
        {
            Caption = 'Run on Thursday';
            DataClassification = CustomerContent;
        }
        field(34; "Run on Friday"; Boolean)
        {
            Caption = 'Run on Friday';
            DataClassification = CustomerContent;
        }
        field(35; "Run on Saturday"; Boolean)
        {
            Caption = 'Run on Saturday';
            DataClassification = CustomerContent;
        }
        field(36; "Run on Sunday"; Boolean)
        {
            Caption = 'Run on Sunday';
            DataClassification = CustomerContent;
        }
        field(40; "Retry Interval (On Error)"; Duration)
        {
            Caption = 'Retry Interval (On Error)';
            DataClassification = CustomerContent;
        }
        field(41; "Max No. Of Retries (On Error)"; Integer)
        {
            Caption = 'Max No. Of Retries (On Error)';
            DataClassification = CustomerContent;
        }
        field(42; "Action After Max. No. of Retri"; Option)
        {
            Caption = 'Action After Max. No. of Retri';
            OptionCaption = 'Reschedule To Next Runtime,Stop Task';
            OptionMembers = Reschedule2NextRuntime,StopTask;
            DataClassification = CustomerContent;
        }
        field(50; "Type Of Output"; Option)
        {
            Caption = 'Type Of Output';
            OptionCaption = ' ,Paper,XMLFile,HTMLFile,PDFFile,Excel,Word';
            OptionMembers = " ",Paper,XMLFile,HTMLFile,PDFFile,Excel,Word;
            DataClassification = CustomerContent;
        }
        field(51; "Printer Name"; Text[100])
        {
            Caption = 'Printer Name';
            TableRelation = Printer;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                PrinterLookup();
            end;
        }
        field(52; "File Path"; Text[100])
        {
            Caption = 'File Path';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "File Path" = '' then
                    exit;

                if CopyStr("File Path", StrLen("File Path"), 1) <> '\' then
                    "File Path" += '\';
            end;
        }
        field(53; "File Name"; Text[100])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(55; "File Type"; Option)
        {
            Caption = 'File Type';
            OptionCaption = ' ,HTML,XML,PDF';
            OptionMembers = " ",HTML,XML,PDF;
            DataClassification = CustomerContent;
        }
        field(60; "Error Counter"; Integer)
        {
            Caption = 'Error Counter';
            DataClassification = CustomerContent;
        }
        field(61; "First E-Mail on Error No."; Integer)
        {
            Caption = 'First E-mail on Error No.';
            DataClassification = CustomerContent;
        }
        field(62; "Last E-Mail on Error No."; Integer)
        {
            Caption = 'Last E-mail on Error No.';
            DataClassification = CustomerContent;
        }
        field(70; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';
            DataClassification = CustomerContent;
        }
        field(71; "Last Modified By User"; Code[50])
        {
            Caption = 'Last Modified By User';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(80; "Delete Log After"; Duration)
        {
            Caption = 'Delete Log After';
            DataClassification = CustomerContent;
        }
        field(81; "Disable File Logging"; Boolean)
        {
            Caption = 'Disable Logging of files';
            DataClassification = CustomerContent;
        }
        field(90; "Language ID"; Integer)
        {
            Caption = 'Language ID';
            DataClassification = CustomerContent;
        }
        field(91; "Abbreviated Name"; Text[3])
        {
            CalcFormula = Lookup("Windows Language"."Abbreviated Name" WHERE("Language ID" = FIELD("Language ID")));
            Caption = 'Abbreviated Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(111; "Valid After"; Time)
        {
            Caption = 'Valid After';
            DataClassification = CustomerContent;
        }
        field(112; "Valid Until"; Time)
        {
            Caption = 'Valid Until';
            DataClassification = CustomerContent;
        }
        field(130; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(131; "Dependence Type"; Option)
        {
            Caption = 'Dependence Type';
            OptionCaption = ' ,Error,Succes';
            OptionMembers = " ",Error,Succes;
            DataClassification = CustomerContent;
        }
        field(140; "Task Parameters"; Integer)
        {
            CalcFormula = Count("NPR Task Line Parameters" WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                                                              "Journal Line No." = FIELD("Line No."),
                                                              "Field No." = CONST(0)));
            Caption = 'Task Parameters';
            FieldClass = FlowField;
        }
        field(150; "Table 1 No."; Integer)
        {
            Caption = 'Table 1 No.';
            DataClassification = CustomerContent;
        }
        field(151; "Table 1 Filter"; TableFilter)
        {
            Caption = 'Table 1 Filter';
            DataClassification = CustomerContent;
        }
        field(160; "Request Page XML"; BLOB)
        {
            Caption = 'Request Page XML';
            DataClassification = CustomerContent;
        }
        field(161; "Report Request Page Options"; Boolean)
        {
            Caption = 'Report Request Page Options';
            DataClassification = CustomerContent;
        }
        field(170; "Send E-Mail (On Start)"; Boolean)
        {
            Caption = 'Send Email On Start';
            DataClassification = CustomerContent;
        }
        field(171; "No. of E-Mail (On Start)"; Integer)
        {
            CalcFormula = Count("NPR Task Line Parameters" WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                                                              "Journal Line No." = FIELD("Line No."),
                                                              "Field No." = CONST(171)));
            Caption = 'No. of Email On Start';
            FieldClass = FlowField;
        }
        field(175; "Send E-Mail (On Error)"; Boolean)
        {
            Caption = 'Send Email On Error';
            DataClassification = CustomerContent;
        }
        field(176; "No. of E-Mail (On Error)"; Integer)
        {
            CalcFormula = Count("NPR Task Line Parameters" WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                                                              "Journal Line No." = FIELD("Line No."),
                                                              "Field No." = CONST(176)));
            Caption = 'No. of Email On Error';
            FieldClass = FlowField;
        }
        field(177; "First E-Mail After Error No."; Integer)
        {
            Caption = 'First E-Mail After Error No.';
            DataClassification = CustomerContent;
        }
        field(178; "Last E-Mail After Error No."; Integer)
        {
            Caption = 'Last E-Mail After Error No.';
            DataClassification = CustomerContent;
        }
        field(180; "Send E-Mail (On Success)"; Boolean)
        {
            Caption = 'Send Email On Success';
            DataClassification = CustomerContent;
        }
        field(181; "No. of E-Mail (On Success)"; Integer)
        {
            CalcFormula = Count("NPR Task Line Parameters" WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                                                              "Journal Line No." = FIELD("Line No."),
                                                              "Field No." = CONST(181)));
            Caption = 'No. of Email On Success';
            FieldClass = FlowField;
        }
        field(182; "Send Only if File Exists"; Boolean)
        {
            Caption = 'Send only if File Exists';
            DataClassification = CustomerContent;
        }
        field(183; "Exclude File(s) in Mail"; Boolean)
        {
            Caption = 'Exclude File(s) in Mail';
            Description = 'TQ1.27';
            DataClassification = CustomerContent;
        }
        field(185; "No. of E-Mail (On Run)"; Integer)
        {
            CalcFormula = Count("NPR Task Line Parameters" WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                                                              "Journal Line No." = FIELD("Line No."),
                                                              "Field No." = CONST(185)));
            Caption = 'No. of E-Mail (On Run)';
            FieldClass = FlowField;
        }
        field(186; "No. of E-Mail CC (On Run)"; Integer)
        {
            CalcFormula = Count("NPR Task Line Parameters" WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                                                              "Journal Line No." = FIELD("Line No."),
                                                              "Field No." = CONST(186)));
            Caption = 'No. of E-Mail CC (On Run)';
            FieldClass = FlowField;
        }
        field(187; "No. of E-Mail BCC (On Run)"; Integer)
        {
            CalcFormula = Count("NPR Task Line Parameters" WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                                                              "Journal Line No." = FIELD("Line No."),
                                                              "Field No." = CONST(187)));
            Caption = 'No. of E-Mail BCC (On Run)';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            MaintainSIFTIndex = false;
        }
    }

    trigger OnDelete()
    var
        TaskQueue: Record "NPR Task Queue";
        TaskLog: Record "NPR Task Log (Task)";
        TaskOutputLog: Record "NPR Task Output Log";
        TaskLineParm: Record "NPR Task Line Parameters";
    begin
        TaskQueue.LockTable();
        TaskQueue.SetRange(Company, CompanyName);
        TaskQueue.SetRange("Task Template", "Journal Template Name");
        TaskQueue.SetRange("Task Batch", "Journal Batch Name");
        TaskQueue.SetRange("Task Line No.", "Line No.");
        if TaskQueue.FindFirst() then begin
            TaskQueue.TestField(Status, TaskQueue.Status::Awaiting);
            TaskQueue.Delete(true);
        end;

        TaskLog.SetRange("Journal Template Name", "Journal Template Name");
        TaskLog.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLog.SetRange("Line No.", "Line No.");
        if TaskLog.FindSet(true, true) then
            repeat
                TaskLog."Journal Template Name" := '';
                TaskLog."Journal Batch Name" := '';
                TaskLog."Line No." := 0;
                TaskLog.Modify();
            until TaskLog.Next() = 0;

        TaskOutputLog.SetRange("Journal Template Name", "Journal Template Name");
        TaskOutputLog.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskOutputLog.SetRange("Journal Line No.", "Line No.");
        if TaskOutputLog.FindSet(true, true) then
            repeat
                TaskOutputLog."Journal Template Name" := '';
                TaskOutputLog."Journal Batch Name" := '';
                TaskOutputLog."Journal Line No." := 0;
                TaskOutputLog.Modify();
            until TaskOutputLog.Next() = 0;

        TaskLineParm.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParm.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParm.SetRange("Journal Line No.", "Line No.");
        TaskLineParm.DeleteAll();

        TaskJnlMgt.SyncroniseCompanies(Rec, 2);
    end;

    trigger OnInsert()
    begin
        "Last Modified Date" := CurrentDateTime;
        "Last Modified By User" := UserId;
        TaskJnlMgt.SyncroniseCompanies(Rec, 0);
    end;

    trigger OnModify()
    begin
        "Last Modified Date" := CurrentDateTime;
        "Last Modified By User" := UserId;
        TaskJnlMgt.SyncroniseCompanies(Rec, 1);
    end;

    trigger OnRename()
    begin
        TaskJnlMgt.SyncroniseCompanies(Rec, 3);
    end;

    var
        TaskJnlMgt: Codeunit "NPR Task Jnl. Management";
        Text001: Label 'Error Counter is set to 0';
        AutoParameterDisabled: Boolean;

    procedure SetUpNewLine(LastTaskLine: Record "NPR Task Line")
    var
        NASGroup: Record "NPR Task Worker Group";
        TaskBatch: Record "NPR Task Batch";
        TaskTemplate: Record "NPR Task Template";
    begin
        "Run on Monday" := true;
        "Run on Tuesday" := true;
        "Run on Wednesday" := true;
        "Run on Thursday" := true;
        "Run on Friday" := true;
        "Run on Saturday" := true;
        "Run on Sunday" := true;
        Priority := Priority::Medium;

        if TaskBatch.Get("Journal Template Name", "Journal Batch Name") and (TaskBatch."Task Worker Group" <> '') then
            "Task Worker Group" := TaskBatch."Task Worker Group"
        else
            if TaskTemplate.Get("Journal Template Name") and (TaskTemplate."Task Worker Group" <> '') then
                "Task Worker Group" := TaskTemplate."Task Worker Group"
            else begin
                NASGroup.SetRange(Default, true);
                if NASGroup.FindFirst() then
                    "Task Worker Group" := NASGroup.Code;
            end;
    end;

    procedure LookupNextRunTime(): DateTime
    var
        TaskQueue: Record "NPR Task Queue";
    begin
        if not TaskQueue.Get(CompanyName, "Journal Template Name", "Journal Batch Name", "Line No.") then
            TaskQueue.Init();

        exit(TaskQueue."Next Run time");
    end;

    procedure SetNextRuntime(NextRunDateTime: DateTime; AssignTask2Me: Boolean)
    var
        TaskQueue: Record "NPR Task Queue";
    begin
        if not TaskQueue.Get(CompanyName, "Journal Template Name", "Journal Batch Name", "Line No.") then begin
            TaskQueue.SetupNewLine(Rec, false);
            TaskQueue."Next Run time" := NextRunDateTime;
            if AssignTask2Me then
                TaskQueue.Validate(Status, TaskQueue.Status::Assigned);
            TaskQueue.Insert();
        end else begin
            TaskQueue."Next Run time" := NextRunDateTime;
            if AssignTask2Me then
                TaskQueue.Validate(Status, TaskQueue.Status::Assigned);
            TaskQueue.Modify();
        end;
    end;

    procedure TaskUsesPrinter(): Boolean
    begin
        exit("Type Of Output" in ["Type Of Output"::Paper]);
    end;

    procedure TaskGenerateOutput(): Boolean
    begin
        exit("Type Of Output" in ["Type Of Output"::XMLFile,
                                  "Type Of Output"::HTMLFile,
                                  "Type Of Output"::PDFFile,
                                  "Type Of Output"::Excel,
                                  "Type Of Output"::Word]);
    end;

    procedure PrinterLookup()
    var
        Printer: Record Printer;
    begin
        if PAGE.RunModal(PAGE::Printers, Printer) = ACTION::LookupOK then
            "Printer Name" := Printer.Name;
    end;

    procedure GetExpectedDuration(): Duration
    var
        TaskLog: Record "NPR Task Log (Task)";
        Counter: Integer;
        TotalDur: Duration;
    begin
        TaskLog.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
        TaskLog.SetRange("Journal Template Name", "Journal Template Name");
        TaskLog.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLog.SetRange("Line No.", "Line No.");
        TaskLog.Ascending(false);

        if TaskLog.FindSet() then
            repeat
                if TaskLog."Ending Time" <> 0DT then begin
                    Counter += 1;
                    TotalDur += TaskLog."Ending Time" - TaskLog."Starting Time";
                end;
            until (TaskLog.Next() = 0) or (Counter = 5);
        if Counter <> 0 then
            exit(Round(TotalDur / Counter, 1));
    end;

    procedure UpdateTaskQueue()
    var
        TaskQueue: Record "NPR Task Queue";
    begin
        TaskQueue.LockTable();
        if not TaskQueue.Get(CompanyName, "Journal Template Name", "Journal Batch Name", "Line No.") then
            exit;

        //only if the user changes the line (not if its done by code)
        if CurrFieldNo <> 0 then
            TaskQueue.TestField(Status, TaskQueue.Status::Awaiting);
        TaskQueue.Enabled := Enabled;
        TaskQueue.Priority := Priority;
        TaskQueue."Task Worker Group" := "Task Worker Group";
        TaskQueue."Object Type" := "Object Type";
        TaskQueue."Object No." := "Object No.";
        TaskQueue.Modify();
    end;

    procedure GetLogEntryNo(): Integer
    var
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
    begin
        exit(TaskQueueAdd2Log.GetCurrentLogEntryNo());
    end;

    procedure GetFilePathAndName() filename: Text[1024]
    var
        TaskQueueExecute: Codeunit "NPR Task Queue Execute";
    begin
        TestField("File Path");
        TestField("File Name");
        exit(TaskQueueExecute.GetFilePath(Rec) + TaskQueueExecute.GetFileName(Rec));
    end;

    procedure IncreaseIndentation()
    begin
        if Indentation = 0 then
            CheckIndentation();

        Indentation += 1;
        Modify();
    end;

    procedure DecreaseIndentation()
    begin
        if Indentation > 0 then
            Indentation -= 1;
        Modify();
    end;

    procedure CheckIndentation()
    begin
        TestField(Recurrence, Recurrence::None);
    end;

    procedure GetParameterText(ParameterName: Text[30]): Text[1024]
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(TaskLineParam.Value);

        InsertParameter(ParameterName, 0);
    end;

    procedure GetParameterInt(ParameterName: Text[30]): Integer
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(TaskLineParam."Integer Value");

        InsertParameter(ParameterName, 4);
    end;

    procedure GetParameterBool(ParameterName: Text[30]): Boolean
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(TaskLineParam."Boolean Value");

        InsertParameter(ParameterName, 6);
    end;

    procedure GetParameterDate(ParameterName: Text[30]): Date
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(TaskLineParam."Date Value");
        InsertParameter(ParameterName, 1);
    end;

    procedure GetParameterTime(ParameterName: Text[30]): Time
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(TaskLineParam."Time Value");
        InsertParameter(ParameterName, 2);
    end;

    procedure GetParameterDateFormula(ParameterName: Text[30]): Text[100]
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(Format(TaskLineParam."Date Formula"));
        InsertParameter(ParameterName, 7);
    end;

    procedure GetParameterCalcDate(ParameterName: Text[30]): Date
    var
        DateFormula: DateFormula;
    begin
        Evaluate(DateFormula, GetParameterDateFormula(ParameterName));
        if (Format(DateFormula) = '') then
            exit(0D);

        exit(CalcDate(DateFormula, Today));
    end;

    procedure SetParameterText(ParameterName: Text[30]; Value: Text[1024])
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam.Value := Value;
        TaskLineParam.Modify();
    end;

    procedure SetParameterInt(ParameterName: Text[30]; Value: Integer)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Integer Value" := Value;
        TaskLineParam.Modify();
    end;

    procedure SetParameterBool(ParameterName: Text[30]; Value: Boolean)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Boolean Value" := Value;
        TaskLineParam.Modify();
    end;

    procedure SetParameterDate(ParameterName: Text[30]; Value: Date)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Date Value" := Value;
        TaskLineParam.Modify();
    end;

    procedure SetParameterTime(ParameterName: Text[30]; Value: Time)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Time Value" := Value;
        TaskLineParam.Modify();
    end;

    procedure SetParameterDateFormula(ParameterName: Text[30]; Value: DateFormula)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Date Formula" := Value;
        TaskLineParam.Modify();
    end;

    procedure ParametersExists(): Boolean
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field No.", 0);
        exit(not TaskLineParam.IsEmpty());
    end;

    procedure InsertParameter(ParameterName: Code[20]; FieldType: Option Text,Date,Time,DateTime,"Integer",Decimal,Boolean,DateFilter)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
        LineNo: Integer;
    begin
        if AutoParameterDisabled then
            exit;

        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field No.", 0);
        if TaskLineParam.FindLast() then
            LineNo := TaskLineParam."Line No." + 10000
        else
            LineNo := 10000;

        TaskLineParam.Init();
        TaskLineParam."Journal Template Name" := "Journal Template Name";
        TaskLineParam."Journal Batch Name" := "Journal Batch Name";
        TaskLineParam."Journal Line No." := "Line No.";
        TaskLineParam."Field No." := 0;
        TaskLineParam."Line No." := LineNo;
        TaskLineParam."Field Code" := ParameterName;
        TaskLineParam."Field Type" := FieldType;
        TaskLineParam.Insert();
    end;

    local procedure TableFilter2View(TableNo: Integer; TableFilter: Text[1024]; TableKey: Text[1024]; CurrTableView: Text[1024]): Text[1024]
    var
        AllObj: Record AllObj;
        TableView: Text[1024];
        Pos: Integer;
    begin
        TableView := '';
        if TableKey = '' then begin
            Pos := StrPos(CurrTableView, 'WHERE(');
            if Pos > 0 then
                TableView := CopyStr(CurrTableView, 1, Pos - 1)
            else
                TableView := CurrTableView + ' ';
        end else
            TableView := 'SORTING(' + TableKey + ') ';

        Pos := StrPos(TableFilter, ': ');
        if Pos = 0 then
            exit(TableView);

        AllObj.Get(AllObj."Object Type"::Table, TableNo);

        if CopyStr(TableFilter, 1, Pos - 1) <> AllObj."Object Name" then
            exit(TableView);

        TableFilter := CopyStr(TableFilter, Pos + 2);

        Pos := StrPos(TableFilter, '=');
        if Pos = 0 then
            exit(TableView);

        TableView := TableView + 'WHERE(';

        while Pos > 0 do begin
            TableView := TableView + CopyStr(TableFilter, 1, Pos) + 'FILTER(';
            TableFilter := CopyStr(TableFilter, Pos + 1);

            if TableFilter[1] = '"' then begin
                TableFilter := CopyStr(TableFilter, 2);
                Pos := StrPos(TableFilter, '"');
                while Pos > 0 do begin
                    TableView := TableView + CopyStr(TableFilter, 1, Pos - 1);
                    if CopyStr(TableFilter, Pos, 2) = '""' then begin
                        TableView := TableView + '"';
                        TableFilter := CopyStr(TableFilter, Pos + 2);
                        Pos := StrPos(TableFilter, '"');
                    end else begin
                        TableFilter := CopyStr(TableFilter, Pos + 1);
                        Pos := 0;
                    end;
                end;
            end;

            Pos := StrPos(TableFilter, ',');
            if Pos = 0 then
                Pos := StrLen(TableFilter) + 1;

            TableView := TableView + CopyStr(TableFilter, 1, Pos - 1) + ')' + CopyStr(TableFilter, Pos, 1);
            TableFilter := CopyStr(TableFilter, Pos + 1);
            Pos := StrPos(TableFilter, '=');
        end;

        TableView := TableView + ')';

        exit(TableView);
    end;

    procedure GetTableView(TableNo: Integer; CurrTableView: Text[1024]): Text[1024]
    begin
        if TableNo = 0 then
            exit(CurrTableView);

        if TableNo = "Table 1 No." then
            exit(TableFilter2View(TableNo, Format("Table 1 Filter"), '', CurrTableView));
    end;

    procedure TimeSlotStillValid(): Boolean
    begin
        if Indentation > 0 then
            exit(true);

        //weekday check
        case Date2DWY(Today, 1) of
            1:
                if not "Run on Monday" then
                    exit(false);
            2:
                if not "Run on Tuesday" then
                    exit(false);
            3:
                if not "Run on Wednesday" then
                    exit(false);
            4:
                if not "Run on Thursday" then
                    exit(false);
            5:
                if not "Run on Friday" then
                    exit(false);
            6:
                if not "Run on Saturday" then
                    exit(false);
            7:
                if not "Run on Sunday" then
                    exit(false);
        end;

        //time check
        if ("Valid After" <> 0T) and ("Valid Until" <> 0T) then begin
            if "Valid After" < "Valid Until" then begin
                //not crossing midnight
                if (Time < "Valid After") or
                   (Time > "Valid Until") then
                    exit(false);
            end else begin
                //crossing midnight
                if (Time < "Valid After") and
                   (Time > "Valid Until") then
                    exit(false);
            end;
        end;

        exit(true);
    end;

    procedure AddMessageLine2Log(MessageLine: Text[1024])
    var
        TaskLog: Record "NPR Task Log (Task)";
    begin
        //WARNING - this function locks table "Task Log" - wont be released before a COMMIT
        TaskLog.AddMessage(Rec, MessageLine);
    end;

    procedure AddMessageLine2OutputLog(MessageLine: Text[1024])
    var
        TaskOutputLog: Record "NPR Task Output Log";
    begin
        //WARNING - this function locks table "Task Output Log" - wont be released before a COMMIT
        TaskOutputLog.AddDescription(Rec, MessageLine);
    end;

    procedure DisableAutoParameterCreation()
    begin
        AutoParameterDisabled := true;
    end;

    procedure GetReportParameters(): Text
    var
        InStr: InStream;
        Params: Text;
    begin
        TestField("Object Type", "Object Type"::Report);
        TestField("Object No.");

        CalcFields("Request Page XML");
        if "Request Page XML".HasValue() then begin
            "Request Page XML".CreateInStream(InStr, TEXTENCODING::UTF8);
            InStr.Read(Params);
        end;

        exit(Params);
    end;

    procedure SetReportParameters(Params: Text)
    var
        OutStr: OutStream;
    begin
        TestField("Object Type", "Object Type"::Report);
        TestField("Object No.");
        Clear("Request Page XML");
        if Params <> '' then begin
            "Report Request Page Options" := true;
            "Request Page XML".CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.Write(Params);
        end;
        Modify();
    end;

    procedure RunReportRequestPage()
    var
        Params: Text;
    begin
        if "Object Type" <> "Object Type"::Report then
            exit;
        if "Object No." = 0 then
            exit;

        Params := REPORT.RunRequestPage("Object No.", GetReportParameters());

        if Params <> '' then
            SetReportParameters(Params);
    end;
}