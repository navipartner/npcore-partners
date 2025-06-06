#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
codeunit 6248472 "NPR UPG No Series Experience"
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
        UpgradeImplementationFieldOnNoSeries();
    end;

    internal procedure UpgradeImplementationFieldOnNoSeries()
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        FRAuditNoSeries: Record "NPR FR Audit No. Series";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
    begin
        UpgradeStep := 'UpgradeImplementationFieldOnNoSeries';
        if HasUpgradeTag() then
            exit;

        POSUnit.Reset();
        POSUnit.SetLoadFields("No.", "POS Audit Profile", "POS End of Day Profile");
        if POSUnit.FindSet() then
            repeat
                FRAuditNoSeries.SetLoadFields("Reprint No. Series", "JET No. Series", "Period No. Series", "Grand Period No. Series", "Yearly Period No. Series");
                if FRAuditNoSeries.Get(POSUnit."No.") then begin
                    UpdateImpementationInNoSriesLines(FRAuditNoSeries."Reprint No. Series", Enum::"No. Series Implementation"::Normal);
                    UpdateImpementationInNoSriesLines(FRAuditNoSeries."JET No. Series", Enum::"No. Series Implementation"::Normal);
                    UpdateImpementationInNoSriesLines(FRAuditNoSeries."Period No. Series", Enum::"No. Series Implementation"::Normal);
                    UpdateImpementationInNoSriesLines(FRAuditNoSeries."Grand Period No. Series", Enum::"No. Series Implementation"::Normal);
                    UpdateImpementationInNoSriesLines(FRAuditNoSeries."Yearly Period No. Series", Enum::"No. Series Implementation"::Normal);
                end;

                POSAuditProfile.SetLoadFields("Sale Fiscal No. Series", "Credit Sale Fiscal No. Series", "Balancing Fiscal No. Series", "Sales Ticket No. Series");
                if POSAuditProfile.Get(POSUnit."POS Audit Profile") then begin
                    UpdateImpementationInNoSriesLines(POSAuditProfile."Sale Fiscal No. Series", Enum::"No. Series Implementation"::Normal);
                    UpdateImpementationInNoSriesLines(POSAuditProfile."Credit Sale Fiscal No. Series", Enum::"No. Series Implementation"::Normal);
                    UpdateImpementationInNoSriesLines(POSAuditProfile."Balancing Fiscal No. Series", Enum::"No. Series Implementation"::Normal);

                    UpdateImpementationInNoSriesLines(POSAuditProfile."Sales Ticket No. Series", Enum::"No. Series Implementation"::Sequence);
                end;

                POSEndofDayProfile.SetLoadFields("Bank Deposit Ref. Nos.", "Move to Bin Ref. Nos.", "BT OUT: Bank Deposit Ref. Nos.", "BT OUT: Move to Bin Ref. Nos.", "BT IN: Tr.from Bank Ref. Nos.", "BT IN: Move fr. Bin Ref. Nos.");
                if POSEndofDayProfile.Get(POSUnit."POS End of Day Profile") then begin
                    UpdateImpementationInNoSriesLines(POSEndofDayProfile."Bank Deposit Ref. Nos.", Enum::"No. Series Implementation"::Sequence);
                    UpdateImpementationInNoSriesLines(POSEndofDayProfile."Move to Bin Ref. Nos.", Enum::"No. Series Implementation"::Sequence);
                    UpdateImpementationInNoSriesLines(POSEndofDayProfile."BT OUT: Bank Deposit Ref. Nos.", Enum::"No. Series Implementation"::Sequence);
                    UpdateImpementationInNoSriesLines(POSEndofDayProfile."BT OUT: Move to Bin Ref. Nos.", Enum::"No. Series Implementation"::Sequence);
                    UpdateImpementationInNoSriesLines(POSEndofDayProfile."BT IN: Tr.from Bank Ref. Nos.", Enum::"No. Series Implementation"::Sequence);
                    UpdateImpementationInNoSriesLines(POSEndofDayProfile."BT IN: Move fr. Bin Ref. Nos.", Enum::"No. Series Implementation"::Sequence);
                end;
            until POSUnit.Next() = 0;
        SetUpgradeTag();
    end;

    local procedure UpdateImpementationInNoSriesLines(NoSerisCode: Code[20]; Implementation: Enum "No. Series Implementation")
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSerisCode = '' then
            exit;

        NoSeriesLine.Reset();
        NoSeriesLine.SetRange("Series Code", NoSerisCode);
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.SetFilter(Implementation, '<>%1', Implementation);
        if not NoSeriesLine.IsEmpty then
            NoSeriesLine.ModifyAll(Implementation, Implementation, true);
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG No Series Experience", UpgradeStep)) then
            exit(true);
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG No Series Experience', UpgradeStep);
    end;

    local procedure SetUpgradeTag()
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG No Series Experience", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#ENDIF