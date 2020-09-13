table 6014652 "NPR Tax Free GB IIN Blacklist"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB IIN Blacklist';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Country Code"; Integer)
        {
            Caption = 'Shop Country Code';
            DataClassification = CustomerContent;
        }
        field(2; "Range Inclusive Start"; Integer)
        {
            Caption = 'Range Inclusive Start';
            DataClassification = CustomerContent;
        }
        field(3; "Range Exclusive End"; Integer)
        {
            Caption = 'Range Exclusive End';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Shop Country Code", "Range Inclusive Start", "Range Exclusive End")
        {
        }
    }

    fieldgroups
    {
    }
}

