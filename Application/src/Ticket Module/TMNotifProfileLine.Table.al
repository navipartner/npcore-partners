table 6014590 "NPR TM Notif. Profile Line"
{
    Caption = 'Ticket Notification Profile Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR TM Notification Profile";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(20; "Unit of Measure"; Option)
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
            OptionMembers = DAYS,HOURS;
            OptionCaption = 'Day(s),Hour(s)';
        }
        field(25; Units; Integer)
        {
            Caption = 'Units';
            DataClassification = CustomerContent;
        }
        field(30; "Notification Trigger"; Option)
        {
            Caption = 'Notification Trigger';
            DataClassification = CustomerContent;
            OptionMembers = RESERVATION,FIRST_ADMISSION,REVOKE,WELCOME;
            OptionCaption = 'Reservation Reminder,First Admission,Revoke,Welcome';
        }
        field(32; "Detention Time Seconds"; Integer)
        {
            Caption = 'Detention Time (Seconds)';
            DataClassification = CustomerContent;
        }
        field(33; "Shared Detention Queue"; Boolean)
        {
            Caption = 'Shared Detention Queue';
            DataClassification = CustomerContent;
            InitValue = true;
        }

        field(35; "Notification Engine"; Option)
        {
            Caption = 'Notification Engine';
            DataClassification = CustomerContent;
            OptionMembers = NPR_INTERNAL,NPR_EXTERNAL;
            OptionCaption = 'Internal,External';
        }
        field(45; "Template Code"; Code[10])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
        }
        field(120; "Notification Extra Text"; Text[200])
        {
            Caption = 'Notification Extra Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Profile Code", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ProfilesLines: Record "NPR TM Notif. Profile Line";
    begin
        if (Rec."Line No." = 0) then begin
            Rec."Line No." := 100;
            ProfilesLines.SetFilter("Profile Code", '=%1', Rec."Profile Code");
            if (ProfilesLines.FindLast()) then
                Rec."Line No." += ProfilesLines."Line No.";
        end;
    end;
}