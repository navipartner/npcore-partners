codeunit 6248212 "NPR UPG Global Sales"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        _LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        _UpgradeTag: Codeunit "Upgrade Tag";
        _UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        _UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        SetIsReturnOnGlobalPOSSalesLine();
    end;

    internal procedure SetIsReturnOnGlobalPOSSalesLine()
    var
        NpGpPOSSalesLine: Record "NPR NpGp POS Sales Line";
    begin
        _UpgradeStep := 'SetIsReturnOnGlobalPOSSalesLine';
        if HasUpgradeTag() then
            exit;
        LogStart();

        NpGpPOSSalesLine.SetFilter(Quantity, '<%1', 0);
        NpGpPOSSalesLine.ModifyAll(Return, true);

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        exit(_UpgradeTag.HasUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Global Sales", _UpgradeStep)));
    end;

    local procedure SetUpgradeTag()
    begin
        if HasUpgradeTag() then
            exit;
        _UpgradeTag.SetUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Global Sales", _UpgradeStep));
    end;

    local procedure LogStart()
    begin
        _LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Global Sales', _UpgradeStep);
    end;

    local procedure LogFinish()
    begin
        _LogMessageStopwatch.LogFinish();
    end;
}