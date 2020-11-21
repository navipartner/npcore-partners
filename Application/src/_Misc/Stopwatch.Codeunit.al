codeunit 6150897 "NPR Stopwatch"
{
    var
        _start: Dictionary of [Text, DateTime];
        _elapsed: Dictionary of [Text, Duration];

        LabelErrorUnknownStopwatch: Label 'Unknown stopwatch identifier: %1';

    procedure Elapsed(Id: Text) Result: Duration;
    var
        CurrentTimeStamp: DateTime;
        StartTimeStamp: DateTime;
    begin
        CurrentTimeStamp := CurrentDateTime();

        if (_elapsed.ContainsKey(Id)) then
            _elapsed.Get(Id, Result);

        if (_start.Get(Id, StartTimeStamp)) then
            Result += (CurrentTimeStamp - StartTimeStamp);
    end;

    procedure ElapsedMilliseconds(Id: Text) ElapsedMs: BigInteger;
    begin
        ElapsedMs := Elapsed(Id);
    end;

    procedure IsRunning(Id: Text) Running: Boolean;
    begin
        exit(_start.ContainsKey(Id));
    end;

    procedure ResetAll();
    begin
        Clear(_start);
        Clear(_elapsed);
    end;

    procedure Reset(Id: Text);
    begin
        if (_start.ContainsKey(Id)) then
            _start.Remove(Id);

        if (_elapsed.ContainsKey(Id)) then
            _elapsed.Remove(Id);
    end;

    procedure Restart(Id: Text);
    begin
        Reset(Id);
        Start(Id);
    end;

    procedure Start(Id: Text);
    begin
        if (IsRunning(Id)) then
            exit;

        _start.Add(Id, CurrentDateTime());
    end;

    procedure Stop(Id: Text);
    var
        EndTimeStamp: DateTime;
        StartTimeStamp: DateTime;
        ElapsedThisPeriod: Duration;
    begin
        EndTimeStamp := CurrentDateTime();

        if (not _start.ContainsKey(Id)) then
            Error(LabelErrorUnknownStopwatch, Id);

        if (_elapsed.ContainsKey(Id)) then begin
            _elapsed.Get(Id, ElapsedThisPeriod);
            _elapsed.Remove(Id);
        end;

        _start.Get(Id, StartTimeStamp);
        _start.Remove(Id);

        ElapsedThisPeriod += (EndTimeStamp - StartTimeStamp);
        _elapsed.Add(Id, ElapsedThisPeriod);
    end;
}
