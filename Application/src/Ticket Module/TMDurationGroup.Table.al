table 6059799 "NPR TM DurationGroup"
{
    DataClassification = ToBeClassified;
    Caption = 'Ticket Duration Group';
    Access = Internal;
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Duration Group Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; SynchronizedActivation; Option)
        {
            Caption = 'Synchronized Activation';
            DataClassification = CustomerContent;
            OptionMembers = NA,LOCATION,OCCASION,ALL_MEMBERS;
            OptionCaption = ' ,Admission Locations,Admission Events,Duration Group Members';
        }
        field(25; AlignmentSource; Option)
        {
            Caption = 'Alignment Source';
            DataClassification = CustomerContent;
            OptionMembers = SCANNED,DEFAULT,INDIVIDUAL;
            OptionCaption = 'Scanned Admission,Default Admission,Each Admission Schedule';
        }
        field(30; DurationMinutes; Integer)
        {
            Caption = 'Duration (Minutes)';
            DataClassification = CustomerContent;
        }
        field(35; CapOnEndTime; Boolean)
        {
            Caption = 'Cap on End Time';
            DataClassification = CustomerContent;
        }
        field(40; AlignLateArrivalOn; Option)
        {
            Caption = 'Align Late Arrival On';
            DataClassification = CustomerContent;
            OptionMembers = SCHEDULE_END,ARRIVAL;
            OptionCaption = 'Scheduled End Time,Arrival Time';
        }
        field(41; AlignEarlyArrivalOn; Option)
        {
            Caption = 'Align Early Arrival On';
            DataClassification = CustomerContent;
            OptionMembers = SCHEDULE_START,ARRIVAL;
            OptionCaption = 'Scheduled Start Time,Arrival Time';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}