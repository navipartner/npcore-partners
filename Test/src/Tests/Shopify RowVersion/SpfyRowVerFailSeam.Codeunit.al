codeunit 85455 "NPR Spfy RowVer Fail Seam"
{
    // Failure injection for the change-detection engine tests: while armed for an item, the real inventory
    // recalculation reached from the Item Ledger Entry dispatch fails, so a poison row can be driven through
    // the quarantine path over a real dispatch. The arm is sticky on purpose - the batched poll path attempts
    // the same row twice per cycle (batch attempt, then pinpoint re-walk) and both attempts must fail.
    //
    // Armed by SystemId rather than No.: the seam is session-lived and not rolled back by test isolation, so
    // a test that fails before disarming leaves it armed for whatever runs next in the same session. The
    // fixture lib's generated item codes can collide across test codeunits, so keying on No. risked matching
    // an unrelated item too; a SystemId never does. Every RowVer test codeunit's Initialize() also disarms
    // via SpfyRowVerTestLib.ResetState(), which is what actually clears an arm left by a failed test - see
    // that procedure for why the armed item itself (committed, not rolled back) needs that on top of this.
    Access = Internal;
    SingleInstance = true;

    var
        _ArmedItemId: Guid;
        InjectedInventoryErr: Label 'Injected inventory failure for %1. This is a programming bug.', Locked = true;

    procedure Arm(ItemId: Guid)
    begin
        _ArmedItemId := ItemId;
    end;

    procedure Disarm()
    begin
        Clear(_ArmedItemId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnCalculateInventoryLevel', '', false, false)]
    local procedure FailInventoryCalculation(ShopifyStoreCode: Code[20]; LocationFilter: Text; ItemNo: Code[20]; VariantCode: Code[10]; IncludeTransferOrders: Option No,Outbound,All; var StockQty: Decimal; var Handled: Boolean)
    var
        Item: Record Item;
    begin
        if IsNullGuid(_ArmedItemId) then
            exit;
        Item.SetLoadFields(SystemId);
        if not Item.Get(ItemNo) then
            exit;
        if Item.SystemId <> _ArmedItemId then
            exit;
        Error(InjectedInventoryErr, ItemNo);
    end;
}
