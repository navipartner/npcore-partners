#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22

codeunit 6248528 "NPR CouponAPIHandler"
{
    access = internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR CouponApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR CouponApiFunctions"; var Request: Codeunit "NPR API Request")
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
        CouponApiAgent: Codeunit "NPR CouponApiAgent";
    begin
        case _ApiFunction of

            _ApiFunction::CREATE_COUPON:
                _Response := CouponApiAgent.CreateCoupon(_Request);

            _ApiFunction::GET_COUPON:
                _Response := CouponApiAgent.GetCoupon(_Request);

            _ApiFunction::DELETE_COUPON:
                _Response := CouponApiAgent.DeleteCoupon(_Request);
        end;
    end;
}
#endif