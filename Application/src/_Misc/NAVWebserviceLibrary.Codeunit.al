codeunit 6014595 "NPR NAV Webservice Library"
{

    trigger OnRun()
    begin
    end;

    var
        ParameterList: Text;
        HttpStatusMsg: Text;
        ResultNode: DotNet NPRNetXmlNode;
        ResultDocument: DotNet "NPRNetXmlDocument";
        "--": Integer;
        ServiceNamespace: Text;
        ServicePassword: Text;
        ServiceDomainName: Text;
        ServiceUserName: Text;
        ServiceUrl: Text;
        ServiceBaseUrl: Text;
        ServiceCompanyName: Text;
        ServiceInstanceName: Text;
        ServiceType: Text;
        ServiceName: Text;
        ServiceMethod: Text;

    procedure InvokeWithResponse(var ReturnValue: Text; var NodeList: DotNet NPRNetXmlNodeList) Result: Boolean
    var
        XMLDocument: DotNet "NPRNetXmlDocument";
        StringLibrary: Codeunit "NPR String Library";
        ReturnStatusCode: Integer;
        Company: Text[250];
        HttpStatus: Text;
        Variables: Text[1024];
    begin
        Result := false;

        XMLDocument := XMLDocument.XmlDocument();

        // Create SOAP Envelope
        BuildRequestEnvelope(XMLDocument);

        // Invoke the service
        ReturnStatusCode := InvokeWebService(Url, ServiceDomainName, ServiceUserName, ServicePassword, XMLDocument);

        // If status is OK - Get Result XML
        if ReturnStatusCode = 200 then begin
            SelectNode(StrSubstNo('%1_Result', ServiceMethod), NameSpace, XMLDocument, ResultNode);
            ReturnValue := ResultNode.InnerText;
            exit(true)
        end else begin
            ReturnValue := StrSubstNo('ERROR On the Communication Channel : %1', ReturnStatusCode);
            exit(false);
        end;
    end;

    procedure InvokeWebService(Url: Text; Domain: Text; Username: Text; Password: Text; var XMLDocument: DotNet "NPRNetXmlDocument") ReturnStatus: Integer
    var
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        NetworkCredentials: DotNet NPRNetNetworkCredential;
        RequestStream: DotNet NPRNetStreamWriter;
        NetConvHelper: Variant;
    begin
        // Create XMLHTTP and SEND
        HttpWebRequest := HttpWebRequest.Create(Url);
        NetworkCredentials := NetworkCredentials.NetworkCredential();

        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.Headers.Add('SOAPAction', ServiceMethod);

        NetworkCredentials.Password := Password;
        NetworkCredentials.UserName := Username;
        NetworkCredentials.Domain := Domain;
        HttpWebRequest.Credentials := NetworkCredentials;

        NetConvHelper := HttpWebRequest.GetRequestStream();
        RequestStream := NetConvHelper;

        XMLDocument.Save(RequestStream);

        HttpWebResponse := HttpWebRequest.GetResponse();
        if HttpWebResponse.StatusCode <> 200 then Message(HttpWebResponse.StatusDescription);
        XMLDocument.Load(HttpWebResponse.GetResponseStream());

        ResultDocument := XMLDocument;

        exit(HttpWebResponse.StatusCode);
    end;

    procedure BuildRequestEnvelope(var XMLDocument: DotNet "NPRNetXmlDocument")
    var
        Node: DotNet NPRNetXmlNode;
        SoapEnvelope: DotNet NPRNetXmlElement;
        SoapBody: DotNet NPRNetXmlElement;
        SoapMethod: DotNet NPRNetXmlElement;
        XMLDocumentParams: DotNet "NPRNetXmlDocument";
    begin
        SoapEnvelope := XMLDocument.CreateElement('Soap', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        SoapEnvelope.SetAttribute('xmlns:Soap', 'http://schemas.xmlsoap.org/soap/envelope/');
        XMLDocument.PreserveWhitespace(true);
        XMLDocument.AppendChild(SoapEnvelope);

        // Create SOAP Body
        SoapBody := XMLDocument.CreateElement('Soap', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        SoapEnvelope.AppendChild(SoapBody);

        // Create Method Element
        SoapMethod := XMLDocument.CreateElement(ServiceMethod);
        SoapMethod.SetAttribute('xmlns', NameSpace);
        SoapBody.AppendChild(SoapMethod);

        // Transfer parameters by loading them into a XML Document and move them
        XMLDocumentParams := XMLDocumentParams.XmlDocument();
        XMLDocumentParams.LoadXml('<parameters>' + ParameterList + '</parameters>');
        XMLDocumentParams.PreserveWhitespace(true);
        if XMLDocumentParams.FirstChild.HasChildNodes then begin
            while XMLDocumentParams.FirstChild.ChildNodes.Count > 0 do begin
                Node := XMLDocumentParams.FirstChild.FirstChild;
                Node := XMLDocumentParams.FirstChild.RemoveChild(Node);
                Node := SoapMethod.OwnerDocument.ImportNode(Node, true);
                SoapMethod.AppendChild(Node);
            end;
        end;
    end;

    procedure SelectNodes(Name: Text; NameSpace: Text; var XMLDocument: DotNet "NPRNetXmlDocument"; var NodeList: DotNet NPRNetXmlNodeList)
    var
        XMLNameSpaceManager: DotNet NPRNetXmlNamespaceManager;
        XMLNameTable: DotNet NPRNetXmlNameTable;
    begin
        XMLNameSpaceManager := XMLNameSpaceManager.XmlNamespaceManager(XMLDocument.NameTable);
        XMLNameSpaceManager.AddNamespace('tns', NameSpace);
        NodeList := XMLDocument.SelectNodes(StrSubstNo('//tns:%1', Name), XMLNameSpaceManager);
    end;

    procedure SelectNode(Name: Text; NameSpace: Text; var XMLDocument: DotNet "NPRNetXmlDocument"; var Node: DotNet NPRNetXmlNode)
    var
        XMLNameSpaceManager: DotNet NPRNetXmlNamespaceManager;
        XMLNameTable: DotNet NPRNetXmlNameTable;
    begin
        XMLNameSpaceManager := XMLNameSpaceManager.XmlNamespaceManager(XMLDocument.NameTable);
        XMLNameSpaceManager.AddNamespace('tns', NameSpace);
        Node := XMLDocument.SelectSingleNode(StrSubstNo('//tns:%1', Name), XMLNameSpaceManager);
    end;

    procedure StoreXMLClientSide(var XMLDocument: DotNet "NPRNetXmlDocument"; Path: Text)
    var
        [RunOnClient]
        StreamWriter: DotNet NPRNetStreamWriter;
    begin
        StreamWriter := StreamWriter.StreamWriter(Path, false);
        StreamWriter.Write(XMLDocument.OuterXml);
        StreamWriter.Close();
    end;

    procedure Reset()
    begin
        ParameterList := '';
        ServiceMethod := '';
        ServiceType := '';
    end;

    procedure AddParameter(Name: Text; Value: Text)
    var
        Parameter: Text;
    begin
        Parameter := StrSubstNo('<%1>%2</%1>', Name, Value);
        ParameterList := ParameterList + Parameter;
    end;

    local procedure "-- Context"()
    begin
    end;

    local procedure Url() Url: Text
    begin
        if ServiceUrl <> '' then
            exit(ServiceUrl)
        else
            Url := StrSubstNo('%1/%2/ws/%3/%4/%5', ServiceBaseUrl, ServiceInstanceName, ServiceCompanyName, ServiceType, ServiceName)
    end;

    local procedure NameSpace() NameSpace: Text
    begin
        if LowerCase(ServiceType) = 'page' then
            NameSpace := StrSubstNo('urn:microsoft-dynamics-schemas/%1/%2', LowerCase(ServiceType), LowerCase(ServiceName))
        else
            NameSpace := StrSubstNo('urn:microsoft-dynamics-schemas/%1/%2', LowerCase(ServiceType), ServiceName);
    end;

    procedure "-- Result Accessors"()
    begin
    end;

    procedure GetNodeValue(NodeName: Text): Text
    var
        Node: DotNet NPRNetXmlNode;
    begin
        SelectNode(NodeName, NameSpace, ResultDocument, Node);
        exit(Node.InnerText)
    end;

    procedure "-- Properties"()
    begin
    end;

    procedure UsePassword(PasswordIn: Text)
    begin
        ServicePassword := PasswordIn;
    end;

    procedure UseDomainName(DomainNameIn: Text)
    begin
        ServiceDomainName := DomainNameIn;
    end;

    procedure UseUserName(UsernameIn: Text)
    begin
        ServiceUserName := UsernameIn
    end;

    procedure UseUrl(UrlIn: Text)
    begin
        ServiceUrl := UrlIn;
    end;

    procedure UseBaseUrl(ServiceBaseUrlIn: Text)
    begin
        ServiceBaseUrl := ServiceBaseUrlIn;
    end;

    procedure UseCompanyName(ServiceCompanyNameIn: Text)
    var
        StringLibrary: Codeunit "NPR String Library";
    begin
        StringLibrary.Construct(ServiceCompanyNameIn);
        StringLibrary.Replace(' ', '%20');
        ServiceCompanyName := StringLibrary.Text;
    end;

    procedure UseServiceInstanceName(ServiceInstanceNameIn: Text)
    begin
        ServiceInstanceName := ServiceInstanceNameIn;
    end;

    procedure UseServiceType(ServiceTypeIn: Text)
    begin
        ServiceType := ServiceTypeIn;
    end;

    procedure UseServiceName(ServiceNameIn: Text)
    begin
        ServiceName := ServiceNameIn;
    end;

    procedure UseServiceMethod(ServiceMethodIn: Text)
    begin
        ServiceMethod := ServiceMethodIn;
    end;
}

