codeunit 85527 "NPR Test Nested Item Modify"
{
    // Manually bound after-modify subscriber that modifies the same item once more, as some customer extensions do, and
    // then asks the before-image helper for the outer modify's image, so the answer does not depend on subscriber order.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _ThroughSameRecord: Boolean;
        _NestedModifyDone: Boolean;
        _OuterImageUnitPrice: Decimal;

    procedure SetThroughSameRecord(ThroughSameRecord: Boolean)
    begin
        _ThroughSameRecord := ThroughSameRecord;
    end;

    procedure NestedModifyDone(): Boolean
    begin
        exit(_NestedModifyDone);
    end;

    procedure OuterImageUnitPrice(): Decimal
    begin
        exit(_OuterImageUnitPrice);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterModifyEvent, '', false, false)]
    local procedure ModifyTheSameItemAgain(var Rec: Record Item; var xRec: Record Item)
    var
        OtherItem: Record Item;
        BeforeImage: Record Item;
        ItemBeforeImage: Codeunit "NPR Item Before Image";
    begin
        if Rec.IsTemporary() then
            exit;
        if _NestedModifyDone then
            exit;
        _NestedModifyDone := true;
        if _ThroughSameRecord then begin
            Rec.Description := 'Changed by a nested modify';
            Rec.Modify(true);
        end else begin
            OtherItem.Get(Rec."No.");
            OtherItem.Description := 'Changed by a nested modify';
            OtherItem.Modify(true);
        end;
        ItemBeforeImage.GetBeforeImage(Rec, xRec, BeforeImage);
        _OuterImageUnitPrice := BeforeImage."Unit Price";
    end;
}
