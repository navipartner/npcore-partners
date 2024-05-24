enum 6014649 "NPR Adyen Webhook Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; standard)
    {
        Caption = 'standard';
    }
    value(10; "account-settings-notification")
    {
        Caption = 'account-settings-notification';
    }
    value(20; "banktransfer-notification")
    {
        Caption = 'banktransfer-notification';
    }
    value(30; "boletobancario-notification")
    {
        Caption = 'boletobancario-notification';
    }
    value(40; "directdebit-notification")
    {
        Caption = 'directdebit-notification';
    }
    value(50; "ach-notification-of-change-notification")
    {
        Caption = 'ach-notification-of-change-notification';
    }
    value(60; "pending-notification")
    {
        Caption = 'pending-notification';
    }
    value(70; "ideal-notification")
    {
        Caption = 'ideal-notification';
    }
    value(80; "ideal-pending-notification")
    {
        Caption = 'ideal-pending-notification';
    }
    value(90; "report-notification")
    {
        Caption = 'report-notification';
    }
    value(100; "rreq-notification")
    {
        Caption = 'rreq-notification';
    }
}
