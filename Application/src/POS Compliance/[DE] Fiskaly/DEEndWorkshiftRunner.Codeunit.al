codeunit 6151379 "NPR DE End Workshift Runner"
{
    Access = Internal;

    var
        _PosEntryNo: Integer;
        _Successful: Boolean;
        _UnitNo: Code[10];

    trigger OnRun()
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
    begin
        DEAuditMgt.DoEndWorkshiftDeFiscaly(_UnitNo, _Successful, _PosEntryNo);
    end;

    internal procedure SetParameters(UnitNo: Code[10]; Successful: Boolean; PosEntryNo: Integer)
    begin
        _UnitNo := UnitNo;
        _Successful := Successful;
        _PosEntryNo := PosEntryNo;
    end;
}
