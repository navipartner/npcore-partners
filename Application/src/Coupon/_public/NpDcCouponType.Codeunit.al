codeunit 6248503 "NPR NpDc Coupon Type"
{
    Access = Public;

    var
        _CouponType: Record "NPR NpDc Coupon Type";

    procedure SetView(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer")
    begin
        _CouponType.Reset();
        _CouponType.SetView(CouponTypeBuffer.GetView());
    end;

    procedure GetBySystemId(SystemId: Guid; var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer") Found: Boolean
    begin
        CouponTypeBuffer.Reset();
        CouponTypeBuffer.DeleteAll();

        if not _CouponType.GetBySystemId(SystemId) then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, _CouponType);

        Found := true;
    end;

    procedure FindSet(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer") Found: Boolean
    begin
        CouponTypeBuffer.Reset();
        CouponTypeBuffer.DeleteAll();

        if not _CouponType.FindSet() then
            exit;

        repeat
            PopulateBufferFromRec(CouponTypeBuffer, _CouponType);
        until _CouponType.Next() = 0;
        CouponTypeBuffer.FindFirst();

        Found := true;
    end;

    procedure FindFirst(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer") Found: Boolean
    begin
        CouponTypeBuffer.Reset();
        CouponTypeBuffer.DeleteAll();

        if not _CouponType.FindFirst() then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, _CouponType);
        Found := true;
    end;

    procedure FindLast(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer") Found: Boolean
    begin
        CouponTypeBuffer.Reset();
        CouponTypeBuffer.DeleteAll();

        if not _CouponType.FindLast() then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, _CouponType);

        Found := true;
    end;

    procedure Insert(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; ExecuteTrigger: Boolean)
    begin
        _CouponType.Init();
        _CouponType.TransferFields(CouponTypeBuffer);
        _CouponType.Insert(ExecuteTrigger);
    end;

    procedure Modify(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; ExecuteTrigger: Boolean)
    begin
        _CouponType.GetBySystemId(CouponTypeBuffer.SystemId);
        _CouponType.TransferFields(CouponTypeBuffer);
        _CouponType.Modify(ExecuteTrigger);
    end;

    procedure Delete(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; ExecuteTrigger: Boolean)
    begin
        _CouponType.GetBySystemId(CouponTypeBuffer.SystemId);
        _CouponType.Delete(ExecuteTrigger);
    end;

    procedure DeleteAll(ExecuteTrigger: Boolean)
    begin
        _CouponType.DeleteAll(ExecuteTrigger);
    end;

    local procedure PopulateBufferFromRec(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; CouponType: Record "NPR NpDc Coupon Type")
    begin
        CouponTypeBuffer.Init();
        CouponTypeBuffer.TransferFields(CouponType);
        CouponTypeBuffer.SystemId := CouponType.SystemId;
        CouponTypeBuffer.Insert(false, false);
    end;

    local procedure PopulateRecFromBuffer(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; var CouponType: Record "NPR NpDc Coupon Type")
    begin
        CouponType.TransferFields(CouponTypeBuffer, false);
    end;

    local procedure OnBeforeInsertRec(var CouponType: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not FeatureFlagsManagement.IsEnabled('couponTypeFacadeEvents') then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, CouponType);
        OnBeforeInsertRecEvent(CouponTypeBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponTypeBuffer, CouponType);
    end;

    local procedure OnAfterInsertRec(var CouponType: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not FeatureFlagsManagement.IsEnabled('couponTypeFacadeEvents') then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, CouponType);
        OnAfterInsertRecEvent(CouponTypeBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponTypeBuffer, CouponType);
    end;

    local procedure OnBeforeModifyRec(var CouponType: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not FeatureFlagsManagement.IsEnabled('couponTypeFacadeEvents') then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, CouponType);
        OnBeforeModifyRecEvent(CouponTypeBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponTypeBuffer, CouponType);
    end;

    local procedure OnAfterModifyRec(var CouponType: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not FeatureFlagsManagement.IsEnabled('couponTypeFacadeEvents') then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, CouponType);
        OnAfterModifyRecEvent(CouponTypeBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponTypeBuffer, CouponType);
    end;

    local procedure OnBeforeDeleteRec(var CouponType: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not FeatureFlagsManagement.IsEnabled('couponTypeFacadeEvents') then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, CouponType);
        OnBeforeDeleteRecEvent(CouponTypeBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponTypeBuffer, CouponType);
    end;

    local procedure OnAfterDeleteRec(var CouponType: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not FeatureFlagsManagement.IsEnabled('couponTypeFacadeEvents') then
            exit;

        PopulateBufferFromRec(CouponTypeBuffer, CouponType);
        OnAfterDeleteRecEvent(CouponTypeBuffer, RunTrigger);
        PopulateRecFromBuffer(CouponTypeBuffer, CouponType);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnBeforeInsertEvent, '', false, false)]
#endif
    local procedure OnBeforeInsertEvent(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    begin
        OnBeforeInsertRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure OnAfterInsertEvent(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    begin
        OnAfterInsertRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure OnBeforeModifyEvent(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    begin
        OnBeforeModifyRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure OnAfterModifyEvent(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    begin
        OnAfterModifyRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnBeforeDeleteEvent, '', false, false)]
#endif
    local procedure OnBeforeDeleteEvent(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    begin
        OnBeforeDeleteRec(Rec, RunTrigger);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure OnAfterDeleteEvent(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    begin
        OnAfterDeleteRec(Rec, RunTrigger);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeleteRecEvent(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterDeleteRecEvent(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeInsertRecEvent(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertRecEvent(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeModifyRecEvent(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; RunTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterModifyRecEvent(var CouponTypeBuffer: Record "NPR NpDc Coupon Type Buffer"; RunTrigger: Boolean)
    begin
    end;
}