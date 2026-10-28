codeunit 85583 "NPR Ecom Doc Write Subscriber"
{
    // AddProperty initializes the shared object; opening an object in each writer would break merging.
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentCustomFieldsJsonObject, '', false, false)]
    local procedure HeaderWriterA(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        SalesDocumentCustomFieldsJsonObject.AddProperty('writerA', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentCustomFieldsJsonObject, '', false, false)]
    local procedure HeaderWriterB(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        SalesDocumentCustomFieldsJsonObject.AddProperty('writerB', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetPaymentDocumentDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure PaymentWriterA(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        PaymentDocumentDetailsCustomFieldsJsonObject.AddProperty('writerA', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetPaymentDocumentDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure PaymentWriterB(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        PaymentDocumentDetailsCustomFieldsJsonObject.AddProperty('writerB', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnCreateAddSalesLineDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure LineWriterA(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        SalesLineDetailsCustomFieldsJsonObject.AddProperty('writerA', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnCreateAddSalesLineDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure LineWriterB(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        SalesLineDetailsCustomFieldsJsonObject.AddProperty('writerB', true);
    end;
}
