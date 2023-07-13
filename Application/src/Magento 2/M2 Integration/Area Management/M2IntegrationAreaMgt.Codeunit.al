codeunit 6150974 "NPR M2 Integration Area Mgt."
{
    Access = Internal;
#if not (BC17 or BC18 or BC19 or BC20)
    var
        MsiJobQueueDescriptionLbl: Label 'Create NaviConnect Tasks for Multi Source Inventory changes';
        FailedToCreateJobQueueEntryErr: Label 'Failed to create Job Queue Entry';

    internal procedure AreaIsEnabled(IntegrationArea: Enum "NPR M2 Integration Area"): Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        MagentoSetup.Get();
        case IntegrationArea of
            "NPR M2 Integration Area"::"MSI Stock Data":
                exit(MagentoSetup."MSI Integration Area Enabled");
            else
                exit(false);
        end;
    end;

    internal procedure EnableArea(IntegrationArea: Enum "NPR M2 Integration Area"; var MagentoSetup: Record "NPR Magento Setup")
    begin
        case IntegrationArea of
            "NPR M2 Integration Area"::"MSI Stock Data":
                begin
                    MagentoSetup."MSI Integration Area Enabled" := true;
                    EnableMsiIntegration();
                end;
            else
                exit;
        end;

        MagentoSetup.Modify(true);
    end;

    local procedure EnableMsiIntegration()
    var
        IntegrationRecord: Record "NPR M2 Integration Record";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        MsiArea: Enum "NPR M2 Integration Area";
        TaskSetup: Record "NPR Nc Task Setup";
        MSIIntegrationMgt: Codeunit "NPR M2 MSI Integration Mgt.";
        Item: Record Item;
        M2RecordChangeLog: Record "NPR M2 Record Change Log";
    begin
        MsiArea := Enum::"NPR M2 Integration Area"::"MSI Stock Data";

        IntegrationRecord.AddTable(Database::"Item Ledger Entry", MsiArea);
        IntegrationRecord.AddTable(Database::"Sales Line", MsiArea);
        IntegrationRecord.AddTable(Database::"NPR M2 Record Change Log", MsiArea);

        TaskSetup.SetRange("Task Processor Code", MSIIntegrationMgt.GetTaskProcessor());
        TaskSetup.SetRange("Table No.", Database::"NPR M2 MSI Request");
        if (not TaskSetup.FindFirst()) then begin
            TaskSetup.Init();
            TaskSetup."Entry No." := 0;
            TaskSetup."Task Processor Code" := MSIIntegrationMgt.GetTaskProcessor();
            TaskSetup."Table No." := Database::"NPR M2 MSI Request";
            TaskSetup."Codeunit ID" := Codeunit::"NPR M2 MSI Task Mgt.";
            TaskSetup.Insert(); // don't run the OnInsert trigger! it will insert data log setup, which we don't want to
        end;

        Item.SetRange("NPR Magento Item", true);
        if (Item.FindSet()) then
            repeat
                M2RecordChangeLog.Init();
                M2RecordChangeLog."Entry No." := 0;
                M2RecordChangeLog."Entity Identifier" := Item."No.";
                M2RecordChangeLog."Type of Change" := M2RecordChangeLog."Type of Change"::ResendStockData;
                M2RecordChangeLog.Insert();
            until Item.Next() = 0;

        if (not JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR M2 MSI Integration Mgt.",
            '',
            MsiJobQueueDescriptionLbl,
            CurrentDateTime(),
            2,
            'NPR-M2',
            JobQueueEntry
        )) then
            Error(FailedToCreateJobQueueEntryErr);

        JobQueueMgt.StartJobQueueEntry(JobQueueEntry); // does a check if user can start a task
    end;
#endif
}