#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248360 "NPR EcomAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR EcomApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('POST', '/ecommerce/documents'):
                exit(Handle(_ApiFunction::CREATE_SALES_DOCUMENT, Request));
            Request.Match('GET', '/ecommerce/documents/:documentId'):
                exit(Handle(_ApiFunction::GET_SALES_DOCUMENT, Request));
            Request.Match('GET', '/ecommerce/documents'):
                exit(Handle(_ApiFunction::FIND_SALES_DOCUMENTS, Request));
        end;
    end;

    local procedure Handle(ApiFunction: Enum "NPR EcomApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        EcomApiHandler: Codeunit "NPR EcomApiHandler";
        ApiError: Enum "NPR API Error Code";
        ResponseMessage: Text;
    begin
        Commit();
        ClearLastError();

        EcomApiHandler.SetRequest(ApiFunction, Request);
        if (EcomApiHandler.Run()) then begin
            Response := EcomApiHandler.GetResponse();
            exit(Response);
        end;

        ResponseMessage := GetLastErrorText();
        ApiError := ErrorToEnum();

        Response.CreateErrorResponse(ApiError, ResponseMessage);
        exit(Response);
    end;

    local procedure ErrorToEnum(): Enum "NPR API Error Code"
    begin
        exit(Enum::"NPR API Error Code"::generic_error);
    end;

}
#endif