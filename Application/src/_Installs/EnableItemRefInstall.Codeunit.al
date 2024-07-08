codeunit 6014503 "NPR Enable Item Ref. Install"
{
    Access = Internal;
#if BC17 or BC18
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    begin
        AutoEnableItemReference();
    end;

    local procedure AutoEnableItemReference()
    var
        EnableItemRefUpgr: Codeunit "NPR Enable Item Ref. Upgr.";
    begin
        EnableItemRefUpgr.AutoEnableItemReference();
    end;
#endif
}