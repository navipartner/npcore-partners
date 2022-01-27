codeunit 6014504 "NPR MobilePayV10 Call Thrtl."
{
    Access = Internal;
    // https://mobilepaydev.github.io/MobilePay-PoS-v10/api_principles#call_throttling

    SingleInstance = true;

    var
        PollingDict: Dictionary of [Text, DateTime];

    internal procedure SetPollingLimit(Endpoint: Text; DelayInMs: Integer)
    var
        NextPollingMoment: DateTime;
    begin
        NextPollingMoment := CurrentDateTime + DelayInMs;
        PutValueToDictionary(Endpoint, NextPollingMoment);
    end;

    internal procedure CheckPollingThrottlingLimitAndWait(Endpoint: Text)
    var
        NextPollingMoment: DateTime;
        SleepMs: Integer;
    begin
        if (Endpoint = '') then
            exit;

        NextPollingMoment := GetValueFromDictionary(Endpoint);
        SleepMs := NextPollingMoment - CurrentDateTime;
        if (SleepMs > 0) then begin
            Sleep(SleepMs);
        end;

        exit;
    end;

    local procedure PutValueToDictionary(DictKey: Text; DictValue: DateTime)
    begin
        if (not PollingDict.ContainsKey(DictKey)) then begin
            PollingDict.Add(DictKey, DictValue);
        end else begin
            PollingDict.Set(DictKey, DictValue);
        end;
    end;

    local procedure GetValueFromDictionary(DictKey: Text): DateTime
    var
        NextPollingMoment: DateTime;
    begin
        if not PollingDict.Get(DictKey, NextPollingMoment) then
            NextPollingMoment := CurrentDateTime;

        if ((NextPollingMoment - CurrentDateTime) > GetMaxTimeoutInMs()) then begin
            // Let's keep some reasonable max timeout (not defined by MobilePay).
            NextPollingMoment := CurrentDateTime + GetMaxTimeoutInMs();
            PutValueToDictionary(DictKey, NextPollingMoment);
        end;

        exit(NextPollingMoment);
    end;

    local procedure GetMaxTimeoutInMs(): Integer
    begin
        exit(30 * 1000);
    end;

}
