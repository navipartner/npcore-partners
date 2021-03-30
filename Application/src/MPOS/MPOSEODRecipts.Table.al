table 6059963 "NPR MPOS EOD Recipts"
{
    Caption = 'MPOS EOD Recipts';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Created By"; Code[10])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(11; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(12; "Callback Receipt 1"; BLOB)
        {
            Caption = 'Callback Receipt 1';
            DataClassification = CustomerContent;
        }
        field(13; "Callback Timestamp"; Text[100])
        {
            Caption = 'Callback Timestamp';
            DataClassification = CustomerContent;
        }
        field(14; "Callback Device Id"; Code[10])
        {
            Caption = 'Callback Device Id';
            DataClassification = CustomerContent;
        }
        field(15; "Callback Register No."; Code[10])
        {
            Caption = 'Callback Register No.';
            DataClassification = CustomerContent;
        }
        field(100; "Response Json"; BLOB)
        {
            Caption = 'Response Json';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }
}

