codeunit 85668 "NPR Spfy Order Cancel Stub"
{
    // Answers the question the order import asks Shopify before it creates a document: is this order canceled now?
    // The import list and the event log processor create the importing codeunits themselves, so the mock client
    // is handed out through the test seam of "NPR Spfy Order Cancel Check". Bind an instance for the part of the
    // test that runs the import.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        _QueryNameTok: Label 'GetOrderCancellation', Locked = true;

    /// <summary>Shopify reports the order as not canceled.</summary>
    procedure SetOrderOpen(ShopifyOrderId: Text)
    begin
        _MockClient.AddResponse(_QueryNameTok, ShopifyOrderId, '{"data":{"order":{"id":"gid://shopify/Order/' + ShopifyOrderId + '","cancelledAt":null}}}');
    end;

    /// <summary>Shopify reports the order as canceled.</summary>
    procedure SetOrderCancelled(ShopifyOrderId: Text)
    begin
        _MockClient.AddResponse(_QueryNameTok, ShopifyOrderId, '{"data":{"order":{"id":"gid://shopify/Order/' + ShopifyOrderId + '","cancelledAt":"2026-01-15T10:00:00Z"}}}');
    end;

    /// <summary>Shopify answers, but without the order, as it does for an order that no longer exists.</summary>
    procedure SetOrderMissing(ShopifyOrderId: Text)
    begin
        _MockClient.AddResponse(_QueryNameTok, ShopifyOrderId, '{"data":{"order":null}}');
    end;

    /// <summary>The request about the order fails, as it does when Shopify cannot be reached.</summary>
    procedure SetRequestFails(ShopifyOrderId: Text)
    begin
        _MockClient.AddFailure(_QueryNameTok, ShopifyOrderId);
    end;

    /// <summary>How many times Shopify was asked whether an order is canceled.</summary>
    procedure RequestCount(): Integer
    begin
        exit(_MockClient.CountRequestsContaining(_QueryNameTok));
    end;

    /// <summary>How many times Shopify was asked about this order.</summary>
    procedure RequestCountFor(ShopifyOrderId: Text) MatchCount: Integer
    begin
        if _MockClient.GetRequestContaining(_QueryNameTok, 'gid://shopify/Order/' + ShopifyOrderId) = '' then
            exit(0);
        exit(_MockClient.CountRequestsContaining('gid://shopify/Order/' + ShopifyOrderId));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Order Cancel Check", 'OnBeforeGetGraphQLClient', '', false, false)]
    local procedure HandOutMockClient(var GraphQLClient: Interface "NPR Spfy IGraphQL Client"; var Handled: Boolean)
    begin
        GraphQLClient := _MockClient;
        Handled := true;
    end;
}
