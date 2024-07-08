codeunit 6184694 "NPR Vipps Mp SetupState"
{
    Access = Internal;
    SingleInstance = True;

    var
        _CurrentPosUnitNo: Code[10];
        _CurrentMsn: Text[10];

    #region SETUP
    internal procedure SetCurrentPosUnitNo(CurrentPosUnitNo: Code[10])
    begin
        _CurrentPosUnitNo := CurrentPosUnitNo;
    end;

    internal procedure GetCurrentPosUnitNo(): Code[10]
    begin
        exit(_CurrentPosUnitNo);
    end;

    internal procedure SetCurrentMsn(CurrentMsn: Text[10])
    begin
        _CurrentMsn := CurrentMsn;
    end;

    internal procedure GetCurrentMsn(): Text[10]
    begin
        exit(_CurrentMsn);
    end;
    #endregion
}