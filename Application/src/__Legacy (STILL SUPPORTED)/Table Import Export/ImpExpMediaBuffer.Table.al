table 6014450 "NPR Imp. Exp. Media Buffer"
{
    Caption = 'Import Export Media Buffer';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; Media; Media)
        {
            Caption = 'Media';
            DataClassification = CustomerContent;
        }
        field(3; MediaSet; MediaSet)
        {
            Caption = 'MediaSet';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

