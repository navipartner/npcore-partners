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
    value(1; "RETURN_INFORMATION")
    {
        Caption = 'Return Information', Locked = true,
        Comment = 'This value is used for return sales.';
    }
    value(2; "SALES_CARDHOLDER_VERIFICATION")
    {
        Caption = 'Sales Cardholder Verification', Locked = true,
        Comment = 'This value is used for sales cardholder verification.';
    }
    value(3; "ACQUIRE_SIGNATURE")
    {
        Caption = 'Acquire Signature', Locked = true,
        Comment = 'This value is used for acquiring signature with specific popup window used for signature acquisition only.';
    }
}