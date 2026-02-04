codeunit 6150972 "NPR NpDc ArchCouponEntry"
{
    Access = Public;

    var
        _ArchCouponEntry: Record "NPR NpDc Arch.Coupon Entry";

    procedure SetView(var ArchCouponEntryBuff: Record "NPR NpDc ArchCouponEntryBuff")
    begin
        _ArchCouponEntry.Reset();
        _ArchCouponEntry.SetView(ArchCouponEntryBuff.GetView());
    end;

    procedure GetBySystemId(SystemId: Guid; var ArchCouponEntryBuff: Record "NPR NpDc ArchCouponEntryBuff") Found: Boolean
    begin
        ArchCouponEntryBuff.Reset();
        ArchCouponEntryBuff.DeleteAll();

        if not _ArchCouponEntry.GetBySystemId(SystemId) then
            exit;

        PopulateBufferFromRec(ArchCouponEntryBuff, _ArchCouponEntry);

        Found := true;
    end;

    procedure FindSet(var ArchCouponEntryBuff: Record "NPR NpDc ArchCouponEntryBuff") Found: Boolean
    begin
        ArchCouponEntryBuff.Reset();
        ArchCouponEntryBuff.DeleteAll();

        if not _ArchCouponEntry.FindSet() then
            exit;

        repeat
            PopulateBufferFromRec(ArchCouponEntryBuff, _ArchCouponEntry);
        until _ArchCouponEntry.Next() = 0;
        ArchCouponEntryBuff.FindFirst();

        Found := true;
    end;

    procedure FindFirst(var ArchCouponEntryBuff: Record "NPR NpDc ArchCouponEntryBuff") Found: Boolean
    begin
        ArchCouponEntryBuff.Reset();
        ArchCouponEntryBuff.DeleteAll();

        if not _ArchCouponEntry.FindFirst() then
            exit;

        PopulateBufferFromRec(ArchCouponEntryBuff, _ArchCouponEntry);
        Found := true;
    end;

    procedure FindLast(var ArchCouponEntryBuff: Record "NPR NpDc ArchCouponEntryBuff") Found: Boolean
    begin
        ArchCouponEntryBuff.Reset();
        ArchCouponEntryBuff.DeleteAll();

        if not _ArchCouponEntry.FindLast() then
            exit;

        PopulateBufferFromRec(ArchCouponEntryBuff, _ArchCouponEntry);

        Found := true;
    end;

    local procedure PopulateBufferFromRec(var ArchCouponEntryBuff: Record "NPR NpDc ArchCouponEntryBuff"; ArchCouponEntry: Record "NPR NpDc Arch.Coupon Entry")
    begin
        ArchCouponEntryBuff.Init();
        ArchCouponEntryBuff.TransferFields(ArchCouponEntry);
        ArchCouponEntryBuff.SystemId := ArchCouponEntry.SystemId;
        ArchCouponEntryBuff.Insert(false, false);
    end;
}
