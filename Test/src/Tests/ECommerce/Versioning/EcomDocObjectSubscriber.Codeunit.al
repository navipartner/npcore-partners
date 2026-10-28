codeunit 85584 "NPR Ecom Doc Object Subscriber"
{
    // Bind alone; two subscribers opening a root object on the same builder would fail.
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentCustomFieldsJsonObject, '', false, false)]
    local procedure HeaderObjectWriter(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        SalesDocumentCustomFieldsJsonObject.StartObject()
                                           .AddProperty('objectWriter', true);
        SalesDocumentCustomFieldsJsonObject.EndObject();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetPaymentDocumentDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure PaymentObjectWriter(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        PaymentDocumentDetailsCustomFieldsJsonObject.StartObject()
                                                    .AddProperty('objectWriter', true);
        PaymentDocumentDetailsCustomFieldsJsonObject.EndObject();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnCreateAddSalesLineDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure LineObjectWriter(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        SalesLineDetailsCustomFieldsJsonObject.StartObject()
                                              .AddProperty('objectWriter', true);
        SalesLineDetailsCustomFieldsJsonObject.EndObject();
    end;
}
