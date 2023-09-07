enum 6014580 "NPR CRO Audit Entry Type"
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