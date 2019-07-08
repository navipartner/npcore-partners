table 6060113 "TM Ticket Participant Wks."
{
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016
    // TM1.17/TSA20160916  CASE 251883 Added SMS Option
    // TM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines

    Caption = 'Ticket Participant Wks.';
    DrillDownPageID = "TM Ticket Participant Wks.";
    LookupPageID = "TM Ticket Participant Wks.";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(6;"Applies To Schedule Entry No.";Integer)
        {
            Caption = 'Applies To Schedule Entry No.';
            TableRelation = "TM Admission Schedule Entry";
        }
        field(10;"Notification Send Status";Option)
        {
            Caption = 'Notification Send Status';
            OptionCaption = 'Pending,Sent,Canceled,Failed,Not Sent,Duplicate';
            OptionMembers = PENDING,SENT,CANCELED,FAILED,NOT_SENT,DUPLICATE;
        }
        field(11;"Notification Sent At";DateTime)
        {
            Caption = 'Notification Sent At';
        }
        field(12;"Notification Sent By User";Text[30])
        {
            Caption = 'Notification Sent By User';
        }
        field(13;"Notifcation Created At";DateTime)
        {
            Caption = 'Notifcation Created At';
        }
        field(15;Blocked;Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                "Blocked At" := CreateDateTime (0D, 0T);
                "Blocked By User" := '';
                if (Blocked) then begin
                  "Blocked At" := CurrentDateTime ();
                  "Blocked By User" := UserId;
                end;
            end;
        }
        field(16;"Blocked At";DateTime)
        {
            Caption = 'Blocked At';
        }
        field(17;"Blocked By User";Text[30])
        {
            Caption = 'Blocked By User';
        }
        field(20;"Ticket No.";Code[20])
        {
            Caption = 'Ticket No.';
        }
        field(21;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
        }
        field(22;"Admission Description";Text[50])
        {
            Caption = 'Admission Description';
        }
        field(25;"Notification Type";Option)
        {
            Caption = 'Notification Type';
            OptionCaption = 'Reminder,Cancelation,Reschedule';
            OptionMembers = REMINDER,CANCELATION,RESCHEDULE;
        }
        field(30;"Det. Ticket Access Entry No.";Integer)
        {
            Caption = 'Det. Ticket Access Entry No.';
            TableRelation = "TM Det. Ticket Access Entry";
        }
        field(40;"Text 1";Text[250])
        {
            Caption = 'Text 1';
        }
        field(50;"Text 2";Text[250])
        {
            Caption = 'Text 2';
        }
        field(60;"Original Schedule Entry No.";Integer)
        {
            Caption = 'Original Schedule Entry No.';
            TableRelation = "TM Admission Schedule Entry";
        }
        field(61;"Original Start Date";Date)
        {
            Caption = 'Original Start Date';
        }
        field(62;"Original Start Time";Time)
        {
            Caption = 'Original Start Time';
        }
        field(63;"Original End Date";Date)
        {
            Caption = 'Original End Date';
        }
        field(64;"Original End Time";Time)
        {
            Caption = 'Original End Time';
        }
        field(70;"New Schedule Entry No.";Integer)
        {
            Caption = 'New Schedule Entry No.';
            TableRelation = "TM Admission Schedule Entry";
        }
        field(71;"New Start Date";Date)
        {
            Caption = 'New Start Date';
        }
        field(72;"New Start Time";Time)
        {
            Caption = 'New Start Time';
        }
        field(73;"New End Date";Date)
        {
            Caption = 'New End Date';
        }
        field(74;"New End Time";Time)
        {
            Caption = 'New End Time';
        }
        field(80;"Notification Method";Option)
        {
            Caption = 'Notification Method';
            OptionCaption = ' ,E-Mail,SMS';
            OptionMembers = NA,EMAIL,SMS;
        }
        field(81;"Notification Address";Text[80])
        {
            Caption = 'Notification Address';
        }
        field(200;"Failed With Message";Text[250])
        {
            Caption = 'Failed With Message';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Applies To Schedule Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

