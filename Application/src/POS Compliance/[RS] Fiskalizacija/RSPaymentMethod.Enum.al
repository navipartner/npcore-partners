enum 6014525 "NPR RS Payment Method"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; Other)
    {
        Caption = 'Other';
    }
    value(1; Cash)
    {
        Caption = 'Cash';
    }
    value(2; Card)
    {
        Caption = 'Card';
    }
    value(3; Check)
    {
        Caption = 'Check';
    }
    value(4; WireTransfer)
    {
        Caption = 'Wire Transfer';
    }
    value(5; Voucher)
    {
        Caption = 'Voucher';
    }
    value(6; MobileMoney)
    {
        Caption = 'Mobile Money';
    }
}