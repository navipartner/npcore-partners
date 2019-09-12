codeunit 6151164 "MM Loyalty Points WS (Client)"
{
    // MM1.38/TSA /20190221 CASE 338215 Initial Version
    // MM1.40/TSA /20190604 CASE 357360 Refactored - removed duplicate code, reuse webservice api code in codeunit 6060147
    // 
    // *** This codeunit should be decommisioned ***


    trigger OnRun()
    begin
    end;

    procedure WebServiceApi(LoyaltyEndpointClient: Record "MM NPR Remote Endpoint Setup";SoapAction: Text;var ReasonText: Text;var XmlDocIn: DotNet npNetXmlDocument;var XmlDocOut: DotNet npNetXmlDocument): Boolean
    var
        NPRMembership: Codeunit "MM NPR Membership";
    begin

        //-MM1.40 [357360]
        exit (NPRMembership.WebServiceApi (LoyaltyEndpointClient, SoapAction, ReasonText, XmlDocIn, XmlDocOut));

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
        //      B64Credential := ToBase64 (STRSUBSTNO ('%1:%2', LoyaltyEndpointClient."User Account", LoyaltyEndpointClient."User Password"));
        //      HttpWebRequest.Headers.Add ('Authorization', STRSUBSTNO ('Basic %1', B64Credential));
        //    END;
        //  ELSE
        //    HttpWebRequest.UseDefaultCredentials (TRUE);
        // END;
        //
        // HttpWebRequest.Method := 'POST';
        // HttpWebRequest.ContentType := 'application/xml; charset=utf-8';
        // HttpWebRequest.Headers.Add ('SOAPAction', STRSUBSTNO ('"%1"', SoapAction));
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
        //+MM1.40 [357360]
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

        exit (DelChr (InText, '<=>', DelChr (InText, '<=>', '1234567890 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-+*')));
    end;
}

