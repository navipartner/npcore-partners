enum 6014497 "NPR DE TSS State"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    Caption = 'DE TSS State';

    value(0; Unknown) { Caption = 'Unknown'; }
    value(1; CREATED) { Caption = 'CREATED'; }
    value(2; UNINITIALIZED) { Caption = 'UNINITIALIZED'; }
    value(3; INITIALIZED) { Caption = 'INITIALIZED'; }
    value(4; DISABLED) { Caption = 'DISABLED'; }
    value(5; DELETED) { Caption = 'DELETED'; }
    value(6; DEFECTIVE) { Caption = 'DEFECTIVE'; }
}
