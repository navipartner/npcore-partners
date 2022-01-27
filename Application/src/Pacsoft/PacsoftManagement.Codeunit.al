codeunit 6014484 "NPR Pacsoft Management"
{
    Access = Internal;
    trigger OnRun()
    begin
        SendDocuments();
    end;

    var
        PacsoftSetup: Record "NPR Shipping Provider Setup";
        GotIComm: Boolean;
        SendShipmentAgainQst: Label 'The shipment was already sent to Pacsoft, do you wish to send it again?';

    procedure SendDocuments()
    var
        ShipmentDocument: Record "NPR Shipping Provider Document";
    begin
        Clear(ShipmentDocument);
        ShipmentDocument.SetCurrentKey("Export Time");
        ShipmentDocument.SetRange("Export Time", 0DT);
        if ShipmentDocument.FindSet() then
            repeat
                SendDocument(ShipmentDocument, false);
            until ShipmentDocument.Next() = 0;
    end;

    procedure SendDocument(var ShipmentDocument: Record "NPR Shipping Provider Document"; WithDialog: Boolean)
    var
        OutStr: OutStream;
        DocumentSentMsg: Label 'Document sent.';
    begin
        GetIComm();
        if not PacsoftSetup."Use Pacsoft integration" then exit;

        ShipmentDocument.CalcFields("Request XML");
        Clear(ShipmentDocument."Request XML");
        ShipmentDocument.Modify();

        if WithDialog then begin
            if not Confirm(SendShipmentAgainQst, false) then
                exit;
        end else
            if ShipmentDocument."Export Time" <> 0DT then
                exit;

        ShipmentDocument."Request XML Name" := 'Request ' +
                                                Format(Today) +
                                                ' ' +
                                                Format(Time, 0, '<Hours24,2>-<Minutes,2>-<Seconds,2>') +
                                                ' ' +
                                                Format(ShipmentDocument."Entry No.") +
                                                '.xml';
        ShipmentDocument."Request XML".CreateOutStream(OutStr);
        ShipmentDocument.SetRecFilter();
        XMLPORT.Export(XMLPORT::"NPR Pacsoft Shipment Document", OutStr, ShipmentDocument);
        ShipmentDocument.Modify();

        Clear(OutStr);

        PrepareXml(ShipmentDocument);
        SendXML(ShipmentDocument);

        if WithDialog then
            Message(DocumentSentMsg);
    end;

    local procedure SendXML(var ShipmentDocument: Record "NPR Shipping Provider Document")
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        XMLResponce: XMLport "NPR Pacsoft Response";
        InStr: InStream;
        URI: Text[250];
    begin
        ShipmentDocument.CalcFields("Request XML");
        if not ShipmentDocument."Request XML".HasValue() then
            exit;

        URI := StrSubstNo(PacsoftSetup."Send Order URI", PacsoftSetup.Session, PacsoftSetup.User, PacsoftSetup.Pin);

        ShipmentDocument."Request XML".CreateInStream(InStr);
        Content.WriteFrom(InStr);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');

        RequestMessage.Content(Content);
        RequestMessage.SetRequestUri(URI);
        RequestMessage.Method := 'POST';

        Client.Timeout(120000);
        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then
            Error(ResponseMessage.ReasonPhrase());

        ShipmentDocument."Response XML Name" := 'Response ' +
                                                  Format(Today) +
                                                  ' ' +
                                                  Format(Time, 0, '<Hours24,2>-<Minutes,2>-<Seconds,2>') +
                                                  ' ' +
                                                  Format(ShipmentDocument."Entry No.") +
                                                  '.xml';
        StoreResponseOfSentPacsoftShipmentDocument(ShipmentDocument, ResponseMessage);
        ShipmentDocument.Modify();

        Clear(InStr);
        ShipmentDocument."Response XML".CreateInStream(InStr);
        XMLResponce.SetShipmentDocument(ShipmentDocument);
        XMLResponce.SetSource(InStr);
        XMLResponce.Import();
        XMLResponce.GetShipmentDocument(ShipmentDocument);

        if ShipmentDocument.Status = '201' then
            ShipmentDocument."Export Time" := CurrentDateTime();

        ShipmentDocument.Modify();
    end;

    local procedure StoreResponseOfSentPacsoftShipmentDocument(var ShipmentDocument: Record "NPR Shipping Provider Document"; ResponseMessage: HttpResponseMessage)
    var
        Document: XmlDocument;
        OutStr: OutStream;
        Response: Text;
    begin
        ResponseMessage.Content().ReadAs(Response);
        XmlDocument.ReadFrom(Response, Document);
        ShipmentDocument."Response XML".CreateOutStream(OutStr);
        Document.WriteTo(OutStr);
    end;

    procedure CheckDocument(ShipmentDocument: Record "NPR Shipping Provider Document") OK: Boolean
    var
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentService: Record "Shipping Agent Services";
        ShipDocService: Record "NPR Pacsoft Shipm. Doc. Serv.";
        CustomsItemRows: Record "NPR Pacsoft Customs Item Rows";
        CompanyInfo: Record "Company Information";
        TextNoNotification: Label 'Please select a Notification service';
        TextNoItemRows: Label 'Please fill at least one Customs Item Row.';
        TextBeforeToday: Label 'must be today or later.';
        TextNoCustomsDocument: Label 'can not be blank.';
        Found: Boolean;
    begin
        if ShipmentDocument."Entry No." = 0 then exit;

        ShipmentDocument.TestField("Receiver ID");
        ShipmentDocument.TestField(Name);
        ShipmentDocument.TestField(Address);
        ShipmentDocument.TestField("Post Code");
        ShipmentDocument.TestField(City);
        ShipmentDocument.TestField("Country/Region Code");
        ShipmentDocument.TestField("Shipment Date");
        if ShipmentDocument."Shipment Date" < Today() then
            ShipmentDocument.FieldError("Shipment Date", TextBeforeToday);

        ShipmentDocument.TestField("Shipping Agent Code");
        ShippingAgent.Get(ShipmentDocument."Shipping Agent Code");
        ShippingAgent.TestField("NPR Pacsoft Product");
        case ShippingAgent."NPR Shipping Agent Demand" of
            ShippingAgent."NPR Shipping Agent Demand"::" ":
                ;
            ShippingAgent."NPR Shipping Agent Demand"::"Select a Service":
                begin
                    Found := false;
                    Clear(ShipDocService);
                    ShipDocService.SetCurrentKey("Entry No.", "Shipping Agent Code");
                    ShipDocService.SetRange("Entry No.", ShipmentDocument."Entry No.");
                    if ShipDocService.FindSet() then
                        repeat
                            ShippingAgentService.Get(ShipmentDocument."Shipping Agent Code", ShipDocService."Shipping Agent Service Code");
                            case ShippingAgentService."NPR Service Demand" of
                                ShippingAgentService."NPR Service Demand"::"Selected E-mail":
                                    ShipmentDocument.TestField("E-Mail");
                                ShippingAgentService."NPR Service Demand"::"Selected Mobile No.":
                                    ShipmentDocument.TestField("SMS No.");
                            end;
                            if ShippingAgentService."NPR Notification Service" then
                                Found := true;
                        until (Found) or (ShipDocService.Next() = 0);
                    if not Found then
                        Error(TextNoNotification);
                end;
            ShippingAgent."NPR Shipping Agent Demand"::"Customs Information":
                begin
                    if ShipmentDocument."Customs Document" = ShipmentDocument."Customs Document"::" " then
                        ShipmentDocument.FieldError("Customs Document", TextNoCustomsDocument);
                    ShipmentDocument.TestField("Customs Currency");
                    ShipmentDocument.TestField("Total Weight");
                    Found := false;
                    Clear(CustomsItemRows);
                    CustomsItemRows.SetCurrentKey("Shipment Document Entry No.", "Entry No.");
                    CustomsItemRows.SetRange("Shipment Document Entry No.", ShipmentDocument."Entry No.");
                    if CustomsItemRows.FindSet() then
                        repeat
                            Found := true;
                            if ShipmentDocument."Customs Document" <> ShipmentDocument."Customs Document"::CN23 then
                                CustomsItemRows.TestField("Item Code");
                            CustomsItemRows.TestField(Copies);
                            CustomsItemRows.TestField("Customs Value");
                            CustomsItemRows.TestField(Content);
                            if ShipmentDocument."Customs Document" <> ShipmentDocument."Customs Document"::CN23 then
                                CustomsItemRows.TestField("Country of Origin");
                        until CustomsItemRows.Next() = 0;

                    if not Found then
                        Error(TextNoItemRows);
                end;
        end;

        if ShipmentDocument."Send Link To Print" then begin
            CompanyInfo.Get();
            CompanyInfo.TestField("E-Mail");
            ShipmentDocument.TestField("E-Mail");
        end;

        OK := true;
        exit(OK);
    end;

    procedure PrepareXml(var ShipmentDocument: Record "NPR Shipping Provider Document")
    var
        Document: XmlDocument;
        Element: XmlElement;
        InStr: InStream;
        OutStr: OutStream;
    begin
        ShipmentDocument.CalcFields("Request XML");
        if not ShipmentDocument."Request XML".HasValue() then
            exit;

        ShipmentDocument."Request XML".CreateInStream(InStr);
        XmlDocument.ReadFrom(InStr, Document);
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'no'));
        Document.GetRoot(Element);

        Clear(ShipmentDocument."Request XML");

        ShipmentDocument."Request XML".CreateOutStream(OutStr);
        Document.WriteTo(OutStr);
        ShipmentDocument.Modify();
    end;

    procedure HandleSpecialChars(pText: Text[1024]) ReturnText: Text[1024]
    var
        i: Integer;
    begin
        for i := 1 to StrLen(pText) do
            case pText[i] of
                '&':
                    ReturnText += '&amp;';
                '<':
                    ReturnText += '&lt;';
                '>':
                    ReturnText += '&gt;';
                '''':
                    ReturnText += '&apos;';
                '"':
                    ReturnText += '&quot;';
                else
                    ReturnText += Format(pText[i])
            end;
    end;

    local procedure GetIComm()
    begin
        if GotIComm then exit;

        PacsoftSetup.Get();
        GotIComm := true;
    end;
}

