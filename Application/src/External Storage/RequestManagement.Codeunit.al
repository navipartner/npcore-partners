codeunit 6184863 "NPR Request Management"
{
    var
        WrongPathErr: Label 'Could not resolve web request, please make sure the format of the request is correct (look for missing ''/'' charracters in the request URL)';
        JSONValueDefErr: Label 'This a programming error: JSON value type not yet defined';
        NullInputlXMLErr: Label 'Imput XML document must not be null';
        NoElementsErr: Label 'InputXML has 0 elements';

    procedure HMACCryptography(var StringToSign: Text; HashKey: Text; HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512)
    var
        CryptographyMgt: Codeunit "Cryptography Management";
    begin
        StringToSign := CryptographyMgt.GenerateHashAsBase64String(StringToSign, HashKey, HMAC);
    end;

    [Obsolete('Use native Business Central objects instead of dotnet.')]
    procedure HandleHttpRequest(HttpWebRequest: DotNet NPRNetHttpWebRequest; var Response: Text; Silent: Boolean): Boolean
    var
        MockRequest: Codeunit "NPR Mock Request";
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        MemoryStream: DotNet NPRNetStream;
        ByteArray: DotNet NPRNetArray;
        Convert: DotNet NPRNetConvert;
        BinaryReader: DotNet NPRNetBinaryReader;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        ClearLastError;

        if MockRequest.GetResponse() > '' then begin
            Response := MockRequest.GetResponse();
            MockRequest.SetResponse('');

            exit(true);
        end;

        if TrySendHttpRequest(HttpWebRequest, HttpWebResponse) then begin
            if HttpWebResponse.GetResponseHeader('Content-Length') > '' then begin
                //MemoryStream is cast to ConnectStream at runtime, most of its properties and methods will not be available
                MemoryStream := HttpWebResponse.GetResponseStream();
                BinaryReader := BinaryReader.BinaryReader(MemoryStream);
                ByteArray := BinaryReader.ReadBytes(Convert.ToInt32(HttpWebResponse.GetResponseHeader('Content-Length')));
                MemoryStream.FlushAsync();

                Response := Convert.ToBase64String(ByteArray);
            end else begin
                StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream());

                Response := StreamReader.ReadToEnd();

                StreamReader.Dispose();
            end;

            exit(true);
        end;

        if not Silent then
            Error(GetLastErrorText);
    end;

    procedure HandleFTPRequest(FTPWebRequest: DotNet NPRNetFtpWebRequest; var Response: Text; Silent: Boolean): Boolean
    var
        MockRequest: Codeunit "NPR Mock Request";
        FTPWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        ByteArray: DotNet NPRNetArray;
        BinaryReader: DotNet NPRNetBinaryReader;
        Convert: DotNet NPRNetConvert;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        ClearLastError;

        if MockRequest.GetResponse() > '' then begin
            Response := MockRequest.GetResponse();
            MockRequest.SetResponse('');

            exit(true);
        end;

        if TrySendFTPRequest(FTPWebRequest, FTPWebResponse) then begin
            if FTPWebRequest.Method = 'RETR' then begin
                MemoryStream := FTPWebResponse.GetResponseStream();
                BinaryReader := BinaryReader.BinaryReader(MemoryStream);

                while MemoryStream.CanRead do begin
                    ByteArray := BinaryReader.ReadBytes(1048576);

                    Response += Convert.ToBase64String(ByteArray);
                end;

                MemoryStream.FlushAsync();
            end else begin
                StreamReader := StreamReader.StreamReader(FTPWebResponse.GetResponseStream());

                Response := StreamReader.ReadToEnd();

                StreamReader.Dispose();
            end;

            exit(true);
        end;

        if not Silent then
            Error(GetLastErrorText);
    end;

    procedure CreateFTPRequest(var FTPWebRequest: DotNet NPRNetFtpWebRequest; FTPHost: Text; FTPCode: Code[10]; Command: Code[10]; Secure: Boolean)
    var
        FTPSetup: Record "NPR FTP Setup";
        NetworkCredentials: DotNet NPRNetNetworkCredential;
    begin
        FTPSetup.Get(FTPCode);

        FTPWebRequest := FTPWebRequest.Create(FTPHost);
        FTPWebRequest.Timeout := FTPSetup.Timeout;
        FTPWebRequest.EnableSsl := Secure;
        FTPWebRequest.Credentials(NetworkCredentials.NetworkCredential(FTPSetup.User, FTPSetup.GetPassword()));
        FTPWebRequest.Method(Command);
        FTPWebRequest.UseBinary := true;
        FTPWebRequest.UsePassive := true;
        FTPWebRequest.KeepAlive := false;
    end;

    [TryFunction]
    [Obsolete('Use native Business Central objects instead of dotnet.')]
    procedure TrySendHttpRequest(var HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse)
    begin
        HttpWebResponse := HttpWebRequest.GetResponse();
    end;

    [TryFunction]
    procedure TrySendFTPRequest(var FTPWebRequest: DotNet NPRNetFtpWebRequest; var FTPWebResponse: DotNet NPRNetFtpWebResponse)
    begin
        FTPWebResponse := FTPWebRequest.GetResponse();
    end;

    procedure BlobLenght(var TempBlob: Codeunit "Temp Blob") Lenght: BigInteger
    var
        Bytes: Integer;
        InStr: InStream;
        Red: Text;
    begin
        TempBlob.CreateInStream(InStr);

        repeat
            Bytes := InStr.Read(Red);
            Lenght += Bytes;
        until Bytes = 0;
    end;

    [Obsolete('Use native Business Central objects instead of dotnet.')]
    procedure StreamToHttpRequest(var HttpWebRequest: DotNet NPRNetHttpWebRequest; var TempBlob: Codeunit "Temp Blob"; ContentLenght: BigInteger)
    var
        InStr: InStream;
        Stream: DotNet NPRNetStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        HashBytes: DotNet NPRNetArray;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        TempBlob.CreateInStream(InStr);
        CopyStream(MemoryStream, InStr);

        HashBytes := MemoryStream.ToArray();
        MemoryStream.Close();

        Stream := HttpWebRequest.GetRequestStream();
        Stream.Write(HashBytes, 0, ContentLenght);
        Stream.Close();
    end;

    procedure StreamToFTPRequest(var FTPWebRequest: DotNet NPRNetFtpWebRequest; var TempBlob: Codeunit "Temp Blob"; ContentLenght: BigInteger)
    var
        InStr: InStream;
        Stream: DotNet NPRNetStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        HashBytes: DotNet NPRNetArray;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        TempBlob.CreateInStream(InStr);
        CopyStream(MemoryStream, InStr);

        HashBytes := MemoryStream.ToArray();
        MemoryStream.Close();

        Stream := FTPWebRequest.GetRequestStream();
        Stream.Write(HashBytes, 0, ContentLenght);
        Stream.Close();
    end;

    procedure UTCDateTimeNowText(Format: Text): Text
    var
        DateTime: DotNet NPRNetDateTime;
        CultureInfo: DotNet NPRNetCultureInfo;
        DateTimeOffset: DotNet NPRNetDateTimeOffset;
    begin
        DateTime := DateTime.UtcNow;
        CultureInfo := CultureInfo.InvariantCulture;

        DateTimeOffset := DateTimeOffset.DateTimeOffset(DateTime);
        DateTimeOffset := DateTimeOffset.ToLocalTime;

        exit(DateTimeOffset.ToString(Format, CultureInfo));
    end;

    [Obsolete('This method is for compatibility only. Please use standard JsonObject instead.')]
    procedure JsonAdd(var Json: Text; Property: Text; Value: Variant; JString: Boolean)
    var
        JObject: JsonObject;
    begin
        if Json > '' then begin
            JObject.ReadFrom(Json);
        end;

        JObject.Add(Property, FORMAT(Value));
        JObject.WriteTo(Json);
    end;

    procedure GetJsonValueByPropertyNameSingleNode(JsonText: Text; PropertyName: Text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(JsonText);
        if JObject.Get(PropertyName, JToken) then
            if JToken.IsValue then
                exit(JToken.AsValue().AsText())
            else
                exit('')
        else
            exit('');
    end;

    [Obsolete('Use native Business Central objects')]
    procedure GetXMLFromJsonArray(JsonText: Text; var XMLList: DotNet "NPRNetXmlDocument"; ArrayPropertyName: Text; ExtractFromProperty: Text; CheckProperty: Text; CheckPropertyValue: Text): Boolean
    var
        XMLElement: DotNet NPRNetXmlElement;
        XMLRoot: DotNet NPRNetXmlNode;
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        JSONTextReader: DotNet NPRNetJsonTextReader;
        StringReader: DotNet NPRNetStringReader;
        TextReader: DotNet NPRNetTextReader;
        Jarray: DotNet NPRNetJArray;
        Uri: DotNet NPRNetUri;
    begin
        XMLList := XMLList.XmlDocument();
        XMLRoot := XMLList.CreateElement('root');
        XMLList.AppendChild(XMLRoot);

        TextReader := StringReader.StringReader(JsonText);
        JSONTextReader := JSONTextReader.JsonTextReader(TextReader);

        JObject := JToken.ReadFrom(JSONTextReader);

        Jarray := JObject.SelectToken(ArrayPropertyName);

        foreach JToken in Jarray do
            if (CheckProperty = '') or
              (GetJsonValueByPropertyNameSingleNode(JToken.ToString(), CheckProperty) = CheckPropertyValue)
            then begin
                XMLElement := XMLList.CreateElement(Format(DelChr(CreateGuid, '=', '{-}')));
                XMLElement.InnerText := Uri.UnescapeDataString(JToken.SelectToken(ExtractFromProperty).ToString());
                XMLRoot.AppendChild(XMLElement);
            end;

        exit(XMLRoot.ChildNodes.Count() > 0);
    end;

    procedure GetXMLFromJsonArray(JsonText: Text; var XMLList: XmlDocument; ArrayPropertyName: Text;
        ExtractFromProperty: Text; CheckProperty: Text; CheckPropertyValue: Text): Boolean
    var
        XmlElem: XmlElement;
        XMLRoot: XmlElement;
        JObject: JsonObject;
        JToken: JsonToken;
        JToken1: JsonToken;
        SelectedToken: JsonToken;
        Jarray: JsonArray;
        ElementName: Text;
        ElementValue: Text;
        JValue: JsonValue;
    begin
        XmlDocument.ReadFrom('<root />', XMLList);
        XMLList.GetRoot(XMLRoot);

        JObject.ReadFrom(JsonText);
        JObject.SelectToken(ArrayPropertyName, JToken);
        Jarray := JToken.AsArray();

        foreach JToken in Jarray do begin
            Clear(JValue);
            if JToken.AsObject().Contains(CheckProperty) then begin
                JToken.AsObject().Get(CheckProperty, JToken1);
                JValue := JToken1.AsValue();
            end;
            if (CheckProperty = '') or
              (JValue.AsText() = CheckPropertyValue)
            then begin
                ElementName := Format(DelChr(CreateGuid, '=', '{-}'));
                JToken.SelectToken(ExtractFromProperty, SelectedToken);
                ElementValue := ConvertStr(SelectedToken.AsValue().AsText(), '+', '');
                XmlElem := XmlElement.Create(ElementName, '', ElementValue);
                XMLRoot.Add(XmlElem);
            end;
        end;

        exit(XMLRoot.HasElements());
    end;

    [TryFunction]
    procedure TryGetMIMEType(FileName: Text; var MIMEType: Text)
    var
        FileMgt: Codeunit "File Management";
    begin
        MIMEType := FileMgt.GetFileNameMimeType(FileName);
    end;

    procedure ReplaceSubstringAnyLength(Original: Text; var New: Text; FromStr: Text; ToStr: Text)
    var
        Position: Integer;
        SubStr: Text;
    begin
        Position := StrPos(Original, FromStr);

        if Position = 0 then begin
            New += Original;

            exit;
        end;

        SubStr := CopyStr(Original, Position + StrLen(FromStr));

        New += CopyStr(Original, 1, Position - 1) + ToStr;

        ReplaceSubstringAnyLength(SubStr, New, FromStr, ToStr);
    end;

    [Obsolete('Use native Business Central objects')]
    procedure HandleURLWebException()
    var
        Exception: DotNet NPRNetException;
        WebException: DotNet NPRNetWebException;
        WebExceptionStatus: DotNet NPRNetWebExceptionStatus;
    begin
        if IsNull(GetLastErrorObject) then
            exit;

        Exception := GetLastErrorObject;

        WebException := WebException.WebException();
        if not Exception.InnerException.GetType.Equals(WebException.GetType()) then
            Error(Exception.Message());

        WebException := Exception.InnerException();

        //can't compare .Net variables directly
        if WebException.Status().ToString() = WebExceptionStatus.NameResolutionFailure.ToString() then
            Error(WrongPathErr);

        Error(WebException.Message());
    end;

    procedure FindLastOccuranceInString(String: Text; Char: Char) Position: Integer
    var
        i: Integer;
    begin
        for i := 1 to StrLen(String) do
            if CopyStr(String, i, 1) = Format(Char) then
                Position := i;
    end;

    [TryFunction]
    [Obsolete('Use native Business Central objects')]
    procedure GetNodesFromXmlText(XMLText: Text; XPath: Text; var XMLNodeList: DotNet NPRNetXmlNodeList)
    var
        XMLDocument: DotNet "NPRNetXmlDocument";
    begin
        XMLDocument := XMLDocument.XmlDocument();
        XMLDocument.LoadXml(XMLText);
        XMLNodeList := XMLDocument.SelectNodes(XPath);
    end;

    procedure GetNodesFromXmlText(XMLText: Text; XPath: Text; var XMLNodeList: XmlNodeList): Boolean
    var
        XmlDoc: XmlDocument;
    begin
        XmlDocument.ReadFrom(XMLText, XmlDoc);
        if not XmlDoc.SelectNodes(XPath, XMLNodeList) then
            exit(true)
        else
            exit(false);
    end;

    [Obsolete('Use native Business Central objects')]
    procedure AppendXML(InputXML: DotNet "NPRNetXmlDocument"; ParentNodeName: Text; var OutputXML: DotNet "NPRNetXmlDocument")
    var
        XMLNode: DotNet NPRNetXmlNode;
        XMLRoot: DotNet NPRNetXmlNode;
    begin
        case true of
            IsNull(InputXML):
                Error(NullInputlXMLErr);
            InputXML.ChildNodes.Count() = 0:
                Error(NoElementsErr);
            IsNull(OutputXML):
                begin
                    if ParentNodeName = '' then
                        ParentNodeName := 'root';

                    OutputXML := OutputXML.XmlDocument();
                    XMLRoot := OutputXML.CreateElement(ParentNodeName);
                    OutputXML.AppendChild(XMLRoot);
                end;
        end;

        if ParentNodeName = '' then
            XMLRoot := OutputXML.DocumentElement
        else
            XMLRoot := OutputXML.SelectSingleNode(ParentNodeName);

        foreach XMLNode in InputXML.FirstChild.ChildNodes do
            XMLRoot.AppendChild(XMLRoot.OwnerDocument.ImportNode(XMLNode, true));
    end;

    procedure AppendXML(InputXML: XmlDocument; ParentNodeName: Text; var OutputXML: XmlDocument)
    var
        Node: XmlNode;
        XmlRoot: XmlElement;
        XmlRootNode: XmlNode;
        InputXmlRoot: XmlElement;
    begin
        case true of
            not InputXML.GetRoot(InputXmlRoot):
                Error(NullInputlXMLErr);
            not OutputXML.GetRoot(XmlRoot):
                begin
                    if ParentNodeName = '' then
                        ParentNodeName := 'root';
                    XmlDocument.ReadFrom(StrSubstNo('<%1 />', ParentNodeName), OutputXML);
                end;
        end;

        if ParentNodeName = '' then
            OutputXML.GetRoot(XmlRoot)
        else begin
            OutputXML.AsXmlNode().AsXmlElement().SelectSingleNode(ParentNodeName, XmlRootNode);
            XmlRoot := XmlRootNode.AsXmlElement();
        end;

        InputXml.GetRoot(InputXmlRoot);
        foreach Node in InputXmlRoot.GetChildElements() do begin
            XmlRoot.Add(Node.AsXmlElement());
        end;
    end;

    procedure AddOrReplaceRequestHeader(var WebRequest: HttpRequestMessage; HeaderName: Text; HeaderValue: Text);
    var
        Headers: HttpHeaders;
    begin
        WebRequest.GetHeaders(Headers);
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;

    procedure AddOrReplaceContentHeader(var WebRequest: HttpRequestMessage; HeaderName: Text; HeaderValue: Text);
    var
        Headers: HttpHeaders;
    begin
        WebRequest.Content.GetHeaders(Headers);
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;

    procedure RemoveRequestHeader(var WebRequest: HttpRequestMessage; HeaderName: Text);
    var
        Headers: HttpHeaders;
    begin
        WebRequest.GetHeaders(Headers);
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);
    end;

    procedure RemoveContentHeader(var WebRequest: HttpRequestMessage; HeaderName: Text);
    var
        Headers: HttpHeaders;
    begin
        WebRequest.Content.GetHeaders(Headers);
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);
    end;
}
