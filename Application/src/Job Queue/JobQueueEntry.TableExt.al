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
    }
}