codeunit 6150689 "NPR Print and Admit Public"
{
    [IntegrationEvent(false, false)]
    internal procedure OnGetDataForReference(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeHandleBuffer(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
    end;
}
