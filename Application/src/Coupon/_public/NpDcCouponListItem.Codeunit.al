codeunit 6248505 "NPR NpDc Coupon List Item"
{
    Access = Public;

    var
        _CouponListItem: Record "NPR NpDc Coupon List Item";

    procedure SetView(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf")
    begin
        _CouponListItem.Reset();
        _CouponListItem.SetView(CouponListItemBuffer.GetView());
    end;

    procedure GetBySystemId(SystemId: Guid; var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf") Found: Boolean
    begin
        CouponListItemBuffer.Reset();
        CouponListItemBuffer.DeleteAll();

        if not _CouponListItem.GetBySystemId(SystemId) then
            exit;

        PopulateBufferFromRec(CouponListItemBuffer, _CouponListItem);

        Found := true;
    end;

    procedure FindSet(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf") Found: Boolean
    begin
        CouponListItemBuffer.Reset();
        CouponListItemBuffer.DeleteAll();

        if not _CouponListItem.FindSet() then
            exit;

        repeat
            PopulateBufferFromRec(CouponListItemBuffer, _CouponListItem);
        until _CouponListItem.Next() = 0;
        CouponListItemBuffer.FindFirst();

        Found := true;
    end;

    procedure FindFirst(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf") Found: Boolean
    begin
        CouponListItemBuffer.Reset();
        CouponListItemBuffer.DeleteAll();

        if not _CouponListItem.FindFirst() then
            exit;

        PopulateBufferFromRec(CouponListItemBuffer, _CouponListItem);
        Found := true;
    end;

    procedure FindLast(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf") Found: Boolean
    begin
        CouponListItemBuffer.Reset();
        CouponListItemBuffer.DeleteAll();

        if not _CouponListItem.FindLast() then
            exit;

        PopulateBufferFromRec(CouponListItemBuffer, _CouponListItem);

        Found := true;
    end;

    procedure Insert(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; ExecuteTrigger: Boolean)
    begin
        _CouponListItem.Init();
        _CouponListItem.TransferFields(CouponListItemBuffer);
        _CouponListItem.Insert(ExecuteTrigger);
    end;

    procedure Modify(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; ExecuteTrigger: Boolean)
    begin
        _CouponListItem.GetBySystemId(CouponListItemBuffer.SystemId);
        _CouponListItem.TransferFields(CouponListItemBuffer);
        _CouponListItem.Modify(ExecuteTrigger);
    end;

    procedure Delete(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; ExecuteTrigger: Boolean)
    begin
        _CouponListItem.GetBySystemId(CouponListItemBuffer.SystemId);
        _CouponListItem.Delete(ExecuteTrigger);
    end;

    procedure DeleteAll(ExecuteTrigger: Boolean)
    begin
        _CouponListItem.DeleteAll(ExecuteTrigger);
    end;

    local procedure PopulateBufferFromRec(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; CouponListItem: Record "NPR NpDc Coupon List Item")
    begin
        CouponListItemBuffer.Init();
        CouponListItemBuffer.TransferFields(CouponListItem);
        CouponListItemBuffer.SystemId := CouponListItem.SystemId;
        CouponListItemBuffer.Insert(false, false);
    end;

    local procedure PopulateRecFromBuffer(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; var CouponListItem: Record "NPR NpDc Coupon List Item")
    begin
        CouponListItem.TransferFields(CouponListItemBuffer, false);
    end;

    local procedure OnBeforeInsertRec(var CouponListItem: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    var
        CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf";
    begin
        PopulateBufferFromRec(CouponListItemBuffer, CouponListItem);
        OnBeforeInsertRecEvent(CouponListItemBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponListItemBuffer, CouponListItem);
    end;

    local procedure OnAfterInsertRec(var CouponListItem: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    var
        CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf";
    begin
        PopulateBufferFromRec(CouponListItemBuffer, CouponListItem);
        OnAfterInsertRecEvent(CouponListItemBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponListItemBuffer, CouponListItem);
    end;

    local procedure OnBeforeModifyRec(var CouponListItem: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    var
        CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf";
    begin
        PopulateBufferFromRec(CouponListItemBuffer, CouponListItem);
        OnBeforeModifyRecEvent(CouponListItemBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponListItemBuffer, CouponListItem);
    end;

    local procedure OnAfterModifyRec(var CouponListItem: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    var
        CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf";
    begin
        PopulateBufferFromRec(CouponListItemBuffer, CouponListItem);
        OnAfterModifyRecEvent(CouponListItemBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponListItemBuffer, CouponListItem);
    end;

    local procedure OnBeforeDeleteRec(var CouponListItem: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    var
        CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf";
    begin
        PopulateBufferFromRec(CouponListItemBuffer, CouponListItem);
        OnBeforeDeleteRecEvent(CouponListItemBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponListItemBuffer, CouponListItem);
    end;

    local procedure OnAfterDeleteRec(var CouponListItem: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    var
        CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf";
    begin
        PopulateBufferFromRec(CouponListItemBuffer, CouponListItem);
        OnAfterDeleteRecEvent(CouponListItemBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponListItemBuffer, CouponListItem);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", 'OnBeforeInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", OnBeforeInsertEvent, '', false, false)]
#endif
    local procedure OnBeforeInsertEvent(var Rec: Record "NPR NpDc Coupon List Item" temporary; RunTrigger: Boolean)
    begin
        OnBeforeInsertRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure OnAfterInsertEvent(var Rec: Record "NPR NpDc Coupon List Item" temporary; RunTrigger: Boolean)
    begin
        OnAfterInsertRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure OnBeforeModifyEvent(var Rec: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    begin
        OnBeforeModifyRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure OnAfterModifyEvent(var Rec: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    begin
        OnAfterModifyRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", 'OnBeforeDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", OnBeforeDeleteEvent, '', false, false)]
#endif
    local procedure OnBeforeDeleteEvent(var Rec: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    begin
        OnBeforeDeleteRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon List Item", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure OnAfterDeleteEvent(var Rec: Record "NPR NpDc Coupon List Item"; RunTrigger: Boolean)
    begin
        OnAfterDeleteRec(Rec, RunTrigger);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeleteRecEvent(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterDeleteRecEvent(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeInsertRecEvent(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertRecEvent(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeModifyRecEvent(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterModifyRecEvent(var CouponListItemBuffer: Record "NPR NpDc Coupon List Item Buf"; RunTrigger: Boolean)
    begin
    end;
}