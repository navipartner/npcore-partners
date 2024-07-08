table 6059904 "NPR Task Log (Task)"
{
    Access = Internal;
    Caption = 'Task Log';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(3; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Task,Login,Logout,Change Company,Login Tread,Logout Tread';
            OptionMembers = Task,Login,Logout,ChangeComp,LoginTread,LogoutTread;
            DataClassification = CustomerContent;
        }
        field(10; "Starting Time"; DateTime)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(11; "Ending Time"; DateTime)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;
        }
        field(12; "Expected Ending Time"; DateTime)
        {
            Caption = 'Expected Ending Time';
            DataClassification = CustomerContent;
        }
        field(13; "Task Duration"; Duration)
        {
            Caption = 'Task Duration';
            DataClassification = CustomerContent;
        }
        field(15; Status; Option)
        {
            Caption = 'Status';
            Description = 'TQ1.27';
            OptionCaption = ',Started,Error,Succes,Message';
            OptionMembers = " ",Started,Error,Succes,Message;
            DataClassification = CustomerContent;
        }
        field(16; "Last Error Message"; Text[250])
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(17; "Last Error Message BLOB"; BLOB)
        {
            Caption = 'Last Error Message BLOB';
            DataClassification = CustomerContent;
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(21; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
        }
        field(22; "Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = CustomerContent;
        }
        field(23; "Session ID"; Integer)
        {
            Caption = 'Session ID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(40; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = ' ,Report,Codeunit';
            OptionMembers = " ","Report","Codeunit";
            DataClassification = CustomerContent;
        }
        field(41; "Object No."; Integer)
        {
            Caption = 'Object No.';
            DataClassification = CustomerContent;
        }
        field(42; "No. of Output Log Entries"; Integer)
        {
            CalcFormula = Count("NPR Task Output Log" WHERE("Task Log Entry No." = FIELD("Entry No.")));
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
}
