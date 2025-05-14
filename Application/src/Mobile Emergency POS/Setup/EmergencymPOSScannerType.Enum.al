enum 6059892 "NPR Emergency mPOS ScannerType"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; BinaryEye)
    {
        Caption = 'Camera', Locked = true;
    }
    value(1; HID)
    {
        Caption = 'HID', Locked = true;
    }
}
