enum 6014531 "NPR RS Pin Status Response"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0100; "SUCCESS")
    {
        Caption = 'SUCCESS', Locked = true;
    }
    value(2100; "PIN_WRONG")
    {
        Caption = 'PIN_WRONG', Locked = true;
    }
    value(2110; "PIN_ENTRY_EXCEEDED")
    {
        Caption = 'PIN_ENTRY_EXCEEDED', Locked = true;
    }
    value(1300; "SMART_CARD_NOT_INSERTED")
    {
        Caption = 'SMART_CARD_NOT_INSERTED', Locked = true;
    }
    value(2220; "SECURE_ELEMENT_FAILURE")
    {
        Caption = 'SECURE_ELEMENT_FAILURE', Locked = true;
    }
    value(2400; "SDC_DEVICE_NOT_CONFIGURED_FOR_SIGN")
    {
        Caption = 'SDC_DEVICE_NOT_CONFIGURED_FOR_SIGN', Locked = true;
    }
    value(1999; "ESDC_PIN_NOT_PASS")
    {
        Caption = 'ESDC_PIN_NOT_PASS', Locked = true;
    }
}