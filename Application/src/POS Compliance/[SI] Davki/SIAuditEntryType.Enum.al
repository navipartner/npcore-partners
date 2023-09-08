enum 6014533 "NPR SI Audit Entry Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "POS Entry")
    {
        Caption = 'POS Entry';
    }
}