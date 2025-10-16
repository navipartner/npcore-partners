#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248361 "NPR EcomApiHandler"
{
    Access = Internal;

    var
        _Request: Codeunit "NPR API Request";
        _Response: Codeunit "NPR API Response";
        _ApiFunction: Enum "NPR EcomApiFunctions";
        IncEcomSalesDocApiAgent: Codeunit "NPR IncEcomSalesDocApiAgent";
        IncEcomSalesDocApiAgentV2: Codeunit "NPR IncEcomSalesDocApiAgentV2";
        IncEcomSalesDocImplV2: Codeunit "NPR Inc Ecom Sales Doc Impl V2";

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
    begin
        case _ApiFunction of
            _ApiFunction::CREATE_SALES_DOCUMENT:
                RunCreateDocAPIAgentBasedOnRequestHeaderVersion();
            _ApiFunction::GET_SALES_DOCUMENT:
                RunGetDocAPIAgentBasedOnRequestHeaderVersion();
        end;
    end;

    local procedure RunCreateDocAPIAgentBasedOnRequestHeaderVersion()
    begin
        case true of
            _Request.ApiVersion() >= IncEcomSalesDocImplV2.GetApiVersionV2():
                _Response := IncEcomSalesDocApiAgentV2.CreateIncomingEcomDocument(_Request);
            else
                _Response := IncEcomSalesDocApiAgent.CreateIncomingEcomDocument(_Request);
        // Add new api-date-version cases here as needed
        end;
    end;

    local procedure RunGetDocAPIAgentBasedOnRequestHeaderVersion()
    begin
        case true of
            _Request.ApiVersion() >= IncEcomSalesDocImplV2.GetApiVersionV2():
                _Response := IncEcomSalesDocApiAgentV2.GetIncomingEcomDocumentById(_Request);
            else
                _Response := IncEcomSalesDocApiAgent.GetIncomingEcomDocumentById(_Request);
        // Add new api-date-version cases here as needed
        end;
    end;
}
#endif