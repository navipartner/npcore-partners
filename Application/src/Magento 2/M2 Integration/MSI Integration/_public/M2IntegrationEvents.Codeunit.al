codeunit 6151386 "NPR M2 Integration Events"
{
    internal procedure CallOnAfterUpdateMsiDataOnBeforeInsertTasks(var TempMSIRequest: Record "NPR M2 MSI Request" temporary)
    begin
        OnAfterUpdateMsiDataOnBeforeInsertTasks(TempMSIRequest);
    end;

    internal procedure CallOnBeforeFillTempMSIRequest(var TempMSIRequest: Record "NPR M2 MSI Request" temporary; VariantCodeSpecified: Boolean; MagentoSources: List of [Text[50]]; var IsHandled: Boolean)
    begin
        OnBeforeFillTempMSIRequest(TempMSIRequest, VariantCodeSpecified, MagentoSources, IsHandled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateMsiDataOnBeforeInsertTasks(var TempMSIRequest: Record "NPR M2 MSI Request" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillTempMSIRequest(var TempMSIRequest: Record "NPR M2 MSI Request" temporary; VariantCodeSpecified: Boolean; MagentoSources: List of [Text[50]]; var IsHandled: Boolean)
    begin
    end;
}