codeunit 6151193 "NPR Spfy Chg Hdlr Vouchers" implements "NPR Spfy Change Handler"
{
    Access = Internal;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";

    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    begin
        if DetectedChange.ChangeType() = "NPR Spfy Change Type"::Delete then
            exit(false);
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Retail Vouchers") then
            exit(false);
        case DetectedChange.TableNo() of
            Database::"NPR NpRv Voucher":
                exit(ProcessVoucher(DetectedChange));
            Database::"NPR NpRv Voucher Entry":
                exit(ProcessVoucherEntry(DetectedChange));
            Database::"NPR NpRv Arch. Voucher":
                exit(ProcessArchVoucher(DetectedChange));
        end;
        exit(false);
    end;

    local procedure ProcessVoucher(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        Voucher: Record "NPR NpRv Voucher";
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        Baseline: JsonObject;
        RecRef: RecordRef;
        StoreCode: Code[20];
        CurrentEndingDate: Text;
        ShouldSend: Boolean;
    begin
        if not Voucher.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        if not ResolveVoucherStore(Voucher, StoreCode) then
            exit(false);

        CurrentEndingDate := Format(DT2Date(Voucher."Ending Date"), 0, 9);
        SpfySyncStateMgt.GetBaseline(Database::"NPR NpRv Voucher", Voucher.SystemId, StoreCode, Baseline);
        // Only send on a proven Ending Date change against a known baseline. A synced voucher with no baseline
        // (restored from archive via Unarchive, or after a reset) adopts its baseline WITHOUT sending — matching the
        // old Data Log path, which exited on Insert and pushed only on an Ending Date modify. Seeding pre-establishes
        // baselines for existing synced vouchers (SpfySyncStateSeedWorker), so no legitimate change is missed.
        if SpfySyncStateMgt.HasBaseline(Database::"NPR NpRv Voucher", Voucher.SystemId, StoreCode) then
            ShouldSend := SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetVoucherEndingDateKey()) <> CurrentEndingDate;

        if ShouldSend then begin
            Clear(NcTask);
            RecRef.GetTable(Voucher);
            TaskCreated := SpfyScheduleSend.InitNcTask(StoreCode, RecRef, Voucher."No.", NcTask.Type::Modify, NcTask);
        end;

        SpfySyncStateMgt.SetFacet(Baseline, SpfySyncStateMgt.GetVoucherEndingDateKey(), CurrentEndingDate);
        SpfySyncStateMgt.SaveBaseline(Database::"NPR NpRv Voucher", Voucher.SystemId, StoreCode, Baseline);
        exit(TaskCreated);
    end;

    local procedure ProcessVoucherEntry(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        NcTask: Record "NPR Nc Task";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        VoucherRecRef: RecordRef;
        EntryRecRef: RecordRef;
        StoreCode: Code[20];
    begin
        if not VoucherEntry.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        if VoucherEntry."Spfy Initiated in Shopify" and (VoucherEntry."Entry Type" in [VoucherEntry."Entry Type"::"Issue Voucher", VoucherEntry."Entry Type"::"Top-up"]) then
            exit(false);

        Voucher."No." := VoucherEntry."Voucher No.";
        if not Voucher.Find() then begin
            if not SpfyRetailVoucherMgt.FindAndCopyFromArchivedVoucher(ArchVoucher, Voucher) then
                exit(false);
            VoucherRecRef.GetTable(ArchVoucher);
        end else
            VoucherRecRef.GetTable(Voucher);

        if not ResolveVoucherStore(Voucher, StoreCode) then
            exit(false);

        if SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID") = '' then begin
            // Insert dispatch is by table no.: swap an archived RecRef back to the voucher so the gift-card upsert runs, not the disable branch.
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then
                VoucherRecRef.GetTable(Voucher);
            Clear(NcTask);
            TaskCreated := SpfyScheduleSend.InitNcTask(StoreCode, VoucherRecRef, Voucher."No.", NcTask.Type::Insert, NcTask);
        end;

        Clear(NcTask);
        EntryRecRef.GetTable(VoucherEntry);
        TaskCreated := SpfyScheduleSend.InitNcTask(StoreCode, EntryRecRef, Voucher."No.", NcTask.Type::Modify, NcTask) or TaskCreated;
        exit(TaskCreated);
    end;

    local procedure ProcessArchVoucher(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        Voucher: Record "NPR NpRv Voucher";
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        ArchRecRef: RecordRef;
        StoreCode: Code[20];
    begin
        if not ArchVoucher.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        if ArchVoucher."Disabled at Shopify" then
            exit(false);

        Voucher.TransferFields(ArchVoucher);
        if ArchVoucher."Arch. No." <> '' then
            Voucher."No." := ArchVoucher."Arch. No."
        else
            Voucher."No." := ArchVoucher."No.";

        if not ResolveVoucherStore(Voucher, StoreCode) then
            exit(false);

        Clear(NcTask);
        ArchRecRef.GetTable(ArchVoucher);
        exit(SpfyScheduleSend.InitNcTask(StoreCode, ArchRecRef, Voucher."No.", NcTask.Type::Modify, NcTask));
    end;

    local procedure ResolveVoucherStore(Voucher: Record "NPR NpRv Voucher"; var StoreCode: Code[20]): Boolean
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        StoreCode := '';
        if Voucher."No." = '' then
            exit(false);
        if not SpfyRetailVoucherMgt.IsShopifyIntegratedVoucherType(Voucher."Voucher Type") then
            exit(false);
        if not VoucherType.Get(Voucher."Voucher Type") then
            exit(false);
        StoreCode := VoucherType.GetStoreCode();
        exit(SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Retail Vouchers", StoreCode));
    end;
}
