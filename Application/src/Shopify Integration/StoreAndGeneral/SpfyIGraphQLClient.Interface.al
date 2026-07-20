#if not BC17
interface "NPR Spfy IGraphQL Client"
{
    Access = Internal;

    /// <summary>
    /// Executes the GraphQL request whose JSON body is attached to NcTask."Data Output" and returns the parsed response.
    /// Abstracts the Shopify HTTP boundary so callers can be tested against a mock client.
    /// Mirrors the [TryFunction] semantics of "NPR Spfy Communication Handler".ExecuteShopifyGraphQLRequest:
    /// returns false on failure with the reason available via GetLastErrorText().
    /// </summary>
    procedure ExecuteRequest(var NcTask: Record "NPR Nc Task"; CheckIntegrationIsEnabled: Boolean; var ShopifyResponse: JsonToken): Boolean
}
#endif
