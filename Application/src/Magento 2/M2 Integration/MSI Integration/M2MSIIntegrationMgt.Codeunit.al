codeunit 6150969 "NPR M2 MSI Integration Mgt."
{
    Access = Internal;

#if (BC17 or BC18 or BC19 or BC20)
    trigger OnRun()
    begin
        Error('Not implemented for versions lower than BC21!');
    end;
#else
    trigger OnRun()
    begin
        _MagentoSetup.Get();
        if (not _MagentoSetup."Magento Enabled") then
            exit;

        if (not _IntegrationAreaMgt.AreaIsEnabled(Enum::"NPR M2 Integration Area"::"MSI Stock Data")) then
            exit;

        UpdateMsiData();
    end;

    var
        _MagentoSetup: Record "NPR Magento Setup";
        _IntegrationAreaMgt: Codeunit "NPR M2 Integration Area Mgt.";
        _ItemHelper: Codeunit "NPR M2 Integration Item Helper";
        NPRM2IntegrationTaskProcessorTok: Label 'NPR-M2', MaxLength = 20, Locked = true;
        NPRM2IntegrationDescription: Label 'NP Retail Magento 2 integration', MaxLength = 50;

    local procedure UpdateMsiData()
    var
        TempMSIRequest: Record "NPR M2 MSI Request" temporary;
        M2IntegrationEvents: Codeunit "NPR M2 Integration Events";
    begin
        EmitUsageTelemetry();

        UpdateMsiDataItemLedgerEntry(TempMSIRequest);
        UpdateMsiDataSalesLine(TempMSIRequest);
        UpdateMsiDataRecordChanges(TempMSIRequest);

        M2IntegrationEvents.CallOnAfterUpdateMsiDataOnBeforeInsertTasks(TempMSIRequest);

        InsertTasks(TempMSIRequest);
    end;

    local procedure UpdateMsiDataSalesLine(var TempMSIRequest: Record "NPR M2 MSI Request" temporary)
    var
        IntegrationRecord: Record "NPR M2 Integration Record";
        SalesLine: Record "Sales Line";
        Location: Record Location;
    begin
        IntegrationRecord.LockTable();
        IntegrationRecord.Get(Database::"Sales Line", Enum::"NPR M2 Integration Area"::"MSI Stock Data");

#if not BC21
        SalesLine.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        SalesLine.SetCurrentKey(SystemRowVersion);
        SalesLine.SetLoadFields(Type, "No.", "Variant Code", "Location Code", SystemRowVersion);
        SalesLine.SetFilter(SystemRowVersion, '>%1', IntegrationRecord."Last SystemRowVersionNo");
        if (not SalesLine.FindSet()) then
            exit;

        repeat
            if ((SalesLine.Type = SalesLine.Type::Item) and
                    (SalesLine."Location Code" <> '') and
                    (_ItemHelper.IsMagentoItem(SalesLine."No.")) and
                    (Location.Get(SalesLine."Location Code")) and
                    (Location."NPR Magento 2 Source" <> ''))
            then
                CreateMsiRequest(TempMSIRequest, SalesLine."No.", SalesLine."Variant Code", Location."NPR Magento 2 Source");
        until SalesLine.Next() = 0;

        IntegrationRecord."Last SystemRowVersionNo" := SalesLine.SystemRowVersion;
        IntegrationRecord.Modify();
    end;

    local procedure UpdateMsiDataItemLedgerEntry(var TempMSIRequest: Record "NPR M2 MSI Request" temporary)
    var
        IntegrationRecord: Record "NPR M2 Integration Record";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
    begin
        IntegrationRecord.LockTable();
        IntegrationRecord.Get(Database::"Item Ledger Entry", Enum::"NPR M2 Integration Area"::"MSI Stock Data");

#if not BC21
        ItemLedgerEntry.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        ItemLedgerEntry.SetCurrentKey(SystemRowVersion);
        ItemLedgerEntry.SetLoadFields("Item No.", "Variant Code", "Location Code", SystemRowVersion);
        ItemLedgerEntry.SetFilter(SystemRowVersion, '>%1', IntegrationRecord."Last SystemRowVersionNo");
        if (not ItemLedgerEntry.FindSet()) then
            exit;

        repeat
            if (_ItemHelper.IsMagentoItem(ItemLedgerEntry."Item No.") and
                (Location.Get(ItemLedgerEntry."Location Code")) and
                (Location."NPR Magento 2 Source" <> ''))
            then
                CreateMsiRequest(TempMSIRequest, ItemLedgerEntry."Item No.", ItemLedgerEntry."Variant Code", Location."NPR Magento 2 Source");
        until ItemLedgerEntry.Next() = 0;

        IntegrationRecord."Last SystemRowVersionNo" := ItemLedgerEntry.SystemRowVersion;
        IntegrationRecord.Modify();
    end;

    local procedure UpdateMsiDataRecordChanges(var TempMSIRequest: Record "NPR M2 MSI Request" temporary)
    var
        IntegrationRecord: Record "NPR M2 Integration Record";
        RecordChangeLog: Record "NPR M2 Record Change Log";
        ItemNo: Code[20];
        VariantCode: Code[10];
        Location: Record Location;
    begin
        IntegrationRecord.LockTable();
        IntegrationRecord.Get(Database::"NPR M2 Record Change Log", Enum::"NPR M2 Integration Area"::"MSI Stock Data");

#if not BC21
        RecordChangeLog.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        RecordChangeLog.SetCurrentKey(SystemRowVersion);
        RecordChangeLog.SetFilter("Type of Change", '%1|%2', RecordChangeLog."Type of Change"::ResendStockData, RecordChangeLog."Type of Change"::ItemEnabled);
        RecordChangeLog.SetFilter(SystemRowVersion, '>%1', IntegrationRecord."Last SystemRowVersionNo");
        if (not RecordChangeLog.FindSet()) then
            exit;

        repeat
            _ItemHelper.Sku2ItemNoVariant(RecordChangeLog."Entity Identifier", ItemNo, VariantCode);
            if (_ItemHelper.IsMagentoItem(ItemNo)) then
                if ((RecordChangeLog."Location Code" = '') or
                    (Location.Get(RecordChangeLog."Location Code") and (Location."NPR Magento 2 Source" <> '')))
                then
                    CreateMsiRequest(TempMSIRequest, ItemNo, VariantCode, RecordChangeLog."Location Code");
        until RecordChangeLog.Next() = 0;

        IntegrationRecord."Last SystemRowVersionNo" := RecordChangeLog.SystemRowVersion;
        IntegrationRecord.Modify();
    end;

    local procedure CreateMsiRequest(var TempMSIRequest: Record "NPR M2 MSI Request" temporary; ItemNo: Code[20]; VariantCode: Code[10]; Source: Text[50])
    begin
        TempMSIRequest.SetRange("Item No.", ItemNo);
        TempMSIRequest.SetFilter("Variant Code", '%1|%2', VariantCode, '');
        TempMSIRequest.SetFilter("Magento Source", '%1|%2', Source, '');
        if (not TempMSIRequest.IsEmpty()) then
            exit;

        TempMSIRequest.Init();
        TempMSIRequest."Item No." := ItemNo;
        TempMSIRequest."Variant Code" := VariantCode;
        TempMSIRequest."Magento Source" := Source;
        TempMSIRequest.Insert();
    end;

    local procedure InsertTasks(var TempMSIRequest: Record "NPR M2 MSI Request" temporary)
    var
        NcTask: Record "NPR Nc Task";
    begin
        EnsureTaskProcessorExists();

        TempMSIRequest.Reset();
        if (TempMSIRequest.FindSet()) then
            repeat
                NcTask.Init();
                NcTask."Entry No." := 0;
                NcTask."Task Processor Code" := NPRM2IntegrationTaskProcessorTok;
                NcTask."Table No." := Database::"NPR M2 MSI Request";
                NcTask."Log Date" := CurrentDateTime();
#pragma warning disable AA0139
                NcTask."Record Position" := TempMSIRequest.GetPosition(false);
#pragma warning restore AA00139
                NcTask."Record ID" := TempMSIRequest.RecordId;
                NcTask."Record Value" := CopyStr(StrSubstNo('%1,%2,%3', TempMSIRequest."Item No.", TempMSIRequest."Variant Code", TempMSIRequest."Magento Source"), 1, MaxStrLen(NcTask."Record Value"));
                NcTask.Insert(true);
            until TempMSIRequest.Next() = 0;
    end;

    local procedure EnsureTaskProcessorExists()
    var
        TaskProcessor: Record "NPR Nc Task Processor";
    begin
        if (TaskProcessor.Get(NPRM2IntegrationTaskProcessorTok)) then
            exit;

        TaskProcessor.Init();
        TaskProcessor.Code := NPRM2IntegrationTaskProcessorTok;
        TaskProcessor.Description := CopyStr(NPRM2IntegrationDescription, 1, MaxStrLen(TaskProcessor.Description));
        TaskProcessor.Insert(true);
    end;

    internal procedure GetTaskProcessor(): Code[20]
    begin
        exit(NPRM2IntegrationTaskProcessorTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", 'RunSourceCardEvent', '', true, true)]
    local procedure TaskListRunSourceCard(var RecRef: RecordRef; var RunCardExecuted: Boolean)
    var
        TempMSIRequest: Record "NPR M2 MSI Request" temporary;
        Item: Record Item;
        PageMgt: Codeunit "Page Management";
    begin
        if ((RunCardExecuted) or (RecRef.Number() <> Database::"NPR M2 MSI Request")) then
            exit;

        RecRef.SetTable(TempMSIRequest);

        if (TempMSIRequest."Item No." = '') then
            exit;

        if (not Item.Get(TempMSIRequest."Item No.")) then
            exit;

        RunCardExecuted := true;
        PageMgt.PageRun(Item);
    end;

    local procedure EmitUsageTelemetry()
    var
        Dimensions: Dictionary of [Text, Text];
        Tenant: Text;
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        Dimensions.Add('NPR_Feature', 'M2_MSI');
        Dimensions.Add('NPR_Company', CompanyName());

        Tenant := AzureADTenant.GetAadTenantId();
        if (Tenant = '') then
            Tenant := TenantId();
        Dimensions.Add('NPR_Tenant', Tenant);

        Session.LogMessage(
            'NPR_M2_FEATURE_USAGE',
            'MSI Integration started',
            Verbosity::Normal,
            DataClassification::OrganizationIdentifiableInformation,
            TelemetryScope::ExtensionPublisher,
            Dimensions
        );
    end;
#endif
}