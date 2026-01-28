enumextension 6014401 "NPR Retention Period Enum" extends "Retention Period Enum"
{
    value(6014400; "NPR 14 Days")
    {
        Caption = '14 Days';
        Implementation = "Retention Period" = "NPR Retention Period Impl.";
        ObsoleteState = Pending;
        ObsoleteTag = '2026-01-28';
        ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';
    }
    value(6014401; "NPR 2 Years")
    {
        Caption = '2 Years';
        Implementation = "Retention Period" = "NPR Retention Period Impl.";
        ObsoleteState = Pending;
        ObsoleteTag = '2026-01-28';
        ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';
    }
    value(6014402; "NPR 6 Years")
    {
        Caption = '6 Years';
        Implementation = "Retention Period" = "NPR Retention Period Impl.";
        ObsoleteState = Pending;
        ObsoleteTag = '2026-01-28';
        ObsoleteReason = 'No longer relevant, as NaviPartner uses its own retention policy handler in BC26+.';
    }
}