#if not (BC17 or BC18 or BC19 or BC20 or BC21)
enum 6151015 "NPR Digital Document Type"
{
    Access = Internal;
    Extensible = true;

    value(1; Invoice)
    {
        Caption = 'Invoice';
    }
    value(2; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(10; "Ecom Sales Document")
    {
        Caption = 'Ecom Sales Document';
    }
}
#endif