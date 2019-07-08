codeunit 6151558 "NpXml Wsdl Import"
{
    // NC2.01 /TR  /20160929  CASE 240432 Object created
    // NC2.01 /TR  /20170102  CASE 240432 Updated code
    // NC2.03 /BR  /20170315  CASE 269250 Fixed issue with creating line no. 0
    // NC2.03 /TR  /20170320  CASE 240432 Reconstructed codeunit incl. functions calls. Removed XmlNsManager parameter from all functions.
    // NC2.08 /BR  /20171123  CASE 297355 Deleted unused variables


    trigger OnRun()
    begin
    end;

    var
        XmlNsManager: DotNet npNetXmlNamespaceManager;
        XmlNameTable: DotNet npNetXmlNameTable;
        Text000: Label 'Templatename %1 already exists. Either rename the existing template or delete it. ';
        "--": Integer;
        SchemaNameSpace: Text;
        GlobalLevel: Integer;
        GlobalLineNo: Integer;
        Text001: Label 'Input the WSDL url';
        Text002: Label 'Import WSDL';

    procedure "--- UI"()
    begin
    end;

    procedure ImportWSDL(NpXmlTemplate: Record "NpXml Template")
    var
        WsdlImportDialog: Page "NpXml Wsdl Input Dialog";
        Path: Text;
    begin
        if not (WsdlImportDialog.RunModal = ACTION::OK) then
          exit;

        Path := WsdlImportDialog.GetWSDLPath();

        if IsUrl(Path) then
          ImportUrl(Path,WsdlImportDialog.GetUsername,WsdlImportDialog.GetPassword,NpXmlTemplate)
        else
          ImportFile(Path,NpXmlTemplate);
    end;

    local procedure ImportFile(Path: Text;NpXmlTemplate: Record "NpXml Template")
    var
        XmlDoc: DotNet npNetXmlDocument;
    begin
        if not LoadFile(Path,XmlDoc) then
          exit;
        ParseData(XmlDoc,NpXmlTemplate);
    end;

    local procedure ImportUrl(Path: Text;UserName: Text;Password: Text;NpXmlTemplate: Record "NpXml Template")
    var
        MemoryStream: DotNet npNetMemoryStream;
        XmlDoc: DotNet npNetXmlDocument;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        CredentialCache: DotNet npNetCredentialCache;
        NetworkCredential: DotNet npNetNetworkCredential;
        Uri: DotNet npNetUri;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Env: DotNet npNetEnvironment;
        WsdlImportDialog: Page "NpXml Wsdl Input Dialog";
        Url: Text;
    begin
        Uri := Uri.Uri(Path);
        HttpWebRequest := HttpWebRequest.Create(Uri);

        NetworkCredential := NetworkCredential.NetworkCredential(UserName,Password);
        CredentialCache := CredentialCache.CredentialCache;
        CredentialCache.Add(Uri,'NTLM',NetworkCredential);
        HttpWebRequest.Credentials := CredentialCache;

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        HttpWebResponse := HttpWebRequest.GetResponse;
        MemoryStream := HttpWebResponse.GetResponseStream;

        if not IsNull(XmlDoc) then
          Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream);
        ParseData(XmlDoc,NpXmlTemplate);
    end;

    procedure "-- Basic"()
    begin
    end;

    local procedure IsUrl(Path: Text): Boolean
    begin
        if (StrPos(Path,'http://') <> 0) or (StrPos(Path,'https://') <> 0) then
          exit(true);
        exit(false);
    end;

    local procedure ParseData(XmlDoc: DotNet npNetXmlDocument;NpXmlTemplate: Record "NpXml Template")
    var
        DocumentElement: DotNet npNetXmlDocument;
        IEnumerator: DotNet npNetIEnumerator;
        XmlElement: DotNet npNetXmlElement;
        "--": Integer;
        DataTypes: DotNet npNetXmlElement;
        Binding: DotNet npNetXmlElement;
        PortTypes: DotNet npNetXmlElement;
        Operations: DotNet npNetXmlNodeList;
        OperationMessage: DotNet npNetXmlElement;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        CommentLine: Record "Comment Line" temporary;
        OperationName: Text;
        CurrentPrefix: Text;
        XPath: Text;
        XmlNode: DotNet npNetXmlNode;
    begin
        XmlNameTable := XmlDoc.NameTable;
        //-NC2.03 [240432]
        //GetNameSpaces(XmlDoc,XmlNsManager);
        SetNameSpaceManager(XmlDoc);
        if IsNull(XmlNsManager) then
          exit;
        //+NC2.03 [240432]

        DocumentElement := XmlDoc.DocumentElement;
        if IsNull(DocumentElement) then
          exit;

        if not SetupData(DocumentElement,DataTypes,Binding,PortTypes,Operations) then
          exit;

        Clear(CommentLine);
        IEnumerator := Operations.GetEnumerator;
        while IEnumerator.MoveNext do begin
          XmlElement := IEnumerator.Current;
          OperationName := XmlElement.GetAttribute("XPathParameter.Name");
          if not CommentLine.Get(CommentLine."Table Name"::Customer,CopyStr(OperationName,1,10),1000) then begin
            CommentLine."Table Name" := CommentLine."Table Name"::Customer;
            CommentLine."No." := CopyStr(OperationName,1,10);
            CommentLine.Code := CopyStr(OperationName,1,10);
            CommentLine."Line No." := 1000;
            CommentLine.Comment := CopyStr(OperationName,1,80);
            CommentLine.Insert;
          end;
        end;

        if (PAGE.RunModal(PAGE::"Comment Line - Retail",CommentLine) = ACTION::LookupOK) then begin
          if not GetOperationMessage(OperationMessage,DocumentElement,PortTypes,CommentLine.Comment) then
             exit;
          CreateNpXml(CommentLine.Comment,OperationMessage,DataTypes,NpXmlTemplate);
        end;
    end;

    local procedure LoadFile(Path: Text;var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        FileName: Text;
        InStream: InStream;
        "--": Integer;
        [RunOnClient]
        FileInfo: DotNet npNetFileInfo;
        FileManagement: Codeunit "File Management";
        ClientTempFileName: Text;
        ServerFileName: Text;
    begin
        FileInfo := FileInfo.FileInfo(Path);
        ClientTempFileName := FileManagement.ClientTempFileName('xml');
        FileInfo.CopyTo(ClientTempFileName);

        if not UploadIntoStream('Import','<TEMP>',' All Files (*.*)|*.*',ClientTempFileName,InStream) then
          exit(false);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);
        exit(true);
    end;

    local procedure SetupData(DocumentElement: DotNet npNetXmlDocument;var DataTypes: DotNet npNetXmlElement;var Binding: DotNet npNetXmlElement;var PortTypes: DotNet npNetXmlElement;var Operations: DotNet npNetXmlNodeList): Boolean
    var
        IEnumerator: DotNet npNetIEnumerator;
        CurrentNsPrefix: Text;
        NameSpaceFound: Boolean;
    begin
        if IsNull(DocumentElement) then
          exit;

        CurrentNsPrefix := GetElementNameSpacePrefix(DocumentElement,'types');
        GetXmlElement(DocumentElement,DataTypes,'types',CurrentNsPrefix);
        if not GetXmlElement(DocumentElement,PortTypes,'portType',CurrentNsPrefix) then
          exit(false);
        if not GetXmlElement(DocumentElement,Binding,'binding',CurrentNsPrefix) then
          exit(false);
        if not GetNodeList(Operations,Binding,'operation',CurrentNsPrefix) then
          exit(false);
        exit(true);
    end;

    local procedure CreateNpXml(NpXmlName: Text;OperationMessage: DotNet npNetXmlDocument;DataTypes: DotNet npNetXmlDocument;NpXmlTemplate: Record "NpXml Template")
    var
        NpXmlElement: Record "NpXml Element";
        IEnumerator: DotNet npNetIEnumerator;
        XmlElement: DotNet npNetXmlElement;
        LineNo: Integer;
        CurrentPrefix: Text;
    begin
        NpXmlName := NpXmlTemplate.Code;

        LineNo := 0;
        GlobalLevel := -1;
        //-NC2.03 [269250]
        GlobalLineNo := 10000;
        //+NC2.03 [269250]
        IEnumerator := OperationMessage.GetEnumerator;
        while IEnumerator.MoveNext do begin
          XmlElement := IEnumerator.Current;
          if not IsSimpleDataType(XmlElement) then
            ImportCustomType(XmlElement.GetAttribute("XPathParameter.Element"),NpXmlName,DataTypes,LineNo)
          else begin
            GlobalLevel := 0;
            CurrentPrefix := GetElementNameSpacePrefix(XmlElement,'message');
            ImportElement(NpXmlName,XmlElement.GetAttribute("XPathParameter.Name"),CurrentPrefix)
          end;
        end;
    end;

    procedure "--- Main"()
    begin
    end;

    local procedure SetNameSpaceManager(XmlDoc: DotNet npNetXmlDocument)
    var
        XPathNavigator: DotNet npNetXPathNavigator;
        XPathNodeType: DotNet npNetXPathNodeType;
        XmlNamespaceScope: DotNet npNetXmlNamespaceScope;
        Dictionary: DotNet npNetIDictionary_Of_T_U;
        IEnumerator: DotNet npNetIEnumerator;
        NameSpace: Text;
        NameSpaceUrl: Text;
    begin
        XmlNsManager := XmlNsManager.XmlNamespaceManager(XmlNameTable);
        XPathNavigator := XmlDoc.CreateNavigator;
        while XPathNavigator.MoveToFollowing(XPathNodeType.Element) do begin
          Dictionary := XPathNavigator.GetNamespacesInScope(XmlNamespaceScope.Local);
          IEnumerator := Dictionary.Keys.GetEnumerator;
          while IEnumerator.MoveNext do begin
            NameSpace := Format(IEnumerator.Current);
            Dictionary.TryGetValue(NameSpace,NameSpaceUrl);
            if not XmlNsManager.HasNamespace(NameSpace) then
              XmlNsManager.AddNamespace(IEnumerator.Current,NameSpaceUrl);
          end;
        end;
    end;

    local procedure GetNameSpaces(XmlDoc: DotNet npNetXmlDocument;var XmlNsManager: DotNet npNetXmlNamespaceManager)
    var
        XPathNavigator: DotNet npNetXPathNavigator;
        XPathNodeType: DotNet npNetXPathNodeType;
        XmlNamespaceScope: DotNet npNetXmlNamespaceScope;
        Dictionary: DotNet npNetIDictionary_Of_T_U;
        IEnumerator: DotNet npNetIEnumerator;
        NameSpace: Text;
        NameSpaceUrl: Text;
    begin
        XmlNsManager := XmlNsManager.XmlNamespaceManager(XmlNameTable);
        XPathNavigator := XmlDoc.CreateNavigator;
        while XPathNavigator.MoveToFollowing(XPathNodeType.Element) do begin
          Dictionary := XPathNavigator.GetNamespacesInScope(XmlNamespaceScope.Local);
          IEnumerator := Dictionary.Keys.GetEnumerator;
          while IEnumerator.MoveNext do begin
            //-NC2.03 [240432]
            NameSpace := Format(IEnumerator.Current);
            //Dictionary.TryGetValue(FORMAT(IEnumerator.Current),NameSpace);
            Dictionary.TryGetValue(NameSpace,NameSpaceUrl);
            //IF NOT XmlNsManager.HasNamespace(FORMAT(IEnumerator.Current)) THEN
            if not XmlNsManager.HasNamespace(NameSpace) then
              //XmlNsManager.AddNamespace(IEnumerator.Current,NameSpace);
              XmlNsManager.AddNamespace(IEnumerator.Current,NameSpaceUrl);
            //+NC2.03 [240432]
          end;
        end;
    end;

    local procedure GetXmlElement(XmlDoc: DotNet npNetXmlDocument;var XmlElement: DotNet npNetXmlDocument;XPath: Text;Prefix: Text): Boolean
    var
        XmlNsManager2: DotNet npNetXmlNamespaceManager;
        NameSpacePrefix: Text;
        test: Text;
    begin
        if Prefix <> '' then
          XmlElement := XmlDoc.SelectSingleNode(Prefix+':'+XPath,XmlNsManager);
          if not IsNull(XmlElement) then
            exit(true);

        XmlNsManager2 := XmlNsManager2.XmlNamespaceManager(XmlNameTable);
        XmlNsManager2.AddNamespace('default',XmlNsManager.DefaultNamespace);
        XmlElement := XmlDoc.SelectSingleNode('default:'+XPath,XmlNsManager2);
        if not IsNull(XmlElement) then
          exit(true);

        //-NC2.03 [240432]
        XmlNsManager2 := XmlNsManager2.XmlNamespaceManager(XmlNameTable);
        XmlNsManager2.AddNamespace('default','http://www.w3.org/2001/XMLSchema');
        XmlElement := XmlDoc.SelectSingleNode('default:'+XPath,XmlNsManager2);
        if not IsNull(XmlElement) then
          exit(true);
        //+NC2.03 [240432]

        exit(false);
    end;

    local procedure GetNodeList(var XmlNodeList: DotNet npNetXmlNodeList;XmlElement: DotNet npNetXmlElement;ElementName: Text;Prefix: Text): Boolean
    var
        XmlNsManager2: DotNet npNetXmlNamespaceManager;
    begin
        if Prefix <> '' then
          XmlNodeList := XmlElement.SelectNodes(Prefix+':'+ElementName,XmlNsManager);
          if not IsNull(XmlNodeList) then
            exit(true);

        XmlNsManager2 := XmlNsManager2.XmlNamespaceManager(XmlNameTable);
        XmlNsManager2.AddNamespace('default',XmlNsManager.DefaultNamespace);
        XmlNodeList := XmlElement.SelectNodes('default:'+ElementName,XmlNsManager2);
        if IsNull(XmlNodeList) then
          exit(false);
        exit(true);
    end;

    local procedure GetOperationMessage(var OperationMessage: DotNet npNetXmlElement;DocumentElement: DotNet npNetXmlDocument;PortTypes: DotNet npNetXmlElement;OperationName: Text): Boolean
    var
        Value: Text;
        XPath: Text;
        PortTypeOperation: DotNet npNetXmlElement;
        Input: DotNet npNetXmlElement;
        CurrentPrefix: Text;
    begin
        if not IsNull(OperationMessage) then
          Clear(OperationMessage);

        CurrentPrefix := GetElementNameSpacePrefix(PortTypes,'operation');
        //XPath := CreateXPath('operation',"XPathParameter.Name",XmlElement.GetAttribute("XPathParameter.Name"));
        XPath := CreateXPath('operation',"XPathParameter.Name",OperationName);
        if not GetXmlElement(PortTypes,PortTypeOperation,XPath,CurrentPrefix) then
           exit(false);
        if not GetXmlElement(PortTypeOperation,Input,'input',CurrentPrefix) then
          exit(false);

        Value := TrimText(Input.GetAttribute('message'));
        XPath := CreateXPath('message',"XPathParameter.Name",Value);
        if not GetXmlElement(DocumentElement,OperationMessage,XPath,CurrentPrefix) then
          exit(false);
        exit(true);
    end;

    procedure "--- Import"()
    begin
    end;

    local procedure ImportCustomType(ElementName: Text;NpXmlName: Text;DataTypes: DotNet npNetXmlDocument;var LineNo: Integer)
    var
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        XmlNodeList2: DotNet npNetXmlNodeList;
        IEnumerator: DotNet npNetIEnumerator;
        XmlElement2: DotNet npNetXmlElement;
        XPath: Text;
        NameSpacePrefix: Text;
        XmlElement3: DotNet npNetXmlElement;
    begin
        if ElementName = '' then
          exit;
        //-[CASE240432]
        //GetNameSpaces(DataTypes,XmlNsManager);
        //+[CASE240432]

        XmlNodeList := DataTypes.ChildNodes;
        IEnumerator := XmlNodeList.GetEnumerator;
        while IEnumerator.MoveNext do begin
          XmlElement := IEnumerator.Current;
          XPath := CreateXPath("XPathParameter.Element","XPathParameter.Name",TrimText(ElementName));
          NameSpacePrefix := GetElementNameSpacePrefix(XmlElement,XPath);

          if GetXmlElement(XmlElement,XmlElement2,XPath,NameSpacePrefix) then begin
            XmlNodeList2 := XmlElement2.ChildNodes;
            if XmlNodeList2.Count > 0 then
              ImportCustomTypeChildNodes(XmlNodeList2,DataTypes,NpXmlName,XmlElement,XmlElement2,NameSpacePrefix);

            if XmlNodeList2.Count = 0 then begin
              XPath := CreateXPath('complexType',"XPathParameter.Name",XmlElement2.GetAttribute("XPathParameter.Type"));
              if GetXmlElement(XmlElement,XmlElement3,XPath,NameSpacePrefix) then begin
                GlobalLevel += 1;
                ImportElement(NpXmlName,TrimText(ElementName),NameSpacePrefix);
                ImportComplexType(XmlElement3,NpXmlName,DataTypes,NameSpacePrefix);
                GlobalLevel -= 1;
              end;
            end;

          end;
        end;
    end;

    local procedure ImportCustomTypeChildNodes(XmlNodeList2: DotNet npNetXmlNodeList;DataTypes: DotNet npNetXmlDocument;NpXmlName: Text;XmlDocument: DotNet npNetXmlElement;XmlElement: DotNet npNetXmlElement;NameSpacePrefix: Text)
    var
        IEnumerator2: DotNet npNetIEnumerator;
        XmlElement2: DotNet npNetXmlElement;
        CurrentNameSpace: Text;
    begin
        IEnumerator2 := XmlNodeList2.GetEnumerator;
        while IEnumerator2.MoveNext do begin
          XmlElement2 := IEnumerator2.Current;

          if NameSpacePrefix = '' then begin
            CurrentNameSpace := 'ns'+Format(GlobalLevel+1);
            InsertNpXmlNameSpace(NpXmlName,CurrentNameSpace,XmlDocument.GetAttribute('targetNamespace'));
          end;

          if IsComplexType(XmlElement2.Name) then
            ImportComplexType(XmlElement2,NpXmlName,DataTypes,CurrentNameSpace)
          else begin
            if GlobalLevel = -1 then GlobalLevel := 0;
            ImportElement(NpXmlName,XmlElement.GetAttribute("XPathParameter.Name"),CurrentNameSpace)
          end;
        end;
    end;

    local procedure ImportComplexType(ComplexType: DotNet npNetXmlElement;NpXmlName: Text;DataTypes: DotNet npNetXmlDocument;Prefix: Text)
    var
        Sequence: DotNet npNetXmlElement;
        XmlElement: DotNet npNetXmlElement;
        IEnumerator: DotNet npNetIEnumerator;
        IEnumerator2: DotNet npNetIEnumerator;
    begin
        //-[CASE240432]
        //GetNameSpaces(DataTypes,XmlNsManager);
        //+[CASE240432]

        IEnumerator := ComplexType.ChildNodes.GetEnumerator;
        while IEnumerator.MoveNext do begin
          Sequence := IEnumerator.Current;
          GlobalLevel += 1;
          IEnumerator2 := Sequence.ChildNodes.GetEnumerator;
          while IEnumerator2.MoveNext do begin
            XmlElement := IEnumerator2.Current;
            ImportElement(NpXmlName,XmlElement.GetAttribute("XPathParameter.Name"),Prefix);
            if not IsSimpleDataType(XmlElement) then
              ImportCustomTypeByNameSpace(XmlElement,DataTypes,NpXmlName,Prefix);
          end;
          GlobalLevel -= 1;
        end;
    end;

    local procedure ImportCustomTypeByNameSpace(XmlElement: DotNet npNetXmlElement;DataTypes: DotNet npNetXmlDocument;NpXmlName: Text;CurrentNameSpace: Text)
    var
        Alias: Text;
        "Schema": DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNsManager: DotNet npNetXmlNamespaceManager;
        ComplexType: DotNet npNetXmlElement;
        XPath: Text;
    begin
        GetNameSpaces(DataTypes,XmlNsManager);

        Alias := ValidateAlias(DataTypes,XmlElement,NpXmlName,CurrentNameSpace);
        if Alias = '' then
          exit;

        if not GetElementFromSchema(DataTypes,XmlElement2,"XPathParameter.Element",TrimText(XmlElement.GetAttribute("XPathParameter.Type"))) then begin
          SetSchemaNameSpace(XmlNsManager.LookupNamespace(Alias));
          if not GetElementFromSchema(DataTypes,XmlElement2,"XPathParameter.Element",TrimText(XmlElement.GetAttribute("XPathParameter.Type"))) then
            exit;
        end;

        XPath := CreateXPath('schema','targetNamespace',XmlNsManager.LookupNamespace(Alias));
        if not GetXmlElement(DataTypes,Schema,XPath,'') then
          exit;

        if not IsSimpleDataType(XmlElement2) then begin
          XPath := CreateXPath('complexType',"XPathParameter.Name",TrimText(XmlElement2.GetAttribute("XPathParameter.Type")));
          if not GetXmlElement(Schema,ComplexType,XPath,'') then
            exit;
          ImportComplexType(ComplexType,NpXmlName,DataTypes,CurrentNameSpace);
          exit;
        end;

        ImportElement(NpXmlName,XmlElement2.GetAttribute("XPathParameter.Name"),'ns'+Format(GlobalLevel+1));
        exit;
    end;

    local procedure ImportElement(NpXmlName: Text;AttributeName: Text;Alias: Text)
    var
        NpXmlElement: Record "NpXml Element";
    begin
        if AttributeName = '' then
          exit;

        Clear(NpXmlElement);
        NpXmlElement."Xml Template Code" := NpXmlName;
        NpXmlElement."Line No." := GlobalLineNo;
        NpXmlElement."Element Name" := AttributeName;
        NpXmlElement.Level := GlobalLevel;
        NpXmlElement.Namespace := Alias;
        NpXmlElement.Insert(true);
        GlobalLineNo += 10000;
    end;

    local procedure GetElementFromSchema(DataTypes: DotNet npNetXmlDocument;var XmlElement: DotNet npNetXmlElement;Attribute: Text;AttributeValue: Text): Boolean
    var
        "Schema": DotNet npNetXmlElement;
        XPath: Text;
    begin
        XPath := CreateXPath('schema','targetNamespace',GetSchemaNameSpace);
        if not GetXmlElement(DataTypes,Schema,XPath,'') then
          exit(false);

        XPath := CreateXPath(Attribute,"XPathParameter.Name",AttributeValue);
        if not GetXmlElement(Schema,XmlElement,XPath,'') then
          exit(false);
        exit(true);
    end;

    procedure "--- Support"()
    begin
    end;

    local procedure TrimText(Input: Text): Text
    begin
        exit(CopyStr(Input,StrPos(Input,':')+1,StrLen(Input)-StrPos(Input,':')));
    end;

    local procedure IsSimpleDataType(XmlElement: DotNet npNetXmlElement): Boolean
    begin
        if TrimText(XmlElement.GetAttribute('element')) in ['string','decimal','int','long','double','date','dateTime'] then
          exit(true);

        if TrimText(XmlElement.GetAttribute('type')) in ['string','decimal','int','long','double','date','dateTime'] then
          exit(true);
        exit(false);
    end;

    local procedure IsComplexType(Name: Text): Boolean
    begin
        exit(TrimText(Name) = 'complexType');
    end;

    local procedure GetPrefix(Attribute: Text): Text
    var
        Prefix: Text;
    begin
        Prefix := CopyStr(Attribute,1,StrPos(Attribute,':'));
        if Prefix = '' then
          exit('');

        exit(CopyStr(Prefix,1,StrLen(Prefix)-1));
    end;

    local procedure GetElementNameSpacePrefix(XmlElement: DotNet npNetXmlElement;ElementName: Text): Text
    var
        IEnumerator: DotNet npNetIEnumerator;
        CurrentNsPrefix: Text;
        XmlElement2: DotNet npNetXmlElement;
    begin
        IEnumerator := XmlNsManager.GetEnumerator;
        while IEnumerator.MoveNext do begin
          CurrentNsPrefix := Format(IEnumerator.Current);
          if CurrentNsPrefix <> '' then begin
            if not IsNull(XmlElement.SelectSingleNode(CurrentNsPrefix+':'+ElementName,XmlNsManager)) then
              exit(CurrentNsPrefix);
          end;
        end;
        exit('');
    end;

    procedure SetSchemaNameSpace(NameSpace: Text)
    begin
        SchemaNameSpace := NameSpace;
    end;

    procedure GetSchemaNameSpace(): Text
    begin
        exit(SchemaNameSpace);
    end;

    local procedure InsertNpXmlNameSpace(NpXmlName: Text;Alias: Text;NameSpace: Text)
    var
        NpXmlNamespaces: Record "NpXml Namespace";
    begin
        if NpXmlNamespaces.Get(NpXmlName,Alias) then
          exit;

        Clear(NpXmlNamespaces);
        NpXmlNamespaces."Xml Template Code" := NpXmlName;
        NpXmlNamespaces.Alias := Alias;
        NpXmlNamespaces.Namespace := NameSpace;
        NpXmlNamespaces.Insert(true);
    end;

    local procedure ValidateAlias(DataTypes: DotNet npNetXmlDocument;XmlElement: DotNet npNetXmlElement;NpXmlName: Text;var CurrentNameSpace: Text): Text
    var
        Alias: Text;
        ComplexType: DotNet npNetXmlElement;
    begin
        Alias := GetPrefix(XmlElement.GetAttribute("XPathParameter.Type"));

        if Alias = '' then
          exit(''); // - Not a well defined WSDL. Not sure if it is possible to create this scenario e.g. type='sales_order' ?

        if Alias = 'tns' then begin
          if not GetElementFromSchema(DataTypes,ComplexType,'complexType',TrimText(XmlElement.GetAttribute("XPathParameter.Type"))) then
            exit('');
          ImportComplexType(ComplexType,NpXmlName,DataTypes,CurrentNameSpace);
          exit('');
        end;

        if not XmlNsManager.HasNamespace(Alias) then
          exit('');

        CurrentNameSpace := 'ns'+Format(GlobalLevel+1);
        InsertNpXmlNameSpace(NpXmlName,CurrentNameSpace,XmlNsManager.LookupNamespace(Alias));
        exit(Alias);
    end;

    procedure "--- XPath Help Functions"()
    begin
    end;

    local procedure "XPathParameter.Name"(): Text
    begin
        exit('name');
    end;

    local procedure "XPathParameter.Type"(): Text
    begin
        exit('type');
    end;

    local procedure "XPathParameter.Element"(): Text
    begin
        exit('element');
    end;

    local procedure CreateXPath(Element: Text;Attribute: Text;AttributeName: Text): Text
    begin
        exit(Element+'[@'+Attribute+'='+''''+AttributeName+''''+']');
    end;
}

