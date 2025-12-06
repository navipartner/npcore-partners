tableextension 6014472 "NPR Job Queue Entry" extends "Job Queue Entry"
{
    fields
    {
        field(6014400; "NPR Notif. Profile on Error"; Code[20])
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
        field(6014403; "NPR Manually Set On Hold"; Boolean)
        {
            Caption = 'Manually Set On Hold';
            DataClassification = CustomerContent;
        }
        field(6014409; "NPR Heartbeat URL"; Text[150])
        {
            Caption = 'Heartbeat URL';
            DataClassification = CustomerContent;
        }
        field(6014412; "NPR Time Zone"; Text[180])
        {
            Caption = 'Time Zone';
            DataClassification = CustomerContent;
        }
        field(6014413; "NPR NP Protected Job"; Boolean)
        {
            Caption = 'NP Protected Job';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //DO NOT CREATE FIELDS WITH IDS: 6014404..6014408|6014410|6014411 (The IDs are reserved in table 6151148 "NPR Monitored Job Queue Entry")
    }

    trigger OnDelete()
    var
        ManagedByApp: Record "NPR Managed By App Job Queue";
    begin
        if ManagedByApp.Get(Rec.ID) then
            ManagedByApp.Delete();
    end;

    internal procedure GetTimeZoneName(): Text
#if not (BC17 or BC18)
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
#endif
    begin
#if not (BC17 or BC18)
        if Rec."NPR Time Zone" = '' then
            exit('');
        exit(TimeZoneSelection.GetTimeZoneDisplayName(Rec."NPR Time Zone"));
#else
        exit(Rec."NPR Time Zone");
#endif
    end;
}