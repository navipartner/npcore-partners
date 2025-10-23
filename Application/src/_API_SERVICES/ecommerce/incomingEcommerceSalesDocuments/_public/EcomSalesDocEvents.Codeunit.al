#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248603 "NPR Ecom Sales Doc Events"
{
    Access = Public;


    [IntegrationEvent(false, false)]
    internal procedure OnSetSalesDocCreationStatusCreatedBeforeModifyRecord(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ModifyRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetSalesDocCreationStatusErrorBeforeModifyRecord(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ErrorMessage: Text[500]; UpdateStatus: Boolean; ModifyRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetSalesDocStatusPendingBeforeModifyRecord(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ModifyRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHandleResponseBeforeModifyRecord(Success: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header"; UpdateRetryCount: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetItemNoAndVariantNoFromExternalNo(EcomSalesLine: Record "NPR Ecom Sales Line"; var ItemNo: Code[20]; var VariantCode: Code[10]; var Found: Boolean; var Handled: Boolean);
    begin
    end;
}
#endif
