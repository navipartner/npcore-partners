table 6014450 "Import Export Media Buffer"
{
    // NPR5.48/MMV /20190215 CASE 342396 Created object

    Caption = 'Import Export Media Buffer';

    fields
    {
        field(1;"Primary Key";Integer)
        {
            AutoIncrement = true;
            Caption = 'Primary Key';
        }
        field(2;Media;Media)
        {
            Caption = 'Media';
        }
        field(3;MediaSet;MediaSet)
        {
            Caption = 'MediaSet';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

