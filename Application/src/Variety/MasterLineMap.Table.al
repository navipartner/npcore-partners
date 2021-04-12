table 6014525 "NPR Master Line Map"
{
    DataClassification = CustomerContent;
    Caption = 'Master Line Map';

    fields
    {
        field(1; "Table Id"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Id';
        }
        field(2; "Table Record Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Record Id';
        }
        field(3; "Is Master"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Master';
        }
        field(4; "Master Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Master Id';
        }
        field(5; Ordinal; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Ordinal';
        }
    }

    keys
    {
        key(Key1; "Table Id", "Table Record Id")
        {
            Clustered = true;
        }
        key(Key2; "Master Id", "Ordinal")
        {
        }
    }
}