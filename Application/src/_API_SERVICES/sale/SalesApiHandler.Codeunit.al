#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248376 "NPR SalesApiHandler"
{
    Access = Internal;

    var
        _Request: Codeunit "NPR API Request";
        _Response: Codeunit "NPR API Response";
        _ApiFunction: Enum "NPR SalesApiFunctions";
        SalesApiAgent: Codeunit "NPR SalesApiAgent";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR SalesApiFunctions"; var Request: Codeunit "NPR API Request")
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
    begin
        case _ApiFunction of
            _ApiFunction::GET_SALES_INVOICE_PDF:
                _Response := SalesApiAgent.GetInvoiceByDocumentNoAsPdf(_Request);
        end;
    end;
}
#endif