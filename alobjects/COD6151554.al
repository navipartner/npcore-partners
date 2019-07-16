codeunit 6151554 "NpXml Dom Mgt."
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


    trigger OnRun()
    begin
    end;

    var
        NpXmlTemplate2: Record "NpXml Template";
        OutputTempBlob: Record TempBlob temporary;
        ResponseTempBlob: Record TempBlob temporary;
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

    procedure AddAttribute(var XmlNode: DotNet npNetXmlNode;Name: Text[260];NodeValue: Text[260]) ExitStatus: Integer
    var
        NewAttributeXmlNode: DotNet npNetXmlNode;
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

    procedure AddAttributeNamespace(var XmlNode: DotNet npNetXmlNode;Name: Text[260];Namespace: Text;NodeValue: Text[260]) ExitStatus: Integer
    var
        NewAttributeXmlNode: DotNet npNetXmlNode;
    begin
        //-NC2.03 [267094]
        NewAttributeXmlNode := XmlNode.OwnerDocument.CreateAttribute(Name,Namespace);
        if IsNull(NewAttributeXmlNode) then begin
          ExitStatus := 60;
          exit(ExitStatus)
        end;

        if NodeValue <> '' then
          NewAttributeXmlNode.InnerText := NodeValue;

        XmlNode.Attributes.SetNamedItem(NewAttributeXmlNode);
        //+NC2.03 [267094]
    end;

    procedure AddElement(var XmlElement: DotNet npNetXmlElement;ElementName: Text[250];var CreatedXmlElement: DotNet npNetXmlElement)
    var
        NewChildXmlElement: DotNet npNetXmlElement;
        XmlNodeType: DotNet npNetXmlNodeType;
    begin
        NewChildXmlElement := XmlElement.OwnerDocument.CreateNode(XmlNodeType.Element,ElementName,'');
        XmlElement.AppendChild(NewChildXmlElement);
        CreatedXmlElement := NewChildXmlElement;
    end;

    procedure AddElementNamespace(var XmlElement: DotNet npNetXmlElement;ElementName: Text;Namespace: Text;var CreatedXmlElement: DotNet npNetXmlElement)
    var
        NewChildXmlElement: DotNet npNetXmlElement;
        XmlNodeType: DotNet npNetXmlNodeType;
    begin
        if Namespace = '' then
          Namespace := XmlElement.OwnerDocument.NamespaceURI();
        NewChildXmlElement := XmlElement.OwnerDocument.CreateNode(XmlNodeType.Element,ElementName,Namespace);
        XmlElement.AppendChild(NewChildXmlElement);
        CreatedXmlElement := NewChildXmlElement;
    end;

    procedure FindNode(XmlNode: DotNet npNetXmlNode;NodePath: Text[250];var XmlNodeChild: DotNet npNetXmlNode): Boolean
    begin
        if IsNull(XmlNode) then
          exit(false);

        XmlNodeChild := XmlNode.SelectSingleNode(NodePath);

        exit(not IsNull(XmlNodeChild));
    end;

    procedure FindNodes(XmlNode: DotNet npNetXmlNode;NodePath: Text[250];var XmlNodeList: DotNet npNetXmlNodeList): Boolean
    begin
        XmlNodeList := XmlNode.SelectNodes('//' + NodePath);

        exit(not IsNull(XmlNodeList));
    end;

    procedure InitDoc(var XmlDoc: DotNet npNetXmlDocument;var XmlDocNode: DotNet npNetXmlNode;NodeName: Text[1024])
    begin
        if not IsNull(XmlDoc) then
          Clear(XmlDoc);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<' + NodeName + ' />');

        XmlDocNode := XmlDoc.DocumentElement();
    end;

    procedure IsLeafNode(XmlNode: DotNet npNetXmlNode): Boolean
    var
        XmlNode2: DotNet npNetXmlNode;
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

    procedure GetXmlText(XmlElement: DotNet npNetXmlElement;NodePath: Text;MaxLength: Integer;Required: Boolean): Text
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        if IsNull(XmlElement) then begin
          if Required then
            Error(Error003,NodePath,'');
          exit('');
        end;

        XmlElement2 := XmlElement.SelectSingleNode(NodePath);
        if IsNull(XmlElement2) then begin
          if Required then
            Error(Error003,NodePath,XmlElement.Name);
          exit('');
        end;

        if MaxLength > 0 then
          exit(CopyStr(XmlElement2.InnerText,1,MaxLength));

        exit(XmlElement2.InnerText);
    end;

    procedure GetXmlTextNamespace(XmlElement: DotNet npNetXmlElement;NodePath: Text;XmlNsManager: DotNet npNetXmlNamespaceManager;MaxLength: Integer;Required: Boolean): Text
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        if IsNull(XmlElement) then begin
          if Required then
            Error(Error003,NodePath,'');
          exit('');
        end;

        XmlElement2 := XmlElement.SelectSingleNode(NodePath,XmlNsManager);
        if IsNull(XmlElement2) then begin
          if Required then
            Error(Error003,NodePath,XmlElement.Name);
          exit('');
        end;

        if MaxLength > 0 then
          exit(CopyStr(XmlElement2.InnerText,1,MaxLength));

        exit(XmlElement2.InnerText);
    end;

    procedure GetXmlAttributeText(XmlElement: DotNet npNetXmlElement;AttributeName: Text;Required: Boolean) AttributeText: Text
    begin
        AttributeText := XmlElement.GetAttribute(AttributeName);
        if Required and (AttributeText = '') then
          Error(Error004,AttributeName,XmlElement.Name);
    end;

    procedure LoadXml(var MemoryStream: DotNet npNetMemoryStream;var XmlDoc: DotNet npNetXmlDocument) XmlLoaded: Boolean
    begin
        //-NC2.01 [256392]
        // ASSERTERROR BEGIN
        //  XmlDoc := XmlDoc.XmlDocument;
        //  XmlDoc.Load(MemoryStream);
        //
        //  ERROR('');
        // END;
        XmlLoaded := TryLoadXmlStream(MemoryStream,XmlDoc);
        //+NC2.01 [256392]
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        //-NC2.01 [256392]
        // EXIT(GETLASTERRORTEXT = '');
        //  EXIT(TRUE);
        exit(XmlLoaded);
        //+NC2.01 [256392]
    end;

    [TryFunction]
    procedure TryLoadXml(XmlString: Text;var XmlDoc: DotNet npNetXmlDocument)
    begin
        //-NC2.01
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlString);
        //+NC2.01
    end;

    [TryFunction]
    local procedure TryLoadXmlStream(var MemoryStream: DotNet npNetMemoryStream;var XmlDoc: DotNet npNetXmlDocument)
    begin
        //-NC2.01 [256392]
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream);
        //+NC2.01 [256392]
    end;

    procedure PrettyPrintXml(XmlString: Text) PrettyXml: Text
    var
        StreamReader: DotNet npNetStreamReader;
        XmlDoc: DotNet npNetXmlDocument;
        TempBlob: Record TempBlob temporary;
        InStream: InStream;
        OutStream: OutStream;
    begin
        //-NC2.01
        if not TryLoadXml(XmlString,XmlDoc) then
          exit(XmlString);

        TempBlob.Blob.CreateOutStream(OutStream,TEXTENCODING::UTF8);
        XmlDoc.Save(OutStream);

        TempBlob.Blob.CreateInStream(InStream,TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(InStream);
        PrettyXml := StreamReader.ReadToEnd;
        //+NC2.01
    end;

    [TryFunction]
    procedure RemoveNameSpaces(var XmlDoc: DotNet npNetXmlDocument)
    var
        MemoryStream: DotNet npNetMemoryStream;
        MemoryStream2: DotNet npNetMemoryStream;
        XmlStyleSheet: DotNet npNetXmlDocument;
        XslCompiledTransform: DotNet npNetXslCompiledTransform;
        XmlReader: DotNet npNetXmlReader;
        XmlWriter: DotNet npNetXmlWriter;
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
        XslCompiledTransform.Transform(XmlReader,XmlWriter);
        MemoryStream2.Position := 0;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream2);
    end;

    local procedure "--- Get"()
    begin
    end;

    procedure FindElement(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean;var XmlElement2: DotNet npNetXmlElement): Boolean
    begin
        //-NC2.19 [345261]
        if IsNull(XmlElement) then begin
          if not Required then
            exit(false);

          Error(Text000,XmlElement.Name + '/' + Path);
        end;

        XmlElement2 := XmlElement.SelectSingleNode(Path);
        if IsNull(XmlElement2) and Required then
          Error(Text000,XmlElement.Name + '/' + Path);

        exit(not IsNull(XmlElement2));
        //+NC2.19 [345261]
    end;

    procedure GetElementBigInt(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: BigInteger
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(0);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementBoolean(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: Boolean
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(false);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(false);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementCode(XmlElement: DotNet npNetXmlElement;Path: Text;MaxLength: Integer;Required: Boolean) Value: Code[1024]
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit('');
        end;

        TextValue := XmlElement2.InnerText;
        if MaxLength > 0 then
          TextValue := CopyStr(TextValue,1,MaxLength);

        Value := UpperCase(CopyStr(TextValue,1,MaxStrLen(Value)));

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementDate(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: Date
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0D);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(0D);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementDec(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: Decimal
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(0);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementDT(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: DateTime
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0DT);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(0DT);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementGuid(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: Guid
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit;
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit;

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementInt(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: Integer
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(0);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementText(XmlElement: DotNet npNetXmlElement;Path: Text;MaxLength: Integer;Required: Boolean) Value: Text
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit('');
        end;

        Value := XmlElement2.InnerText;
        if MaxLength > 0 then
          Value := CopyStr(Value,1,MaxLength);

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementTime(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: Time
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0T);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(0T);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetElementDuration(XmlElement: DotNet npNetXmlElement;Path: Text;Required: Boolean) Value: Duration
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.21 [344264]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        if not Evaluate(Value,XmlElement2.InnerText,9) then begin
          if not Required then
            exit(0);

          Error(Text001,XmlElement2.InnerText,GetDotNetType(Value),XmlElement.Name + '/' + Path);
        end;

        exit(Value);
        //+NC2.21 [344264]
    end;

    procedure GetAttributeBigInt(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: BigInteger
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(0);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeBoolean(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: Boolean
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(false);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(false);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeCode(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;MaxLength: Integer;Required: Boolean) Value: Code[1024]
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit('');
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if MaxLength > 0 then
          TextValue := CopyStr(TextValue,1,MaxLength);

        Value := UpperCase(CopyStr(TextValue,1,MaxStrLen(Value)));

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeDate(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: Date
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0D);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(0D);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeDec(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: Decimal
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(0);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeDT(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: DateTime
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0DT);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(0DT);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeGuid(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: Guid
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit;
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit;

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeInt(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: Integer
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(0);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeText(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;MaxLength: Integer;Required: Boolean) Value: Text
    var
        XmlElement2: DotNet npNetXmlElement;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit('');
        end;

        Value := XmlElement2.GetAttribute(Name);
        if MaxLength > 0 then
          Value := CopyStr(Value,1,MaxLength);

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeTime(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: Time
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.19 [345261]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0T);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(0T);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.19 [345261]
    end;

    procedure GetAttributeDuration(XmlElement: DotNet npNetXmlElement;Path: Text;Name: Text;Required: Boolean) Value: Duration
    var
        XmlElement2: DotNet npNetXmlElement;
        TextValue: Text;
        FullPath: Text;
    begin
        //-NC2.21 [344264]
        XmlElement2 := XmlElement;
        if Path <> '' then begin
          if (not FindElement(XmlElement,Path,Required,XmlElement2)) then
            exit(0);
        end;

        TextValue := XmlElement2.GetAttribute(Name);
        if not Evaluate(Value,TextValue,9) then begin
          if not Required then
            exit(0);

          FullPath := XmlElement.Name;
          if Path <> '' then
            FullPath += '/' + Path;
          FullPath += '@' + Name;
          Error(Text001,TextValue,GetDotNetType(Value),FullPath);
        end;

        exit(Value);
        //+NC2.21 [344264]
    end;

    local procedure "--- Dotnet"()
    begin
        //-NC2.19 [342218]
        //+NC2.19 [342218]
    end;

    procedure GetDotNetTime(Provider: Text): Text
    var
        DotNetDateTime: DotNet npNetDateTime;
    begin
        //-NC2.19 [342218]
        DotNetDateTime := DotNetDateTime.Now();
        exit(DotNetDateTime.ToString(Provider));
        //+NC2.19 [342218]
    end;

    procedure ComputeSha256Hash("Key": Text;Value: Text;EncodingName: Text) Hash: Text
    var
        BitConverter: DotNet npNetBitConverter;
        Encoding: DotNet npNetEncoding;
        HmacSha256: DotNet npNetHMACSHA256;
    begin
        //-NC2.19 [342218]
        Encoding := Encoding.GetEncoding(EncodingName);
        HmacSha256 := HmacSha256.HMACSHA256(Encoding.GetBytes(Key));
        Hash := BitConverter.ToString(HmacSha256.ComputeHash(Encoding.GetBytes(Value)));
        exit(Hash);
        //+NC2.19 [342218]
    end;

    procedure ToBase64String(Input: Text;EncodingName: Text): Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        //-NC2.19 [342218]
        Encoding := Encoding.GetEncoding(EncodingName);
        exit(Convert.ToBase64String(Encoding.GetBytes(Input)));
        //+NC2.19 [342218]
    end;

    procedure "--- WebRequest"()
    begin
    end;

    procedure GetWebExceptionMessage(var WebException: DotNet npNetWebException) ExceptionMessage: Text
    var
        HttpWebResponse: DotNet npNetHttpWebResponse;
        InnerWebException: DotNet npNetWebException;
        LastErrorText: Text;
    begin
        //-NC2.19 [345261]
        // IF TryGetWebExceptionResponse(WebException,HttpWebResponse) THEN BEGIN
        //  ExceptionMessage := GetWebResponseText(HttpWebResponse);
        //  EXIT(ExceptionMessage);
        // END;
        // EXIT('');
        LastErrorText := GetLastErrorText;
        if IsNull(WebException) then
          exit(LastErrorText);

        if TryGetInnerWebException(WebException,InnerWebException) then begin
          if TryGetWebExceptionResponse(InnerWebException,HttpWebResponse) then begin
            ExceptionMessage := GetWebResponseText(HttpWebResponse);
            if ExceptionMessage <> '' then
              exit(ExceptionMessage);
          end;

          if not IsNull(InnerWebException) then begin
            if InnerWebException.Message <> '' then
              exit(InnerWebException.Message);
          end;
        end;

        if TryGetWebExceptionResponse(WebException,HttpWebResponse) then begin
          ExceptionMessage := GetWebResponseText(HttpWebResponse);
          if ExceptionMessage <> '' then
            exit(ExceptionMessage);
        end;

        if WebException.Message <> '' then
          exit(WebException.Message);

        exit(LastErrorText);
        //+NC2.19 [345261]
    end;

    procedure GetWebExceptionInnerMessage(var WebException: DotNet npNetWebException) ExceptionMessage: Text
    var
        InnerWebException: DotNet npNetWebException;
    begin
        //-NC2.01 [256392]
        // ASSERTERROR BEGIN
        //  InnerWebException := WebException.InnerException;
        //  ERROR('');
        // END;
        //
        // IF GETLASTERRORTEXT = '' THEN BEGIN
        //  ExceptionMessage := GetWebExceptionMessage(InnerWebException);
        //  EXIT(ExceptionMessage);
        // END;
        if TryGetInnerWebException(WebException,InnerWebException) then begin
          ExceptionMessage := GetWebExceptionMessage(InnerWebException);
          exit(ExceptionMessage);
        end;
        //+NC2.01 [256392]

        exit('');
    end;

    procedure GetWebResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse) ResponseText: Text
    var
        HttpWebException: DotNet npNetWebException;
        BinaryReader: DotNet npNetBinaryReader;
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        APIUsername: Text;
        ElementName: Text;
        Response: Text;
    begin
        //-NC2.01 [256392]
        // ASSERTERROR BEGIN
        //  Stream := HttpWebResponse.GetResponseStream;
        //  StreamReader := StreamReader.StreamReader(Stream);
        //  ResponseText := StreamReader.ReadToEnd;
        //  Stream.Flush;
        //  Stream.Close;
        //  CLEAR(Stream);
        //
        //  ERROR('');
        // END;
        //
        // IF GETLASTERRORTEXT = '' THEN
        //  EXIT(ResponseText);
        if TryReadResponseText(HttpWebResponse,ResponseText) then
          exit(ResponseText);
        //+NC2.01 [256392]

        exit('');
    end;

    procedure SendWebRequest(var XmlDoc: DotNet npNetXmlDocument;HttpWebRequest: DotNet npNetHttpWebRequest;var HttpWebResponse: DotNet npNetHttpWebResponse;var WebException: DotNet npNetWebException): Boolean
    begin
        //-NC2.01 [256392]
        // ASSERTERROR BEGIN
        //  MemoryStream := HttpWebRequest.GetRequestStream;
        //  XmlDoc.Save(MemoryStream);
        //  MemoryStream.Flush;
        //  MemoryStream.Close;
        //  CLEAR(MemoryStream);
        //  HttpWebResponse := HttpWebRequest.GetResponse;
        //
        //  ERROR('');
        // END;
        //
        // IF GETLASTERRORTEXT = '' THEN
        //  EXIT(TRUE);
        if TryGetWebResponse(XmlDoc,HttpWebRequest,HttpWebResponse) then
          exit(true);
        //+NC2.01 [256392]

        WebException := GetLastErrorObject;
        //-NC2.19 [345261]
        // IF ISNULL(WebException) THEN
        //  EXIT(FALSE);
        //+NC2.19 [345261]

        //-NC2.01 [256392]
        // ASSERTERROR BEGIN
        //  HttpWebResponse := WebException.Response;
        //  ERROR('');
        // END;
        //-NC2.19 [345261]
        // IF TryGetWebExceptionResponse(WebException,HttpWebResponse) THEN;
        //+NC2.19 [345261]
        //+NC2.01 [256392]

        exit(false);
    end;

    procedure SendWebRequestText(Request: Text;HttpWebRequest: DotNet npNetHttpWebRequest;var HttpWebResponse: DotNet npNetHttpWebResponse;var WebException: DotNet npNetWebException): Boolean
    begin
        //-NC2.05 [265609]
        if TryGetWebResponseText(Request,HttpWebRequest,HttpWebResponse) then
          exit(true);

        WebException := GetLastErrorObject;
        //-NC2.19 [345261]
        // IF ISNULL(WebException) THEN
        //  EXIT(FALSE);
        //+NC2.19 [345261]

        //-NC2.19 [345261]
        //IF TryGetWebExceptionResponse(WebException,HttpWebResponse) THEN;
        //+NC2.19 [345261]
        //+NC2.05 [265609]

        exit(false);
    end;

    procedure SetTrustedCertificateValidation(var HttpWebRequest: DotNet npNetHttpWebRequest)
    var
        NpWebRequest: DotNet npNetNpWebRequest;
    begin
        NpWebRequest := NpWebRequest.NpWebRequest;
        NpWebRequest.SetTrustedCertificateValidation(HttpWebRequest);
    end;

    [TryFunction]
    local procedure TryGetInnerWebException(var WebException: DotNet npNetWebException;var InnerWebException: DotNet npNetWebException)
    begin
        //-NC2.01 [256392]
        InnerWebException := WebException.InnerException;
        //+NC2.01 [256392]
    end;

    [TryFunction]
    local procedure TryGetWebExceptionResponse(var WebException: DotNet npNetWebException;var HttpWebResponse: DotNet npNetHttpWebResponse)
    begin
        //-NC2.01 [256392]
        HttpWebResponse := WebException.Response;
        //+NC2.01 [256392]
    end;

    [TryFunction]
    local procedure TryGetWebResponse(var XmlDoc: DotNet npNetXmlDocument;HttpWebRequest: DotNet npNetHttpWebRequest;var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        MemoryStream: DotNet npNetMemoryStream;
    begin
        //-NC2.01 [256392]
        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        HttpWebResponse := HttpWebRequest.GetResponse;
        //+NC2.01 [256392]
    end;

    [TryFunction]
    local procedure TryGetWebResponseText(var Request: Text;HttpWebRequest: DotNet npNetHttpWebRequest;var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        StreamWriter: DotNet npNetStreamWriter;
        Stream: DotNet npNetStream;
    begin
        //-NC2.05 [265609]
        //-NC2.06 [288285]
        // MemoryStream := HttpWebRequest.GetRequestStream;
        // OutStr := MemoryStream;
        // OutStr.WRITETEXT(Request);
        // MemoryStream.Flush;
        // MemoryStream.Close;
        // CLEAR(MemoryStream);
        Stream := HttpWebRequest.GetRequestStream;
        StreamWriter := StreamWriter.StreamWriter(Stream);
        StreamWriter.Write(Request);
        StreamWriter.Close;
        Stream.Close;
        //+NC2.06 [288285]
        HttpWebResponse := HttpWebRequest.GetResponse;
        //+NC2.05 [265609]
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse;var ResponseText: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
    begin
        //-NC2.01 [256392]
        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        ResponseText := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        Clear(Stream);
        //+NC2.01 [256392]
    end;
}

