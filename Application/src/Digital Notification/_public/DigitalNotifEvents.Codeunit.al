#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6151156 "NPR Dig. Notif. Events"
{
    Access = Public;

    /// <summary>
    /// Fires after the data provider has populated the example JSON shown in the Email template designer.
    /// Use it to add fields/lines so PTE templates can preview them.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterGenerateContentExample(var ContentJson: JsonObject)
    begin
    end;

    /// <summary>
    /// Fires after the example header fields have been added to the JSON (still no real document).
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterAddExampleHeaderFieldsToJson(var ContentJson: JsonObject)
    begin
    end;

    /// <summary>
    /// Fires after a single example line has been added to the example lines array.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterAddExampleLineJson(var LineJson: JsonObject)
    begin
    end;

    /// <summary>
    /// Fires after the data provider has built the JSON for an Ecom Sales Document notification entry.
    /// Records are passed by value (mutations to record fields don't flow back to the publisher).
    /// Subscribers should extend the JSON via ContentJson — do not call Modify/Insert/Delete on the source
    /// records (those would still persist to the database outside the publisher's control).
    /// Fires only for Ecom Sales Document notifications; Invoice / Credit Memo paths do not emit this event.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetEcomSalesDocContent(EcomSalesHeader: Record "NPR Ecom Sales Header"; var ContentJson: JsonObject)
    begin
    end;

    /// <summary>
    /// Fires after the Ecom Sales Header fields have been added to the JSON (right after manifest_url),
    /// before document_lines and payment_lines are appended.
    /// Records are passed by value (mutations to record fields don't flow back to the publisher).
    /// Subscribers should extend the JSON via ContentJson — do not call Modify/Insert/Delete on the source
    /// records (those would still persist to the database outside the publisher's control).
    /// Fires only for Ecom Sales Document notifications.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterAddEcomSalesDocHeaderFieldsToJson(EcomSalesHeader: Record "NPR Ecom Sales Header"; var ContentJson: JsonObject)
    begin
    end;

    /// <summary>
    /// Fires after a single Ecom Sales Line's JSON has been built, just before it's appended to the document_lines array.
    /// Records are passed by value (mutations to record fields don't flow back to the publisher).
    /// Subscribers should extend the line JSON via LineJson — do not call Modify/Insert/Delete on the source
    /// records (those would still persist to the database outside the publisher's control).
    /// Fires only for Ecom Sales Document notifications.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterAddEcomSalesDocLineJson(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var LineJson: JsonObject)
    begin
    end;

    /// <summary>
    /// Fires after a single example payment line has been added to the example payment lines array.
    /// Only emitted for Ecom Sales Document entries (Sales Invoice / Cr. Memo entries do not carry ecom payment lines).
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterAddExamplePaymentLineJson(var PaymentLineJson: JsonObject)
    begin
    end;

    /// <summary>
    /// Fires after a single Ecom Sales Payment Line's JSON has been built, just before it's appended to the payment_lines array.
    /// Records are passed by value (mutations to record fields don't flow back to the publisher).
    /// Subscribers should extend the payment-line JSON via PaymentLineJson — do not call Modify/Insert/Delete on the
    /// source records (those would still persist to the database outside the publisher's control).
    /// Fires only for Ecom Sales Document notifications.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnAfterAddEcomSalesDocPaymentLineJson(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentLineJson: JsonObject)
    begin
    end;
}
#endif
