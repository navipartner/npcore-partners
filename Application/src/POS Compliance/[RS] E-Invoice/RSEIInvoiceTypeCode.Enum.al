enum 6014698 "NPR RS EI Invoice Type Code"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "380")
    {
        Caption = 'Commercial Invoice';
    }
    value(1; "381")
    {
        Caption = 'Credit Memo';
    }
    value(2; "383")
    {
        Caption = 'Debit Memo';
    }
    value(3; "386")
    {
        Caption = 'Prepayment Invoice';
    }
}