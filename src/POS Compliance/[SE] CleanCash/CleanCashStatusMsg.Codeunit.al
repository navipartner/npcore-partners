codeunit 6014461 "NPR CleanCash Status Msg." implements "NPR CleanCash XCCSP Interface"
{


    procedure CreateRequest(PosUnitNo: Code[10]; var EntryNo: Integer): Boolean
    var
        CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request";
        CleanCashSetup: Record "NPR CleanCash Setup";
    begin

        CleanCashSetup.Get(PosUnitNo);

        CleanCashTransactionRequest.Init();
        CleanCashTransactionRequest."Entry No." := 0;
        CleanCashTransactionRequest."Organisation No." := CleanCashSetup."Organization ID";
        CleanCashTransactionRequest."Pos Id" := CleanCashSetup."CleanCash Register No.";
        CleanCashTransactionRequest."POS Unit No." := PosUnitNo;
        CleanCashTransactionRequest."Request Type" := CleanCashTransactionRequest."Request Type"::StatusRequest;
        CleanCashTransactionRequest.Insert();
        EntryNo := CleanCashTransactionRequest."Entry No.";

        exit(true);
    end;

    procedure CreateRequest(PosEntry: Record "NPR POS Entry"; RequestType: Enum "NPR CleanCash Request Type"; var EntryNo: Integer): Boolean
    begin
        exit(CreateRequest(PosEntry."POS Unit No.", EntryNo));
    end;


    procedure GetRequestXml(CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; var XmlDoc: XmlDocument) Success: Boolean;
    var
        CleanCashXCCSPProtocol: Codeunit "NPR CleanCash XCCSP Protocol";
        DebugText: Text;
        XmlNs: Text;
        Declaration: XmlDeclaration;
        Data: XmlElement;
        Envelope: XmlElement;
        StatusRequest: XmlElement;
    begin

        XmlNs := CleanCashXCCSPProtocol.GetNamespace();

        StatusRequest := XmlElement.Create('StatusRequest', XmlNs);
        StatusRequest.Add(CleanCashXCCSPProtocol.AddElement('PosId', CleanCashTransactionRequest."Pos Id", XmlNs));
        StatusRequest.Add(CleanCashXCCSPProtocol.AddElement('OrgNo', CleanCashTransactionRequest."Organisation No.", XmlNs));

        Data := XmlElement.Create('data', XmlNs);
        Data.Add(StatusRequest);

        Envelope := XmlElement.Create('request', XmlNs);
        Envelope.Add(CleanCashXCCSPProtocol.AddElement('type', 'RequestStatus', XmlNs));
        Envelope.Add(Data);

        XmlDoc := XmlDocument.Create();
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'ISO-8859-1', 'yes'));

        XmlDoc.Add(Envelope);

        exit(true);

    end;

    procedure SerializeResponse(var CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; XmlDoc: XmlDocument; var ResponseEntryNo: Integer) Success: Boolean
    var
        CleanCashResponse: Record "NPR CleanCash Trans. Response";
        CleanCashXCCSPProtocol: Codeunit "NPR CleanCash XCCSP Protocol";
        DebugText: Text;
        EnumAsText: Text;
        DataElement: XmlElement;
        Element: XmlElement;
        NamespaceManager: XmlNamespaceManager;
        Node: XmlNode;
    begin

        CleanCashResponse.SetFilter("Request Entry No.", '=%1', CleanCashTransactionRequest."Entry No.");
        if (not CleanCashResponse.FindLast()) then
            CleanCashResponse."Request Entry No." := CleanCashTransactionRequest."Entry No.";
        CleanCashResponse."Response No." += 1;
        CleanCashResponse.Init();

        CleanCashResponse."Response Datetime" := CurrentDateTime();

        NamespaceManager.NameTable(XmlDoc.NameTable());
        NamespaceManager.AddNamespace('cc', CleanCashXCCSPProtocol.GetNamespace());
        XmlDoc.GetRoot(Element);

        if (Element.SelectSingleNode('cc:type[text()="Fault"]', NamespaceManager, Node)) then
            CleanCashXCCSPProtocol.SerializeFaultInfo(Element, NamespaceManager, CleanCashResponse);

        if (Element.SelectSingleNode('cc:type[text()="StatusResponse"]', NamespaceManager, Node)) then begin

            if (Element.SelectSingleNode('cc:data', NamespaceManager, Node)) then begin
                DataElement := Node.AsXmlElement();
                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:Status/cc:Id', CleanCashResponse."CleanCash Unit Id");
                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:Status/cc:Firmware', CleanCashResponse."CleanCash Firmware");
                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:Status/cc:InstalledLicenses', CleanCashResponse."Installed Licenses");

                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:Status/cc:MainStatus', EnumAsText);
                evaluate(CleanCashResponse."CleanCash Main Status", EnumAsText);

                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:Status/cc:StorageStatus', EnumAsText);
                evaluate(CleanCashResponse."CleanCash Storage Status", EnumAsText);

                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:Status/cc:Type', EnumAsText);
                evaluate(CleanCashResponse."CleanCash Type", EnumAsText);

            end;
        end;

        exit(CleanCashResponse.Insert());

    end;

    procedure AddToPrintBuffer(var LinePrintMgt: Codeunit "NPR RP Line Print Mgt."; var CleanCashTransaction: Record "NPR CleanCash Trans. Request")
    begin

    end;

}