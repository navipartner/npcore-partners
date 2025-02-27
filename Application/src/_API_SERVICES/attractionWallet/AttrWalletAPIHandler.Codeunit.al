#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22

codeunit 6248330 "NPR AttrWalletAPIHandler"
{
    access = internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR AttrWalletApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR AttrWalletApiFunctions"; var Request: Codeunit "NPR API Request")
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
        WalletApiAgent: Codeunit "NPR WalletApiAgent";
    begin
        case _ApiFunction of

            _ApiFunction::FIND_WALLET_USING_REFERENCE_NUMBER:
                _Response := WalletApiAgent.FindWalletUsingReferenceNumber(_Request);

            _ApiFunction::GET_WALLET_USING_ID:
                _Response := WalletApiAgent.GetWalletUsingId(_Request);

            _ApiFunction::GET_ASSET_HISTORY:
                _Response := WalletApiAgent.GetAssetHistory(_Request);


            _ApiFunction::ADD_WALLET_ASSETS:
                _Response := WalletApiAgent.AddAssets(_Request);

            _ApiFunction::CREATE_WALLET:
                _Response := WalletApiAgent.CreateWallet(_Request);

        end;
    end;
}
#endif