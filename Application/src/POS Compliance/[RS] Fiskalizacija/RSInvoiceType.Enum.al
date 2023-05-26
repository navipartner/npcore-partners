enum 6014520 "NPR RS Invoice Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; NORMAL)
    {
        Caption = 'Normal', Locked = true;
    }
    value(1; ADVANCE)
    {
        Caption = 'Advance', Locked = true;
    }
    value(2; TRAINING)
    {
        Caption = 'Training', Locked = true;
    }
    value(3; COPY)
    {
        Caption = 'Copy', Locked = true;
    }
    value(4; PROFORMA)
    {
        Caption = 'Proforma', Locked = true;
    }
}