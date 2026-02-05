codeunit 6150873 "NPR HL Mapped Value Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Public;

    procedure GetMappedValue(RecID: RecordId; AttachedToFieldNo: Integer; Mandatory: Boolean): Text[100]
    var
        HLMappedValue: Record "NPR HL Mapped Value";
    begin
        FilterRecordset(RecID, AttachedToFieldNo, HLMappedValue);
        if Mandatory then begin
            HLMappedValue.FindFirst();
            HLMappedValue.TestField(Value);
        end else
            if not HLMappedValue.FindFirst() then
                exit('');
        exit(HLMappedValue.Value);
    end;

    procedure SetMappedValue(RecID: RecordId; AttachedToFieldNo: Integer; NewValue: Text[100]; WithCheck: Boolean)
    var
        HLMappedValue: Record "NPR HL Mapped Value";
    begin
        if NewValue = '' then begin
            RemoveMappedValues(RecID, AttachedToFieldNo);
            exit;
        end;

        if WithCheck then
            CheckForDuplicates(RecID, AttachedToFieldNo, NewValue);

        FilterRecordset(RecID, AttachedToFieldNo, HLMappedValue);
        if not HLMappedValue.FindFirst() then begin
            HLMappedValue.Init();
            HLMappedValue."Table No." := RecID.TableNo();
            HLMappedValue."BC Record ID" := RecID;
            HLMappedValue."Attached to Field No." := AttachedToFieldNo;
            HLMappedValue."Entry No." := 0;
            HLMappedValue.Insert();
        end;

        if HLMappedValue.Value <> NewValue then begin
            HLMappedValue.Value := NewValue;
            HLMappedValue.Modify(true);
        end;
    end;

    procedure CopyMappedValues(FromRecID: RecordId; ToRecID: RecordId; AttachedToFieldNo: Integer; OnlySpecifiedField: Boolean; Move: Boolean)
    var
        HLMappedValue: Record "NPR HL Mapped Value";
    begin
        FilterRecordset(FromRecID, AttachedToFieldNo, HLMappedValue);
        if not OnlySpecifiedField then
            HLMappedValue.SetRange("Attached to Field No.");
        if HLMappedValue.FindSet() then
            repeat
                SetMappedValue(ToRecID, HLMappedValue."Attached to Field No.", HLMappedValue.Value, not Move or (FromRecID.TableNo() <> ToRecID.TableNo()));
                if Move then
                    HLMappedValue.Delete();
            until HLMappedValue.Next() = 0;
    end;

    procedure RemoveMappedValues(RecID: RecordId)
    var
        HLMappedValue: Record "NPR HL Mapped Value";
    begin
        FilterRecordset(RecID, 0, HLMappedValue);
        HLMappedValue.SetRange("Attached to Field No.");
        if not HLMappedValue.IsEmpty() then
            HLMappedValue.DeleteAll();
    end;

    procedure RemoveMappedValues(RecID: RecordId; AttachedToFieldNo: Integer)
    var
        HLMappedValue: Record "NPR HL Mapped Value";
    begin
        FilterRecordset(RecID, AttachedToFieldNo, HLMappedValue);
        if not HLMappedValue.IsEmpty() then
            HLMappedValue.DeleteAll();
    end;

    procedure FindMappedValue(TableNo: Integer; AttachedToFieldNo: Integer; ValueToFind: Text[100]; var RecRef: RecordRef) Found: Boolean
    var
        HLMappedValue: Record "NPR HL Mapped Value";
    begin
        Clear(RecRef);
        FilterWhereUsed(TableNo, AttachedToFieldNo, ValueToFind, false, HLMappedValue);
        if HLMappedValue.Find('-') then
            repeat
                Found := RecRef.Get(HLMappedValue."BC Record ID");
            until Found or (HLMappedValue.Next() = 0);
    end;

    procedure FilterWhereUsed(TableNo: Integer; AttachedToFieldNo: Integer; ValueToFind: Text[100]; ForUpdate: Boolean; var HLMappedValue: Record "NPR HL Mapped Value")
    begin
        HLMappedValue.Reset();
        if ForUpdate then
            HLMappedValue.LockTable();
        HLMappedValue.SetCurrentKey("Table No.", "Attached to Field No.", Value);
        HLMappedValue.SetRange("Table No.", TableNo);
        HLMappedValue.SetRange("Attached to Field No.", AttachedToFieldNo);
        HLMappedValue.SetRange(Value, ValueToFind);
    end;

    local procedure FilterRecordset(RecID: RecordId; AttachedToFieldNo: Integer; var HLMappedValue: Record "NPR HL Mapped Value")
    begin
        HLMappedValue.Reset();
        HLMappedValue.SetCurrentKey("Table No.", "BC Record ID", "Attached to Field No.");
        HLMappedValue.SetRange("Table No.", RecID.TableNo());
        HLMappedValue.SetRange("BC Record ID", RecID);
        HLMappedValue.SetRange("Attached to Field No.", AttachedToFieldNo);
    end;

    local procedure CheckForDuplicates(RecID: RecordId; AttachedToFieldNo: Integer; NewValue: Text[100])
    var
        HLMappedValue: Record "NPR HL Mapped Value";
        ValueAlreadyAssigned: Label 'Provided value ''%1'' has already been assigned to another record (%2)';
    begin
        if NewValue = '' then
            exit;

        FilterWhereUsed(RecID.TableNo(), AttachedToFieldNo, NewValue, false, HLMappedValue);
        HLMappedValue.SetFilter("BC Record ID", '<>%1', RecID);
        if HLMappedValue.FindFirst() then
            Error(ValueAlreadyAssigned, NewValue, HLMappedValue."BC Record ID");
    end;

    //#region Subscribers
    [EventSubscriber(ObjectType::Table, Database::"NPR NpCs Store", 'OnAfterDeleteEvent', '', false, false)]
    local procedure CsStore_RemovedMappedValues(var Rec: Record "NPR NpCs Store"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveMappedValues(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpCs Store", 'OnAfterRenameEvent', '', false, false)]
    local procedure CsStore_MoveMappedValues(var Rec: Record "NPR NpCs Store"; var xRec: Record "NPR NpCs Store"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyMappedValues(xRec.RecordId(), Rec.RecordId(), 0, false, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnAfterDeleteEvent', '', false, false)]
    local procedure Attribute_RemovedMappedValues(var Rec: Record "NPR Attribute"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveMappedValues(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnAfterRenameEvent', '', false, false)]
    local procedure Attribute_MoveMappedValues(var Rec: Record "NPR Attribute"; var xRec: Record "NPR Attribute"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyMappedValues(xRec.RecordId(), Rec.RecordId(), 0, false, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Lookup Value", 'OnAfterDeleteEvent', '', false, false)]
    local procedure AttributeValue_RemovedMappedValues(var Rec: Record "NPR Attribute Lookup Value"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveMappedValues(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Lookup Value", 'OnAfterRenameEvent', '', false, false)]
    local procedure AttributeValue_MoveMappedValues(var Rec: Record "NPR Attribute Lookup Value"; var xRec: Record "NPR Attribute Lookup Value"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyMappedValues(xRec.RecordId(), Rec.RecordId(), 0, false, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership Setup", 'OnAfterDeleteEvent', '', false, false)]
    local procedure MembershipSetup_RemovedMappedValues(var Rec: Record "NPR MM Membership Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveMappedValues(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership Setup", 'OnAfterRenameEvent', '', false, false)]
    local procedure MembershipSetup_MoveMappedValues(var Rec: Record "NPR MM Membership Setup"; var xRec: Record "NPR MM Membership Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyMappedValues(xRec.RecordId(), Rec.RecordId(), 0, false, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Country/Region", 'OnAfterDeleteEvent', '', false, false)]
    local procedure Country_RemovedMappedValues(var Rec: Record "Country/Region"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveMappedValues(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Country/Region", 'OnAfterRenameEvent', '', false, false)]
    local procedure Country_MoveMappedValues(var Rec: Record "Country/Region"; var xRec: Record "Country/Region"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyMappedValues(xRec.RecordId(), Rec.RecordId(), 0, false, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HL MultiChoice Field", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HLMCField_RemovedMappedValues(var Rec: Record "NPR HL MultiChoice Field"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveMappedValues(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HL MultiChoice Field", 'OnAfterRenameEvent', '', false, false)]
    local procedure HLMCField_MoveMappedValues(var Rec: Record "NPR HL MultiChoice Field"; var xRec: Record "NPR HL MultiChoice Field"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyMappedValues(xRec.RecordId(), Rec.RecordId(), 0, false, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HL MultiChoice Fld Option", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HLMCFieldOpt_RemovedMappedValues(var Rec: Record "NPR HL MultiChoice Fld Option"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveMappedValues(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HL MultiChoice Fld Option", 'OnAfterRenameEvent', '', false, false)]
    local procedure HLMCFieldOpt_MoveMappedValues(var Rec: Record "NPR HL MultiChoice Fld Option"; var xRec: Record "NPR HL MultiChoice Fld Option"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyMappedValues(xRec.RecordId(), Rec.RecordId(), 0, false, true);
    end;
    //#endregion
}