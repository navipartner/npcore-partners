enum 6014464 "NPR ND Entry Att. Int. Type"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Report Parameters")
    {
        Caption = 'Report Parameters';
    }

}
