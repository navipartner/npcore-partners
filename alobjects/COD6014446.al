codeunit 6014446 "M2 Demo Picture Mgt2"
{
    // NPR5.48/TS /20180605  CASE 3331723 Temp Object Created


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Magento returned the following Error:\\';

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151411, 'OnGetMagentoUrl', '', true, true)]
    local procedure GetM2DemoPictureUrl(var Sender: Record "Magento Picture"; var MagentoUrl: Text; var Handled: Boolean)
    var
        MagentoSetup: Record "Magento Setup";
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
        String: DotNet String;
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Magento Picture Url", CurrCodeunitId(), 'GetM2DemoPictureUrl') then
            exit;

        Handled := true;

        MagentoUrl := 'https://' + LowerCase(CompanyName) + '.demo.npecommerce.dk/pub/demos/';
        MagentoUrl += LowerCase(CompanyName) + '_media/catalog/product/api/' + Sender.Name;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"M2 Demo Picture Mgt2");
    end;
}

