codeunit 6184863 "Request Management"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created


    trigger OnRun()
    begin
    end;

    var
        WrongPathErr: Label 'Could not resolve web request, please make sure the format of the request is correct (look for missing ''/'' charracters in the request URL)';
        JSONValueDefErr: Label 'This a programming error: JSON value type not yet defined';
        NullInputlXMLErr: Label 'Imput XML document must not be null';
        NoElementsErr: Label 'InputXML has 0 elements';

    procedure HMACCryptography(var StringToSign: Text; "Key": Text; HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512)
    var
        KeyedHashAlgorithm: DotNet npNetKeyedHashAlgorithm;
        Encoding: DotNet npNetEncoding;
        HashBytes: DotNet npNetArray;
        Convert: DotNet npNetConvert;
    begin
        //function obsolete in versions 14 and above
        KeyedHashAlgorithm := KeyedHashAlgorithm.Create(Format(HMAC));
        KeyedHashAlgorithm.Key(Convert.FromBase64String(Key));
        HashBytes := KeyedHashAlgorithm.ComputeHash(Encoding.UTF8.GetBytes(StringToSign));
        KeyedHashAlgorithm.Dispose();

        StringToSign := Convert.ToBase64String(HashBytes);
    end;

    procedure HandleHttpRequest(HttpWebRequest: DotNet npNetHttpWebRequest; var Response: Text; Silent: Boolean): Boolean
    var
        MockRequest: Codeunit "Mock Request";
        HttpWebResponse: DotNet npNetHttpWebResponse;
        MemoryStream: DotNet npNetStream;
        ByteArray: DotNet npNetArray;
        Convert: DotNet npNetConvert;
        BinaryReader: DotNet npNetBinaryReader;
        StreamReader: DotNet npNetStreamReader;
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

    procedure HandleFTPRequest(FTPWebRequest: DotNet npNetFtpWebRequest; var Response: Text; Silent: Boolean): Boolean
    var
        MockRequest: Codeunit "Mock Request";
        FTPWebResponse: DotNet npNetFtpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        ByteArray: DotNet npNetArray;
        BinaryReader: DotNet npNetBinaryReader;
        Convert: DotNet npNetConvert;
        StreamReader: DotNet npNetStreamReader;
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

    procedure CreateFTPRequest(var FTPWebRequest: DotNet npNetFtpWebRequest; FTPHost: Text; FTPCode: Code[10]; Command: Code[10]; Secure: Boolean)
    var
        FTPSetup: Record "FTP Setup";
        NetworkCredentials: DotNet npNetNetworkCredential;
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
    procedure TrySendHttpRequest(var HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse)
    begin
        HttpWebResponse := HttpWebRequest.GetResponse();
    end;

    [TryFunction]
    procedure TrySendFTPRequest(var FTPWebRequest: DotNet npNetFtpWebRequest; var FTPWebResponse: DotNet npNetFtpWebResponse)
    begin
        FTPWebResponse := FTPWebRequest.GetResponse();
    end;

    procedure BlobLenght(var TempBlob: Record TempBlob) Lenght: BigInteger
    var
        Bytes: Integer;
        InStr: InStream;
        Red: Text;
    begin
        TempBlob.Blob.CreateInStream(InStr);

        repeat
            Bytes := InStr.Read(Red);
            Lenght += Bytes;
        until Bytes = 0;
    end;

    procedure StreamToHttpRequest(var HttpWebRequest: DotNet npNetHttpWebRequest; var TempBlob: Record TempBlob; ContentLenght: BigInteger)
    var
        InStr: InStream;
        Stream: DotNet npNetStream;
        MemoryStream: DotNet npNetMemoryStream;
        HashBytes: DotNet npNetArray;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        TempBlob.Blob.CreateInStream(InStr);
        CopyStream(MemoryStream, InStr);

        HashBytes := MemoryStream.ToArray();
        MemoryStream.Close();

        Stream := HttpWebRequest.GetRequestStream();
        Stream.Write(HashBytes, 0, ContentLenght);
        Stream.Close();
    end;

    procedure StreamToFTPRequest(var FTPWebRequest: DotNet npNetFtpWebRequest; var TempBlob: Record TempBlob; ContentLenght: BigInteger)
    var
        InStr: InStream;
        Stream: DotNet npNetStream;
        MemoryStream: DotNet npNetMemoryStream;
        HashBytes: DotNet npNetArray;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        TempBlob.Blob.CreateInStream(InStr);
        CopyStream(MemoryStream, InStr);

        HashBytes := MemoryStream.ToArray();
        MemoryStream.Close();

        Stream := FTPWebRequest.GetRequestStream();
        Stream.Write(HashBytes, 0, ContentLenght);
        Stream.Close();
    end;

    procedure UTCDateTimeNowText(Format: Text): Text
    var
        DateTime: DotNet npNetDateTime;
        CultureInfo: DotNet npNetCultureInfo;
        DateTimeOffset: DotNet npNetDateTimeOffset;
    begin
        DateTime := DateTime.UtcNow;
        CultureInfo := CultureInfo.InvariantCulture;

        DateTimeOffset := DateTimeOffset.DateTimeOffset(DateTime);
        DateTimeOffset := DateTimeOffset.ToLocalTime;

        exit(DateTimeOffset.ToString(Format, CultureInfo));
    end;

    procedure JsonAdd(var Json: Text; Property: Text; Value: Variant; JString: Boolean)
    var
        CR: Char;
        LF: Char;
        Quotes: Text;
        TextValue: Text;
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJToken;
        JSONTextReader: DotNet npNetJsonTextReader;
        StringReader: DotNet npNetStringReader;
        TextReader: DotNet npNetTextReader;
        JArray: DotNet npNetJArray;
    begin
        JObject := JObject.JObject();

        if Json > '' then begin
            TextReader := StringReader.StringReader(Json);
            JSONTextReader := JSONTextReader.JsonTextReader(TextReader);
            JObject := JToken.ReadFrom(JSONTextReader);
        end;

        JObject.Add(Property, JToken);

        case true of
            Value.IsBoolean:
                ReplaceSubstringAnyLength(JObject.ToString(), TextValue, 'null', Format(Value, 0, 9));
            Value.IsText, Value.IsCode:
                begin
                    if not JString then
                        Quotes := '"';

                    ReplaceSubstringAnyLength(JObject.ToString(), TextValue, 'null', Quotes + Format(Value) + Quotes);
                end;
            Value.IsDecimal, Value.IsBigInteger, Value.IsInteger:
                ReplaceSubstringAnyLength(JObject.ToString(), TextValue, 'null', Format(Value, 0, 2));
            else
                Error(JSONValueDefErr);
        end;

        Json := TextValue;

        //carriage return and line feed created by the JObject object are sometimes not accepted by WebHeaderCollection class, cannot discern why
        CR := 13;
        LF := 10;
        Json := DelChr(Json, '=', Format(CR) + Format(LF));
    end;

    procedure GetJsonValueByPropertyNameSingleNode(JsonText: Text; PropertyName: Text): Text
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJToken;
        JSONTextReader: DotNet npNetJsonTextReader;
        StringReader: DotNet npNetStringReader;
        TextReader: DotNet npNetTextReader;
    begin
        //if more than one property share the name the method will fail
        TextReader := StringReader.StringReader(JsonText);
        JSONTextReader := JSONTextReader.JsonTextReader(TextReader);

        JObject := JToken.ReadFrom(JSONTextReader);

        JToken := JObject.SelectToken(PropertyName);

        exit(JToken.ToString);
    end;

    procedure GetXMLFromJsonArray(JsonText: Text; var XMLList: DotNet npNetXmlDocument; ArrayPropertyName: Text; ExtractFromProperty: Text; CheckProperty: Text; CheckPropertyValue: Text): Boolean
    var
        XMLElement: DotNet npNetXmlElement;
        XMLRoot: DotNet npNetXmlNode;
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJToken;
        JSONTextReader: DotNet npNetJsonTextReader;
        StringReader: DotNet npNetStringReader;
        TextReader: DotNet npNetTextReader;
        Jarray: DotNet npNetJArray;
        Uri: DotNet npNetUri;
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

    [TryFunction]
    procedure TryGetMIMEType(FileName: Text; var MIMEType: Text)
    var
        MimeMapping: DotNet npNetMimeMapping;
    begin
        MIMEType := MimeMapping.GetMimeMapping(FileName);
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

    procedure HandleURLWebException()
    var
        Exception: DotNet npNetException;
        WebException: DotNet npNetWebException;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
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
    procedure GetNodesFromXmlText(XMLText: Text; XPath: Text; var XMLNodeList: DotNet npNetXmlNodeList)
    var
        XMLDocument: DotNet npNetXmlDocument;
    begin
        XMLDocument := XMLDocument.XmlDocument();
        XMLDocument.LoadXml(XMLText);
        XMLNodeList := XMLDocument.SelectNodes(XPath);
    end;

    procedure AppendXML(InputXML: DotNet npNetXmlDocument; ParentNodeName: Text; var OutputXML: DotNet npNetXmlDocument)
    var
        XMLNode: DotNet npNetXmlNode;
        XMLRoot: DotNet npNetXmlNode;
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
}

