enum 6014605 "NPR EFT Adyen Response Type"
{
    Extensible = false;
#if not BC17
    Access = internal;
#endif

    value(0; Diagnose)
    {
        Caption = 'Diagnose';
    }
    value(1; Void)
    {
        Caption = 'Void';
    }
    value(2; Payment)
    {
        Caption = 'Payment';
    }
    value(3; TransactionStatus)
    {
        Caption = 'TransactionStatus';
    }
    value(4; CardAcquisition)
    {
        Caption = 'CardAcquisition';
    }
    value(5; AbortAcquireCard)
    {
        Caption = 'AbortAcquireCard';
    }
    value(6; RejectNotification)
    {
        Caption = 'RejectNotification';
    }
    value(7; DisableContract)
    {
        Caption = 'DisableContract';
    }
}