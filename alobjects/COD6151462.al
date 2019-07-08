codeunit 6151462 "M2 Picture Mgt."
{
    // MAG2.08/MHA /20171016  CASE 292926 Object created - M2 Integration
    // MAG2.09/TS  /20171113  CASE 296169 Magento Urls can be https


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Magento returned the following Error:\\';

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
        MagentoSetup: Record "Magento Setup";
        MagentoMgt: Codeunit "Magento Mgt.";
        XmlDoc: DotNet XmlDocument;
    begin
        MagentoSetup.Get;
        MagentoSetup.TestField("Api Url");
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
        MagentoApiPost(MagentoSetup."Api Url",'images',XmlDoc);
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

    [EventSubscriber(ObjectType::Table, 6151411, 'OnGetMagentoUrl', '', true, true)]
    local procedure GetM2PictureUrl(var Sender: Record "Magento Picture";var MagentoUrl: Text;var Handled: Boolean)
    var
        MagentoSetup: Record "Magento Setup";
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
        String: DotNet String;
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Magento Picture Url",CurrCodeunitId(),'GetM2PictureUrl') then
          exit;

        Handled := true;
        MagentoUrl := '';
        if Sender.Name = '' then
          exit;

        MagentoSetup.Get;
        //-MAG2.09 [296169]
        //String := MagentoSetup."Magento Url" + 'pub/media/catalog/' + Sender.GetMagentoType() + '/api/' + Sender.Name;
        //MagentoUrl := String.Replace('https','http');
        MagentoUrl := MagentoSetup."Magento Url" + 'pub/media/catalog/' + Sender.GetMagentoType() + '/api/' + Sender.Name;
        //+MAG2.09 [296169]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151419, 'OnDragDropPicture', '', true, true)]
    local procedure UploadM2Picture(PictureName: Text;PictureType: Text;PictureDataUri: Text;var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"DragDrop Picture",CurrCodeunitId(),'UploadM2Picture') then
          exit;

        Handled := true;
        SendMagentoPicture(PictureName,PictureType,PictureDataUri);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"M2 Picture Mgt.");
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure MagentoApiPost(MagentoApiUrl: Text;Method: Text;var XmlDoc: DotNet XmlDocument) Result: Boolean
    var
        MagentoSetup: Record "Magento Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        WebException: DotNet WebException;
        ErrorMessage: Text;
        Response: Text;
    begin
        if MagentoApiUrl = '' then
          exit(false);

        if not IsNull(HttpWebRequest) then
          Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(MagentoApiUrl + Method);
        HttpWebRequest.Timeout := 1000 * 60 * 5;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'naviconnect/xml';
        HttpWebRequest.Accept('naviconnect/xml');

        MagentoSetup.Get;
        HttpWebRequest.Headers.Add('Authorization',MagentoSetup."Api Authorization");

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
          if ErrorMessage = '' then
            ErrorMessage := NpXmlDomMgt.GetWebExceptionInnerMessage(WebException);
          if ErrorMessage = '' then
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          ErrorMessage := Text000 + ErrorMessage;
          Error(CopyStr(ErrorMessage,1,1000));
        end;

        exit(NpXmlDomMgt.TryLoadXml(Response,XmlDoc));
    end;
}

