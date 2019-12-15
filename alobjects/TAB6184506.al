table 6184506 "EFT Transaction Async Response"
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object

    Caption = 'EFT Transaction Async Response';

    fields
    {
        field(1;"Request Entry No";Integer)
        {
            Caption = 'Request Entry No';
        }
        field(2;Response;BLOB)
        {
            Caption = 'Response';
        }
        field(3;Error;Boolean)
        {
            Caption = 'Error';
        }
        field(4;"Error Text";Text[250])
        {
            Caption = 'Error Text';
        }
    }

    keys
    {
        key(Key1;"Request Entry No")
        {
        }
    }

    fieldgroups
    {
    }
}

