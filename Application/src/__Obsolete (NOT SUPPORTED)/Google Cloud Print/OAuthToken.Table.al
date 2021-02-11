table 6014582 "NPR OAuth Token"
{

    Caption = 'OAuth Token';
    DataClassification = CustomerContent;

    ObsoleteState = Removed;
    ObsoleteReason = 'GCP Removed';
    fields
    {
        field(1; "Token Name"; Code[20])
        {
            Caption = 'Token Name';
            DataClassification = CustomerContent;
        }
        field(2; "Token Value"; BLOB)
        {
            Caption = 'Token Value';
            DataClassification = CustomerContent;
        }
        field(3; "Time Stamp"; DateTime)
        {
            Caption = 'Time Stamp';
            DataClassification = CustomerContent;
        }
        field(4; "Expires In (Seconds)"; Integer)
        {
            Caption = 'Expires In (Seconds)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Token Name")
        {
        }
    }

    fieldgroups
    {
    }

}

