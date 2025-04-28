enum 6059886 "NPR HU L Transaction Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Standard Receipt")
    {
        Caption = 'Standard Receipt';
    }
    value(2; Return)
    {
        Caption = 'Return';
    }
    value(3; "Simple Invoice")
    {
        Caption = 'Simple Invoice';
    }
    value(4; Void)
    {
        Caption = 'Void';
    }
}