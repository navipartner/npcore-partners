codeunit 6014496 "NPR Reten. Pol. Install"
{
    // based on codeunit 3999 "Reten. Pol. Install - BaseApp" from Base App

    Subtype = Install;
    Access = Internal;
    Permissions =
        tabledata "Retention Period" = ri,
        tabledata "Retention Policy Setup" = ri,
        tabledata "NPR Data Log Record" = rd,
        tabledata "NPR Data Log Field" = rd,
        tabledata "NPR Tax Free Voucher" = rd,
        tabledata "NPR POS Quote Entry" = rd,
        tabledata "NPR POS Quote Line" = rd,
        tabledata "NPR NpCs Arch. Document" = rd,
        tabledata "NPR Nc Task" = rd,
        tabledata "NPR Exchange Label" = rd,
        tabledata "NPR NpGp POS Sales Entry" = rd,
        tabledata "NPR POS Entry Output Log" = rd,
        tabledata "NPR Nc Import Entry" = rd,
        tabledata "NPR POS Period Register" = rd,
        tabledata "NPR POS Entry" = rd,
        tabledata "NPR POS Sales Line" = rd,
        tabledata "NPR POS Payment Line" = rd,
        tabledata "NPR POS Balancing Line" = rd,
        tabledata "NPR POS Tax Amount Line" = rd,
        tabledata "NPR POS Posting Log" = rd,
        tabledata "NPR EFT Transaction Request" = rd;

    trigger OnInstallAppPerCompany()
    begin
        AddAllowedTables();
        
    end;

    procedure AddAllowedTables()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        RtnPeriodEnum: Enum "Retention Period Enum";
    begin
        if UpgradeTag.HasUpgradeTag(GetNPRRetenPolTablesUpgradeTag()) then
            exit;

        // if additional filters are needed on record, see codeunit 3999 procedure AddChangeLogEntryToAllowedTables() in Base App

        AddAllowedTable(Database::"NPR Nc Task", RtnPeriodEnum::"14 Days"); // 6151502 - ok

        AddAllowedTable(Database::"NPR Data Log Record", RtnPeriodEnum::"1 Month"); // 6059898
        AddAllowedTable(Database::"NPR Data Log Field", RtnPeriodEnum::"1 Month"); // 6059899

        AddAllowedTable(Database::"NPR POS Entry Output Log", RtnPeriodEnum::"3 Months"); // 6014400 - ok
        AddAllowedTable(Database::"NPR Nc Import Entry", RtnPeriodEnum::"3 Months"); // 6151504 - ok

        AddAllowedTable(Database::"NPR POS Quote Entry", RtnPeriodEnum::"1 Year"); // 6151002 - ok
        AddAllowedTable(Database::"NPR POS Quote Line", RtnPeriodEnum::"1 Year"); // 6151003 - ok
        AddAllowedTable(Database::"NPR NpCs Arch. Document", RtnPeriodEnum::"1 Year"); // 6151202 - ok

        AddAllowedTable(Database::"NPR Exchange Label", RtnPeriodEnum::"2 Years"); // 6014498 - ok 
        AddAllowedTable(Database::"NPR NpGp POS Sales Entry", RtnPeriodEnum::"2 Years"); // 6151167 - ok
        AddAllowedTable(Database::"NPR POS Posting Log", RtnPeriodEnum::"6 Months"); // 6150635 - ok
        AddAllowedTable(Database::"NPR EFT Transaction Request", RtnPeriodEnum::"2 Years"); // 6184495 - ok
        AddAllowedTable(Database::"NPR Tax Free Voucher", RtnPeriodEnum::"2 Years"); // 6014477 - ok

        AddAllowedTable(Database::"NPR POS Entry", RtnPeriodEnum::"5 Years"); // 6150621 - ok
        AddAllowedTable(Database::"NPR POS Tax Amount Line", RtnPeriodEnum::"5 Years"); // 6150629 - ok
        AddAllowedTable(Database::"NPR POS Period Register", RtnPeriodEnum::"5 Years"); // 6150620 - ok
        AddAllowedTable(Database::"NPR POS Sales Line", RtnPeriodEnum::"5 Years"); // 6150622 - ok
        AddAllowedTable(Database::"NPR POS Payment Line", RtnPeriodEnum::"5 Years"); // 6150623 - ok
        AddAllowedTable(Database::"NPR POS Balancing Line", RtnPeriodEnum::"5 Years"); // 6150624 - ok 

        // do not forget to add table to DeleteRecordsWithIndirectPermissionsOnApplyRetentionPolicyIndirectPermissionRequired below
        // and to CDU permissions

        UpgradeTag.SetUpgradeTag(GetNPRRetenPolTablesUpgradeTag());
    end;

    local procedure AddAllowedTable(TableId: Integer; RtnPeriodEnum: Enum "Retention Period Enum")
    var
        RecRef: RecordRef;
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        RecRef.Open(TableId);

        RetenPolAllowedTables.AddAllowedTable(TableId, RecRef.SystemCreatedAtNo());
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
            exit;
        RetentionPolicySetup.Validate("Table Id", TableId);
        RetentionPolicySetup.Validate("Apply to all records", true);
        RetentionPolicySetup.Validate("Retention Period", RetentionPeriodCode);
        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Insert(true);
    end;

    local procedure GetNPRRetenPolTablesUpgradeTag(): Code[250]
    begin
        exit('NPR-RetenPolTables-20210211');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetNPRRetenPolTablesUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnBeforeOnRun', '', false, false)]
    local procedure AddAllowedTablesOnBeforeCompanyInit()
    var
        SystemInitialization: Codeunit "System Initialization";
    begin
        if SystemInitialization.IsInProgress() then
            AddAllowedTables();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Apply Retention Policy", 'OnApplyRetentionPolicyIndirectPermissionRequired', '', true, true)]
    local procedure DeleteRecordsWithIndirectPermissionsOnApplyRetentionPolicyIndirectPermissionRequired(var RecRef: RecordRef; var Handled: Boolean)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        NoFiltersErr: Label 'No filters were set on table %1, %2. Please contact your Microsoft Partner for assistance.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table.';
    begin
        // if someone else took it, exit
        if Handled then
            exit;

        // if no filters have been set, something is wrong.
        if (RecRef.GetFilters() = '') or (not RecRef.MarkedOnly()) then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(NoFiltersErr, RecRef.Number, RecRef.Name));

        // check if we can handle the table
        if not (RecRef.Number in [
            Database::"NPR Data Log Record",
            Database::"NPR Data Log Field",
            Database::"NPR Tax Free Voucher",
            Database::"NPR POS Quote Entry",
            Database::"NPR POS Quote Line",
            Database::"NPR NpCs Arch. Document",
            Database::"NPR Nc Task",
            Database::"NPR Exchange Label",
            Database::"NPR NpGp POS Sales Entry",
            Database::"NPR POS Entry Output Log",
            Database::"NPR Nc Import Entry",
            Database::"NPR POS Period Register",
            Database::"NPR POS Entry",
            Database::"NPR POS Sales Line",
            Database::"NPR POS Payment Line",
            Database::"NPR POS Balancing Line",
            Database::"NPR POS Tax Amount Line",
            Database::"NPR POS Posting Log",
            Database::"NPR EFT Transaction Request"])
        then
            exit;

        // delete all remaining records
        RecRef.DeleteAll();

        // set handled
        Handled := true;
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Apply");
    end;
}
