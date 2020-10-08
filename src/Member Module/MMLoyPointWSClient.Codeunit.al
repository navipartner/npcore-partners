codeunit 6151164 "NPR MM Loy. Point WS (Client)"
{

    // 
    // *** This codeunit should be decommisioned ***

    trigger OnRun()
    begin
    end;

    procedure WebServiceApi(LoyaltyEndpointClient: Record "NPR MM NPR Remote Endp. Setup"; SoapAction: Text; var ReasonText: Text; var XmlDocIn: DotNet "NPRNetXmlDocument"; var XmlDocOut: DotNet "NPRNetXmlDocument"): Boolean
    var
        NPRMembership: Codeunit "NPR MM NPR Membership";
    begin

        exit(NPRMembership.WebServiceApi(LoyaltyEndpointClient, SoapAction, ReasonText, XmlDocIn, XmlDocOut));

        //
        // ReasonText := '';
        // HttpWebRequest := HttpWebRequest.Create (LoyaltyEndpointClient."Endpoint URI");
        // HttpWebRequest.Timeout := LoyaltyEndpointClient."Connection Timeout (ms)";
        // HttpWebRequest.KeepAlive (TRUE);
        //
        //
        // CASE LoyaltyEndpointClient."Credentials Type" OF
        //  LoyaltyEndpointClient."Credentials Type"::NAMED :
        //    BEGIN
        //      HttpWebRequest.UseDefaultCredentials (FALSE);
        //      B64Credential := ToBase64 (StrSubstNo ('%1:%2', LoyaltyEndpointClient."User Account", LoyaltyEndpointClient."User Password"));
        //      HttpWebRequest.Headers.Add ('Authorization', StrSubstNo ('Basic %1', B64Credential));
        //    END;
        //  ELSE
        //    HttpWebRequest.UseDefaultCredentials (TRUE);
        // END;
        //
        // HttpWebRequest.Method := 'POST';
        // HttpWebRequest.ContentType := 'application/xml; charset=utf-8';
        // HttpWebRequest.Headers.Add ('SOAPAction', StrSubstNo ('"%1"', SoapAction));
        //
        // NpXmlDomMgt.SetTrustedCertificateValidation (HttpWebRequest);
        //
        // IF (TrySendWebRequest (XmlDocIn, HttpWebRequest, HttpWebResponse, SoapAction)) THEN BEGIN
        //  IF (TryReadResponseText (HttpWebResponse, ResponseText, SoapAction)) THEN BEGIN
        //    IF (TryParseResponseText (ResponseText)) THEN BEGIN
        //      XmlDocOut := XmlDocOut.XmlDocument;
        //      XmlDocOut.LoadXml (ResponseText);
        //
        //      EXIT (TRUE);
        //    END;
        //  END;
        // END;
        //
        // XmlDocOut := XmlDocOut.XmlDocument;
        // GetExceptionDescription (XmlDocOut, SoapAction, LoyaltyEndpointClient."Endpoint URI");
        //
        // EXIT (FALSE);

    end;

    procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
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

    procedure XmlSafe(InText: Text): Text
    begin

        exit(DelChr(InText, '<=>', DelChr(InText, '<=>', '1234567890 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-+*')));
    end;
}

