codeunit 6151192 "NPR Spfy Chg Hdlr Sales Orders" implements "NPR Spfy Change Handler"
{
    Access = Internal;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";

    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    begin
        if DetectedChange.ChangeType() = "NPR Spfy Change Type"::Delete then
            exit(ProcessDelete(DetectedChange));
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders") then
            exit(false);
        case DetectedChange.TableNo() of
            Database::"NPR Spfy Store-Customer Link":
                exit(ProcessStoreCustomerLink(DetectedChange));
        end;
        exit(false);
    end;

    local procedure ProcessDelete(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        CreatedTaskQueue: Enum "NPR Spfy Task Dest Queue";
    begin
        if DetectedChange.TableNo() <> Database::Customer then
            exit(false);
        if DetectedChange.CustomerNo() = '' then
            exit(false);
        // Disabled store: leave the row Pending (defer), do not drop the delete.
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", DetectedChange.StoreCode()) then
            exit(false);

        Customer."No." := DetectedChange.CustomerNo();
        RecRef.GetTable(Customer);
        SpfyScheduleSend.InitNcTask(DetectedChange.StoreCode(), RecRef, RecRef.RecordId(), Customer."No.", NcTask.Type::Delete, CurrentDateTime(), 0DT, Enum::"NPR Spfy Reuse Delayed NC Task"::Any, CreatedTaskQueue, NcTask);
        if NcTask."Entry No." = 0 then
            exit(false);
        DetectedChange.SetCreatedNcTaskEntryNo(NcTask."Entry No.");
        DetectedChange.SetCreatedTaskQueue(CreatedTaskQueue);
        exit(true);
    end;

    local procedure ProcessStoreCustomerLink(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        Baseline: JsonObject;
        CurrentHash: Text;
        RecRef: RecordRef;
        TaskType: Enum "NPR Spfy Change Type";
        NewCustomer: Boolean;
    begin
        if not SpfyStoreCustomerLink.GetBySystemId(DetectedChange.SystemId()) then
            exit;
        if not Customer.Get(SpfyStoreCustomerLink."No.") then
            exit;
        if not (SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled") then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code") then
            exit;
        if not SpfyCustomerMgt.TestRequiredFields(Customer, false) then
            exit;
        if not ResolveCustomerTaskType(SpfyStoreCustomerLink, TaskType) then
            exit;

        NewCustomer := SpfyStoreCustomerLink."Sync. to this Store" and not SpfyStoreCustomerLink."Synchronization Is Enabled";
        CurrentHash := SpfySyncStateMgt.StoreCustomerLinkPayloadHash(SpfyStoreCustomerLink);
        SpfySyncStateMgt.GetBaseline(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", Baseline);
        // Do NOT add the marketing flag to this guard: its reset is conditional, so guarding it could re-send forever.
        if (not NewCustomer) and (TaskType = "NPR Spfy Change Type"::Modify)
            and (SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetStoreCustomerLinkHashKey()) = CurrentHash)
            and (not SpfyStoreCustomerLink."Address Updated in BC")
        then
            exit;

        Clear(NcTask);
        case TaskType of
            "NPR Spfy Change Type"::Insert:
                NcTask.Type := NcTask.Type::Insert;
            "NPR Spfy Change Type"::Modify:
                NcTask.Type := NcTask.Type::Modify;
        end;
        RecRef.GetTable(Customer);
        TaskCreated := SpfyScheduleSend.InitNcTask(SpfyStoreCustomerLink."Shopify Store Code", RecRef, Customer."No.", NcTask.Type, NcTask);

        SpfySyncStateMgt.SetFacet(Baseline, SpfySyncStateMgt.GetStoreCustomerLinkHashKey(), CurrentHash);
        SpfySyncStateMgt.SaveBaseline(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", Baseline);
    end;

    // The sync-disable transition must NOT fall through to Modify: its delete is captured at the write path into the Deletion Log outbox.
    local procedure ResolveCustomerTaskType(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; var TaskType: Enum "NPR Spfy Change Type"): Boolean
    begin
        case true of
            SpfyStoreCustomerLink."Sync. to this Store" and not SpfyStoreCustomerLink."Synchronization Is Enabled":
                TaskType := "NPR Spfy Change Type"::Insert;
            SpfyStoreCustomerLink."Sync. to this Store" and SpfyStoreCustomerLink."Synchronization Is Enabled":
                TaskType := "NPR Spfy Change Type"::Modify;
            else
                exit(false);
        end;
        exit(true);
    end;
}
