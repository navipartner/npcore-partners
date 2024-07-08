enum 6014501 "NPR DE Fiskaly VAT Rate"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    Caption = 'DE Fiskaly VAT Rate';

    value(0; " ") { Caption = ' '; }
    value(1; NORMAL) { Caption = 'NORMAL'; }
    value(2; REDUCED_1) { Caption = 'REDUCED_1'; }
    value(3; SPECIAL_RATE_1) { Caption = 'SPECIAL_RATE_1'; }
    value(4; SPECIAL_RATE_2) { Caption = 'SPECIAL_RATE_2'; }
    value(5; NULL) { Caption = 'NULL'; }
}
