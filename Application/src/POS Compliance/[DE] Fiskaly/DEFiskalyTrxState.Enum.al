enum 6014499 "NPR DE Fiskaly Trx. State"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    Caption = 'DE Fiskaly Transaction State';

    value(0; Unknown) { Caption = 'Unknown'; }
    value(1; ACTIVE) { Caption = 'ACTIVE'; }
    value(2; FINISHED) { Caption = 'FINISHED'; }
    value(3; CANCELLED) { Caption = 'CANCELLED'; }
}
