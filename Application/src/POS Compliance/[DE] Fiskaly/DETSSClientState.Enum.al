enum 6014498 "NPR DE TSS Client State"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    Caption = 'DE TSS Client State';

    value(0; Unknown) { Caption = 'Unknown'; }
    value(1; REGISTERED) { Caption = 'REGISTERED'; }
    value(2; DEREGISTERED) { Caption = 'DEREGISTERED'; }
}
