// Native sibling of frozen codeunit "NPR Spfy Close Order": only sanctioned legacy defect fixes are dual-applied, new-queue behavior changes are not.
codeunit 6151483 "NPR Spfy Task Close Order"
{
    Access = Internal;
    TableNo = "NPR Spfy Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"Sales Header":
                CloseShopifyOrder(Rec);
        end;
    end;

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
    begin
        if not _GraphQLClientSet then begin
            _GraphQLClient := DefaultGraphQLClient;
            _GraphQLClientSet := true;
        end;
        exit(_GraphQLClient);
    end;

    local procedure CloseShopifyOrder(var SpfyTask: Record "NPR Spfy Task")
    var
        ShopifyResponse: JsonToken;
        Success: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();

        Success := SendCloseOrderRequestGraphQL(SpfyTask, ShopifyResponse);
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if _SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
    end;

    local procedure SendCloseOrderRequestGraphQL(var SpfyTask: Record "NPR Spfy Task"; var ShopifyResponse: JsonToken): Boolean
    var
        InputObj: JsonObject;
        RootObj: JsonObject;
        VariablesObj: JsonObject;
        OutStr: OutStream;
        OrderGID: Text;
        CloseOrderMutationTxt: Label 'mutation CloseOrder($input: OrderCloseInput!) {orderClose(input: $input) { order { id closedAt } userErrors { field message } } }', Locked = true;
    begin
        OrderGID := 'gid://shopify/Order/' + SpfyTask."Record Value";
        InputObj.Add('id', OrderGID);
        VariablesObj.Add('input', InputObj);
        RootObj.Add('query', CloseOrderMutationTxt);
        RootObj.Add('variables', VariablesObj);
        SpfyTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        RootObj.WriteTo(OutStr);
        exit(GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse));
    end;

    var
        _SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GraphQLClientSet: Boolean;
}
