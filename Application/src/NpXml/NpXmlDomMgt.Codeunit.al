codeunit 6151554 "NPR NpXml Dom Mgt."
{
    // NC1.13 /MHA /20150414  CASE 211360 Object Created - Restructured NpXml Codeunits. Independent functions moved to new codeunits
    //                                    NC8.00: WebRequest Exception is catched using ASSERTERROR and GETLASTERROROBJECT
    // NC1.16 /MHA /20150519  CASE 214257 Added Get-functions with Required parameter
    // NC1.17 /MHA /20150527  CASE 214935 Added function LoadXml() for exception handling
    // NC1.17 /MHA /20150616  CASE 215910 Added function IsLeafNode because values are treated as nodes
    // NC1.22 /TS  /20150126  CASE 232405 Removed max length on Return value in function GetxmlText()
    // NC1.22 /MHA /20160429  CASE 237658 Added function AddElementNamespace() and removed forced LOWERCASE
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.01 /MHA /20160905  CASE 242551 Added functions TryLoadXml() and PrettyPrintXml()
    // NC2.01 /MHA /20161219  CASE 256392 Replaced ASSERTERROR with Try Functions to prevent implicit roll back
    // NC2.03 /MHA /20170404  CASE 267094 Added function AddAttributeNamespace()
    // NC2.05 /MHA /20170615  CASE 265609 Added functions to enabled raw Text Web Request: SendWebRequestText(),TryGetWebResponseText()
    // NC2.06/MHA /20170901   CASE 288285 Replace Nav OutStream with DotNet StreamWriter in TryGetWebResponseText() to correct Encoding
    // NC2.13/JDH /20180604   CASE 317971 Changed caption to ENU
    // NC2.19/MHA /20190116  CASE 342218 Added functions to be used to calculate Authorization Header from Extension
    // NC2.19/MHA /20190311  CASE 345261 Removed implicit TryGetWebExceptionResponse() in SendWebRequest() and SendWebRequestText() and added Get functions
    // NC2.21/MHA /20190530  CASE 344264 Added functions Xml Get functions for duration
    // NC2.22/MHA /20190705  CASE 361164 Changed scope of GetWebExceptionInnerMessage() and TryGetWebExceptionResponse() from Global to Local
    // NC2.25/MHA /20200205  CASE 389167 KeepAlive is disabled in SendWebRequest() and SendWebRequestText()


    trigger OnRun()
    begin
    end;

    var
        NpXmlTemplate2: Record "NPR NpXml Template";
        OutputTempBlob: Codeunit "Temp Blob";
        ResponseTempBlob: Codeunit "Temp Blob";
        Error003: Label 'Xml element %1 is missing in %2';
        Error004: Label 'Xml attribute %1 is missing in %2';
        RecRef: RecordRef;
        OutputOutStr: OutStream;
        ResponseOutStr: OutStream;
        Window: Dialog;
        PrimaryKeyValue: Text;
        BatchCount: Integer;
        HideDialog: Boolean;
        Initialized: Boolean;
        OutputInitialized: Boolean;
        Text000: Label 'XmlElement %1 is missing';
        Text001: Label 'Value "%1" is not %2 in <%3>';

    procedure "--- No Namespace"()
    begin
    end;

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

    procedure AddElement(var XmlElement: DotNet NPRNetXmlElement; ElementName: Text[250]; var CreatedXmlElement: DotNet NPRNetXmlElement)
    var
        NewChildXmlElement: DotNet NPRNetXmlElement;
        XmlNodeType: DotNet NPRNetXmlNodeType;
    begin
        NewChildXmlElement := XmlElement.OwnerDocument.CreateNode(XmlNodeType.Element, ElementName, '');
        XmlElement.AppendChild(NewChildXmlElement);
        CreatedXmlElement := NewChildXmlElement;
    end;

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

    procedure InitDoc(var XmlDoc: DotNet "NPRNetXmlDocument"; var XmlDocNode: DotNet NPRNetXmlNode; NodeName: Text[1024])
    begin
        if not IsNull(XmlDoc) then
            Clear(XmlDoc);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<' + NodeName + ' />');

        XmlDocNode := XmlDoc.DocumentElement();
    end;

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
    procedure TryLoadXml(XmlString: Text; var XmlDoc: DotNet "NPRNetXmlDocument")
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlString);
    end;

    [TryFunction]
    local procedure TryLoadXmlStream(var MemoryStream: DotNet NPRNetMemoryStream; var XmlDoc: DotNet "NPRNetXmlDocument")
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream);
    end;

    procedure PrettyPrintXml(XmlString: Text) PrettyXml: Text
    var
        StreamReader: DotNet NPRNetStreamReader;
        XmlDoc: DotNet "NPRNetXmlDocument";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if not TryLoadXml(XmlString, XmlDoc) then
            exit(XmlString);

        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        XmlDoc.Save(OutStream);

        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(InStream);
        PrettyXml := StreamReader.ReadToEnd;
    end;

    [TryFunction]
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

    local procedure "--- Get"()
    begin
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

        Element.SelectSingleNode(Path, Node);
        Element2 := Node.AsXmlElement();
        if Element2.IsEmpty() and Required then
            Error(Text000, Element.Name + '/' + Path);

        exit(not Element2.IsEmpty());
    end;

    procedure GetElementBigInt(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: BigInteger
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

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]

    procedure GetElementDT(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: DateTime
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0DT);
        end;

        if not Evaluate(Value, XmlElement2.InnerText, 9) then begin
            if not Required then
                exit(0DT);

            Error(Text001, XmlElement2.InnerText, GetDotNetType(Value), XmlElement.Name + '/' + Path);
        end;

        exit(Value);
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

    procedure GetElementGuid(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: Guid
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit;
        end;

        if not Evaluate(Value, XmlElement2.InnerText, 9) then begin
            if not Required then
                exit;

            Error(Text001, XmlElement2.InnerText, GetDotNetType(Value), XmlElement.Name + '/' + Path);
        end;

        exit(Value);
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

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementTime(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: Time
    var
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0T);
        end;

        if not Evaluate(Value, XmlElement2.InnerText, 9) then begin
            if not Required then
                exit(0T);

            Error(Text001, XmlElement2.InnerText, GetDotNetType(Value), XmlElement.Name + '/' + Path);
        end;

        exit(Value);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetElementDuration(XmlElement: DotNet NPRNetXmlElement; Path: Text; Required: Boolean) Value: Duration
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

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetAttributeBigInt(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: BigInteger
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(0);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
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

    procedure GetAttributeBoolean(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: Boolean
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(false);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(false);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
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

    procedure GetAttributeDate(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: Date
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0D);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(0D);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
    end;

    procedure GetAttributeDec(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: Decimal
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(0);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
    end;

    procedure GetAttributeDT(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: DateTime
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0DT);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(0DT);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
    end;

    procedure GetAttributeGuid(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: Guid
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit;
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit;

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
    end;

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure GetAttributeInt(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: Integer
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(0);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
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

    procedure GetAttributeTime(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: Time
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0T);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(0T);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
    end;

    procedure GetAttributeDuration(XmlElement: DotNet NPRNetXmlElement; Path: Text; Name: Text; Required: Boolean) Value: Duration
    var
        XmlElement2: DotNet NPRNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        XmlElement2 := XmlElement;
        if Path <> '' then begin
            if (not FindElement(XmlElement, Path, Required, XmlElement2)) then
                exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value, TextValue, 9) then begin
            if not Required then
                exit(0);

            FullPath := XmlElement.Name;
            if Path <> '' then
                FullPath += '/' + Path;
            FullPath += '@' + Name;
            Error(Text001, TextValue, GetDotNetType(Value), FullPath);
        end;

        exit(Value);
    end;

    local procedure "--- Dotnet"()
    begin
    end;

    procedure GetDotNetTime(Provider: Text): Text
    var
        DotNetDateTime: DotNet NPRNetDateTime;
    begin
        DotNetDateTime := DotNetDateTime.Now();
        exit(DotNetDateTime.ToString(Provider));
    end;

    procedure ComputeSha256Hash("Key": Text; Value: Text; EncodingName: Text) Hash: Text
    var
        BitConverter: DotNet NPRNetBitConverter;
        Encoding: DotNet NPRNetEncoding;
        HmacSha256: DotNet NPRNetHMACSHA256;
    begin
        Encoding := Encoding.GetEncoding(EncodingName);
        HmacSha256 := HmacSha256.HMACSHA256(Encoding.GetBytes(Key));
        Hash := BitConverter.ToString(HmacSha256.ComputeHash(Encoding.GetBytes(Value)));
        exit(Hash);
    end;

    procedure ToBase64String(Input: Text; EncodingName: Text): Text
    var
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
    begin
        Encoding := Encoding.GetEncoding(EncodingName);
        exit(Convert.ToBase64String(Encoding.GetBytes(Input)));
    end;

    procedure "--- WebRequest"()
    begin
    end;

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

    local procedure GetWebExceptionInnerMessage(var WebException: DotNet NPRNetWebException) ExceptionMessage: Text
    var
        InnerWebException: DotNet NPRNetWebException;
    begin
        if TryGetInnerWebException(WebException, InnerWebException) then begin
            ExceptionMessage := GetWebExceptionMessage(InnerWebException);
            exit(ExceptionMessage);
        end;

        exit('');
    end;

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

    procedure SendWebRequest(var XmlDoc: DotNet "NPRNetXmlDocument"; HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse; var WebException: DotNet NPRNetWebException): Boolean
    begin
        //-NC2.25 [389167]
        HttpWebRequest.KeepAlive(false);
        //+NC2.25 [389167]
        if TryGetWebResponse(XmlDoc, HttpWebRequest, HttpWebResponse) then
            exit(true);

        WebException := GetLastErrorObject;
        exit(false);
    end;

    procedure SendWebRequestText(Request: Text; HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse; var WebException: DotNet NPRNetWebException): Boolean
    begin
        //-NC2.25 [389167]
        HttpWebRequest.KeepAlive(false);
        //+NC2.25 [389167]
        if TryGetWebResponseText(Request, HttpWebRequest, HttpWebResponse) then
            exit(true);

        WebException := GetLastErrorObject;

        exit(false);
    end;

    procedure SetTrustedCertificateValidation(var HttpWebRequest: DotNet NPRNetHttpWebRequest)
    var
        NpWebRequest: DotNet NPRNetNpWebRequest;
    begin
        NpWebRequest := NpWebRequest.NpWebRequest;
        NpWebRequest.SetTrustedCertificateValidation(HttpWebRequest);
    end;

    [TryFunction]
    local procedure TryGetInnerWebException(var WebException: DotNet NPRNetWebException; var InnerWebException: DotNet NPRNetWebException)
    begin
        InnerWebException := WebException.InnerException;
    end;

    [TryFunction]
    local procedure TryGetWebExceptionResponse(var WebException: DotNet NPRNetWebException; var HttpWebResponse: DotNet NPRNetHttpWebResponse)
    begin
        HttpWebResponse := WebException.Response;
    end;

    [TryFunction]
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

    local procedure GetAttributeFromElement(Element: XmlElement; AttributeName: Text; var Attribute: XmlAttribute; Required: Boolean);
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
