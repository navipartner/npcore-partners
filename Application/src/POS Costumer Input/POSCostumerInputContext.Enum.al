enum 6014519 "NPR POS Costumer Input Context"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif
    value(0; "MONEY_BACK")
    {
        Caption = 'Money Back', Locked = true,
        Comment = 'This value is used for sales where money is given back to the costumer.';
    }
}