table 6059921 "NPR MMTimelineEventBuffer"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No';
        }
        field(2; HideEvent; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Hide Event';
        }

        field(10; EventType; Enum "NPR MMTimelineEventType")
        {
            DataClassification = CustomerContent;
            Caption = 'Event Type';
        }

        field(20; EventDateTime; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Event Date Time';
        }

        field(21; EventCreatedBy; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Event Created By';
        }

        field(30; SourceTableId; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Table Id';
        }

        field(40; SourceSystemId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Source System Id';
        }

        field(50; Title; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Title';
        }

        field(60; Details; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Details';
        }

    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }

        key(Key2; EventDateTime)
        {
        }
        key(Key3; SourceSystemId, SourceTableId)
        {
        }
    }


}