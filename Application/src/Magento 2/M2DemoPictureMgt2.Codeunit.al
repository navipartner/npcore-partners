codeunit 6014446 "NPR M2 Demo Picture Mgt2"
{
    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Magento returned the following Error:\\';

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151411, 'OnGetMagentoUrl', '', true, true)]
    local procedure GetM2DemoPictureUrl(var Sender: Record "NPR Magento Picture"; var MagentoUrl: Text; var Handled: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Magento Picture Url", CurrCodeunitId(), 'GetM2DemoPictureUrl') then
            exit;

        Handled := true;

        MagentoUrl := 'https://' + LowerCase(CompanyName) + '.demo.npecommerce.dk/pub/demos/';
        MagentoUrl += LowerCase(CompanyName) + '_media/catalog/product/api/' + Sender.Name;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR M2 Demo Picture Mgt2");
    end;
}

