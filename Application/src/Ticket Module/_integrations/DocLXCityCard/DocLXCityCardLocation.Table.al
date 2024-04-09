table 6150825 "NPR DocLXCityCardLocation"
{
    Caption = 'DocLX City Card Location';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; CityCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'City Code';
            TableRelation = "NPR DocLXCityCardSetup";
        }
        field(2; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(10; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(20; CityCardLocationId; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'City Card Location Id';
        }
        field(30; CouponSelection; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Coupon Selection';
            OptionMembers = LOCATION,ITEM;
            OptionCaption = 'Location,Item';
        }
        field(40; CouponType; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Coupon Type';
            TableRelation = "NPR NpDc Coupon Type";
        }

    }

    keys
    {
        key(Key1; CityCode, Code)
        {
            Clustered = true;
        }
    }

}