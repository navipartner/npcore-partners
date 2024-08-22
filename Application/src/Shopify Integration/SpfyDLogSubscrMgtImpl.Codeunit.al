#if not BC17
codeunit 6184799 "NPR Spfy DLog Subscr.Mgt.Impl."
{
    Access = Internal;
    Permissions =
        tabledata "NPR Data Log Setup (Table)" = rimd,
        tabledata "NPR Data Log Subscriber" = rimd;

    procedure CreateDataLogSetup(IntegrationArea: Enum "NPR Spfy Integration Area")
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
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
            "NPR Spfy Integration Area"::"Retail Vouchers":
                begin
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR NpRv Voucher", DataLogSetup."Log Insertion"::" ", DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR NpRv Arch. Voucher", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::" ", DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR NpRv Voucher Entry", DataLogSetup."Log Insertion"::Detailed, DataLogSetup."Log Modification"::" ", DataLogSetup."Log Deletion"::" ", JobQueueMgt.DaysToDuration(7));
                end;
        end;
        SpfyIntegrationEvents.OnAfterCreateDataLogSetup(IntegrationArea);
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
                Database::"NPR Spfy Inventory Level",
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