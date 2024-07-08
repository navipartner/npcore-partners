codeunit 6014418 "NPR UPG Azure Functions Data"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Azure Functions Data', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Azure Functions Data")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateRegToPos();
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Azure Functions Data"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateRegToPos()
    var
        AFArgumentsNotificHub: Record "NPR AF Arguments - Notific.Hub";
        AFNotificationHub: Record "NPR AF Notification Hub";
    begin
        if AFArgumentsNotificHub.FindSet() then
            repeat
                AFArgumentsNotificHub."To POS Unit No." := AFArgumentsNotificHub."To Register No.";
                AFArgumentsNotificHub."From POS Unit No." := AFArgumentsNotificHub."From Register No.";
                AFArgumentsNotificHub.Modify();
            until AFArgumentsNotificHub.Next() = 0;

        if AFNotificationHub.FindSet() then
            repeat
                AFNotificationHub."To POS Unit No." := AFNotificationHub."To Register No.";
                AFNotificationHub."From POS Unit No." := AFNotificationHub."From Register No.";

                AFNotificationHub."Handled Pos Unit No." := AFNotificationHub."Handled Register";
                AFNotificationHub."Cancelled Pos Unit No." := AFNotificationHub."Cancelled Register";
                AFNotificationHub."Completed Pos Unit No." := AFNotificationHub."Completed Register";
                AFNotificationHub."Temp Current Pos Unit No." := AFNotificationHub."Temp Current Register";

                AFNotificationHub.Modify();
            until AFNotificationHub.Next() = 0;
    end;
}
