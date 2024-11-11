#if not BC17
codeunit 6185090 "NPR Spfy Metafield Mgt. Public"
{
    Access = Public;

    procedure SelectShopifyMetafield(ShopifyStoreCode: Code[20]; OwnerType: Enum "NPR Spfy Metafield Owner Type"; var SelectedMetafieldID: Text[30]): Boolean
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        exit(SpfyMetafieldMgt.SelectShopifyMetafield(ShopifyStoreCode, OwnerType, SelectedMetafieldID));
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetOwnerTypeAsText(OwnerType: Enum "NPR Spfy Metafield Owner Type"; var Result: Text; var Handled: Boolean)
    begin
    end;
}
#endif