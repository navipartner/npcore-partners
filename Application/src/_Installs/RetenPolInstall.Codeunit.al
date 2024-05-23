codeunit 6014496 "NPR Reten. Pol. Install"
{
    // based on codeunit 3999 "Reten. Pol. Install - BaseApp" from Base App
    Access = Internal;

    Subtype = Install;
    Permissions =
        tabledata "Retention Period" = ri,
        tabledata "Retention Policy Setup" = rimd,
        tabledata "Retention Policy Setup Line" = rimd;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";

    trigger OnInstallAppPerCompany()
    begin
        AddAllowedTables(true);
    end;

    procedure AddAllowedTables(IsUpgrade: Boolean)
    begin
        // if you add a new table here, also update codeunit 6059926 "NPR Retail Logs Delete"
        if IsUpgrade then
            LogMessageStopwatch.LogStart(CompanyName(), 'NPR Reten. Pol. Install', 'AddAllowedTables');

        // if additional filters are needed on record, see codeunit 3999 procedure AddChangeLogEntryToAllowedTables() in Base App
        // if want to use Data Archive when deleting the record, also update codeunit 6059927 "NPR Reten. Pol. Data Archive"

        AddDefaultRetentionPolicy(IsUpgrade);

        AddNcTaskRetentionPolicy(IsUpgrade);

        AddPOSPostingLogRetentionPolicy(IsUpgrade);

        AddPOSLayoutArchiveRetentionPolicy(IsUpgrade);

        AddPOSSavedSalesRetentionPolicy(IsUpgrade);

        AddTableListUpdateRetentionPolicy(IsUpgrade);

        AddHeyLoyaltyWebhookRequestsRetentionPolicy(IsUpgrade);

        AddM2RecordChangeLogTableRetentionPolicy(IsUpgrade);

        AddNPRERetentionPolicy(IsUpgrade);

        AddSalesPriceMaintRetentionPolicy(IsUpgrade);

        if IsUpgrade then
            LogMessageStopwatch.LogFinish();
    end;


    local procedure AddDefaultRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install") then
                exit;

        AddAllowedTable(Database::"NPR Data Log Record", Enum::"Retention Period Enum"::"1 Week", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR Data Log Field", Enum::"Retention Period Enum"::"1 Week", Enum::"Reten. Pol. Deleting"::Default);

        AddAllowedTable(Database::"NPR POS Entry Output Log", Enum::"Retention Period Enum"::"3 Months", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR Nc Import Entry", Enum::"Retention Period Enum"::"1 Month", Enum::"Reten. Pol. Deleting"::Default);

        AddAllowedTable(Database::"NPR NpCs Arch. Document", Enum::"Retention Period Enum"::"1 Year", Enum::"Reten. Pol. Deleting"::Default);

        AddAllowedTable(Database::"NPR Exchange Label", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR NpGp POS Sales Entry", Enum::"Retention Period Enum"::"5 Years", Enum::"Reten. Pol. Deleting"::Default);
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

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install");
    end;

    local procedure AddNcTaskRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NcTask') then
                exit;

        AddNcTaskRetentionPolicy();

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NcTask');
    end;

    local procedure AddPOSPostingLogRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSPostingLog') then
                exit;

        AddAllowedTable(Database::"NPR POS Posting Log", Enum::"Retention Period Enum"::"1 Week", Enum::"Reten. Pol. Deleting"::Default);

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSPostingLog');
    end;

    local procedure AddPOSLayoutArchiveRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSLayoutArchive') then
                exit;

        AddAllowedTable(Database::"NPR POS Layout Archive", Enum::"Retention Period Enum"::"6 Months", Enum::"Reten. Pol. Deleting"::Default);

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSLayoutArchive');
    end;

    local procedure AddPOSSavedSalesRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSSavedSales') then
                exit;

        AddPosSavedSalesRetentionPolicy();

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSSavedSales');
    end;

    local procedure AddTableListUpdateRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'RetenTableListUpdate_20230223') then
                exit;

        AddAllowedTable(Database::"NPR EFT Transaction Log", Enum::"Retention Period Enum"::"1 Year", Enum::"Reten. Pol. Deleting"::Default);
        AddAllowedTable(Database::"NPR EFT Transaction Request", Enum::"Retention Period Enum"::"1 Year", Enum::"Reten. Pol. Deleting"::Default);
        RemoveRetentionPolicy(Database::"NPR Nc Task Output");

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'RetenTableListUpdate_20230223');
    end;

    local procedure AddHeyLoyaltyWebhookRequestsRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'HeyLoyaltyWebhookRequests') then
                exit;

        AddHeyLoyaltyWebhookRequestRetentionPolicy();

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'HeyLoyaltyWebhookRequests');
    end;

    local procedure AddM2RecordChangeLogTableRetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'M2RecordChangeLogTable') then
                exit;

        AddAllowedTable(Database::"NPR M2 Record Change Log", Enum::"Retention Period Enum"::"1 Month", Enum::"Reten. Pol. Deleting"::Default);

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'M2RecordChangeLogTable');
    end;

    local procedure AddNPRERetentionPolicy(IsUpgrade: Boolean)
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NPRE') then
                exit;

        AddWaiterPadRetentionPolicy();
        AddWaiterPadPrntLogEntryRetentionPolicy();
        AddKitchenOrderRetentionPolicy();

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NPRE');
    end;

    local procedure AddSalesPriceMaintRetentionPolicy(IsUpgrade: Boolean)
    var
        SalesPriceMaintLog: Record "NPR Sales Price Maint. Log";
        RecRef: RecordRef;
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        if IsUpgrade then
            if HasUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'SalesPriceMaintenance') then
                exit;

        SalesPriceMaintLog.SetRange(Processed, false);
        RtnPeriodEnum := RtnPeriodEnum::"Never Delete";
        RecRef.GetTable(SalesPriceMaintLog);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        SalesPriceMaintLog.SetRange(Processed, true);
        RtnPeriodEnum := RtnPeriodEnum::"1 Month";
        RecRef.GetTable(SalesPriceMaintLog);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR Sales Price Maint. Log", RecRef.SystemCreatedAtNo(), TableFilters);
        CreateRetentionPolicySetup(Database::"NPR Sales Price Maint. Log", GetRetentionPeriodCode(RtnPeriodEnum), true, false);

        if IsUpgrade then
            SetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'SalesPriceMaintenance');
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

    local procedure AddPosSavedSalesRetentionPolicy()
    var
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        RemoveRetentionPolicy(Database::"NPR POS Saved Sale Line");
        RemoveRetentionPolicy(Database::"NPR POS Saved Sale Entry");

        POSSavedSaleEntry.SetRange("Contains EFT Approval", true);
        RtnPeriodEnum := RtnPeriodEnum::"Never Delete";
        RecRef.GetTable(POSSavedSaleEntry);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, true, RecRef);

        POSSavedSaleEntry.SetRange("Contains EFT Approval", false);
        RtnPeriodEnum := RtnPeriodEnum::"3 Months";
        RecRef.GetTable(POSSavedSaleEntry);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR POS Saved Sale Entry", RecRef.SystemCreatedAtNo(), TableFilters);

        CreateRetentionPolicySetup(Database::"NPR POS Saved Sale Entry", GetRetentionPeriodCode(RtnPeriodEnum), true, false);
    end;

    local procedure AddNcTaskRetentionPolicy()
    var
        NcTask: Record "NPR Nc Task";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        RemoveRetentionPolicy(Database::"NPR Nc Task");

        NcTask.SetRange(Processed, false);
        NcTask.SetRange("Process Error", false);
        RtnPeriodEnum := RtnPeriodEnum::"Never Delete";
        RecRef.GetTable(NcTask);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, true, RecRef);

        NcTask.SetRange(Processed, false);
        NcTask.SetRange("Process Error", true);
        RtnPeriodEnum := RtnPeriodEnum::"1 Month";
        RecRef.GetTable(NcTask);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        NcTask.SetRange(Processed, true);
        NcTask.SetRange("Process Error");
        RtnPeriodEnum := RtnPeriodEnum::"NPR 14 Days";
        RecRef.GetTable(NcTask);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

#IF NOT BC17 AND NOT BC18
        RetenPolAllowedTables.AddAllowedTable(Database::"NPR Nc Task", RecRef.SystemCreatedAtNo(), 0, Enum::"Reten. Pol. Filtering"::"NPR Reten. Pol. Filtering", Enum::"Reten. Pol. Deleting"::"NPR Reten. Pol. Deleting", TableFilters);
#ELSE
        RetenPolAllowedTables.AddAllowedTable(Database::"NPR Nc Task", RecRef.SystemCreatedAtNo(), TableFilters);
#ENDIF

        CreateRetentionPolicySetup(Database::"NPR Nc Task", GetRetentionPeriodCode(RtnPeriodEnum), true, false);
    end;

    local procedure AddHeyLoyaltyWebhookRequestRetentionPolicy()
    var
        HLWebhookRequest: Record "NPR HL Webhook Request";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        RemoveRetentionPolicy(Database::"NPR HL Webhook Request");

        HLWebhookRequest.SetFilter("Processing Status", '<>%1', HLWebhookRequest."Processing Status"::Processed);
        RtnPeriodEnum := RtnPeriodEnum::"Never Delete";
        RecRef.GetTable(HLWebhookRequest);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, true, RecRef);

        HLWebhookRequest.SetRange("Processing Status", HLWebhookRequest."Processing Status"::Processed);
        RtnPeriodEnum := RtnPeriodEnum::"1 Month";
        RecRef.GetTable(HLWebhookRequest);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR HL Webhook Request", RecRef.SystemCreatedAtNo(), TableFilters);

        CreateRetentionPolicySetup(Database::"NPR HL Webhook Request", GetRetentionPeriodCode(RtnPeriodEnum), HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members), false);
    end;

    local procedure AddWaiterPadRetentionPolicy()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        RemoveRetentionPolicy(Database::"NPR NPRE Waiter Pad");

        WaiterPad.SetRange(Closed, false);
        RtnPeriodEnum := RtnPeriodEnum::"3 Months";
        RecRef.GetTable(WaiterPad);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        WaiterPad.SetRange(Closed, true);
        RtnPeriodEnum := RtnPeriodEnum::"NPR 14 Days";
        RecRef.GetTable(WaiterPad);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR NPRE Waiter Pad", RecRef.SystemCreatedAtNo(), TableFilters);
        CreateRetentionPolicySetup(Database::"NPR NPRE Waiter Pad", GetRetentionPeriodCode(RtnPeriodEnum), not RestaurantSetup.IsEmpty(), false);
    end;

    local procedure AddWaiterPadPrntLogEntryRetentionPolicy()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        WPadPrntLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        RemoveRetentionPolicy(Database::"NPR NPRE W.Pad Prnt LogEntry");

        WPadPrntLogEntry.SetRange("Waiter Pad Line Exists", true);
        RtnPeriodEnum := RtnPeriodEnum::"Never Delete";
        RecRef.GetTable(WPadPrntLogEntry);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, true, RecRef);

        WPadPrntLogEntry.SetRange("Waiter Pad Line Exists", false);
        RtnPeriodEnum := RtnPeriodEnum::"3 Months";
        RecRef.GetTable(WPadPrntLogEntry);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR NPRE W.Pad Prnt LogEntry", RecRef.SystemCreatedAtNo(), TableFilters);
        CreateRetentionPolicySetup(Database::"NPR NPRE W.Pad Prnt LogEntry", GetRetentionPeriodCode(RtnPeriodEnum), not RestaurantSetup.IsEmpty(), false);
    end;

    local procedure AddKitchenOrderRetentionPolicy()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        RecRef: RecordRef;
        RtnPeriodEnum: Enum "Retention Period Enum";
        TableFilters: JsonArray;
    begin
        RemoveRetentionPolicy(Database::"NPR NPRE Kitchen Order");

        KitchenOrder.SetRange("On Hold", true);
        RtnPeriodEnum := RtnPeriodEnum::"Never Delete";
        RecRef.GetTable(KitchenOrder);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, true, RecRef);

        KitchenOrder.SetRange("On Hold", false);
        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status"::Planned);
        RtnPeriodEnum := RtnPeriodEnum::"3 Months";
        RecRef.GetTable(KitchenOrder);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status"::Cancelled);
        RtnPeriodEnum := RtnPeriodEnum::"NPR 14 Days";
        RecRef.GetTable(KitchenOrder);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RtnPeriodEnum, RecRef.SystemCreatedAtNo(), true, false, RecRef);

        RetenPolAllowedTables.AddAllowedTable(Database::"NPR NPRE Kitchen Order", RecRef.SystemCreatedAtNo(), TableFilters);
        CreateRetentionPolicySetup(Database::"NPR NPRE Kitchen Order", GetRetentionPeriodCode(RtnPeriodEnum), SetupProxy.KDSActivatedForAnyRestaurant(), false);
    end;

    local procedure HasUpgradeTag(UpgradeCodeunitID: Integer; UpgradeStep: Text): Boolean
    begin
        exit(UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(UpgradeCodeunitID, UpgradeStep)));
    end;

    local procedure HasUpgradeTag(UpgradeCodeunitID: Integer): Boolean
    begin
        exit(UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(UpgradeCodeunitID)));
    end;

    local procedure SetUpgradeTag(UpgradeCodeunitID: Integer; UpgradeStep: Text)
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(UpgradeCodeunitID, UpgradeStep))
    end;

    local procedure SetUpgradeTag(UpgradeCodeunitID: Integer)
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(UpgradeCodeunitID));
    end;

    local procedure RemoveRetentionPolicy(TableId: Integer)
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        if RetentionPolicySetup.Get(TableId) then
            if RetentionPolicySetup.WritePermission() then
                RetentionPolicySetup.Delete(true);
        if RetenPolAllowedTables.IsAllowedTable(TableId) then
            RetenPolAllowedTables.RemoveAllowedTable(TableId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnBeforeOnRun', '', false, false)]
    local procedure AddAllowedTablesOnBeforeCompanyInit()
    var
        SystemInitialization: Codeunit "System Initialization";
    begin
        if SystemInitialization.IsInProgress() then
            AddAllowedTables(true);
    end;
}