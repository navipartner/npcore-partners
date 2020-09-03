table 6059906 "NPR Task Worker Group"
{
    // TQ1.18/MH/20141110  CASE 198170 Renamed field 50 from "Max. Cuncurrent Threads" to Max. Concurrent Threads.
    //                                 Data Per Company set to NO - Group is now common to all companies
    // TQ1.21/JDH/20141212 CASE 198170 Keep Alive time set to 10 min default
    // TQ1.24/JDH/20150320 CASE 208247 Added Captions
    // TQ1.25/MH/20150422  CASE 210797 Removed KeepAlive functionality - Deleted field 32 "Keep Alive Time"
    // TQx.xx/RMT/20150806 CASE 219843 Set "Max. Concurrent Threads" when default
    // TQ1.28/MHA/20151216  CASE 219843 Task Queue

    Caption = 'Task Worker Group';
    DataPerCompany = false;
    DrillDownPageID = "NPR Task Worker Group";
    LookupPageID = "NPR Task Worker Group";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(20; "Language ID"; Integer)
        {
            Caption = 'Language ID';
        }
        field(21; "Abbreviated Name"; Text[3])
        {
            CalcFormula = Lookup ("Windows Language"."Abbreviated Name" WHERE("Language ID" = FIELD("Language ID")));
            Caption = 'Abbreviated Name';
            FieldClass = FlowField;
        }
        field(29; "Thread Handling"; Option)
        {
            Caption = 'Thread Handling';
            Description = 'CASE210797';
            OptionCaption = 'Process Task and End';
            OptionMembers = ExecuteTasksAndDie;

            trigger OnValidate()
            begin
                //-TQ1.25
                ////-TQ1.21
                //IF ("Thread Handling" = "Thread Handling"::KeepAliveFor) AND ("Keep Alive Time" = 0) THEN
                //  "Keep Alive Time" := 1000 * 60 * 10; //10 min
                ////+TQ1.21
                //+TQ1.25
            end;
        }
        field(30; "Min Interval Between Check"; Duration)
        {
            Caption = 'Min Interval Between Check';
        }
        field(31; "Max Interval Between Check"; Duration)
        {
            Caption = 'Max Interval Between Check';
        }
        field(33; "Next Check Time"; DateTime)
        {
            Caption = 'Next Check Time';
            Description = 'Only used temporary';
        }
        field(40; Default; Boolean)
        {
            Caption = 'Standard';
        }
        field(50; "Max. Concurrent Threads"; Integer)
        {
            Caption = 'Max. Concurrent Threads';
        }
        field(51; "No. of Active Threads"; Integer)
        {
            CalcFormula = Count ("NPR Task Worker" WHERE("Task Worker Group" = FIELD(Code)));
            Caption = 'No. of Active Threads';
            FieldClass = FlowField;
            TableRelation = "NPR Task Worker" WHERE("Task Worker Group" = FIELD(Code));
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'STD';
        Text002: Label 'Standard Group';

    procedure Initialize(NASGroupID: Code[10]; Desc: Text[30]; IsDefault: Boolean)
    begin
        if Get(NASGroupID) then
            exit;

        Init;
        Code := NASGroupID;
        Description := Desc;
        "Language ID" := GlobalLanguage;
        "Min Interval Between Check" := 10 * 1000;
        "Max Interval Between Check" := 60 * 1000;
        Default := IsDefault;
        //-TQ1.16
        //-TQ1.28
        //IF NASGroupID = 'MASTER' THEN
        if (NASGroupID = 'MASTER') or Default then
            //+TQ1.28
            "Max. Concurrent Threads" := 1;
        //+TQ1.16
        Insert;
    end;

    procedure InsertDefault()
    begin
        Initialize(Text001, Text002, true);
    end;
}

