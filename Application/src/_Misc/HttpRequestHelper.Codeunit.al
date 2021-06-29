codeunit 6014591 "NPR HttpRequest Helper"
{
    trigger OnRun()
    begin
    end;

    local procedure Reset()
    begin
        Clear(HeadersDict);
    end;

    internal procedure SetHeaderCollectionObject(var Headers: HttpHeaders)
    begin
        HeadersColl := Headers;
        Reset();
    end;

    internal procedure SetHeader(HeaderName: Text; HeaderValue: Text)
    begin
        HeadersColl.Add(HeaderName, HeaderValue);
        HeadersDict.Add(HeaderName, HeaderValue);
    end;

    internal procedure GetHeader(HeaderName: Text): Text
    var
        HeaderValue: Text;
    begin
        HeadersDict.Get(HeaderName, HeaderValue);
        exit(HeaderValue);
    end;

    internal procedure SetAllCachedHeaders(var Headers: HttpHeaders)
    var
        i: Integer;
        keysList: List of [Text];
        keyName: Text;
        keyValue: Text;
    begin
        if (HeadersDict.Count() = 0) then
            exit;

        KeysList := HeadersDict.Keys;
        for i := 1 to KeysList.Count() do begin
            keyName := KeysList.Get(i);
            keyValue := HeadersDict.Get(keyName);
            Headers.Add(keyName, keyValue);
        end;
    end;

    internal procedure CopyRequest(var FromRequest: HttpRequestMessage; var ToRequest: HttpRequestMessage)
    var
        ToHeaders: HttpHeaders;
    begin
        Clear(ToRequest);
        // Copy content
        ToRequest.Content(fromRequest.Content);
        // Copy headers
        ToRequest.GetHeaders(ToHeaders);
        ToHeaders.Clear();
        SetAllCachedHeaders(ToHeaders);
        // Copy URI
        toRequest.SetRequestUri(fromRequest.GetRequestUri());
        // Copy method
        toRequest.Method(fromRequest.Method());
    end;

    var
        HeadersColl: HttpHeaders;
        HeadersDict: Dictionary of [Text, Text];
}