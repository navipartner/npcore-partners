#if not BC17
codeunit 6184816 "NPR Spfy Retail Voucher Mgt."
{
    Access = Internal;
    TableNo = "NPR Data Log Record";

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";

    procedure ProcessDataLogRecord(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    begin
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Retail Vouchers") then
            exit;

        case DataLogEntry."Table ID" of
            Database::"NPR NpRv Voucher":
                TaskCreated := ProcessVoucher(DataLogEntry);
            Database::"NPR NpRv Voucher Entry":
                TaskCreated := UpdateShopifyGiftCardBalance(DataLogEntry);
            Database::"NPR NpRv Arch. Voucher":
                TaskCreated := DisableShopifyGiftCard(DataLogEntry);
            else
                exit;
        end;
        Commit();
    end;

    local procedure ProcessVoucher(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        xVoucher: Record "NPR NpRv Voucher";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        VoucherRecRef: RecordRef;
        xVoucherRecRef: RecordRef;
        ShopifyStoreCode: Code[20];
    begin
        if DataLogEntry."Type of Change" In [DataLogEntry."Type of Change"::Rename, DataLogEntry."Type of Change"::Delete] then
            exit;  //Deletes and renames are not supported
        if DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Insert then
            exit;  //New vouchers are sent, when initial balance is registered
        if not FindVoucher(DataLogEntry, VoucherRecRef, Voucher, ShopifyStoreCode) then
            exit;

        if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, xVoucherRecRef) then begin
            xVoucherRecRef.SetTable(xVoucher);
            if DT2Date(Voucher."Ending Date") = DT2Date(xVoucher."Ending Date") then
                exit;  //No changes to send
        end;

        NcTask.Type := NcTask.Type::Modify;
        exit(SpfyScheduleSend.InitNcTask(ShopifyStoreCode, DataLogEntry."Record ID".GetRecord(), Voucher."No.", NcTask.Type, NcTask));
    end;

    local procedure UpdateShopifyGiftCardBalance(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        VoucherRecRef: RecordRef;
        ShopifyStoreCode: Code[20];
    begin
        if DataLogEntry."Type of Change" In [DataLogEntry."Type of Change"::Rename, DataLogEntry."Type of Change"::Delete] then
            exit;
        if not FindVoucher(DataLogEntry, VoucherRecRef, Voucher, ShopifyStoreCode) then
            exit;

        if SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecRef.RecordId(), "NPR Spfy ID Type"::"Entry ID") = '' then begin
            NcTask.Type := NcTask.Type::Insert;
            if VoucherRecRef.Number = Database::"NPR NpRv Arch. Voucher" then
                VoucherRecRef.GetTable(Voucher);
            TaskCreated := SpfyScheduleSend.InitNcTask(ShopifyStoreCode, VoucherRecRef, Voucher."No.", NcTask.Type, NcTask);
        end;

        Clear(NcTask);
        NcTask.Type := NcTask.Type::Modify;
        TaskCreated := SpfyScheduleSend.InitNcTask(ShopifyStoreCode, DataLogEntry."Record ID".GetRecord(), Voucher."No.", NcTask.Type, NcTask) or TaskCreated;
    end;

    local procedure DisableShopifyGiftCard(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        VoucherRecRef: RecordRef;
        ShopifyStoreCode: Code[20];
    begin
        if DataLogEntry."Type of Change" <> DataLogEntry."Type of Change"::Insert then
            exit;
        if not FindVoucher(DataLogEntry, VoucherRecRef, Voucher, ShopifyStoreCode) then
            exit;

        Clear(NcTask);
        NcTask.Type := NcTask.Type::Modify;
        exit(SpfyScheduleSend.InitNcTask(ShopifyStoreCode, VoucherRecRef, Voucher."No.", NcTask.Type, NcTask));
    end;

    procedure FindVoucher(ContainerRec: Variant; var VoucherRecRef: RecordRef; var Voucher: Record "NPR NpRv Voucher"; var ShopifyStoreCode: Code[20]): Boolean
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        DataLogEntry: Record "NPR Data Log Record";
        NcTask: Record "NPR Nc Task";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        VoucherType: Record "NPR NpRv Voucher Type";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        DataTypeMgt: Codeunit "Data Type Management";
        ContainerRecRef: RecordRef;
        SourceRecId: RecordId;
        xRecRestored: Boolean;
    begin
        Clear(Voucher);
        if not DataTypeMgt.GetRecordRef(ContainerRec, ContainerRecRef) then
            exit(false);
        case ContainerRecRef.Number of
            Database::"NPR Data Log Record":
                begin
                    ContainerRecRef.SetTable(DataLogEntry);
                    SourceRecId := DataLogEntry."Record ID";
                end;
            Database::"NPR Nc Task":
                begin
                    ContainerRecRef.SetTable(NcTask);
                    SourceRecId := NcTask."Record ID";
                end;
            else
                exit(false);
        end;
        VoucherRecRef := SourceRecId.GetRecord();

        case SourceRecId.TableNo of
            Database::"NPR NpRv Voucher":
                VoucherRecRef.SetTable(Voucher);
            Database::"NPR NpRv Arch. Voucher":
                begin
                    if not VoucherRecRef.Find() then
                        exit(false);
                    VoucherRecRef.SetTable(ArchVoucher);
                    CopyFromArchivedVoucher(ArchVoucher, Voucher);
                end;
            Database::"NPR NpRv Voucher Entry":
                begin
                    VoucherRecRef.SetTable(VoucherEntry);
                    if not VoucherEntry.Find() then
                        case ContainerRecRef.Number of
                            Database::"NPR Data Log Record":
                                begin
                                    xRecRestored := DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, VoucherRecRef);
                                    if not xRecRestored then
                                        exit(false);
                                    VoucherRecRef.SetTable(VoucherEntry);
                                end;
                            Database::"NPR Nc Task":
                                VoucherEntry."Voucher No." := CopyStr(NcTask."Record Value", 1, MaxStrLen(VoucherEntry."Voucher No."));
                        end;
                    Voucher."No." := VoucherEntry."Voucher No.";
                    if Voucher.Find() then
                        VoucherRecRef.GetTable(Voucher);
                end;
            else
                exit(false)
        end;

        If Voucher."No." = '' then
            exit(false);

        if SourceRecId.TableNo <> Database::"NPR NpRv Arch. Voucher" then
            if not Voucher.Find() then begin
                if not FindAndCopyFromArchivedVoucher(ArchVoucher, Voucher) then
                    exit(false);
                VoucherRecRef.GetTable(ArchVoucher);
            end;

        VoucherType.Code := Voucher."Voucher Type";
        if not IsShopifyIntegratedVoucherType(VoucherType.Code) then
            exit(false);
        ShopifyStoreCode := VoucherType.GetStoreCode();
        exit(SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Retail Vouchers", ShopifyStoreCode));
    end;

    procedure FindAndCopyFromArchivedVoucher(var ArchVoucher: Record "NPR NpRv Arch. Voucher"; var Voucher: Record "NPR NpRv Voucher"): Boolean
    begin
        ArchVoucher.SetCurrentKey("Arch. No.");
        ArchVoucher.SetRange("Arch. No.", Voucher."No.");
        if not ArchVoucher.FindLast() then
            exit(false);
        CopyFromArchivedVoucher(ArchVoucher, Voucher);
        exit(true);
    end;

    local procedure CopyFromArchivedVoucher(ArchVoucher: Record "NPR NpRv Arch. Voucher"; var Voucher: Record "NPR NpRv Voucher")
    begin
        clear(Voucher);
        Voucher.TransferFields(ArchVoucher);
        if ArchVoucher."Arch. No." <> '' then
            Voucher."No." := ArchVoucher."Arch. No."
        else
            Voucher."No." := ArchVoucher."No.";
    end;

    procedure TestRequiredFields(Voucher: Record "NPR NpRv Voucher")
    var
        VourcherType: Record "NPR NpRv Voucher Type";
    begin
        Voucher.TestField("No.");
        Voucher.TestField("Voucher Type");
        VourcherType.Get(Voucher."Voucher Type");
        VourcherType.TestField("Integrate with Shopify");
        VourcherType.CheckStoreIsAssigned(true);
    end;

    procedure IsShopifyIntegratedVoucherType(VoucherTypeCode: Code[20]): Boolean
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        if not GetVoucherType(VoucherTypeCode, VoucherType) then
            exit(false);
        exit(VoucherType."Integrate with Shopify");
    end;

    procedure IsShopifySyncedVoucher(VoucherRecId: RecordId): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(VoucherRecId, "NPR Spfy ID Type"::"Entry ID") <> '');
    end;

    local procedure GetVoucherType(VoucherTypeCode: Code[20]; var VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    begin
        Clear(VoucherType);
        if VoucherTypeCode = '' then
            exit(false);
        exit(VoucherType.Get(VoucherTypeCode));
    end;


    procedure GetVoucherNo(ShopifyVoucherId: Text[30]; var NpRvVoucher: Record "NPR NpRv Voucher")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        RecRef: RecordRef;
    begin
        SpfyAssignedIDMgt.FilterWhereUsed("NPR Spfy ID Type"::"Entry ID", ShopifyVoucherId, false, ShopifyAssignedID);
        ShopifyAssignedID.SetRange("Table No.", Database::"NPR NpRv Voucher");
        if ShopifyAssignedID.FindFirst() then
            if RecRef.Get(ShopifyAssignedID."BC Record ID") then
                RecRef.SetTable(NpRvVoucher);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnBeforeInsertEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", OnBeforeInsertEvent, '', true, false)]
#endif
    local procedure CheckVoucherOnInsert(var Rec: Record "NPR NpRv Voucher")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckReferenceNo(Rec);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnBeforeValidateEvent', 'Reference No.', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", OnBeforeValidateEvent, 'Reference No.', true, false)]
#endif
    local procedure ReferenceNoOnValidate(var Rec: Record "NPR NpRv Voucher")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckReferenceNo(Rec);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnBeforeRenameEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", OnBeforeRenameEvent, '', true, false)]
#endif
    local procedure BlockShopifyVoucherRename(var Rec: Record "NPR NpRv Voucher")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckIfShopifyVoucherAndThrowError(Rec.RecordId(), Rec."Voucher Type", 0, false);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", 'OnBeforeDeleteEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", OnBeforeDeleteEvent, '', true, false)]
#endif
    local procedure BlockShopifyVoucherDelete(var Rec: Record "NPR NpRv Voucher"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CheckIfShopifyVoucherAndThrowError(Rec.RecordId(), Rec."Voucher Type", 1, true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", 'OnBeforeRenameEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Arch. Voucher", OnBeforeRenameEvent, '', true, false)]
#endif
    local procedure BlockShopifyArchVoucherRename(var Rec: Record "NPR NpRv Arch. Voucher")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckIfShopifyVoucherAndThrowError(Rec.RecordId(), Rec."Voucher Type", 0, true);
    end;

    local procedure CheckIfShopifyVoucherAndThrowError(VoucherRecId: RecordId; VoucherTypeCode: Code[20]; ActionType: Option Rename,Delete; OnlySynced: Boolean)
    var
        ChangeDisallowed: Boolean;
        ActionTypeOptionCaptions: Label 'rename,delete';
        ActionNotAllowedErr: Label 'You cannot %1 a Shopify integrated retail voucher.', Comment = '%1 - action (rename/delete)';
    begin
        if OnlySynced then
            ChangeDisallowed := IsShopifySyncedVoucher(VoucherRecId)
        else
            ChangeDisallowed := IsShopifyIntegratedVoucherType(VoucherTypeCode);

        if ChangeDisallowed then
            Error(ActionNotAllowedErr, SelectStr(ActionType + 1, ActionTypeOptionCaptions));
    end;

    local procedure CheckReferenceNo(Voucher: Record "NPR NpRv Voucher")
    var
        IncorrectRefNoLengthErr: Label 'Shopify integrated vouchers must have reference number string lenght between 8 and 20 characters.';
    begin
        if Voucher."Reference No." = '' then
            exit;
        if IsShopifyIntegratedVoucherType(Voucher."Voucher Type") then
            if not (StrLen(Voucher."Reference No.") in [8 .. 20]) then
                Error(IncorrectRefNoLengthErr);
    end;

    procedure InitialSync(var ShopifyStore: Record "NPR Spfy Store"; var VoucherTypeIn: Record "NPR NpRv Voucher Type"; var VoucherIn: Record "NPR NpRv Voucher"; WithDialog: Boolean)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        ConfirmQst: Label 'This batch job will do intial retail voucher migration from BC to Shopify. It will go through retail vouchers in BC and create those marked as synchronizable with your Shopify Store ''%1'' as gift cards at the store. System will also update gift cards balances at Shopify, if needed.';
        DialogText1Lbl: Label 'Syncing retail vouchers to Shopify Store ''%1''...\\';
        DialogText2Lbl: Label 'Voucher Type #1########\';
        DialogText3Lbl: Label 'Voucher No.  #2########\';
        DialogText4Lbl: Label 'Progress     @3@@@@@@@@';
        DoneLbl: Label 'The operation completed successfully.';
        NothingToDoErr: Label 'There is nothing to do (there are no retail vouchers in the system to be sent to Shopify Store ''%1'').';
        StoreNotSelectedErr: Label 'You must select a Shopify Store Code.';
    begin
        if ShopifyStore.Count() <> 1 then
            Error(StoreNotSelectedErr);
        ShopifyStore.FindFirst();
        SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::"Retail Vouchers", ShopifyStore.Code);

        if WithDialog then
            if not Confirm(ConfirmQst + '\' + SpfyIntegrationMgt.LongRunningProcessConfirmQst(), true, ShopifyStore.Code) then
                exit;

        VoucherType.Copy(VoucherTypeIn);
        Voucher.Copy(VoucherIn);
        TotalRecNo := 0;
        VoucherType.FilterGroup(2);
        VoucherType.SetRange("Integrate with Shopify", true);
        VoucherType.FilterGroup(0);
        if VoucherType.FindSet() then
            repeat
                VoucherType.Mark(VoucherType.GetStoreCode() = ShopifyStore.Code);
                if VoucherType.Mark() then begin
                    Voucher.FilterGroup(2);
                    Voucher.SetRange("Voucher Type", VoucherType.Code);
                    Voucher.FilterGroup(0);
                    TotalRecNo += Voucher.Count();
                end;
            until VoucherType.Next() = 0;

        if TotalRecNo <= 0 then
            Error(NothingToDoErr, ShopifyStore.Code);

        if WithDialog then
            Window.Open(
                StrSubstNo(DialogText1Lbl, ShopifyStore.Code) +
                DialogText2Lbl +
                DialogText3Lbl +
                DialogText4Lbl);

        Voucher.SetAutoCalcFields("Initial Amount", Amount);
        VoucherType.MarkedOnly(true);
        VoucherType.FindSet();
        repeat
            if WithDialog then
                Window.Update(1, VoucherType.Code);

            Voucher.FilterGroup(2);
            Voucher.SetRange("Voucher Type", VoucherType.Code);
            Voucher.FilterGroup(0);
            if Voucher.FindSet() then
                repeat
                    if WithDialog then
                        Window.Update(2, Voucher."No.");

                    RetailVoucherInitialSync(Voucher, ShopifyStore.Code);
                    Commit();

                    if WithDialog then begin
                        RecNo += 1;
                        Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                    end;
                until Voucher.Next() = 0;
        until VoucherType.Next() = 0;

        if WithDialog then begin
            Window.Close();
            Message(DoneLbl);
        end;
    end;

    local procedure RetailVoucherInitialSync(Voucher: Record "NPR NpRv Voucher"; ShopifyStoreCode: Code[20]) TaskCreated: Boolean
    var
        NcTask: Record "NPR Nc Task";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        ShopifyGiftCardID: Text[30];
    begin
        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if (ShopifyGiftCardID = '') and (Voucher.Amount <= 0) then
            exit;

        if ShopifyGiftCardID = '' then begin
            NcTask.Type := NcTask.Type::Insert;
            TaskCreated := SpfyScheduleSend.InitNcTask(ShopifyStoreCode, Voucher.RecordId().GetRecord(), Voucher."No.", NcTask.Type, NcTask);
            if Voucher.Amount = Voucher."Initial Amount" then
                exit;
        end;

        VoucherEntry.SetCurrentKey("Voucher No.");
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        VoucherEntry.FindLast();
        Clear(NcTask);
        NcTask.Type := NcTask.Type::Modify;
        TaskCreated := SpfyScheduleSend.InitNcTask(ShopifyStoreCode, VoucherEntry.RecordId().GetRecord(), Voucher."No.", NcTask.Type, NcTask);
    end;
}
#endif