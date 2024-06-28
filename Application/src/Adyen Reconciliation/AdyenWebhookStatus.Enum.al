enum 6059767 "NPR Adyen Webhook Status"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; "New")
    {
        Caption = 'New';
    }
    value(10; "Processed")
    {
        Caption = 'Processed';
    }
    value(20; "Error")
    {
        Caption = 'Error';
    }
    value(30; "Canceled")
    {
        Caption = 'Canceled';
    }
}
