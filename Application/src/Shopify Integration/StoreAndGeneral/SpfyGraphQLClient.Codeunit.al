#if not BC17
codeunit 6151278 "NPR Spfy GraphQL Client" implements "NPR Spfy IGraphQL Client"
{
    Access = Internal;

    var
        _SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";

    procedure ExecuteRequest(var NcTask: Record "NPR Nc Task"; CheckIntegrationIsEnabled: Boolean; var ShopifyResponse: JsonToken): Boolean
    begin
        exit(_SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, CheckIntegrationIsEnabled, ShopifyResponse));
    end;
}
#endif
