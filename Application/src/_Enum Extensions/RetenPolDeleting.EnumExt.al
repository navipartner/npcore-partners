#if not (BC17 or BC18)
enumextension 6014404 "NPR Reten. Pol. Deleting" extends "Reten. Pol. Deleting"
{
    value(6014400; "NPR Data Archive")
    {
        Caption = 'Data Archive';
        Implementation = "Reten. Pol. Deleting" = "NPR Reten. Pol. Delete. Impl.";
        ObsoleteState = Pending;
        ObsoleteTag = '2026-01-28';
        ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';
    }
    value(6014401; "NPR Reten. Pol. Deleting")
    {
        Caption = 'NPR Custom Reten. Pol. Del.';
        Implementation = "Reten. Pol. Deleting" = "NPR Reten. Pol. Deleting Impl.";
        ObsoleteState = Pending;
        ObsoleteTag = '2026-01-28';
        ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';
    }
}
#endif