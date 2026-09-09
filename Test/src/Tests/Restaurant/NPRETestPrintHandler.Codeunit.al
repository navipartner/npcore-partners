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
        _LastJobLineCount: Integer;

    trigger OnRun()
    begin
        _InvocationCount += 1;
        _CapturedWaiterPadNo := Rec."Waiter Pad No.";
        Rec.Reset();
        _LastJobLineCount := Rec.Count();
    end;

    procedure ClearCaptured()
    begin
        _InvocationCount := 0;
        _LastJobLineCount := 0;
        Clear(_CapturedWaiterPadNo);
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
}
