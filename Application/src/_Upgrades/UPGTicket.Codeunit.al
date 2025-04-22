codeunit 6248400 "NPR UPGTicket"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        _UpgradeTag: Codeunit "Upgrade Tag";
        _UpgradeTagDef: Codeunit "NPR Upgrade Tag Definitions";
        _UpgradeStep: Text;
        _LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";

    trigger OnUpgradePerCompany()
    begin
        UpgradeCouponForceAmountBoolToEnum();
    end;

    local procedure UpgradeCouponForceAmountBoolToEnum()
    var
        TicketCouponProfile: Record "NPR TM CouponProfile";
    begin
        _UpgradeStep := 'CouponProfileForceAmountBoolToEnum';
        if (HasUpgradeTag()) then
            exit;

        TicketCouponProfile.SetRange(ForceTicketAmount, true);
        TicketCouponProfile.ModifyAll(ForceAmount, "NPR TM CouponForceAmount"::AMOUNT_INCL_VAT);

        SetUpgradeTag();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if (_UpgradeTag.HasUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPGTicket", _UpgradeStep))) then
            exit(true);
        _LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPGTicket', _UpgradeStep);
        exit(false);
    end;

    local procedure SetUpgradeTag()
    begin
        _UpgradeTag.SetUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPGTicket", _UpgradeStep));
        _LogMessageStopwatch.LogFinish();
    end;
}