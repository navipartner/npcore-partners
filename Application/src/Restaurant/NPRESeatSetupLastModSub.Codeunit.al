codeunit 6150973 "NPR NPRE Seat.Setup LastModSub"
{
    Access = Internal;

    // The modify subscribers compare Rec with the row still on disk, not xRec: for a code-driven Modify xRec already carries
    // the values being written, and xRec is shared with every later subscriber. Modify, delete and rename stamp the
    // restaurant before the row is written and a move stamps both restaurants in code order, so those lock in one order;
    // inserts still stamp after the row.

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure SeatingLocationOnAfterInsert(var Rec: Record "NPR NPRE Seating Location")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec."Restaurant Code");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure SeatingLocationOnBeforeModify(var Rec: Record "NPR NPRE Seating Location")
    var
        CurrentSeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if Rec.IsTemporary() then
            exit;
        CurrentSeatingLocation.ReadIsolation := IsolationLevel::ReadCommitted;
        CurrentSeatingLocation.SetLoadFields("Restaurant Code");
        if not CurrentSeatingLocation.Get(Rec.Code) then
            Clear(CurrentSeatingLocation);
        UpdateRestaurantsSeatingLastModified(Rec."Restaurant Code", CurrentSeatingLocation."Restaurant Code");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", 'OnBeforeRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnBeforeRenameEvent, '', false, false)]
#endif
    local procedure SeatingLocationOnBeforeRename(var Rec: Record "NPR NPRE Seating Location")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec."Restaurant Code");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", 'OnBeforeDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnBeforeDeleteEvent, '', false, false)]
#endif
    local procedure SeatingLocationOnBeforeDelete(var Rec: Record "NPR NPRE Seating Location")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec."Restaurant Code");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure SeatingOnAfterInsert(var Rec: Record "NPR NPRE Seating")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec.GetSeatingRestaurant());
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure SeatingOnBeforeModify(var Rec: Record "NPR NPRE Seating")
    var
        CurrentSeating: Record "NPR NPRE Seating";
    begin
        if Rec.IsTemporary() then
            exit;
        CurrentSeating.ReadIsolation := IsolationLevel::ReadCommitted;
        if not CurrentSeating.Get(Rec.Code) then
            exit;
        if not HasSeatingSetupChanged(Rec, CurrentSeating) then
            exit;
        UpdateRestaurantsSeatingLastModified(Rec.GetSeatingRestaurant(), CurrentSeating.GetSeatingRestaurant());
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", 'OnBeforeRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnBeforeRenameEvent, '', false, false)]
#endif
    local procedure SeatingOnBeforeRename(var Rec: Record "NPR NPRE Seating")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec.GetSeatingRestaurant());
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", 'OnBeforeDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnBeforeDeleteEvent, '', false, false)]
#endif
    local procedure SeatingOnBeforeDelete(var Rec: Record "NPR NPRE Seating")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec.GetSeatingRestaurant());
    end;

    // The layout components are part of the seating setup as far as anything reading this timestamp is concerned: a
    // decoration moved on the floor plan changes what the POS restaurant view and the /restaurants endpoint hand out,
    // even though no seating row was touched. Tables are covered twice over, since saving one writes its seating as
    // well, and a redundant bump costs a reload nobody notices.

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure LocationLayoutOnAfterInsert(var Rec: Record "NPR NPRE Location Layout")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(GetLayoutRestaurant(Rec."Seating Location"));
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure LocationLayoutOnBeforeModify(var Rec: Record "NPR NPRE Location Layout")
    var
        CurrentLocationLayout: Record "NPR NPRE Location Layout";
    begin
        if Rec.IsTemporary() then
            exit;

        // Deliberately ungated, unlike the seating subscriber above which skips a modify that changed nothing worth
        // reporting. The change that matters most here is a component being dragged to a new position, and that lives
        // in the "Frontend Properties" blob rather than in any ordinary field. HasSeatingSetupChanged compares ordinary
        // fields and has never had a blob to contend with, since "NPR NPRE Seating" has none, so copying that gate here
        // would need a blob comparison it does not do. Until something demonstrates such a gate is both correct and
        // worth the reads, bump unconditionally: an extra reload costs a refresh nobody notices, while a missed one
        // leaves a rearranged floor plan on screen, which is the gap these subscribers exist to close.
        CurrentLocationLayout.ReadIsolation := IsolationLevel::ReadCommitted;
        CurrentLocationLayout.SetLoadFields("Seating Location");
        if not CurrentLocationLayout.Get(Rec.Code) then
            Clear(CurrentLocationLayout);
        UpdateRestaurantsSeatingLastModified(GetLayoutRestaurant(Rec."Seating Location"), GetLayoutRestaurant(CurrentLocationLayout."Seating Location"));
    end;

    // Stamps the restaurant a row joins and the one it leaves. The two are taken in code order so that two sessions moving
    // rows in opposite directions lock the restaurants in the same order; a blank or repeated code is stamped once.
    local procedure UpdateRestaurantsSeatingLastModified(RestaurantCode1: Code[20]; RestaurantCode2: Code[20])
    begin
        if RestaurantCode1 = RestaurantCode2 then begin
            UpdateRestaurantSeatingLastModified(RestaurantCode1);
            exit;
        end;
        if RestaurantCode1 < RestaurantCode2 then begin
            UpdateRestaurantSeatingLastModified(RestaurantCode1);
            UpdateRestaurantSeatingLastModified(RestaurantCode2);
        end else begin
            UpdateRestaurantSeatingLastModified(RestaurantCode2);
            UpdateRestaurantSeatingLastModified(RestaurantCode1);
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", 'OnBeforeRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", OnBeforeRenameEvent, '', false, false)]
#endif
    local procedure LocationLayoutOnBeforeRename(var Rec: Record "NPR NPRE Location Layout")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(GetLayoutRestaurant(Rec."Seating Location"));
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", 'OnBeforeDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Location Layout", OnBeforeDeleteEvent, '', false, false)]
#endif
    local procedure LocationLayoutOnBeforeDelete(var Rec: Record "NPR NPRE Location Layout")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(GetLayoutRestaurant(Rec."Seating Location"));
    end;

    local procedure GetLayoutRestaurant(SeatingLocationCode: Code[10]): Code[20]
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        SeatingLocation.SetLoadFields("Restaurant Code");
        if not SeatingLocation.Get(SeatingLocationCode) then
            exit('');
        exit(SeatingLocation."Restaurant Code");
    end;

    local procedure HasSeatingSetupChanged(Seating: Record "NPR NPRE Seating"; xSeating: Record "NPR NPRE Seating"): Boolean
    var
        RecRef: RecordRef;
        xRecRef: RecordRef;
        FieldRef: FieldRef;
        i: Integer;
    begin
        RecRef.GetTable(Seating);
        xRecRef.GetTable(xSeating);
        for i := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(i);
            if (FieldRef.Class = FieldClass::Normal) and not IsOperationalSeatingField(FieldRef.Number) then
                if Format(FieldRef.Value) <> Format(xRecRef.FieldIndex(i).Value) then
                    exit(true);
        end;
        exit(false);
    end;

    local procedure IsOperationalSeatingField(FieldNo: Integer): Boolean
    var
        Seating: Record "NPR NPRE Seating";
    begin
        exit(FieldNo in [
            Seating.FieldNo(Status),
            Seating.FieldNo("Current Waiter Pad Description")
        ]);
    end;

    local procedure UpdateRestaurantSeatingLastModified(RestaurantCode: Code[20])
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        if RestaurantCode = '' then
            exit;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        Restaurant.ReadIsolation := IsolationLevel::UpdLock;
#else
        Restaurant.LockTable();
#endif
        Restaurant.SetLoadFields("Seating Setup Last Modified At");
        if not Restaurant.Get(RestaurantCode) then
            exit;
        Restaurant."Seating Setup Last Modified At" := CurrentDateTime();
        Restaurant.Modify();
    end;
}
