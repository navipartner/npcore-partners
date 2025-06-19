#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248252 "NPR RetailVouchersApiHandler"
{
    Access = Internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR RetailVoucherApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR RetailVoucherApiFunctions"; var Request: Codeunit "NPR API Request")
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
        RetailVoucherAgent: Codeunit "NPR RetailVoucherAgent";
    begin
        case _ApiFunction of
            _ApiFunction::FIND_VOUCHERS:
                begin
                    _Response := RetailVoucherAgent.FindVouchers(_Request)
                end;
            _ApiFunction::CREATE_VOUCHER:
                begin
                    _Response := RetailVoucherAgent.CreateVoucher(_Request);
                end;
            _ApiFunction::GET_VOUCHER:
                begin
                    _Response := RetailVoucherAgent.GetVoucher(_Request);
                end;
            _ApiFunction::RESERVE_VOUCHER:
                begin
                    _Response := RetailVoucherAgent.ReserveVoucher(_Request);
                end;
            _ApiFunction::CANCEL_RES_VOUCHER:
                begin
                    _Response := RetailVoucherAgent.CancelVoucherReservation(_Request);
                end;
        end;
    end;
}
#endif