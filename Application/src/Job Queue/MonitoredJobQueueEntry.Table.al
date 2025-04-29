table 6151148 "NPR Monitored Job Queue Entry"
{
    Caption = 'Job Queue Monitor Entry';
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

            trigger OnLookup()
            begin
                Validate("Expiration Date/Time", LookupDateTime("Expiration Date/Time", "Earliest Start Date/Time", 0DT));
            end;

            trigger OnValidate()
            begin
                CheckStartAndExpirationDateTime();
            end;
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

            trigger OnValidate()
            begin
                TestField("Recurring Job");
                if "Starting Time" = 0T then
                    "Reference Starting Time" := 0DT
                else
                    "Reference Starting Time" := CreateDateTime(DMY2Date(1, 1, 2000), "Starting Time");
            end;
        }
        field(27; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Recurring Job");
            end;
        }
        field(28; "Reference Starting Time"; DateTime)
        {
            Caption = 'Reference Starting Time';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Starting Time" := DT2Time("Reference Starting Time");
            end;
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
            TableRelation = "AAD Application";

            trigger OnLookup()
            var
                AADApplication: Record "AAD Application";
                AccessControl: Record "Access Control";
                User: Record User;
                AADApplicationPage: Page "AAD Application List";
                PermissionSetLbl: Label 'NPR EXT JQ REFRESHER', Locked = true;
            begin
                if AADApplication.FindSet() then
                    repeat
                        if AccessControl.Get(AADApplication."User ID", PermissionSetLbl, '', AccessControl.Scope::System, AADApplication."App ID") then
                            AADApplication.Mark(true);
                    until AADApplication.Next() = 0;

                AADApplication.MarkedOnly(true);
                AADApplicationPage.SetTableView(AADApplication);
                AADApplicationPage.LookupMode := true;
                if AADApplicationPage.RunModal() <> Action::LookupOK then
                    exit;
                AADApplicationPage.GetRecord(AADApplication);

                if User.Get(AADApplication."User ID") then
                    "NPR Entra App User Name" := User."User Name";
            end;
        }
        field(6014407; "NP Managed Job"; Boolean)
        {
            Caption = 'NP Managed Job';
            DataClassification = CustomerContent;
        }
        field(6014409; "NPR Heartbeat URL"; Text[150])
        {
            Caption = 'Heartbeat URL';
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

    local procedure CheckStartAndExpirationDateTime()
    begin
        if IsExpired("Earliest Start Date/Time") then
            Error(ExpiresBeforeStartErr, FieldCaption("Expiration Date/Time"), FieldCaption("Earliest Start Date/Time"));
    end;

    local procedure IsExpired(AtDateTime: DateTime): Boolean
    begin
        exit((AtDateTime <> 0DT) and ("Expiration Date/Time" <> 0DT) and ("Expiration Date/Time" < AtDateTime));
    end;

    local procedure LookupDateTime(InitDateTime: DateTime; EarliestDateTime: DateTime; LatestDateTime: DateTime): DateTime
    var
        DateTimeDialog: Page "Date-Time Dialog";
        NewDateTime: DateTime;
    begin
        NewDateTime := InitDateTime;
        if InitDateTime < EarliestDateTime then
            InitDateTime := EarliestDateTime;
        if (LatestDateTime <> 0DT) and (InitDateTime > LatestDateTime) then
            InitDateTime := LatestDateTime;

        DateTimeDialog.SetDateTime(RoundDateTime(InitDateTime, 1000));

        if DateTimeDialog.RunModal() = ACTION::OK then
            NewDateTime := DateTimeDialog.GetDateTime();
        exit(NewDateTime);
    end;

    var
        ExpiresBeforeStartErr: Label '%1 must be later than %2.', Comment = '%1 = Expiration Date, %2=Start date';
}
