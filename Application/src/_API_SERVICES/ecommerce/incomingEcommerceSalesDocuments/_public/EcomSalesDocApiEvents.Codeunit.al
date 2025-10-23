#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248606 "NPR EcomSalesDocApiEvents"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessIncomingSalesHeaderInsertIncSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesLine(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncomingSalesLineBeforeInsert(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncomingSalesPaymentLineBeforeInsert(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeModifyIncomingSalesDocumentCommentBeforeModifyRecordLink(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var RecordLink: Record "Record Link");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentCustomFieldsJsonObject(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentCustomFieldsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Not used anymore', '2023-10-19')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentJsonObjectAfterSalesHeaderInformation(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Not used anymore', '2023-10-19')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentJsonObjectAfterSalesHeaderInformationBeforeEndObject(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentCreateResponseBeforeEndObject(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Not used anymore', '2023-10-19')]
    [IntegrationEvent(false, false)]
    internal procedure OnCreateAddSalesLineDetailsJsonObjectBeforeEndObject(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateAddSalesLineDetailsCustomFieldsJsonObject(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetPaymentDocumentDetailsCustomFieldsJsonObject(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;
}
#endif
