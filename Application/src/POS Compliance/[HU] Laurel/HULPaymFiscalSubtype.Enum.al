enum 6059840 "NPR HU L Paym. Fiscal Subtype"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Non-categorized")
    {
        Caption = 'Non-categorized';
    }
    value(1; "National Voucher")
    {
        Caption = 'Erzsébet Voucher', Locked = true;
    }
    value(2; "Loan Card")
    {
        Caption = 'Széchenyi Card', Locked = true;
    }
    value(3; "Gift Card")
    {
        Caption = 'Gift Card';
    }
    value(4; "Loyalty Card")
    {
        Caption = 'Loyalty Card';
    }
    value(5; "Smartcard")
    {
        Caption = 'Smartcard';
    }
    value(6; "Bottle deposit voucher")
    {
        Caption = 'Bottle deposit voucher';
    }
    value(7; "Coupon")
    {
        Caption = 'Coupon';
    }
}