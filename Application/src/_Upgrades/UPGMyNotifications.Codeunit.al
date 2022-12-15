codeunit 6060023 "NPR UPG My Notifications"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG My Notifications', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG My Notifications")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        DoUpgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG My Notifications"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure DoUpgrade()
    var
        MyNotifications: Record "My Notifications";
        POSUnitNotificationIdLbl: Label '407f8cda-a82f-46d2-967e-85bb9153aca2', Locked = true;
    begin
        MyNotifications.SetRange("Notification Id", POSUnitNotificationIdLbl);
        if MyNotifications.IsEmpty then
            exit;

        MyNotifications.DeleteAll();
    end;
}
