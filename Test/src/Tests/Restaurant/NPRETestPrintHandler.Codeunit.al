codeunit 85413 "NPR NPRE Test Print Handler"
{
    // Stand-in for a kitchen print handler, registered against a print template's "Codeunit ID" so a test can see
    // exactly what the new print experience dispatched. Single instance so the captured values survive the
    // Codeunit.Run that invokes it and can be read back by the test afterwards.
    Access = Internal;
    SingleInstance = true;
    TableNo = "NPR NPRE W.Pad.Line Out.Buffer";

    var
        _CapturedWaiterPadNo: Code[20];
        _InvocationCount: Integer;
        _JobLines: List of [Text];
        _LastJobLineCount: Integer;

    trigger OnRun()
    var
        LineNos: Text;
    begin
        _InvocationCount += 1;
        _CapturedWaiterPadNo := Rec."Waiter Pad No.";
        Rec.Reset();
        _LastJobLineCount := Rec.Count();

        // Record which waiter pad lines this job carried, so a test can tell which ticket a line ended up on.
        if Rec.FindSet() then
            repeat
                if LineNos <> '' then
                    LineNos += ',';
                LineNos += Format(Rec."Waiter Pad Line No.");
            until Rec.Next() = 0;
        _JobLines.Add(LineNos);
    end;

    procedure ClearCaptured()
    begin
        _InvocationCount := 0;
        _LastJobLineCount := 0;
        Clear(_CapturedWaiterPadNo);
        Clear(_JobLines);
    end;

    procedure InvocationCount(): Integer
    begin
        exit(_InvocationCount);
    end;

    procedure CapturedWaiterPadNo(): Code[20]
    begin
        exit(_CapturedWaiterPadNo);
    end;

    procedure LastJobLineCount(): Integer
    begin
        exit(_LastJobLineCount);
    end;

    procedure JobLineCount(JobIndex: Integer): Integer
    var
        LineNos: Text;
    begin
        LineNos := _JobLines.Get(JobIndex);
        if LineNos = '' then
            exit(0);
        exit(LineNos.Split(',').Count());
    end;

    // 1-based index of the first job that carried this waiter pad line, or 0 if no job did.
    procedure JobIndexContainingLine(WaiterPadLineNo: Integer): Integer
    var
        JobIndex: Integer;
    begin
        for JobIndex := 1 to _JobLines.Count() do
            if JobContainsLine(JobIndex, WaiterPadLineNo) then
                exit(JobIndex);
        exit(0);
    end;

    procedure JobCountContainingLine(WaiterPadLineNo: Integer): Integer
    var
        JobIndex: Integer;
        JobCount: Integer;
    begin
        for JobIndex := 1 to _JobLines.Count() do
            if JobContainsLine(JobIndex, WaiterPadLineNo) then
                JobCount += 1;
        exit(JobCount);
    end;

    local procedure JobContainsLine(JobIndex: Integer; WaiterPadLineNo: Integer): Boolean
    begin
        exit(StrPos(',' + _JobLines.Get(JobIndex) + ',', ',' + Format(WaiterPadLineNo) + ',') > 0);
    end;
}
