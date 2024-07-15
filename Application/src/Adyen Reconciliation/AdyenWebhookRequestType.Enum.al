enum 6059768 "NPR Adyen Webhook Request Type"
{
    Extensible = true;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; " ")
    {
        Caption = ' ';
    }
    value(10; Reconciliation)
    {
        Caption = 'Reconciliation';
    }
    value(20; "Pay by Link")
    {
        Caption = 'Pay by Link';
    }
    value(30; "Endless aisle")
    {
        Caption = 'Endless aisle';
    }
}