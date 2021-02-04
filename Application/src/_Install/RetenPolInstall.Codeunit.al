codeunit 6014496 "NPR Reten. Pol. Install"
{
    // based on codeunit 3999 "Reten. Pol. Install - BaseApp" from Base App

    Subtype = Install;
    Access = Internal;
    Permissions = tabledata "Retention Period" = ri,
                  tabledata "Retention Policy Setup" = ri,
                  tabledata "NPR Data Log Record" = rd,
                  tabledata "NPR Data Log Field" = rd;

    var
        OneMonthTok: Label 'One Month', MaxLength = 20;
        NoFiltersErr: Label 'No filters were set on table %1, %2. Please contact your Microsoft Partner for assistance.', Comment = '%1 = a id of a table (integer), %2 = the caption of the table.';

    trigger OnInstallAppPerCompany()
    begin
        AddAllowedTables();
    end;

    procedure AddAllowedTables()
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetNPRRetenPolTablesUpgradeTag()) then
            exit;

        // if additional filters are needed on record, see codeunit 3999 procedure AddChangeLogEntryToAllowedTables() in Base App

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR Data Log Record", DataLogRecord.FieldNo("Log Date"));
        RetenPolAllowedTables.AddAllowedTable(Database::"NPR Data Log Field", DataLogField.FieldNo("Log Date"));

        CreateRetentionPolicySetup(Database::"NPR Data Log Record", CreateOneMonthRetentionPeriod());
        CreateRetentionPolicySetup(Database::"NPR Data Log Field", CreateOneMonthRetentionPeriod());

        // do not forget to add table to DeleteRecordsWithIndirectPermissionsOnApplyRetentionPolicyIndirectPermissionRequired below
        // and to CDU permissions

        UpgradeTag.SetUpgradeTag(GetNPRRetenPolTablesUpgradeTag());
    end;

    local procedure CreateOneMonthRetentionPeriod(): Code[20]
    var
        RetentionPeriod: Record "Retention Period";
    begin
        if RetentionPeriod.Get(OneMonthTok) then
            exit(RetentionPeriod.Code);

        RetentionPeriod.SetRange("Retention Period", RetentionPeriod."Retention Period"::"1 Month");
        if RetentionPeriod.FindFirst() then
            exit(RetentionPeriod.Code);

        RetentionPeriod.Code := CopyStr(UpperCase(OneMonthTok), 1, MaxStrLen(RetentionPeriod.Code));
        RetentionPeriod.Description := OneMonthTok;
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::"1 Month");
        RetentionPeriod.Insert(true);
        exit(RetentionPeriod.Code);
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
        exit('NPR-RetenPolTables-20210204');
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
            Database::"NPR Data Log Field"])
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
