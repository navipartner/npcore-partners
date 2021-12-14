codeunit 6151085 "NPR RIS Retail Inv. Set Mgt."
{

    procedure IsRetailInventoryEnabled(): Boolean
    var
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
    begin
        exit(not RetailInventorySet.IsEmpty());
    end;

    procedure RunProcessInventorySet(Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
        RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer";
        VariantFilter: Text;
    begin
        if PAGE.RunModal(0, RetailInventorySet) <> ACTION::LookupOK then
            exit;

        ItemVariant.SetRange("Item No.", Item."No.");
        if not ItemVariant.IsEmpty() then begin
            if PAGE.RunModal(0, ItemVariant) = ACTION::LookupOK then
                VariantFilter := ItemVariant.Code;
        end;

        ProcessInventorySet(RetailInventorySet, Item."No.", VariantFilter, RetailInventoryBuffer);
        PAGE.Run(0, RetailInventoryBuffer);
    end;

    procedure TestProcessInventorySet(RetailInventorySet: Record "NPR RIS Retail Inv. Set")
    var
        ItemVariant: Record "Item Variant";
        Item: Record Item;
        RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer";
        VariantFilter: Text;
    begin
        if PAGE.RunModal(0, Item) <> ACTION::LookupOK then
            exit;

        ItemVariant.SetRange("Item No.", Item."No.");
        if not ItemVariant.IsEmpty() then begin
            if PAGE.RunModal(0, ItemVariant) = ACTION::LookupOK then
                VariantFilter := ItemVariant.Code;
        end;

        ProcessInventorySet(RetailInventorySet, Item."No.", VariantFilter, RetailInventoryBuffer);
        PAGE.Run(0, RetailInventoryBuffer);
    end;

    procedure ProcessInventorySet(RetailInventorySet: Record "NPR RIS Retail Inv. Set"; ItemFilter: Text; VariantFilter: Text; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer")
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
                RetailInventoryBuffer."Item Filter" := CopyStr(ItemFilter, 1, MaxStrLen(RetailInventoryBuffer."Item Filter"));
                RetailInventoryBuffer."Variant Filter" := CopyStr(VariantFilter, 1, MaxStrLen(RetailInventoryBuffer."Variant Filter"));
                RetailInventoryBuffer."Location Filter" := CopyStr(RetailInventorySetEntry."Location Filter", 1, MaxStrLen(RetailInventoryBuffer."Variant Filter"));

                OnSetFilter(RetailInventoryBuffer, RetailInventorySetEntry, RetailInventorySet);

                RetailInventoryBuffer."Company Name" := RetailInventorySetEntry."Company Name";
                RetailInventoryBuffer.Insert();

                Handled := false;
                OnProcessInventorySetEntry(RetailInventorySetEntry, RetailInventoryBuffer, Handled);
                if not Handled then
                    ProcessInventorySetEntry(RetailInventorySetEntry, RetailInventoryBuffer, Handled);
            until RetailInventorySetEntry.Next() = 0;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnProcessInventorySetEntry(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer"; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RIS Retail Inv. Set Mgt.", 'OnProcessInventorySetEntry', '', true, true)]
    local procedure ProcessInventorySetEntry(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer"; var Handled: Boolean)
    begin
        if Handled then
            exit;

        Handled := true;

        RetailInventoryBuffer.Inventory := 0;
        RetailInventoryBuffer."Qty. on Sales Order" := 0;
        RetailInventoryBuffer."Qty. on Sales Return" := 0;
        RetailInventoryBuffer."Qty. on Purch. Order" := 0;
        RetailInventoryBuffer."Qty. on Purch. Return" := 0;
        RetailInventoryBuffer."Phys. Inventory" := 0;

        if not TryRequestInventory(RetailInventorySetEntry, RetailInventoryBuffer) then begin
            RetailInventoryBuffer."Processing Error" := true;
            RetailInventoryBuffer."Processing Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(RetailInventoryBuffer."Processing Error Message"));
        end;

        RetailInventoryBuffer.Modify();
    end;

    [TryFunction]
    procedure TryRequestInventory(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer")
    var
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
    begin
        RetailInventorySet.Get(RetailInventorySetEntry."Set Code");
        case RetailInventorySet."Client Type" of
            RetailInventorySet."Client Type"::SOAP:
                begin
                    RequestInventorySoap(RetailInventorySetEntry, RetailInventoryBuffer);
                end;
            RetailInventorySet."Client Type"::OData:
                begin
                    RequestInventoryOData(RetailInventorySetEntry, RetailInventoryBuffer);
                end;
        end;
    end;

    local procedure RequestInventorySoap(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer")
    var
        TempBlob: Codeunit "Temp Blob";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        [NonDebuggable]
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
        InStream: InStream;
        OutStream: OutStream;
        XmlDoc: XmlDocument;
        XmlNodeList: XmlNodeList;
        Node, NodeInventory, NodePurchaseOrderQty, NodePurchReturnQty, NodeSalesOrderQty, NodeSalesReturnQty : XmlNode;
        i: Integer;
        Position: Integer;
        Inventory, QtyOnSalesOrder, QtyOnPurchOrder, QtyOnSalesReturn, QtyOnPurchReturn : Decimal;
        Response: Text;
        WsNamespace: Text;
        XmlString: Text;
    begin
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

        HttpWebRequest.GetHeaders(HeadersReq);

        RetailInventorySetEntry.SetRequestHeadersAuthorization(HeadersReq);

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
            if Node.SelectSingleNode('.//*[local-name()="inventory"]', NodeInventory) then begin
                if Evaluate(Inventory, NodeInventory.AsXmlElement().InnerText, 9) then begin
                    RetailInventoryBuffer."Phys. Inventory" += Inventory;
                end;
            end;
            if Node.SelectSingleNode('.//*[local-name()="qtyOnSalesOrder"]', NodeSalesOrderQty) then begin
                if Evaluate(QtyOnSalesOrder, NodeSalesOrderQty.AsXmlElement().InnerText(), 9) then begin
                    RetailInventoryBuffer."Qty. on Sales Order" += QtyOnSalesOrder;
                    RetailInventoryBuffer."Phys. Inventory" += QtyOnSalesOrder;
                end;
            end;
            if Node.SelectSingleNode('.//*[local-name()="qtyOnSalesReturn"]', NodeSalesReturnQty) then begin
                if Evaluate(QtyOnSalesReturn, NodeSalesReturnQty.AsXmlElement().InnerText(), 9) then begin
                    RetailInventoryBuffer."Qty. on Sales Return" += QtyOnSalesReturn;
                end;
            end;
            if Node.SelectSingleNode('.//*[local-name()="qtyOnPurchOrder"]', NodePurchaseOrderQty) then begin
                if Evaluate(QtyOnPurchOrder, NodePurchaseOrderQty.AsXmlElement().InnerText(), 9) then begin
                    RetailInventoryBuffer."Qty. on Purch. Order" += QtyOnPurchOrder;
                end;
            end;
            if Node.SelectSingleNode('.//*[local-name()="qtyOnPurchReturn"]', NodePurchReturnQty) then begin
                if Evaluate(QtyOnPurchReturn, NodePurchReturnQty.AsXmlElement().InnerText(), 9) then begin
                    RetailInventoryBuffer."Qty. on Purch. Return" += QtyOnPurchReturn;
                end;
            end;
        end;
        RetailInventoryBuffer.Inventory := RetailInventoryBuffer."Phys. Inventory" - RetailInventoryBuffer."Qty. on Sales Order";
        if RetailInventoryBuffer.Inventory < 0 then
            RetailInventoryBuffer.Inventory := 0;
    end;

    local procedure RequestInventoryOData(RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer")
    var
        TempBlob: Codeunit "Temp Blob";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Headers: HttpHeaders;
        JObject: JsonObject;
        JToken: JsonToken;
        OutStr: OutStream;
        UrlBuilder: TextBuilder;
        Url, Response : Text;
        Inventory, QtyOnSalesOrder, QtyOnPurchOrder, QtyOnSalesReturn, QtyOnPurchReturn : Decimal;
    begin
        TempBlob.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        UrlBuilder.Append(RetailInventorySetEntry."Api Url");
        UrlBuilder.Append('(''');
        UrlBuilder.Append(RetailInventoryBuffer."Item Filter");
        UrlBuilder.Append(''')');
        case true of
            (RetailInventoryBuffer."Location Filter" <> '') and (RetailInventoryBuffer."Variant Filter" <> ''):
                begin
                    UrlBuilder.Append(StrSubstNo('?$filter=Location_Filter eq ''%1'' and Variant_Filter eq ''%2''', RetailInventoryBuffer."Location Filter", RetailInventoryBuffer."Variant Filter"));
                end;
            (RetailInventoryBuffer."Location Filter" = '') and (RetailInventoryBuffer."Variant Filter" <> ''):
                begin
                    UrlBuilder.Append(StrSubstNo('?$filter=Variant_Filter eq ''%1''', RetailInventoryBuffer."Variant Filter"));
                end;
            (RetailInventoryBuffer."Location Filter" <> '') and (RetailInventoryBuffer."Variant Filter" = ''):
                begin
                    UrlBuilder.Append(StrSubstNo('?$filter=Location_Filter eq ''%1''', RetailInventoryBuffer."Location Filter"));
                end;
        end;

        OnPrepareRequestFilter(UrlBuilder, RetailInventoryBuffer, RetailInventorySetEntry);

        HttpWebRequest.GetHeaders(Headers);

        RetailInventorySetEntry.SetRequestHeadersAuthorization(Headers);

        Url := UrlBuilder.ToText();
        HttpWebRequest.SetRequestUri(Url);
        HttpWebRequest.Method := 'GET';

        Client.Timeout(5000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        if not HttpWebResponse.IsSuccessStatusCode then begin
            Error('%1 - %2', HttpWebResponse.HttpStatusCode(), HttpWebResponse.ReasonPhrase());
        end;

        HttpWebResponse.Content.ReadAs(Response);
        JObject.ReadFrom(Response);
        if JObject.SelectToken('$.Inventory', JToken) then begin
            Inventory := JToken.AsValue().AsDecimal();
            RetailInventoryBuffer."Phys. Inventory" += Inventory;
        end;
        if JObject.SelectToken('$.Qty_on_Sales_Order', JToken) then begin
            QtyOnSalesOrder := JToken.AsValue().AsDecimal();
            RetailInventoryBuffer."Qty. on Sales Order" += QtyOnSalesOrder;
        end;
        if JObject.SelectToken('$.Qty_on_Sales_Return', JToken) then begin
            QtyOnSalesReturn := JToken.AsValue().AsDecimal();
            RetailInventoryBuffer."Qty. on Sales Return" += QtyOnSalesReturn;
        end;
        if JObject.SelectToken('$.Qty_on_Purch_Order', JToken) then begin
            QtyOnPurchOrder := JToken.AsValue().AsDecimal();
            RetailInventoryBuffer."Qty. on Purch. Order" += QtyOnPurchOrder;
        end;
        if JObject.SelectToken('$.Qty_on_Purch_Return', JToken) then begin
            QtyOnPurchReturn := JToken.AsValue().AsDecimal();
            RetailInventoryBuffer."Qty. on Purch. Return" += QtyOnPurchReturn;
        end;
        RetailInventoryBuffer.Inventory := RetailInventoryBuffer."Phys. Inventory" - RetailInventoryBuffer."Qty. on Sales Order";
        if RetailInventoryBuffer.Inventory < 0 then
            RetailInventoryBuffer.Inventory := 0;
    end;

    procedure ResetInventorySetEntriesAPIValues(RetailInvSet: Record "NPR RIS Retail Inv. Set")
    var
        RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry";
    begin
        RetailInventorySetEntry.SetRange("Set Code", RetailInvSet.Code);
        if RetailInventorySetEntry.FindSet(true) then
            repeat
                ResetInventorySetEntryAPIValues(RetailInventorySetEntry);
                case RetailInvSet."Client Type" of
                    RetailInvSet."Client Type"::Soap:
                        begin
                            RetailInventorySetEntry."Api Url" := CopyStr(GetUrl(CLIENTTYPE::SOAP, RetailInventorySetEntry."Company Name", OBJECTTYPE::Codeunit, CODEUNIT::"NPR Magento Webservice"), 1, MaxStrLen(RetailInventorySetEntry."Api Url"));
                        end;
                    RetailInvSet."Client Type"::OData:
                        begin
                            RetailInventorySetEntry."Api Url" := CopyStr(GetUrl(CLIENTTYPE::ODataV4, RetailInventorySetEntry."Company Name", OBJECTTYPE::Page, Page::"Item Card"), 1, MaxStrLen(RetailInventorySetEntry."Api Url"));
                        end;
                end;
                RetailInventorySetEntry.Modify();
            until RetailInventorySetEntry.Next() = 0;
    end;

    procedure ResetInventorySetEntryAPIValues(var RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry")
    begin
        RetailInventorySetEntry."Api Username" := '';
        RetailInventorySetEntry.RemoveApiPassword();
        RetailInventorySetEntry."Api Url" := '';
        RetailInventorySetEntry."OAuth2 Setup Code" := '';
    end;

    procedure SetApiUrl(var RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry")
    var
        RetailInvSet: Record "NPR RIS Retail Inv. Set";
    begin
        if RetailInventorySetEntry."Api Url" = '' then begin
            RetailInvSet.Get(RetailInventorySetEntry."Set Code");
            case RetailInvSet."Client Type" of
                RetailInvSet."Client Type"::Soap:
                    begin
                        RetailInventorySetEntry."Api Url" := CopyStr(GetUrl(CLIENTTYPE::SOAP, RetailInventorySetEntry."Company Name", OBJECTTYPE::Codeunit, CODEUNIT::"NPR Magento Webservice"), 1, MaxStrLen(RetailInventorySetEntry."Api Url"));
                    end;
                RetailInvSet."Client Type"::OData:
                    begin
                        RetailInventorySetEntry."Api Url" := CopyStr(GetUrl(CLIENTTYPE::ODataV4, RetailInventorySetEntry."Company Name", OBJECTTYPE::Page, Page::"Item Card"), 1, MaxStrLen(RetailInventorySetEntry."Api Url"));
                    end;
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetFilter(var RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer"; RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry"; RetailInventorySet: Record "NPR RIS Retail Inv. Set")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPrepareRequestFilter(var UrlBuilder: TextBuilder; RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer"; RetailInventorySetEntry: Record "NPR RIS Retail Inv. Set Entry")
    begin
    end;
}