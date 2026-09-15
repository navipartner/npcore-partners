#if not BC17
codeunit 6184799 "NPR Spfy DLog Subscr.Mgt.Impl."
{
    Access = Internal;
    Permissions =
        tabledata "NPR Data Log Setup (Table)" = rimd,
        tabledata "NPR Data Log Subscriber" = rimd,
        tabledata "NPR Data Log Processing Entry" = rimd;

    procedure CreateDataLogSetup(IntegrationArea: Enum "NPR Spfy Integration Area")
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        // RowVersion on => never (re)create Shopify Data Log setup
        if SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        SpfyIntegrationMgt.SetRereadSetup();
        case IntegrationArea of
            "NPR Spfy Integration Area"::Items:
                begin
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::Item, DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"Item Variant", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"Item Reference", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Store-Item Link", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Item Variant Modif.", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Simple, DataLogSetup."Log Deletion"::Simple, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Entity Metafield", DataLogSetup."Log Insertion"::" ", DataLogSetup."Log Modification"::Simple, DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                end;

            "NPR Spfy Integration Area"::"Inventory Levels":
                begin
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"Item Ledger Entry", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::" ", DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"Sales Line", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Inventory Level", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Store-Item Link", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    if SpfyIntegrationMgt.IncludeTrasferOrdersAnyStore() then
                        AddDataLogSetupEntity(
                            IntegrationArea, Database::"Transfer Line", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                end;

            "NPR Spfy Integration Area"::"Item Prices":
                begin
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Item Price", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                end;

            "NPR Spfy Integration Area"::"Retail Vouchers":
                begin
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR NpRv Voucher", DataLogSetup."Log Insertion"::" ", DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR NpRv Arch. Voucher", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::" ", DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR NpRv Voucher Entry", DataLogSetup."Log Insertion"::Detailed, DataLogSetup."Log Modification"::" ", DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                end;

            "NPR Spfy Integration Area"::"Sales Orders":
                begin
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Store-Customer Link", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR Spfy Entity Metafield", DataLogSetup."Log Insertion"::" ", DataLogSetup."Log Modification"::Simple, DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                end;
        end;
        SpfyIntegrationEvents.OnAfterCreateDataLogSetup(IntegrationArea);
    end;

    procedure RemoveDataLogSetup(IntegrationArea: Enum "NPR Spfy Integration Area")
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyHandlerId: Code[20];
    begin
        SpfyHandlerId := SpfyIntegrationMgt.DataProcessingHandlerID(false);   // AutoCreate=false: no setup → blank → nothing to remove
        if SpfyHandlerId = '' then
            exit;

        case IntegrationArea of
            "NPR Spfy Integration Area"::Items:
                begin
                    RemoveDataLogSetupEntity(Database::Item, SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"Item Variant", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"Item Reference", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR Spfy Store-Item Link", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR Spfy Item Variant Modif.", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR Spfy Entity Metafield", SpfyHandlerId);
                end;

            "NPR Spfy Integration Area"::"Inventory Levels":
                begin
                    RemoveDataLogSetupEntity(Database::"Item Ledger Entry", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"Sales Line", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR Spfy Inventory Level", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR Spfy Store-Item Link", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"Transfer Line", SpfyHandlerId);
                end;

            "NPR Spfy Integration Area"::"Item Prices":
                RemoveDataLogSetupEntity(Database::"NPR Spfy Item Price", SpfyHandlerId);

            "NPR Spfy Integration Area"::"Retail Vouchers":
                begin
                    RemoveDataLogSetupEntity(Database::"NPR NpRv Voucher", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR NpRv Arch. Voucher", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR NpRv Voucher Entry", SpfyHandlerId);
                end;

            "NPR Spfy Integration Area"::"Sales Orders":
                begin
                    RemoveDataLogSetupEntity(Database::"NPR Spfy Store-Customer Link", SpfyHandlerId);
                    RemoveDataLogSetupEntity(Database::"NPR Spfy Entity Metafield", SpfyHandlerId);
                end;
        end;
    end;

    local procedure RemoveDataLogSetupEntity(TableId: Integer; SpfyHandlerId: Code[20])
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
    begin
        // Remove the SPFY subscriber row. SPFY rows are stored with a blank Company Name (AddAsSubscriber inserts blank-company).
        DataLogSubscriber.SetRange(Code, SpfyHandlerId);
        DataLogSubscriber.SetRange("Table ID", TableId);
        DataLogSubscriber.SetRange("Company Name", '');
        if not DataLogSubscriber.IsEmpty() then
            DataLogSubscriber.DeleteAll(true);

        // Remove any SPFY-scoped processing entries for this table. SPFY normally creates none (its subscriber has
        // Data Processing Codeunit ID = 0, so NPR Data Log Management.ProcessDataLogRecord — filter > 0 — never schedules
        // them), but a PTE/custom OnSetupDataLogSubsriberDataProcessingParams could set the Codeunit ID; scoping the delete
        // to (Subscriber Code = SPFY, Table Number) keeps it safe even on tables still shared by another consumer.
        DataLogProcessingEntry.SetRange("Subscriber Code", SpfyHandlerId);
        DataLogProcessingEntry.SetRange("Table Number", TableId);
        if not DataLogProcessingEntry.IsEmpty() then
            DataLogProcessingEntry.DeleteAll(true);

        // Keep the Setup (Table) row (and any backlog) if another consumer (e.g. NpXml / HeyLoyalty) still subscribes to this table.
        DataLogSubscriber.Reset();
        DataLogSubscriber.SetRange("Table ID", TableId);
        DataLogSubscriber.SetFilter(Code, '<>%1', SpfyHandlerId);
        if not DataLogSubscriber.IsEmpty() then
            exit;

        // No other consumer → drop the Setup (Table) row to stop Data Log generation for this table.
        if DataLogSetup.Get(TableId) then
            DataLogSetup.Delete(true);

        // The leftover NPR Data Log Record / Field backlog is intentionally NOT mass-deleted here: on a large integration it
        // can be millions of rows (slow + heavy locks during the one-way cutover). The rows are inert once unsubscribed and
        // are cleaned by the existing Data Log retention policy ("NPR Ret.Pol.: Data Log Record" → CleanDataLog, whose
        // no-setup fallback pass removes orphaned rows past the retention period).
    end;

    internal procedure AddDataLogSetupEntity(IntegrationArea: Enum "NPR Spfy Integration Area"; TableId: Integer; LogInsertion: Integer; LogModification: Integer; LogDeletion: Integer; KeepLogFor: Duration)
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        xDataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        xDataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        LogModificationAlt: Integer;
        Handled: Boolean;
    begin
        DataLogSetup.InsertNewTable(TableId, LogInsertion, LogModification, LogDeletion);
        xDataLogSetup := DataLogSetup;
        if DataLogSetup."Log Insertion" < LogInsertion then
            DataLogSetup."Log Insertion" := LogInsertion;
        if LogModification = DataLogSetup."Log Modification"::Changes then
            LogModificationAlt := DataLogSetup."Log Modification"::Detailed
        else
            LogModificationAlt := LogModification;
        if DataLogSetup."Log Modification" < LogModificationAlt then
            DataLogSetup."Log Modification" := LogModification;
        if DataLogSetup."Log Deletion" < LogDeletion then
            DataLogSetup."Log Deletion" := LogDeletion;
        if DataLogSetup."Keep Log for" < KeepLogFor then
            DataLogSetup."Keep Log for" := KeepLogFor;
        if Format(DataLogSetup) <> Format(xDataLogSetup) then
            DataLogSetup.Modify(true);

        DataLogSubscriber.AddAsSubscriber(SpfyIntegrationMgt.DataProcessingHandlerID(true), DataLogSetup."Table ID");
        xDataLogSubscriber := DataLogSubscriber;
        SpfyIntegrationEvents.OnSetupDataLogSubsriberDataProcessingParams(IntegrationArea, DataLogSetup."Table ID", DataLogSubscriber, Handled);
        if not Handled then
            case DataLogSetup."Table ID" of
                Database::Item,
                Database::"Item Variant",
                Database::"Item Reference",
                Database::"NPR Spfy Store-Item Link",
                Database::"NPR Spfy Store-Customer Link",
                Database::"NPR Spfy Item Variant Modif.",
                Database::"NPR Spfy Entity Metafield",
                Database::"NPR Spfy Inventory Level",
                Database::"NPR Spfy Item Price",
                Database::"Sales Line",
                Database::"Transfer Line",
                Database::"Item Ledger Entry",
                Database::"NPR NpRv Voucher",
                Database::"NPR NpRv Arch. Voucher",
                Database::"NPR NpRv Voucher Entry":
                    begin
                        DataLogSubscriber."Direct Data Processing" := false;
                        DataLogSubscriber."Delayed Data Processing (sec)" := 20;
                    end;
            end;
        if Format(DataLogSubscriber) <> Format(xDataLogSubscriber) then
            DataLogSubscriber.Modify(true);
    end;
}
#endif