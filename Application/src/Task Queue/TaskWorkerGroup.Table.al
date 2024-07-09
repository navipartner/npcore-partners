table 6059906 "NPR Task Worker Group"
{
    Access = Internal;
    Caption = 'Task Worker Group';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Language ID"; Integer)
        {
            Caption = 'Language ID';
            DataClassification = CustomerContent;
        }
        field(21; "Abbreviated Name"; Text[3])
        {
            CalcFormula = Lookup("Windows Language"."Abbreviated Name" WHERE("Language ID" = FIELD("Language ID")));
            Caption = 'Abbreviated Name';
            FieldClass = FlowField;
        }
        field(29; "Thread Handling"; Option)
        {
            Caption = 'Thread Handling';
            Description = 'CASE210797';
            OptionCaption = 'Process Task and End';
            OptionMembers = ExecuteTasksAndDie;
            DataClassification = CustomerContent;
        }
        field(30; "Min Interval Between Check"; Duration)
        {
            Caption = 'Min Interval Between Check';
            DataClassification = CustomerContent;
        }
        field(31; "Max Interval Between Check"; Duration)
        {
            Caption = 'Max Interval Between Check';
            DataClassification = CustomerContent;
        }
        field(33; "Next Check Time"; DateTime)
        {
            Caption = 'Next Check Time';
            Description = 'Only used temporary';
            DataClassification = CustomerContent;
        }
        field(40; Default; Boolean)
        {
            Caption = 'Standard';
            DataClassification = CustomerContent;
        }
        field(50; "Max. Concurrent Threads"; Integer)
        {
            Caption = 'Max. Concurrent Threads';
            DataClassification = CustomerContent;
        }
        field(51; "No. of Active Threads"; Integer)
        {
            CalcFormula = Count("NPR Task Worker" WHERE("Task Worker Group" = FIELD(Code)));
            Caption = 'No. of Active Threads';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

