enum 6014532 "NPR Voucher Category"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;
    Caption = 'Voucher Category';

    value(0; " ")
    {
        Caption = '', Locked = true;
    }
    value(1; "Gift Voucher")
    {
        Caption = 'Gift Voucher';
    }
    value(2; "Credit Voucher")
    {
        Caption = 'Credit Voucher';
    }
}
