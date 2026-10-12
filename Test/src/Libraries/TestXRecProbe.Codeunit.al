codeunit 85519 "NPR Test xRec Probe"
{
    // Manually bound observer of modify events on the tables whose NP Retail subscribers once replaced xRec. For a
    // code-driven Modify the platform hands subscribers an xRec that already carries the values being written (it only
    // knows a true before-image for page edits), and Microsoft's workflow rules rely on that. Per table the probe records
    // whether the field under test still reads the same in xRec and Rec, which is false as soon as an earlier subscriber
    // replaces xRec with the row from the database.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _ModifySeen: Dictionary of [Integer, Boolean];
        _XRecCarriesRecValue: Dictionary of [Integer, Boolean];
        _ItemBeforeImageUnitPrice: Decimal;

    procedure ModifySeen(TableNo: Integer): Boolean
    begin
        exit(_ModifySeen.ContainsKey(TableNo));
    end;

    procedure XRecCarriesRecValue(TableNo: Integer): Boolean
    var
        Carries: Boolean;
    begin
        if not _XRecCarriesRecValue.Get(TableNo, Carries) then
            exit(false);
        exit(Carries);
    end;

    local procedure Record(TableNo: Integer; Carries: Boolean)
    begin
        _ModifySeen.Set(TableNo, true);
        _XRecCarriesRecValue.Set(TableNo, Carries);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterModifyEvent, '', false, false)]
    local procedure RecordCustomerModify(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if not Rec.IsTemporary() then
            Record(Database::Customer, xRec.Name = Rec.Name);
    end;

    /// <summary>The unit price the Item before-image helper handed out during the last observed item modify.</summary>
    procedure ItemBeforeImageUnitPrice(): Decimal
    begin
        exit(_ItemBeforeImageUnitPrice);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterModifyEvent, '', false, false)]
    local procedure RecordItemModify(var Rec: Record Item; var xRec: Record Item)
    var
        BeforeImage: Record Item;
        ItemBeforeImage: Codeunit "NPR Item Before Image";
    begin
        if Rec.IsTemporary() then
            exit;
        Record(Database::Item, xRec."Item Category Code" = Rec."Item Category Code");
        ItemBeforeImage.GetBeforeImage(Rec, xRec, BeforeImage);
        _ItemBeforeImageUnitPrice := BeforeImage."Unit Price";
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnAfterModifyEvent, '', false, false)]
    local procedure RecordSeatingLocationModify(var Rec: Record "NPR NPRE Seating Location"; var xRec: Record "NPR NPRE Seating Location")
    begin
        if not Rec.IsTemporary() then
            Record(Database::"NPR NPRE Seating Location", xRec."Restaurant Code" = Rec."Restaurant Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnAfterModifyEvent, '', false, false)]
    local procedure RecordSeatingModify(var Rec: Record "NPR NPRE Seating"; var xRec: Record "NPR NPRE Seating")
    begin
        if not Rec.IsTemporary() then
            Record(Database::"NPR NPRE Seating", xRec."Seating Location" = Rec."Seating Location");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", OnAfterModifyEvent, '', false, false)]
    local procedure RecordLocationLayoutModify(var Rec: Record "NPR NPRE Location Layout"; var xRec: Record "NPR NPRE Location Layout")
    begin
        if not Rec.IsTemporary() then
            Record(Database::"NPR NPRE Location Layout", xRec."Seating Location" = Rec."Seating Location");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Layout", OnAfterModifyEvent, '', false, false)]
    local procedure RecordPOSLayoutModify(var Rec: Record "NPR POS Layout"; var xRec: Record "NPR POS Layout")
    begin
        if not Rec.IsTemporary() then
            Record(Database::"NPR POS Layout", xRec.Description = Rec.Description);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Subscr. Payment Request", OnAfterModifyEvent, '', false, false)]
    local procedure RecordSubscrPaymentRequestModify(var Rec: Record "NPR MM Subscr. Payment Request"; var xRec: Record "NPR MM Subscr. Payment Request")
    begin
        if not Rec.IsTemporary() then
            Record(Database::"NPR MM Subscr. Payment Request", xRec.Status = Rec.Status);
    end;
}
