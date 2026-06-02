#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151028 "NPR Entria Webhook Subscr."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnItemModified(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        EntriaIntegrWebhooks: Codeunit "NPR Entria Integr. Webhooks";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        if not Rec."NPR Entria Product" then
            exit;
        if not Rec.AreFieldsLoaded("Unit Price") then
            exit;
        if not xRec.AreFieldsLoaded("Unit Price") then
            exit;
        if Rec."Unit Price" = xRec."Unit Price" then
            exit;
        if not EntriaIntegrationMgt.HasEnabledStore() then
            exit;

        EntriaIntegrWebhooks.OnItemUnitPriceChanged(Rec.SystemId, Rec."No.", Rec."Unit Price");
    end;
}
#endif
