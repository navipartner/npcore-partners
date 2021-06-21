codeunit 6150913 "NPR POS HC Gen. Web Req."
{
    var
        InvalidXml: Label 'The response is not in valid XML format.\\%1';

    procedure CallGenericWebRequest(EndpointCode: Code[10]; RequestCode: Code[20]; Parameters: array[6] of Text; var ResponseArray: array[4] of Text)
    var
        HCEndpointSetup: Record "NPR POS HC Endpoint Setup";
        SoapAction: Text;
        RequestXmlDocText: Text;
        ResponseXmlElement: XmlElement;
        ResponseText: Text;
        TmpHCGenericWebRequest: Record "NPR HC Generic Web Request" temporary;
        ResponseXmlText: Text;
    begin

        HCEndpointSetup.Get(EndpointCode);
        CreateGenericRequestRecord(RequestCode, Parameters, TmpHCGenericWebRequest);
        BuildGenericRequest(TmpHCGenericWebRequest, SoapAction, RequestXmlDocText);
        if (not WebServiceApi(HCEndpointSetup, SoapAction, RequestXmlDocText, ResponseXmlElement, ResponseXmlText)) then
            Error('Error from WebService:\\%1', ResponseXmlElement.InnerXml());

        if (not ApplyGenericResponse(TmpHCGenericWebRequest, ResponseXmlElement, ResponseText, ResponseXmlText)) then
            Error(ResponseText);
        ResponseArray[1] := TmpHCGenericWebRequest."Response 1";
        ResponseArray[2] := TmpHCGenericWebRequest."Response 2";
        ResponseArray[3] := TmpHCGenericWebRequest."Response 3";
        ResponseArray[4] := TmpHCGenericWebRequest."Response 4";
    end;

    local procedure CreateGenericRequestRecord(RequestCode: Code[20]; Parameters: array[6] of Text; var TmpHCGenericWebRequest: Record "NPR HC Generic Web Request" temporary)
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
        TmpHCGenericWebRequest.Insert();
    end;

    local procedure BuildGenericRequest(var TmpHCGenericWebRequest: Record "NPR HC Generic Web Request" temporary; var SoapAction: Text; var XmlRequest: Text): Boolean
    var
        WebReqLbl: Label '<x61:requestline number="%1" requestcode="%2">', Locked = true;
    begin
        SoapAction := 'urn:microsoft-dynamics-schemas/codeunit/hqconnector:GenericWebRequest';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hqc="urn:microsoft-dynamics-schemas/codeunit/hqconnector" xmlns:x61="urn:microsoft-dynamics-nav/xmlports/x6150905">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <hqc:GenericWebRequest>' +
         '         <hqc:genericrequest>' +
         '            <x61:request>';
        XmlRequest += StrSubstNo(WebReqLbl,
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

        exit(true);
    end;

    local procedure ApplyGenericResponse(var TmpHCGenericWebRequest: Record "NPR HC Generic Web Request" temporary; var Element: XmlElement; var ResponseText: Text; ResponseXmlText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NodeList: XmlNodeList;
        Node: XmlNode;
        TextOk: Text;
        ElementPath: Text;
    begin

        if Element.IsEmpty then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(ResponseXmlText));
            exit(false);
        end;

        ElementPath := '//GenericWebRequest_Result/genericrequest/requestresponse/responseStatus/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responseCode', 10, true);

        if (UpperCase(TextOk) <> 'OK') then begin
            ElementPath := '//GenericWebRequest_Result/genericrequest/requestresponse/responseStatus/';
            ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responseDescription', 1000, true);
            exit(false);
        end;

        ElementPath := 'GenericWebRequest_Result/genericrequest/requestresponse/responeseline';
        if (not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), ElementPath, NodeList)) then
            Error('Find node [%1] failed in document \\%2', ElementPath, Element.InnerXml);

        foreach Node in NodeList do begin
            TmpHCGenericWebRequest."Response 1" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'response1', MaxStrLen(TmpHCGenericWebRequest."Response 1"), false);
            TmpHCGenericWebRequest."Response 2" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'response2', MaxStrLen(TmpHCGenericWebRequest."Response 2"), false);
            TmpHCGenericWebRequest."Response 3" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'response3', MaxStrLen(TmpHCGenericWebRequest."Response 3"), false);
            TmpHCGenericWebRequest."Response 4" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'response4', MaxStrLen(TmpHCGenericWebRequest."Response 4"), false);
            exit(true);
        end;
    end;

    procedure WebServiceApi(EndpointSetup: Record "NPR POS HC Endpoint Setup"; SoapAction: Text; XmlDocInText: Text; var XmlElementOut: XmlElement; var ResponseXmlText: Text): Boolean
    var
        XMLDomManagement: Codeunit "XML DOM Management";
        Base64Convert: codeunit "Base64 Convert";
        B64Credential: Text[200];
        XmlDocOut: XmlDocument;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Request: HttpRequestMessage;
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        BasicAuthLbl: Label 'Basic %1', Locked = true;
        Base64ConvertCredentialsLbl: Label '%1:%2', Locked = true;
        SoapActionLbl: Label '"%1"', Locked = true;
        ResponseLbl: Label '<responseStatus><responseCode>%1</responseCode><responseDescription>%2 - %3</responseDescription></responseStatus>', Locked = true;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        case EndpointSetup."Credentials Type" of
            EndpointSetup."Credentials Type"::NAMED:
                begin
                    B64Credential := Base64Convert.ToBase64(StrSubstNo(Base64ConvertCredentialsLbl, EndpointSetup."User Account", EndpointSetup."User Password"));
                    RequestHeaders.Add('Authorization', StrSubstNo(BasicAuthLbl, B64Credential));
                end;
            else
        end;

        Request.Method('POST');
        Request.SetRequestUri(EndpointSetup."Endpoint URI");

        RequestContent.WriteFrom(XmlDocInText);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', StrSubstNo(SoapActionLbl, SoapAction));
        ContentHeader := Client.DefaultRequestHeaders();

        Request.Content(RequestContent);
        Client.Timeout(EndpointSetup."Connection Timeout (ms)");
        Client.Send(Request, Response);

        if Response.IsSuccessStatusCode then begin
            Response.Content.ReadAs(ResponseXmlText);
            ResponseXmlText := XMLDomManagement.RemoveNamespaces(ResponseXmlText);
            XmlDocument.ReadFrom(ResponseXmlText, XmlDocOut);
            XmlDocOut.GetRoot(XmlElementOut);
            exit(true);
        end;

        ResponseXmlText := Response.ReasonPhrase;
        if (StrLen(ResponseXmlText) > 0) then
            XmlDocument.ReadFrom(ResponseXmlText, XmlDocOut)
        else
            XmlDocument.ReadFrom(StrSubstNo(
              ResponseLbl,
              Response.HttpStatusCode,
              Response.ReasonPhrase,
              EndpointSetup."Endpoint URI"), XmlDocOut);

        XmlDocOut.GetRoot(XmlElementOut);

        exit(false);
    end;
}

