enum 6014510 "NPR Denomination Target"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = true;

    value(0; Counted) { Caption = 'Counted Amount'; }
    value(1; BankDeposit) { Caption = 'Bank Deposit Amount'; }
    value(2; MoveToBin) { Caption = 'Move to Bin Amount'; }
}
