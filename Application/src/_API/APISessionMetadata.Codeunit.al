codeunit 6150730 "NPR API Session Metadata"
{
    Access = Internal;

    var
        _StartTime: DateTime;
        _StartRowsRead: BigInteger;
        _StartStatementsExecuted: BigInteger;

    procedure SetStartTime(StartTime: DateTime)
    begin
        _StartTime := StartTime;
    end;

    procedure SetStartRowsRead(StartRowsRead: BigInteger)
    begin
        _StartRowsRead := StartRowsRead;
    end;

    procedure SetStartStatementsExecuted(StartStatementsExecuted: BigInteger)
    begin
        _StartStatementsExecuted := StartStatementsExecuted;
    end;

    procedure GetStartTime(): DateTime
    begin
        exit(_StartTime);
    end;

    procedure GetStartRowsRead(): BigInteger
    begin
        exit(_StartRowsRead);
    end;

    procedure GetStartStatementsExecuted(): BigInteger
    begin
        exit(_StartStatementsExecuted);
    end;
}