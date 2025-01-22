codeunit 6185015 "NPR IRL Audit Mgt."
{
    Access = Internal;

    #region IRL Fiscal - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        IRLFiscalizationSetup: Record "NPR IRL Fiscalization Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        IRLFiscalizationSetup.ChangeCompany(CompanyName);
        if IRLFiscalizationSetup.Get() then
            IRLFiscalizationSetup.Delete();
    end;
#endif

    #endregion

    #region Retention Policy by Law 6 Years insted of NPR 5 Years
    procedure UpdateRetentionPolicyTo6Years()
    begin
        AddAllowedTable(Database::"NPR Exchange Label", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR NpGp POS Sales Entry", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR Tax Free Voucher", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR POS Entry", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR POS Entry Tax Line", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR POS Period Register", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR POS Entry Sales Line", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR POS Entry Payment Line", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR POS Balancing Line", Enum::"Retention Period Enum"::"NPR 6 Years", Enum::"Reten. Pol. Deleting"::Default);
    end;

    local procedure AddAllowedTable(TableId: Integer; RtnPeriodEnum: Enum "Retention Period Enum"; RetenPolDeleting: Enum "Reten. Pol. Deleting")
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        TableFilters: JsonArray;
    begin
        RecRef.Open(TableId);

        RetenPolAllowedTables.AddAllowedTable(TableId, RecRef.SystemCreatedAtNo(), 0, Enum::"Reten. Pol. Filtering"::Default, RetenPolDeleting, TableFilters);
        CreateRetentionPolicySetup(TableId, GetRetentionPeriodCode(RtnPeriodEnum), true, true);
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

    local procedure AddRetentionPolicySetupToBuffer(TableId: Integer; RetentionPeriodCode: Code[20]; EnablePolicy: Boolean; ApplyToAllRecords: Boolean)
    var
        RetenPolicySetupBuffer: Record "NPR Reten. Policy Setup Buffer";
    begin
        if RetenPolicySetupBuffer.Get(TableId) then // this to cover the case if there were multiple tries to do the install/upgrade, but data from the buffer hasn't been processed in the meantime
            RetenPolicySetupBuffer.Delete();

        RetenPolicySetupBuffer.Init();
        RetenPolicySetupBuffer."Table Id" := TableId;
        RetenPolicySetupBuffer."Retention Period" := RetentionPeriodCode;
        RetenPolicySetupBuffer.Enabled := EnablePolicy;
        RetenPolicySetupBuffer."Apply to All Records" := ApplyToAllRecords;
        RetenPolicySetupBuffer.Insert();
    end;

    local procedure CreateRetentionPolicySetup(TableId: Integer; RetentionPeriodCode: Code[20]; EnablePolicy: Boolean; ApplyToAllRecords: Boolean)
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        JobQueueUserHandler: Codeunit "NPR Job Queue User Handler";
    begin
        if not (RetentionPolicySetup.WritePermission() and JobQueueUserHandler.CanUserRefreshJobQueueEntries()) then begin
            AddRetentionPolicySetupToBuffer(TableId, RetentionPeriodCode, EnablePolicy, ApplyToAllRecords);
            exit;
        end;
        if RetentionPolicySetup.Get(TableId) then
            RetentionPolicySetup.Delete(true);

        InsertRetentionPolicySetup(TableId, RetentionPeriodCode, EnablePolicy, ApplyToAllRecords);
    end;

    internal procedure InsertRetentionPolicySetup(TableId: Integer; RetentionPeriodCode: Code[20]; EnablePolicy: Boolean; ApplyToAllRecords: Boolean)
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        RetentionPolicySetup.Init();
        RetentionPolicySetup.Validate("Table Id", TableId);
#if BC17
        RetentionPolicySetup.Validate("Apply to all records", true);
#else
        RetentionPolicySetup.Validate("Apply to all records", ApplyToAllRecords);
#endif
        if RetentionPolicySetup."Apply to all records" then
            RetentionPolicySetup.Validate("Retention Period", RetentionPeriodCode);
        RetentionPolicySetup.Validate(Enabled, false);
        RetentionPolicySetup.Insert(true);

        if EnablePolicy then
            EnableRetentionPolicySetup(TableId);
    end;

    local procedure EnableRetentionPolicySetup(TableId: Integer)
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if not RetentionPolicySetup.Get(TableId) then
            exit;

        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Modify(true);
    end;
    #endregion
}