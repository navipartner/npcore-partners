codeunit 6248448 "NPR SG SpeedGate Facade"
{
    Access = Public;

    procedure GetLastScannedReferenceByScanner(ScannerId: Code[10]; var ReferenceNumberType: Enum "NPR SG ReferenceNumberType"; var ReferenceNo: Text[100]; var AdmittedReferenceNo: Text[100]) Found: Boolean
    var
        SGEntryLog: Record "NPR SGEntryLog";
    begin
        SGEntryLog.SetRange(ScannerId, ScannerId);
        Found := SGEntryLog.FindLast();
        ReferenceNumberType := SGEntryLog.ReferenceNumberType;
        ReferenceNo := SGEntryLog.ReferenceNo;
        AdmittedReferenceNo := SGEntryLog.AdmittedReferenceNo;
    end;
}