table 6059902 "NPR Task Line"
{
    // TQ1.16/JDH/20140916 CASE 179044 added field "Send Only if File Exists" -possible to send ok emails only if a file has been generated
    // TQ1.17/JDH/20141008 CASE 179044 added function, so a manual check can be done, if the line is still valid to run (timeslot expired)
    //                                 Logging of imformation added
    // TQ1.18/MH/20141110  CASE 198170 "Task Worker Group" is set in the following priority: Batch --> Template --> Default.
    // TQ1.20/JDH/20141203 CASE 199884 Added testfield to object type, so its not possible to add object no without an object type
    // TQ1.21/JDH/20141218 CASE 202057 if time crosses midnight, it will fail in timeslot still valid
    //                                 if filepath is blanked, a copystr overflow occurs
    // TQ1.21/JDH/20141219 CASE 202183 Added fields "Delete Log After" and "Disable File Logging"
    // TQ1.24/JDH/20150320 CASE 208247 Added Captions
    // TQ1.24/JDH/20150320 CASE 209090 Possible to set the language on the task line
    // TQ1.25/JDH/20150504 CASE 210797 Possible to disable automatic parameter creation
    // TQ1.27/TS/201150716 CASE 211152 Possible to not include files in mail
    // TQ1.28/RMT/20151130 CASE 219795 Change of parameters to function call "CalculateNextRunTime"
    // TQ1.29/JDH /20161101 CASE 242044 possible to use the new 2016 feature to store requestpage parameters in a blob
    // TQ1.33/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 11
    // NPR5.47/MHA /20181022  CASE 333301 Updated AllObj.Get() to reflect Primary Key in Object No. - OnValidate()

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
                    //-TQ1.28
                    //RunTask.CalculateNextRunTime(Rec,TRUE);
                    RunTask.CalculateNextRunTime(Rec, true, DummyEnabled);
                    //+TQ1.28
                end;
                UpdateTaskQueue;
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
                UpdateTaskQueue;
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
                "Object": Record "Object";
                AllObj: Record AllObj;
            begin
                //-TQ1.19
                TestField("Object Type");
                //+TQ1.19
                //-TQ1.33 [322752]
                // CASE "Object Type" OF
                //  "Object Type"::Report: Object.GET(Object.Type::Report, '', "Object No.");
                //  "Object Type"::Codeunit: Object.GET(Object.Type::Codeunit, '', "Object No.");
                // END;
                //
                // //-TQ1.18
                // //Description := Object.Name;
                // IF Description = '' THEN
                //  Description := Object.Name;
                // //+TQ1.18

                case "Object Type" of
                    //-NPR5.47 [333301]
                    // "Object Type"::Report: AllObj.GET(AllObj."Object Type"::Report, '', "Object No.");
                    // "Object Type"::Codeunit: AllObj.GET(AllObj."Object Type"::Codeunit, '', "Object No.");
                    "Object Type"::Report:
                        AllObj.Get(AllObj."Object Type"::Report, "Object No.");
                    "Object Type"::Codeunit:
                        AllObj.Get(AllObj."Object Type"::Codeunit, "Object No.");
                //+NPR5.47 [333301]
                end;

                if Description = '' then
                    Description := Object.Name;
                //+TQ1.33 [322752]
                UpdateTaskQueue;
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
                UpdateTaskQueue;
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
                UpdateTaskQueue;
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
                PrinterLookup;
            end;
        }
        field(52; "File Path"; Text[100])
        {
            Caption = 'File Path';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-TQ1.21
                if "File Path" = '' then
                    exit;
                //+TQ1.21

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

    fieldgroups
    {
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

        //-TQ1.18
        //NASGroup.SETRANGE(Default,TRUE);
        //IF NASGroup.FindFirst() THEN
        //  "Task Worker Group" := NASGroup.Code;
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
        //+TQ1.18
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
            //-TQ1.25
            if AssignTask2Me then
                TaskQueue.Validate(Status, TaskQueue.Status::Assigned);
            //+TQ1.25
            TaskQueue.Insert();
        end else begin
            TaskQueue."Next Run time" := NextRunDateTime;
            //-TQ1.25
            if AssignTask2Me then
                TaskQueue.Validate(Status, TaskQueue.Status::Assigned);
            //+TQ1.25
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

        if TaskLog.FindFirst() then
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
        //-TQ1.29
        exit(TaskQueueAdd2Log.GetCurrentLogEntryNo);
        //+TQ1.29
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
            CheckIndentation;

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

        //-TQ1.17
        InsertParameter(ParameterName, 0);
        //+TQ1.17
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

        //-TQ1.17
        InsertParameter(ParameterName, 4);
        //+TQ1.17
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

        //-TQ1.17
        InsertParameter(ParameterName, 6);
        //+TQ1.17
    end;

    procedure GetParameterDate(ParameterName: Text[30]): Date
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.17
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(TaskLineParam."Date Value");
        InsertParameter(ParameterName, 1);
        //+TQ1.17
    end;

    procedure GetParameterTime(ParameterName: Text[30]): Time
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.17
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if TaskLineParam.FindFirst() then
            exit(TaskLineParam."Time Value");
        InsertParameter(ParameterName, 2);
        //+TQ1.17
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
        //-TQ1.16
        InsertParameter(ParameterName, 7);
        //+TQ1.16
    end;

    procedure GetParameterCalcDate(ParameterName: Text[30]): Date
    var
        DateFormula: DateFormula;
    begin
        //-TQ1.16
        Evaluate(DateFormula, GetParameterDateFormula(ParameterName));
        if (Format(DateFormula) = '') then
            exit(0D);

        exit(CalcDate(DateFormula, Today));
        //+TQ1.16
    end;

    procedure SetParameterText(ParameterName: Text[30]; Value: Text[1024])
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.17
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam.Value := Value;
        TaskLineParam.Modify();
        //+TQ1.17
    end;

    procedure SetParameterInt(ParameterName: Text[30]; Value: Integer)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.17
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Integer Value" := Value;
        TaskLineParam.Modify();
        //+TQ1.17
    end;

    procedure SetParameterBool(ParameterName: Text[30]; Value: Boolean)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.17
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Boolean Value" := Value;
        TaskLineParam.Modify();
        //+TQ1.17
    end;

    procedure SetParameterDate(ParameterName: Text[30]; Value: Date)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.17
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Date Value" := Value;
        TaskLineParam.Modify();
        //+TQ1.17
    end;

    procedure SetParameterTime(ParameterName: Text[30]; Value: Time)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.17
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Time Value" := Value;
        TaskLineParam.Modify();
        //+TQ1.17
    end;

    procedure SetParameterDateFormula(ParameterName: Text[30]; Value: DateFormula)
    var
        TaskLineParam: Record "NPR Task Line Parameters";
    begin
        //-TQ1.20.01
        TaskLineParam.SetRange("Journal Template Name", "Journal Template Name");
        TaskLineParam.SetRange("Journal Batch Name", "Journal Batch Name");
        TaskLineParam.SetRange("Journal Line No.", "Line No.");
        TaskLineParam.SetRange("Field Code", ParameterName);
        if not TaskLineParam.FindFirst() then
            exit;

        TaskLineParam."Date Formula" := Value;
        TaskLineParam.Modify();
        //+TQ1.20.01
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
        //-TQ1.25
        if AutoParameterDisabled then
            exit;
        //+TQ1.25

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
        //-TQ1.16
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
        //+TQ1.16
    end;

    procedure GetTableView(TableNo: Integer; CurrTableView: Text[1024]): Text[1024]
    begin
        //-TQ1.16
        if TableNo = 0 then
            exit(CurrTableView);

        if TableNo = "Table 1 No." then
            exit(TableFilter2View(TableNo, Format("Table 1 Filter"), '', CurrTableView));
        //+TQ1.16
    end;

    procedure TimeSlotStillValid(): Boolean
    begin
        //-TQ1.17
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
                //-TQ1.21
                //IF (TIME > "Valid After") OR
                //   (TIME < "Valid Until") THEN
                if (Time < "Valid After") and
                   (Time > "Valid Until") then
                    //+TQ1.21
                    exit(false);
            end;
        end;

        exit(true);
        //+TQ1.17
    end;

    procedure AddMessageLine2Log(MessageLine: Text[1024])
    var
        TaskLog: Record "NPR Task Log (Task)";
    begin
        //-TQ1.17
        //WARNING - this function locks table "Task Log" - wont be released before a COMMIT
        TaskLog.AddMessage(Rec, MessageLine);
        //+TQ1.17
    end;

    procedure AddMessageLine2OutputLog(MessageLine: Text[1024])
    var
        TaskOutputLog: Record "NPR Task Output Log";
    begin
        //-TQ1.17
        //WARNING - this function locks table "Task Output Log" - wont be released before a COMMIT
        TaskOutputLog.AddDescription(Rec, MessageLine);
        //+TQ1.17
    end;

    procedure DisableAutoParameterCreation()
    begin
        //-TQ1.25
        AutoParameterDisabled := true;
        //+TQ1.25
    end;

    procedure GetReportParameters(): Text
    var
        InStr: InStream;
        Params: Text;
    begin
        //-TQ1.29 [242044]
        TestField("Object Type", "Object Type"::Report);
        TestField("Object No.");

        CalcFields("Request Page XML");
        if "Request Page XML".HasValue() then begin
            "Request Page XML".CreateInStream(InStr, TEXTENCODING::UTF8);
            InStr.Read(Params);
        end;

        exit(Params);
        //+TQ1.29 [242044]
    end;

    procedure SetReportParameters(Params: Text)
    var
        OutStr: OutStream;
    begin
        //-TQ1.29 [242044]
        TestField("Object Type", "Object Type"::Report);
        TestField("Object No.");
        Clear("Request Page XML");
        if Params <> '' then begin
            "Report Request Page Options" := true;
            "Request Page XML".CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.Write(Params);
        end;
        Modify();
        //+TQ1.29 [242044]
    end;

    procedure RunReportRequestPage()
    var
        Params: Text;
    begin
        //-TQ1.29 [242044]
        if "Object Type" <> "Object Type"::Report then
            exit;
        if "Object No." = 0 then
            exit;

        Params := REPORT.RunRequestPage("Object No.", GetReportParameters);

        if Params <> '' then
            SetReportParameters(Params);
        //+TQ1.29 [242044]
    end;
}

