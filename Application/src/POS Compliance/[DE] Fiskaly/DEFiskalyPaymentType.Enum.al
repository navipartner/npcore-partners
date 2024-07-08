enum 6014502 "NPR DE Fiskaly Payment Type"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    Caption = 'DE Fiskaly Payment Type';

    value(0; " ") { Caption = ' '; }
    value(1; CASH) { Caption = 'CASH'; }
    value(2; NON_CASH) { Caption = 'NON_CASH'; }
}
