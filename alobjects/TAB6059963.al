table 6059963 "MPOS EOD Recipts"
{
    // NPR5.51/CLVA/20190805 CASE 364011 Created object

    Caption = 'MPOS EOD Recipts';

    fields
    {
        field(1;"No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(10;"Created By";Code[10])
        {
            Caption = 'Created By';
        }
        field(11;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(12;"Callback Receipt 1";BLOB)
        {
            Caption = 'Callback Receipt 1';
        }
        field(13;"Callback Timestamp";Text[100])
        {
            Caption = 'Callback Timestamp';
        }
        field(14;"Callback Device Id";Code[10])
        {
            Caption = 'Callback Device Id';
        }
        field(15;"Callback Register No.";Code[10])
        {
            Caption = 'Callback Register No.';
        }
        field(100;"Response Json";BLOB)
        {
            Caption = 'Response Json';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

