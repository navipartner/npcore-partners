codeunit 6248749 "NPR Inventory Item Change Mgt."
{
    Access = Internal;

    /// <summary>Makes inventory sync return every item in the buffer again. Call it in the same transaction as the write that changes their output, before or after that write: change rows stay hidden from sync until the transaction commits.</summary>
    procedure MarkItemsChanged(var TempItemChange: Record "NPR Inventory Item Change" temporary)
    begin
        // The buffer is keyed by item no., so concurrent callers lock change rows in the same order.
        if TempItemChange.FindSet() then
            repeat
                Touch(TempItemChange."Item No.");
            until TempItemChange.Next() = 0;
    end;

    procedure AddItemNo(var TempItemChange: Record "NPR Inventory Item Change" temporary; ItemNo: Code[20])
    begin
        if ItemNo = '' then
            exit;
        TempItemChange.Init();
        TempItemChange."Item No." := ItemNo;
        if TempItemChange.Insert() then;
    end;

    /// <summary>Returns the SystemRowVersion of the item's change row, or 0 when the item has none.</summary>
    procedure GetChangeRowVersion(ItemNo: Code[20]): BigInteger
    var
        ItemChange: Record "NPR Inventory Item Change";
    begin
        ItemChange.ReadIsolation := IsolationLevel::ReadCommitted;
        if not ItemChange.Get(ItemNo) then
            exit(0);
        exit(ItemChange.SystemRowVersion);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"NPR Inventory Item Change", 'RIM')]
    local procedure Touch(ItemNo: Code[20])
    var
        ItemChange: Record "NPR Inventory Item Change";
    begin
        ItemChange.ReadIsolation := IsolationLevel::UpdLock;
        if not ItemChange.Get(ItemNo) then begin
            ItemChange.Init();
            ItemChange."Item No." := ItemNo;
            ItemChange."Change Count" := 1;
            if ItemChange.Insert() then
                exit;
            // Another session inserted the row after our Get. Lock it and update it.
            ItemChange.Get(ItemNo);
        end;
        ItemChange."Change Count" += 1;
        ItemChange.Modify();
    end;
}
