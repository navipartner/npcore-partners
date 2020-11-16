table 6014450 "NPR Imp. Exp. Media Buffer"
{
    // NPR5.48/MMV /20190215 CASE 342396 Created object

    Caption = 'Import Export Media Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
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

