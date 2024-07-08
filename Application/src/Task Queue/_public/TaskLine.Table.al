table 6059902 "NPR Task Line"
{
    Caption = 'Task Line';
    DataClassification = CustomerContent;
#IF BC17
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Task Queue module is about to be removed from NP Retail. We are now using Job Queue instead.';
#ELSE
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';
#ENDIF
    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
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
        }
        field(10; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = ' ,Report,Codeunit';
            OptionMembers = " ","Report","Codeunit";
            DataClassification = CustomerContent;
        }
        field(11; "Object No."; Integer)
        {
            Caption = 'Object No.';
            DataClassification = CustomerContent;
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
        }
        field(16; "Estimated Duration"; Duration)
        {
            Caption = 'Estimated Duration';
            DataClassification = CustomerContent;
        }
        field(19; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
        }
        field(20; Recurrence; Option)
        {
            Caption = 'Recurrence';
            OptionCaption = ' ,Hourly,Daily,Weekly,Custom,DateFormula,None';
            OptionMembers = " ",Hourly,Daily,Weekly,Custom,DateFormula,"None";
            DataClassification = CustomerContent;
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
            DataClassification = CustomerContent;
        }
        field(52; "File Path"; Text[100])
        {
            Caption = 'File Path';
            DataClassification = CustomerContent;
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
            DataClassification = EndUserIdentifiableInformation;
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

#IF BC17
    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetUpNewLine(LastTaskLine: Record "NPR Task Line")
    begin
    end;
#ENDIF

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure LookupNextRunTime(): DateTime
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetNextRuntime(NextRunDateTime: DateTime; AssignTask2Me: Boolean)
    var
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure TaskUsesPrinter(): Boolean
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure TaskGenerateOutput(): Boolean
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetExpectedDuration(): Duration
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure UpdateTaskQueue()
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetLogEntryNo(): Integer
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetFilePathAndName() filename: Text[1024]
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure IncreaseIndentation()
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure DecreaseIndentation()
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure CheckIndentation()
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetParameterText(ParameterName: Text[20]): Text[250]
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetParameterInt(ParameterName: Text[20]): Integer
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetParameterBool(ParameterName: Text[20]): Boolean
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetParameterDate(ParameterName: Text[20]): Date
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetParameterTime(ParameterName: Text[20]): Time
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetParameterDateFormula(ParameterName: Text[20]): Text[100]
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetParameterCalcDate(ParameterName: Text[20]): Date
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetParameterText(ParameterName: Text[20]; Value: Text[1024])
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetParameterInt(ParameterName: Text[20]; Value: Integer)
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetParameterBool(ParameterName: Text[20]; Value: Boolean)
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetParameterDate(ParameterName: Text[20]; Value: Date)
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetParameterTime(ParameterName: Text[20]; Value: Time)
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetParameterDateFormula(ParameterName: Text[20]; Value: DateFormula)
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure ParametersExists(): Boolean
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure InsertParameter(ParameterName: Code[20]; FieldType: Option Text,Date,Time,DateTime,"Integer",Decimal,Boolean,DateFilter)
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    local procedure TableFilter2View(TableNo: Integer; TableFilter: Text[1024]; TableKey: Text[1024]; CurrTableView: Text[1024]): Text[1024]
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetTableView(TableNo: Integer; CurrTableView: Text[1024]): Text[1024]
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure TimeSlotStillValid(): Boolean
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure AddMessageLine2Log(MessageLine: Text[1024])
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure AddMessageLine2OutputLog(MessageLine: Text[1024])
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure DisableAutoParameterCreation()
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure GetReportParameters(): Text
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure SetReportParameters(Params: Text)
    begin
    end;

    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure RunReportRequestPage()
    begin
    end;
}
