codeunit 6151204 "NpCs Store Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store


    trigger OnRun()
    begin
    end;

    local procedure "--- Init"()
    begin
    end;

    procedure InitLocalStore(var NpCsStore: Record "NpCs Store")
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

        if not WebService.Get(WebService."Object Type"::Codeunit,'collect_in_store_service') then begin
          WebService.Init;
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

    procedure UpdateContactInfo(var NpCsStore: Record "NpCs Store")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet NetworkCredential;
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        XmlDoc: DotNet XmlDocument;
        XmlElement: DotNet XmlElement;
        WebException: DotNet WebException;
        ErrorMessage: Text;
        Response: Text;
        PrevRec: Text;
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
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
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpCsStore."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpCsStore."Service Username",NpCsStore."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType('application/xml; charset=utf-8');
        HttpWebRequest.Headers.Add('SOAPAction','GetCollectStores');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then
              ErrorMessage := XmlElement.InnerText;
          end;
          Error(ErrorMessage);
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not NpXmlDomMgt.TryLoadXml(Response,XmlDoc) then
          Error(Response);

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        NpXmlDomMgt.FindElement(XmlDoc.DocumentElement,'Body/GetCollectStores_Result/stores/store[@store_code = "' + NpCsStore.Code + '"]',true,XmlElement);

        PrevRec := Format(NpCsStore);

        NpCsStore."Contact Name" := NpXmlDomMgt.GetElementText(XmlElement,'contact_name',MaxStrLen(NpCsStore."Contact Name"),false);
        NpCsStore."Contact Name 2" := NpXmlDomMgt.GetElementText(XmlElement,'contact_name_2',MaxStrLen(NpCsStore."Contact Name 2"),false);
        NpCsStore."Contact Address" := NpXmlDomMgt.GetElementText(XmlElement,'contact_address',MaxStrLen(NpCsStore."Contact Address"),false);
        NpCsStore."Contact Address 2" := NpXmlDomMgt.GetElementText(XmlElement,'contact_address_2',MaxStrLen(NpCsStore."Contact Address 2"),false);
        NpCsStore."Contact Post Code" := NpXmlDomMgt.GetElementCode(XmlElement,'contact_post_code',MaxStrLen(NpCsStore."Contact Post Code"),false);
        NpCsStore."Contact Country/Region Code" := NpXmlDomMgt.GetElementText(XmlElement,'contact_country_code',MaxStrLen(NpCsStore."Contact Country/Region Code"),false);
        NpCsStore."Contact County" := NpXmlDomMgt.GetElementText(XmlElement,'contact_county',MaxStrLen(NpCsStore."Contact County"),false);
        NpCsStore."Contact Phone No." := NpXmlDomMgt.GetElementText(XmlElement,'contact_phone_no',MaxStrLen(NpCsStore."Contact Phone No."),false);
        NpCsStore."Contact E-mail" := NpXmlDomMgt.GetElementText(XmlElement,'contact_email',MaxStrLen(NpCsStore."Contact E-mail"),false);

        if PrevRec <> Format(NpCsStore) then
          NpCsStore.Modify(true);
    end;

    [TryFunction]
    procedure TryGetCollectService(NpCsStore: Record "NpCs Store")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet NetworkCredential;
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        XmlDoc: DotNet XmlDocument;
        XmlElement: DotNet XmlElement;
        WebException: DotNet WebException;
        ErrorMessage: Text;
    begin
        NpCsStore.TestField("Service Url");

        HttpWebRequest := HttpWebRequest.Create(NpCsStore."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpCsStore."Service Username",NpCsStore."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'GET';
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if TryGetWebResponse(HttpWebRequest,HttpWebResponse) then
          exit;

        WebException := GetLastErrorObject;
        ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
        if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
          NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
          if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then begin
            ErrorMessage := XmlElement.InnerText;
            Error(ErrorMessage);
          end;
        end;

        Error(ErrorMessage);
    end;

    [TryFunction]
    local procedure TryGetWebResponse(HttpWebRequest: DotNet HttpWebRequest;var HttpWebResponse: DotNet HttpWebResponse)
    begin
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    procedure InitStoresWithDistance(FromNpCsStore: Record "NpCs Store";var TempNpCsStore: Record "NpCs Store" temporary)
    var
        NpCsStore: Record "NpCs Store";
    begin
        NpCsStore.SetFilter(Code,'<>%1',FromNpCsStore.Code);
        if not NpCsStore.FindSet then
          exit;

        repeat
          TempNpCsStore.Init;
          TempNpCsStore := NpCsStore;
          TempNpCsStore."Distance (km)" := CalcDistance(FromNpCsStore,TempNpCsStore);
          TempNpCsStore.Insert;
        until NpCsStore.Next = 0;
    end;

    local procedure "--- Get/Find"()
    begin
    end;

    procedure GetCollectWSUrl(ServiceCompanyName: Text) Url: Text
    begin
        exit(GetUrl(CLIENTTYPE::SOAP,ServiceCompanyName,OBJECTTYPE::Codeunit,CollectWsCodeunitId()));
    end;

    procedure GetServiceName(NpCsStore: Record "NpCs Store") ServiceName: Text
    var
        Position: Integer;
    begin
        ServiceName := NpCsStore."Service Url";
        Position := StrPos(ServiceName,'?');
        if Position > 0 then
          ServiceName := DelStr(ServiceName,Position);

        if ServiceName = '' then
          exit('');

        if ServiceName[StrLen(ServiceName)] = '/' then
          ServiceName := DelStr(ServiceName,StrLen(ServiceName));

        Position := StrPos(ServiceName,'/');
        while Position > 0 do begin
          ServiceName := DelStr(ServiceName,1,Position);
          Position := StrPos(ServiceName,'/');
        end;

        exit(ServiceName);
    end;

    procedure FindLocalStore(var NpCsStore: Record "NpCs Store")
    begin
        Clear(NpCsStore);
        NpCsStore.SetRange("Local Store",true);
        NpCsStore.FindFirst;
    end;

    local procedure "--- Store Inventory"()
    begin
    end;

    procedure CalcDistance(FromNpCsStore: Record "NpCs Store";ToNpCsStore: Record "NpCs Store") Distance: Decimal
    var
        Math: DotNet Math;
        PI: Decimal;
        Lat1: Decimal;
        Lat2: Decimal;
        Lon1: Decimal;
        Lon2: Decimal;
    begin
        if not Evaluate(Lat1,FromNpCsStore."Geolocation Latitude",9) then
          if Evaluate(Lat1,FromNpCsStore."Geolocation Latitude") then;
        if not Evaluate(Lon1,FromNpCsStore."Geolocation Longitude",9) then
          if Evaluate(Lon1,FromNpCsStore."Geolocation Longitude") then;
        if not Evaluate(Lat2,ToNpCsStore."Geolocation Latitude",9) then
          if Evaluate(Lat2,ToNpCsStore."Geolocation Latitude") then;
        if not Evaluate(Lon2,ToNpCsStore."Geolocation Longitude",9) then
          if Evaluate(Lon2,ToNpCsStore."Geolocation Longitude") then;

        PI := 3.14159265358979;
        Lon1 *= PI / 180;
        Lat1 *= PI / 180;
        Lon2 *= PI / 180;
        Lat2 *= PI / 180;

        Distance := Math.Acos(Math.Sin(Lat1) * Math.Sin(Lat2) + Math.Cos(Lat1) * Math.Cos(Lat2) * Math.Cos(Lon2-Lon1)) * 6371;
        exit(Distance);
    end;

    procedure SetBufferInventory(var NpCsStoreInventoryBuffer: Record "NpCs Store Inventory Buffer" temporary)
    var
        TempNpCsStore: Record "NpCs Store" temporary;
    begin
        if not FindBufferStores(NpCsStoreInventoryBuffer,TempNpCsStore) then
          exit;

        TempNpCsStore.FindSet;
        repeat
          Clear(NpCsStoreInventoryBuffer);
          SetBufferInventoryStore(TempNpCsStore.Code,NpCsStoreInventoryBuffer);
        until TempNpCsStore.Next = 0;

        Clear(NpCsStoreInventoryBuffer);
    end;

    local procedure SetBufferInventoryStore(StoreCode: Code[20];var NpCsStoreInventoryBuffer: Record "NpCs Store Inventory Buffer" temporary)
    var
        NpCsStore: Record "NpCs Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet NetworkCredential;
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        XmlDoc: DotNet XmlDocument;
        XmlElement: DotNet XmlElement;
        WebException: DotNet WebException;
        ReqBody: Text;
        Response: Text;
    begin
        if not NpCsStore.Get(StoreCode) then
          exit;
        if NpCsStore."Service Url" = '' then
          exit;

        NpCsStoreInventoryBuffer.SetRange("Store Code",NpCsStore.Code);
        if NpCsStoreInventoryBuffer.IsEmpty then
          exit;

        ReqBody :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:inv="urn:microsoft-dynamics-nav/xmlports/collect_local_inventory">' +
            '<soapenv:Body>' +
              '<GetLocalInventory xmlns="urn:microsoft-dynamics-schemas/codeunit/collect_in_store_service">' +
                '<local_inventory>' +
                  '<inv:location_filter>' + NpCsStore."Location Code" + '</inv:location_filter>' +
                  '<inv:products>';

        NpCsStoreInventoryBuffer.FindSet;
        repeat
          ReqBody +=
                      '<inv:product sku="' + NpCsStoreInventoryBuffer.Sku + '" />';
        until NpCsStoreInventoryBuffer.Next = 0;
        ReqBody +=
                  '</inv:products>' +
                '</local_inventory>' +
              '</GetLocalInventory>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';
          XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(ReqBody);

        HttpWebRequest := HttpWebRequest.CreateHttp(NpCsStore."Service Url");
        HttpWebRequest.ContentType := 'text/xml;charset=UTF-8';
        HttpWebRequest.Headers.Add('SOAPAction','GetLocalInventory');
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpCsStore."Service Username",NpCsStore."Service Password");
        HttpWebRequest.Credentials(Credential);
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          Error(NpXmlDomMgt.GetWebExceptionMessage(WebException));

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not NpXmlDomMgt.TryLoadXml(Response,XmlDoc) then
          exit;

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        XmlElement := XmlElement.SelectSingleNode('Body/GetLocalInventory_Result/local_inventory/products');
        if IsNull(XmlElement) then
          exit;

        NpCsStoreInventoryBuffer.FindSet;
        repeat
          NpCsStoreInventoryBuffer.Inventory := GetElementDecimal(XmlElement,'product[@sku="' + NpCsStoreInventoryBuffer.Sku + '"]/inventory');
          NpCsStoreInventoryBuffer."In Stock" := NpCsStoreInventoryBuffer.Quantity <= NpCsStoreInventoryBuffer.Inventory;
          NpCsStoreInventoryBuffer.Modify;
        until NpCsStoreInventoryBuffer.Next = 0;
    end;

    local procedure FindBufferStores(var NpCsStoreInventoryBuffer: Record "NpCs Store Inventory Buffer" temporary;var TempNpCsStore: Record "NpCs Store" temporary): Boolean
    var
        NpCsStore: Record "NpCs Store";
    begin
        if not TempNpCsStore.IsTemporary then
          exit(false);

        Clear(NpCsStoreInventoryBuffer);
        if NpCsStoreInventoryBuffer.IsEmpty then
          exit(false);

        NpCsStoreInventoryBuffer.SetFilter("Store Code",'<>%1','');
        while NpCsStoreInventoryBuffer.FindFirst do begin
          if not TempNpCsStore.Get(NpCsStoreInventoryBuffer."Store Code") then begin
            TempNpCsStore.Init;
            if NpCsStore.Get(NpCsStoreInventoryBuffer."Store Code") then
              TempNpCsStore := NpCsStore;
            TempNpCsStore.Code := NpCsStoreInventoryBuffer."Store Code";
            TempNpCsStore.Insert;
          end;

          NpCsStoreInventoryBuffer.SetFilter("Store Code",'>%1',NpCsStoreInventoryBuffer."Store Code");
        end;

        exit(TempNpCsStore.FindFirst);
    end;

    local procedure GetElementDecimal(XmlElement: DotNet XmlElement;Path: Text) Value: Decimal
    var
        XmlElement2: DotNet XmlElement;
    begin
        if IsNull(XmlElement) then
          exit(0);

        XmlElement2 := XmlElement.SelectSingleNode(Path);
        if IsNull(XmlElement2) then
          exit(0);

        if not Evaluate(Value,XmlElement2.InnerText,9) then
          exit(0);

        exit(Value);
    end;

    local procedure "--- UI"()
    begin
    end;

    procedure ShowAddress(NpCsStore: Record "NpCs Store")
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
        Url := ConvertStr(Url,' ','+');
        HyperLink(Url);
    end;

    procedure ShowGeolocation(NpCsStore: Record "NpCs Store")
    var
        Url: Text;
    begin
        Url := StrSubstNo('http://maps.google.com/maps?q=%1,%2',NpCsStore."Geolocation Latitude",NpCsStore."Geolocation Longitude");
        HyperLink(Url);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CollectWsCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Collect Webservice");
    end;
}

