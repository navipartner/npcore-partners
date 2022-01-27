codeunit 6151554 "NPR NpXml Dom Mgt."
{
    var
        Error003: Label 'Xml element %1 is missing in %2';
        Error004: Label 'Xml attribute %1 is missing in %2';
        Text000: Label 'XmlElement %1 is missing';
        Text001: Label 'Value "%1" is not Boolean in <%2>';
        Text002: Label 'Value "%1" is not Date in <%2>';
        Text003: Label 'Value "%1" is not Decimal in <%2>';
        Text004: Label 'Value "%1" is not DateTime in <%2>';
        Text005: Label 'Value "%1" is not Integer in <%2>';
        Text006: Label 'Value "%1" is not Duration in <%2>';
        Text007: Label 'Value "%1" is not BigInteger in <%2>';

    procedure AddAttribute(var Node: XmlNode; AttributeName: Text[260]; AttributeValue: Text[260])
    begin
        if (AttributeName in ['', 'xmlns']) OR (AttributeName.Contains(':')) then
            exit;

        if AttributeValue <> '' then
            Node.AsXmlElement().SetAttribute(AttributeName, AttributeValue);
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

    procedure AddAttributeNamespace(var Node: XmlNode; Prefix: Text[260]; AttributeName: Text[260]; NamespaceUri: Text; AttributeValue: Text[260])
    begin
        if (Prefix = '') OR (AttributeName = '') then
            exit;

        if (Prefix.Contains(':')) OR (AttributeName.Contains(':')) then
            exit;

        if AttributeValue <> '' then begin
            Node.AsXmlElement().Add(XmlAttribute.CreateNamespaceDeclaration(Prefix, NamespaceUri));
            Node.AsXmlElement().Add(XmlAttribute.Create(AttributeName, NamespaceUri, AttributeValue));
        end;
    end;

    procedure AddElement(var Element: XmlElement; ElementName: Text[250]; var CreatedXmlElement: XmlElement)
    begin
        CreatedXmlElement := XmlElement.Create(ElementName);
        Element.Add(CreatedXmlElement);
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

    procedure FindNode(Node: XmlNode; NodePath: Text[250]; var NodeChild: XmlNode): Boolean
    begin
        if not Node.SelectSingleNode(NodePath, NodeChild) then
            exit(false);

        exit(true);
    end;

    procedure FindNodes(Node: XmlNode; NodePath: Text[250]; var NodeList: XmlNodeList): Boolean
    begin
        Node.SelectNodes('//' + NodePath, NodeList);

        exit(true);
    end;

    procedure InitDoc(var XmlDoc: XmlDocument; var XmlDocNode: XmlNode; NodeName: Text[1024]; CustomNamespaceForXMLNS: Text[100])
    var
        Element: XmlElement;
    begin
        Clear(XmlDoc);
        if CustomNamespaceForXMLNS = '' then
            XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?>' + '<' + NodeName + ' />', XmlDoc)
        else
            XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?>' + '<' + NodeName + ' xmlns="' + CustomNamespaceForXMLNS + '" />', XmlDoc);
        XmlDoc.GetRoot(Element);
        XmlDocNode := Element.AsXmlNode();
    end;

    procedure AddRootAttributes(var XmlDocNode: XmlNode; NpXmlTemplate: Record "NPR NpXml Template")
    var
        Element: XmlElement;
    begin
        if not NpXmlTemplate."Root Element Attr. Enabled" then
            exit;

        Element := XmlDocNode.AsXmlElement();
        if (NpXmlTemplate."Root Element Attr. 1 Name" <> '') and (NpXmlTemplate."Root Element Attr. 1 Name" <> 'xmlns') then
            Element.SetAttribute(NpXmlTemplate."Root Element Attr. 1 Name", NpXmlTemplate."Root Element Attr. 1 Value");

        if (NpXmlTemplate."Root Element Attr. 2 Name" <> '') and (NpXmlTemplate."Root Element Attr. 2 Name" <> 'xmlns') then
            Element.SetAttribute(NpXmlTemplate."Root Element Attr. 2 Name", NpXmlTemplate."Root Element Attr. 2 Value");

        XmlDocNode := Element.AsXmlNode();
    end;

    procedure IsLeafNode(Node: XmlNode): Boolean
    var
        ChildNodesList: XmlNodeList;
        ChildNode: XmlNode;
    begin
        if not Node.AsXmlElement().HasElements then
            exit(true);

        ChildNodesList := Node.AsXmlElement().GetChildElements();
        foreach ChildNode in ChildNodesList do
            if ChildNode.AsXmlElement().Name <> '#text' then
                exit(false);

        exit(true);
    end;

    procedure GetXmlText(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text
    var
        Node: XmlNode;
    begin

        if (not Element.SelectSingleNode(NodePath, Node)) then begin
            if (Required) then
                Error(Error003, NodePath, '');
            exit('');
        end;

        if (MaxLength > 0) then
            exit(CopyStr(Node.AsXmlElement().InnerText(), 1, MaxLength));

        exit(Node.AsXmlElement().InnerText());
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

        if not Element.SelectSingleNode(NodePath, XmlNsManager, Node) then begin
            if Required then
                Error(Error003, NodePath, Element.Name);
            exit('');
        end;

        Element2 := Node.AsXmlElement();

        if MaxLength > 0 then
            exit(CopyStr(Element2.InnerText, 1, MaxLength));

        exit(Element2.InnerText);
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
                ClearLastError();
                exit(false);
            end;
            Error(Text000, Element.Name + '/' + Path);
        end;

        Element2 := Node.AsXmlElement();
        exit(true);
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

            Error(Text001, Element2.InnerText, Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
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

            Error(Text002, Element2.InnerText, Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
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

            Error(Text003, Element2.InnerText, Element.Name + '/' + Path);
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

            Error(Text004, Element2.InnerText, Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
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

            Error(Text005, Element2.InnerText, Element.Name + '/' + Path);
        end;

        exit(ReturnValue);
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

            Error(Text006, Element2.InnerText, Element.Name + '/' + Path);
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
            Error(Text007, TextValue, FullPath);
        end;

        exit(ReturnValue);
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
            Error(Text005, TextValue, FullPath);
        end;

        exit(ReturnValue);
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
