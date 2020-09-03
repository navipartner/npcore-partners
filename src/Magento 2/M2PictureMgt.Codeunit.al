codeunit 6151462 "NPR M2 Picture Mgt."
{
    // MAG2.08/MHA /20171016  CASE 292926 Object created - M2 Integration
    // MAG2.09/TS  /20171113  CASE 296169 Magento Urls can be https
    // MAG2.22/MHA /20190705  CASE 361164 Updated Exception Message parsing in MagentoApiPost()
    // MAG2.22/MHA /20190716  CASE 361234 Added function GetMagentoType()


    trigger OnRun()
    begin
    end;

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
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
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
        MagentoApiPost(MagentoSetup."Api Url", 'images', XmlDoc);
    end;

    local procedure "--- Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDragDropPicture(PictureName: Text; PictureType: Text; PictureDataUri: Text; var Handled: Boolean)
    begin
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151411, 'OnGetMagentoUrl', '', true, true)]
    local procedure GetM2PictureUrl(var Sender: Record "NPR Magento Picture"; var MagentoUrl: Text; var Handled: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
        String: DotNet NPRNetString;
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Magento Picture Url", CurrCodeunitId(), 'GetM2PictureUrl') then
            exit;

        Handled := true;
        MagentoUrl := '';
        if Sender.Name = '' then
            exit;

        MagentoSetup.Get;
        //-MAG2.22 [361234]
        MagentoUrl := MagentoSetup."Magento Url" + 'pub/media/catalog/' + GetMagentoType(Sender) + '/api/' + Sender.Name;
        //+MAG2.22 [361234]
    end;

    local procedure GetMagentoType(MagentoPicture: Record "NPR Magento Picture"): Text
    begin
        //-MAG2.22 [361234]
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
        //+MAG2.22 [361234]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151419, 'OnDragDropPicture', '', true, true)]
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

    local procedure "--- Aux"()
    begin
    end;

    procedure MagentoApiPost(MagentoApiUrl: Text; Method: Text; var XmlDoc: DotNet "NPRNetXmlDocument") Result: Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        WebException: DotNet NPRNetWebException;
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
        HttpWebRequest.Headers.Add('Authorization', MagentoSetup."Api Authorization");

        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then begin
            //-MAG2.22 [361164]
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(CopyStr(ErrorMessage, 1, 1000));
            //+MAG2.22 [361164]
        end;

        exit(NpXmlDomMgt.TryLoadXml(Response, XmlDoc));
    end;
}

