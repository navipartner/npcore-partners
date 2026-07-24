// Value NAMES must equal the API licenseType codes so Evaluate() maps by name. Ordinals encode the period length in
// months (months01 = 1, months12 = 12) — the same scheme the legacy "NPR POS Lic. Billing Lic. Type" enum used, but
// NOT the same value set (quarter/months03 dropped, monthly/months01 added), so do not assume a 1:1 legacy mapping.
enum 6059789 "NPR License Term"
{
    Access = Internal;
    Extensible = false;
    Caption = 'NPR License Term';

    value(0; _)
    {
        Caption = '';
    }
    value(1; months01)
    {
        Caption = '1 Month';
    }
    value(12; months12)
    {
        Caption = '1 Year';
    }
}
