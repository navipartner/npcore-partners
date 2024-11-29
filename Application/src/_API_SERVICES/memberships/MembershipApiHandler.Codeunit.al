#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185122 "NPR MembershipApiHandler"
{
    Access = Internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR MembershipApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR MembershipApiFunctions"; var Request: Codeunit "NPR API Request")
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
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        PaymentMethodApiAgent: Codeunit "NPR API SubscriptionPmtMethods";
    begin
        case _ApiFunction of
            _ApiFunction::GET_MEMBERSHIP_USING_NUMBER:
                _Response := MembershipApiAgent.GetMembershipByNumber(_Request);

            _ApiFunction::GET_ALL_PAYMENT_METHODS:
                _Response := PaymentMethodApiAgent.GetPaymentMethods(_Request);

            _ApiFunction::CREATE_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.CreatePaymentMethod(_Request);

            _ApiFunction::GET_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.GetPaymentMethod(_Request);

            _ApiFunction::UPDATE_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.UpdatePaymentMethod(_Request);

            _ApiFunction::DELETE_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.DeletePaymentMethod(_Request);

        end;
    end;


}
#endif