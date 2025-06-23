#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248428 "NPR LoyaltyApiHandler"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'This API is being phased out';

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR LoyaltyApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR LoyaltyApiFunctions"; var Request: Codeunit "NPR API Request")
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
        LoyaltyPointsAgent: Codeunit "NPR LoyaltyPointsAgent";
        LoyaltyCouponAgent: Codeunit "NPR LoyaltyCouponAgent";
        LoyaltyGeneralAgent: Codeunit "NPR LoyaltyGeneralAgent";
    begin
        case _ApiFunction of
            _ApiFunction::GET_LOYALTY_POINTS:
                _Response := LoyaltyPointsAgent.GetLoyaltyPoints(_Request);

            _ApiFunction::GET_LOYALTY_POINT_ENTRIES:
                _Response := LoyaltyPointsAgent.GetLoyaltyPointEntries(_Request);

            _ApiFunction::GET_MEMBERSHIP_RECEIPT_LIST:
                _Response := LoyaltyGeneralAgent.GetLoyaltyMembershipReceiptList(_Request);

            _ApiFunction::RESERVE_POINTS:
                _Response := LoyaltyPointsAgent.ReservePoints(_Request);

            _ApiFunction::CANCEL_RESERVE_POINTS:
                _Response := LoyaltyPointsAgent.CancelReservePoints(_Request);

            _ApiFunction::CAPTURE_RESERVE_POINTS:
                _Response := LoyaltyPointsAgent.CaptureReservePoints(_Request);

            _ApiFunction::GET_MEMBERSHIP_RECEIPT_PDF:
                _Response := LoyaltyGeneralAgent.GetLoyaltyMembershipReceiptPdf(_Request);

            _ApiFunction::GET_LOYALTY_CONFIGURATION:
                _Response := LoyaltyGeneralAgent.GetLoyaltyConfiguration(_Request);

            _ApiFunction::REGISTER_SALE:
                _Response := LoyaltyGeneralAgent.RegisterSale(_Request);

            _ApiFunction::GET_COUPON_ELIGIBILITY:
                _Response := LoyaltyCouponAgent.GetCouponEligibility(_Request);

            _ApiFunction::CREATE_COUPON:
                _Response := LoyaltyCouponAgent.CreateCoupon(_Request);

            _ApiFunction::LIST_COUPON:
                _Response := LoyaltyCouponAgent.ListCoupon(_Request);

            _ApiFunction::DELETE_COUPON:
                _Response := LoyaltyCouponAgent.DeleteCoupon(_Request);
        end;
    end;
}
#endif