codeunit 6150973 "NPR NPRE Seat.Setup LastModSub"
{
    Access = Internal;

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
    local procedure SeatingLocationRefreshxRec(var Rec: Record "NPR NPRE Seating Location"; var xRec: Record "NPR NPRE Seating Location")
    begin
        if Rec.IsTemporary() then
            exit;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        xRec.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        if not xRec.Find() then
            Clear(xRec);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure SeatingLocationOnAfterModify(var Rec: Record "NPR NPRE Seating Location"; var xRec: Record "NPR NPRE Seating Location")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec."Restaurant Code");
        if Rec."Restaurant Code" <> xRec."Restaurant Code" then
            UpdateRestaurantSeatingLastModified(xRec."Restaurant Code");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", 'OnAfterRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnAfterRenameEvent, '', false, false)]
#endif
    local procedure SeatingLocationOnAfterRename(var Rec: Record "NPR NPRE Seating Location")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec."Restaurant Code");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating Location", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure SeatingLocationOnAfterDelete(var Rec: Record "NPR NPRE Seating Location")
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
    local procedure SeatingRefreshxRec(var Rec: Record "NPR NPRE Seating"; var xRec: Record "NPR NPRE Seating")
    begin
        if Rec.IsTemporary() then
            exit;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        xRec.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        if not xRec.Find() then
            Clear(xRec);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure SeatingOnAfterModify(var Rec: Record "NPR NPRE Seating"; var xRec: Record "NPR NPRE Seating")
    begin
        if Rec.IsTemporary() then
            exit;
        if not HasSeatingSetupChanged(Rec, xRec) then
            exit;
        UpdateRestaurantSeatingLastModified(Rec.GetSeatingRestaurant());
        if Rec."Seating Location" <> xRec."Seating Location" then
            UpdateRestaurantSeatingLastModified(xRec.GetSeatingRestaurant());
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", 'OnAfterRenameEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnAfterRenameEvent, '', false, false)]
#endif
    local procedure SeatingOnAfterRename(var Rec: Record "NPR NPRE Seating")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec.GetSeatingRestaurant());
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Seating", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure SeatingOnAfterDelete(var Rec: Record "NPR NPRE Seating")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateRestaurantSeatingLastModified(Rec.GetSeatingRestaurant());
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
