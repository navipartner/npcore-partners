#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151046 "NPR ChannelMgrApiHandler"
{
    Access = Internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR ChannelMgrApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR ChannelMgrApiFunctions"; var Request: Codeunit "NPR API Request")
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
        OrderAgent: Codeunit "NPR ChannelMgrOrderAgent";
    begin
        case _ApiFunction of
            _ApiFunction::CREATE_ORDER:
                _Response := OrderAgent.CreateOrder(_Request);

            _ApiFunction::REPLACE_ORDER:
                _Response := OrderAgent.ReplaceOrder(_Request);

            _ApiFunction::DELETE_ORDER:
                _Response := OrderAgent.DeleteOrder(_Request);

            _ApiFunction::GET_ORDER:
                _Response := OrderAgent.GetOrder(_Request);

            _ApiFunction::LIST_ORDERS_BY_PARTNER:
                _Response := OrderAgent.ListOrdersByPartner(_Request);

            _ApiFunction::CONFIRM_ORDER:
                _Response := OrderAgent.ConfirmOrder(_Request);
        end;
    end;
}
#endif
