#if not BC17
codeunit 6248553 "NPR Spfy Customer Mgt."
{
    Access = Internal;
    TableNo = "NPR Data Log Record";

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";

    internal procedure ProcessDataLogRecord(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        case DataLogEntry."Table ID" of
            Database::"NPR Spfy Store-Customer Link":
                begin
                    TaskCreated := ProcessStoreCustomerLink(DataLogEntry);
                end;
            Database::"NPR Spfy Entity Metafield":
                begin
                    TaskCreated := SpfyMetafieldMgt.ProcessMetafield(DataLogEntry);
                end;
            else
                exit;
        end;
        Commit();
    end;

    local procedure ScheduleCustomerSync(DataLogEntry: Record "NPR Data Log Record"; Customer: Record Customer; SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        clear(NcTask);
        case true of
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Insert:
                NcTask.Type := NcTask.Type::Insert;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Modify:
                begin
                    case true of
                        not SpfyStoreCustomerLink."Sync. to this Store" and not SpfyStoreCustomerLink."Synchronization Is Enabled":
                            exit;
                        SpfyStoreCustomerLink."Sync. to this Store" and not SpfyStoreCustomerLink."Synchronization Is Enabled":
                            NcTask.Type := NcTask.Type::Insert;
                        not SpfyStoreCustomerLink."Sync. to this Store" and SpfyStoreCustomerLink."Synchronization Is Enabled":
                            NcTask.Type := NcTask.Type::Delete;
                        else
                            NcTask.Type := NcTask.Type::Modify;
                    end;
                end;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete:
                NcTask.Type := NcTask.Type::Delete;
        end;

        RecRef.GetTable(Customer);
        exit(SpfyScheduleSend.InitNcTask(SpfyStoreCustomerLink."Shopify Store Code", RecRef, Customer."No.", NcTask.Type, NcTask));
    end;

    local procedure ProcessStoreCustomerLink(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        RecRef: RecordRef;
    begin
        if DataLogEntry."Type of Change" in [DataLogEntry."Type of Change"::Rename, DataLogEntry."Type of Change"::Delete] then
            exit;

        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SpfyStoreCustomerLink);
        if not SpfyStoreCustomerLink.Find() or not Customer.Get(SpfyStoreCustomerLink."No.") then
            exit;
        if not (SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled") then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code") then
            exit;
        if not TestRequiredFields(Customer, false) then
            exit;

        DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Modify;
        exit(ScheduleCustomerSync(DataLogEntry, Customer, SpfyStoreCustomerLink));
    end;

    internal procedure ProcessMetafield(SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; var ShopifyStoreCode: Code[20]; var TaskRecordValue: Text): Boolean
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        RecRef: RecordRef;
    begin
        if SpfyEntityMetafield."Table No." <> Database::"NPR Spfy Store-Customer Link" then
            exit;

        RecRef := SpfyEntityMetafield."BC Record ID".GetRecord();
        RecRef.SetTable(SpfyStoreCustomerLink);
        if SpfyStoreCustomerLink.Type <> SpfyStoreCustomerLink.Type::Customer then
            exit;
        if not Customer.Get(SpfyStoreCustomerLink."No.") then
            exit;
        if not (SpfyStoreCustomerLink.Find() and (SpfyStoreCustomerLink."Sync. to this Store" or SpfyStoreCustomerLink."Synchronization Is Enabled")) then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code") then
            exit;
        if not TestRequiredFields(Customer, false) then
            exit;

        ShopifyStoreCode := SpfyStoreCustomerLink."Shopify Store Code";
        TaskRecordValue := Customer."No.";
        exit(true);
    end;

    internal procedure TestRequiredFields(Customer: Record Customer; WithError: Boolean): Boolean
    begin
        if WithError then begin
            if Customer.Blocked = Customer.Blocked::All then
                Customer.FieldError(Blocked);
            exit(true);
        end;

        exit(
            Customer.Blocked <> Customer.Blocked::All);
    end;

    internal procedure AutoEnableCustomerSync(Customer: Record Customer)
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
    begin
        if Customer."E-Mail" = '' then
            exit;
        SpfyStore.SetRange("Auto Sync New Customers", SpfyStore."Auto Sync New Customers"::MembershipOnly);
        if SpfyStore.IsEmpty() then
            exit;
        if not SpfyIntegrationMgt.IsEnabledForAnyStore(Enum::"NPR Spfy Integration Area"::"Sales Orders") then
            exit;

        SpfyStore.FindSet();
        repeat
            if SpfyIntegrationMgt.IsEnabled(Enum::"NPR Spfy Integration Area"::"Sales Orders", SpfyStore) then begin
                SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
                SpfyStoreCustomerLink."No." := Customer."No.";
                SpfyStoreCustomerLink."Shopify Store Code" := SpfyStore.Code;
                if not SpfyStoreCustomerLink.Find() then begin
                    SpfyStoreLinkMgt.UpdateStoreCustomerLinks(Customer);
                    SpfyStoreCustomerLink.Find();
                end;
                if not SpfyStoreCustomerLink."Sync. to this Store" then
                    SpfyStoreCustomerLink.Validate("Sync. to this Store", true);  //also modifies the record during field validation
            end;
        until SpfyStore.Next() = 0;
    end;

    internal procedure FindCustomerByShopifyID(ShopifyStoreCode: Code[20]; CustomerId: Text[30]; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link") Found: Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
    begin
        Clear(SpfyStoreCustomerLink);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Spfy Store-Customer Link", "NPR Spfy ID Type"::"Entry ID", CustomerId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SpfyStoreCustomerLink);
                    SpfyStoreCustomerLink.Mark(
                        (SpfyStoreCustomerLink.Type = SpfyStoreCustomerLink.Type::Customer) and (SpfyStoreCustomerLink."No." <> '') and
                        (SpfyStoreCustomerLink."Shopify Store Code" = ShopifyStoreCode));
                end;
            until ShopifyAssignedID.Next() = 0;
        SpfyStoreCustomerLink.MarkedOnly(true);
        Found := not SpfyStoreCustomerLink.IsEmpty();
    end;

    local procedure CheckCustomerIsSynchronized(Customer: Record Customer): Boolean
    begin
        Customer.CalcFields("NPR Spfy Synced Customer");
        exit(Customer."NPR Spfy Synced Customer");
    end;

    internal procedure CustomerIsPlannedForSync(Customer: Record Customer): Boolean
    begin
        Customer.CalcFields("NPR Spfy Synced Cust.(Planned)");
        exit(Customer."NPR Spfy Synced Cust.(Planned)");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeRenameEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeRenameEvent, '', true, false)]
#endif
    local procedure CheckNotShopifyCustomerOnRename(var Rec: Record Customer)
    var
        RenameNotAllowedErr: Label 'Shopify enabled customers cannot be renamed.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckCustomerIsSynchronized(Rec) then
            Error(RenameNotAllowedErr);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeDeleteEvent, '', true, false)]
#endif
    local procedure CheckNotShopifyCustomerOnDelete(var Rec: Record Customer)
    var
        DeleteNotAllowedErr: Label 'The customer has already been synchronized with one or more Shopify stores. First, you will need to disable customer synchronization with all Shopify stores and wait for the changes to sync with Shopify. Only then will you be able to delete the customer from Business Central.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckCustomerIsSynchronized(Rec) then
            Error(DeleteNotAllowedErr);
    end;
}
#endif