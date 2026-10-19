codeunit 85445 "NPR NP Passes Notifier Mock" implements "NPR INPPasses Notifier"
{
    SingleInstance = true;

    var
        _SerialNumbers: List of [Text];
        _LastSerialNumber: Text[36];
        _Calls: Integer;

    procedure NotifyPassUpdated(SerialNumber: Text[36])
    begin
        _Calls += 1;
        _LastSerialNumber := SerialNumber;
        _SerialNumbers.Add(SerialNumber);
    end;

    procedure Reset()
    begin
        _Calls := 0;
        _LastSerialNumber := '';
        Clear(_SerialNumbers);
    end;

    procedure CallCount(): Integer
    begin
        exit(_Calls);
    end;

    procedure LastSerialNumber(): Text[36]
    begin
        exit(_LastSerialNumber);
    end;

    procedure WasNotified(SerialNumber: Text): Boolean
    begin
        exit(_SerialNumbers.Contains(SerialNumber));
    end;

    // The injected notifier is session state; clear it so later tests hit the real webhook.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", OnAfterTestMethodRun, '', false, false)]
    local procedure ClearInjectedNotifierAfterTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    var
        Facade: Codeunit "NPR NP Passes Facade";
    begin
        Facade.ClearNotifier();
    end;
}
