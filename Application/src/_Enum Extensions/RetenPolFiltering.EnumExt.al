#if not (BC17 or BC18)
enumextension 6014409 "NPR Reten. Pol. Filtering" extends "Reten. Pol. Filtering"
{
    value(6014400; "NPR Reten. Pol. Filtering")
    {
        Caption = 'NPR Custom Reten. Pol. Filt.';
        Implementation = "Reten. Pol. Filtering" = "NPR Reten. Pol. Filtering Impl";
        ObsoleteState = Pending;
        ObsoleteTag = '2026-01-28';
        ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';
    }
}
#endif