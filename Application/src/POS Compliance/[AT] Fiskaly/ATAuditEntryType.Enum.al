enum 6014682 "NPR AT Audit Entry Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "POS Entry")
    {
        Caption = 'POS Entry';
    }
    value(1; "Control Transaction")
    {
        Caption = 'Control Transaction';
    }
}