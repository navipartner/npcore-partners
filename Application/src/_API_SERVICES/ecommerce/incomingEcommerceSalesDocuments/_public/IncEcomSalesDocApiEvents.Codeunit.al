#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248446 "NPR IncEcomSalesDocApiEvents"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesHeader(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessIncomingSalesHeaderInsertIncSalesHeader(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesLine(SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Inc Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncomingSalesLineBeforeInsert(SalesLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncEcomSalesLine: Record "NPR Inc Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesPaymentLine(PaymentLineJsonToken: JsonToken; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncomingSalesPaymentLineBeforeInsert(PaymentLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeModifyIncomingSalesDocumentCommentBeforeModifyRecordLink(SalesLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var RecordLink: Record "Record Link");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentJsonObjectAfterSalesHeaderInformation(IncSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentJsonObjectAfterSalesHeaderInformationBeforeEndObject(IncSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentCreateResponseBeforeEndObject(IncSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateAddSalesLineDetailsJsonObjectBeforeEndObject(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;
}
#endif
