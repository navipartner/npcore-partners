codeunit 6151164 "MM Loyalty Points WS (Client)"
{
    // MM1.38/TSA /20190221 CASE 338215 Initial Version


    trigger OnRun()
    begin
    end;

    procedure WebServiceApi(LoyaltyEndpointClient: Record "MM NPR Remote Endpoint Setup"; SoapAction: Text; var ReasonText: Text; var XmlDocIn: DotNet npNetXmlDocument; var XmlDocOut: DotNet npNetXmlDocument): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        Convert: DotNet npNetConvert;
        B64Credential: Text[200];
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        WebInnerException: DotNet npNetWebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
    begin

        ReasonText := '';
        HttpWebRequest := HttpWebRequest.Create(LoyaltyEndpointClient."Endpoint URI");
        HttpWebRequest.Timeout := LoyaltyEndpointClient."Connection Timeout (ms)";
        HttpWebRequest.KeepAlive(true);


        case LoyaltyEndpointClient."Credentials Type" of
            LoyaltyEndpointClient."Credentials Type"::NAMED:
                begin
                    HttpWebRequest.UseDefaultCredentials(false);
                    B64Credential := ToBase64(StrSubstNo('%1:%2', LoyaltyEndpointClient."User Account", LoyaltyEndpointClient."User Password"));
                    HttpWebRequest.Headers.Add('Authorization', StrSubstNo('Basic %1', B64Credential));
                end;
            else
                HttpWebRequest.UseDefaultCredentials(true);
        end;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'application/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', StrSubstNo('"%1"', SoapAction));

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if (TrySendWebRequest(XmlDocIn, HttpWebRequest, HttpWebResponse, SoapAction)) then begin
            if (TryReadResponseText(HttpWebResponse, ResponseText, SoapAction)) then begin
                if (TryParseResponseText(ResponseText)) then begin
                    XmlDocOut := XmlDocOut.XmlDocument;
                    XmlDocOut.LoadXml(ResponseText);

                    exit(true);
                end;
            end;
        end;

        XmlDocOut := XmlDocOut.XmlDocument;
        GetExceptionDescription(XmlDocOut, SoapAction, LoyaltyEndpointClient."Endpoint URI");

        exit(false);
    end;

    local procedure GetExceptionDescription(var XmlDocOut: DotNet npNetXmlDocument; SoapAction: Text; Endpoint: Text)
    var
        ReasonText: Text;
        WebException: DotNet npNetWebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
    begin

        ReasonText := StrSubstNo('Error from WebServiceApi %1\\%2', GetLastErrorText, SoapAction);

        Exception := GetLastErrorObject();
        if ((Format(GetDotNetType(Exception.GetBaseException()))) <> (Format(GetDotNetType(WebException)))) then begin
            //ERROR (Exception.ToString ());
            XmlDocOut.LoadXml(StrSubstNo(
              '<Fault>' +
                '<faultstatus>%1</faultstatus>' +
                '<faultstring>%2 - %3</faultstring>' +
              '</Fault>',
              998,
              ReasonText,
              Endpoint));
            exit;
        end;

        WebException := Exception.GetBaseException();
        TryReadExceptionResponseText(WebException, StatusCode, StatusDescription, ResponseText);

        if (StrLen(ResponseText) > 0) then
            XmlDocOut.LoadXml(ResponseText);

        if (StrLen(ResponseText) = 0) then
            XmlDocOut.LoadXml(StrSubstNo(
              '<Fault>' +
                '<faultstatus>%1</faultstatus>' +
                '<faultstring>%2 - %3</faultstring>' +
              '</Fault>',
              StatusCode,
              StatusDescription,
              Endpoint));
    end;

    [TryFunction]
    local procedure TrySendWebRequest(var XmlDoc: DotNet npNetXmlDocument; HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse; SoapAction: Text)
    var
        MemoryStream: DotNet npNetMemoryStream;
    begin

        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse; var ResponseText: Text; SoapAction: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
    begin

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream());
        ResponseText := StreamReader.ReadToEnd;
        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet npNetWebException; var StatusCode: Code[10]; var StatusDescription: Text; var ResponseXml: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        WebResponse: DotNet npNetWebResponse;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        SystemConvert: DotNet npNetConvert;
        StatusCodeInt: Integer;
        DotNetType: DotNet npNetType;
    begin

        ResponseXml := '';

        // No respone body on time out
        if (WebException.Status.Equals(WebExceptionStatus.Timeout)) then begin
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(WebExceptionStatus.Timeout, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := WebExceptionStatus.Timeout.ToString();
            exit;
        end;

        // This happens for unauthorized and server side faults (4xx and 5xx)
        // The response stream in unauthorized fails in XML transformation later
        if (WebException.Status.Equals(WebExceptionStatus.ProtocolError)) then begin
            HttpWebResponse := WebException.Response();
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(HttpWebResponse.StatusCode, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := HttpWebResponse.StatusDescription;
            if (StatusCode[1] = '4') then // 4xx messages
                exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryGetWebExceptionResponse(var WebException: DotNet npNetWebException; var HttpWebResponse: DotNet npNetHttpWebResponse)
    begin

        HttpWebResponse := WebException.Response;
    end;

    [TryFunction]
    local procedure TryGetInnerWebException(var WebException: DotNet npNetWebException; var InnerWebException: DotNet npNetWebException)
    begin

        InnerWebException := WebException.InnerException;
    end;

    [TryFunction]
    local procedure TryParseResponseText(XmlText: Text)
    var
        XmlDocOut: DotNet npNetXmlDocument;
    begin

        XmlDocOut := XmlDocOut.XmlDocument;
        XmlDocOut.LoadXml(XmlText);
    end;

    procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Record TempBlob temporary;
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.Blob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        B64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    procedure XmlSafe(InText: Text): Text
    begin

        exit(DelChr(InText, '<=>', DelChr(InText, '<=>', '1234567890 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-+*')));
    end;
}

