table 6060113 "NPR TM Ticket Particpt. Wks."
{
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016
    // TM1.17/TSA20160916  CASE 251883 Added SMS Option
    // TM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.45/TSA /20191101 CASE 374620 Added Notification Type::Stakeholder

    Caption = 'Ticket Participant Wks.';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR TM Ticket Particpt. Wks.";
    LookupPageID = "NPR TM Ticket Particpt. Wks.";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(6; "Applies To Schedule Entry No."; Integer)
        {
            Caption = 'Applies To Schedule Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admis. Schedule Entry";
        }
        field(10; "Notification Send Status"; Option)
        {
            Caption = 'Notification Send Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Pending,Sent,Canceled,Failed,Not Sent,Duplicate';
            OptionMembers = PENDING,SENT,CANCELED,FAILED,NOT_SENT,DUPLICATE;
        }
        field(11; "Notification Sent At"; DateTime)
        {
            Caption = 'Notification Sent At';
            DataClassification = CustomerContent;
        }
        field(12; "Notification Sent By User"; Text[30])
        {
            Caption = 'Notification Sent By User';
            DataClassification = CustomerContent;
        }
        field(13; "Notifcation Created At"; DateTime)
        {
            Caption = 'Notifcation Created At';
            DataClassification = CustomerContent;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec."Blocked At" := CreateDateTime(0D, 0T);
                Rec."Blocked By User" := '';
                if (Rec.Blocked) then begin
                    Rec."Blocked At" := CurrentDateTime();
                    Rec."Blocked By User" := CopyStr(UserId(), 1, MaxStrLen(Rec."Blocked By User"));
                end;
            end;
        }
        field(16; "Blocked At"; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = CustomerContent;
        }
        field(17; "Blocked By User"; Text[30])
        {
            Caption = 'Blocked By User';
            DataClassification = CustomerContent;
        }
        field(20; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(21; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(22; "Admission Description"; Text[50])
        {
            Caption = 'Admission Description';
            DataClassification = CustomerContent;
        }
        field(25; "Notification Type"; Option)
        {
            Caption = 'Notification Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Reminder,Cancelation,Reschedule,Stakeholder';
            OptionMembers = REMINDER,CANCELATION,RESCHEDULE,STAKEHOLDER;
        }
        field(30; "Det. Ticket Access Entry No."; Integer)
        {
            Caption = 'Det. Ticket Access Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Det. Ticket AccessEntry";
        }
        field(40; "Text 1"; Text[250])
        {
            Caption = 'Text 1';
            DataClassification = CustomerContent;
        }
        field(50; "Text 2"; Text[250])
        {
            Caption = 'Text 2';
            DataClassification = CustomerContent;
        }
        field(60; "Original Schedule Entry No."; Integer)
        {
            Caption = 'Original Schedule Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admis. Schedule Entry";
        }
        field(61; "Original Start Date"; Date)
        {
            Caption = 'Original Start Date';
            DataClassification = CustomerContent;
        }
        field(62; "Original Start Time"; Time)
        {
            Caption = 'Original Start Time';
            DataClassification = CustomerContent;
        }
        field(63; "Original End Date"; Date)
        {
            Caption = 'Original End Date';
            DataClassification = CustomerContent;
        }
        field(64; "Original End Time"; Time)
        {
            Caption = 'Original End Time';
            DataClassification = CustomerContent;
        }
        field(70; "New Schedule Entry No."; Integer)
        {
            Caption = 'New Schedule Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admis. Schedule Entry";
        }
        field(71; "New Start Date"; Date)
        {
            Caption = 'New Start Date';
            DataClassification = CustomerContent;
        }
        field(72; "New Start Time"; Time)
        {
            Caption = 'New Start Time';
            DataClassification = CustomerContent;
        }
        field(73; "New End Date"; Date)
        {
            Caption = 'New End Date';
            DataClassification = CustomerContent;
        }
        field(74; "New End Time"; Time)
        {
            Caption = 'New End Time';
            DataClassification = CustomerContent;
        }
        field(80; "Notification Method"; Option)
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
            OptionCaption = ' ,E-Mail,SMS';
            OptionMembers = NA,EMAIL,SMS;
        }
        field(81; "Notification Address"; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(200; "Failed With Message"; Text[250])
        {
            Caption = 'Failed With Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Applies To Schedule Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

