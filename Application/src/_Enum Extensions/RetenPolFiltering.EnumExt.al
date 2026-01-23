#if (BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
enumextension 6014409 "NPR Reten. Pol. Filtering" extends "Reten. Pol. Filtering"
{
    value(6014400; "NPR Reten. Pol. Filtering")
    {
        Caption = 'NPR Custom Reten. Pol. Filt.';
        Implementation = "Reten. Pol. Filtering" = "NPR Reten. Pol. Filtering Impl";
    }
}
#endif