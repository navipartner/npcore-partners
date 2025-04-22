enum 6059882 "NPR TM CouponForceAmount"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; NOT_FORCED)
    {
        Caption = 'Not Forced';
    }
    value(1; AMOUNT_INCL_VAT)
    {
        Caption = 'Amount Incl. VAT';
    }
    value(2; LIST_PRICE_INCL_VAT)
    {
        Caption = 'List Price Incl. VAT';
    }
}