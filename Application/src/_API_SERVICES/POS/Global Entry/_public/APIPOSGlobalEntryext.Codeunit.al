#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248260 "NPR API POS Global Entry Ext"
{
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeApplyExtensionFields(var RecRef: RecordRef; var ExtensionData: Dictionary of [Integer, JsonToken])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure SetPOSEntryExtensionData(POSEntry: Record "NPR POS Entry"; var ExtensionFieldsData: Dictionary of [Integer, Text])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure SetPOSEntrySalesLineExtensionData(POSSalesLine: Record "NPR POS Entry Sales Line"; var ExtensionFieldsData: Dictionary of [Integer, Text])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure SetPOSEntryPaymentLineExtensionData(POSPaymentLine: Record "NPR POS Entry Payment Line"; var ExtensionFieldsData: Dictionary of [Integer, Text])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure SetPOSInfoPOSEntryExtensionData(POSInfoPOSEntry: Record "NPR POS Info POS Entry"; var ExtensionFieldsData: Dictionary of [Integer, Text])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInitRequestBody(POSEntry: Record "NPR POS Entry"; var JsonRequest: JsonObject)
    begin
    end;

}
#endif