report 6014436 "NPR Update Retention Policy"
{
    Caption = 'Update Retention Policy';
    UsageCategory = None;
    ProcessingOnly = true;
    UseRequestPage = false;
#if not BC17
    Extensible = false;
#endif

    Permissions =
        tabledata "Retention Period" = rim,
        tabledata "Retention Policy Setup" = rimd,
        tabledata "NPR Data Log Field" = rd,
        tabledata "NPR Tax Free Voucher" = rd,
        tabledata "NPR POS Saved Sale Entry" = rd,
        tabledata "NPR POS Saved Sale Line" = rd,
        tabledata "NPR NpCs Arch. Document" = rd,
        tabledata "NPR Nc Task" = rd,
        tabledata "NPR Exchange Label" = rd,
        tabledata "NPR NpGp POS Sales Entry" = rd,
        tabledata "NPR POS Entry Output Log" = rd,
        tabledata "NPR Nc Import Entry" = rd,
        tabledata "NPR POS Period Register" = rd,
        tabledata "NPR POS Entry" = rd,
        tabledata "NPR POS Entry Sales Line" = rd,
        tabledata "NPR POS Entry Payment Line" = rd,
        tabledata "NPR POS Balancing Line" = rd,
        tabledata "NPR POS Entry Tax Line" = rd,
        tabledata "NPR POS Posting Log" = rd,
        tabledata "NPR EFT Transaction Request" = rd,
        tabledata "NPR Aux. Value Entry" = rd,
        tabledata "NPR Aux. Item Ledger Entry" = rd,
        tabledata "NPR Replication Error Log" = rd,
        tabledata "NPR BTF EndPoint Error Log" = rd;

    trigger OnPreReport()
    var
        RtnPeriodEnum: Enum "Retention Period Enum";
        ConfirmUpdateLbl: Label 'System will update Retention Policy with NPCore defined tables. Continue?';
        SuccessfullyProcessedLbl: Label 'Successfully processed %1 tables', Comment = '%1-table count';
    begin
        if not Confirm(ConfirmUpdateLbl, false) then
            exit;

        SuccessfullyProcessedCount := 0;

        AddAllowedTable(Database::"NPR Nc Task", RtnPeriodEnum::"1 Week");

        AddAllowedTable(Database::"NPR Data Log Record", RtnPeriodEnum::"1 Week");
        AddAllowedTable(Database::"NPR Data Log Field", RtnPeriodEnum::"1 Week");

        AddAllowedTable(Database::"NPR POS Entry Output Log", RtnPeriodEnum::"3 Months");
        AddAllowedTable(Database::"NPR Nc Import Entry", RtnPeriodEnum::"1 Month");

        AddAllowedTable(Database::"NPR POS Posting Log", RtnPeriodEnum::"1 Week");

        AddAllowedTable(Database::"NPR POS Saved Sale Entry", RtnPeriodEnum::"3 Months");
        AddAllowedTable(Database::"NPR POS Saved Sale Line", RtnPeriodEnum::"3 Months");
        AddAllowedTable(Database::"NPR NpCs Arch. Document", RtnPeriodEnum::"1 Year");

        AddAllowedTable(Database::"NPR Exchange Label", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR NpGp POS Sales Entry", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR EFT Transaction Request", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR Tax Free Voucher", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR POS Entry", RtnPeriodEnum::"5 Years");

        AddAllowedTable(Database::"NPR POS Entry Tax Line", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR POS Period Register", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR POS Entry Sales Line", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR POS Entry Payment Line", RtnPeriodEnum::"5 Years");
        AddAllowedTable(Database::"NPR POS Balancing Line", RtnPeriodEnum::"5 Years");

        AddAllowedTable(Database::"NPR Replication Error Log", RtnPeriodEnum::"1 Month");
        AddAllowedTable(Database::"NPR BTF EndPoint Error Log", RtnPeriodEnum::"1 Month");

        AddAllowedTable(Database::"NPR MM Admis. Service Entry", RtnPeriodEnum::"NPR 14 Days");

        Message(SuccessfullyProcessedLbl, SuccessfullyProcessedCount);
    end;

    local procedure AddAllowedTable(TableId: Integer; RtnPeriodEnum: Enum "Retention Period Enum")
    var
        RecRef: RecordRef;
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        RecRef.Open(TableId);

        RetenPolAllowedTables.AddAllowedTable(TableId, RecRef.SystemCreatedAtNo());
        CreateRetentionPolicySetup(TableId, GetRetentionPeriodCode(RtnPeriodEnum));
        SuccessfullyProcessedCount += 1;
    end;

    local procedure CreateRetentionPolicySetup(TableId: Integer; RetentionPeriodCode: Code[20])
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if RetentionPolicySetup.Get(TableId) then
            RetentionPolicySetup.Delete(true);

        RetentionPolicySetup.Validate("Table Id", TableId);
        RetentionPolicySetup.Validate("Apply to all records", true);
        RetentionPolicySetup.Validate("Retention Period", RetentionPeriodCode);
        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Insert(true);
    end;

    local procedure GetRetentionPeriodCode(RtnPeriodEnum: Enum "Retention Period Enum"): Code[20]
    var
        RetentionPeriod: Record "Retention Period";
        RtnPeriodCode: Code[20];
    begin
        RtnPeriodCode := CopyStr(Format(RtnPeriodEnum), 1, MaxStrLen(RtnPeriodCode));

        if RetentionPeriodExists(RtnPeriodCode, RtnPeriodEnum, RetentionPeriod) then
            exit(RetentionPeriod.Code);

        RetentionPeriod.Code := RtnPeriodCode;
        RetentionPeriod.Description := CopyStr(Format(RtnPeriodEnum), 1, MaxStrLen(RetentionPeriod.Description));
        RetentionPeriod.Validate("Retention Period", RtnPeriodEnum);
        RetentionPeriod.Insert(true);
        exit(RetentionPeriod.Code);
    end;

    local procedure RetentionPeriodExists(RtnPeriodCode: Code[20]; RtnPeriodEnum: Enum "Retention Period Enum"; var RetentionPeriod: Record "Retention Period"): Boolean
    begin
        if RetentionPeriod.Get(RtnPeriodCode) then
            exit(true);

        RetentionPeriod.SetRange("Retention Period", RtnPeriodEnum);
        if RetentionPeriod.FindFirst() then
            exit(true);
        exit(false);
    end;

    var
        SuccessfullyProcessedCount: Integer;
}