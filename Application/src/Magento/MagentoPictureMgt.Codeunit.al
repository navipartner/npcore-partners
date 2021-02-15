codeunit 6151419 "NPR Magento Picture Mgt."
{
    var
        MagentoSetup: Record "NPR Magento Setup";

    procedure DragDropPicture(PictureName: Text; PictureType: Text; PictureDataUri: Text)
    var
        Handled: Boolean;
    begin
        OnDragDropPicture(PictureName, PictureType, PictureDataUri, Handled);
        if Handled then
            exit;

        SendMagentoPicture(PictureName, PictureType, PictureDataUri);
    end;

    local procedure SendMagentoPicture(PictureName: Text; PictureType: Text; PictureDataUri: Text)
    var
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        XmlDoc: XmlDocument;
    begin
        MagentoSetup.Get;
        MagentoSetup.TestField("Magento Url");
        Clear(XmlDoc);

        XmlDocument.ReadFrom('<?xml version="1.0" encoding="UTF-8"?>' +
                       '<images>' +
                         '<image image_name="' + PictureName + '" type="' + PictureType + '">' +
                           '<image_data>' +
                             '<![CDATA[' + PictureDataUri + ']]>' +
                           '</image_data>' +
                         '</image>' +
                       '</images>', XmlDoc);
        MagentoMgt.MagentoApiPost(MagentoSetup."Api Url", 'images', XmlDoc);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDragDropPicture(PictureName: Text; PictureType: Text; PictureDataUri: Text; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Picture Mgt.", 'OnDragDropPicture', '', true, true)]
    local procedure UploadMagentoPicture(PictureName: Text; PictureType: Text; PictureDataUri: Text; var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"DragDrop Picture", CurrCodeunitId(), 'UploadMagentoPicture') then
            exit;

        Handled := true;
        SendMagentoPicture(PictureName, PictureType, PictureDataUri);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Picture Mgt.");
    end;
}