codeunit 88015 "NPR BCPT Subscr. Adyen Mock"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Subscr.Pmt.: Adyen", 'OnBeforeInvokeAPI', '', false, false)]
    local procedure BuildMockAdyenResponse(var Request: Text; var Response: Text; var Handled: Boolean)
    var
        JsonWriter: Codeunit "Json Text Reader/Writer";
        LibraryRandom: Codeunit "NPR BPCT Library - Random";
        JsonRequest: JsonObject;
        JsonPaymentMethod: JsonObject;
        JsonAmount: JsonObject;
        JsonToken: JsonToken;
        StoredPaymentMethodId: Text;
        ShopperReference: Text;
        Currency: Text;
        Value: Text;
        MerchantReference: Text;
    begin
        if not JsonRequest.ReadFrom(Request) then
            exit;

        if JsonRequest.Get('shopperReference', JsonToken) then
            ShopperReference := JsonToken.AsValue().AsText();

        if JsonRequest.Get('merchantReference', JsonToken) then
            MerchantReference := JsonToken.AsValue().AsText();

        if JsonRequest.Get('amount', JsonToken) then begin
            JsonAmount := JsonToken.AsObject();
            JsonAmount.Get('currency', JsonToken);
            Currency := JsonToken.AsValue().AsText();
            JsonAmount.Get('value', JsonToken);
            Value := JsonToken.AsValue().AsText();
        end;

        if JsonRequest.Get('paymentMethod', JsonToken) then begin
            JsonPaymentMethod := JsonToken.AsObject();
            JsonPaymentMethod.Get('storedPaymentMethodId', JsonToken);
            StoredPaymentMethodId := JsonToken.AsValue().AsText();
        end;

        // Begin building response
        JsonWriter.WriteStartObject('');
        JsonWriter.WriteStringProperty('pspReference', LibraryRandom.RandText(16));
        JsonWriter.WriteStringProperty('resultCode', 'Authorised');

        // amount
        JsonWriter.WriteStartObject('amount');
        JsonWriter.WriteStringProperty('currency', Currency);
        JsonWriter.WriteStringProperty('value', Value);
        JsonWriter.WriteEndObject();

        JsonWriter.WriteStringProperty('merchantReference', MerchantReference);

        // paymentMethod
        JsonWriter.WriteStartObject('paymentMethod');
        JsonWriter.WriteStringProperty('brand', 'mc');
        JsonWriter.WriteStringProperty('type', 'scheme');
        JsonWriter.WriteEndObject();

        // additionalData
        JsonWriter.WriteStartObject('additionalData');
        JsonWriter.WriteStringProperty('recurring.recurringDetailReference', StoredPaymentMethodId);
        JsonWriter.WriteStringProperty('recurring.shopperReference', ShopperReference);
        JsonWriter.WriteStringProperty('resultCode', 'Authorised');
        JsonWriter.WriteStringProperty('avsResult', '5 No AVS data provided');
        JsonWriter.WriteStringProperty('cvcResult', '3 Not checked');
        JsonWriter.WriteStringProperty('authCode', LibraryRandom.RandInt(6));
        JsonWriter.WriteStringProperty('cardSummary', LibraryRandom.RandInt(4));
        JsonWriter.WriteStringProperty('issuerCountry', 'BE');
        JsonWriter.WriteStringProperty('cardHolderName', LibraryRandom.RandText(20));
        JsonWriter.WriteStringProperty('alias', LibraryRandom.RandInt(10));
        JsonWriter.WriteStringProperty('tokenization.storedPaymentMethodId', StoredPaymentMethodId);
        JsonWriter.WriteStringProperty('recurringProcessingModel', 'Subscription');
        JsonWriter.WriteStringProperty('paymentMethod', 'mc');
        JsonWriter.WriteStringProperty('cardPaymentMethod', 'mc');
        JsonWriter.WriteEndObject();

        // fraudResult
        JsonWriter.WriteStartObject('fraudResult');
        JsonWriter.WriteStringProperty('accountScore', -100);

        JsonWriter.WriteStartArray('results');
        JsonWriter.WriteStartObject('');
        JsonWriter.WriteStringProperty('accountScore', -100);
        JsonWriter.WriteStringProperty('checkId', 82);
        JsonWriter.WriteStringProperty('name', 'CustomFieldCheck');
        JsonWriter.WriteEndObject();
        JsonWriter.WriteEndArray();
        JsonWriter.WriteEndObject(); // fraudResult

        JsonWriter.WriteEndObject(); // root

        Response := JsonWriter.GetJsonAsText();
        Handled := true;
    end;
}