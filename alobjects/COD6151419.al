codeunit 6151419 "Magento Picture Mgt."
{
    // MAG2.05/MHA /20170714  CASE 283777 Object created
    // MAG2.07/MHA /20170830  CASE 286943 Moved IsSubscriber() to CU6151401 "Magento Setup Mgt."


    trigger OnRun()
    begin
    end;

    var
        MagentoSetup: Record "Magento Setup";

    procedure DragDropPicture(PictureName: Text;PictureType: Text;PictureDataUri: Text)
    var
        Handled: Boolean;
    begin
        OnDragDropPicture(PictureName,PictureType,PictureDataUri,Handled);
        if Handled then
          exit;

        SendMagentoPicture(PictureName,PictureType,PictureDataUri);
    end;

    local procedure SendMagentoPicture(PictureName: Text;PictureType: Text;PictureDataUri: Text)
    var
        MagentoMgt: Codeunit "Magento Mgt.";
        XmlDoc: DotNet XmlDocument;
    begin
        MagentoSetup.Get;
        MagentoSetup.TestField("Magento Url");
        if not IsNull(XmlDoc) then
          Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="UTF-8"?>' +
                       '<images>' +
                         '<image image_name="' + PictureName + '" type="' + PictureType + '">' +
                           '<image_data>' +
                             '<![CDATA[' + PictureDataUri + ']]>' +
                           '</image_data>' +
                         '</image>' +
                       '</images>');
        MagentoMgt.MagentoApiPost(MagentoSetup."Api Url",'images',XmlDoc);
    end;

    local procedure "--- Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDragDropPicture(PictureName: Text;PictureType: Text;PictureDataUri: Text;var Handled: Boolean)
    begin
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151419, 'OnDragDropPicture', '', true, true)]
    local procedure UploadMagentoPicture(PictureName: Text;PictureType: Text;PictureDataUri: Text;var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.07 [286943]
        //IF NOT IsSubscriber(CurrCodeunitId(),'UploadMagentoPicture') THEN
        //  EXIT;
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"DragDrop Picture",CurrCodeunitId(),'UploadMagentoPicture') then
          exit;
        //+MAG2.07 [286943]

        Handled := true;
        SendMagentoPicture(PictureName,PictureType,PictureDataUri);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Magento Picture Mgt.");
    end;
}

