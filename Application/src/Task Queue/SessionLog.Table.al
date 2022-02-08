table 6059908 "NPR Session Log"
{
    Access = Internal;
    // TQ1.28/MHA/20151216  CASE 219795 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Used to log start of threads + Master thread
    // TQ1.31/BR /20171109 CASE 295987 Added option ErrorStartingTread to Field Log Type, and field Error Message
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions

    Caption = 'Session Log';
    DataPerCompany = false;
    DrillDownPageID = "NPR Session Log";
    LookupPageID = "NPR Session Log";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(9; "Log Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = ',Login,Logout,,Login Tread,Error Starting Tread';
            OptionMembers = ,LoginMaster,LogoutMaster,,LoginTread,ErrorStartingTread;
            DataClassification = CustomerContent;
        }
        field(10; "Log Time"; DateTime)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;

        }
        field(21; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            TableRelation = "NPR Task Worker Group";
            DataClassification = CustomerContent;
        }
        field(22; "Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = CustomerContent;
        }
        field(30; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(40; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }


    procedure AddLogin(TaskWorker: Record "NPR Task Worker") AddedEntryNo: Integer
    begin
        //-TQ1.29
        //InitLine;
        InitLine(TaskWorker);
        //+TQ1.29
        "Log Type" := "Log Type"::LoginMaster;
        "Task Worker Group" := TaskWorker."Task Worker Group";

        Insert();
        exit("Entry No.");
    end;

    procedure AddLogout(TaskWorker: Record "NPR Task Worker") AddedEntryNo: Integer
    begin
        //-TQ1.29
        //InitLine;
        InitLine(TaskWorker);
        //+TQ1.29

        "Log Type" := "Log Type"::LogoutMaster;
        "Task Worker Group" := TaskWorker."Task Worker Group";

        Insert();
        exit("Entry No.");
    end;

    local procedure InitLine(TaskWorker: Record "NPR Task Worker")
    begin
        Init();
        "Entry No." := 0;
        "Log Time" := CurrentDateTime;
        //-TQ1.29
        // "User ID" := USERID;
        // "Server Instance ID" := SERVICEINSTANCEID;
        // "Session ID" := SESSIONID;
        "User ID" := CopyStr(TaskWorker."User ID", 1, MaxStrLen("User ID"));
        "Server Instance ID" := TaskWorker."Server Instance ID";
        //+TQ1.29
    end;

    procedure LogStartSession(MasterTaskWorker: Record "NPR Task Worker"; TaskQueue: Record "NPR Task Queue") AddedEntryNo: Integer
    begin
        //-TQ1.29
        //InitLine;
        InitLine(MasterTaskWorker);
        //+TQ1.29
        "Log Type" := "Log Type"::LoginTread;
        //-TQ1.29
        //"Task Worker Group" := TaskWorker."Task Worker Group";
        "Task Worker Group" := TaskQueue."Task Worker Group";
        "Company Name" := TaskQueue.Company;
        //+TQ1.29
        Insert();
        exit("Entry No.");
    end;
}

