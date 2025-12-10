codeunit 85090 "NPR Library SI Fiscal"
{
    EventSubscriberInstance = Manual;
    procedure CreateAuditProfileAndSISetup(var POSAuditProfile: Record "NPR POS Audit Profile"; var POSStore: Record "NPR POS Store"; var POSUnit: Record "NPR POS Unit"; var SalespersonPurchaser: Record "Salesperson/Purchaser")
    var
        NoSeriesLine: Record "No. Series Line";
        SIAuxSalespersonPurchaser: Record "NPR SI Aux Salesperson/Purch.";
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
        SIPOSStoreMapping: Record "NPR SI POS Store Mapping";
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
        OStream: OutStream;
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := HandlerCode();
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Audit Handler" := HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Do Not Print Receipt on Sale" := true;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sales Ticket No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence);
#ELSE
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
#ENDIF
        NoSeriesLine.Modify();
        POSAuditProfile.Insert();
        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Modify();

        SIPOSStoreMapping.Init();
        SIPOSStoreMapping."POS Store Code" := POSStore.Code;
        SIPOSStoreMapping."Building Number" := GetTestBuildingNumber();
        SIPOSStoreMapping."Building Section Number" := GetTestBuildingSectNumber();
        SIPOSStoreMapping."Cadastral Number" := GetTestCadastralNumber();
        SIPOSStoreMapping."Validity Date" := CalcDate('<1D>', Today());
        SIPOSStoreMapping."Receipt No. Series" := CreateNumberSeries();
        NoSeriesLine.SetRange("Series Code", SIPOSStoreMapping."Receipt No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Normal);
#ELSE
        NoSeriesLine.Validate("Allow Gaps in Nos.", false);
#ENDIF
        NoSeriesLine.Validate("Starting No.", '1');
        NoSeriesLine.Modify();
        SIPOSStoreMapping.Insert();

        SIAuxSalespersonPurchaser.Init();
        SIAuxSalespersonPurchaser."Salesperson/Purchaser SystemId" := SalespersonPurchaser.SystemId;
        SIAuxSalespersonPurchaser."NPR SI Salesperson Tax Number" := GetTestSalespersonTaxNo();
        SIAuxSalespersonPurchaser.Insert();

        SIFiscalizationSetup.DeleteAll();
        SIFiscalizationSetup.Init();
        SIFiscalizationSetup."Enable SI Fiscal" := true;
        SIFiscalizationSetup."Signing Certificate Password" := GetTestCertPassword();
        SIFiscalizationSetup."Signing Certificate Thumbprint" := GetTestCertThumbprint();
        SIFiscalizationSetup."Certificate Subject Ident." := GetTestCertCertificateIdent();
        SIFiscalizationSetup."Signing Certificate".CreateOutStream(OStream);
        OStream.WriteText('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');

        SIFiscalizationSetup."Environment URL" := 'https://blagajne-test.fu.gov.si:9002/v1/cash_registers';
        SIFiscalizationSetup.Insert();

        BindSubscription(LibrarySIFiscal);
        RegisterPOSStore(SIPOSStoreMapping);
        UnbindSubscription(LibrarySIFiscal);
    end;

    procedure CreateNumberSeries(): Text
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    procedure CreatePOSStore(var POSStore: Record "NPR POS Store"; POSPostingProfile: Record "NPR POS Posting Profile")
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
        POSStore.Address := GetTestAddress();
        POSStore.City := GetTestCity();
        POSStore."Post Code" := GetTestPostCode();
        POSStore.Modify();
    end;

    procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'SI_DAVKI', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure GetTestCertPassword(): Text[250]
    begin
        exit('RVL6J6DH0NYJ');
    end;

    local procedure GetTestCertThumbprint(): Text[250]
    begin
        exit('D9D3C393F213E96CFB223AD924E215579A2100D0');
    end;

    local procedure GetTestSalespersonTaxNo(): Integer
    begin
        exit(12345678);
    end;

    local procedure GetTestCertCertificateIdent(): Code[11]
    begin
        exit('1774');
    end;

    local procedure RegisterPOSStore(var POSStoreMapping: Record "NPR SI POS Store Mapping")
    var
        SITaxCommunicationMgt: Codeunit "NPR SI Tax Communication Mgt.";
    begin
        SITaxCommunicationMgt.RegisterPOSStore(POSStoreMapping);
    end;

    local procedure GetTestBuildingNumber(): Integer
    begin
        exit(12);
    end;

    local procedure GetTestBuildingSectNumber(): Integer
    begin
        exit(9);
    end;

    local procedure GetTestCadastralNumber(): Integer
    begin
        exit(4567);
    end;

    local procedure GetTestAddress(): Text[50]
    begin
        exit('Test Address 12b');
    end;

    local procedure GetTestCity(): Text[30]
    begin
        exit('Ljubljana');
    end;

    local procedure GetTestPostCode(): Code[20]
    begin
        exit('1100');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR SI Tax Communication Mgt.", 'OnBeforeSendHttpRequest', '', false, false)]
    local procedure OnBeforeSendHttpRequest(sender: Codeunit "NPR SI Tax Communication Mgt."; var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fu="http://www.fu.gov.si/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><fu:InvoiceResponse Id="data"><fu:Header><fu:MessageID>94273892-4805-42a4-b1a0-f41da94da6a2</fu:MessageID><fu:DateTime>2023-11-01T13:30:48</fu:DateTime></fu:Header><fu:UniqueInvoiceID>e7d2c6a1-e40d-4036-882a-4655d861f1fb</fu:UniqueInvoiceID><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/><Reference URI="#data"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/><DigestValue>K6BQgF4TjfeIo2RijovRBXYJDUM2KcarFJTkO21bwdI=</DigestValue></Reference></SignedInfo><SignatureValue>ZvaRpE2itAzeUsmYLgmYXkksGDprn/7TRCUf/jHemB98d6wUbxfGLLbZrghdnKd9Akuvc2K98KiL 8pcyWDnaY3GVYkD3D11bOQYYMTlnCuvTUA2T+ZAAK9a7pisAvVb4QvHQQADapQjLSEmR3KfM5pyp BvhgHdhPDOHknrYizVaWDmxmW1dLHWqbmxsvsDtupkfsZ0cQUO5l1iXdsvDotvccuLvZ5vW0lLvk 0LxnMtxppk6k37JfOdRFpwEYFFU6SBx0Fn7SIpPlccvb9gn+JuHSHqW8x0+WOfe3BNTQDazNtAzh lKTsAkiRqUd/bCNO1vDWy5J5ZLcLt5BvttWWew==</SignatureValue><KeyInfo><X509Data><X509SubjectName>CN=DavPotRacTEST + OID.2.5.4.5=1237997210011, OU=systems, O=state authorities, C=SI</X509SubjectName><X509IssuerSerial><X509IssuerName>CN=SIGOV-CA,2.5.4.97=#130e56415453492d3137363539393537,O=Republika Slovenija,C=SI</X509IssuerName><X509SerialNumber>64766398760318685497656163882</X509SerialNumber></X509IssuerSerial><X509Certificate>MIIGJDCCBIygAwIBAgINANFFgmgAAAAAVn0+KjANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQGEwJT STEcMBoGA1UEChMTUmVwdWJsaWthIFNsb3ZlbmlqYTEXMBUGA1UEYRMOVkFUU0ktMTc2NTk5NTcx ETAPBgNVBAMTCFNJR09WLUNBMB4XDTIwMDUwNjA4MTE1OVoXDTI1MDUwNjA4NDE1OVowaTELMAkG A1UEBhMCU0kxGjAYBgNVBAoTEXN0YXRlIGF1dGhvcml0aWVzMRAwDgYDVQQLEwdzeXN0ZW1zMSww FAYDVQQDEw1EYXZQb3RSYWNURVNUMBQGA1UEBRMNMTIzNzk5NzIxMDAxMTCCASIwDQYJKoZIhvcN AQEBBQADggEPADCCAQoCggEBAODJIvOX5DfmBO1sL+tvRr+YjRYZo1qDlGuw4kRqvmYIhKqNRPPt kp51qO6kaqbhX4gvj5LHU03fhBje4YQSd/6j+kNPFuVKvyvyhYkk3ogLEQh9rBXxxq875Mpmtewv OU2abDm0ACyvINya5g9ap0CDeDPd5hRJcQ1Kwhby2CtCT3VHc7YCamv8pZ2tZZsmk/v4GEbsGMjq SgWV3PfHcKOElzDua+hHC6ggFQx04p7RqA/veubx2XZIWYjAc725TA6CKzs0EZQMcvDV4TU5VNyy GpWpMPVeyj03cbypVp0uHoZMSechRUfiRmchT4hyBASPhkTtO4xe2NemuG5kaYMCAwEAAaOCAlsw ggJXMA4GA1UdDwEB/wQEAwIFoDBABgNVHSAEOTA3MDUGCisGAQQBr1kBCQkwJzAlBggrBgEFBQcC ARYZaHR0cDovL3d3dy5jYS5nb3Yuc2kvY3BzLzB3BggrBgEFBQcBAQRrMGkwPgYIKwYBBQUHMAKG Mmh0dHA6Ly93d3cuc2lnb3YtY2EuZ292LnNpL2NydC9zaWdvdi1jYTItY2VydHMucDdjMCcGCCsG AQUFBzABhhtodHRwOi8vb2NzcC5zaWdvdi1jYS5nb3Yuc2kwIQYDVR0RBBowGIEWbWFyamFuLmFt YnJvemljQGdvdi5zaTCCATIGA1UdHwSCASkwggElMIGxoIGuoIGrhixodHRwOi8vd3d3LnNpZ292 LWNhLmdvdi5zaS9jcmwvc2lnb3YtY2EyLmNybIZ7bGRhcDovL3g1MDAuZ292LnNpL2NuPVNJR09W LUNBLG9yZ2FuaXphdGlvbklkZW50aWZpZXI9VkFUU0ktMTc2NTk5NTcsbz1SZXB1Ymxpa2ElMjBT bG92ZW5pamEsYz1TST9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0MG+gbaBrpGkwZzELMAkGA1UE BhMCU0kxHDAaBgNVBAoTE1JlcHVibGlrYSBTbG92ZW5pamExFzAVBgNVBGETDlZBVFNJLTE3NjU5 OTU3MREwDwYDVQQDEwhTSUdPVi1DQTEOMAwGA1UEAxMFQ1JMMzQwEwYDVR0jBAwwCoAIRl5A5VPt /v4wEQYDVR0OBAoECEIy3tUNJ2R8MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggGBABzHlENX 4aW4HGn00AmFwPYYWDJ86A5q+atRhsfBerFSR5qRpnsD4CojqyIbGxtzrT3SwR1MOqJOuIOazP03 bMCzRDnNLvWeyUfmbrZ+LrTCoik5Y2teDTisuIeALDjT8avbPGrO69SkDaKIKH3zRgFAxAFziRKz JzARVs2aY2pjCkiDUJO4Ha2tTZ1xAcDZWMNDXcYlui+fVx5Ps2L71kxD5cQzVdMdP80o3IDUb8et hQ1JVdQjGswn662hfaZ1v9pIFOdxgzMp0alpuHlT3OOui/SbwxPV4YZUKRpQHYUA6aR66rEDozPf r58XNp2z0pUzT4O3Llr2mAVkeeTMOTzT5fraqr3+UpgRGaVoCUxIWo4JG9B2uZ8nv9a72ASPv9c0 srenLrBHziuoVd7IndL/gIElIgABz6ygQsY3LQ24j1QkiTykOxMbHxruzPhSW0B4ISohWFSYtyz6 FXQeE9k63quLXpGuEumQC1H/KeLnTRAkv+2O2v0qexCqLh7Gcg==</X509Certificate></X509Data><KeyValue><RSAKeyValue><Modulus>4Mki85fkN+YE7Wwv629Gv5iNFhmjWoOUa7DiRGq+ZgiEqo1E8+2SnnWo7qRqpuFfiC+PksdTTd+E GN7hhBJ3/qP6Q08W5Uq/K/KFiSTeiAsRCH2sFfHGrzvkyma17C85TZpsObQALK8g3JrmD1qnQIN4 M93mFElxDUrCFvLYK0JPdUdztgJqa/ylna1lmyaT+/gYRuwYyOpKBZXc98dwo4SXMO5r6EcLqCAV DHTintGoD+965vHZdkhZiMBzvblMDoIrOzQRlAxy8NXhNTlU3LIalakw9V7KPTdxvKlWnS4ehkxJ 5yFFR+JGZyFPiHIEBI+GRO07jF7Y16a4bmRpgw==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue></KeyValue></KeyInfo></Signature></fu:InvoiceResponse></soapenv:Body></soapenv:Envelope>';
        sender.TestGetEORCodeFromResponse(SIPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR SI Tax Communication Mgt.", 'OnBeforeRegisterPOSStore', '', false, false)]
    local procedure OnBeforeRegisterPOSStore(sender: Codeunit "NPR SI Tax Communication Mgt."; var SIPOSStoreMapping: Record "NPR SI POS Store Mapping"; var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText := '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fu="http://www.fu.gov.si/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><fu:BusinessPremiseResponse Id="data"><fu:Header><fu:MessageID>899e9ec2-0104-417c-b9cd-8feb0a9a8234</fu:MessageID><fu:DateTime>2023-11-01T15:04:45</fu:DateTime>                   </fu:Header>                                    <Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/><Reference URI="#data"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/><DigestValue>HqPX+z0qxgbkhFIE06+KoqcJyHjQHsv4o5U8xcn0D7s=</DigestValue></Reference></SignedInfo><SignatureValue>cV/yothqIe5z0YRIhJH5mUzq2VFcIMBhMT9Tig0EW7hc2R0Pk+66/nyN6WbwRq3qu+kX36Uhadf0F4S028wlb2Cq4p5hM2DLXE+Fa/SQ5yH7wsoU2mzfljuuLn3aDHjgB70RaicomfzQz1LRfq7C6XBpVCztHuu0cJzxo07vjrHz4KLrBT0xEcq/vqdkrtAe3sDYGJBmOJ6SZ40Wucvkrka2gnItRlhgnUbazsljkZ4XZ6xQvvEIT8kdY0Gr6mFZR9/oT4lBt1SvqV4jY0i1KZIWFVIu1JbUhwqChMS4WNFiPcFAiim/gzrHgWUKs29pH5te63E78PqY1ZyByFH1kQ==</SignatureValue><KeyInfo><X509Data><X509SubjectName>CN=DavPotRacTEST + OID.2.5.4.5=1237997210011, OU=systems, O=state authorities, C=SI</X509SubjectName><X509IssuerSerial><X509IssuerName>CN=SIGOV-CA,2.5.4.97=#130e56415453492d3137363539393537,O=Republika Slovenija,C=SI</X509IssuerName><X509SerialNumber>64766398760318685497656163882</X509SerialNumber></X509IssuerSerial><X509Certificate>MIIGJDCCBIygAwIBAgINANFFgmgAAAAAVn0+KjANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQGEwJTSTEcMBoGA1UEChMTUmVwdWJsaWthIFNsb3ZlbmlqYTEXMBUGA1UEYRMOVkFUU0ktMTc2NTk5NTcxETAPBgNVBAMTCFNJR09WLUNBMB4XDTIwMDUwNjA4MTE1OVoXDTI1MDUwNjA4NDE1OVowaTELMAkGA1UEBhMCU0kxGjAYBgNVBAoTEXN0YXRlIGF1dGhvcml0aWVzMRAwDgYDVQQLEwdzeXN0ZW1zMSwwFAYDVQQDEw1EYXZQb3RSYWNURVNUMBQGA1UEBRMNMTIzNzk5NzIxMDAxMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAODJIvOX5DfmBO1sL+tvRr+YjRYZo1qDlGuw4kRqvmYIhKqNRPPtkp51qO6kaqbhX4gvj5LHU03fhBje4YQSd/6j+kNPFuVKvyvyhYkk3ogLEQh9rBXxxq875MpmtewvOU2abDm0ACyvINya5g9ap0CDeDPd5hRJcQ1Kwhby2CtCT3VHc7YCamv8pZ2tZZsmk/v4GEbsGMjqSgWV3PfHcKOElzDua+hHC6ggFQx04p7RqA/veubx2XZIWYjAc725TA6CKzs0EZQMcvDV4TU5VNyyGpWpMPVeyj03cbypVp0uHoZMSechRUfiRmchT4hyBASPhkTtO4xe2NemuG5kaYMCAwEAAaOCAlswggJXMA4GA1UdDwEB/wQEAwIFoDBABgNVHSAEOTA3MDUGCisGAQQBr1kBCQkwJzAlBggrBgEFBQcCARYZaHR0cDovL3d3dy5jYS5nb3Yuc2kvY3BzLzB3BggrBgEFBQcBAQRrMGkwPgYIKwYBBQUHMAKGMmh0dHA6Ly93d3cuc2lnb3YtY2EuZ292LnNpL2NydC9zaWdvdi1jYTItY2VydHMucDdjMCcGCCsGAQUFBzABhhtodHRwOi8vb2NzcC5zaWdvdi1jYS5nb3Yuc2kwIQYDVR0RBBowGIEWbWFyamFuLmFtYnJvemljQGdvdi5zaTCCATIGA1UdHwSCASkwggElMIGxoIGuoIGrhixodHRwOi8vd3d3LnNpZ292LWNhLmdvdi5zaS9jcmwvc2lnb3YtY2EyLmNybIZ7bGRhcDovL3g1MDAuZ292LnNpL2NuPVNJR09WLUNBLG9yZ2FuaXphdGlvbklkZW50aWZpZXI9VkFUU0ktMTc2NTk5NTcsbz1SZXB1Ymxpa2ElMjBTbG92ZW5pamEsYz1TST9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0MG+gbaBrpGkwZzELMAkGA1UEBhMCU0kxHDAaBgNVBAoTE1JlcHVibGlrYSBTbG92ZW5pamExFzAVBgNVBGETDlZBVFNJLTE3NjU5OTU3MREwDwYDVQQDEwhTSUdPVi1DQTEOMAwGA1UEAxMFQ1JMMzQwEwYDVR0jBAwwCoAIRl5A5VPt/v4wEQYDVR0OBAoECEIy3tUNJ2R8MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggGBABzHlENX4aW4HGn00AmFwPYYWDJ86A5q+atRhsfBerFSR5qRpnsD4CojqyIbGxtzrT3SwR1MOqJOuIOazP03bMCzRDnNLvWeyUfmbrZ+LrTCoik5Y2teDTisuIeALDjT8avbPGrO69SkDaKIKH3zRgFAxAFziRKzJzARVs2aY2pjCkiDUJO4Ha2tTZ1xAcDZWMNDXcYlui+fVx5Ps2L71kxD5cQzVdMdP80o3IDUb8ethQ1JVdQjGswn662hfaZ1v9pIFOdxgzMp0alpuHlT3OOui/SbwxPV4YZUKRpQHYUA6aR66rEDozPfr58XNp2z0pUzT4O3Llr2mAVkeeTMOTzT5fraqr3+UpgRGaVoCUxIWo4JG9B2uZ8nv9a72ASPv9c0srenLrBHziuoVd7IndL/gIElIgABz6ygQsY3LQ24j1QkiTykOxMbHxruzPhSW0B4ISohWFSYtyz6FXQeE9k63quLXpGuEumQC1H/KeLnTRAkv+2O2v0qexCqLh7Gcg==</X509Certificate></X509Data><KeyValue><RSAKeyValue><Modulus>4Mki85fkN+YE7Wwv629Gv5iNFhmjWoOUa7DiRGq+ZgiEqo1E8+2SnnWo7qRqpuFfiC+PksdTTd+EGN7hhBJ3/qP6Q08W5Uq/K/KFiSTeiAsRCH2sFfHGrzvkyma17C85TZpsObQALK8g3JrmD1qnQIN4M93mFElxDUrCFvLYK0JPdUdztgJqa/ylna1lmyaT+/gYRuwYyOpKBZXc98dwo4SXMO5r6EcLqCAVDHTintGoD+965vHZdkhZiMBzvblMDoIrOzQRlAxy8NXhNTlU3LIalakw9V7KPTdxvKlWnS4ehkxJ5yFFR+JGZyFPiHIEBI+GRO07jF7Y16a4bmRpgw==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue></KeyValue></KeyInfo></Signature></fu:BusinessPremiseResponse></soapenv:Body></soapenv:Envelope>';
        SIPOSStoreMapping.Registered := true;
        SIPOSStoreMapping.Modify();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR SI Audit Mgt.", 'OnBeforePrintFiscalReceipt', '', false, false)]
    local procedure OnBeforePrintFiscalReceipt(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR SI Audit Mgt.", 'OnBeforeSendHttpRequestForSignZOICode', '', false, false)]
    local procedure OnBeforeSendHttpRequestForSignZOICode(var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText := '3024e56bf1ddd2e7eeb5715c6859a913';
        IsHandled := true;
    end;
}