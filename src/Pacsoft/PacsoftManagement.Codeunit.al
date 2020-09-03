codeunit 6014484 "NPR Pacsoft Management"
{
    // NPR6.000.001/LJJ/130114 DeleteEmptyXMLNodes shall not delete ADDON's
    // PS1.00/LS/20140905  CASE 190533 Pacsoft Module
    // NPR4.16/JDH/20151016 CASE 225285 Removed reference to Old NAS module from the OnRun Trigger
    // PS1.01/RA/20160809  CASE 228449 Total refactoring of codeunit


    trigger OnRun()
    begin
        SendDocuments;
    end;

    var
        PacsoftSetup: Record "NPR Pacsoft Setup";
        GotIComm: Boolean;
        Text6014400: Label 'The shipment was allready sent to Pacsoft, do you wish to sent it again?';

    procedure SendDocuments()
    var
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        RecRef: RecordRef;
    begin
        Clear(ShipmentDocument);
        ShipmentDocument.SetCurrentKey("Export Time");
        ShipmentDocument.SetRange("Export Time", 0DT);
        if ShipmentDocument.FindSet then
            repeat
                SendDocument(ShipmentDocument, false);
            until ShipmentDocument.Next = 0;
    end;

    procedure SendDocument(var pShipmentDocument: Record "NPR Pacsoft Shipment Document"; WithDialog: Boolean)
    var
        RecRef: RecordRef;
        TextFile: File;
        oStream: OutStream;
        Filename: Text[250];
        TextMessage: Label 'Document sent.';
        RBMgt: Codeunit "File Management";
    begin
        GetIComm;
        if not PacsoftSetup."Use Pacsoft integration" then exit;


        pShipmentDocument.CalcFields("Request XML");
        Clear(pShipmentDocument."Request XML");
        pShipmentDocument.Modify;

        if WithDialog then begin
            if not Confirm(Text6014400, false) then
                exit;
        end else
            if pShipmentDocument."Export Time" <> 0DT then
                exit;

        pShipmentDocument."Request XML Name" := 'Request ' +
                                                Format(Today) +
                                                ' ' +
                                                Format(Time, 0, '<Hours24,2>-<Minutes,2>-<Seconds,2>') +
                                                ' ' +
                                                Format(pShipmentDocument."Entry No.") +
                                                '.xml';
        pShipmentDocument."Request XML".CreateOutStream(oStream);
        pShipmentDocument.SetRecFilter;
        XMLPORT.Export(XMLPORT::"NPR Pacsoft Shipment Document", oStream, pShipmentDocument);
        pShipmentDocument.Modify;

        //XMLDoc.Save('C\Temp\Test_RAS_nu_1.xml');
        //Filename := TEMPORARYPATH+  'Test_RAS_nu_3.xml';
        //TextFile.CREATE('C:\Temp\Test_RAS_nu_3.xml');
        //TextFile.CREATEOUTSTREAM(oStream);
        //RBMgt.DownloadToFile('C:\Temp\Test_RAS_nu_3.xml', 'C:\Temp\Test_RAS_nu_3.xml');
        //TextFile.CLOSE;
        Clear(oStream);

        RemoveEmptyXmlTags(pShipmentDocument);
        //EXIT;
        SendXML(pShipmentDocument);

        if WithDialog then
            Message(TextMessage);
    end;

    local procedure SendXML(var pShipmentDocument: Record "NPR Pacsoft Shipment Document")
    var
        XMLDoc: DotNet "NPRNetXmlDocument";
        str: DotNet NPRNetStream;
        reader: DotNet NPRNetXmlTextReader;
        document: DotNet "NPRNetXmlDocument";
        StringBuilder: DotNet NPRNetStringBuilder;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        credentials: DotNet NPRNetCredentialCache;
        stream: DotNet NPRNetStreamWriter;
        ascii: DotNet NPRNetEncoding;
        Type: DotNet NPRNetEncoding;
        iStream: InStream;
        iStream2: InStream;
        oStream: OutStream;
        XMLResponce: XMLport "NPR Pacsoft Response";
        URI: Text[250];
    begin
        pShipmentDocument.CalcFields("Request XML");
        if not pShipmentDocument."Request XML".HasValue then
            exit;

        pShipmentDocument."Request XML".CreateInStream(iStream);

        if IsNull(XMLDoc) then
            Clear(XMLDoc);

        XMLDoc := XMLDoc.XmlDocument;
        XMLDoc.CreateXmlDeclaration('1.0', 'UTF-8', 'no');
        XMLDoc.Load(iStream);
        StringBuilder := StringBuilder.StringBuilder;
        //StringBuilder.Append(XMLDoc.xml );
        StringBuilder.Append(XMLDoc.OuterXml);
        URI := StrSubstNo(PacsoftSetup."Send Order URI", PacsoftSetup.Session, PacsoftSetup.User, PacsoftSetup.Pin);

        HttpWebRequest := HttpWebRequest.Create(URI);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.KeepAlive := false;
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Credentials := credentials.DefaultCredentials;
        HttpWebRequest.Timeout := 120000;

        stream := stream.StreamWriter(HttpWebRequest.GetRequestStream(), Type.UTF8);
        stream.Write(StringBuilder.ToString);
        stream.Close();

        HttpWebResponse := HttpWebRequest.GetResponse;
        Clear(HttpWebRequest);

        if HttpWebResponse.StatusCode <> 200 then
            Error(HttpWebResponse.StatusDescription);

        pShipmentDocument."Response XML Name" := 'Response ' +
                                                  Format(Today) +
                                                  ' ' +
                                                  Format(Time, 0, '<Hours24,2>-<Minutes,2>-<Seconds,2>') +
                                                  ' ' +
                                                  Format(pShipmentDocument."Entry No.") +
                                                  '.xml';
        str := HttpWebResponse.GetResponseStream;
        reader := reader.XmlTextReader(str);
        document := document.XmlDocument();
        document.Load(reader);
        pShipmentDocument."Response XML".CreateOutStream(oStream);
        document.Save(oStream);
        pShipmentDocument.Modify;

        Clear(iStream);
        pShipmentDocument."Response XML".CreateInStream(iStream);
        XMLResponce.SetShipmentDocument(pShipmentDocument);
        XMLResponce.SetSource(iStream);
        XMLResponce.Import;
        XMLResponce.GetShipmentDocument(pShipmentDocument);

        if pShipmentDocument.Status = '201' then
            pShipmentDocument."Export Time" := CurrentDateTime;

        pShipmentDocument.Modify;

        reader.Close();
        str.Close();
    end;

    procedure CheckDocument(pShipmentDocument: Record "NPR Pacsoft Shipment Document") OK: Boolean
    var
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentService: Record "Shipping Agent Services";
        ShipDocService: Record "NPR Pacsoft Shipm. Doc. Serv.";
        CustomsItemRows: Record "NPR Pacsoft Customs Item Rows";
        CompanyInfo: Record "Company Information";
        Found: Boolean;
        TextNoNotification: Label 'Please select a Notification service';
        TextNoItemRows: Label 'Please fill at least one Customs Item Row.';
        TextBeforeToday: Label 'must be today or later.';
        TextNoCustomsDocument: Label 'can not be blank.';
    begin
        with pShipmentDocument do begin
            if "Entry No." = 0 then exit;

            TestField("Receiver ID");
            TestField(Name);
            TestField(Address);
            TestField("Post Code");
            TestField(City);
            TestField("Country/Region Code");
            TestField("Shipment Date");
            if "Shipment Date" < Today then
                FieldError("Shipment Date", TextBeforeToday);

            TestField("Shipping Agent Code");
            ShippingAgent.Get("Shipping Agent Code");
            ShippingAgent.TestField("NPR Pacsoft Product");
            case ShippingAgent."NPR Shipping Agent Demand" of
                ShippingAgent."NPR Shipping Agent Demand"::" ":
                    ;
                ShippingAgent."NPR Shipping Agent Demand"::"Select a Service":
                    begin
                        Found := false;
                        Clear(ShipDocService);
                        ShipDocService.SetCurrentKey("Entry No.", "Shipping Agent Code");
                        ShipDocService.SetRange("Entry No.", "Entry No.");
                        if ShipDocService.FindSet then
                            repeat
                                ShippingAgentService.Get("Shipping Agent Code", ShipDocService."Shipping Agent Service Code");
                                case ShippingAgentService."NPR Service Demand" of
                                    ShippingAgentService."NPR Service Demand"::"Selected E-mail":
                                        TestField("E-Mail");
                                    ShippingAgentService."NPR Service Demand"::"Selected Mobile No.":
                                        TestField("SMS No.");
                                end;
                                if ShippingAgentService."NPR Notification Service" then
                                    Found := true;
                            until (Found) or (ShipDocService.Next = 0);
                        if not Found then
                            Error(TextNoNotification);
                    end;
                ShippingAgent."NPR Shipping Agent Demand"::"Customs Information":
                    begin
                        if "Customs Document" = "Customs Document"::" " then
                            FieldError("Customs Document", TextNoCustomsDocument);
                        TestField("Customs Currency");
                        TestField("Total Weight");
                        Found := false;
                        Clear(CustomsItemRows);
                        CustomsItemRows.SetCurrentKey("Shipment Document Entry No.", "Entry No.");
                        CustomsItemRows.SetRange("Shipment Document Entry No.", "Entry No.");
                        if CustomsItemRows.FindSet then
                            repeat
                                Found := true;
                                if "Customs Document" <> "Customs Document"::CN23 then
                                    CustomsItemRows.TestField("Item Code");
                                CustomsItemRows.TestField(Copies);
                                CustomsItemRows.TestField("Customs Value");
                                CustomsItemRows.TestField(Content);
                                if "Customs Document" <> "Customs Document"::CN23 then
                                    CustomsItemRows.TestField("Country of Origin");
                            until CustomsItemRows.Next = 0;

                        if not Found then
                            Error(TextNoItemRows);
                    end;
            end;

            if "Send Link To Print" then begin
                CompanyInfo.Get;
                CompanyInfo.TestField("E-Mail");
                TestField("E-Mail");
            end;
        end;

        OK := true;
        exit(OK);
    end;

    procedure RemoveEmptyXmlTags(var pShipmentDocument: Record "NPR Pacsoft Shipment Document")
    var
        XMLDoc: DotNet "NPRNetXmlDocument";
        XmlDocNode: DotNet NPRNetXmlNode;
        iStream: InStream;
        oStream: OutStream;
        RBMgt: Codeunit "File Management";
    begin
        //RemoveEmptyXmlTags
        pShipmentDocument.CalcFields("Request XML");
        if not pShipmentDocument."Request XML".HasValue then
            exit;

        pShipmentDocument."Request XML".CreateInStream(iStream);

        if not IsNull(XMLDoc) then
            Clear(XMLDoc);

        XMLDoc := XMLDoc.XmlDocument;
        XMLDoc.CreateXmlDeclaration('1.0', 'UTF-8', 'no');
        //XMLDoc.Save('C\Temp\Test_RAS_nu_1.xml');
        //RBMgt.DownloadToFile('C\Temp\Test_RAS_nu_1.xml', 'C\Temp\Test_RAS_nu_1.xml');


        XMLDoc.Load(iStream);
        XmlDocNode := XMLDoc.DocumentElement;
        DeleteEmptyXMLNodes(XmlDocNode);

        //pShipmentDocument.CALCFIELDS("Request XML");
        Clear(pShipmentDocument."Request XML");
        pShipmentDocument.Modify;

        pShipmentDocument."Request XML".CreateOutStream(oStream);
        //XMLDoc.Save('C\Temp\Test_RAS_nu_2.xml');
        //RBMgt.DownloadToFile('C\Temp\Test_RAS_nu_2.xml', 'C\Temp\Test_RAS_nu_2.xml');
        //XMLDoc.Save(TEMPORARYPATH + 'Test_RAS_nu_1.xml');
        //RBMgt.DownloadToFile(TEMPORARYPATH + 'Test_RAS_nu_1.xml', 'C:\Temp\Test_RAS_nu_1.xml');
        //EXIT;

        XMLDoc.Save(oStream);
        pShipmentDocument.Modify;
    end;

    procedure DeleteEmptyXMLNodes(var XmlDocNode: DotNet NPRNetXmlNode): Boolean
    var
        XMLChildNode: DotNet NPRNetXmlNode;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        XmlNodeType: DotNet NPRNetXmlNodeType;
        i: Integer;
        y: Integer;
        NetConvHelper: Variant;
    begin
        //DeleteEmptyXMLNodes
        XmlNodeType := XmlDocNode.NodeType;
        if XmlNodeType.ToString = 'Element' then begin
            if XmlDocNode.HasChildNodes = false then begin
                if (StrPos(XmlDocNode.OuterXml, '/>') > 0) and (StrPos(XmlDocNode.OuterXml, 'addon') = 0) then begin
                    NetConvHelper := XmlDocNode.ParentNode.RemoveChild(XmlDocNode);
                    XmlNodeType := NetConvHelper;
                    exit(true);
                end;
            end else begin
                XmlNodeList := XmlDocNode.ChildNodes;
                i := XmlNodeList.Count;
                y := 0;
                while i > y do begin
                    XMLChildNode := XmlNodeList.Item(y);
                    if not DeleteEmptyXMLNodes(XMLChildNode) then
                        y += 1
                    else
                        i -= 1;
                end;
            end;
        end;

        exit(false);
    end;

    procedure HandleSpecialChars(pText: Text[1024]) ReturnText: Text[1024]
    var
        i: Integer;
    begin
        //CLEAR(ReturnText);

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

        //EXIT(ReturnText);
    end;

    local procedure GetIComm()
    begin
        if GotIComm then exit;

        PacsoftSetup.Get;
        GotIComm := true;
    end;
}

