#if not BC17
codeunit 6185020 "NPR Spfy Store Background Task"
{
    Access = Internal;

    trigger OnRun()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyResponse: JsonToken;
        Results: Dictionary of [Text, Text];
        ShopifyStoreCode: Code[20];
        ShopifyStoreID: Text[30];
    begin
        if not Page.GetBackgroundParameters().ContainsKey('StoreCode') then
            exit;
        ShopifyStoreCode := CopyStr(Page.GetBackgroundParameters().Get('StoreCode'), 1, MaxStrLen(ShopifyStoreCode));
        if ShopifyStoreCode = '' then
            exit;
        ShopifyStore.Get(ShopifyStoreCode);
        ClearLastError();
        if not SpfyCommunicationHandler.GetShopifyStoreConfiguration(ShopifyStore.Code, ShopifyResponse) then
            Error(GetLastErrorText());
        ClearLastError();
        if not SpfyIntegrationMgt.UpdateShopifyStoreWithDataFromShopify(ShopifyStore, ShopifyStoreID, ShopifyResponse, false) then
            Error(GetLastErrorText());

        Results.Add(Format(ShopifyStore.FieldNo("Plan Display Name")), ShopifyStore."Plan Display Name");
        Results.Add(Format(ShopifyStore.FieldNo("Shopify Plus Subscription")), Format(ShopifyStore."Shopify Plus Subscription", 0, 9));
        Results.Add('ShopifyStoreID', ShopifyStoreID);
        Page.SetBackgroundTaskResult(Results);
    end;
}
#endif