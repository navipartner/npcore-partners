codeunit 6014497 "NPR Reten. Pol. Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    var
        RetenPolInstall: Codeunit "NPR Reten. Pol. Install";
    begin
        RetenPolInstall.AddAllowedTables(true);
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        RetenPolInstall.InitiateV2RetentionPolicyUpgrade();
#endif
    end;
}
