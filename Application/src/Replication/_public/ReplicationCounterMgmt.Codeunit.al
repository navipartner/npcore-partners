﻿codeunit 6014626 "NPR Replication Counter Mgmt."
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Replication Counter is replaced by SystemRowVersion';

    procedure UpdateReplicationCounter(RecRef: RecordRef; ReplicationCounterFieldNo: Integer)
    var
#IF (BC17 or BC18 or BC19 or BC20)
        FRefReplicationCounter: FieldRef;
#ENDIF
    begin
#IF (BC17 or BC18 or BC19 or BC20)
        if not CheckReplicationCounterUpdateIsEnabled() then
            exit;

        if not NumberSequence.Exists('NPRReplicationModule_' + Format(RecRef.Number), true) then
            NumberSequence.Insert('NPRReplicationModule_' + Format(RecRef.Number), 1, 1, true);

        FRefReplicationCounter := RecRef.Field(ReplicationCounterFieldNo);
        FRefReplicationCounter.Value := NumberSequence.Next('NPRReplicationModule_' + Format(RecRef.Number), true);
#ENDIF
    end;

#IF (BC17 or BC18 or BC19 or BC20)
    local procedure CheckReplicationCounterUpdateIsEnabled(): Boolean
    var
        ReplicationSetupSourceCompany: Record "NPR Replication Setup (Source)";
    begin
        if ReplicationSetupSourceCompany.Get() then
            exit(ReplicationSetupSourceCompany."Enable Replication Counter");
    end;

    #region CustomTables
    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVarietyGroup(var Rec: Record "NPR Variety Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVarietyGroup(var Rec: Record "NPR Variety Group"; var xRec: Record "NPR Variety Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameVarietyGroup(var Rec: Record "NPR Variety Group"; var xRec: Record "NPR Variety Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVariety(var Rec: Record "NPR Variety"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVariety(var Rec: Record "NPR Variety"; var xRec: Record "NPR Variety"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameVariety(var Rec: Record "NPR Variety"; var xRec: Record "NPR Variety"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Table", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVarietyTable(var Rec: Record "NPR Variety Table"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Table", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVarietyTable(var Rec: Record "NPR Variety Table"; var xRec: Record "NPR Variety Table"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Table", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameVarietyTable(var Rec: Record "NPR Variety Table"; var xRec: Record "NPR Variety Table"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Value", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVarietyValue(var Rec: Record "NPR Variety Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Value", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVarietyValue(var Rec: Record "NPR Variety Value"; var xRec: Record "NPR Variety Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Variety Value", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameVarietyValue(var Rec: Record "NPR Variety Value"; var xRec: Record "NPR Variety Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertAttribute(var Rec: Record "NPR Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyAttribute(var Rec: Record "NPR Attribute"; var xRec: Record "NPR Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameAttribute(var Rec: Record "NPR Attribute"; var xRec: Record "NPR Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute ID", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertAttributeID(var Rec: Record "NPR Attribute ID"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute ID", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyAttributeID(var Rec: Record "NPR Attribute ID"; var xRec: Record "NPR Attribute ID"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute ID", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameAttributeID(var Rec: Record "NPR Attribute ID"; var xRec: Record "NPR Attribute ID"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertPeriodDisc(var Rec: Record "NPR Period Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPeriodDisc(var Rec: Record "NPR Period Discount"; var xRec: Record "NPR Period Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenamePeriodDisc(var Rec: Record "NPR Period Discount"; var xRec: Record "NPR Period Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertPeriodDiscLine(var Rec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPeriodDiscLine(var Rec: Record "NPR Period Discount Line"; var xRec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenamePeriodDiscLine(var Rec: Record "NPR Period Discount Line"; var xRec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Disc. Time Interv.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMixedDiscTimeInterv(var Rec: Record "NPR Mixed Disc. Time Interv."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Disc. Time Interv.", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDiscTimeInterv(var Rec: Record "NPR Mixed Disc. Time Interv."; var xRec: Record "NPR Mixed Disc. Time Interv."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Disc. Time Interv.", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMixedDiscTimeInterv(var Rec: Record "NPR Mixed Disc. Time Interv."; var xRec: Record "NPR Mixed Disc. Time Interv."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Level", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMixedDiscLevels(var Rec: Record "NPR Mixed Discount Level"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Level", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDiscLevels(var Rec: Record "NPR Mixed Discount Level"; var xRec: Record "NPR Mixed Discount Level"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Level", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMixedDiscLevels(var Rec: Record "NPR Mixed Discount Level"; var xRec: Record "NPR Mixed Discount Level"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMixedDiscLine(var Rec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDiscLine(var Rec: Record "NPR Mixed Discount Line"; var xRec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMixedDiscLine(var Rec: Record "NPR Mixed Discount Line"; var xRec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMixedDisc(var Rec: Record "NPR Mixed Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMixedDisc(var Rec: Record "NPR Mixed Discount"; var xRec: Record "NPR Mixed Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMixedDisc(var Rec: Record "NPR Mixed Discount"; var xRec: Record "NPR Mixed Discount"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertNpDcCouponTypes(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyNpDcCouponTypes(var Rec: Record "NPR NpDc Coupon Type"; var xRec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameNpDcCouponTypes(var Rec: Record "NPR NpDc Coupon Type"; var xRec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. G/L Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertAuxGLAccount(var Rec: Record "NPR Aux. G/L Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. G/L Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyAuxGLAccount(var Rec: Record "NPR Aux. G/L Account"; var xRec: Record "NPR Aux. G/L Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Aux. G/L Account", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameAuxGLAccount(var Rec: Record "NPR Aux. G/L Account"; var xRec: Record "NPR Aux. G/L Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Website", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoWebsite(var Rec: Record "NPR Magento Website"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Website", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoWebsite(var Rec: Record "NPR Magento Website"; var xRec: Record "NPR Magento Website"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Website", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoWebsite(var Rec: Record "NPR Magento Website"; var xRec: Record "NPR Magento Website"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Website Link", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoWebsiteLink(var Rec: Record "NPR Magento Website Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Website Link", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoWebsiteLink(var Rec: Record "NPR Magento Website Link"; var xRec: Record "NPR Magento Website Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Website Link", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoWebsiteLink(var Rec: Record "NPR Magento Website Link"; var xRec: Record "NPR Magento Website Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Store", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoStore(var Rec: Record "NPR Magento Store"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Store", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoStore(var Rec: Record "NPR Magento Store"; var xRec: Record "NPR Magento Store"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Store", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoStore(var Rec: Record "NPR Magento Store"; var xRec: Record "NPR Magento Store"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Store Item", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoStoreItem(var Rec: Record "NPR Magento Store Item"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Store Item", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoStoreItem(var Rec: Record "NPR Magento Store Item"; var xRec: Record "NPR Magento Store Item"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Store Item", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoStoreItem(var Rec: Record "NPR Magento Store Item"; var xRec: Record "NPR Magento Store Item"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Picture", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoPicture(var Rec: Record "NPR Magento Picture"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Picture", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoPicture(var Rec: Record "NPR Magento Picture"; var xRec: Record "NPR Magento Picture"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Picture", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoPicture(var Rec: Record "NPR Magento Picture"; var xRec: Record "NPR Magento Picture"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Picture Link", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoPictureLink(var Rec: Record "NPR Magento Picture Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Picture Link", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoPictureLink(var Rec: Record "NPR Magento Picture Link"; var xRec: Record "NPR Magento Picture Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Picture Link", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoPictureLink(var Rec: Record "NPR Magento Picture Link"; var xRec: Record "NPR Magento Picture Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Category", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoCategory(var Rec: Record "NPR Magento Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Category", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoCategory(var Rec: Record "NPR Magento Category"; var xRec: Record "NPR Magento Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Category", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoCategory(var Rec: Record "NPR Magento Category"; var xRec: Record "NPR Magento Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Category Link", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoCategoryLink(var Rec: Record "NPR Magento Category Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Category Link", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoCategoryLink(var Rec: Record "NPR Magento Category Link"; var xRec: Record "NPR Magento Category Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Category Link", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoCategoryLink(var Rec: Record "NPR Magento Category Link"; var xRec: Record "NPR Magento Category Link"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Brand", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoBrand(var Rec: Record "NPR Magento Brand"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Brand", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoBrand(var Rec: Record "NPR Magento Brand"; var xRec: Record "NPR Magento Brand"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Brand", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoBrand(var Rec: Record "NPR Magento Brand"; var xRec: Record "NPR Magento Brand"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoAttribute(var Rec: Record "NPR Magento Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoAttribute(var Rec: Record "NPR Magento Attribute"; var xRec: Record "NPR Magento Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoAttribute(var Rec: Record "NPR Magento Attribute"; var xRec: Record "NPR Magento Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attr. Label", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoAttributeLabel(var Rec: Record "NPR Magento Attr. Label"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attr. Label", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoAttributeLabel(var Rec: Record "NPR Magento Attr. Label"; var xRec: Record "NPR Magento Attr. Label"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attr. Label", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoAttributeLabel(var Rec: Record "NPR Magento Attr. Label"; var xRec: Record "NPR Magento Attr. Label"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute Set", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoAttributeSet(var Rec: Record "NPR Magento Attribute Set"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute Set", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoAttributeSet(var Rec: Record "NPR Magento Attribute Set"; var xRec: Record "NPR Magento Attribute Set"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attribute Set", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoAttributeSet(var Rec: Record "NPR Magento Attribute Set"; var xRec: Record "NPR Magento Attribute Set"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attr. Set Value", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoAttributeSetVal(var Rec: Record "NPR Magento Attr. Set Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attr. Set Value", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoAttributeSetVal(var Rec: Record "NPR Magento Attr. Set Value"; var xRec: Record "NPR Magento Attr. Set Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Attr. Set Value", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoAttributeSetVal(var Rec: Record "NPR Magento Attr. Set Value"; var xRec: Record "NPR Magento Attr. Set Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Item Attr.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoItemAttribute(var Rec: Record "NPR Magento Item Attr."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Item Attr.", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoItemAttribute(var Rec: Record "NPR Magento Item Attr."; var xRec: Record "NPR Magento Item Attr."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Item Attr.", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoItemAttribute(var Rec: Record "NPR Magento Item Attr."; var xRec: Record "NPR Magento Item Attr."; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Item Attr. Value", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoItemAttributeVal(var Rec: Record "NPR Magento Item Attr. Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Item Attr. Value", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoItemAttributeVal(var Rec: Record "NPR Magento Item Attr. Value"; var xRec: Record "NPR Magento Item Attr. Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Item Attr. Value", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoItemAttributeVal(var Rec: Record "NPR Magento Item Attr. Value"; var xRec: Record "NPR Magento Item Attr. Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Display Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoDisplayGroup(var Rec: Record "NPR Magento Display Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Display Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoDisplayGroup(var Rec: Record "NPR Magento Display Group"; var xRec: Record "NPR Magento Display Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Display Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoDisplayGroup(var Rec: Record "NPR Magento Display Group"; var xRec: Record "NPR Magento Display Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Product Relation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertMagentoProductRelation(var Rec: Record "NPR Magento Product Relation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Product Relation", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyMagentoProductRelation(var Rec: Record "NPR Magento Product Relation"; var xRec: Record "NPR Magento Product Relation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Product Relation", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameMagentoProductRelation(var Rec: Record "NPR Magento Product Relation"; var xRec: Record "NPR Magento Product Relation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;
    #endregion

    #region TableExtensions
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertCust(var Rec: Record "Customer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustomer(var Rec: Record "Customer"; var xRec: Record "Customer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameCustomer(var Rec: Record "Customer"; var xRec: Record "Customer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertCustBankAcc(var Rec: Record "Customer Bank Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustomerBankAcc(var Rec: Record "Customer Bank Account"; var xRec: Record "Customer Bank Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameCustomerBankAcc(var Rec: Record "Customer Bank Account"; var xRec: Record "Customer Bank Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItem(var Rec: Record Item; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItem(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItem(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemCat(var Rec: Record "Item Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemCat(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemCat(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemVar(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemVar(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemVar(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemAttribute(var Rec: Record "Item Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemAttribute(var Rec: Record "Item Attribute"; var xRec: Record "Item Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemAttribute(var Rec: Record "Item Attribute"; var xRec: Record "Item Attribute"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemAttributeValue(var Rec: Record "Item Attribute Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemAttributeValue(var Rec: Record "Item Attribute Value"; var xRec: Record "Item Attribute Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemAttributeValue(var Rec: Record "Item Attribute Value"; var xRec: Record "Item Attribute Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemAttributeValueMapping(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemAttributeValueMapping(var Rec: Record "Item Attribute Value Mapping"; var xRec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemAttributeValueMapping(var Rec: Record "Item Attribute Value Mapping"; var xRec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Translation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemAttributeTranslation(var Rec: Record "Item Attribute Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Translation", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemAttributeTranslation(var Rec: Record "Item Attribute Translation"; var xRec: Record "Item Attribute Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Translation", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemAttributeTranslation(var Rec: Record "Item Attribute Translation"; var xRec: Record "Item Attribute Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attr. Value Translation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemAttributeValueTranslation(var Rec: Record "Item Attr. Value Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attr. Value Translation", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemAttributeValueTranslation(var Rec: Record "Item Attr. Value Translation"; var xRec: Record "Item Attr. Value Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attr. Value Translation", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemAttributeValueTranslation(var Rec: Record "Item Attr. Value Translation"; var xRec: Record "Item Attr. Value Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertDefaultDim(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyDefaultDim(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameDefaultDim(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertDim(var Rec: Record "Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyDim(var Rec: Record "Dimension"; var xRec: Record "Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameDim(var Rec: Record "Dimension"; var xRec: Record "Dimension"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertDimValue(var Rec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyDimValue(var Rec: Record "Dimension Value"; var xRec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameDimValue(var Rec: Record "Dimension Value"; var xRec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemRef(var Rec: Record "Item Reference"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemRef(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemRef(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit Of Measure", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemUOM(var Rec: Record "Item Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit Of Measure", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemUOM(var Rec: Record "Item Unit Of Measure"; var xRec: Record "Item Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit Of Measure", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemUOM(var Rec: Record "Item Unit Of Measure"; var xRec: Record "Item Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit Of Measure", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertUOM(var Rec: Record "Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit Of Measure", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyUOM(var Rec: Record "Unit Of Measure"; var xRec: Record "Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit Of Measure", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameUOM(var Rec: Record "Unit Of Measure"; var xRec: Record "Unit Of Measure"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertPriceListHeader(var Rec: Record "Price List Header"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPriceListHeader(var Rec: Record "Price List Header"; var xRec: Record "Price List Header"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Header", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenamePriceListHeader(var Rec: Record "Price List Header"; var xRec: Record "Price List Header"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertPriceListLine(var Rec: Record "Price List Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPriceListLine(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenamePriceListLine(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertSalespersonPurchaser(var Rec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifySalespersonPurchaser(var Rec: Record "Salesperson/Purchaser"; var xRec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameSalespersonPurchaser(var Rec: Record "Salesperson/Purchaser"; var xRec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Price Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertCustPriceGroup(var Rec: Record "Customer Price Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Price Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustPriceGroup(var Rec: Record "Customer Price Group"; var xRec: Record "Customer Price Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Price Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameCustPriceGroup(var Rec: Record "Customer Price Group"; var xRec: Record "Customer Price Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Discount Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertCustDiscountGroup(var Rec: Record "Customer Discount Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Discount Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustDiscountGroup(var Rec: Record "Customer Discount Group"; var xRec: Record "Customer Discount Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Discount Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameCustDiscountGroup(var Rec: Record "Customer Discount Group"; var xRec: Record "Customer Discount Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertCustPostingGroup(var Rec: Record "Customer Posting Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCustPostGroup(var Rec: Record "Customer Posting Group"; var xRec: Record "Customer Posting Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameCustPostGroup(var Rec: Record "Customer Posting Group"; var xRec: Record "Customer Posting Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertLocation(var Rec: Record Location; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyLocation(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameLocation(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertShipMethod(var Rec: Record "Shipment Method"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyShipMethod(var Rec: Record "Shipment Method"; var xRec: Record "Shipment Method"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipment Method", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameShipMethod(var Rec: Record "Shipment Method"; var xRec: Record "Shipment Method"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertPaymentTerms(var Rec: Record "Payment Terms"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPaymentTerms(var Rec: Record "Payment Terms"; var xRec: Record "Payment Terms"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenamePaymentTerms(var Rec: Record "Payment Terms"; var xRec: Record "Payment Terms"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertPayMethod(var Rec: Record "Payment Method"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyPayMethod(var Rec: Record "Payment Method"; var xRec: Record "Payment Method"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenamePayMethod(var Rec: Record "Payment Method"; var xRec: Record "Payment Method"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertCurrency(var Rec: Record Currency; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyCurrency(var Rec: Record Currency; var xRec: Record Currency; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameCurrency(var Rec: Record Currency; var xRec: Record Currency; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVend(var Rec: Record "Vendor"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVend(var Rec: Record "Vendor"; var xRec: Record "Vendor"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameVendor(var Rec: Record "Vendor"; var xRec: Record "Vendor"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVendBankAcc(var Rec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVendBankAcc(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameVendorBankAcc(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVendPostGr(var Rec: Record "Vendor Posting Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyVendPostGr(var Rec: Record "Vendor Posting Group"; var xRec: Record "Vendor Posting Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameVendorPostGr(var Rec: Record "Vendor Posting Group"; var xRec: Record "Vendor Posting Group"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Vendor", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertVendItem(var Rec: Record "Item Vendor"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Vendor", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemVendor(var Rec: Record "Item Vendor"; var xRec: Record "Item Vendor"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Vendor", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemVendor(var Rec: Record "Item Vendor"; var xRec: Record "Item Vendor"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertGLAccount(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        AuxGLAcc: Record "NPR Aux. G/L Account";
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if not AuxGLAcc.Get(Rec."No.") then begin
            AuxGLAcc."No." := Rec."No.";
            AuxGLAcc.Insert();
        end else
            AuxGLAcc.Modify(); // triggers updateReplicationCounter for the Aux Table.
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyGLAccount(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; RunTrigger: Boolean)
    var
        AuxGLAcc: Record "NPR Aux. G/L Account";
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if not AuxGLAcc.Get(Rec."No.") then begin
            AuxGLAcc."No." := Rec."No.";
            AuxGLAcc.Insert();
        end else
            AuxGLAcc.Modify(); // triggers updateReplicationCounter for the Aux Table.
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameGLAccount(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; RunTrigger: Boolean)
    var
        AuxGLAcc: Record "NPR Aux. G/L Account";
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if not AuxGLAcc.Get(xRec."No.") then begin
            AuxGLAcc."No." := xRec."No.";
            AuxGLAcc.Insert();
        end; // modify/rename not needed because it is handled in codeuninit 6014460 "NPR Aux. Tables Event Subs." function --> GLAccountOnAfterRename 
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Translation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemTranslation(var Rec: Record "Item Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Translation", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemTranslation(var Rec: Record "Item Translation"; var xRec: Record "Item Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Translation", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemTranslation(var Rec: Record "Item Translation"; var xRec: Record "Item Translation"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Substitution", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertItemSubstitution(var Rec: Record "Item Substitution"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Substitution", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyItemSubstitution(var Rec: Record "Item Substitution"; var xRec: Record "Item Substitution"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Substitution", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameItemSubstitution(var Rec: Record "Item Substitution"; var xRec: Record "Item Substitution"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturer", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeInsertManufacturer(var Rec: Record "Manufacturer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturer", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeModifyManufacturer(var Rec: Record "Manufacturer"; var xRec: Record "Manufacturer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturer", 'OnBeforeRenameEvent', '', false, false)]
    local procedure UpdateReplicationCounterOnBeforeRenameManufacturer(var Rec: Record "Manufacturer"; var xRec: Record "Manufacturer"; RunTrigger: Boolean)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary() then
            exit;

        if CompanyName() <> Rec.CurrentCompany() then
            exit;

        if DataTypeMgmt.GetRecordRef(Rec, RecRef) then begin
            UpdateReplicationCounter(RecRef, Rec.FieldNo("NPR Replication Counter"));
            RecRef.SetTable(Rec);
        end;
    end;
    #endregion
#ENDIF
}
