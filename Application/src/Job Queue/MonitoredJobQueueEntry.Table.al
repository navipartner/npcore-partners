table 6151148 "NPR Monitored Job Queue Entry"
{
    Caption = 'Monitored Job';
    Access = Internal;
    DataCaptionFields = "Object Type to Run", "Object ID to Run", "Object Caption to Run";
    DataClassification = CustomerContent;

    fields
    {
        field(6014405; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(6014406; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            TableRelation = "Job Queue Entry".ID;
            DataClassification = CustomerContent;
        }
        field(3; XML; BLOB)
        {
            Caption = 'XML';
            DataClassification = CustomerContent;
        }
        field(5; "Expiration Date/Time"; DateTime)
        {
            Caption = 'Expiration Date/Time';
            DataClassification = CustomerContent;
        }
        field(6; "Earliest Start Date/Time"; DateTime)
        {
            Caption = 'Earliest Start Date/Time';
            DataClassification = CustomerContent;
        }
        field(7; "Object Type to Run"; Option)
        {
            Caption = 'Object Type to Run';
            InitValue = "Report";
            OptionCaption = ',,,Report,,Codeunit';
            OptionMembers = ,,,"Report",,"Codeunit";
            DataClassification = CustomerContent;
        }
        field(8; "Object ID to Run"; Integer)
        {
            Caption = 'Object ID to Run';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("Object Type to Run"));
        }
        field(9; "Object Caption to Run"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = field("Object Type to Run"),
                                                                           "Object ID" = field("Object ID to Run")));
            Caption = 'Object Caption to Run';
            Editable = false;
            FieldClass = FlowField;
        }
#if BC17 or BC18 or BC19 or BC20 or BC21
        field(10; "Report Output Type"; Option)
        {
            OptionCaption = 'PDF,Word,Excel,Print,None (Processing only)';
            OptionMembers = PDF,Word,Excel,Print,"None (Processing only)";
#else
        field(10; "Report Output Type"; Enum "Job Queue Report Output Type")
        {
#endif
            Caption = 'Report Output Type';
            DataClassification = CustomerContent;
        }
        field(11; "Maximum No. of Attempts to Run"; Integer)
        {
            Caption = 'Maximum No. of Attempts to Run';
            MaxValue = 10;
            DataClassification = CustomerContent;
        }
        field(15; "Record ID to Process"; RecordID)
        {
            Caption = 'Record ID to Process';
            DataClassification = CustomerContent;
        }
        field(16; "Parameter String"; Text[250])
        {
            Caption = 'Parameter String';
            DataClassification = CustomerContent;
        }
        field(17; "Recurring Job"; Boolean)
        {
            Caption = 'Recurring Job';
            DataClassification = CustomerContent;
        }
        field(18; "No. of Minutes between Runs"; Integer)
        {
            Caption = 'No. of Minutes between Runs';
            DataClassification = CustomerContent;
        }
        field(19; "Run on Mondays"; Boolean)
        {
            Caption = 'Run on Mondays';
            DataClassification = CustomerContent;
        }
        field(20; "Run on Tuesdays"; Boolean)
        {
            Caption = 'Run on Tuesdays';
            DataClassification = CustomerContent;
        }
        field(21; "Run on Wednesdays"; Boolean)
        {
            Caption = 'Run on Wednesdays';
            DataClassification = CustomerContent;
        }
        field(22; "Run on Thursdays"; Boolean)
        {
            Caption = 'Run on Thursdays';
            DataClassification = CustomerContent;
        }
        field(23; "Run on Fridays"; Boolean)
        {
            Caption = 'Run on Fridays';
            DataClassification = CustomerContent;
        }
        field(24; "Run on Saturdays"; Boolean)
        {
            Caption = 'Run on Saturdays';
            DataClassification = CustomerContent;
        }
        field(25; "Run on Sundays"; Boolean)
        {
            Caption = 'Run on Sundays';
            DataClassification = CustomerContent;
        }
        field(26; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(27; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;
        }
        field(28; "Reference Starting Time"; DateTime)
        {
            Caption = 'Reference Starting Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(29; "Next Run Date Formula"; DateFormula)
        {
            Caption = 'Next Run Date Formula';
            DataClassification = CustomerContent;
        }
        field(30; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(33; "Job Queue Category Code"; Code[10])
        {
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category";
            DataClassification = CustomerContent;
        }
        field(43; "Notify On Success"; Boolean)
        {
            Caption = 'Notify On Success';
            DataClassification = CustomerContent;
        }
        field(44; "User Language ID"; Integer)
        {
            Caption = 'User Language ID';
            DataClassification = CustomerContent;
        }
        field(45; "Printer Name"; Text[250])
        {
            Caption = 'Printer Name';
            DataClassification = CustomerContent;
        }
        field(46; "Report Request Page Options"; Boolean)
        {
            Caption = 'Report Request Page Options';
            DataClassification = CustomerContent;
        }
        field(47; "Rerun Delay (sec.)"; Integer)
        {
            Caption = 'Rerun Delay (sec.)';
            DataClassification = CustomerContent;
            MaxValue = 3600;
            MinValue = 0;
        }
        field(50; "Manual Recurrence"; Boolean)
        {
            Caption = 'Manual Recurrence';
            DataClassification = CustomerContent;
        }
        field(52; "Inactivity Timeout Period"; Integer)
        {
            Caption = 'Inactivity Timeout Period';
            DataClassification = CustomerContent;
            MinValue = 5;
            InitValue = 5;
        }
        field(54; "Job Timeout"; Duration)
        {
            Caption = 'Job Timeout';
            DataClassification = SystemMetadata;
        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
        field(57; "Priority Within Category"; Enum "Job Queue Priority")
        {
            Caption = 'Priority';
            InitValue = Normal;
            DataClassification = SystemMetadata;
        }
#endif
        field(6014400; "Notif. Profile on Error"; Code[20])
        {
            Caption = 'Notification Profile on Error';
            DataClassification = CustomerContent;
            TableRelation = "NPR Job Queue Notif. Profile";
        }
        field(6014401; "NPR Auto-Resched. after Error"; Boolean)
        {
            Caption = 'Auto-Reschedule after Error';
            DataClassification = CustomerContent;
        }
        field(6014402; "NPR Auto-Resched. Delay (sec.)"; Integer)
        {
            Caption = 'Auto-Reschedule Delay (sec.)';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(6014404; "NPR Entra App User Name"; Text[250])
        {
            Caption = 'JQ Runner User Name';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-06-14';
            ObsoleteReason = 'Replaced by field "JQ Runner User Name"';
        }
        field(6014407; "NP Managed Job"; Boolean)
        {
            Caption = 'NP Protected Job';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-05-12';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014408; "JQ Runner User Name"; Code[50])
        {
            Caption = 'JQ Runner User Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                JQRefresherSetup: Record "NPR Job Queue Refresh Setup";
            begin
                JQRefresherSetup.UpdateRefresherUser("JQ Runner User Name");
            end;
        }
        field(6014409; "NPR Heartbeat URL"; Text[150])
        {
            Caption = 'Heartbeat URL';
            DataClassification = CustomerContent;
        }
        field(6014410; "Last Refresh Status"; Option)
        {
            Caption = 'Last Refresh Status';
            DataClassification = CustomerContent;
            OptionMembers = " ",Error,Success;
            OptionCaption = ' ,Error,Success';
        }
        field(6014411; "Last Error Message"; Blob)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(6014412; "Time Zone"; Text[180])
        {
            Caption = 'Time Zone';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key2; "Job Queue Entry ID")
        {
        }
        key(Key3; "Object ID to Run", "Object Type to Run")
        {
        }
    }

    trigger OnDelete()
    var
        ManagedByApp: Record "NPR Managed By App Job Queue";
    begin
        if not isNullGuid(Rec."Job Queue Entry ID") then
            if ManagedByApp.Get(Rec."Job Queue Entry ID") then
                ManagedByApp.Delete();
    end;

    internal procedure ChangeJobTimeZoneToWebserviceTimezone(JQRefreshSetup: Record "NPR Job Queue Refresh Setup")
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        TimeOffset: Duration;
    begin
        if ("Starting Time" = 0T) and ("Ending Time" = 0T) then begin
            "Reference Starting Time" := 0DT;
            "Time Zone" := '';
            exit;
        end;

        TimeOffset := CalculateTimeOffset(JQRefreshSetup);
        if "Starting Time" <> 0T then
            "Starting Time" := "Starting Time" + TimeOffset;
        if "Ending Time" <> 0T then
            "Ending Time" := "Ending Time" + TimeOffset;
        "Time Zone" := JQRefreshSetup."Webservice Time Zone";

        TempJobQueueEntry."Recurring Job" := true;
        TempJobQueueEntry.Validate("Starting Time", "Starting Time");
        "Reference Starting Time" := TempJobQueueEntry."Reference Starting Time";
    end;

    local procedure CalculateTimeOffset(JQRefreshSetup: Record "NPR Job Queue Refresh Setup"): Duration
    var
        DT: DateTime;
        NewDT: DateTime;
    begin
        DT := CurrentDateTime();
        NewDT := DT +
            JQRefreshSetup.GetWebserviceUserTimeZoneOffset() + DaylightSavingTimeOffset(DT, JQRefreshSetup."Webservice Time Zone") -
            GetJobTimeZoneOffset() - DaylightSavingTimeOffset(DT, "Time Zone");
        exit(NewDT - DT);
    end;

    local procedure DaylightSavingTimeOffset(DateTimeToCheck: DateTime; TimeZoneID: Text) TimeOffset: Duration
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        TimeZone: Codeunit "Time Zone";
#endif
    begin
        TimeOffset := 0;
        if (DateTimeToCheck = 0DT) or (TimeZoneID in ['', 'UTC']) then
            exit;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        if TimeZone.TimeZoneSupportsDaylightSavingTime(TimeZoneID) then
            if TimeZone.IsDaylightSavingTime(DateTimeToCheck, TimeZoneID) then
                TimeOffset := 1 * 60 * 60 * 1000;  //1 hour
#endif
    end;

    local procedure GetJobTimeZoneOffset() TimeZoneOffset: Duration
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        TypeHelper: Codeunit "Type Helper";
    begin
        if "Time Zone" = '' then begin
            if not JQRefreshSetup.Get() then
                Clear(JQRefreshSetup);
            JQRefreshSetup.TestField("Default Job Time Zone");
            "Time Zone" := JQRefreshSetup."Default Job Time Zone";
        end;
        TypeHelper.GetTimezoneOffset(TimeZoneOffset, "Time Zone");
    end;

    internal procedure SetErrorMessage(NewErrorText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Last Error Message");
        if NewErrorText = '' then
            exit;
        "Last Error Message".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewErrorText);
    end;

    procedure GetErrorMessage(ShowDefaultMsg: Boolean): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        ErrorText: Text;
        NoErrorMessageTxt: Label 'No error message was registered for the entry.';
    begin
        ErrorText := '';
        if "Last Error Message".HasValue() then begin
            CalcFields("Last Error Message");
            "Last Error Message".CreateInStream(InStream, TextEncoding::UTF8);
            ErrorText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
        end;
        if (ErrorText = '') and ShowDefaultMsg then
            ErrorText := NoErrorMessageTxt;
        exit(ErrorText);
    end;
}
