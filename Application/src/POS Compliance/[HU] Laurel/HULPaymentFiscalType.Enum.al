enum 6059885 "NPR HU L Payment Fiscal Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "CASH")
    {
        Caption = 'Cash';
    }
    value(1; "CREDIT/DEBIT")
    {
        Caption = 'Credit/Debit';
    }
    value(2; "OTHER")
    {
        Caption = 'Other';
    }
    value(3; "ROUNDING")
    {
        Caption = 'Rounding';
    }
    value(4; "FOREIGN")
    {
        Caption = 'Foreign';
    }
    value(5; "EMPTY")
    {
        Caption = 'Empty';
    }
    value(6; "CHANGE")
    {
        Caption = 'Change';
    }
}