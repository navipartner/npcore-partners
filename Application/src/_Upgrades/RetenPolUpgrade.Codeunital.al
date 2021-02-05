codeunit 6014497 "NPR Reten. Pol. Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    var
        RetenPolInstall: Codeunit "NPR Reten. Pol. Install";
    begin
        RetenPolInstall.AddAllowedTables();
    end;
}
