codeunit 6151059 "NPR UPG NpEc Store Loc. Code"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG NpEc Store Loc. Code', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NpEc Store Loc. Code", 'CopyLocationCodeToCorrectLengthField')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CopyLocationCodes();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NpEc Store Loc. Code", 'CopyLocationCodeToCorrectLengthField'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CopyLocationCodes()
    var
        NpEcStore: Record "NPR NpEc Store";
    begin
        NpEcStore.SetFilter("Location Code", '<>%1', '');
        if not NpEcStore.FindSet() then
            exit;
        repeat
            NpEcStore.LocationCode := CopyStr(NpEcStore."Location Code", 1, MaxStrLen(NpEcStore.LocationCode));
            NpEcStore.Modify();
        until NpEcStore.Next() = 0;
    end;
}
