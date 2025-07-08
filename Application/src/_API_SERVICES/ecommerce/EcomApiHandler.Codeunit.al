#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248361 "NPR EcomApiHandler"
{
    Access = Internal;

    var
        _Request: Codeunit "NPR API Request";
        _Response: Codeunit "NPR API Response";
        _ApiFunction: Enum "NPR EcomApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR EcomApiFunctions"; var Request: Codeunit "NPR API Request")
    var
        ErrorCode: Enum "NPR API Error Code";
        ErrorStatusCode: Enum "NPR API HTTP Status Code";
    begin
        _ApiFunction := ApiFunction;
        _Request := Request;
        _Response.CreateErrorResponse(ErrorCode::resource_not_found, StrSubstNo('The API function %1 is not yet supported.', _ApiFunction), ErrorStatusCode::"Bad Request");
    end;

    internal procedure GetResponse() Response: Codeunit "NPR API Response"
    begin
        Response := _Response;
    end;

    internal procedure HandleFunction()
    var
        IncEcomSalesDocApiAgent: Codeunit "NPR IncEcomSalesDocApiAgent";
    begin
        case _ApiFunction of
            _ApiFunction::CREATE_SALES_DOCUMENT:
                _Response := IncEcomSalesDocApiAgent.CreateIncomingEcomDocument(_Request);
            _ApiFunction::GET_SALES_DOCUMENT:
                _Response := IncEcomSalesDocApiAgent.GetIncomingEcomDocumentById(_Request);
        end;
    end;
}
#endif