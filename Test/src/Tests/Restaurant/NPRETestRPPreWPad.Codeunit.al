codeunit 85427 "NPR NPRE Test RP Pre WPad"
{
    // The waiter pad counterpart of "NPR NPRE Test RP Preprocess". The retail print template dispatch branches on the
    // resolved template's "Table ID": a waiter pad line template is handed the marked set of lines, a waiter pad
    // template is handed the pad itself. A pre-processing codeunit's TableNo is fixed, so covering the second branch
    // needs a second stand-in rather than a second entry point on the first.
    Access = Internal;
    SingleInstance = true;
    TableNo = "NPR NPRE Waiter Pad";

    var
        _CapturedWaiterPadNo: Code[20];
        _CapturedPadCount: Integer;
        _InvocationCount: Integer;

    trigger OnRun()
    begin
        _InvocationCount += 1;
        _CapturedWaiterPadNo := Rec."No.";

        // The dispatch narrows the pad with SetRecFilter() before handing it over. Counting what arrived is how a test
        // states that: without the filter the job would carry every pad in the company.
        _CapturedPadCount := Rec.Count();
    end;

    procedure ClearCaptured()
    begin
        _InvocationCount := 0;
        _CapturedPadCount := 0;
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

    procedure CapturedPadCount(): Integer
    begin
        exit(_CapturedPadCount);
    end;
}
