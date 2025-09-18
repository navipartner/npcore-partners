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

    [IntegrationEvent(false, false)]
    internal procedure OnInitStoreItemLinkMetafields(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInitStoreCustomerLinkMetafields(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean; Silent: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDoBCMetafieldUpdate(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield"; OwnerNo: Code[20]; var Updated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessMetafieldEntityDataLogEntry(SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; var ShopifyStoreCode: Code[20]; var TaskRecordValue: Text; var ProcessRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnPrepareMetafieldUpdateRequest(RecRef: RecordRef; var OwnerRecID: RecordId; var ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var ShopifyOwnerID: Text[30]; var ShopifyStoreCode: Code[20]; var Handled: Boolean)
    begin
    end;
}
#endif