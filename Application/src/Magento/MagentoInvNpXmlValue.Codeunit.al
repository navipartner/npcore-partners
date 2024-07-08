codeunit 6151408 "NPR Magento Inv. NpXml Value"
{
    Access = Internal;
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef: RecordRef;
        OutStr: OutStream;
        CustomValue: Text;
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");

        if not RecRef.Find() then
            exit;

        SetRecInfo(RecRef, ItemNo, VariantCode);
        RecRef.Close();
        Clear(RecRef);

        CustomValue := Format(CalcMagentoInventory(ItemNo, VariantCode), 0, 9);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;


    local procedure CalcMagentoInventory(ItemNo: Code[20]; VariantCode: Code[10]) Inventory: Decimal
    var
        MagentoInventoryCompany: Record "NPR Magento Inv. Company";
        MagentoSetup: Record "NPR Magento Setup";
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
    begin
        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit(0);

        if not MagentoSetup."Intercompany Inventory Enabled" then begin
            Inventory := MagentoItemMgt.GetStockQty(ItemNo, VariantCode);

            exit(Inventory);
        end;

        Inventory := 0;
        if not MagentoInventoryCompany.FindSet() then
            exit(0);

        repeat
            Inventory += CalcMagentoInventoryCompany(MagentoInventoryCompany, ItemNo, VariantCode);
        until MagentoInventoryCompany.Next() = 0;
    end;

    procedure CalcMagentoInventoryCompany(MagentoInventoryCompany: Record "NPR Magento Inv. Company"; ItemNo: Code[20]; VariantCode: Code[10]) Inventory: Decimal
    var
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStr: InStream;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        [NonDebuggable]
        HeadersReq: HttpHeaders;
        XmlDoc: XmlDocument;
        Node: XmlNode;
        XmlNodeList: XmlNodeList;
        ItemAttribute: XmlAttribute;
        VariantAttribute: XmlAttribute;
        Response: Text;
        XmlTxt: Text;
        i: Integer;
    begin
        if MagentoInventoryCompany."Company Name" = CompanyName then begin
            Inventory := MagentoItemMgt.GetStockQty3(ItemNo, VariantCode, MagentoInventoryCompany);
            exit(Inventory);
        end;
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);

        XmlTxt := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                       '  <soapenv:Header />' +
                       '  <soapenv:Body>' +
                       '    <GetItemInventory xmlns="urn:microsoft-dynamics-schemas/codeunit/magento_services">' +
                       '       <itemFilter />' +
                       '       <variantFilter />' +
                       '       <locationFilter />' +
                       '       <items />' +
                       '    </GetItemInventory>' +
                       '  </soapenv:Body>' +
                       '</soapenv:Envelope>';
        XmlDocument.ReadFrom(XmlTxt, XmlDoc);

        XmlDoc.SelectSingleNode('.//*[local-name()="itemFilter"]', Node);
        Node.AsXmlElement().Add(ItemNo);
        XmlDoc.SelectSingleNode('.//*[local-name()="variantFilter"]', Node);
        Node.AsXmlElement().Add(VariantCode);
        XmlDoc.SelectSingleNode('.//*[local-name()="locationFilter"]', Node);
        Node.AsXmlElement().Add(MagentoInventoryCompany."Location Filter");

        XmlDoc.WriteTo(OutStream);
        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);
        Content.WriteFrom(InStr);

        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');
        Headers.Add('SOAPAction', 'GetItemInventory');

        HttpWebRequest.GetHeaders(HeadersReq);

        MagentoInventoryCompany.SetRequestHeadersAuthorization(HeadersReq);

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(MagentoInventoryCompany."Api Url");
        HttpWebRequest.Method := 'POST';

        Client.Timeout(5000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        Clear(XmlDoc);
        HttpWebResponse.Content.ReadAs(Response);
        XmlDocument.ReadFrom(Response, XmlDoc);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        XmlDoc.SelectNodes('.//*[local-name()="item"]', XmlNodeList);

        foreach Node in XmlNodeList do begin
            XmlNodeList.Get(i, Node);
            if Node.AsXmlElement().Attributes().Get('item_no', ItemAttribute) then
                if Node.AsXmlElement().Attributes().Get('variant_code', VariantAttribute) then
                    if (ItemAttribute.Value = ItemNo) and (VariantAttribute.Value = VariantCode) then begin
                        Evaluate(Inventory, Node.AsXmlElement().InnerText, 9);
                        exit(Inventory);
                    end;
        end;
        exit(0);
    end;

    local procedure SetRecInfo(var RecRef: RecordRef; var ItemNo: Code[20]; var VariantCode: Code[10]): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    ItemNo := Item."No.";
                    VariantCode := '';
                    exit(true);
                end;
            DATABASE::"Item Variant":
                begin
                    RecRef.SetTable(ItemVariant);
                    ItemNo := ItemVariant."Item No.";
                    VariantCode := ItemVariant.Code;
                    exit(true);
                end;
        end;

        exit(false);
    end;
}
