#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248626 "NPR API Customer Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetCustomerNoSeries(RequestBody: JsonToken; var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetCustomerTemplate(RequestBody: JsonToken; var CustomerTemplateCode: Code[20]; var ConfigTemplateCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeModifyCustomer(RequestBody: JsonToken; var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertCustomer(RequestBody: JsonToken; var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertCustomer(RequestBody: JsonToken; var Customer: Record Customer)
    begin
    end;
}
#endif
