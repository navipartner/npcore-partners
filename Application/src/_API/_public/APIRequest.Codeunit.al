#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185051 "NPR API Request"
{
    var
        _HttpMethod: Enum "Http Method";
        _Path: Text;
        _ModuleName: Text;
        _RelativePathSegments: List of [Text];
        _QueryParams: Dictionary of [Text, Text];
        _Headers: Dictionary of [Text, Text];
        _BodyJson: JsonToken;

    #region Initializer
    procedure Init(RequestHttpMethod: Enum "Http Method"; RequestPath: Text; RequestRelativePathSegments: List of [Text]; RequestQueryParams: Dictionary of [Text, Text];
        RequestHeaders: Dictionary of [Text, Text]; RequestBodyJson: JsonToken)
    begin
        _HttpMethod := RequestHttpMethod;
        _Path := RequestPath;
        _RelativePathSegments := RequestRelativePathSegments;
        _QueryParams := RequestQueryParams;
        _Headers := RequestHeaders;
        _BodyJson := RequestBodyJson;
        _ModuleName := _RelativePathSegments.Get(1);
    end;
    #endregion

    #region Getters
    procedure HttpMethod(): Enum "Http Method"
    begin
        exit(_HttpMethod);
    end;

    procedure ModuleName(): Text
    begin
        exit(_ModuleName);
    end;

    procedure FullPath(): Text
    begin
        exit(_Path);
    end;

    procedure Paths(): List of [Text]
    begin
        exit(_RelativePathSegments);
    end;

    procedure QueryParams(): Dictionary of [Text, Text]
    begin
        exit(_QueryParams);
    end;

    procedure Headers(): Dictionary of [Text, Text]
    begin
        exit(_Headers);
    end;

    procedure BodyJson(): JsonToken
    begin
        exit(_BodyJson);
    end;

    procedure ApiVersion(): Date
    var
        _apiVersion: Date;
    begin
        if not _Headers.ContainsKey('x-api-version') then
            exit(Today());

        Evaluate(_apiVersion, _Headers.Get('x-api-version'), 9);
        exit(_apiVersion);
    end;

    procedure Match(Method: Text; _fullPath: Text): Boolean
    var
        _Paths: List of [Text];
        i: Integer;
    begin
        if (Format(_HttpMethod) <> Method) then
            exit(false);

        _Paths := _fullPath.Split('/');
        _Paths.Remove('');
        if (_Paths.Count() <> _RelativePathSegments.Count()) then
            exit(false);

        for i := 1 to _Paths.Count() do begin
            if (not _Paths.Get(i).StartsWith(':')) then begin
                if (_Paths.Get(i) <> _RelativePathSegments.Get(i)) then
                    exit(false);
            end;
        end;

        exit(true);
    end;

    #endregion
}
#endif