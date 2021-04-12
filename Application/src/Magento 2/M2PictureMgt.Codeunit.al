codeunit 6151462 "NPR M2 Picture Mgt."
{
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
        MagentoSetup: Record "NPR Magento Setup";
        XmlDoc: XmlDocument;
    begin
        MagentoSetup.Get();
        MagentoSetup.TestField("Api Url");
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="UTF-8"?>' +
                       '<images>' +
                         '<image image_name="' + PictureName + '" type="' + PictureType + '">' +
                           '<image_data>' +
                             '<![CDATA[' + PictureDataUri + ']]>' +
                           '</image_data>' +
                         '</image>' +
                       '</images>', XmlDoc);

        MagentoApiPost(MagentoSetup."Api Url", 'images', XmlDoc);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDragDropPicture(PictureName: Text; PictureType: Text; PictureDataUri: Text; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Picture", 'OnGetMagentoUrl', '', true, true)]
    local procedure GetM2PictureUrl(var Sender: Record "NPR Magento Picture"; var MagentoUrl: Text; var Handled: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Magento Picture Url", CurrCodeunitId(), 'GetM2PictureUrl') then
            exit;

        Handled := true;
        MagentoUrl := '';
        if Sender.Name = '' then
            exit;

        MagentoSetup.Get();
        MagentoUrl := MagentoSetup."Magento Url" + 'pub/media/catalog/' + GetMagentoType(Sender) + '/api/' + Sender.Name;
    end;

    local procedure GetMagentoType(MagentoPicture: Record "NPR Magento Picture"): Text
    begin
        case MagentoPicture.Type of
            MagentoPicture.Type::Item:
                begin
                    exit('product');
                end;
            MagentoPicture.Type::Brand:
                begin
                    exit('brand');
                end;
            MagentoPicture.Type::"Item Group":
                begin
                    exit('category');
                end;
            MagentoPicture.Type::Customer:
                begin
                    exit('customer');
                end;
        end;

        exit('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Picture Mgt.", 'OnDragDropPicture', '', true, true)]
    local procedure UploadM2Picture(PictureName: Text; PictureType: Text; PictureDataUri: Text; var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"DragDrop Picture", CurrCodeunitId(), 'UploadM2Picture') then
            exit;

        Handled := true;
        SendMagentoPicture(PictureName, PictureType, PictureDataUri);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR M2 Picture Mgt.");
    end;

    procedure MagentoApiPost(MagentoApiUrl: Text; Method: Text; var XmlDoc: XmlDocument) Result: Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        Client: HttpClient;
        Response: Text;
    begin
        if MagentoApiUrl = '' then
            exit(false);

        HttpWebRequest.SetRequestUri(MagentoApiUrl + Method);
        HttpWebRequest.Method('POST');
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'naviconnect/xml');
        HttpWebRequest.Content(Content);

        HttpWebRequest.GetHeaders(Headers);
        Headers.Add('Accept', 'naviconnect/xml');

        MagentoSetup.Get();
        Headers.Add('Authorization', MagentoSetup."Api Authorization");

        Client.Timeout := 300000;
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);
        if not HttpWebResponse.IsSuccessStatusCode() then
            Error(StrSubstNo('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response));

        exit(XmlDocument.ReadFrom(Response, XmlDoc));
    end;
}