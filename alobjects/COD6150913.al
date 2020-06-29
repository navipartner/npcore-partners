codeunit 6150913 "POS HC Generic Web Request"
{
    // NPR5.38/BR  /20171205  CASE 297946 Initial Version


    trigger OnRun()
    begin
    end;

    var
        InvalidXml: Label 'The response is not in valid XML format.\\%1';

    local procedure "-- Client Side (POS)"()
    begin
    end;

    procedure CallGenericWebRequest(EndpointCode: Code[10]; RequestCode: Code[20]; Parameters: array[6] of Text; var ResponseArray: array[4] of Text)
    var
        HCEndpointSetup: Record "POS HC Endpoint Setup";
        SoapAction: Text;
        RequestXmlDoc: DotNet npNetXmlDocument;
        ResponseXmlDoc: DotNet npNetXmlDocument;
        ResponseText: Text;
        TmpHCGenericWebRequest: Record "HC Generic Web Request" temporary;
    begin

        HCEndpointSetup.Get(EndpointCode);
        CreateGenericRequestRecord(RequestCode, Parameters, TmpHCGenericWebRequest);
        BuildGenericRequest(TmpHCGenericWebRequest, SoapAction, RequestXmlDoc);
        if (not WebServiceApi(HCEndpointSetup, SoapAction, RequestXmlDoc, ResponseXmlDoc)) then
            Error('Error from WebService:\\%1', ResponseXmlDoc.InnerXml());

        if (not ApplyGenericResponse(TmpHCGenericWebRequest, ResponseXmlDoc, ResponseText)) then
            Error(ResponseText);
        ResponseArray[1] := TmpHCGenericWebRequest."Response 1";
        ResponseArray[2] := TmpHCGenericWebRequest."Response 2";
        ResponseArray[3] := TmpHCGenericWebRequest."Response 3";
        ResponseArray[4] := TmpHCGenericWebRequest."Response 4";
    end;

    local procedure CreateGenericRequestRecord(RequestCode: Code[20]; Parameters: array[6] of Text; var TmpHCGenericWebRequest: Record "HC Generic Web Request" temporary)
    begin
        TmpHCGenericWebRequest."Entry No." := 0;
        TmpHCGenericWebRequest."Request Date" := CurrentDateTime;
        TmpHCGenericWebRequest."Request User ID" := UserId;
        TmpHCGenericWebRequest."Request Code" := RequestCode;
        TmpHCGenericWebRequest."Parameter 1" := Parameters[1];
        TmpHCGenericWebRequest."Parameter 2" := Parameters[2];
        TmpHCGenericWebRequest."Parameter 3" := Parameters[3];
        TmpHCGenericWebRequest."Parameter 4" := Parameters[4];
        TmpHCGenericWebRequest."Parameter 5" := Parameters[5];
        TmpHCGenericWebRequest."Parameter 6" := Parameters[6];
        TmpHCGenericWebRequest.Insert;
    end;

    local procedure BuildGenericRequest(var TmpHCGenericWebRequest: Record "HC Generic Web Request" temporary; var SoapAction: Text; var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        XmlRequest: Text;
        LineType: Option;
    begin

        SoapAction := 'urn:microsoft-dynamics-schemas/codeunit/hqconnector:GenericWebRequest';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hqc="urn:microsoft-dynamics-schemas/codeunit/hqconnector" xmlns:x61="urn:microsoft-dynamics-nav/xmlports/x6150905">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <hqc:GenericWebRequest>' +
         '         <hqc:genericrequest>' +
         '            <x61:request>';
        //XmlRequest += STRSUBSTNO ('<x61:requestline number="%1" actioncode="%2" parameter1="%3" parameter2="%4" parameter3="%5" parameter4="%6" parameter5="%7" parameter6="%8">',
        XmlRequest += StrSubstNo('<x61:requestline number="%1" requestcode="%2">',
                                  TmpHCGenericWebRequest."Entry No.",
                                  TmpHCGenericWebRequest."Request Code");
        XmlRequest += '<parameter1>' + TmpHCGenericWebRequest."Parameter 1" + '</parameter1>';
        XmlRequest += '<parameter2>' + TmpHCGenericWebRequest."Parameter 2" + '</parameter2>';
        XmlRequest += '<parameter3>' + TmpHCGenericWebRequest."Parameter 3" + '</parameter3>';
        XmlRequest += '<parameter4>' + TmpHCGenericWebRequest."Parameter 4" + '</parameter4>';
        XmlRequest += '<parameter5>' + TmpHCGenericWebRequest."Parameter 5" + '</parameter5>';
        XmlRequest += '<parameter6>' + TmpHCGenericWebRequest."Parameter 6" + '</parameter6>';
        XmlRequest += '<requestdate>' + Format(TmpHCGenericWebRequest."Request Date", 0, 9) + '</requestdate>';
        XmlRequest += '<requestuserid>' + TmpHCGenericWebRequest."Request User ID" + '</requestuserid>';

        XmlRequest +=
         '              </x61:requestline>' +
         '            </x61:request>' +
         '         </hqc:genericrequest>' +
         '      </hqc:GenericWebRequest>' +
         '   </soapenv:Body>' +
         '</soapenv:Envelope>';

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlRequest);
        exit(true);
    end;

    local procedure ApplyGenericResponse(var TmpHCGenericWebRequest: Record "HC Generic Web Request" temporary; var XmlDoc: DotNet npNetXmlDocument; var ResponseText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        XmlNodeElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        TextOk: Text;
        ElementPath: Text;
        NumberText: Text[100];
        DecimalNumber: Decimal;
        IntegerNumber: Integer;
        i: Integer;
        SaleLinePOS: Record "Sale Line POS";
    begin

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;

        if (IsNull(XmlElement)) then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        ElementPath := '//GenericWebRequest_Result/genericrequest/requestresponse/responseStatus/';
        TextOk := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'responseCode', 10, true);

        if (UpperCase(TextOk) <> 'OK') then begin
            ElementPath := '//GenericWebRequest_Result/genericrequest/requestresponse/responseStatus/';
            ResponseText := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'responseDescription', 1000, true);
            exit(false);
        end;

        ElementPath := 'GenericWebRequest_Result/genericrequest/requestresponse/responeseline';
        if (not NpXmlDomMgt.FindNodes(XmlElement, ElementPath, XmlNodeList)) then
            Error('Find node [%1] failed in document \\%2', ElementPath, XmlElement.InnerXml);
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlNodeElement := XmlNodeList.ItemOf(i);
            TmpHCGenericWebRequest."Response 1" := NpXmlDomMgt.GetXmlText(XmlNodeElement, 'response1', MaxStrLen(TmpHCGenericWebRequest."Response 1"), false);
            TmpHCGenericWebRequest."Response 2" := NpXmlDomMgt.GetXmlText(XmlNodeElement, 'response2', MaxStrLen(TmpHCGenericWebRequest."Response 2"), false);
            TmpHCGenericWebRequest."Response 3" := NpXmlDomMgt.GetXmlText(XmlNodeElement, 'response3', MaxStrLen(TmpHCGenericWebRequest."Response 3"), false);
            TmpHCGenericWebRequest."Response 4" := NpXmlDomMgt.GetXmlText(XmlNodeElement, 'response4', MaxStrLen(TmpHCGenericWebRequest."Response 4"), false);
            //TmpHCGenericWebRequest.MODIFY;
            exit(true);
        end;
    end;

    local procedure "--WSSupport"()
    begin
    end;

    procedure WebServiceApi(EndpointSetup: Record "POS HC Endpoint Setup"; SoapAction: Text; var XmlDocIn: DotNet npNetXmlDocument; var XmlDocOut: DotNet npNetXmlDocument): Boolean
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

        HttpWebRequest := HttpWebRequest.Create(EndpointSetup."Endpoint URI");
        HttpWebRequest.Timeout := EndpointSetup."Connection Timeout (ms)";
        HttpWebRequest.KeepAlive(false);

        case EndpointSetup."Credentials Type" of
            EndpointSetup."Credentials Type"::NAMED:
                begin
                    HttpWebRequest.UseDefaultCredentials(false);
                    B64Credential := ToBase64(StrSubstNo('%1:%2', EndpointSetup."User Account", EndpointSetup."User Password"));
                    HttpWebRequest.Headers.Add('Authorization', StrSubstNo('Basic %1', B64Credential));
                end;
            else
                HttpWebRequest.UseDefaultCredentials(true);
        end;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', StrSubstNo('"%1"', SoapAction));

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if (TrySendWebRequest(XmlDocIn, HttpWebRequest, HttpWebResponse)) then begin
            TryReadResponseText(HttpWebResponse, ResponseText);
            XmlDocOut := XmlDocOut.XmlDocument;
            XmlDocOut.LoadXml(ResponseText);
            exit(true);
        end;

        Exception := GetLastErrorObject();
        if ((Format(GetDotNetType(Exception.GetBaseException()))) <> (Format(GetDotNetType(WebException)))) then
            Error(Exception.ToString());

        WebException := Exception.GetBaseException();
        TryReadExceptionResponseText(WebException, StatusCode, StatusDescription, ResponseText);

        XmlDocOut := XmlDocOut.XmlDocument;
        if (StrLen(ResponseText) > 0) then
            XmlDocOut.LoadXml(ResponseText);

        if (StrLen(ResponseText) = 0) then
            XmlDocOut.LoadXml(StrSubstNo(
              '<responseStatus>' +
                '<responseCode>%1</responseCode>' +
                '<responseDescription>%2 - %3</responseDescription>' +
              '</responseStatus>',
              StatusCode,
              StatusDescription,
              EndpointSetup."Endpoint URI"));

        exit(false);
    end;

    [TryFunction]
    local procedure TrySendWebRequest(var XmlDoc: DotNet npNetXmlDocument; HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse)
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
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse; var ResponseText: Text)
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

    local procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        Clear(TempBlob);
        TempBlob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        B64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    local procedure EvaluateToDecimal(NumberText: Text[30]): Decimal
    var
        DecimalValueOut: Decimal;
    begin
        if (NumberText = '') then
            NumberText := '0.0';

        Evaluate(DecimalValueOut, NumberText, 9);
        exit(DecimalValueOut);
    end;

    local procedure EvaluateToInteger(NumberText: Text[30]): Integer
    var
        IntegerValueOut: Integer;
    begin

        if (NumberText = '') then
            NumberText := '0';

        Evaluate(IntegerValueOut, NumberText, 9);
        exit(IntegerValueOut);
    end;
}

