enum 6059849 "NPR EFT Adyen Aux Operation"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(1; ABORT_TRX)
    {
        Caption = 'Abort Transaction';
    }
    value(2; ACQUIRE_CARD)
    {
        Caption = 'Acquire Card';
    }
    value(3; ABORT_ACQUIRED)
    {
        Caption = 'Abort Acquired Card';
    }
    value(4; DETECT_SHOPPER)
    {
        Caption = 'Detect Shopper from Card';
    }
    value(5; CLEAR_SHOPPER)
    {
        Caption = 'Clear Shopper from Card';
    }
    value(6; DISABLE_CONTRACT)
    {
        Caption = 'Disable Shopper Recurring Contract';
    }
    value(8; SUBSCRIPTION_CONFIRM)
    {
        Caption = 'Subscription Confirmation';
    }
}