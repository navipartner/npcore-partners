enum 6014659 "NPR RS EI Payment Means"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(1; "10")
    {
        Caption = 'Cash';
    }
    value(2; "20")
    {
        Caption = 'Cheque';
    }
    value(3; "30")
    {
        Caption = 'Credit Transfer';
    }
    value(4; "31")
    {
        Caption = 'Debit Transfer';
    }
    value(5; "42")
    {
        Caption = 'Payment to Bank Account';
    }
    value(6; "54")
    {
        Caption = 'Credit Card';
    }
    value(7; "55")
    {
        Caption = 'Debit Card';
    }
    value(8; "56")
    {
        Caption = 'Bank Giro';
    }
}