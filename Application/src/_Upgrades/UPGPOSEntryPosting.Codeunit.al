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
        RemoveLeftoverSalesDeferralRows();
    end;

    local procedure UpgradePOSEntryDeferralSchedule()
    var
        DeferralHeader: Record "Deferral Header";
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

    internal procedure RemoveLeftoverSalesDeferralRows()
    begin
        UpgradeStep := 'RemoveLeftoverSalesDeferralRows';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Entry Posting', UpgradeStep);

        if TryLogSalesDeferralRows() then;
        DeleteSalesDeferralPostingBufferRows();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure DeleteSalesDeferralPostingBufferRows()
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
    begin
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        if not DeferralPostingBuffer.IsEmpty() then
            DeferralPostingBuffer.DeleteAll();
    end;

    internal procedure IsModifiedAfterCreation(CreatedAt: DateTime; ModifiedAt: DateTime): Boolean
    begin
        exit((CreatedAt <> 0DT) and (ModifiedAt > CreatedAt));
    end;

    [TryFunction]
    local procedure TryLogSalesDeferralRows()
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        Sentry: Codeunit "NPR Sentry";
        DocumentNo: Code[20];
        CreatedAt: DateTime;
        ModifiedAt: DateTime;
        MoreRows: Boolean;
        OwnsTransaction: Boolean;
        DocumentModifiedRows: Integer;
        DocumentRows: Integer;
        Documents: Integer;
        ModifiedRows: Integer;
        PartNo: Integer;
        SalesRows: Integer;
        Parts: List of [Text];
        Part: TextBuilder;
        TransactionNameTok: Label 'Deferral Posting Buffer cleanup', Locked = true;
        OperationTok: Label 'bc.upgrade.deferral_buffer_cleanup', Locked = true;
        SalesRowsTagTok: Label 'deferral.sales_rows', Locked = true;
        ModifiedRowsTagTok: Label 'deferral.modified_rows', Locked = true;
        CallStackTok: Label 'NPR UPG POS Entry Posting(RemoveLeftoverSalesDeferralRows)', Locked = true;
        HeaderLbl: Label 'The upgrade deletes %1 leftover Sales rows of %2 documents from the Deferral Posting Buffer, %3 rows modified after creation, part %4 of %5. The deferral posting bug fixed in CORE-2651 left these rows.', Locked = true;
        ColumnsLbl: Label 'Document No.,Grouped Rows,Modified Rows,Created At,Last Modified At', Locked = true;
        DocumentLbl: Label '%1,%2,%3,%4,%5', Locked = true;
    begin
        DeferralPostingBuffer.ReadIsolation := IsolationLevel::ReadCommitted;
        DeferralPostingBuffer.SetCurrentKey("Deferral Doc. Type", "Document No.", "Deferral Line No.");
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        DeferralPostingBuffer.SetLoadFields("Document No.");
        if not DeferralPostingBuffer.FindSet() then
            exit;

        repeat
            DocumentNo := DeferralPostingBuffer."Document No.";
            DocumentRows := 0;
            DocumentModifiedRows := 0;
            CreatedAt := 0DT;
            ModifiedAt := 0DT;
            repeat
                DocumentRows += 1;
                if IsModifiedAfterCreation(DeferralPostingBuffer.SystemCreatedAt, DeferralPostingBuffer.SystemModifiedAt) then
                    DocumentModifiedRows += 1;
                if (DeferralPostingBuffer.SystemCreatedAt <> 0DT) and ((CreatedAt = 0DT) or (DeferralPostingBuffer.SystemCreatedAt < CreatedAt)) then
                    CreatedAt := DeferralPostingBuffer.SystemCreatedAt;
                if DeferralPostingBuffer.SystemModifiedAt > ModifiedAt then
                    ModifiedAt := DeferralPostingBuffer.SystemModifiedAt;
                MoreRows := DeferralPostingBuffer.Next() <> 0;
            until (not MoreRows) or (DeferralPostingBuffer."Document No." <> DocumentNo);
            Documents += 1;
            SalesRows += DocumentRows;
            ModifiedRows += DocumentModifiedRows;
            if Part.Length() = 0 then begin
                Part.AppendLine();
                Part.Append(ColumnsLbl);
            end;
            Part.AppendLine();
            Part.Append(StrSubstNo(DocumentLbl, DocumentNo, Format(DocumentRows, 0, 9), Format(DocumentModifiedRows, 0, 9), Format(CreatedAt, 0, 9), Format(ModifiedAt, 0, 9)));
            if (Documents mod 50 = 0) or not MoreRows then begin
                Parts.Add(Part.ToText());
                Part.Clear();
            end;
        until not MoreRows;

        OwnsTransaction := not Sentry.HasActiveTransaction();
        if OwnsTransaction then
            Sentry.InitScopeAndTransaction(TransactionNameTok, OperationTok);
        Sentry.AddTransactionTag(SalesRowsTagTok, Format(SalesRows, 0, 9));
        Sentry.AddTransactionTag(ModifiedRowsTagTok, Format(ModifiedRows, 0, 9));
        for PartNo := 1 to Parts.Count() do
            Sentry.AddError(StrSubstNo(HeaderLbl, Format(SalesRows, 0, 9), Format(Documents, 0, 9), Format(ModifiedRows, 0, 9), Format(PartNo, 0, 9), Format(Parts.Count(), 0, 9)) + Parts.Get(PartNo), CallStackTok);
        if OwnsTransaction then
            Sentry.FinalizeScope();
    end;
}
