codeunit 6014626 "NPR Replication Counter Mgmt."
{
    var
        MissingKeyReplicationCounterErr: Label 'Secondary Key for table ''%1'' on field ''%2'' is missing. This is a programming error.';

    #region General
    procedure UpdateReplicationCounter(RecRef: RecordRef; ReplicationCounterFieldNo: Integer)
    var
        FRefReplicationCounter: FieldRef;
        NewestRepCounter: BigInteger;
        RecRefNewerRepCounter: RecordRef;
        FRefNewerRepCounter: FieldRef;
        ReplicationKeyIndex: Integer;
    begin
        if SetupDisabled() then
            exit;
        FRefReplicationCounter := RecRef.Field(ReplicationCounterFieldNo);
        FRefReplicationCounter.Value := RecRef.Field(0).Value; //SQL Timestamp

        // check if there is a newer replication counter. If yes, increase value so the current record has highest replication counter
        RecRefNewerRepCounter.Open(RecRef.Number);
        FRefNewerRepCounter := RecRefNewerRepCounter.Field(ReplicationCounterFieldNo);
        FRefNewerRepCounter.SetFilter('>=%1', FRefReplicationCounter.Value);
        IF NOT RecRefNewerRepCounter.IsEmpty() then begin
            ReplicationKeyIndex := GetReplicationCounterKeyIndex(RecRefNewerRepCounter, FRefNewerRepCounter);
            IF ReplicationKeyIndex <= 1 then
                Error(MissingKeyReplicationCounterErr, RecRefNewerRepCounter.Name, FRefNewerRepCounter.Name);

            RecRefNewerRepCounter.Reset();
            RecRefNewerRepCounter.CurrentKeyIndex(ReplicationKeyIndex); //Set Replication Counter Key --> Findlast always gets the highest Replication Counter!
            RecRefNewerRepCounter.FindLast();
            NewestRepCounter := RecRefNewerRepCounter.Field(ReplicationCounterFieldNo).Value;
            FRefReplicationCounter.Value := NewestRepCounter + 1;
        end;
    end;

    local procedure GetReplicationCounterKeyIndex(RecRef: RecordRef; RepCounterFieldRef: FieldRef): Integer
    var
        i: Integer;
        KRef: KeyRef;
        FRef: FieldRef;
    begin
        For i := 1 to RecRef.KeyCount do begin
            KRef := RecRef.KeyIndex(i);
            IF KRef.Active then
                IF KRef.FieldCount = 1 then begin //we are looking for the key with only one field --> Replication Counter
                    FRef := KRef.FieldIndex(1);
                    IF FRef.Name = RepCounterFieldRef.Name then
                        exit(i);
                end;
        end;
    end;

    local procedure SetupDisabled(): Boolean
    var
        ReplicationServiceSetup: Record "NPR Replication Service Setup";
    begin
        ReplicationServiceSetup.SetRange(Enabled, true);
        exit(ReplicationServiceSetup.IsEmpty());
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. G/L Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertAuxGLEntry(var Rec: Record "NPR Aux. G/L Entry"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. G/L Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyAuxGLEntry(var Rec: Record "NPR Aux. G/L Entry"; var xRec: Record "NPR Aux. G/L Entry"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. G/L Entry", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameAuxGLEntry(var Rec: Record "NPR Aux. G/L Entry"; var xRec: Record "NPR Aux. G/L Entry"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertCustBankAcc(var Rec: Record "Customer Bank Account"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustomerBankAcc(var Rec: Record "Customer Bank Account"; var xRec: Record "Customer Bank Account"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameCustomerBankAcc(var Rec: Record "Customer Bank Account"; var xRec: Record "Customer Bank Account"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertSalespersonPurchaser(var Rec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifySalespersonPurchaser(var Rec: Record "Salesperson/Purchaser"; var xRec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameSalespersonPurchaser(var Rec: Record "Salesperson/Purchaser"; var xRec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Price Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertCustPriceGroup(var Rec: Record "Customer Price Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Price Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustPriceGroup(var Rec: Record "Customer Price Group"; var xRec: Record "Customer Price Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Price Group", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameCustPriceGroup(var Rec: Record "Customer Price Group"; var xRec: Record "Customer Price Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Discount Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertCustDiscountGroup(var Rec: Record "Customer Discount Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Discount Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustDiscountGroup(var Rec: Record "Customer Discount Group"; var xRec: Record "Customer Discount Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Discount Group", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameCustDiscountGroup(var Rec: Record "Customer Discount Group"; var xRec: Record "Customer Discount Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertCustPostingGroup(var Rec: Record "Customer Posting Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustPostGroup(var Rec: Record "Customer Posting Group"; var xRec: Record "Customer Posting Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameCustPostGroup(var Rec: Record "Customer Posting Group"; var xRec: Record "Customer Posting Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertLocation(var Rec: Record Location; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyLocation(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameLocation(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertShipMethod(var Rec: Record "Shipment Method"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyShipMethod(var Rec: Record "Shipment Method"; var xRec: Record "Shipment Method"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameShipMethod(var Rec: Record "Shipment Method"; var xRec: Record "Shipment Method"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertPaymentTerms(var Rec: Record "Payment Terms"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPaymentTerms(var Rec: Record "Payment Terms"; var xRec: Record "Payment Terms"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenamePaymentTerms(var Rec: Record "Payment Terms"; var xRec: Record "Payment Terms"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertPayMethod(var Rec: Record "Payment Method"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPayMethod(var Rec: Record "Payment Method"; var xRec: Record "Payment Method"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenamePayMethod(var Rec: Record "Payment Method"; var xRec: Record "Payment Method"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertCurrency(var Rec: Record Currency; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCurrency(var Rec: Record Currency; var xRec: Record Currency; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameCurrency(var Rec: Record Currency; var xRec: Record Currency; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertVend(var Rec: Record "Vendor"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVend(var Rec: Record "Vendor"; var xRec: Record "Vendor"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameVendor(var Rec: Record "Vendor"; var xRec: Record "Vendor"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertVendBankAcc(var Rec: Record "Vendor Bank Account"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVendBankAcc(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameVendorBankAcc(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterInsertVendPostGr(var Rec: Record "Vendor Posting Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVendPostGr(var Rec: Record "Vendor Posting Group"; var xRec: Record "Vendor Posting Group"; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnAfterRenameVendorPostGr(var Rec: Record "Vendor Posting Group"; var xRec: Record "Vendor Posting Group"; RunTrigger: Boolean)
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