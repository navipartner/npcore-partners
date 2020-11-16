table 6014568 "NPR RP DataJoin Rec.ID Buffer"
{
    Caption = 'RP Data Join Record ID Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Unique Record No."; Integer)
        {
            Caption = 'Unique Record No.';
            DataClassification = CustomerContent;
        }
        field(2; "Buffer Record ID"; RecordID)
        {
            Caption = 'Buffer Record ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Unique Record No.")
        {
        }
    }

    fieldgroups
    {
    }
}

