#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248446 "NPR IncEcomSalesDocApiEvents"
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with NPR EcomSalesDocApiEvents';


    [Obsolete('Replaced by OnAfterDeserializeIncomingEcomSalesHeader in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesHeader(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [Obsolete('Replaced by OnBeforeProcessIncomingSalesHeaderInsertIncSalesHeader in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeProcessIncomingSalesHeaderInsertIncSalesHeader(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [Obsolete('Replaced by OnAfterDeserializeIncomingEcomSalesLine in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesLine(SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Inc Ecom Sales Line");
    begin
    end;

    [Obsolete('Replaced by OnBeforeInsertIncomingSalesLineBeforeInsert in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncomingSalesLineBeforeInsert(SalesLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncEcomSalesLine: Record "NPR Inc Ecom Sales Line");
    begin
    end;

    [Obsolete('Replaced by OnAfterDeserializeIncomingEcomSalesPaymentLine in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeIncomingEcomSalesPaymentLine(PaymentLineJsonToken: JsonToken; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line");
    begin
    end;

    [Obsolete('Replaced by OnBeforeInsertIncomingSalesPaymentLineBeforeInsert in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertIncomingSalesPaymentLineBeforeInsert(PaymentLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line");
    begin
    end;

    [Obsolete('Replaced by OnBeforeModifyIncomingSalesDocumentCommentBeforeModifyRecordLink in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeModifyIncomingSalesDocumentCommentBeforeModifyRecordLink(SalesLineJsonToken: JsonToken; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var RecordLink: Record "Record Link");
    begin
    end;


    [Obsolete('Replaced by OnGetSalesDocumentCustomFieldsJsonObject in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentCustomFieldsJsonObject(IncSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncSalesDocumentCustomFieldsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Not used anymore', '2023-10-19')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentJsonObjectAfterSalesHeaderInformation(IncSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Not used anymore', '2023-10-19')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentJsonObjectAfterSalesHeaderInformationBeforeEndObject(IncSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Replaced by OnGetSalesDocumentCreateResponseBeforeEndObject in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetSalesDocumentCreateResponseBeforeEndObject(IncSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Not used anymore', '2023-10-19')]
    [IntegrationEvent(false, false)]
    internal procedure OnCreateAddSalesLineDetailsJsonObjectBeforeEndObject(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Replaced by OnCreateAddSalesLineDetailsCustomFieldsJsonObject in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnCreateAddSalesLineDetailsCustomFieldsJsonObject(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;

    [Obsolete('Replaced by OnGetPaymentDocumentDetailsCustomFieldsJsonObject in codeunit NPR EcomSalesDocApiEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetPaymentDocumentDetailsCustomFieldsJsonObject(IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line"; var PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder");
    begin
    end;
}
#endif
