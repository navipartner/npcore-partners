//One DotNet variable left. Can be easy removed after upgrade to BC 17.2 Described in function CalcDistance (after that delete this comment)
codeunit 6151204 "NPR NpCs Store Mgt."
{
    procedure InitLocalStore(var NpCsStore: Record "NPR NpCs Store")
    begin
        if NpCsStore."Company Name" = '' then
            NpCsStore."Company Name" := CompanyName;

        if NpCsStore."Service Url" = '' then begin
            InitCollectService();
            NpCsStore."Service Url" := GetCollectWSUrl(CompanyName);
        end;
    end;

    local procedure InitCollectService()
    var
        WebService: Record "Web Service";
        PrevRec: Text;
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        if not WebService.Get(WebService."Object Type"::Codeunit, 'collect_in_store_service') then begin
            WebService.Init();
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Object ID" := CollectWsCodeunitId();
            WebService."Service Name" := 'collect_in_store_service';
            WebService.Published := true;
            WebService.Insert(true);
        end;

        PrevRec := Format(WebService);
        WebService."Object ID" := CollectWsCodeunitId();
        WebService.Published := true;
        if PrevRec <> Format(WebService) then
            WebService.Modify(true);
    end;

    procedure UpdateContactInfo(var NpCsStore: Record "NPR NpCs Store")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: Codeunit "XML DOM Management";
        Document: XmlDocument;
        Node: XmlNode;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Request: HttpRequestMessage;
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        ContentText: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        PrevRec: Text;
    begin
        ContentText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"  >' +
            '<soapenv:Body>' +
              '<GetCollectStores xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpCsStore) + '">' +
                '<stores>' +
                  '<store store_code="' + NpCsStore.Code + '" xmlns="urn:microsoft-dynamics-nav/xmlports/collect_store">' +
                    '<location_code>' + NpCsStore."Location Code" + '</location_code>' +
                  '</store>' +
                '</stores>' +
              '</GetCollectStores>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        Request.Method('POST');
        Request.SetRequestUri(NpCsStore."Service Url");

        RequestContent.WriteFrom(ContentText);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', 'GetCollectStores');
        ContentHeader := Client.DefaultRequestHeaders();

        Client.UseWindowsAuthentication(NpCsStore."Service Username", NpCsStore."Service Password");
        Request.Content := RequestContent;
        Client.Send(Request, Response);

        if not Response.IsSuccessStatusCode then begin
            ErrorMessage := Response.ReasonPhrase;
            if XmlDocument.ReadFrom(ErrorMessage, Document) then begin
                if NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node) then
                    ErrorMessage := Node.AsXmlElement().InnerText();
            end;
            Error(ErrorMessage);
        end;

        Response.Content.ReadAs(ResponseText);
        if not XmlDocument.ReadFrom(ResponseText, Document) then
            Error(ResponseText);

        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        XmlDocument.ReadFrom(ResponseText, Document);

        Document.SelectSingleNode('//Body/GetCollectStores_Result/stores/store[@store_code = "' + NpCsStore.Code + '"]', Node);

        PrevRec := Format(NpCsStore);

        NpCsStore."Contact Name" := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_name', MaxStrLen(NpCsStore."Contact Name"), false);
        NpCsStore."Contact Name 2" := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_name_2', MaxStrLen(NpCsStore."Contact Name 2"), false);
        NpCsStore."Contact Address" := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_address', MaxStrLen(NpCsStore."Contact Address"), false);
        NpCsStore."Contact Address 2" := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_address_2', MaxStrLen(NpCsStore."Contact Address 2"), false);
        NpCsStore."Contact Post Code" := NpXmlDomMgt.GetElementCode(Node.AsXmlElement(), 'contact_post_code', MaxStrLen(NpCsStore."Contact Post Code"), false);
        NpCsStore."Contact Country/Region Code" := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_country_code', MaxStrLen(NpCsStore."Contact Country/Region Code"), false);
        NpCsStore."Contact County" := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_county', MaxStrLen(NpCsStore."Contact County"), false);
        NpCsStore."Contact Phone No." := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_phone_no', MaxStrLen(NpCsStore."Contact Phone No."), false);
        NpCsStore."Contact E-mail" := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'contact_email', MaxStrLen(NpCsStore."Contact E-mail"), false);

        if PrevRec <> Format(NpCsStore) then
            NpCsStore.Modify(true);
    end;

    [TryFunction]
    procedure TryGetCollectService(NpCsStore: Record "NPR NpCs Store")
    var
        XmlDomManagement: codeunit "XML DOM Management";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        ErrorMessage: Text;
    begin
        NpCsStore.TestField("Service Url");

        Client.UseWindowsAuthentication(NpCsStore."Service Username", NpCsStore."Service Password");
        if Client.Get(NpCsStore."Service Url", Response) then
            exit;

        ErrorMessage := Response.ReasonPhrase;
        ErrorMessage := XmlDomManagement.RemoveNamespaces(ErrorMessage);
        if XmlDocument.ReadFrom(ErrorMessage, Document) then
            if Document.SelectSingleNode('//faultstring', Node) then
                Error(Node.AsXmlElement().InnerText());

        Error(ErrorMessage);
    end;

    procedure InitStoresWithDistance(FromNpCsStore: Record "NPR NpCs Store"; var TempNpCsStore: Record "NPR NpCs Store" temporary)
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        NpCsStore.SetFilter(Code, '<>%1', FromNpCsStore.Code);
        if not NpCsStore.FindSet() then
            exit;

        repeat
            TempNpCsStore.Init();
            TempNpCsStore := NpCsStore;
            TempNpCsStore."Distance (km)" := CalcDistance(FromNpCsStore, TempNpCsStore);
            TempNpCsStore.Insert();
        until NpCsStore.Next() = 0;
    end;

    procedure GetCollectWSUrl(ServiceCompanyName: Text) Url: Text
    begin
        exit(GetUrl(CLIENTTYPE::SOAP, ServiceCompanyName, OBJECTTYPE::Codeunit, CollectWsCodeunitId()));
    end;

    procedure GetServiceName(NpCsStore: Record "NPR NpCs Store") ServiceName: Text
    var
        Position: Integer;
    begin
        ServiceName := NpCsStore."Service Url";
        Position := StrPos(ServiceName, '?');
        if Position > 0 then
            ServiceName := DelStr(ServiceName, Position);

        if ServiceName = '' then
            exit('');

        if ServiceName[StrLen(ServiceName)] = '/' then
            ServiceName := DelStr(ServiceName, StrLen(ServiceName));

        Position := StrPos(ServiceName, '/');
        while Position > 0 do begin
            ServiceName := DelStr(ServiceName, 1, Position);
            Position := StrPos(ServiceName, '/');
        end;

        exit(ServiceName);
    end;

    procedure FindLocalStore(var NpCsStore: Record "NPR NpCs Store"): Boolean
    var
        LastCode: Text;
    begin
        Clear(NpCsStore);
        NpCsStore.SetRange("Local Store", true);
        NpCsStore.FindLast();
        LastCode := NpCsStore.Code;
        NpCsStore.FindFirst();

        if NpCsStore.Code = LastCode then
            exit(true);

        if PAGE.RunModal(0, NpCsStore) = ACTION::LookupOK then
            exit(true);

        exit(false);
    end;

    procedure CalcDistance(FromNpCsStore: Record "NPR NpCs Store"; ToNpCsStore: Record "NPR NpCs Store") Distance: Decimal
    var
        Math: Codeunit Math;
        Lat1,Lat2,Lon1,Lon2: Decimal;
    begin
        if not Evaluate(Lat1, FromNpCsStore."Geolocation Latitude", 9) then
            if Evaluate(Lat1, FromNpCsStore."Geolocation Latitude") then;
        if not Evaluate(Lon1, FromNpCsStore."Geolocation Longitude", 9) then
            if Evaluate(Lon1, FromNpCsStore."Geolocation Longitude") then;
        if not Evaluate(Lat2, ToNpCsStore."Geolocation Latitude", 9) then
            if Evaluate(Lat2, ToNpCsStore."Geolocation Latitude") then;
        if not Evaluate(Lon2, ToNpCsStore."Geolocation Longitude", 9) then
            if Evaluate(Lon2, ToNpCsStore."Geolocation Longitude") then;

        Lon1 *= Math.Pi() / 180;
        Lat1 *= Math.Pi() / 180;
        Lon2 *= Math.Pi() / 180;
        Lat2 *= Math.Pi() / 180;

        Distance := Math.Acos(Math.Sin(Lat1) * Math.Sin(Lat2) + Math.Cos(Lat1) * Math.Cos(Lat2) * Math.Cos(Lon2 - Lon1)) * 6371;
        exit(Distance);
    end;

    procedure SetBufferInventory(var NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary)
    var
        TempNpCsStore: Record "NPR NpCs Store" temporary;
    begin
        if not FindBufferStores(NpCsStoreInventoryBuffer, TempNpCsStore) then
            exit;

        TempNpCsStore.FindSet();
        repeat
            Clear(NpCsStoreInventoryBuffer);
            SetBufferInventoryStore(TempNpCsStore.Code, NpCsStoreInventoryBuffer);
        until TempNpCsStore.Next() = 0;

        Clear(NpCsStoreInventoryBuffer);
    end;

    local procedure SetBufferInventoryStore(StoreCode: Code[20]; var NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary)
    var
        NpCsStore: Record "NPR NpCs Store";
        XmlDomManagement: Codeunit "XML DOM Management";
        Document: XmlDocument;
        Node: XmlNode;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Response: HttpResponseMessage;
        ReqBody: Text;
        ResponseText: Text;
    begin
        if not NpCsStore.Get(StoreCode) then
            exit;
        if NpCsStore."Service Url" = '' then
            exit;

        NpCsStoreInventoryBuffer.SetRange("Store Code", NpCsStore.Code);
        if NpCsStoreInventoryBuffer.IsEmpty then
            exit;

        ReqBody :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:inv="urn:microsoft-dynamics-nav/xmlports/collect_local_inventory">' +
            '<soapenv:Body>' +
              '<GetLocalInventory xmlns="urn:microsoft-dynamics-schemas/codeunit/collect_in_store_service">' +
                '<local_inventory>' +
                  '<inv:location_filter>' + NpCsStore."Location Code" + '</inv:location_filter>' +
                  '<inv:products>';

        NpCsStoreInventoryBuffer.FindSet();
        repeat
            ReqBody +=
                        '<inv:product sku="' + NpCsStoreInventoryBuffer.Sku + '" />';
        until NpCsStoreInventoryBuffer.Next() = 0;
        ReqBody +=
                  '</inv:products>' +
                '</local_inventory>' +
              '</GetLocalInventory>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(ReqBody);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        ContentHeader.Add('SOAPAction', 'GetLocalInventory');
        ContentHeader.Remove('Connection');
        ContentHeader := Client.DefaultRequestHeaders();

        Client.UseWindowsAuthentication(NpCsStore."Service Username", NpCsStore."Service Password");
        Client.Post(NpCsStore."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode then
            Error(Response.ReasonPhrase);

        Response.Content.ReadAs(ResponseText);
        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        if not XmlDocument.ReadFrom(ResponseText, Document) then
            exit;

        Document.SelectSingleNode('//Body/GetLocalInventory_Result/local_inventory/products', Node);
        if Node.AsXmlElement().IsEmpty() then
            exit;

        NpCsStoreInventoryBuffer.FindSet();
        repeat
            NpCsStoreInventoryBuffer.Inventory := GetElementDecimal(Node.AsXmlElement(), 'product[@sku="' + NpCsStoreInventoryBuffer.Sku + '"]/inventory');
            NpCsStoreInventoryBuffer."In Stock" := NpCsStoreInventoryBuffer.Quantity <= NpCsStoreInventoryBuffer.Inventory;
            NpCsStoreInventoryBuffer.Modify();
        until NpCsStoreInventoryBuffer.Next() = 0;
    end;

    local procedure FindBufferStores(var NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary; var TempNpCsStore: Record "NPR NpCs Store" temporary): Boolean
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if not TempNpCsStore.IsTemporary then
            exit(false);

        Clear(NpCsStoreInventoryBuffer);
        if NpCsStoreInventoryBuffer.IsEmpty then
            exit(false);

        NpCsStoreInventoryBuffer.SetFilter("Store Code", '<>%1', '');
        while NpCsStoreInventoryBuffer.FindFirst() do begin
            if not TempNpCsStore.Get(NpCsStoreInventoryBuffer."Store Code") then begin
                TempNpCsStore.Init();
                if NpCsStore.Get(NpCsStoreInventoryBuffer."Store Code") then
                    TempNpCsStore := NpCsStore;
                TempNpCsStore.Code := NpCsStoreInventoryBuffer."Store Code";
                TempNpCsStore.Insert();
            end;

            NpCsStoreInventoryBuffer.SetFilter("Store Code", '>%1', NpCsStoreInventoryBuffer."Store Code");
        end;

        exit(TempNpCsStore.FindFirst());
    end;

    local procedure GetElementDecimal(Element: XmlElement; Path: Text) Value: Decimal
    var
        Element2: XmlElement;
        Node: XmlNode;
    begin
        if Element.IsEmpty() then
            exit(0);

        Element.SelectSingleNode(Path, Node);
        Element2 := Node.AsXmlElement();
        if Element2.IsEmpty() then
            exit(0);

        if not Evaluate(Value, Element2.InnerText, 9) then
            exit(0);

        exit(Value);
    end;

    procedure ShowAddress(NpCsStore: Record "NPR NpCs Store")
    var
        Url: Text;
    begin
        NpCsStore.TestField("Contact Address");
        Url := 'https://www.google.com/maps/place/' + NpCsStore."Contact Address";
        if NpCsStore."Contact Address 2" <> '' then
            Url += ',' + NpCsStore."Contact Address 2";
        if NpCsStore."Contact Post Code" <> '' then
            Url += ',' + NpCsStore."Contact Post Code";
        if NpCsStore."Contact City" <> '' then
            Url += ',' + NpCsStore."Contact City";
        if NpCsStore."Contact Country/Region Code" <> '' then
            Url += ',' + NpCsStore."Contact Country/Region Code";
        Url := ConvertStr(Url, ' ', '+');
        HyperLink(Url);
    end;

    procedure ShowGeolocation(NpCsStore: Record "NPR NpCs Store")
    var
        Url: Text;
    begin
        Url := StrSubstNo('http://maps.google.com/maps?q=%1,%2', NpCsStore."Geolocation Latitude", NpCsStore."Geolocation Longitude");
        HyperLink(Url);
    end;

    local procedure CollectWsCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Collect WS");
    end;
}

