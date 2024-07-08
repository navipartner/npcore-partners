table 6150826 "NPR DocLXCityCardHistory"
{
    Caption = 'DocLX City Card History';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; CardNumber; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Card Number';
        }
        field(11; CityCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'City Code';
        }
        field(12; LocationCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
        }
        field(20; ArticleName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Article Name';
        }
        field(21; ArticleId; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Article ID';
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
        field(26; ActivationDate; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Activation Date';
        }
        field(27; ValidUntilDate; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Valid Until Date';
        }
        field(30; ValidatedAtDateTime; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Validated At Date Time';
        }
        field(31; ValidatedAtDateTimeUtc; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Validated At Date Time (UTC)';
        }
        Field(34; ValidationResultCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Validation Result Code';
        }
        field(35; ValidationResultMessage; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Validation Result Message';
        }
        field(40; RedeemedAtDateTime; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Redeemed At Date Time';
        }
        field(41; RedemptionResultCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Redemption Result Code';
        }
        field(42; RedemptionResultMessage; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Redemption Result Message';
        }
        field(50; POSUnitNo; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'POS Unit No.';
        }
        field(51; SalesDocumentNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Document No.';
        }
        field(60; CouponType; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Coupon Type';
        }
        field(61; CouponNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Coupon No.';
        }
        field(62; CouponReferenceNo; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Coupon Reference No.';
        }
        field(64; CouponResultCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Coupon Result Code';
        }
        field(65; CouponResultMessage; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Coupon Result Message';
        }
    }



    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }

        key(Key2; CardNumber, CityCode, LocationCode, ValidationResultCode, RedemptionResultCode, CouponResultCode)
        {
            Clustered = false;
        }
        key(Key3; SalesDocumentNo)
        {
            Clustered = false;
        }
        key(Key4; CouponNo)
        {
            Clustered = false;
        }
        key(Key5; CouponReferenceNo)
        {
            Clustered = false;
        }
    }

}