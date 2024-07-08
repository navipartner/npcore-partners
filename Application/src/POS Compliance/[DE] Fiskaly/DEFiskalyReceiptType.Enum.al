enum 6014500 "NPR DE Fiskaly Receipt Type"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    Caption = 'DE Fiskaly Receipt Type';

    value(0; Unknown) { Caption = 'Unknown'; }
    value(1; RECEIPT) { Caption = 'RECEIPT'; }
    value(2; TRAINING) { Caption = 'TRAINING'; }
    value(3; TRANSFER) { Caption = 'TRANSFER'; }
    value(4; "ORDER") { Caption = 'ORDER'; }
    value(5; CANCELLATION) { Caption = 'CANCELLATION'; }
    value(6; ABORT) { Caption = 'ABORT'; }
    value(7; BENEFIT_IN_KIND) { Caption = 'BENEFIT_IN_KIND'; }
    value(8; INVOICE) { Caption = 'INVOICE'; }
    value(9; OTHER) { Caption = 'OTHER'; }
    value(10; ANNULATION) { Caption = 'ANNULATION'; }
}
