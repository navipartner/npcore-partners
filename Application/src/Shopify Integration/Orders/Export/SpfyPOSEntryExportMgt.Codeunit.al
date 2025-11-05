#if not (BC17 or BC18 or BC19 or BC20)
codeunit 6248585 "NPR Spfy POS Entry Export Mgt."
{
    Access = Internal;
    TableNo = "NPR POS Entry";

    var
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;

    trigger OnRun()
    begin
        ProcessOutstandingPOSEntries(Rec, TempSpfyExportPointerBuffer);
    end;

    internal procedure ProcessOutstandingPOSEntries(var POSEntry: Record "NPR POS Entry"; var SpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer")
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        if SpfyExportPointerBuffer.IsEmpty() then
            exit;

        SpfyStoreCustomerLink.SetCurrentKey("Sync. to this Store");
        SpfyStoreCustomerLink.SetRange("Sync. to this Store", true);
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetFilter("Shopify Store Code", SpfyExportPointerBuffer.GetSpfyStoreFilter());

        if POSEntry.FindSet() then
            repeat
                SpfyStoreCustomerLink.SetRange("No.", POSEntry."Customer No.");
                ProcessPOSEntry(POSEntry, SpfyStoreCustomerLink, SpfyExportPointerBuffer);
            until POSEntry.Next() = 0;
    end;

    internal procedure ProcessPOSEntry(POSEntry: Record "NPR POS Entry"; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; var SpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer") TaskCreated: Boolean
    var
        SpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if not IsEligibleForSync(POSEntry) then
            exit;

        if SpfyStoreCustomerLink.FindSet() then
            repeat
                if SpfyExportPointerBuffer.Get(SpfyStoreCustomerLink."Shopify Store Code") then begin
                    if ((SpfyExportPointerBuffer."Cut-Off Date" = 0D) or (POSEntry."Entry Date" >= SpfyExportPointerBuffer."Cut-Off Date")) and
                       (POSEntry.SystemRowVersion > SpfyExportPointerBuffer."Cut-Off POS Entry Row Version")
                    then begin
                        SpfyStorePOSEntryLink."POS Entry No." := POSEntry."Entry No.";
                        SpfyStorePOSEntryLink."Shopify Store Code" := SpfyStoreCustomerLink."Shopify Store Code";
                        if SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") = '' then  //not yet sent to Shopify
                            TaskCreated := SchedulePOSEntrySync(POSEntry, SpfyStoreCustomerLink."Shopify Store Code") or TaskCreated;
                    end;

                    if POSEntry.SystemRowVersion > SpfyExportPointerBuffer."New Last POS Entry Row Version" then begin
                        SpfyExportPointerBuffer."New Last POS Entry Row Version" := POSEntry.SystemRowVersion;
                        SpfyExportPointerBuffer.Modify();
                    end;
                end;
            until SpfyStoreCustomerLink.Next() = 0;
    end;

    local procedure SchedulePOSEntrySync(POSEntry: Record "NPR POS Entry"; ShopifyStoreCode: Code[20]) TaskCreated: Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        clear(NcTask);
        NcTask.Type := NcTask.Type::Insert;

        RecRef.GetTable(POSEntry);
        TaskCreated := SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, Format(POSEntry."Entry No."), NcTask.Type, NcTask);
        if TaskCreated then
            Commit();
    end;

    internal procedure IsEligibleForSync(POSEntry: Record "NPR POS Entry"): Boolean
    begin
        exit(
            not POSEntry."System Entry" and
            (POSEntry."Customer No." <> '') and
            (POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale"]) and
            (POSEntry."Amount Excl. Tax" > 0)  //returns are not supported yet
        );
    end;

    internal procedure SetExportPointerBuffer(var SpfyExportPointerBufferIn: Record "NPR Spfy Export Pointer Buffer")
    begin
        TempSpfyExportPointerBuffer.Copy(SpfyExportPointerBufferIn, true);
    end;

    internal procedure GetExportPointerBuffer(var SpfyExportPointerBufferOut: Record "NPR Spfy Export Pointer Buffer")
    begin
        SpfyExportPointerBufferOut.Copy(TempSpfyExportPointerBuffer, true);
    end;
}
#endif