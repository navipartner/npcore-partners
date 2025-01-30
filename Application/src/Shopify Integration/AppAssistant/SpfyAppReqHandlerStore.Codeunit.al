#if not BC17
codeunit 6248246 "NPR Spfy AppReq.Handler: Store" implements "NPR Spfy App Request IHndlr"
{
    Access = Internal;

    procedure ProcessAppRequest(var SpfyAppRequest: Record "NPR Spfy App Request")
    var
        ShopifyStore: Record "NPR Spfy Store";
        JsonHelper: Codeunit "NPR Json Helper";
        RequestPayload: JsonToken;
        ShopifyURL: Text[250];
    begin
        RequestPayload.ReadFrom(SpfyAppRequest.GetPayloadStream());

#pragma warning disable AA0139
        ShopifyStore.Validate("Shopify Url", JsonHelper.GetJText(RequestPayload, 'shopDomain', true));
        ShopifyURL := ShopifyStore."Shopify Url".TrimEnd('/');
#pragma warning restore AA0139        
        ShopifyStore.SetFilter("Shopify Url", StrSubstNo('@%1*', ShopifyURL));

        if not ShopifyStore.FindFirst() then begin
            ShopifyStore.Reset();
            ShopifyStore.Init();
            ShopifyStore.Code := CopyStr(ShopifyURL.Replace('https://', '').Split('.').Get(1), 1, MaxStrLen(ShopifyStore.Code));
            if ShopifyStore.Find() then begin
                ShopifyStore.Code := CopyStr(ShopifyStore.Code, 1, MaxStrLen(ShopifyStore.Code) - 4) + '_001';
                while ShopifyStore.Find() do
                    ShopifyStore.Code := IncStr(ShopifyStore.Code);
            end;
            ShopifyStore."Shopify Url" := ShopifyURL;
            ShopifyStore.Insert(true);
        end;

#pragma warning disable AA0139
        ShopifyStore."Shopify Access Token" := JsonHelper.GetJText(RequestPayload, 'accessToken', true);
#pragma warning restore AA0139
        ShopifyStore.Modify(true);

        SpfyAppRequest.Status := SpfyAppRequest.Status::Processed;
        SpfyAppRequest."Processed at" := CurrentDateTime();
        SpfyAppRequest.Modify(true);
    end;

    procedure NavigateToRelatedBCEntity(SpfyAppRequest: Record "NPR Spfy App Request")
    var
        ShopifyStore: Record "NPR Spfy Store";
        JsonHelper: Codeunit "NPR Json Helper";
        RequestPayload: JsonToken;
        NotFoundErr: Label 'The Shopify store with URL "%1" was not found.', Comment = '%1 - Shopify store URL';
    begin
        RequestPayload.ReadFrom(SpfyAppRequest.GetPayloadStream());
#pragma warning disable AA0139
        ShopifyStore.Validate("Shopify Url", JsonHelper.GetJText(RequestPayload, 'shopDomain', true));
#pragma warning restore AA0139        
        ShopifyStore.SetFilter("Shopify Url", StrSubstNo('@%1*', ShopifyStore."Shopify Url".TrimEnd('/')));
        if not ShopifyStore.FindFirst() then
            Error(NotFoundErr, ShopifyStore."Shopify Url");

        Page.Run(Page::"NPR Spfy Store Card", ShopifyStore);
    end;
}
#endif