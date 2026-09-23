codeunit 6151226 "NPR Spfy Task Run Context"
{
    Access = Internal;
    SingleInstance = true;

    var
        _SendBoundary: Interface "NPR Spfy Task Send Boundary";
        _CycleTime: DateTime;
        _RunDeadline: DateTime;
        _SendBoundarySet: Boolean;

    internal procedure SetRunDeadline(DeadlineDT: DateTime)
    begin
        _RunDeadline := DeadlineDT;
    end;

    internal procedure RunDeadline(): DateTime
    begin
        exit(_RunDeadline);
    end;

    internal procedure DeadlineExpired(): Boolean
    begin
        exit((_RunDeadline <> 0DT) and (CurrentDateTime() > _RunDeadline));
    end;

    internal procedure ClearRunDeadline()
    begin
        _RunDeadline := 0DT;
    end;

    internal procedure SetCycleTime(AtDateTime: DateTime)
    begin
        _CycleTime := AtDateTime;
    end;

    internal procedure CycleTime(): DateTime
    begin
        exit(_CycleTime);
    end;

    internal procedure ClearCycleTime()
    begin
        _CycleTime := 0DT;
    end;

    internal procedure SetSendBoundary(NewBoundary: Interface "NPR Spfy Task Send Boundary")
    begin
        _SendBoundary := NewBoundary;
        _SendBoundarySet := true;
    end;

    internal procedure HasSendBoundary(): Boolean
    begin
        exit(_SendBoundarySet);
    end;

    internal procedure SendBoundary(): Interface "NPR Spfy Task Send Boundary"
    begin
        exit(_SendBoundary);
    end;

    internal procedure ClearSendBoundary()
    begin
        _SendBoundarySet := false;
    end;
}
