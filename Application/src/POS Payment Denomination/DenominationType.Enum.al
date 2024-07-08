enum 6014509 "NPR Denomination Type"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = true;

    value(0; COIN) { Caption = 'Coin'; }
    value(1; BILL) { Caption = 'Banknote'; }
}