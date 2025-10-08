codeunit 6248569 "NPR UPG POS Entry Posting"
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
        UpgradePOSEntryDeferralSchedule();
        UpgradeMembershipEntryLinkDates();
    end;

    local procedure UpgradePOSEntryDeferralSchedule()
    var
        DeferralHeader: Record "Deferral Header";
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        POSEntry: Record "NPR POS Entry";
        POSEntryNo: Integer;
    begin
        UpgradeStep := 'UpgradePOSEntryDeferralSchedule';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Entry Posting', UpgradeStep);

        DeferralHeader.SetCurrentKey("Deferral Doc. Type", "Gen. Jnl. Template Name", "Gen. Jnl. Batch Name", "Document Type");
        DeferralHeader.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::"G/L");
        DeferralHeader.SetRange("Gen. Jnl. Template Name", '');
        DeferralHeader.SetRange("Gen. Jnl. Batch Name", '');
        DeferralHeader.SetRange("Document Type", Database::"NPR POS Entry Sales Line");
        if DeferralHeader.FindSet() then
            repeat
                if Evaluate(POSEntryNo, DeferralHeader."Document No.") then begin
                    POSEntry.SetRange("Entry No.", POSEntryNo);
                    POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);
                    if not POSEntry.IsEmpty() then
                        DeferralHeader.Delete(true);
                end;
            until DeferralHeader.Next() = 0;

        POSEntry.SetFilter("Post Entry Status", '<>%1', POSEntry."Post Entry Status"::Posted);
        if POSEntry.FindSet() then
            repeat
                DeferralPostingBuffer.SetRange("Document No.", Format(POSEntry."Entry No."));
                if not DeferralPostingBuffer.IsEmpty() then
                    DeferralPostingBuffer.DeleteAll();
            until POSEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeMembershipEntryLinkDates()
    var
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
        MembershipEntryLink2: Record "NPR MM Membership Entry Link";
    begin
        UpgradeStep := 'UpgradePOSEntryDeferralSchedule';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Entry Posting', UpgradeStep);

        MembershipEntryLink.SetRange(Context, MembershipEntryLink.Context::CANCEL); // We have correctly assinged dates only for Cancel
        MembershipEntryLink.SetLoadFields("Initial Valid Until Date", "New Valid Until Date", "Context Period Starting Date", "Context Period Ending Date");
        if MembershipEntryLink.FindSet() then
            repeat
                MembershipEntryLink2 := MembershipEntryLink;
                if MembershipEntryLink."New Valid Until Date" <> 0D then
                    MembershipEntryLink."Context Period Starting Date" := MembershipEntryLink."New Valid Until Date";
                if MembershipEntryLink."Initial Valid Until Date" <> 0D then
                    MembershipEntryLink."Context Period Ending Date" := MembershipEntryLink."Initial Valid Until Date";
                MembershipEntryLink."New Valid Until Date" := 0D;
                MembershipEntryLink."Initial Valid Until Date" := 0D;
                if Format(MembershipEntryLink) <> Format(MembershipEntryLink2) then
                    MembershipEntryLink.Modify();
            until MembershipEntryLink.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
