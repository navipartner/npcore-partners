codeunit 6150877 "NPR Upgrade Variety Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Variety Setup', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Variety Setup")) then begin
            EnablePopupFields();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Variety Setup"));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure EnablePopupFields()
    var
        VarietySetup: Record "NPR Variety Setup";
    begin
        if VarietySetup.Get() and VarietySetup."Pop up Variety Matrix" then begin
            VarietySetup.SetPopupVarietyMatrixOnDocuments(true);
            VarietySetup.Modify();
        end;
    end;
}