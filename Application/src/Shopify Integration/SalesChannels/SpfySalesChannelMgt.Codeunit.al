#if not BC17
codeunit 6248401 "NPR Spfy Sales Channel Mgt."
{
    Access = Internal;

    var
        _JsonHelper: Codeunit "NPR Json Helper";

    internal procedure RetrieveSalesChannelsFromShopify(ShopifyStoreCode: Code[20]; WithDialog: Boolean)
    var
        Window: Dialog;
        RetrievedPublications: JsonToken;
        ShopifyResponse: JsonToken;
        CurrentChannels: List of [Text[30]];
        Cursor: Text;
        CouldNotGetSalesChannelsErr: Label 'Could not get sales channels from Shopify. The following error occured: %1', Comment = '%1 - Shopify returned error text.';
        QueryingShopifyLbl: Label 'Querying Shopify...';
    begin
        if WithDialog then
            WithDialog := GuiAllowed;
        if WithDialog then
            Window.Open(QueryingShopifyLbl);
        GetCurrentChannels(ShopifyStoreCode, CurrentChannels);

        Cursor := '';
        repeat
            if not GetSalesChannelsFromShopify(ShopifyStoreCode, Cursor, ShopifyResponse) then
                Error(CouldNotGetSalesChannelsErr, GetLastErrorText());
            if _JsonHelper.GetJsonToken(ShopifyResponse, 'data.publications.edges', RetrievedPublications) and RetrievedPublications.IsArray() then
                UpdateSalesChannels(ShopifyStoreCode, RetrievedPublications.AsArray(), Cursor, CurrentChannels);
        until not _JsonHelper.GetJBoolean(ShopifyResponse, 'data.publications.pageInfo.hasNextPage', false) or (Cursor = '');

        RemoveObsoleteChannels(ShopifyStoreCode, CurrentChannels);

        if WithDialog then
            Window.Close();
    end;

    local procedure GetSalesChannelsFromShopify(ShopifyStoreCode: Code[20]; Cursor: Text; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        FirstPageQueryTok: Label 'query GetSalesChannels($catalogType: CatalogType!) {publications(first: 25, catalogType: $catalogType) {pageInfo {hasNextPage} edges {cursor node {id catalog {id ... on AppCatalog{apps(first: 1) {edges {node {id handle title}}}}}}}}}', Locked = true;
        SubsequentPageQueryTok: Label 'query GetSalesChannels($catalogType: CatalogType!, $afterCursor: String!) {publications(first: 25, after: $afterCursor, catalogType : $catalogType) {pageInfo {hasNextPage} edges {cursor node {id catalog {id ... on AppCatalog{apps(first: 1) {edges {node {id handle title}}}}}}}}}', Locked = true;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        VariablesJson.Add('catalogType', 'APP');
        if Cursor = '' then
            RequestJson.Add('query', FirstPageQueryTok)
        else begin
            RequestJson.Add('query', SubsequentPageQueryTok);
            VariablesJson.Add('afterCursor', Cursor);
        end;
        RequestJson.Add('variables', VariablesJson);
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);

        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    local procedure UpdateSalesChannels(ShopifyStoreCode: Code[20]; Publications: JsonArray; var Cursor: Text; var CurrentChannels: List of [Text[30]])
    var
        SpfySalesChannel: Record "NPR Spfy Sales Channel";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        Catalog: JsonToken;
        CatalogEdges: JsonToken;
        Publication: JsonToken;
        SalesChannelID: Text[30];
    begin
        foreach Publication in Publications do begin
            Cursor := _JsonHelper.GetJText(Publication, 'cursor', false);
#pragma warning disable AA0139
            SalesChannelID := SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(Publication, '$.node.id', false), '/');
#pragma warning restore AA0139
            if not SpfySalesChannel.Get(ShopifyStoreCode, SalesChannelID) then begin
                SpfySalesChannel.Init();
                SpfySalesChannel."Shopify Store Code" := ShopifyStoreCode;
                SpfySalesChannel.ID := SalesChannelID;
                SpfySalesChannel.Insert(true);
            end else
                CurrentChannels.Remove(SalesChannelID);

            if _JsonHelper.GetJsonToken(Publication, '$.node.catalog.apps.edges', CatalogEdges) and CatalogEdges.IsArray() then
                if CatalogEdges.AsArray().Get(0, Catalog) then begin
#pragma warning disable AA0139
                    SpfySalesChannel.Name := _JsonHelper.GetJText(Catalog, '$.node.title', MaxStrLen(SpfySalesChannel.Name), false);
                    SpfySalesChannel.Handle := _JsonHelper.GetJText(Catalog, '$.node.handle', MaxStrLen(SpfySalesChannel.Handle), false);
#pragma warning restore AA0139
                    SpfySalesChannel.Default := SpfySalesChannel.Handle = OnlineStoreHandle();
                    SpfySalesChannel.Modify(true);
                end;
        end;
    end;

    local procedure GetCurrentChannels(ShopifyStoreCode: Code[20]; var Channels: List of [Text[30]])
    var
        SpfySalesChannel: Record "NPR Spfy Sales Channel";
    begin
        Clear(Channels);
        SpfySalesChannel.SetRange("Shopify Store Code", ShopifyStoreCode);
        if SpfySalesChannel.FindSet() then begin
            repeat
                Channels.Add(SpfySalesChannel.ID);
            until SpfySalesChannel.Next() = 0;
        end;
    end;

    local procedure RemoveObsoleteChannels(ShopifyStoreCode: Code[20]; ObsoleteChannels: List of [Text[30]])
    var
        SpfySalesChannel: Record "NPR Spfy Sales Channel";
        ChannelId: Text[30];
    begin
        foreach ChannelId in ObsoleteChannels do
            if SpfySalesChannel.Get(ShopifyStoreCode, ChannelId) then
                SpfySalesChannel.Delete(true);
    end;

    internal procedure PublishProductToSalesChannels(ShopifyStoreCode: Code[20]; ShopifyProductID: Text[30]): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfySalesChannel: Record "NPR Spfy Sales Channel";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        SalesChannels: JsonArray;
        RequestJson: JsonObject;
        SalesChannel: JsonObject;
        VariablesJson: JsonObject;
        ShopifyResponse: JsonToken;
        QueryTok: Label 'mutation PublishProductToChannels($productId: ID!, $salesChannels: [PublicationInput!]!) {publishablePublish(id: $productId, input: $salesChannels) {userErrors {field message}}}', Locked = true;
    begin
        if not FilterSalesChannelsToPublishProductTo(ShopifyStoreCode, SpfySalesChannel) then
            exit;

        VariablesJson.Add('productId', 'gid://shopify/Product/' + ShopifyProductID);
        SpfySalesChannel.FindSet();
        repeat
            SalesChannel.Add('publicationId', 'gid://shopify/Publication/' + SpfySalesChannel.ID);
            SalesChannels.Add(SalesChannel);
            Clear(SalesChannel);
        until SpfySalesChannel.Next() = 0;
        VariablesJson.Add('salesChannels', SalesChannels);

        NcTask."Store Code" := ShopifyStoreCode;
        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);

        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    local procedure FilterSalesChannelsToPublishProductTo(ShopifyStoreCode: Code[20]; var SpfySalesChannel: Record "NPR Spfy Sales Channel"): Boolean
    begin
        SpfySalesChannel.SetRange("Shopify Store Code", ShopifyStoreCode);
        if SpfySalesChannel.IsEmpty() then
            RetrieveSalesChannelsFromShopify(ShopifyStoreCode, false);

        SpfySalesChannel.SetRange(SpfySalesChannel."Use for publication", true);
        if SpfySalesChannel.IsEmpty() then begin
            SpfySalesChannel.SetRange("Use for publication");
            SpfySalesChannel.SetRange(Default, true);
            if SpfySalesChannel.IsEmpty() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure OnlineStoreHandle(): Text[100]
    begin
        exit('online_store');
    end;
}
#endif