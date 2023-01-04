codeunit 6014496 "NPR Reten. Pol. Install"
{
    // based on codeunit 3999 "Reten. Pol. Install - BaseApp" from Base App
    Access = Internal;

    Subtype = Install;
    Permissions =
        tabledata "Retention Period" = ri,
        tabledata "Retention Policy Setup" = ri;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";

    trigger OnInstallAppPerCompany()
    begin
        AddAllowedTables();
    end;

    procedure AddAllowedTables()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        // if you add a new table here, also update codeunit 6059926 "NPR Retail Logs Delete"
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Reten. Pol. Install', 'AddAllowedTables');

        // if additional filters are needed on record, see codeunit 3999 procedure AddChangeLogEntryToAllowedTables() in Base App
        // if want to use Data Archive when deleting the record, also update codeunit 6059927 "NPR Reten. Pol. Data Archive"
        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install")) then begin
            AddAllowedTable(Database::"NPR Nc Task", Enum::"Retention Period Enum"::"1 Week", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR Data Log Record", Enum::"Retention Period Enum"::"1 Week", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR Data Log Field", Enum::"Retention Period Enum"::"1 Week", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR POS Entry Output Log", Enum::"Retention Period Enum"::"3 Months", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR Nc Import Entry", Enum::"Retention Period Enum"::"1 Month", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR POS Posting Log", Enum::"Retention Period Enum"::"6 Months", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR NpCs Arch. Document", Enum::"Retention Period Enum"::"1 Year", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR Exchange Label", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR NpGp POS Sales Entry", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR EFT Transaction Request", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR Tax Free Voucher", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR POS Entry", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR POS Entry Tax Line", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR POS Period Register", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR POS Entry Sales Line", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR POS Entry Payment Line", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR POS Balancing Line", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR Replication Error Log", Enum::"Retention Period Enum"::"1 Month", Enum::"Reten. Pol. Deleting"::Default);
            AddAllowedTable(Database::"NPR BTF EndPoint Error Log", Enum::"Retention Period Enum"::"1 Month", Enum::"Reten. Pol. Deleting"::Default);

            AddAllowedTable(Database::"NPR MM Admis. Service Entry", Enum::"Retention Period Enum"::"NPR 14 Days", Enum::"Reten. Pol. Deleting"::Default);

#IF NOT BC17 AND NOT BC18
            AddAllowedTable(Database::"NPR EFT Receipt", Enum::"Retention Period Enum"::"6 Months", Enum::"Reten. Pol. Deleting"::"NPR Data Archive");
#ENDIF
            // if you add a new table above, also update codeunit 6059926 "NPR Retail Logs Delete"

            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install"));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSLayoutArchive')) then begin
            AddAllowedTable(Database::"NPR POS Layout Archive", Enum::"Retention Period Enum"::"6 Months", Enum::"Reten. Pol. Deleting"::Default);
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSLayoutArchive'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSSavedSales')) then begin
            AddPosSavedSalesRetentionPolicy();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSSavedSales'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure AddAllowedTable(TableId: Integer; RtnPeriodEnum: Enum "Retention Period Enum"; RetenPolDeleting: Enum "Reten. Pol. Deleting")
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        TableFilters: JsonArray;
    begin
        RecRef.Open(TableId);

        RetenPolAllowedTables.AddAllowedTable(TableId, RecRef.SystemCreatedAtNo(), 0, Enum::"Reten. Pol. Filtering"::Default, RetenPolDeleting, TableFilters);
        CreateRetentionPolicySetup(TableId, GetRetentionPeriodCode(RtnPeriodEnum));
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

    local procedure AddPosSavedSalesRetentionPolicy()
    var
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        if RetentionPolicySetup.Get(Database::"NPR POS Saved Sale Line") then
            RetentionPolicySetup.Delete(true);
        if RetenPolAllowedTables.IsAllowedTable(Database::"NPR POS Saved Sale Line") then
            RetenPolAllowedTables.RemoveAllowedTable(Database::"NPR POS Saved Sale Line");

        if RetentionPolicySetup.Get(Database::"NPR POS Saved Sale Entry") then
            RetentionPolicySetup.Delete(true);
        if RetenPolAllowedTables.IsAllowedTable(Database::"NPR POS Saved Sale Entry") then
            RetenPolAllowedTables.RemoveAllowedTable(Database::"NPR POS Saved Sale Entry");

        POSSavedSaleEntry.SetRange("Contains EFT Approval", true);
        RtnPeriodEnum := RtnPeriodEnum::"Never Delete";
        RecRef.GetTable(POSSavedSaleEntry);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, true, RecRef);

        POSSavedSaleEntry.SetRange("Contains EFT Approval", false);
        RtnPeriodEnum := RtnPeriodEnum::"3 Months";
        RecRef.GetTable(POSSavedSaleEntry);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR POS Saved Sale Entry", RecRef.SystemCreatedAtNo(), TableFilters);

        CreateRetentionPolicySetup(Database::"NPR POS Saved Sale Entry", GetRetentionPeriodCode(RtnPeriodEnum));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnBeforeOnRun', '', false, false)]
    local procedure AddAllowedTablesOnBeforeCompanyInit()
    var
        SystemInitialization: Codeunit "System Initialization";
    begin
        if SystemInitialization.IsInProgress() then
            AddAllowedTables();
    end;
}
