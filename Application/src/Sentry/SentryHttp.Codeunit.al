#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6184896 "NPR Sentry Http"
{
    Access = Internal;

    //https://develop.sentry.dev/sdk/performance/#header-sentry-trace

    procedure TryParseSentryTraceHeader(SentryTraceHeader: Text; var ExternalId: Text; var ExternalSpanId: Text; var ExternalSampled: Boolean): Boolean
    var
        Parts: List of [Text];
    begin
        ExternalId := '';
        ExternalSpanId := '';
        ExternalSampled := false;

        if SentryTraceHeader = '' then
            exit(false);

        Parts := SentryTraceHeader.Split('-');
        if Parts.Count() < 2 then
            exit(false);

        ExternalId := Parts.Get(1);
        ExternalSpanId := Parts.Get(2);
        if Parts.Count() >= 3 then
            ExternalSampled := Parts.Get(3) = '1';

        exit(true);
    end;

    procedure AddSentryTraceHeader(var Headers: HttpHeaders; TraceId: Text; SpanId: Text; Sampled: Boolean)
    begin
        Headers.Add('sentry-trace', StrSubstNo('%1-%2-%3', TraceId, SpanId, Format(Sampled, 0, 2)));
    end;

    [TryFunction]
    procedure GetBaseUrl(url: Text; var baseUrl: Text)
    begin
        if url.StartsWith('https://') then
            url := url.Substring(9)
        else if url.StartsWith('http://') then
            url := url.Substring(8);

        if url.Contains('?') then
            url := url.Split('?').Get(1);
        if url.Contains('/') then
            url := url.Split('/').Get(1);

        baseUrl := url;
    end;
}
#endif