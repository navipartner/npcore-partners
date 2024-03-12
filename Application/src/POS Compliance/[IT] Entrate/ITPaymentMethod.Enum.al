enum 6014621 "NPR IT Payment Method"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "0")
    {
        Caption = 'Cash';
    }
    value(1; "1")
    {
        Caption = 'Cheque';
    }
    value(2; "2")
    {
        Caption = 'Card';
    }
    value(3; "3")
    {
        Caption = 'Ticket';
    }
}