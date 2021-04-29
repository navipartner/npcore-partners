codeunit 6151551 "NPR NpXml Mgt."
{
    trigger OnRun()
    begin
        CreateXml();
    end;

    var
        NpXmlTemplate2: Record "NPR NpXml Template";
        OutputTempBlob: Codeunit "Temp Blob";
        ResponseTempBlob: Codeunit "Temp Blob";
        Error002: Label 'Record in %1 within the filters does not exist';
        Error003: Label 'Upload failed with status code: %1 and description: %2';
        Error004: Label 'Authorization failed. Wrong FTP username/password.';
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NpXmlValueMgt: Codeunit "NPR NpXml Value Mgt.";
        RecRef: RecordRef;
        OutputOutStr: OutStream;
        ResponseOutStr: OutStream;
        Window: Dialog;
        PrimaryKeyValue: Text;
        Text002: Label 'Exporting %1 to XML\Exporting:           @2@@@@@@@@@@@@@@@@@@@\Estimated Time Left: #3###################\Record:       #4###########################';
        HideDialog: Boolean;
        Initialized: Boolean;
        OutputInitialized: Boolean;
        Text200: Label 'Finding first record in %1 within the filters: @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\Estimated Time Left:                           #3##############################\Record:  #4####################################################################';

    procedure CreateXml()
    var
        Node: XmlNode;
        Document: XmlDocument;
        Counter: Integer;
        XmlEntityCount: Integer;
        Total: Integer;
        StartTime: Time;
        RecordSetExists: Boolean;
    begin
        if not Initialized then
            exit;

        Initialized := false;
        StartTime := Time;
        Counter := 0;
        Total := RecRef.Count;
        OpenDialog(StrSubstNo(Text002, NpXmlTemplate2.Code));

        if NpXmlTemplate2."Max Records per File" <= 0 then
            NpXmlTemplate2."Max Records per File" := 10000000;

        XmlEntityCount := 0;
        NpXmlDomMgt.InitDoc(Document, Node, NpXmlTemplate2."Xml Root Name", NpXmlTemplate2."Custom Namespace for XMLNS");
        NpXmlDomMgt.AddRootAttributes(Node, NpXmlTemplate2);
        RecordSetExists := RecRef.FindSet();
        repeat
            Counter += 1;
            UpdateDialog(Counter, Total, StartTime, RecRef.GetPosition);

            if ParseDataToXmlDocNode(RecRef, RecordSetExists, Node) then
                XmlEntityCount += 1;

            if XmlEntityCount >= NpXmlTemplate2."Max Records per File" then begin
                FinalizeDoc(Document, NpXmlTemplate2, GetFilename(NpXmlTemplate2."Xml Root Name", PrimaryKeyValue, Counter));
                XmlEntityCount := 0;
                NpXmlDomMgt.InitDoc(Document, Node, NpXmlTemplate2."Xml Root Name", NpXmlTemplate2."Custom Namespace for XMLNS");
                NpXmlDomMgt.AddRootAttributes(Node, NpXmlTemplate2);
            end;
        until RecRef.Next = 0;

        if XmlEntityCount > 0 then
            FinalizeDoc(Document, NpXmlTemplate2, GetFilename(NpXmlTemplate2."Xml Root Name", PrimaryKeyValue, Counter));

        Clear(Document);
        CloseDialog;
    end;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    procedure ParseDataToXmlDocNode(var RecRef: RecordRef; RecordSetExists: Boolean; var XmlDocNode: DotNet NPRNetXmlNode) Success: Boolean
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef2: RecordRef;
    begin
        if IsNull(XmlDocNode) then
            exit(false);

        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate2.Code);
        NpXmlElement.SetFilter("Parent Line No.", '=%1', 0);
        NpXmlElement.SetRange(Active, true);
        if not NpXmlElement.FindSet then
            exit(false);

        Success := true;
        repeat
            SetRecRefXmlFilter(NpXmlElement, RecRef, RecRef2);
            if RecordSetExists or (RecRef.Number <> RecRef2.Number) then begin
                if RecRef2.FindSet then
                    repeat
                        Success := AddXmlElement(XmlDocNode, NpXmlElement, RecRef2, 0) and Success;
                    until RecRef2.Next = 0;
            end else
                Success := AddXmlElement(XmlDocNode, NpXmlElement, RecRef2, 0);
            RecRef2.Close;
        until NpXmlElement.Next = 0;

        exit(Success);
    end;

    procedure ParseDataToXmlDocNode(var RecRef: RecordRef; RecordSetExists: Boolean; var Node: XmlNode) Success: Boolean
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef2: RecordRef;
    begin
        if not Node.IsXmlElement then
            exit(false);

        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate2.Code);
        NpXmlElement.SetFilter("Parent Line No.", '=%1', 0);
        NpXmlElement.SetRange(Active, true);
        if not NpXmlElement.FindSet then
            exit(false);

        Success := true;
        repeat
            SetRecRefXmlFilter(NpXmlElement, RecRef, RecRef2);
            if RecordSetExists or (RecRef.Number <> RecRef2.Number) then begin
                if RecRef2.FindSet then
                    repeat
                        Success := AddXmlElement(Node, NpXmlElement, RecRef2, 0) and Success;
                    until RecRef2.Next = 0;
            end else
                Success := AddXmlElement(Node, NpXmlElement, RecRef2, 0);
            RecRef2.Close;
        until NpXmlElement.Next = 0;

        exit(Success);
    end;

    procedure Initialize(NewNpXmlTemplate: Record "NPR NpXml Template"; var NewRecRef: RecordRef; NewPrimaryKeyValue: Text; NewHideDialog: Boolean)
    begin
        NpXmlTemplate2 := NewNpXmlTemplate;
        RecRef := NewRecRef;
        PrimaryKeyValue := NewPrimaryKeyValue;
        HideDialog := NewHideDialog;
        Initialized := true;
    end;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    local procedure AddXmlElement(var XmlNode: DotNet NPRNetXmlNode; NpXmlElement: Record "NPR NpXml Element"; var RecRef: RecordRef; CurrLevel: Integer) LevelAppended: Boolean
    var
        NewXmlNode: DotNet NPRNetXmlElement;
        NpXmlElementChild: Record "NPR NpXml Element";
        RecRefFilter: RecordRef;
        RecRefChild: RecordRef;
        XmlComment: DotNet NPRNetXmlComment;
        Finished: Boolean;
        ElementName: Text;
        Namespace: Text;
    begin
        if not NpXmlElement.Active then
            exit;

        Clear(RecRefFilter);
        RecRefFilter.Open(RecRef.Number);
        RecRefFilter := RecRef.Duplicate;
        RecRefFilter.SetRecFilter;

        if not NpXmlElement.Hidden then begin
            ElementName := GetXmlElementName(NpXmlElement);
            Namespace := GetXmlNamespace(NpXmlElement);
            NpXmlDomMgt.AddElementNamespace(XmlNode, ElementName, Namespace, NewXmlNode);
            AddXmlValue(NewXmlNode, NpXmlElement, RecRefFilter);
        end else
            NewXmlNode := XmlNode;

        Clear(NpXmlElementChild);
        NpXmlElementChild.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlElementChild.SetRange("Parent Line No.", NpXmlElement."Line No.");
        NpXmlElementChild.SetRange(Active, true);
        if NpXmlElementChild.FindSet then
            repeat
                SetRecRefXmlFilter(NpXmlElementChild, RecRefFilter, RecRefChild);
                if RecRefChild.FindSet then
                    repeat
                        AddXmlElement(NewXmlNode, NpXmlElementChild, RecRefChild, CurrLevel + 1);
                    until RecRefChild.Next = 0;
            until (NpXmlElementChild.Next = 0);

        if NpXmlElement.Hidden then
            exit(true);

        NewXmlNode.IsEmpty(NewXmlNode.InnerXml = '');
        if NpXmlElement."Only with Value" and NewXmlNode.IsEmpty then
            XmlNode.RemoveChild(NewXmlNode)
        else
            if NpXmlElement.Comment <> '' then begin
                XmlComment := XmlNode.OwnerDocument.CreateComment(NpXmlElement.Comment);
                XmlNode.InsertBefore(XmlComment, NewXmlNode);
            end;

        exit(true);
    end;

    local procedure AddXmlElement(var Node: XmlNode; NpXmlElement: Record "NPR NpXml Element"; var RecRef: RecordRef; CurrLevel: Integer) LevelAppended: Boolean
    var
        NewXmlNode: XmlNode;
        NpXmlElementChild: Record "NPR NpXml Element";
        RecRefFilter: RecordRef;
        RecRefChild: RecordRef;
        Namespace: Text;
        ChildNodesList: XmlNodeList;
        ChildNode: XmlNode;
    begin
        if not NpXmlElement.Active then
            exit;

        Clear(RecRefFilter);
        RecRefFilter.Open(RecRef.Number);
        RecRefFilter := RecRef.Duplicate;
        RecRefFilter.SetRecFilter;

        if not NpXmlElement.Hidden then begin
            Namespace := GetXmlNamespace(NpXmlElement);
            NpXmlDomMgt.AddElementNamespace(Node, NpXmlElement."Element Name", Namespace, NewXmlNode);
            AddXmlValue(NewXmlNode, NpXmlElement, RecRefFilter);
        end else
            NewXmlNode := Node;

        Clear(NpXmlElementChild);
        NpXmlElementChild.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlElementChild.SetRange("Parent Line No.", NpXmlElement."Line No.");
        NpXmlElementChild.SetRange(Active, true);
        if NpXmlElementChild.FindSet then
            repeat
                SetRecRefXmlFilter(NpXmlElementChild, RecRefFilter, RecRefChild);
                if RecRefChild.FindSet then
                    repeat
                        AddXmlElement(NewXmlNode, NpXmlElementChild, RecRefChild, CurrLevel + 1);
                    until RecRefChild.Next = 0;
            until (NpXmlElementChild.Next = 0);

        if NpXmlElement.Hidden then
            exit(true);

        if NewXmlNode.AsXmlElement.InnerXml = '' then begin
            ChildNodesList := NewXmlNode.AsXmlElement.GetChildNodes();
            foreach ChildNode in ChildNodesList do
                ChildNode.Remove();
        end;


        if NpXmlElement."Only with Value" then begin
            if NewXmlNode.AsXmlElement.IsEmpty OR (NewXmlNode.AsXmlElement.InnerXml = '') then
                NewXmlNode.Remove();
        end else
            if NpXmlElement.Comment <> '' then
                NewXmlNode.AddBeforeSelf(XmlComment.Create(NpXmlElement.Comment));

        exit(true);
    end;

    local procedure AddXmlNamespaces(NpXmlTemplate: Record "NPR NpXml Template"; var XmlDoc: XmlDocument)
    var
        NpXmlNamespaces: Record "NPR NpXml Namespace";
        Element: XmlElement;
    begin
        if not NpXmlTemplate."Namespaces Enabled" then
            exit;

        NpXmlNamespaces.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if not NpXmlNamespaces.FindSet then
            exit;

        XmlDoc.GetRoot(Element);
        repeat
            NpXmlDomMgt.AddNamespaceDeclaration(Element, NpXmlNamespaces.Alias, NpXmlNamespaces.Namespace);
        until NpXmlNamespaces.Next = 0;
    end;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    local procedure AddXmlValue(var XmlNode: DotNet NPRNetXmlElement; var NPXmlElement: Record "NPR NpXml Element"; RecRef: RecordRef)
    var
        NpXmlAttribute: Record "NPR NpXml Attribute";
        NPXmlElement2: Record "NPR NpXml Element";
        NpXmlNamespace: Record "NPR NpXml Namespace";
        XmlCDATA: DotNet NPRNetXmlCDataSection;
        AttributeValue: Text;
        ElementValue: Text;
    begin
        ElementValue := '';
        Clear(NpXmlAttribute);
        NpXmlAttribute.SetRange("Xml Template Code", NPXmlElement."Xml Template Code");
        NpXmlAttribute.SetRange("Xml Element Line No.", NPXmlElement."Line No.");
        NpXmlAttribute.SetFilter("Attribute Name", '<>%1', '');
        if NpXmlAttribute.FindSet then
            repeat
                AttributeValue := '';
                if NpXmlAttribute."Attribute Field No." <> 0 then
                    NPXmlElement2 := NPXmlElement;
                if NpXmlAttribute."Default Field Type" then
                    NPXmlElement2."Field Type" := NPXmlElement2."Field Type"::" ";
                if NpXmlAttribute."Default Field Type" then begin
                    NPXmlElement2."Custom Codeunit ID" := 0;
                    NPXmlElement2."Xml Value Codeunit ID" := 0;
                end;
                AttributeValue := NpXmlValueMgt.GetXmlValue(RecRef, NPXmlElement2, NpXmlAttribute."Attribute Field No.");
                if (NpXmlAttribute."Default Value" <> '') and (AttributeValue = '') then
                    AttributeValue := NpXmlAttribute."Default Value";
                if NpXmlAttribute.Namespace = '' then
                    NpXmlDomMgt.AddAttribute(XmlNode, NpXmlAttribute."Attribute Name", AttributeValue)
                else begin
                    NpXmlNamespace.Get(NpXmlAttribute."Xml Template Code", NpXmlAttribute.Namespace);
                    NpXmlDomMgt.AddAttributeNamespace(XmlNode, NpXmlAttribute.Namespace + ':' + NpXmlAttribute."Attribute Name", NpXmlNamespace.Namespace, AttributeValue);
                end;
            until NpXmlAttribute.Next = 0;

        if NPXmlElement."Field No." <> 0 then
            ElementValue := NpXmlValueMgt.GetXmlValue(RecRef, NPXmlElement, NPXmlElement."Field No.");
        if (NPXmlElement."Default Value" <> '') and (ElementValue = '') then
            ElementValue := NPXmlElement."Default Value";
        XmlNode.IsEmpty(ElementValue = '');
        if NPXmlElement.CDATA then begin
            if ElementValue <> '' then begin
                XmlCDATA := XmlNode.OwnerDocument.CreateCDataSection('');
                XmlNode.AppendChild(XmlCDATA);
                XmlCDATA.AppendData(ElementValue);
            end;
        end else
            XmlNode.InnerText := ElementValue;
    end;

    local procedure AddXmlValue(var Node: XmlNode; var NPXmlElement: Record "NPR NpXml Element"; RecRef: RecordRef)
    var
        NpXmlAttribute: Record "NPR NpXml Attribute";
        NPXmlElement2: Record "NPR NpXml Element";
        NpXmlNamespace: Record "NPR NpXml Namespace";
        ChildNodesList: XmlNodeList;
        ChildNode: XmlNode;
        CData: XmlCData;
        Element: XmlElement;
        AttributeValue: Text;
        ElementValue: Text;
        NewElement: XmlElement;
        NodeElement: XmlElement;
        AttributeCollection: XmlAttributeCollection;
        Attribute: XmlAttribute;
    begin
        ElementValue := '';
        Clear(NpXmlAttribute);
        NpXmlAttribute.SetRange("Xml Template Code", NPXmlElement."Xml Template Code");
        NpXmlAttribute.SetRange("Xml Element Line No.", NPXmlElement."Line No.");
        NpXmlAttribute.SetFilter("Attribute Name", '<>%1', '');
        if NpXmlAttribute.FindSet then
            repeat
                AttributeValue := '';
                if NpXmlAttribute."Attribute Field No." <> 0 then
                    NPXmlElement2 := NPXmlElement;
                if NpXmlAttribute."Default Field Type" then
                    NPXmlElement2."Field Type" := NPXmlElement2."Field Type"::" ";
                if NpXmlAttribute."Default Field Type" then begin
                    NPXmlElement2."Custom Codeunit ID" := 0;
                    NPXmlElement2."Xml Value Codeunit ID" := 0;
                end;
                AttributeValue := NpXmlValueMgt.GetXmlValue(RecRef, NPXmlElement2, NpXmlAttribute."Attribute Field No.");
                if (NpXmlAttribute."Default Value" <> '') and (AttributeValue = '') then
                    AttributeValue := NpXmlAttribute."Default Value";
                if NpXmlAttribute.Namespace = '' then
                    NpXmlDomMgt.AddAttribute(Node, NpXmlAttribute."Attribute Name", AttributeValue)
                else begin
                    NpXmlNamespace.Get(NpXmlAttribute."Xml Template Code", NpXmlAttribute.Namespace);
                    NpXmlDomMgt.AddAttributeNamespace(Node, NpXmlAttribute.Namespace, NpXmlAttribute."Attribute Name", NpXmlNamespace.Namespace, AttributeValue);
                end;
            until NpXmlAttribute.Next = 0;

        if NPXmlElement."Field No." <> 0 then
            ElementValue := NpXmlValueMgt.GetXmlValue(RecRef, NPXmlElement, NPXmlElement."Field No.");
        if (NPXmlElement."Default Value" <> '') and (ElementValue = '') then
            ElementValue := NPXmlElement."Default Value";
        if ElementValue = '' then begin
            ChildNodesList := Node.AsXmlElement.GetChildNodes();
            foreach ChildNode in ChildNodesList do
                ChildNode.Remove();
        end;

        if NPXmlElement.CDATA then begin
            if ElementValue <> '' then begin
                CData := XmlCData.Create(ElementValue);
                Element := Node.AsXmlElement();
                Element.Add(CData);
                Node := Element.AsXmlNode();
            end;
        end else
            if ElementValue <> '' then begin
                NewElement := XmlElement.Create(Node.AsXmlElement().LocalName, Node.AsXmlElement().NamespaceUri);
                NewElement.Add(ElementValue);

                if Node.AsXmlElement.HasAttributes then begin
                    AttributeCollection := Node.AsXmlElement.Attributes();
                    foreach Attribute in AttributeCollection do
                        NewElement.Add(Attribute);
                end;

                ChildNodesList := Node.AsXmlElement.GetChildNodes();
                foreach ChildNode in ChildNodesList do
                    NewElement.Add(ChildNode);

                Node.AddAfterSelf(NewElement);
                if Node.Remove() then
                    Node := NewElement.AsXmlNode();
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupGenericChildTable(NpXmlElement: Record "NPR NpXml Element"; ParentRecRef: RecordRef; var ChildRecRef: RecordRef; var Handled: Boolean)
    begin
    end;

    local procedure SetRecRefXmlFilter(NpXmlElement: Record "NPR NpXml Element"; RecRef: RecordRef; var RecRef2: RecordRef)
    var
        NpXmlFilter: Record "NPR NpXml Filter";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
        BufferBoolean: Boolean;
        Handled: Boolean;
        i: Integer;
    begin
        Clear(RecRef2);
        if NpXmlElement."Generic Child Codeunit ID" <> 0 then
            OnSetupGenericChildTable(NpXmlElement, RecRef, RecRef2, Handled);
        if (not Handled) or (NpXmlElement."Generic Child Codeunit ID" = 0) then begin
            RecRef2.Open(NpXmlElement."Table No.");
            if RecRef.Number = NpXmlElement."Table No." then
                RecRef2.Get(RecRef.RecordId);
        end;

        i := 40;
        NpXmlFilter.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        if NpXmlFilter.FindSet() then begin
            repeat
                i += 1;
                RecRef2.FilterGroup(i);
                FieldRef2 := RecRef2.Field(NpXmlFilter."Field No.");
                case NpXmlFilter."Filter Type" of
                    NpXmlFilter."Filter Type"::TableLink:
                        begin
                            FieldRef := RecRef.Field(NpXmlFilter."Parent Field No.");
                            if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
                                FieldRef.CalcField;
                            FieldRef2.SetFilter('=%1', FieldRef.Value);
                        end;
                    NpXmlFilter."Filter Type"::Constant:
                        begin
                            if NpXmlFilter."Filter Value" <> '' then begin
                                case LowerCase(Format(FieldRef2.Type)) of
                                    'boolean':
                                        FieldRef2.SetFilter('=%1', LowerCase(NpXmlFilter."Filter Value") in ['1', 'yes', 'ja', 'true']);
                                    'integer', 'option':
                                        begin
                                            if Evaluate(BufferDecimal, NpXmlFilter."Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferDecimal);
                                        end;
                                    'decimal':
                                        begin
                                            if Evaluate(BufferInteger, NpXmlFilter."Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferInteger);
                                        end;
                                    else
                                        FieldRef2.SetFilter('=%1', NpXmlFilter."Filter Value");
                                end;
                            end;
                        end;
                    NpXmlFilter."Filter Type"::Filter:
                        begin
                            FieldRef2.SetFilter(NpXmlFilter."Filter Value");
                        end;
                end;
            until NpXmlFilter.Next = 0;

            RecRef2.FilterGroup(0);
        end else
            if RecRef.Number = NpXmlElement."Table No." then
                RecRef2.SetRecFilter();


        case NpXmlElement."Iteration Type" of
            NpXmlElement."Iteration Type"::First:
                begin
                    if RecRef2.FindFirst then
                        RecRef2.SetRecFilter;
                end;
            NpXmlElement."Iteration Type"::Last:
                begin
                    if RecRef2.FindLast then
                        RecRef2.SetRecFilter;
                end;
        end;
    end;

    local procedure ExportToFile(NPXmlTemplate: Record "NPR NpXml Template"; var XmlDoc: XmlDocument; Filename: Text[250])
    var
        "Field": Record "Field";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        HardwareConnectorMgt: codeunit "NPR Hardware Connector Mgt.";
        InStr: InStream;
        OutStr: OutStream;
        Filepath: Text;
        TempFile: Text;
    begin
        if not NPXmlTemplate."File Transfer" then
            exit;

        AddXmlToOutputTempBlob(XmlDoc, 'Xml Template: ' + NPXmlTemplate.Code + ' || File Transfer: ' + NPXmlTemplate."File Path");

        Field.Get(DATABASE::"NPR NpXml Template", NPXmlTemplate.FieldNo("File Transfer"));
        AddTextToResponseTempBlob('<!-- [' + NPXmlTemplate.Code + '] ' + Field."Field Caption" + ': ' + NPXmlTemplate."File Path" + ' -->' + GetChar(13) + GetChar(10));

        NPXmlTemplate.TestField("File Path");
        Filepath := NPXmlTemplate."File Path" + '\';
        if Filepath[StrLen(Filepath)] <> '\' then
            Filepath += '\';
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        if not TempBlob.HasValue then
            exit;
        TempBlob.CreateInStream(InStr);

        TempFile := FileMgt.BLOBExport(TempBlob, Filename, false);
        HardwareConnectorMgt.MoveFileRequest(TempFile, Filepath + Filename);
    end;

    local procedure FinalizeDoc(var XmlDoc: XmlDocument; NPXmlTemplate: Record "NPR NpXml Template"; Filename: Text[1024])
    var
        Transfered: Boolean;
    begin
        Transfered := TransferXml(NPXmlTemplate, XmlDoc, Filename);
        if Transfered then
            exit;

        AddXmlToOutputTempBlob(XmlDoc, 'Xml Template: ' + NPXmlTemplate.Code + ' || No Transfer');
    end;

    local procedure SendApi(NpXmlTemplate: Record "NPR NpXml Template"; var XmlDoc: XmlDocument)
    var
        "Field": Record "Field";
        NpXmlApiHeader: Record "NPR NpXml Api Header";
        NpXmlNamespaces: Record "NPR NpXml Namespace";
        XMLDomManagement: Codeunit "XML DOM Management";
        JsonManagement: Codeunit "JSON Management";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        RequestHeader: HttpHeaders;
        RequestText: Text;
        ResponseMessage: HttpResponseMessage;
        InStr: InStream;
        XmlDoc2: XmlDocument;
        XmlDoc2Text: Text;
        XmlNode2: XmlNode;
        XmlNode2Element: XmlElement;
        RootElement: XmlElement;
        NameSpaceManager: XmlNamespaceManager;
        Element: XmlElement;
        ElementText: Text;
        NodeFromXmlDoc2: XmlNode;
        NodeList: XmlNodeList;
        Node: XmlNode;
        APIUsername: Text;
        ElementName: Text;
        ExceptionMessage: Text;
        JsonRequest: Text;
        Response: Text;
        IsJson: Boolean;
        NetConvHelper: Variant;
    begin
        if not NpXmlTemplate."API Transfer" then
            exit;

        Field.Get(DATABASE::"NPR NpXml Template", NpXmlTemplate.FieldNo("API Transfer"));
        AddTextToResponseTempBlob('<!-- [' + NpXmlTemplate.Code + '] ' + Field."Field Caption" + ': ' + NpXmlTemplate."API Url" + ' -->' + GetChar(13) + GetChar(10));

        case NpXmlTemplate."API Type" of
            NpXmlTemplate."API Type"::"REST (Xml)", NpXmlTemplate."API Type"::"REST (Json)":
                begin
                    XmlDoc2 := XmlDoc;
                    AddXmlNamespaces(NpXmlTemplate, XmlDoc2);
                    if (NpXmlTemplate."Xml Root Namespace" <> '') and NpXmlNamespaces.Get(NpXmlTemplate.Code, NpXmlTemplate."Xml Root Namespace") then begin
                        XmlDoc2.GetRoot(Element);
                        NpXmlDomMgt.AddNamespaceDeclaration(Element, 'nprxmlns', NpXmlNamespaces.Namespace);
                    end;
                end;
            NpXmlTemplate."API Type"::SOAP:
                begin
                    XmlDocument.ReadFrom('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                                        '   <soapenv:Body />' +
                                        '</soapenv:Envelope>'
                                        , XmlDoc2);
                    NameSpaceManager.AddNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
                    XmlDoc2.SelectSingleNode('//soapenv:Body', NameSpaceManager, XmlNode2);
                    AddXmlNamespaces(NpXmlTemplate, XmlDoc2);
                    if NpXmlNamespaces.Get(NpXmlTemplate.Code, NpXmlTemplate."Xml Root Namespace") then;

                    ElementName := NpXmlTemplate."API SOAP Action";
                    if NpXmlTemplate."Xml Root Namespace" <> '' then
                        ElementName := NpXmlTemplate."Xml Root Namespace" + ':' + NpXmlTemplate."API SOAP Action";
                    NpXmlDomMgt.AddElementNamespace(XmlNode2, ElementName, NpXmlNamespaces.Namespace, XmlNode2);

                    NodeList := XmlDoc.GetChildElements();
                    if NodeList.Count <> 0 then
                        foreach Node in NodeList do begin
                            XmlDoc2.SelectSingleNode(GetXmlElementXPath(Node.AsXmlElement()), NameSpaceManager, NodeFromXmlDoc2);
                            XmlNode2Element := XmlNode2.AsXmlElement();
                            XmlNode2Element.Add(NodeFromXmlDoc2);
                        end;
                end;
        end;

        Client.Timeout(1000 * 60 * 5);

        RequestMessage.SetRequestUri(NpXmlTemplate."API Url");
        RequestMessage.GetHeaders(RequestHeader);

        IsJson := NpXmlTemplate."API Type" = NpXmlTemplate."API Type"::"REST (Json)";
        if IsJson then begin
            JsonRequest := Xml2Json(XmlDoc2, NpXmlTemplate);
            AddTextToOutputTempBlob(JsonRequest);
            RequestContent.WriteFrom(JsonRequest);
        end else begin
            XmlDoc2.WriteTo(RequestText);
            RequestContent.WriteFrom(RequestText);
        end;

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');

        case NpXmlTemplate."API Type" of
            NpXmlTemplate."API Type"::"REST (Xml)", NpXmlTemplate."API Type"::"REST (Json)":
                begin
                    RequestMessage.Method(GetApiMethod(NpXmlTemplate));
                    ContentHeader.Add('Content-Type', 'navision/xml');
                    if NpXmlTemplate."API Content-Type" <> '' then begin
                        ContentHeader.Remove('Content-Type');
                        ContentHeader.Add('Content-Type', NpXmlTemplate."API Content-Type");
                    end;
                    RequestHeader.Add('Accept', 'application/xml');
                end;
            NpXmlTemplate."API Type"::SOAP:
                begin
                    RequestMessage.Method('POST');
                    ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
                    if not NpXmlApiHeader.Get(NpXmlTemplate.Code, 'SOAPAction') then
                        RequestHeader.Add('SOAPAction', NpXmlTemplate."API SOAP Action");
                end;
        end;

        APIUsername := NpXmlTemplate.GetApiUsername();
        if NpXmlTemplate."API Password" = '' then
            Client.UseDefaultNetworkWindowsAuthentication()
        else begin
            if NpXmlTemplate."API Username Type" = NpXmlTemplate."API Username Type"::Automatic then
                RequestHeader.Add('Authorization', 'Basic ' + GetBasicAuthInfo(APIUsername, NpXmlTemplate."API Password"))
            else
                Client.UseWindowsAuthentication(APIUsername, NpXmlTemplate."API Password");
        end;

        if NpXmlTemplate."API Content-Type" <> '' then begin
            ContentHeader.Remove('Content-Type');
            ContentHeader.Add('Content-Type', NpXmlTemplate."API Content-Type");
        end;
        if NpXmlTemplate."API Authorization" <> '' then
            RequestHeader.Add('Authorization', NpXmlTemplate."API Authorization");
        if NpXmlTemplate."API Accept" <> '' then
            RequestHeader.Add('Accept', NpXmlTemplate."API Accept");
        NpXmlApiHeader.SetRange("Xml Template Code", NpXmlTemplate.Code);
        if NpXmlApiHeader.FindSet then
            repeat
                AddApiHeader(NpXmlApiHeader, Client, RequestHeader, ContentHeader);
            until NpXmlApiHeader.Next = 0;

        RequestMessage.Content(RequestContent);
        Client.Send(RequestMessage, ResponseMessage);

        ResponseMessage.Content.ReadAs(Response);

        if not ResponseMessage.IsSuccessStatusCode then begin
            ExceptionMessage := ResponseMessage.ReasonPhrase;
            if Response <> '' then
                ExceptionMessage += '\\' + Response;
            AddTextToResponseTempBlob(ExceptionMessage);
            Error('');
        end;

        if (NpXmlTemplate."API Response Path" <> '') and (Response <> '') and (not IsJson) then begin
            Response := XMLDomManagement.RemoveNamespaces(Response);
            XmlDocument.ReadFrom(Response, XmlDoc2);
            XmlDoc2.SelectSingleNode(NpXmlTemplate."API Response Path", Node);
            if not Node.AsXmlElement().IsEmpty then
                Response := Node.AsXmlElement().InnerXml;
        end;

        if not IsJson then
            Response := NpXmlDomMgt.PrettyPrintXml(Response);

        AddTextToResponseTempBlob(Response);

        if (NpXmlTemplate."API Response Success Path" <> '') and (Response <> '') then begin
            if IsJson then begin
                ElementText := JsonManagement.XMLTextToJSONText(Response);
                Element := XmlElement.Create(ElementText);

                XmlDoc2Text := XMLDomManagement.RemoveNamespaces('<?xml version="1.0" encoding="utf-8"?>' + GetChar(13) + GetChar(10) + '<response />');
                XmlDocument.ReadFrom(XmlDoc2Text, XmlDoc2);
                XmlDoc2.GetRoot(RootElement);
                RootElement.Add(Element);
            end else begin
                Response := XMLDomManagement.RemoveNamespaces(Response);
                XmlDocument.ReadFrom(Response, XmlDoc2);
            end;

            NetConvHelper := XmlDoc2;
            if NpXmlDomMgt.GetXmlText(NetConvHelper, NpXmlTemplate."API Response Success Path", MaxStrLen(NpXmlTemplate."API Response Success Value"), false) <> NpXmlTemplate."API Response Success Value" then
                Error('');
        end;
    end;

    local procedure GetXmlElementXPath(Element: XmlElement) xPath: Text
    var
        ParentElement: XmlElement;
    begin
        xPath := Element.Name;
        while Element.GetParent(ParentElement) do begin
            Element := ParentElement;
            xPath := ParentElement.Name + '/' + xPath;
        end;
    end;

    local procedure AddApiHeader(NpXmlApiHeader: Record "NPR NpXml Api Header"; var Client: HttpClient; var RequestHeaders: HttpHeaders; var ContentHeaders: HttpHeaders)
    var
        BigIntBuffer: BigInteger;
        IntBuffer: Integer;
        DateTimeBuffer: DateTime;
        BoolBuffer: Boolean;
    begin
        case LowerCase(NpXmlApiHeader.Name) of
            'timeout':
                begin
                    Evaluate(IntBuffer, NpXmlApiHeader.Value);
                    Client.Timeout(IntBuffer);
                end;
            'accept':
                begin
                    RequestHeaders.Add('Accept', NpXmlApiHeader.Value);
                end;
            'connection':
                begin
                    RequestHeaders.Add('Connection', NpXmlApiHeader.Value);
                end;
            'content-length':
                begin
                    Evaluate(BigIntBuffer, NpXmlApiHeader.Value);
                    RequestHeaders.Add('ContentLength', format(BigIntBuffer));
                end;
            'content-type':
                begin
                    ContentHeaders.Remove('Content-Type');
                    ContentHeaders.Add('ContentType', NpXmlApiHeader.Value);
                end;
            'date':
                begin
                    if not Evaluate(DateTimeBuffer, NpXmlApiHeader.Value, 9) then
                        Evaluate(DateTimeBuffer, NpXmlApiHeader.Value);
                    RequestHeaders.Add('Date', format(DateTimeBuffer));
                end;
            'expect':
                begin
                    RequestHeaders.Add('Expect', NpXmlApiHeader.Value);
                end;
            'host':
                begin
                    RequestHeaders.Add('Host', NpXmlApiHeader.Value);
                end;
            'if-modified-since':
                begin
                    if not Evaluate(DateTimeBuffer, NpXmlApiHeader.Value, 9) then
                        Evaluate(DateTimeBuffer, NpXmlApiHeader.Value);
                    RequestHeaders.Add('IfModifiedSince', format(DateTimeBuffer));
                end;
            'referer':
                begin
                    RequestHeaders.Add('Referer', NpXmlApiHeader.Value);
                end;
            'transfer-encoding':
                begin
                    RequestHeaders.Add('TransferEncoding', NpXmlApiHeader.Value);
                end;
            'user-agent':
                begin
                    RequestHeaders.Add('UserAgent', NpXmlApiHeader.Value);
                end;
            'expect100continue':
                begin
                    if not Evaluate(BoolBuffer, NpXmlApiHeader.Value, 9) then
                        if not Evaluate(BoolBuffer, NpXmlApiHeader.Value, 2) then
                            Evaluate(BoolBuffer, NpXmlApiHeader.Value);
                    if BoolBuffer then
                        RequestHeaders.Add('Expect', '100-continue')
                    else
                        RequestHeaders.Remove('Expect');

                end;
            else
                RequestHeaders.Add(NpXmlApiHeader.Name, NpXmlApiHeader.Value);
        end;
    end;

    local procedure SendFtp(NPXmlTemplate: Record "NPR NpXml Template"; var XmlDoc: XmlDocument; Filename: Text)
    var
        "Field": Record "Field";
        FTPClient: Codeunit "NPR AF FTP Client";
        FTPResponse: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Result: Text;
        StatusCode: Text;
        ErrorDescription: Text;
    begin
        if not NPXmlTemplate."FTP Transfer" then
            exit;
        if NPXmlTemplate."FTP Server" = '' then
            exit;

        if NPXmlTemplate."FTP Filename (Fixed)" <> '' then
            Filename := NPXmlTemplate."FTP Filename (Fixed)";

        AddXmlToOutputTempBlob(XmlDoc, 'Xml Template: ' + NPXmlTemplate.Code + ' || Ftp Transfer: ' + NPXmlTemplate."FTP Server");
        OutputTempBlob.CreateInStream(InStr);

        FTPClient.Construct(NPXmlTemplate."FTP Server", NPXmlTemplate."FTP Username", NPXmlTemplate."FTP Password", NPXmlTemplate."FTP Port", 10000);
        FTPResponse := FTPClient.UploadFile(InStr, NPXmlTemplate."FTP Directory" + '/' + Filename);

        FTPResponse.Get('StatusCode', JToken);
        StatusCode := JToken.AsValue.AsText();

        case StatusCode of
            '200':
                begin
                    Field.Get(DATABASE::"NPR NpXml Template", NPXmlTemplate.FieldNo("FTP Transfer"));
                    AddTextToResponseTempBlob('<!-- [' + NPXmlTemplate.Code + '] ' + Field."Field Caption" + ': ' + NPXmlTemplate."FTP Server" + ' -->' + GetChar(13) + GetChar(10));
                    exit;
                end;
            '401':
                ErrorDescription := Error004;
            else begin
                    FTPResponse.Get('Error', JToken);
                    ErrorDescription := JToken.AsValue.AsText();
                end;
        end;

        AddTextToResponseTempBlob(StrSubstNo(Error003, StatusCode, ErrorDescription));
        Error(StrSubstNo(Error003, StatusCode, ErrorDescription));
    end;

    local procedure TransferXml(NpXmlTemplate: Record "NPR NpXml Template"; var XmlDoc: XmlDocument; Filename: Text[250]) Transfered: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeTransferXml(NpXmlTemplate, RecRef, XmlDoc, Filename, Handled);
        if not (NpXmlTemplate."File Transfer" or NpXmlTemplate."FTP Transfer" or NpXmlTemplate."API Transfer") then
            exit(false);

        if NpXmlTemplate."File Transfer" then
            ExportToFile(NpXmlTemplate, XmlDoc, Filename);

        if NpXmlTemplate."FTP Transfer" then
            SendFtp(NpXmlTemplate, XmlDoc, Filename);

        if NpXmlTemplate."API Transfer" then
            SendApi(NpXmlTemplate, XmlDoc);

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferXml(var NpXmlTemplate: Record "NPR NpXml Template"; var RootRecRef: RecordRef; var XmlDoc: XmlDocument; var Filename: Text[250]; var Handled: Boolean)
    begin
    end;

    local procedure GetApiMethod(NpXmlTemplate: Record "NPR NpXml Template"): Text
    begin
        case NpXmlTemplate."API Method" of
            NpXmlTemplate."API Method"::DELETE:
                exit('DELETE');
            NpXmlTemplate."API Method"::GET:
                exit('GET');
            NpXmlTemplate."API Method"::PATCH:
                exit('PATCH');
            NpXmlTemplate."API Method"::POST:
                exit('POST');
            NpXmlTemplate."API Method"::PUT:
                exit('PUT');
        end;
    end;

    local procedure AddTextToResponseTempBlob(Response: Text)
    var
        LF: Char;
        CR: Char;
    begin
        InitializeOutput();
        if ResponseTempBlob.HasValue then begin
            LF := 10;
            CR := 13;
            ResponseOutStr.WriteText(Format(CR) + Format(LF));
        end;
        ResponseOutStr.WriteText(Response);
    end;

    local procedure AddTextToOutputTempBlob(var OutputText: Text)
    begin
        InitializeOutput();
        if OutputTempBlob.HasValue then
            OutputOutStr.WriteText(GetChar(13) + GetChar(10) + GetChar(13) + GetChar(10));

        OutputOutStr.Write(OutputText);
    end;

    local procedure AddXmlToOutputTempBlob(var XmlDoc: XmlDocument; Comment: Text)
    begin
        InitializeOutput();
        if OutputTempBlob.HasValue then begin
            OutputOutStr.WriteText(GetChar(13) + GetChar(10) + GetChar(13) + GetChar(10));
        end;
        if Comment <> '' then
            OutputOutStr.WriteText('<!--' + Comment + '-->' + GetChar(13) + GetChar(10));
        XmlDoc.WriteTo(OutputOutStr);
    end;

    procedure GetOutput(var TempBlob: Codeunit "Temp Blob") HasOutput: Boolean
    begin
        if not OutputInitialized then begin
            Clear(TempBlob);
            exit(false);
        end;
        TempBlob := OutputTempBlob;
        exit(TempBlob.HasValue);
    end;

    procedure GetResponse(var TempBlob: Codeunit "Temp Blob") HasOutput: Boolean
    begin
        if not OutputInitialized then begin
            Clear(TempBlob);
            exit(false);
        end;
        TempBlob := ResponseTempBlob;
        exit(TempBlob.HasValue);
    end;

    procedure InitializeOutput()
    begin
        if not OutputInitialized then begin
            Clear(OutputTempBlob);
            OutputTempBlob.CreateOutStream(OutputOutStr, TEXTENCODING::UTF8);

            Clear(ResponseTempBlob);
            ResponseTempBlob.CreateOutStream(ResponseOutStr, TEXTENCODING::UTF8);
        end;

        OutputInitialized := true;
    end;

    local procedure CloseDialog()
    begin
        if not UseDialog then
            exit;

        Window.Close;
    end;

    local procedure OpenDialog(Title: Text)
    begin
        if not UseDialog then
            exit;

        Window.Open(Title);
    end;

    local procedure UpdateDialog(Counter: Integer; Total: Integer; StartTime: Time; RecordPosition: Text[1024])
    var
        Runtime: Decimal;
    begin
        if not UseDialog then
            exit;

        if Total = 0 then
            Total := 1;
        Window.Update(2, Round((Counter / Total) * 10000, 1));
        if Counter mod 100 = 0 then begin
            Runtime := (Time - StartTime) / 1000;
            Window.Update(3, Round((Runtime * Total / Counter - Runtime) / 60, 0.01));
        end;
        Window.Update(4, RecordPosition);
    end;

    local procedure UseDialog(): Boolean
    begin
        exit(GuiAllowed and not HideDialog);
    end;

    procedure GetAutomaticUsername(): Text
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.Get(ServiceInstanceId, SessionId);
        exit(LowerCase(ReplaceSpecialChar(ActiveSession."Database Name" + '_' + CompanyName)));
    end;

    procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.ToBase64(Username + ':' + Password, TextEncoding::UTF8));
    end;

    local procedure GetChar(CharInt: Integer): Text[1]
    var
        Char: Char;
    begin
        Char := CharInt;
        exit(Format(Char));
    end;

    local procedure GetFilename(XmlEntityType: Text[50]; PrimaryKeyValue: Text; RecordCounter: Integer): Text[1024]
    var
        Path: Text[1024];
    begin
        PrimaryKeyValue := ReplaceSpecialChar(PrimaryKeyValue);
        if PrimaryKeyValue <> '' then
            exit(Path + DelChr(Format(Today, 0, 9) + Format(Time), '=', ',.: ') + '-' + XmlEntityType + '-' +
                 PrimaryKeyValue + '.xml');

        exit(Path + DelChr(Format(Today, 0, 9) + Format(Time), '=', ',.: ') + '-' + XmlEntityType + '-' +
             PadStrLeft(Format(RecordCounter), 10, '0') + '.xml');
    end;

    local procedure GetXmlElementName(NpXmlElement: Record "NPR NpXml Element"): Text
    var
        NpXmlNamespaces: Record "NPR NpXml Namespace";
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        if NpXmlElement.Namespace = '' then
            exit(NpXmlElement."Element Name");

        if not (NpXmlTemplate.Get(NpXmlElement."Xml Template Code") and NpXmlTemplate."Namespaces Enabled") then
            exit(NpXmlElement."Element Name");

        if not NpXmlNamespaces.Get(NpXmlElement."Xml Template Code", NpXmlElement.Namespace) then
            exit(NpXmlElement."Element Name");

        exit(NpXmlElement.Namespace + ':' + NpXmlElement."Element Name");
    end;

    local procedure GetXmlNamespace(NpXmlElement: Record "NPR NpXml Element"): Text
    var
        NpXmlNamespaces: Record "NPR NpXml Namespace";
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        if NpXmlElement.Namespace = '' then
            exit('');

        if not (NpXmlTemplate.Get(NpXmlElement."Xml Template Code") and NpXmlTemplate."Namespaces Enabled") then
            exit('');
        if not NpXmlNamespaces.Get(NpXmlElement."Xml Template Code", NpXmlElement.Namespace) then
            exit('');

        exit(NpXmlNamespaces.Namespace);
    end;

    local procedure PadStrLeft(InputStr: Text[1024]; StrLength: Integer; PadChr: Char) Output: Text[1024]
    var
        PadLength: Integer;
        i: Integer;
        PadStr: Text[1024];
    begin
        PadLength := StrLength - StrLen(InputStr);
        PadStr := '';
        for i := 1 to PadLength do
            PadStr += Format(PadChr);

        exit(PadStr + InputStr);
    end;

    local procedure ReplaceSpecialChar(Input: Text) Output: Text
    var
        i: Integer;
    begin
        Output := '';
        for i := 1 to StrLen(Input) do
            case Input[i] of
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
              'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
              'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
              'u', 'v', 'w', 'x', 'y', 'z', 'U', 'V', 'W', 'X', 'Y', 'Z', '-', '.', '_', ' ':
                    Output += Format(Input[i]);
                'æ':
                    Output += 'ae';
                'ø', 'ö':
                    Output += 'oe';
                'å', 'ä':
                    Output += 'aa';
                'è', 'é', 'ë', 'ê':
                    Output += 'e';
                'Æ':
                    Output += 'AE';
                'Ø', 'Ö':
                    Output += 'OE';
                'Å', 'Ä':
                    Output += 'AA';
                'É', 'È', 'Ë', 'Ê':
                    Output += 'E';
                else
                    Output += '-';
            end;

        exit(Output);
    end;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    local procedure MarkContainersAsArray(var XmlElement: DotNet NPRNetXmlElement)
    var
        XmlElementNextChild: DotNet NPRNetXmlElement;
        XmlElementChild: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlElement) then
            exit;
        if NpXmlDomMgt.IsLeafNode(XmlElement) then
            exit;

        XmlNodeList := XmlElement.ChildNodes;
        XmlElementChild := XmlElement.FirstChild;
        repeat
            XmlElementNextChild := XmlElementChild.NextSibling;

            if XmlElementChild.Name = '#text' then
                XmlElement.RemoveChild(XmlElementChild)
            else
                MarkContainersAsArray(XmlElementChild);

            XmlElementChild := XmlElementNextChild;
        until IsNull(XmlElementChild);
    end;

    local procedure MarkContainersAsArray(var XmlElement: XmlElement)
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        Element: XmlElement;
    begin
        if XmlElement.IsEmpty then
            exit;
        if NpXmlDomMgt.IsLeafNode(XmlElement.AsXmlNode()) then
            exit;

        NodeList := XmlElement.GetChildElements();
        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            if Element.Name = '#text' then
                Node.Remove()
            else
                MarkContainersAsArray(Element);
        end;

    end;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    procedure Xml2Json(var XmlDoc: DotNet "NPRNetXmlDocument"; NpXmlTemplate: Record "NPR NpXml Template") JsonString: Text
    var
        XmlDoc2: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        JsonConvert: DotNet JsonConvert;
        JsonFormatting: DotNet NPRNetFormatting;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        JToken: DotNet JToken;
        JContainer: DotNet NPRNetJContainer;
        JArray: DotNet JArray;
        RegEx: DotNet NPRNetRegex;
        i: Integer;
    begin
        XmlDoc2 := XmlDoc.Clone;
        XmlNodeList := XmlDoc2.DocumentElement.ChildNodes;
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.Item(i);
            MarkContainersAsArray(XmlElement);
        end;
        if NpXmlTemplate."JSON Root is Array" then begin
            JsonString := JsonConvert.SerializeXmlNode(XmlDoc2.DocumentElement, JsonFormatting.Indented, false);
            JContainer := JContainer.Parse(JsonString);
            JArray := JContainer.SelectTokens(NpXmlTemplate."Xml Root Name", true);
            JsonString := JsonConvert.SerializeObject(JArray, JsonFormatting.Indented);
        end else
            JsonString := JsonConvert.SerializeXmlNode(XmlDoc2.DocumentElement, JsonFormatting.Indented, true);

        if NpXmlTemplate."Use JSON Numbers" then
            JsonString := RegEx.Replace(JsonString, '"(\d*\.?\d*)"(?!:)', '$1');

        JsonString := RegEx.Replace(JsonString, '(?i)#string#', '');

        exit(JsonString);
    end;

    procedure Xml2Json(var Document: XmlDocument; NpXmlTemplate: Record "NPR NpXml Template") JsonString: Text
    var
        Document2: XmlDocument;
        Element: XmlElement;
        JSONManagement: Codeunit "JSON Management";
        NodeList: XmlNodeList;
        Node: XmlNode;
        XmlAsText: Text;
    begin
        Document2 := Document;
        NodeList := Document2.GetChildElements();
        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            MarkContainersAsArray(Element);
        end;

        Document2.WriteTo(XmlAsText);
        JsonString := JSONManagement.XMLTextToJSONText(XmlAsText);

        if NpXmlTemplate."Use JSON Numbers" then
            JsonString := JsonString.Replace('"(\d*\.?\d*)"(?!:)', '$1');

        JsonString := JsonString.Replace('(?i)#string#', '');

        exit(JsonString);
    end;

    procedure PreviewXml(NPXmlTemplateCode: Code[20])
    var
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlTemplate: Record "NPR NpXml Template";
        TempBlob: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        XmlDocNode: XmlNode;
        XmlDoc: XmlDocument;
        InStr: InStream;
        OutStr: OutStream;
        Filename: Text;
        JsonString: Text;
        RecRef2: RecordRef;
        Success: Boolean;
        Counter: Integer;
        Total: Integer;
        StartTime: Time;
    begin
        NpXmlTemplate.Get(NPXmlTemplateCode);
        NpXmlTemplate.TestField("Table No.");
        Clear(RecRef);
        RecRef.Open(NpXmlTemplate."Table No.");
        Counter := 0;
        Total := RecRef.Count;
        RecRef.FindSet;
        Success := false;

        StartTime := Time;
        OpenDialog(StrSubstNo(Text200, RecRef.Caption));
        while not Success do begin
            Counter += 1;
            UpdateDialog(Counter, Total, StartTime, RecRef.GetPosition);
            NpXmlElement.Reset;
            NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
            NpXmlElement.SetFilter("Parent Line No.", '=%1', 0);
            NpXmlElement.SetRange(Active, true);
            NpXmlElement.FindSet;
            repeat
                SetRecRefXmlFilter(NpXmlElement, RecRef, RecRef2);
                Success := RecRef2.FindFirst;
            until (NpXmlElement.Next = 0) or Success;
            if not Success then
                if RecRef.Next = 0 then
                    Error(Error002, RecRef.Caption);
        end;
        CloseDialog();

        PrimaryKeyValue := NpXmlValueMgt.GetPrimaryKeyValue(RecRef);
        Filename := GetFilename(NpXmlTemplate."Xml Root Name", PrimaryKeyValue, 1);
        NpXmlDomMgt.InitDoc(XmlDoc, XmlDocNode, NpXmlTemplate."Xml Root Name", NpXmlTemplate."Custom Namespace for XMLNS");
        NpXmlDomMgt.AddRootAttributes(XmlDocNode, NpXmlTemplate);

        NpXmlElement.Reset;
        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlElement.SetFilter("Parent Line No.", '=%1', 0);
        NpXmlElement.SetRange(Active, true);
        if NpXmlElement.FindSet then
            repeat
                SetRecRefXmlFilter(NpXmlElement, RecRef, RecRef2);
                if RecRef2.FindSet then
                    repeat
                        Success := AddXmlElement(XmlDocNode, NpXmlElement, RecRef2, 0);
                    until (RecRef2.Next = 0) or not Success;
                RecRef2.Close;
            until NpXmlElement.Next = 0;
        RecRef.Close;

        AddXmlNamespaces(NpXmlTemplate, XmlDoc);
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        if not TempBlob.HasValue then
            exit;

        if NpXmlTemplate."API Type" = NpXmlTemplate."API Type"::"REST (Json)" then begin
            JsonString := Xml2Json(XmlDoc, NpXmlTemplate);

            TempBlob.CreateInStream(InStr);
            TempBlob2.CreateOutStream(OutStr);

            CopyStream(OutStr, InStr);
            OutStr.Write(GetChar(13) + GetChar(10) + GetChar(13) + GetChar(10));
            OutStr.Write(JsonString);

            TempBlob := TempBlob2;
        end;
        TempBlob.CreateInStream(InStr);

        DownloadFromStream(InStr, 'Download and preview XML file', '', 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*', FileName);
    end;
}

