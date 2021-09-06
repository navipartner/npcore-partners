codeunit 6150922 "NPR UPG Customer Templates"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Customer Templates', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Customer Templates")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade preconditions
        if not AppropriateVersion() then
            exit;

        // Run upgrade code
        CustomerTemplate2CustomerTempl();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Customer Templates"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure AppropriateVersion(): Boolean
    var
        RefferenceAppVersion: Version;
        CurrentAppVersion: Version;
        ModInfo: ModuleInfo;
    begin
        RefferenceAppVersion := Version.Create(6, 0, 0);
        NavApp.GetCurrentModuleInfo(ModInfo);
        CurrentAppVersion := ModInfo.AppVersion();

        exit(CurrentAppVersion > RefferenceAppVersion);
    end;

    local procedure CustomerTemplate2CustomerTempl()
    var
        CustomerTemplate: Record "Customer Template";
        CustomerTempl: Record "Customer Templ.";
    begin
        if CustomerTemplate.IsEmpty then
            exit;

        CustomerTemplate.FindSet();
        repeat
            if not CustomerTempl.Get(CustomerTemplate.Code) then begin
                CustomerTempl.Init();
                CustomerTempl.TransferFields(CustomerTemplate);
                CustomerTempl.Insert();
            end;
        until CustomerTemplate.Next() = 0;

        CustomerTemplate.DeleteAll();
    end;
}
