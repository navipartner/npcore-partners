codeunit 85421 "NPR NPRE Test RP Preprocess"
{
    // Stand-in pre-processing codeunit for a retail print template, so a test can see the print jobs the retail print
    // template route dispatched and what each one selected. That route has no handler to observe - it resolves an
    // "NPR RP Template Header" and prints it - but "NPR RP Line Print Mgt.".ProcessTemplate runs the template's
    // "Pre Processing Codeunit" once per job, before the print engine renders anything. That makes it the one seam on
    // that route reachable without a complete template: a layout, device settings and an output selection are all
    // needed before a job would reach "NPR Object Output Mgt.", and none of them say anything about how the jobs were
    // grouped, which is what is under test. Single instance so the captured values survive the Codeunit.Run that
    // invokes it.
    Access = Internal;
    SingleInstance = true;
    TableNo = "NPR NPRE Waiter Pad Line";

    var
        _CapturedWaiterPadNo: Code[20];
        _JobLines: List of [Text];

    trigger OnRun()
    var
        LineNos: Text;
    begin
        _CapturedWaiterPadNo := Rec."Waiter Pad No.";

        // The record arrives filtered and marked exactly as the dispatch left it, so iterating it is the job's
        // membership - which dishes this ticket would have printed. Counting jobs alone cannot see a dispatch that
        // selected nothing.
        if Rec.FindSet() then
            repeat
                if LineNos <> '' then
                    LineNos += ',';
                LineNos += Format(Rec."Line No.");
            until Rec.Next() = 0;
        _JobLines.Add(LineNos);
    end;

    procedure ClearCaptured()
    begin
        Clear(_CapturedWaiterPadNo);
        Clear(_JobLines);
    end;

    procedure InvocationCount(): Integer
    begin
        exit(_JobLines.Count());
    end;

    procedure CapturedWaiterPadNo(): Code[20]
    begin
        exit(_CapturedWaiterPadNo);
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

    // 1-based index of the job that selected this waiter pad line, or 0 if no job did. Comparing two lines' job
    // indexes is how a test states that a template split them onto separate tickets, or kept them on one.
    procedure JobIndexContainingLine(WaiterPadLineNo: Integer): Integer
    var
        JobIndex: Integer;
    begin
        for JobIndex := 1 to _JobLines.Count() do
            if StrPos(',' + _JobLines.Get(JobIndex) + ',', ',' + Format(WaiterPadLineNo) + ',') > 0 then
                exit(JobIndex);
        exit(0);
    end;
}
