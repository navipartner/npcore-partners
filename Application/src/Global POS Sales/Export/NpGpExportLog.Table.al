#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151035 "NPR NpGp Export Log"
{
    Access = Internal;

    Caption = 'NpGp Export Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            AutoIncrement = true;
        }
        field(10; "POS Sales Setup Code"; Code[10])
        {
            Caption = 'POS Sales Setup Code';
            TableRelation = "NPR NpGp POS Sales Setup".Code;
        }
        field(11; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "NPR POS Entry"."Entry No.";
        }
        field(21; Sent; Boolean)
        {
            Caption = 'Sent';
        }
        field(22; Failed; Boolean)
        {
            Caption = 'Failed';
        }
        field(23; "Last Error Text"; Text[250])
        {
            Caption = 'Last Error Text';
        }
        field(24; "Retry Count"; Integer)
        {
            Caption = 'Retry Count';
        }
        field(25; "Next Resend"; DateTime)
        {
            Caption = 'Next Resend';
        }
    }
    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }

    procedure SetNextResend()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if Rec."Retry Count" < 1 then
            Rec."Retry Count" := 1;
        case Rec."Retry Count" of
            1:
                Rec."Next Resend" := CurrentDateTime() + JobQueueManagement.MinutesToDuration(15);
            2:
                Rec."Next Resend" := CurrentDateTime() + JobQueueManagement.HoursToDuration(1);
            3:
                Rec."Next Resend" := CurrentDateTime() + JobQueueManagement.HoursToDuration(6);
            4:
                Rec."Next Resend" := CurrentDateTime() + JobQueueManagement.HoursToDuration(12);
            else
                Rec."Next Resend" := CurrentDateTime() + JobQueueManagement.DaysToDuration(1);
        end;
    end;
}
#endif