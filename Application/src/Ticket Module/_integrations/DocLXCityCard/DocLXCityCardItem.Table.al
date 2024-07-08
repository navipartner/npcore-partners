table 6150820 "NPR DocLXCityCardItem"
{
    Caption = 'DocLX City Card Articles';
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
        field(2; LocationCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "NPR DocLXCityCardLocation".Code;
        }

        field(3; ArticleId; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Article ID';
        }

        field(20; ArticleName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Article Name';
        }

        field(22; ValidTimeSpan; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Valid Time Span';
        }
        field(23; ShopKey; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shop Key';
        }
        field(24; CategoryName; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Category Name';
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
        key(Key1; CityCode, LocationCode, ArticleId)
        {
            Clustered = true;
        }
    }


}