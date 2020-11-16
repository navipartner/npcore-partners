table 6151399 "NPR CS Counting schedule"
{
    // NPR5.53/JAKUBV/20200121  CASE 377467 Transport NPR5.53 - 21 January 2020

    Caption = 'CS Counting schedule';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Store"; Code[10])
        {
            Caption = 'POS Store';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Store";
        }
        field(10; "Earliest Start Date/Time"; DateTime)
        {
            Caption = 'Earliest Start Date/Time';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                Validate("Earliest Start Date/Time", LookupDateTime("Earliest Start Date/Time", 0DT, "Expiration Date/Time"));
            end;
        }
        field(11; "Job Queue Status"; Option)
        {
            CalcFormula = Lookup ("Job Queue Entry".Status WHERE(ID = FIELD("Job Queue Entry ID")));
            Caption = 'Job Queue Status';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Ready,In Process,Error,On Hold,Finished';
            OptionMembers = Ready,"In Process",Error,"On Hold",Finished;

            trigger OnLookup()
            begin
                if ("Job Queue Status" = "Job Queue Status"::Ready) then
                    exit;
                JobQueueEntry.ShowStatusMsg("Job Queue Entry ID");
            end;
        }
        field(12; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Job Queue Priority for Post"; Integer)
        {
            Caption = 'Job Queue Priority for Post';
            DataClassification = CustomerContent;
            Editable = true;
            InitValue = 2000;
            MinValue = 1000;
        }
        field(14; "Expiration Date/Time"; DateTime)
        {
            Caption = 'Expiration Date/Time';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                Validate("Expiration Date/Time", LookupDateTime("Expiration Date/Time", "Earliest Start Date/Time", 0DT));
            end;
        }
        field(15; "Recurring Job"; Boolean)
        {
            Caption = 'Recurring Job';
            DataClassification = CustomerContent;
        }
        field(16; "Run on Mondays"; Boolean)
        {
            Caption = 'Run on Mondays';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(17; "Run on Tuesdays"; Boolean)
        {
            Caption = 'Run on Tuesdays';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(18; "Run on Wednesdays"; Boolean)
        {
            Caption = 'Run on Wednesdays';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(19; "Run on Thursdays"; Boolean)
        {
            Caption = 'Run on Thursdays';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(20; "Run on Fridays"; Boolean)
        {
            Caption = 'Run on Fridays';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(21; "Run on Saturdays"; Boolean)
        {
            Caption = 'Run on Saturdays';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(22; "Run on Sundays"; Boolean)
        {
            Caption = 'Run on Sundays';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(23; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Recurring Job");
            end;
        }
        field(24; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Recurring Job");
            end;
        }
        field(25; "Last Ready State"; DateTime)
        {
            CalcFormula = Lookup ("Job Queue Entry"."Last Ready State" WHERE(ID = FIELD("Job Queue Entry ID")));
            Caption = 'Last Ready State';
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Job Queue Created"; Boolean)
        {
            Caption = 'Job Queue Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; "No. of Minutes between Runs"; Integer)
        {
            Caption = 'No. of Minutes between Runs';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetRecurringField;
            end;
        }
        field(28; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = ' ,Scheduled,Error,Running';
            OptionMembers = " ",Scheduled,Error,Running;

            trigger OnLookup()
            begin
                if not (Status = Status::Error) then
                    exit;

                JobQueueEntry.ShowStatusMsg("Job Queue Entry ID");
            end;
        }
        field(29; "Last Executed"; DateTime)
        {
            Caption = 'Last Executed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; Name; Text[50])
        {
            CalcFormula = Lookup ("NPR POS Store".Name WHERE(Code = FIELD("POS Store")));
            Caption = 'Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "POS Store")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if not IsNullGuid("Job Queue Entry ID") then
            if JobQueueEntry.Get("Job Queue Entry ID") then
                JobQueueEntry.Delete(true);
    end;

    trigger OnInsert()
    begin
        "Earliest Start Date/Time" := CurrentDateTime;
    end;

    trigger OnRename()
    begin
        Error(Txt001);
    end;

    var
        JobQueueEntry: Record "Job Queue Entry";
        Txt001: Label 'Schedule Entry can''t be renamed.';

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

        if DateTimeDialog.RunModal = ACTION::OK then
            NewDateTime := DateTimeDialog.GetDateTime;
        exit(NewDateTime);
    end;

    local procedure SetRecurringField()
    begin
        "Recurring Job" :=
          "Run on Mondays" or
          "Run on Tuesdays" or "Run on Wednesdays" or "Run on Thursdays" or "Run on Fridays" or "Run on Saturdays" or "Run on Sundays";

        if "Recurring Job" and ("No. of Minutes between Runs" = 0) then
            "No. of Minutes between Runs" := 1440; //24 hours
    end;
}

