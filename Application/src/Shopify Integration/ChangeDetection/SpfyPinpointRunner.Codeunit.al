codeunit 6151539 "NPR Spfy Pinpoint Runner"
{
    Access = Internal;
    SingleInstance = true;

    var
        _IntegrationType: Enum "NPR Integration Type";
        _DrainEntryNo: BigInteger;
        _TableNo: Integer;
        _Continue: Boolean;
        _DrainSucceeded: Boolean;
        _Mode: Option PinpointWalk,RecordFailure,DrainStep;
        _FirstErrorText: Text;
        _RowCallStack: Text;
        _RowErrorText: Text;

    trigger OnRun()
    var
        ChangeTracker: Record "NPR Change Tracker";
        SpfyChangeDetection: Codeunit "NPR Spfy Change Detection";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
    begin
        // No tracker is involved in a drain step: the deletion log row is the only record it touches.
        if _Mode = _Mode::DrainStep then begin
            if _DrainSucceeded then
                SpfyDeletionLogMgt.ClearDrainFailure(_DrainEntryNo)
            else
                SpfyDeletionLogMgt.RecordDrainFailure(_DrainEntryNo, _RowErrorText, _RowCallStack);
            _Continue := true;
            exit;
        end;
        if not ChangeTracker.Get(_IntegrationType, _TableNo) then
            exit;
        if _Mode = _Mode::RecordFailure then begin
            SpfyChangeDetection.RecordFailedRowWithoutRedispatch(ChangeTracker, _RowErrorText, _RowCallStack);
            _Continue := false;
        end else
            _Continue := SpfyChangeDetection.RunPinpointWindow(ChangeTracker, _FirstErrorText);
    end;

    internal procedure SetTracker(IntegrationType: Enum "NPR Integration Type"; TableNo: Integer; FirstErrorTextParam: Text)
    begin
        _IntegrationType := IntegrationType;
        _TableNo := TableNo;
        _Mode := _Mode::PinpointWalk;
        Clear(_Continue);
        // Seeded, not cleared: the walk's own CaptureFirstError must stay silent once the cycle already reported.
        _FirstErrorText := FirstErrorTextParam;
    end;

    internal procedure SetRecordFailureStep(IntegrationType: Enum "NPR Integration Type"; TableNo: Integer; RowErrorText: Text; RowCallStack: Text)
    begin
        _IntegrationType := IntegrationType;
        _TableNo := TableNo;
        _RowErrorText := RowErrorText;
        _RowCallStack := RowCallStack;
        _Mode := _Mode::RecordFailure;
        Clear(_Continue);
        Clear(_FirstErrorText);
    end;

    internal procedure SetDrainStep(EntryNo: BigInteger; Succeeded: Boolean; RowErrorText: Text; RowCallStack: Text)
    begin
        _DrainEntryNo := EntryNo;
        _DrainSucceeded := Succeeded;
        _RowErrorText := RowErrorText;
        _RowCallStack := RowCallStack;
        _Mode := _Mode::DrainStep;
        Clear(_Continue);
        Clear(_FirstErrorText);
    end;

    internal procedure ShouldContinue(): Boolean
    begin
        exit(_Continue);
    end;

    internal procedure FirstErrorText(): Text
    begin
        exit(_FirstErrorText);
    end;
}
