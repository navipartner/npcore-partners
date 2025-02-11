enum 6059788 "NPR ES Return Reason"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; CORRECTION_1)
    {
        Caption = 'Correction 1';
    }
    value(2; CORRECTION_2)
    {
        Caption = 'Correction 2';
    }
    value(3; CORRECTION_3)
    {
        Caption = 'Correction 3';
    }
    value(4; CORRECTION_4)
    {
        Caption = 'Correction 4';
    }
}
