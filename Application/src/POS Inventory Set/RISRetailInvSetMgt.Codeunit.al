codeunit 6151085 "NPR RIS Retail Inv. Set Mgt."
{

    procedure GetRetailInventoryEnabled(): Boolean
    var
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
    begin
        exit(RetailInventorySet.FindFirst());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessInventorySetEntry(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary; var Handled: Boolean)
    begin
    end;

    procedure RunProcessInventorySet(Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
        TempRetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary;
        VariantFilter: Text;
    begin
        if PAGE.RunModal(0, RetailInventorySet) <> ACTION::LookupOK then
            exit;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindFirst() then begin
            if PAGE.RunModal(0, ItemVariant) = ACTION::LookupOK then
                VariantFilter := ItemVariant.Code;
        end;

        ProcessInventorySet(RetailInventorySet, Item."No.", VariantFilter, TempRetailInventoryBuffer);
        PAGE.Run(0, TempRetailInventoryBuffer);
    end;

    procedure TestProcessInventorySet(RetailInventorySet: Record "NPR RIS Retail Inv. Set")
    var
        Item: Record Item;
        TempRetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary;
    begin
        if PAGE.RunModal(0, Item) <> ACTION::LookupOK then
            exit;

        ProcessInventorySet(RetailInventorySet, Item."No.", '', TempRetailInventoryBuffer);
        PAGE.Run(0, TempRetailInventoryBuffer);
    end;

    procedure ProcessInventorySet(RetailInventorySet: Record "NPR RIS Retail Inv. Set"; ItemFilter: Text; VariantFilter: Text; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary)
    var
        RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry";
        Handled: Boolean;
    begin
        RetailInventoryBuffer.DeleteAll();

        RetailInventorySetEntry.SetRange("Set Code", RetailInventorySet.Code);
        RetailInventorySetEntry.SetRange(Enabled, true);
        if RetailInventorySetEntry.FindSet() then
            repeat
                RetailInventoryBuffer.Init();
                RetailInventoryBuffer."Set Code" := RetailInventorySetEntry."Set Code";
                RetailInventoryBuffer."Line No." := RetailInventorySetEntry."Line No.";
                RetailInventoryBuffer."Item Filter" := ItemFilter;
                RetailInventoryBuffer."Variant Filter" := VariantFilter;
                RetailInventoryBuffer."Location Filter" := RetailInventorySetEntry."Location Filter";
                RetailInventoryBuffer."Company Name" := RetailInventorySetEntry."Company Name";
                RetailInventoryBuffer.Inventory := 0;
                RetailInventoryBuffer.Insert();

                Handled := false;
                OnProcessInventorySetEntry(RetailInventorySetEntry, RetailInventoryBuffer, Handled);
                if not Handled then
                    ProcessInventorySetEntry(RetailInventorySetEntry, RetailInventoryBuffer, Handled);
            until RetailInventorySetEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RIS Retail Inv. Set Mgt.", 'OnProcessInventorySetEntry', '', true, true)]
    local procedure ProcessInventorySetEntry(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary; var Handled: Boolean)
    var
        Inventory: Decimal;
    begin
        if Handled then
            exit;

        Handled := true;

        if RetailInventoryBuffer.Inventory <> 0 then begin
            RetailInventoryBuffer.Inventory := 0;
            RetailInventoryBuffer.Modify();
        end;

        if TryRequestInventory(RetailInventorySetEntry, RetailInventoryBuffer, Inventory) then
            RetailInventoryBuffer.Inventory := Inventory
        else begin
            RetailInventoryBuffer."Processing Error" := true;
            RetailInventoryBuffer."Processing Error Message" := CopyStr(GetLastErrorText, 1, MaxStrLen(RetailInventoryBuffer."Processing Error Message"));
        end;

        RetailInventoryBuffer.Modify();
    end;

    [TryFunction]
    local procedure TryRequestInventory(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer" temporary; var TotalInventory: Decimal)
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
        InStream: InStream;
        OutStream: OutStream;
        XmlDoc: XmlDocument;
        XmlNodeList: XmlNodeList;
        Node: XmlNode;
        i: Integer;
        Position: Integer;
        Inventory: Decimal;
        Response: Text;
        WsNamespace: Text;
        XmlString: Text;
        AuthText: Text;
        AuthLbl: Label '%1:%2', Locked = true;
        BasicLbl: Label 'Basic %1', Locked = true;
    begin
        TotalInventory := 0;
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);

        WsNamespace := RetailInventorySetEntry."Api Url";
        Position := StrPos(WsNamespace, '/');
        while Position > 0 do begin
            WsNamespace := DelStr(WsNamespace, 1, Position);
            Position := StrPos(WsNamespace, '/');
        end;
        Position := StrPos(WsNamespace, '?');
        if Position > 0 then
            WsNamespace := DelStr(WsNamespace, Position);
        WsNamespace := 'urn:microsoft-dynamics-schemas/codeunit/' + WsNamespace;

        XmlString := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                       '  <soapenv:Header />' +
                       '  <soapenv:Body>' +
                       '    <GetItemInventory xmlns="' + WsNamespace + '">' +
                       '       <itemFilter />' +
                       '       <variantFilter />' +
                       '       <locationFilter />' +
                       '       <items />' +
                       '    </GetItemInventory>' +
                       '  </soapenv:Body>' +
                       '</soapenv:Envelope>';

        XmlDocument.ReadFrom(XmlString, XmlDoc);

        XmlDoc.SelectSingleNode('.//*[local-name()="itemFilter"]', Node);
        Node.AsXmlElement().Add(RetailInventoryBuffer."Item Filter");
        XmlDoc.SelectSingleNode('.//*[local-name()="variantFilter"]', Node);
        Node.AsXmlElement().Add(RetailInventoryBuffer."Variant Filter");
        XmlDoc.SelectSingleNode('.//*[local-name()="locationFilter"]', Node);
        Node.AsXmlElement().Add(RetailInventoryBuffer."Location Filter");

        XmlDoc.WriteTo(OutStream);
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        Content.WriteFrom(InStream);


        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');
        Headers.Add('SOAPAction', 'GetItemInventory');

        if RetailInventorySetEntry."Api Username" <> '' then begin
            HttpWebRequest.GetHeaders(HeadersReq);
            AuthText := StrSubstNo(AuthLbl, RetailInventorySetEntry."Api Username", RetailInventorySetEntry."Api Password");
            HeadersReq.Add('Authorization', StrSubstNo(BasicLbl, Base64Convert.ToBase64(AuthText)));
        end;

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(RetailInventorySetEntry."Api Url");
        HttpWebRequest.Method := 'POST';

        Client.Timeout(5000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        Clear(XmlDoc);
        HttpWebResponse.Content.ReadAs(Response);
        XmlDocument.ReadFrom(Response, XmlDoc);

        if not HttpWebResponse.IsSuccessStatusCode then begin
            XmlDoc.SelectSingleNode('.//*[local-name()="faultstring"]', Node);
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Node.AsXmlElement().InnerText)
        end;

        XmlDoc.SelectNodes('.//*[local-name()="item"]', XmlNodeList);

        for i := 1 to XmlNodeList.Count() do begin
            XmlNodeList.Get(i, Node);
            if Evaluate(Inventory, Node.AsXmlElement().InnerText, 9) then begin
                if Inventory < 0 then
                    Inventory := 0;
                TotalInventory += Inventory;
            end;
        end;
    end;
}