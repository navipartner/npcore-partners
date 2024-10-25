table 6150940 "NPR WalletCouponSetup"
{
    DataClassification = CustomerContent;
    Caption = 'Wallet Coupon Setup';
    Access = Internal;

    fields
    {
        field(1; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }

        field(10; TriggerOnItemNo; Code[20])
        {
            Caption = 'Trigger On Item No.';
            DataClassification = CustomerContent;
            TableRelation = "Item";
        }
    }

    keys
    {
        key(Key1; "Coupon Type")
        {
        }
    }

}