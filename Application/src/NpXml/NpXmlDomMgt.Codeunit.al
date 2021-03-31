codeunit 6151554 "NPR NpXml Dom Mgt."
{
    var
        Error003: Label 'Xml element %1 is missing in %2';
        Error004: Label 'Xml attribute %1 is missing in %2';
        Text000: Label 'XmlElement %1 is missing';
        Text001: Label 'Value "%1" is not %2 in <%3>';

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure AddAttribute(var XmlNode: DotNet NPRNetXmlNode; Name: Text[260]; NodeValue: Text[260]) ExitStatus: Integer
    var
        NewAttributeXmlNode: DotNet NPRNetXmlNode;
    begin
        NewAttributeXmlNode := XmlNode.OwnerDocument.CreateAttribute(Name);

        if IsNull(NewAttributeXmlNode) then begin
            ExitStatus := 60;
            exit(ExitStatus)
        end;

        if NodeValue <> '' then
            NewAttributeXmlNode.InnerText := NodeValue;

        XmlNode.Attributes.SetNamedItem(NewAttributeXmlNode);
    end;

    procedure AddAttribute(var Node: XmlNode; AttributeName: Text[260]; AttributeValue: Text[260])
    begin
        if (AttributeName in ['', 'xmlns']) OR (AttributeName.Contains(':')) then
            exit;

        if AttributeValue <> '' then
            Node.AsXmlElement.SetAttribute(AttributeName, AttributeValue);
    end;

    procedure AddAttribute(var Element: XmlElement; AttributeName: Text[260]; AttributeValue: Text[260])
    begin
        if (AttributeName in ['', 'xmlns']) OR (AttributeName.Contains(':')) then
            exit;

        if AttributeValue <> '' then
            Element.SetAttribute(AttributeName, AttributeValue);
    end;

    procedure AddNamespaceDeclaration(var Element: XmlElement; Prefix: Text[260]; Uri: Text[260])
    begin
        if (Prefix in ['', 'xmlns']) OR (Prefix.Contains(':')) then
            exit;

        if Uri <> '' then
            Element.Add(XmlAttribute.CreateNamespaceDeclaration(Prefix, Uri));
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure AddAttributeNamespace(var XmlNode: DotNet NPRNetXmlNode; Name: Text[260]; Namespace: Text; NodeValue: Text[260]) ExitStatus: Integer
    var
        NewAttributeXmlNode: DotNet NPRNetXmlNode;
    begin
        NewAttributeXmlNode := XmlNode.OwnerDocument.CreateAttribute(Name, Namespace);
        if IsNull(NewAttributeXmlNode) then begin
            ExitStatus := 60;
            exit(ExitStatus)
        end;

        if NodeValue <> '' then
            NewAttributeXmlNode.InnerText := NodeValue;

        XmlNode.Attributes.SetNamedItem(NewAttributeXmlNode);
    end;

    procedure AddAttributeNamespace(var Node: XmlNode; Prefix: Text[260]; AttributeName: Text[260]; NamespaceUri: Text; AttributeValue: Text[260])
    begin
        if (Prefix = '') OR (AttributeName = '') then
            exit;

        if (Prefix.Contains(':')) OR (AttributeName.Contains(':')) then
            exit;

        if AttributeValue <> '' then begin
            Node.AsXmlElement.Add(XmlAttribute.CreateNamespaceDeclaration(Prefix, NamespaceUri));
            Node.AsXmlElement.Add(XmlAttribute.Create(AttributeName, NamespaceUri, AttributeValue));
        end;
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure AddElement(var XmlElement: DotNet NPRNetXmlElement; ElementName: Text[250]; var CreatedXmlElement: DotNet NPRNetXmlElement)
    var
        NewChildXmlElement: DotNet NPRNetXmlElement;
        XmlNodeType: DotNet NPRNetXmlNodeType;
    begin
        NewChildXmlElement := XmlElement.OwnerDocument.CreateNode(XmlNodeType.Element, ElementName, '');
        XmlElement.AppendChild(NewChildXmlElement);
        CreatedXmlElement := NewChildXmlElement;
    end;

    procedure AddElement(var Element: XmlElement; ElementName: Text[250]; var CreatedXmlElement: XmlElement)
    begin
        CreatedXmlElement := XmlElement.Create(ElementName);
        Element.Add(CreatedXmlElement);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure AddElementNamespace(var XmlElement: DotNet NPRNetXmlElement; ElementName: Text; Namespace: Text; var CreatedXmlElement: DotNet NPRNetXmlElement)
    var
        NewChildXmlElement: DotNet NPRNetXmlElement;
        XmlNodeType: DotNet NPRNetXmlNodeType;
    begin
        if Namespace = '' then
            Namespace := XmlElement.OwnerDocument.NamespaceURI();
        NewChildXmlElement := XmlElement.OwnerDocument.CreateNode(XmlNodeType.Element, ElementName, Namespace);
        XmlElement.AppendChild(NewChildXmlElement);
        CreatedXmlElement := NewChildXmlElement;
    end;

    procedure AddElementNamespace(var Node: XmlNode; ElementName: Text; Namespace: Text; var CreatedXmNode: XmlNode)
    var
        Element: XmlElement;
        CreatedXmlElement: XmlElement;
    begin
        Element := Node.AsXmlElement();

        if Namespace = '' then
            Namespace := Element.NamespaceUri;

        CreatedXmlElement := XmlElement.Create(ElementName, Namespace);
        Element.Add(CreatedXmlElement);
        CreatedXmNode := CreatedXmlElement.AsXmlNode();
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure FindNode(XmlNode: DotNet NPRNetXmlNode; NodePath: Text[250]; var XmlNodeChild: DotNet NPRNetXmlNode): Boolean
    begin
        if IsNull(XmlNode) then
            exit(false);

        XmlNodeChild := XmlNode.SelectSingleNode(NodePath);

        exit(not IsNull(XmlNodeChild));
    end;

    procedure FindNode(Node: XmlNode; NodePath: Text[250]; var NodeChild: XmlNode): Boolean
    begin
        if not Node.SelectSingleNode(NodePath, NodeChild) then
            exit(false);

        exit(not NodeChild.AsXmlElement.IsEmpty());
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure FindNodes(XmlNode: DotNet NPRNetXmlNode; NodePath: Text[250]; var XmlNodeList: DotNet NPRNetXmlNodeList): Boolean
    begin
        XmlNodeList := XmlNode.SelectNodes('//' + NodePath);

        exit(not IsNull(XmlNodeList));
    end;

    procedure FindNodes(Node: XmlNode; NodePath: Text[250]; var NodeList: XmlNodeList): Boolean
    begin
        Node.SelectNodes('//' + NodePath, NodeList);

        exit(not (NodeList.Count = 0));
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure InitDoc(var XmlDoc: DotNet "NPRNetXmlDocument"; var XmlDocNode: DotNet NPRNetXmlNode; NodeName: Text[1024])
    begin
        if not IsNull(XmlDoc) then
            Clear(XmlDoc);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<' + NodeName + ' />');

        XmlDocNode := XmlDoc.DocumentElement();
    end;

    procedure InitDoc(var XmlDoc: XmlDocument; var XmlDocNode: XmlNode; NodeName: Text[1024])
    var
        Element: XmlElement;
    begin
        Clear(XmlDoc);
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?>' + '<' + NodeName + ' />', XmlDoc);
        XmlDoc.GetRoot(Element);
        XmlDocNode := Element.AsXmlNode();
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure IsLeafNode(XmlNode: DotNet NPRNetXmlNode): Boolean
    var
        XmlNode2: DotNet NPRNetXmlNode;
    begin
        if not XmlNode.HasChildNodes then
            exit(true);

        XmlNode2 := XmlNode.FirstChild;
        repeat
            if XmlNode2.Name <> '#text' then
                exit(false);
            XmlNode2 := XmlNode2.NextSibling;
        until IsNull(XmlNode2);

        exit(true);
    end;

    procedure IsLeafNode(Node: XmlNode): Boolean
    var
        ChildNodesList: XmlNodeList;
        ChildNode: XmlNode;
    begin
        if not Node.AsXmlElement.HasElements then
            exit(true);

        ChildNodesList := Node.AsXmlElement.GetChildElements();
        foreach ChildNode in ChildNodesList do
            if ChildNode.AsXmlElement.Name <> '#text' then
                exit(false);

        exit(true);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetXmlText(XmlElement: DotNet NPRNetXmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        if IsNull(XmlElement) then begin
            if Required then
                Error(Error003, NodePath, '');
            exit('');
        end;

        XmlElement2 := XmlElement.SelectSingleNode(NodePath);
        if IsNull(XmlElement2) then begin
            if Required then
                Error(Error003, NodePath, XmlElement.Name);
            exit('');
        end;

        if MaxLength > 0 then
            exit(CopyStr(XmlElement2.InnerText, 1, MaxLength));

        exit(XmlElement2.InnerText);
    end;

    procedure GetXmlText(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text
    var
        Element2: XmlElement;
        Node: XmlNode;
    begin
        if Element.IsEmpty() then begin
            if Required then
                Error(Error003, NodePath, '');
            exit('');
        end;

        Element.SelectSingleNode(NodePath, Node);
        Element2 := Node.AsXmlElement();
        if Element2.IsEmpty then begin
            if Required then
                Error(Error003, NodePath, Element.Name);
            exit('');
        end;

        if MaxLength > 0 then
            exit(CopyStr(Element2.InnerText, 1, MaxLength));

        exit(Element2.InnerText);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetXmlTextNamespace(XmlElement: DotNet NPRNetXmlElement; NodePath: Text; XmlNsManager: DotNet NPRNetXmlNamespaceManager; MaxLength: Integer; Required: Boolean): Text
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        if IsNull(XmlElement) then begin
            if Required then
                Error(Error003, NodePath, '');
            exit('');
        end;

        XmlElement2 := XmlElement.SelectSingleNode(NodePath, XmlNsManager);
        if IsNull(XmlElement2) then begin
            if Required then
                Error(Error003, NodePath, XmlElement.Name);
            exit('');
        end;

        if MaxLength > 0 then
            exit(CopyStr(XmlElement2.InnerText, 1, MaxLength));

        exit(XmlElement2.InnerText);
    end;

    procedure GetXmlTextNamespace(Element: XmlElement; NodePath: Text; XmlNsManager: XmlNamespaceManager; MaxLength: Integer; Required: Boolean): Text
    var
        Element2: XmlElement;
        Node: XmlNode;
    begin
        if Element.IsEmpty() then begin
            if Required then
                Error(Error003, NodePath, '');
            exit('');
        end;

        Element.SelectSingleNode(NodePath, XmlNsManager, Node);
        Element2 := Node.AsXmlElement();
        if Element2.IsEmpty then begin
            if Required then
                Error(Error003, NodePath, Element.Name);
            exit('');
        end;

        if MaxLength > 0 then
            exit(CopyStr(Element2.InnerText, 1, MaxLength));

        exit(Element2.InnerText);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetXmlAttributeText(XmlElement: DotNet NPRNetXmlElement; AttributeName: Text; Required: Boolean) AttributeText: Text
    begin
        AttributeText := XmlElement.GetAttribute(AttributeName);
        if (Required) and (AttributeText = '') then
            Error(Error004, AttributeName, XmlElement.Name);
    end;

    procedure GetXmlAttributeText(Element: XmlElement; AttributeName: Text; Required: Boolean) AttributeText: Text
    var
        Attribute: XmlAttribute;
    begin
        GetAttributeFromElement(Element, AttributeName, Attribute, Required);
        AttributeText := Attribute.Value;
        if Required and (AttributeText = '') then
            Error(Error004, AttributeName, Element.Name);
    end;

    procedure GetXmlAttributeText(Element: XmlNode; AttributeName: Text; Required: Boolean) AttributeText: Text
    var
        Attribute: XmlAttribute;
    begin
        GetAttributeFromElement(Element.AsXmlElement(), AttributeName, Attribute, Required);
        AttributeText := Attribute.Value;
        if Required and (AttributeText = '') then
            Error(Error004, AttributeName, Element.AsXmlElement().Name);
    end;

    [TryFunction]
    [Obsolete('This function is not needed. Please use standard AL function: XmlDocument.Load();', '')]
    procedure TryLoadXml(XmlString: Text; var XmlDoc: DotNet "NPRNetXmlDocument")
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlString);
    end;

    procedure PrettyPrintXml(XmlString: Text) PrettyXml: Text
    var
        XmlDoc: XmlDocument;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Buffer: Text;
    begin
        if not XmlDocument.ReadFrom(XmlString, XmlDoc) then
            exit(XmlString);

        TempBlob.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        XmlDoc.WriteTo(OutStr);

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);
        while not InStr.EOS do begin
            InStr.ReadText(Buffer);
            PrettyXml += Buffer;
        end;
    end;

    [TryFunction]
    [Obsolete('Use standard procedure RemoveNamespaces from Codeunit "XML DOM Management". Entry parametar is Text and it returns cleared Text as output', '')]
    procedure RemoveNameSpaces(var XmlDoc: DotNet "NPRNetXmlDocument")
    var
        MemoryStream: DotNet NPRNetMemoryStream;
        MemoryStream2: DotNet NPRNetMemoryStream;
        XmlStyleSheet: DotNet "NPRNetXmlDocument";
        XslCompiledTransform: DotNet NPRNetXslCompiledTransform;
        XmlReader: DotNet NPRNetXmlReader;
        XmlWriter: DotNet NPRNetXmlWriter;
    begin
        if IsNull(XmlStyleSheet) then begin
            XmlStyleSheet := XmlStyleSheet.XmlDocument;
            XmlStyleSheet.LoadXml('<?xml version="1.0" encoding="UTF-8"?>' +
                                  '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">' +
                                    '<xsl:output method="xml" encoding="UTF-8" />' +
                                    '<xsl:template match="/">' +
                                      '<xsl:copy>' +
                                        '<xsl:apply-templates />' +
                                      '</xsl:copy>' +
                                    '</xsl:template>' +
                                    '<xsl:template match="*">' +
                                      '<xsl:element name="{local-name()}">' +
                                         '<xsl:apply-templates select="@* | node()" />' +
                                      '</xsl:element>' +
                                    '</xsl:template>' +
                                    '<xsl:template match="@*">' +
                                      '<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>' +
                                    '</xsl:template>' +
                                    '<xsl:template match="text() | processing-instruction() | comment()">' +
                                      '<xsl:copy />' +
                                    '</xsl:template>' +
                                  '</xsl:stylesheet>');
            XslCompiledTransform := XslCompiledTransform.XslCompiledTransform;
            XslCompiledTransform.Load(XmlStyleSheet);
        end;
        MemoryStream := MemoryStream.MemoryStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Position := 0;
        XmlReader := XmlReader.Create(MemoryStream);

        MemoryStream2 := MemoryStream2.MemoryStream;
        XmlWriter := XmlWriter.Create(MemoryStream2);
        XslCompiledTransform.Transform(XmlReader, XmlWriter);
        MemoryStream2.Position := 0;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream2);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure FindElement(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean; var XmlElement2: DotNet NPRNetXmlElement): Boolean
    begin
        if IsNull(XmlElement) then begin
            if not Required then
                exit(false);

            Error(Text000, XmlElement.Name + '/' + Path);
        end;

        XmlElement2 := XmlElement.SelectSingleNode(Path);
        if IsNull(XmlElement2) and Required then
            Error(Text000, XmlElement.Name + '/' + Path);

        exit(not IsNull(XmlElement2));
    end;

    procedure FindElement(Element: XmlElement; Path: Text; Required: Boolean; var Element2: XmlElement): Boolean
    var
        Node: XmlNode;
    begin
        if Element.IsEmpty() then begin
            if not Required then
                exit(false);

            Error(Text000, Element.Name + '/' + Path);
        end;

        if not Element.SelectSingleNode(Path, Node) then begin
            if not Required then begin
                ClearLastError;
                exit(false);
            end;

            Error(Text000, Element.Name + '/' + Path);
        end;

        Element2 := Node.AsXmlElement();
        if Element2.IsEmpty() and Required then
            Error(Text000, Element.Name + '/' + Path);

        exit(not Element2.IsEmpty());
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementBoolean(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: Boolean
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(false);
        end;

        if not Evaluate(Value, XmlElement2.InnerText, 9) then begin
            if not Required then
                exit(false);

            Error(Text001, XmlElement2.InnerText, GetDotNetType(Value), XmlElement.Name + '/' + Path);
        end;

        exit(Value);
    end;

    procedure GetElementBoolean(Element: XmlElement; Path: Text; Required: Boolean) ReturnValue: Boolean
    var
        Element2: XmlElement;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(false);
        end;

        if not Evaluate(ReturnValue, Element2.InnerText, 9) then begin
            if not Required then
                exit(false);

            Error(Text001, Element2.InnerText, GetDotNetType(ReturnValue), Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementCode(XmlElement: DotNet NPRNetXmlElement; Path: Text; MaxLength: Integer; Required: Boolean) Value: Code[1024]
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit('');
        end;

        TextValue := XmlElement2.InnerText;
        if MaxLength > 0 then
            TextValue := CopyStr(TextValue, 1, MaxLength);

        Value := UpperCase(CopyStr(TextValue, 1, MaxStrLen(Value)));

        exit(Value);
    end;

    procedure GetElementCode(Element: XmlElement; Path: Text; MaxLength: Integer; Required: Boolean) ReturnValue: Code[1024]
    var
        Element2: XmlElement;
        TextValue: Text;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit('');
        end;

        TextValue := Element2.InnerText;
        if MaxLength > 0 then
            TextValue := CopyStr(TextValue, 1, MaxLength);

        ReturnValue := UpperCase(CopyStr(TextValue, 1, MaxStrLen(ReturnValue)));

        exit(ReturnValue);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementDate(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: Date
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0D);
        end;

        if not Evaluate(Value, XmlElement2.InnerText, 9) then begin
            if not Required then
                exit(0D);

            Error(Text001, XmlElement2.InnerText, GetDotNetType(Value), XmlElement.Name + '/' + Path);
        end;

        exit(Value);
    end;

    procedure GetElementDate(Element: XmlElement; Path: Text; Required: Boolean) ReturnValue: Date
    var
        Element2: XmlElement;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(0D);
        end;

        if not Evaluate(ReturnValue, Element2.InnerText, 9) then begin
            if not Required then
                exit(0D);

            Error(Text001, Element2.InnerText, GetDotNetType(ReturnValue), Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementDec(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: Decimal
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0);
        end;

        if not Evaluate(Value, XmlElement2.InnerText, 9) then begin
            if not Required then
                exit(0);

            Error(Text001, XmlElement2.InnerText, GetDotNetType(Value), XmlElement.Name + '/' + Path);
        end;

        exit(Value);
    end;

    procedure GetElementDec(Element: XmlElement; Path: Text; Required: Boolean) ReturnValue: Decimal
    var
        Element2: XmlElement;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(0);
        end;

        if not Evaluate(ReturnValue, Element2.InnerText, 9) then begin
            if not Required then
                exit(0);

            Error(Text001, Element2.InnerText, GetDotNetType(ReturnValue), Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
    end;

    procedure GetElementDT(Element: XmlElement; Path: Text; Required: Boolean) ReturnValue: DateTime
    var
        Element2: XmlElement;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(0DT);
        end;

        if not Evaluate(ReturnValue, Element2.InnerText, 9) then begin
            if not Required then
                exit(0DT);

            Error(Text001, Element2.InnerText, GetDotNetType(ReturnValue), Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementInt(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: Integer
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0);
        end;

        if not Evaluate(Value, XmlElement2.InnerText, 9) then begin
            if not Required then
                exit(0);

            Error(Text001, XmlElement2.InnerText, GetDotNetType(Value), XmlElement.Name + '/' + Path);
        end;

        exit(Value);
    end;

    procedure GetElementInt(Element: XmlElement; Path: Text; Required: Boolean) ReturnValue: Integer
    var
        Element2: XmlElement;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(0);
        end;

        if not Evaluate(ReturnValue, Element2.InnerText, 9) then begin
            if not Required then
                exit(0);

            Error(Text001, Element2.InnerText, GetDotNetType(ReturnValue), Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementText(XmlElement: DotNet NPRNetXmlElement; Path: Text; MaxLength: Integer; Required: Boolean) Value: Text
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit('');
        end;

        Value := XmlElement2.InnerText;
        if MaxLength > 0 then
            Value := CopyStr(Value, 1, MaxLength);

        exit(Value);
    end;

    procedure GetElementText(Element: XmlElement; Path: Text; MaxLength: Integer; Required: Boolean) ReturnValue: Text
    var
        Element2: XmlElement;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit('');
        end;

        ReturnValue := Element2.InnerText;
        if MaxLength > 0 then
            ReturnValue := CopyStr(ReturnValue, 1, MaxLength);

        exit(ReturnValue);
    end;

    procedure GetElementDuration(Element: XmlElement; Path: Text; Required: Boolean) ReturnValue: Duration
    var
        Element2: XmlElement;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(0);
        end;

        if not Evaluate(ReturnValue, Element2.InnerText, 9) then begin
            if not Required then
                exit(0);

            Error(Text001, Element2.InnerText, GetDotNetType(ReturnValue), Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
    end;

    procedure GetAttributeBigInt(Element: XmlElement; Path: Text; Name: Text; Required: Boolean) ReturnValue: BigInteger
    var
        Element2: XmlElement;
        Attribute: XmlAttribute;
        TextValue: Text;
        FullPath: Text;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(0);
        end;

        GetAttributeFromElement(Element2, Name, Attribute, Required);
        TextValue := Attribute.Value;
        if not Evaluate(ReturnValue, TextValue, 9) then begin
            if not Required then
                exit(0);

            FullPath := Element.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(ReturnValue), FullPath);
        end;

        exit(ReturnValue);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetAttributeCode(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; MaxLength: Integer; Required: Boolean) Value: Code[1024]
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit('');
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if MaxLength > 0 then
            TextValue := CopyStr(TextValue, 1, MaxLength);

        Value := UpperCase(CopyStr(TextValue, 1, MaxStrLen(Value)));

        exit(Value);
    end;

    procedure GetAttributeCode(Element: XmlElement; Path: Text; Name: Text; MaxLength: Integer; Required: Boolean) ReturnValue: Code[1024]
    var
        Element2: XmlElement;
        TextValue: Text;
        Attribute: XmlAttribute;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit('');
        end;

        GetAttributeFromElement(Element2, Name, Attribute, Required);
        TextValue := Attribute.Value;
        if MaxLength > 0 then
            TextValue := CopyStr(TextValue, 1, MaxLength);

        ReturnValue := UpperCase(CopyStr(TextValue, 1, MaxStrLen(ReturnValue)));

        exit(ReturnValue);
    end;

    procedure GetAttributeInt(Element: XmlElement; Path: Text; Name: Text; Required: Boolean) ReturnValue: Integer
    var
        Element2: XmlElement;
        Attribute: XmlAttribute;
        TextValue: Text;
        FullPath: Text;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit(0);
        end;

        GetAttributeFromElement(Element2, Name, Attribute, Required);
        TextValue := Attribute.Value;
        if not Evaluate(ReturnValue, TextValue, 9) then begin
            if not Required then
                exit(0);

            FullPath := Element.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(ReturnValue), FullPath);
        end;

        exit(ReturnValue);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetAttributeText(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; MaxLength: Integer; Required: Boolean) Value: Text
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit('');
        end;

        Value := XmlElement2.GetAttribute(Name);
        if MaxLength > 0 then
            Value := CopyStr(Value, 1, MaxLength);

        exit(Value);
    end;

    procedure GetAttributeText(Element: XmlElement; Path: Text; Name: Text; MaxLength: Integer; Required: Boolean) ReturnValue: Text
    var
        Element2: XmlElement;
        Attribute: XmlAttribute;
    begin
        Element2 := Element;
        if Path <> '' then begin
            if (not FindElement(Element, Path, Required, Element2)) then
                exit('');
        end;

        GetAttributeFromElement(Element2, Name, Attribute, Required);
        ReturnValue := Attribute.Value;
        if MaxLength > 0 then
            ReturnValue := CopyStr(ReturnValue, 1, MaxLength);

        exit(ReturnValue);
    end;

    [Obsolete('This function is not needed anymore. Now we are using native AL HttpResponseMessage from HttpClient.', '')]
    procedure GetWebExceptionMessage(var WebException: DotNet NPRNetWebException) ExceptionMessage: Text
    var
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        InnerWebException: DotNet NPRNetWebException;
        LastErrorText: Text;
    begin
        LastErrorText := GetLastErrorText;
        if IsNull(WebException) then
            exit(LastErrorText);

        if TryGetInnerWebException(WebException, InnerWebException) then begin
            if TryGetWebExceptionResponse(InnerWebException, HttpWebResponse) then begin
                ExceptionMessage := GetWebResponseText(HttpWebResponse);
                if ExceptionMessage <> '' then
                    exit(ExceptionMessage);
            end;

            if not IsNull(InnerWebException) then begin
                if InnerWebException.Message <> '' then
                    exit(InnerWebException.Message);
            end;
        end;

        if TryGetWebExceptionResponse(WebException, HttpWebResponse) then begin
            ExceptionMessage := GetWebResponseText(HttpWebResponse);
            if ExceptionMessage <> '' then
                exit(ExceptionMessage);
        end;

        if WebException.Message <> '' then
            exit(WebException.Message);

        exit(LastErrorText);
    end;

    [Obsolete('This function is not needed anymore. Now we are using native AL HttpResponseMessage from HttpClient.', '')]
    procedure GetWebResponseText(var HttpWebResponse: DotNet NPRNetHttpWebResponse) ResponseText: Text
    var
        HttpWebException: DotNet NPRNetWebException;
        BinaryReader: DotNet NPRNetBinaryReader;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        APIUsername: Text;
        ElementName: Text;
        Response: Text;
    begin
        if TryReadResponseText(HttpWebResponse, ResponseText) then
            exit(ResponseText);

        exit('');
    end;

    [Obsolete('This function is not needed anymore. Now we are using native AL HttpClient filetype to send WebRequest.', '')]
    procedure SendWebRequest(var XmlDoc: DotNet "NPRNetXmlDocument"; HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse; var WebException: DotNet NPRNetWebException): Boolean
    begin
        HttpWebRequest.KeepAlive(false);
        if TryGetWebResponse(XmlDoc, HttpWebRequest, HttpWebResponse) then
            exit(true);

        WebException := GetLastErrorObject;
        exit(false);
    end;

    [Obsolete('This function is not needed anymore. Now we are using native AL HttpClient filetype to send WebRequest.', '')]
    procedure SendWebRequestText(Request: Text; HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse; var WebException: DotNet NPRNetWebException): Boolean
    begin
        HttpWebRequest.KeepAlive(false);
        if TryGetWebResponseText(Request, HttpWebRequest, HttpWebResponse) then
            exit(true);

        WebException := GetLastErrorObject;

        exit(false);
    end;

    [Obsolete('We have agreed in "Remove .NET i AL" MS teams chat that we will skip calls for this function because it probably is not needed. And if at the end we find that it is still needed, we will lookup for alternatives.', '')]
    procedure SetTrustedCertificateValidation(var HttpWebRequest: DotNet NPRNetHttpWebRequest)
    var
        NpWebRequest: DotNet NPRNetNpWebRequest;
    begin
        NpWebRequest := NpWebRequest.NpWebRequest;
        NpWebRequest.SetTrustedCertificateValidation(HttpWebRequest);
    end;

    [TryFunction]
    [Obsolete('This function is not needed anymore. Now we are using native AL HttpResponseMessage from HttpClient.', '')]
    local procedure TryGetInnerWebException(var WebException: DotNet NPRNetWebException; var InnerWebException: DotNet NPRNetWebException)
    begin
        InnerWebException := WebException.InnerException;
    end;

    [TryFunction]
    [Obsolete('This function is not needed anymore. Now we are using native AL HttpResponseMessage from HttpClient.', '')]
    local procedure TryGetWebExceptionResponse(var WebException: DotNet NPRNetWebException; var HttpWebResponse: DotNet NPRNetHttpWebResponse)
    begin
        HttpWebResponse := WebException.Response;
    end;

    [TryFunction]
    [Obsolete('This function is not needed anymore. Now we are using native AL HttpResponseMessage from HttpClient.', '')]
    local procedure TryGetWebResponse(var XmlDoc: DotNet "NPRNetXmlDocument"; HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse)
    var
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    [Obsolete('This function is not needed anymore. Now we are using native AL HttpResponseMessage from HttpClient.', '')]
    local procedure TryGetWebResponseText(var Request: Text; HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse)
    var
        StreamWriter: DotNet NPRNetStreamWriter;
        Stream: DotNet NPRNetStream;
    begin
        Stream := HttpWebRequest.GetRequestStream;
        StreamWriter := StreamWriter.StreamWriter(Stream);
        StreamWriter.Write(Request);
        StreamWriter.Close;
        Stream.Close;
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    [Obsolete('This function is not needed anymore. Now we are using native AL HttpResponseMessage from HttpClient.', '')]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet NPRNetHttpWebResponse; var ResponseText: Text)
    var
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        ResponseText := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        Clear(Stream);
    end;

    procedure GetAttributeFromElement(Element: XmlElement; AttributeName: Text; var Attribute: XmlAttribute; Required: Boolean);
    var
        AttributeCollection: XmlAttributeCollection;
    begin
        AttributeCollection := Element.Attributes();

        if (Required) then
            AttributeCollection.Get(AttributeName, Attribute);

        if (not Required) then
            if (not AttributeCollection.Get(AttributeName, Attribute)) then
                Attribute := XmlAttribute.Create(AttributeName, '');
    end;
}
