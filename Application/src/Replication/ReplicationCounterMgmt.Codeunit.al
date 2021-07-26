codeunit 6014626 "NPR Replication Counter Mgmt."
{
    #region General
    procedure UpdateReplicationCounter(RecRef: RecordRef; ReplicationCounterFieldNo: Integer)
    var
        FRefSQLTimeStamp: FieldRef;
        FRefReplicationCounter: FieldRef;
    begin
        FRefSQLTimeStamp := RecRef.Field(0); //SQL Timestamp
        FRefReplicationCounter := RecRef.Field(ReplicationCounterFieldNo);
        FRefReplicationCounter.Value := FRefSQLTimeStamp.Value;
    end;
    #endregion

    #region CustomTables
    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertVarietyGroup(var Rec: Record "NPR Variety Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVarietyGroup(var Rec: Record "NPR Variety Group"; var xRec: Record "NPR Variety Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Group", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameVarietyGroup(var Rec: Record "NPR Variety Group"; var xRec: Record "NPR Variety Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertVariety(var Rec: Record "NPR Variety"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVariety(var Rec: Record "NPR Variety"; var xRec: Record "NPR Variety"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameVariety(var Rec: Record "NPR Variety"; var xRec: Record "NPR Variety"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Table", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertVarietyTable(var Rec: Record "NPR Variety Table"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Table", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVarietyTable(var Rec: Record "NPR Variety Table"; var xRec: Record "NPR Variety Table"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Table", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameVarietyTable(var Rec: Record "NPR Variety Table"; var xRec: Record "NPR Variety Table"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Value", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertVarietyValue(var Rec: Record "NPR Variety Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Value", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVarietyValue(var Rec: Record "NPR Variety Value"; var xRec: Record "NPR Variety Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Value", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameVarietyValue(var Rec: Record "NPR Variety Value"; var xRec: Record "NPR Variety Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertAttribute(var Rec: Record "NPR Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyAttribute(var Rec: Record "NPR Attribute"; var xRec: Record "NPR Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameAttribute(var Rec: Record "NPR Attribute"; var xRec: Record "NPR Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute ID", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertAttributeID(var Rec: Record "NPR Attribute ID"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute ID", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyAttributeID(var Rec: Record "NPR Attribute ID"; var xRec: Record "NPR Attribute ID"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute ID", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameAttributeID(var Rec: Record "NPR Attribute ID"; var xRec: Record "NPR Attribute ID"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertPeriodDisc(var Rec: Record "NPR Period Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPeriodDisc(var Rec: Record "NPR Period Discount"; var xRec: Record "NPR Period Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenamePeriodDisc(var Rec: Record "NPR Period Discount"; var xRec: Record "NPR Period Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertPeriodDiscLine(var Rec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPeriodDiscLine(var Rec: Record "NPR Period Discount Line"; var xRec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenamePeriodDiscLine(var Rec: Record "NPR Period Discount Line"; var xRec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. Item Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertAuxILE(var Rec: Record "NPR Aux. Item Ledger Entry"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. Item Ledger Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyAuxILE(var Rec: Record "NPR Aux. Item Ledger Entry"; var xRec: Record "NPR Aux. Item Ledger Entry"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. Item Ledger Entry", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameAuxILE(var Rec: Record "NPR Aux. Item Ledger Entry"; var xRec: Record "NPR Aux. Item Ledger Entry"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Disc. Time Interv.", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertMixedDiscTimeInterv(var Rec: Record "NPR Mixed Disc. Time Interv."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Disc. Time Interv.", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDiscTimeInterv(var Rec: Record "NPR Mixed Disc. Time Interv."; var xRec: Record "NPR Mixed Disc. Time Interv."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Disc. Time Interv.", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameMixedDiscTimeInterv(var Rec: Record "NPR Mixed Disc. Time Interv."; var xRec: Record "NPR Mixed Disc. Time Interv."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Level", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertMixedDiscLevels(var Rec: Record "NPR Mixed Discount Level"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Level", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDiscLevels(var Rec: Record "NPR Mixed Discount Level"; var xRec: Record "NPR Mixed Discount Level"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Level", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameMixedDiscLevels(var Rec: Record "NPR Mixed Discount Level"; var xRec: Record "NPR Mixed Discount Level"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertMixedDiscLine(var Rec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDiscLine(var Rec: Record "NPR Mixed Discount Line"; var xRec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameMixedDiscLine(var Rec: Record "NPR Mixed Discount Line"; var xRec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertMixedDisc(var Rec: Record "NPR Mixed Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDisc(var Rec: Record "NPR Mixed Discount"; var xRec: Record "NPR Mixed Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameMixedDisc(var Rec: Record "NPR Mixed Discount"; var xRec: Record "NPR Mixed Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertNpDcCouponTypes(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyNpDcCouponTypes(var Rec: Record "NPR NpDc Coupon Type"; var xRec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameNpDcCouponTypes(var Rec: Record "NPR NpDc Coupon Type"; var xRec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    #endregion

    #region TableExtensions
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertCust(var Rec: Record "Customer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustomer(var Rec: Record "Customer"; var xRec: Record "Customer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameCustomer(var Rec: Record "Customer"; var xRec: Record "Customer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertItem(var Rec: Record "Item"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItem(var Rec: Record "Item"; var xRec: Record "Item"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameItem(var Rec: Record "Item"; var xRec: Record "Item"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertItemCat(var Rec: Record "Item Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemCat(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameItemCat(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertItemVar(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemVar(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameItemVar(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertDefaultDim(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyDefaultDim(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameDefaultDim(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertDim(var Rec: Record "Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyDim(var Rec: Record "Dimension"; var xRec: Record "Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameDim(var Rec: Record "Dimension"; var xRec: Record "Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertDimValue(var Rec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyDimValue(var Rec: Record "Dimension Value"; var xRec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameDimValue(var Rec: Record "Dimension Value"; var xRec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertItemRef(var Rec: Record "Item Reference"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemRef(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameItemRef(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit Of Measure", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertItemUOM(var Rec: Record "Item Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit Of Measure", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemUOM(var Rec: Record "Item Unit Of Measure"; var xRec: Record "Item Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit Of Measure", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameItemUOM(var Rec: Record "Item Unit Of Measure"; var xRec: Record "Item Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Purchase Price", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertPurchPrice(var Rec: Record "Purchase Price"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Price", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPurchPrice(var Rec: Record "Purchase Price"; var xRec: Record "Purchase Price"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Price", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenamePurchPrice(var Rec: Record "Purchase Price"; var xRec: Record "Purchase Price"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;
#pragma warning restore

    [EventSubscriber(ObjectType::Table, Database::"Unit Of Measure", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertUOM(var Rec: Record "Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit Of Measure", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyUOM(var Rec: Record "Unit Of Measure"; var xRec: Record "Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit Of Measure", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameUOM(var Rec: Record "Unit Of Measure"; var xRec: Record "Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertPriceListHeader(var Rec: Record "Price List Header"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPriceListHeader(var Rec: Record "Price List Header"; var xRec: Record "Price List Header"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Header", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenamePriceListHeader(var Rec: Record "Price List Header"; var xRec: Record "Price List Header"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertPriceListLine(var Rec: Record "Price List Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPriceListLine(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenamePriceListLine(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF Rec.IsTemporary() then
            exit;

        IF DataTypeMgmt.GetRecordRef(Rec, RecRef) THEN begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
            Rec.Modify(false);
        end;
    end;

    #endregion

}