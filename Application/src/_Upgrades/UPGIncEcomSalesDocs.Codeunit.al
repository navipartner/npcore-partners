#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248467 "NPR UPG Inc Ecom Sales Docs"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        CreateIncEcomSalesDocSetup();
    end;

    internal procedure CreateIncEcomSalesDocSetup()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        UpgradeStep := 'CreateIncEcomSalesDocSetup';
        if HasUpgradeTag() then
            exit;

        if not IncEcomSalesDocSetup.Get() then begin
            IncEcomSalesDocSetup.Init();
            IncEcomSalesDocSetup.Insert();

            IncEcomSalesDocSetup.Validate("Auto Proc Sales Order", true);
            IncEcomSalesDocSetup.Validate("Auto Proc Sales Ret Order", true);
            IncEcomSalesDocSetup.Modify(true);
        end;

        SetUpgradeTag();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", UpgradeStep)) then
            exit(true);
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Inc Ecom Sales Docs', UpgradeStep);
    end;

    local procedure SetUpgradeTag()
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#endif