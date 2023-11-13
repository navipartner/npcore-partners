#IF NOT BC17 AND NOT BC18
enumextension 6014409 "NPR Reten. Pol. Filtering" extends "Reten. Pol. Filtering"
{
    value(6014400; "NPR Nc Task")
    {
        Caption = 'Nc Task';
        Implementation = "Reten. Pol. Filtering" = "NPR Nc Task Filtering Impl.";
    }
}
#ENDIF