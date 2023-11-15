#IF NOT BC17 AND NOT BC18
enumextension 6014409 "NPR Reten. Pol. Filtering" extends "Reten. Pol. Filtering"
{
    value(6014400; "NPR Reten. Pol. Filtering")
    {
        Caption = 'NPR Custom Reten. Pol. Filt.';
        Implementation = "Reten. Pol. Filtering" = "NPR Reten. Pol. Filtering Impl";
    }
}
#ENDIF