codeunit 6151313 "NPR Item Before Image"
{
    // Keeps the on-disk Item from OnBeforeModifyEvent for after-modify readers without touching xRec. Images are keyed
    // by item and xRec, so a reader gets its own modify's image unless a nested modify writes exactly what the outer one wrote.
    Access = Internal;
    SingleInstance = true;

    var
        _Images: array[20] of Record Item;
        _ImageKeys: array[20] of Text;
        _ImageCount: Integer;
        _LastSlot: Integer;

    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeModifyEvent, '', false, false)]
    local procedure CaptureBeforeImage(var Rec: Record Item; var xRec: Record Item)
    var
        CurrentItem: Record Item;
    begin
        if Rec.IsTemporary() then
            exit;
        CurrentItem.ReadIsolation := IsolationLevel::ReadCommitted;
        if CurrentItem.Get(Rec."No.") then
            Remember(CurrentItem, xRec);
    end;

    internal procedure Remember(BeforeImage: Record Item; xRec: Record Item)
    begin
        // A ring: images are never taken back, so the oldest, from modifies long over, are overwritten.
        _LastSlot := _LastSlot mod ArrayLen(_Images) + 1;
        _Images[_LastSlot] := BeforeImage;
        _ImageKeys[_LastSlot] := Format(xRec);
        if _ImageCount < ArrayLen(_Images) then
            _ImageCount += 1;
    end;

    /// <summary>Hands out the on-disk row from the start of the Modify that raised Rec and xRec, or xRec when no image matches.</summary>
    internal procedure GetBeforeImage(Rec: Record Item; xRec: Record Item; var BeforeImage: Record Item)
    var
        ImageKey: Text;
        Slot: Integer;
        i: Integer;
    begin
        ImageKey := Format(xRec);
        Slot := _LastSlot;
        for i := 1 to _ImageCount do begin
            if (_Images[Slot]."No." = Rec."No.") and (_ImageKeys[Slot] = ImageKey) then begin
                BeforeImage := _Images[Slot];
                exit;
            end;
            Slot -= 1;
            if Slot = 0 then
                Slot := ArrayLen(_Images);
        end;
        BeforeImage := xRec;
    end;
}
