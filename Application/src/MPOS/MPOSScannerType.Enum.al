enum 6059896 "NPR MPOS Scanner Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; None)
    {
        Caption = 'None', Locked = true;
    }
    value(1; Camera)
    {
        Caption = 'Camera', Locked = true;
    }
    value(2; Zebra)
    {
        Caption = 'Zebra', Locked = true;
    }
    value(3; Honeywell)
    {
        Caption = 'Honeywell', Locked = true;
    }
    value(4; ZebraDataWedge)
    {
        Caption = 'Zebra DataWedge', Locked = true;
    }
    value(5; HID)
    {
        Caption = 'HID', Locked = true;
    }
}
