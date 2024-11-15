#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185006 "NPR REST API Request"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2024-10-13';
    ObsoleteReason = 'Removed REST from object name';

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

    procedure Path(): Text
    begin
        exit(_Path);
    end;

    procedure RelativePathSegments(): List of [Text]
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
    #endregion
}
#endif