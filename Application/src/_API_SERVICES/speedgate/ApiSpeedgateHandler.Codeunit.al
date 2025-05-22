#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185117 "NPR ApiSpeedgateHandler"
{
    Access = Internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR ApiSpeedgateFunctions";
        _ErrorCode: Enum "NPR API Error Code";
        _ErrorMessage: Text;

    internal procedure SetRequest(ApiFunction: Enum "NPR ApiSpeedgateFunctions"; var Request: Codeunit "NPR API Request");
    var
        ErrorStatusCode: Enum "NPR API HTTP Status Code";
    begin
        _ApiFunction := ApiFunction;
        _Request := Request;
        _ErrorCode := _ErrorCode::resource_not_found;
        _ErrorMessage := StrSubstNo('The API function %1 is not yet supported.', _ApiFunction);
        _Response.CreateErrorResponse(_ErrorCode, _ErrorMessage, ErrorStatusCode::"Bad Request");
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR ApiSpeedgateFunctions"; var Request: Codeunit "NPR API Request"; ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text);
    var
        ErrorStatusCode: Enum "NPR API HTTP Status Code";
    begin
        _ApiFunction := ApiFunction;
        _Request := Request;
        _ErrorCode := ErrorCode;
        _ErrorMessage := ErrorMessage;
        _Response.CreateErrorResponse(ErrorCode, _ErrorMessage, ErrorStatusCode::"Bad Request");
    end;

    internal procedure GetResponse() Response: Codeunit "NPR API Response"
    begin
        Response := _Response;
    end;

    trigger OnRun()
    begin
        HandleFunction();
    end;

    procedure HandleFunction()
    var
        Speedgate: Codeunit "NPR ApiSpeedgateAdmit";
        Reports: Codeunit "NPR ApiSpeedgateReports";
    begin
        case _ApiFunction of
            _ApiFunction::GET_SPEEDGATE_SETUP:
                _Response := Speedgate.GetSetup(_Request);

            _ApiFunction::GET_SCANNER_CATEGORIES:
                _Response := Speedgate.GetScannerCategories(_Request);

            _ApiFunction::LOOKUP_REFERENCE_NUMBER:
                _Response := Reports.LookupReferenceNumber(_Request);

            _ApiFunction::TRY_ADMIT:
                _Response := Speedgate.TryAdmit(_Request);

            _ApiFunction::ADMIT:
                _Response := Speedgate.Admit(_Request);

            _ApiFunction::MARK_AS_DENIED:
                _Response := Speedgate.MarkAsDenied(_Request, _ErrorCode, _ErrorMessage);
        end;
    end;

}
#endif