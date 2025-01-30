#if not BC17
enum 6059853 "NPR Spfy App Request Type" implements "NPR Spfy App Request IHndlr"
{
    Access = Internal;
    Extensible = false;
    DefaultImplementation = "NPR Spfy App Request IHndlr" = "NPR Spfy AppReq.Handler: Undef";

    value(0; UNDEFINED)
    {
        Caption = '<Undefined>';
    }
    value(10; UpsertShopifyStore)
    {
        Caption = 'Upsert Shopify Store';
        Implementation = "NPR Spfy App Request IHndlr" = "NPR Spfy AppReq.Handler: Store";
    }
}
#endif