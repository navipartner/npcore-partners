codeunit 6184703 "NPR Entria Prod. Type Subscr."
{
    Access = Internal;

    // Stateless: OnBefore marks the items the stored row contributes before the write, OnAfter the items it contributes after.
    // Field values are never taken from Rec or xRec. They only identify the stored row.
    // The membership tables have no Modify subscribers because every field their collector filters read is in the primary key.

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Sales Setup", OnAfterInsertEvent, '', false, false)]
    local procedure MembersSalesSetupOnAfterInsert(var Rec: Record "NPR MM Members. Sales Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipSaleItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Sales Setup", OnBeforeDeleteEvent, '', false, false)]
    local procedure MembersSalesSetupOnBeforeDelete(var Rec: Record "NPR MM Members. Sales Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipSaleItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Sales Setup", OnBeforeRenameEvent, '', false, false)]
    local procedure MembersSalesSetupOnBeforeRename(var Rec: Record "NPR MM Members. Sales Setup"; var xRec: Record "NPR MM Members. Sales Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipSaleItemNo(GetStoredSystemIdBeforeRename(Rec, xRec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Sales Setup", OnAfterRenameEvent, '', false, false)]
    local procedure MembersSalesSetupOnAfterRename(var Rec: Record "NPR MM Members. Sales Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipSaleItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Alter. Setup", OnAfterInsertEvent, '', false, false)]
    local procedure MembersAlterSetupOnAfterInsert(var Rec: Record "NPR MM Members. Alter. Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipAlterationItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Alter. Setup", OnBeforeDeleteEvent, '', false, false)]
    local procedure MembersAlterSetupOnBeforeDelete(var Rec: Record "NPR MM Members. Alter. Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipAlterationItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Alter. Setup", OnBeforeRenameEvent, '', false, false)]
    local procedure MembersAlterSetupOnBeforeRename(var Rec: Record "NPR MM Members. Alter. Setup"; var xRec: Record "NPR MM Members. Alter. Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipAlterationItemNo(GetStoredSystemIdBeforeRename(Rec, xRec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Members. Alter. Setup", OnAfterRenameEvent, '', false, false)]
    local procedure MembersAlterSetupOnAfterRename(var Rec: Record "NPR MM Members. Alter. Setup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetMembershipAlterationItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR WalletCouponSetup", OnAfterInsertEvent, '', false, false)]
    local procedure WalletCouponSetupOnAfterInsert(var Rec: Record "NPR WalletCouponSetup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetWalletCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR WalletCouponSetup", OnBeforeModifyEvent, '', false, false)]
    local procedure WalletCouponSetupOnBeforeModify(var Rec: Record "NPR WalletCouponSetup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetWalletCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR WalletCouponSetup", OnAfterModifyEvent, '', false, false)]
    local procedure WalletCouponSetupOnAfterModify(var Rec: Record "NPR WalletCouponSetup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetWalletCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR WalletCouponSetup", OnBeforeDeleteEvent, '', false, false)]
    local procedure WalletCouponSetupOnBeforeDelete(var Rec: Record "NPR WalletCouponSetup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetWalletCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR WalletCouponSetup", OnBeforeRenameEvent, '', false, false)]
    local procedure WalletCouponSetupOnBeforeRename(var Rec: Record "NPR WalletCouponSetup"; var xRec: Record "NPR WalletCouponSetup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetWalletCouponItemNo(GetStoredSystemIdBeforeRename(Rec, xRec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR WalletCouponSetup", OnAfterRenameEvent, '', false, false)]
    local procedure WalletCouponSetupOnAfterRename(var Rec: Record "NPR WalletCouponSetup")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetWalletCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Iss.OnEcomSale S.Line", OnAfterInsertEvent, '', false, false)]
    local procedure EcomSaleCouponLineOnAfterInsert(var Rec: Record "NPR NpDc Iss.OnEcomSale S.Line")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetEcomSaleCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Iss.OnEcomSale S.Line", OnBeforeModifyEvent, '', false, false)]
    local procedure EcomSaleCouponLineOnBeforeModify(var Rec: Record "NPR NpDc Iss.OnEcomSale S.Line")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetEcomSaleCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Iss.OnEcomSale S.Line", OnAfterModifyEvent, '', false, false)]
    local procedure EcomSaleCouponLineOnAfterModify(var Rec: Record "NPR NpDc Iss.OnEcomSale S.Line")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetEcomSaleCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Iss.OnEcomSale S.Line", OnBeforeDeleteEvent, '', false, false)]
    local procedure EcomSaleCouponLineOnBeforeDelete(var Rec: Record "NPR NpDc Iss.OnEcomSale S.Line")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetEcomSaleCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Iss.OnEcomSale S.Line", OnBeforeRenameEvent, '', false, false)]
    local procedure EcomSaleCouponLineOnBeforeRename(var Rec: Record "NPR NpDc Iss.OnEcomSale S.Line"; var xRec: Record "NPR NpDc Iss.OnEcomSale S.Line")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetEcomSaleCouponItemNo(GetStoredSystemIdBeforeRename(Rec, xRec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Iss.OnEcomSale S.Line", OnAfterRenameEvent, '', false, false)]
    local procedure EcomSaleCouponLineOnAfterRename(var Rec: Record "NPR NpDc Iss.OnEcomSale S.Line")
    var
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        MarkItem(EntriaProdTypeMgt.GetEcomSaleCouponItemNo(GetStoredSystemId(Rec)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnAfterInsertEvent, '', false, false)]
    local procedure CouponTypeOnAfterInsert(var Rec: Record "NPR NpDc Coupon Type")
    begin
        if Rec.IsTemporary() then
            exit;
        MarkEnabledCouponTypeItems(GetStoredSystemId(Rec));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnBeforeModifyEvent, '', false, false)]
    local procedure CouponTypeOnBeforeModify(var Rec: Record "NPR NpDc Coupon Type")
    begin
        if Rec.IsTemporary() then
            exit;
        MarkEnabledCouponTypeItems(GetStoredSystemId(Rec));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnAfterModifyEvent, '', false, false)]
    local procedure CouponTypeOnAfterModify(var Rec: Record "NPR NpDc Coupon Type")
    begin
        if Rec.IsTemporary() then
            exit;
        MarkEnabledCouponTypeItems(GetStoredSystemId(Rec));
    end;

    // Runs before the children are deleted, so they can still be read.
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnBeforeDeleteEvent, '', false, false)]
    local procedure CouponTypeOnBeforeDelete(var Rec: Record "NPR NpDc Coupon Type")
    begin
        if Rec.IsTemporary() then
            exit;
        MarkEnabledCouponTypeItems(GetStoredSystemId(Rec));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnBeforeRenameEvent, '', false, false)]
    local procedure CouponTypeOnBeforeRename(var Rec: Record "NPR NpDc Coupon Type"; var xRec: Record "NPR NpDc Coupon Type")
    begin
        if Rec.IsTemporary() then
            exit;
        MarkEnabledCouponTypeItems(GetStoredSystemIdBeforeRename(Rec, xRec));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnAfterRenameEvent, '', false, false)]
    local procedure CouponTypeOnAfterRename(var Rec: Record "NPR NpDc Coupon Type")
    begin
        if Rec.IsTemporary() then
            exit;
        MarkEnabledCouponTypeItems(GetStoredSystemId(Rec));
    end;

    local procedure MarkItem(ItemNo: Code[20])
    var
        TempItemChange: Record "NPR Inventory Item Change" temporary;
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
        ItemChangeMgt: Codeunit "NPR Inventory Item Change Mgt.";
    begin
        ItemChangeMgt.AddItemNo(TempItemChange, ItemNo);
        EntriaProdTypeMgt.MarkEntriaItemsChanged(TempItemChange);
    end;

    // A disabled or missing coupon type has code '', so nothing is read or marked.
    local procedure MarkEnabledCouponTypeItems(StoredId: Guid)
    var
        TempItemChange: Record "NPR Inventory Item Change" temporary;
        EntriaProdTypeMgt: Codeunit "NPR Entria Prod. Type Mgt.";
    begin
        EntriaProdTypeMgt.AddCouponTypeItemNos(TempItemChange, EntriaProdTypeMgt.GetEnabledCouponTypeCode(StoredId));
        EntriaProdTypeMgt.MarkEntriaItemsChanged(TempItemChange);
    end;

    // A row renamed without being read has no SystemId. Its old key, in xRec, finds the stored row. Best effort.
    local procedure GetStoredSystemIdBeforeRename(RowVariant: Variant; OldRowVariant: Variant): Guid
    var
        RecRef: RecordRef;
        SystemId: Guid;
    begin
        RecRef.GetTable(RowVariant);
        SystemId := RecRef.Field(RecRef.SystemIdNo()).Value;
        if IsNullGuid(SystemId) then
            exit(GetStoredSystemId(OldRowVariant));
        exit(SystemId);
    end;

    // A row written without being read first has no SystemId. Its primary key then finds the stored row.
    local procedure GetStoredSystemId(RowVariant: Variant): Guid
    var
        RecRef: RecordRef;
        StoredRecRef: RecordRef;
        SystemId: Guid;
    begin
        RecRef.GetTable(RowVariant);
        SystemId := RecRef.Field(RecRef.SystemIdNo()).Value;
        if not IsNullGuid(SystemId) then
            exit(SystemId);
        StoredRecRef.Open(RecRef.Number());
        if StoredRecRef.Get(RecRef.RecordId()) then
            exit(StoredRecRef.Field(StoredRecRef.SystemIdNo()).Value);
    end;
}
