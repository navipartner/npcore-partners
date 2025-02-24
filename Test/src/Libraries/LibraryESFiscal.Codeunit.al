codeunit 85207 "NPR Library ES Fiscal"
{
    EventSubscriberInstance = Manual;

    var
        InvoiceRegistrationState: Enum "NPR ES Inv. Registration State";
        InvoiceCancellationState: Enum "NPR ES Inv. Cancellation State";
        PEMCertificateLbl: Label '-----BEGIN CERTIFICATE-----\nMIIJKDCCBxCgAwIBAgIQcldo1BIzMxBkXgjXnpvsNTANBgkqhkiG9w0BAQsFADCB\nnTELMAkGA1UEBhMCRVMxFDASBgNVBAoMC0laRU5QRSBTLkEuMTowOAYDVQQLDDFB\nWlogWml1cnRhZ2lyaSBwdWJsaWtvYSAtIENlcnRpZmljYWRvIHB1YmxpY28gU0NB\nMTwwOgYDVQQDDDNFQUVrbyBIZXJyaSBBZG1pbmlzdHJhemlvZW4gQ0EgLSBDQSBB\nQVBQIFZhc2NhcyAoMikwHhcNMjMwNTEyMDkzNzI3WhcNMzMwNTEyMDkzNzI3WjCB\nvTELMAkGA1UEBhMCRVMxKTAnBgNVBAoMIEZJU0tBTFkgSUJFUklBIFNPQ0lFREFE\nIExJTUlUQURBMTcwNQYDVQQLDC5HYWlsdSB6aXVydGFnaXJpYSAtIENlcnRpZmlj\nYWRvIGRlIGRpc3Bvc2l0aXZvMRIwEAYDVQQLDAlCNDQ3NTIyMTAxHTAbBgNVBAsM\nFFBVTlRPIERFIEZBQ1RVUkFDSU9OMRcwFQYDVQQDDA5QUk9ELVRFU1QtMDAwMzCC\nAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMfukwMyhk76x42/FP8kRxSX\nTHpPdPfZ3XwcwmQ6kydLjCcwBqRT5M+hsvrY/Kh4rBH7T/mXP7Zd7taLdhMPghFx\nnOlQc/z2EH+bW3uBWtAiP95V5byKw/iOSGfejG0CbazxH4kkJweU9UwjPeMJJ1B7\nZpBpBslcQOJRHxs/nabxn80T9LD54LPeXps/fppYaGVSCweRqvn2ekUFfI+udI0V\n/e0pHcrSRimTKux77Og9GKPfbX2TV8n3PmRMvfH5qa517So8zt8L5dtaYFLLfyQA\nI/H0M8Dm0lUL7olnfDCRD5SODSskgnPw7ND5LFkOUcRjYPokfOqWK/puoa5cmbCs\nmDYsotrXKFKIcJ30U/1sfrMDwqafVBpz16+lAyUtzhFJQFAh1qsJjtHKGQ6AfAtS\nZ3LQbYaKMqdzfq6s8ajgB9PJUx0MC+J2me5IRz06De9cgoj2xvZ8TnLITjpkZuwM\nWwR1spSIK7BEFY7BZT+TVMrRwggQ7Yiz4nq2wcMbVN1yt3FMRi6MYDXXoh5KIvis\nsZ/u7p/S9dk+dqEIbIgJ5lY4HInKAlbCSuBvJz1W+gCN/3U77tD1Ku3B6kQgI00a\nqwtXGw2iHpQHDd8m9gxZBivCk1D1NsJHMq4DUKDq1pZ1hrKb56pef30BxHMWlC3l\nQ6HteIEZRIzcmnGyj9kVAgMBAAGjggNAMIIDPDCBxwYDVR0SBIG/MIG8hhVodHRw\nOi8vd3d3Lml6ZW5wZS5jb22BD2luZm9AaXplbnBlLmNvbaSBkTCBjjFHMEUGA1UE\nCgw+SVpFTlBFIFMuQS4gLSBDSUYgQTAxMzM3MjYwLVJNZXJjLlZpdG9yaWEtR2Fz\ndGVpeiBUMTA1NSBGNjIgUzgxQzBBBgNVBAkMOkF2ZGEgZGVsIE1lZGl0ZXJyYW5l\nbyBFdG9yYmlkZWEgMTQgLSAwMTAxMCBWaXRvcmlhLUdhc3RlaXowDgYDVR0PAQH/\nBAQDAgWgMB0GA1UdDgQWBBR2YYsQTacvEZd/osj10i0VtF7Y1zAfBgNVHSMEGDAW\ngBTAqUr3RyWH/7y1ponOgtJGqInrozCCAR4GA1UdIASCARUwggERMIIBDQYKKwYB\nBAHzOQEDAjCB/jAlBggrBgEFBQcCARYZaHR0cDovL3d3dy5pemVucGUuY29tL2Nw\nczCB1AYIKwYBBQUHAgIwgccMgcRCZXJtZWVuIG11Z2FrIGV6YWd1dHpla28gd3d3\nLml6ZW5wZS5jb20gWml1cnRhZ2lyaWFuIGtvbmZpYW50emEgaXphbiBhdXJyZXRp\nayBrb250cmF0dWEgaXJha3VycmkuTGltaXRhY2lvbmVzIGRlIGdhcmFudGlhcyBl\nbiB3d3cuaXplbnBlLmNvbSBDb25zdWx0ZSBlbCBjb250cmF0byBhbnRlcyBkZSBj\nb25maWFyIGVuIGVsIGNlcnRpZmljYWRvMB8GA1UdJQQYMBYGCCsGAQUFBwMCBgor\nBgEEAYI3CgMMMIGgBggrBgEFBQcBAQSBkzCBkDAiBggrBgEFBQcwAYYWaHR0cDov\nL29jc3AuaXplbnBlLmNvbTBqBggrBgEFBQcwAoZeaHR0cDovL3d3dy5pemVucGUu\nY29tL2NvbnRlbmlkb3MvaW5mb3JtYWNpb24vY2FzX2l6ZW5wZS9lc19jYXMvYWRq\ndW50b3MvQUFQUE5SX2NlcnRfc2hhMjU2LmNydDA6BgNVHR8EMzAxMC+gLaArhilo\ndHRwOi8vY3JsLml6ZW5wZS5jb20vY2dpLWJpbi9jcmxpbnRlcm5hMjANBgkqhkiG\n9w0BAQsFAAOCAgEAMYb6hCNF2pKRY7TT2LFW2bDCV7idPrxsTToCELF0RENUZIfh\nav0I3rexM7z/qHKFC3T7H65S8wzJ55ItM5j99cHs8iz8Kr6ktrsYHcfLBEFcnmGo\nV86XNG2UM0hYO9fsEEMJJSCEvNljfdPtJAce0JxeVxD+QMRCKnNQoFK9b3D/Hd7c\nprVNYl+u/U7NxQJqbhO7s6WJJkMnMlan9KsH7X9/+9kBC59pvDum+z0Tvo61LUqE\nlGIe12cuCPkF7rZ/vuccPfZ1xaPmMDEL0eMJ68L/SB9Ek8wxZ9yvc1JVNSxPovNK\n+VLc4Pg3ffl4AawAk25CYyeczXE/epcYnRLESw4ra8l4B/1Zxr6N9BQR3XJOXt+n\n5xJyVSy6icp5qC5+I4KmsXbDOGW7jj0A0DRMNyJAG3ovQm7JkWAvkJLRTBuOuzc3\neRs7uKeBR6iCWLEGh/f+iRGJjoePbfCjOwCG/eQMalVlAP67uBykkmPzDd405s3e\nLDy+f5PFh2dN56DjOzyurSDSlNb6tsaD1hkD/glZK8HnnfTc/5eXsOGh9hH/xQ6N\ninmlf5NT4wfUSzmIAexBmIKNCbBukketavZxePDRGmTxirQOrWBxQfm84plWC7WS\nGuKjGhaoRqUM9WWF4BU+1tLq+9z2iE8WOibSOBHeRHxUYR1FDpi3ygSPpJU=\n-----END CERTIFICATE-----\n', Locked = true;

    internal procedure CreateAuditProfileAndESSetups(var POSAuditProfile: Record "NPR POS Audit Profile"; var VATPostingSetup: Record "VAT Posting Setup"; var POSUnit: Record "NPR POS Unit")
    begin
        InsertPOSAuditProfile(POSAuditProfile);
        AllowGapsInNoSeries(POSAuditProfile."Sales Ticket No. Series");

        EnableESFiscalization();

        UpdatePOSAuditProfileOnPOSUnit(POSUnit, POSAuditProfile.Code);

        SetVATPctOnVATPostingSetup(VATPostingSetup, 21);
        InsertESReturnReasonMapping();
    end;

    local procedure InsertPOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        ESAuditMgt: Codeunit "NPR ES Audit Mgt.";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := ESAuditMgt.HandlerCode();
        POSAuditProfile."Audit Handler" := CopyStr(ESAuditMgt.HandlerCode(), 1, MaxStrLen(POSAuditProfile."Audit Handler"));
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Require Item Return Reason" := true;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile.Insert();
    end;

    local procedure AllowGapsInNoSeries(SeriesCode: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", SeriesCode);
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
    end;

    internal procedure EnableESFiscalization()
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        TestFiskalyAPIURLLbl: Label 'https://test.es.sign.fiskaly.com/api/v1/', Locked = true;
        LiveFiskalyAPIURLLbl: Label 'https://live.es.sign.fiskaly.com/api/v1/', Locked = true;
        DummyInvoiceDescriptionLbl: Label 'Dummy Invoice Description Testing', Locked = true;
    begin
        if not ESFiscalizationSetup.Get() then
            ESFiscalizationSetup.Insert();

        ESFiscalizationSetup."ES Fiscal Enabled" := true;
        ESFiscalizationSetup."Test Fiskaly API URL" := TestFiskalyAPIURLLbl;
        ESFiscalizationSetup."Live Fiskaly API URL" := LiveFiskalyAPIURLLbl;
        ESFiscalizationSetup."Simplified Invoice Limit" := 3000;
        ESFiscalizationSetup."Invoice Description" := CopyStr(DummyInvoiceDescriptionLbl, 1, MaxStrLen(ESFiscalizationSetup."Invoice Description")); // setting it as label, since allowed value here must be according to pattern which value usually fails validation when it is generated randomly
        ESFiscalizationSetup.Modify();
    end;

    local procedure UpdatePOSAuditProfileOnPOSUnit(var POSUnit: Record "NPR POS Unit"; POSAuditProfileCode: Code[20])
    begin
        POSUnit."POS Audit Profile" := POSAuditProfileCode;
        POSUnit.Modify();
    end;

    local procedure SetVATPctOnVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATPct: Decimal)
    begin
        VATPostingSetup."VAT %" := VATPct;
        VATPostingSetup.Modify();
    end;

    local procedure InsertESReturnReasonMapping()
    var
        ReturnReason: Record "Return Reason";
        ESReturnReasonMapping: Record "NPR ES Return Reason Mapping";
    begin
        ReturnReason.FindSet();
        repeat
            if not ESReturnReasonMapping.Get(ReturnReason.Code) then begin
                ESReturnReasonMapping.Init();
                ESReturnReasonMapping."Return Reason Code" := ReturnReason.Code;
                ESReturnReasonMapping."ES Return Reason" := ESReturnReasonMapping."ES Return Reason"::CORRECTION_1;
                ESReturnReasonMapping.Insert();
            end;
        until ReturnReason.Next() = 0;
    end;

    internal procedure CreateESOrganization(var ESOrganization: Record "NPR ES Organization")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ESOrganization.Init();
        ESOrganization.Validate(
            Code,
            CopyStr(
                LibraryUtility.GenerateRandomCode(ESOrganization.FieldNo(Code), Database::"NPR ES Organization"),
                1,
                LibraryUtility.GetFieldLength(Database::"NPR ES Organization", ESOrganization.FieldNo(Code))));
        ESOrganization.Validate(Description, ESOrganization.Code);  // Validating Description as Code because value is not important.
        ESOrganization.Insert(true);
    end;

    internal procedure CreateESOrganization(var ESOrganization: Record "NPR ES Organization"; TaxpayerTeritory: Enum "NPR ES Taxpayer Territory"; TaxpayerType: Enum "NPR ES Taxpayer Type")
    begin
        CreateESOrganization(ESOrganization);
        CreateTaxpayerForESOrganization(ESOrganization, TaxpayerTeritory, TaxpayerType);
    end;

    local procedure CreateTaxpayerForESOrganization(var ESOrganization: Record "NPR ES Organization"; TaxpayerTeritory: Enum "NPR ES Taxpayer Territory"; TaxpayerType: Enum "NPR ES Taxpayer Type")
    begin
        ESOrganization."Taxpayer Created" := true;
        ESOrganization."Taxpayer Territory" := TaxpayerTeritory;
        ESOrganization."Taxpayer Type" := TaxpayerType;
        ESOrganization.Modify(true);
    end;

    internal procedure CreateESSigner(var ESSigner: Record "NPR ES Signer")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ESSigner.Init();
        ESSigner.Validate(
            Code,
            CopyStr(
                LibraryUtility.GenerateRandomCode(ESSigner.FieldNo(Code), Database::"NPR ES Signer"),
                1,
                LibraryUtility.GetFieldLength(Database::"NPR ES Signer", ESSigner.FieldNo(Code))));
        ESSigner.Validate(Description, ESSigner.Code);  // Validating Description as Code because value is not important.
        ESSigner.Insert(true);
    end;

    internal procedure CreateESSigner(var ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20])
    begin
        CreateESSigner(ESSigner);
        EnableESSigner(ESSigner, ESOrganizationCode);
    end;

    internal procedure EnableESSigner(var ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20])
    begin
        ESSigner.Validate("ES Organization Code", ESOrganizationCode);
        ESSigner.Validate(State, ESSigner.State::ENABLED);
        ESSigner.Validate("Certificate Serial Number", Format(CreateGuid(), 0, 4));
        ESSigner.Validate("Certificate Expires At", CurrentDateTime() + 1000);
        ESSigner.Modify(true);
    end;

    internal procedure CreateESClient(var ESClient: Record "NPR ES Client"; POSUnitNo: Code[10])
    begin
        ESClient.Init();
        ESClient.Validate("POS Unit No.", POSUnitNo);
        ESClient.Validate(Description, POSUnitNo);
        ESClient.Insert(true);
    end;

    internal procedure CreateESClient(var ESClient: Record "NPR ES Client"; ESSigner: Record "NPR ES Signer"; POSUnitNo: Code[10]; ESOrganizationCode: Code[20])
    begin
        CreateESClient(ESClient, POSUnitNo);
        EnableESClient(ESClient, ESSigner, ESOrganizationCode);
    end;

    internal procedure EnableESClient(var ESClient: Record "NPR ES Client"; ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20])
    begin
        ESClient.Validate("ES Organization Code", ESOrganizationCode);
        ESClient.Validate("ES Signer Code", ESSigner.Code);
        ESClient.Validate("ES Signer Id", Format(ESSigner.SystemId, 0, 4));
        ESClient.Validate(State, ESClient.State::ENABLED);
        ESClient.Validate("Invoice No. Series", CreateNumberSeries());
        ESClient.Validate("Complete Invoice No. Series", CreateNumberSeries());
        ESClient.Validate("Correction Invoice No. Series", CreateNumberSeries());
        ESClient.Modify(true);
    end;

    local procedure CreateNumberSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    internal procedure SetInvoiceRegistrationState(NewInvoiceRegistrationState: Enum "NPR ES Inv. Registration State")
    begin
        InvoiceRegistrationState := NewInvoiceRegistrationState;
    end;

    internal procedure SetInvoiceCancellationState(NewInvoiceCancellationState: Enum "NPR ES Inv. Cancellation State")
    begin
        InvoiceCancellationState := NewInvoiceCancellationState;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSetAuthorizationOnPrepareHttpRequest', '', false, false)]
    local procedure HandleOnBeforeSetAuthorizationOnPrepareHttpRequest(var RequestHeaders: HttpHeaders; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateInvoice', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCreateInvoice(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "content": {' +
            '       "client": {' +
            '           "id": "' + Format(ESPOSAuditLogAuxInfo."ES Client Id", 0, 4) + '"' +
            '       },' +
            '       "compliance": {' +
            '           "code": {' +
            '               "image": {' +
            '                   "data": "iVBORw0KGgoAAAANSUhEUgAAAC0AAAAtEAAAAABP4WEFAAACeUlEQVR4nJxXWa7kIAw0Efe/MqMMcmpz/zyk7gQweKmyIbuknfP+r4X+WncM7R1piXfuSvDobbu3w5Ytemd4saprpf7eez338Ta16ZwWgz1XFRTdn9qKvSwgk8O3d0fRh2fsa03xhfsY0x7k51lfv6elasO1tkfaXR7l9YPtqvmvP247tXBkO+6AETJ4TtZXERC+GLxwznZo8FR6XomngWGt4Mfb2gu1C/4gzSDzUfIO6FLvqfp+B/vzKTphT4alDH0NUDOck4uCoRYnT3X0HHgyzdU0oCxVBdw0lNmTpEYokMJwU6uiBo15Uum8uuWuJm8zgCrzOGic0rwR5DyuCiXNM4wzcEy9yScn4Gdqak9Y007n1ATmniuAgoUzxPOvvkqJ+VJAskhphp4om5kNLmFJkyHQzZL/mvys6OEAwB1whbfx5G4ZDVGv2JoeUJSjjsY5qO2KzP23Oltx9+Aj1hVMqwtw/uYx3h0gz1PGimp2nh96xeHqcagAT+dKSUXZVb4FyhLDquHxbbjf0g9zAwcs+zHlHB/JE3v+q9Rtqvz0/nX+qBwH6ZvLcukJINVs6GvJwurN5Z6ddeuBg8Y2U+bzKmGpyjszoPV/DpAxqowhem3H27FDKg+ykit01cPJwdcUjyYTsYOCCxAT9SsAepdOrjIbGOrciue+VD92SVCs3e0TB5lX7Ts2fASpXemVeuiQYtX2qqf26ZeKHnTgD38HEYOcfFPGcaat5dyZrK7+TPKLORRF8lrE1TCdeyqaU6kVp2rOWWfUWsPHXQHjpaFpWuWnH1vbyuIL7Hx3+qkAsC9+n+YTNYpq2e2UgUvrNQC59l8AAAD//xMGQH883VS1AAAAAElFTkSuQmCC",' +
            '                   "format": "image/png",' +
            '                   "measurements": {' +
            '                       "height": 45,' +
            '                       "unit": "px",' +
            '                       "width": 45' +
            '                   }' +
            '               },' +
            '           "type": "QR_CODE"' +
            '           },' +
            '           "tbai": "TBAI-B44752210-160824-vL2IrjAmjWpmr-238",' +
            '           "url": "https://tbai.prep.gipuzkoa.eus/qr/?id=TBAI-B44752210-160824-vL2IrjAmjWpmr-238&s=&nf=E-172380704840&i=64.97&cr=166"' +
            '       },' +
            '       "data": "",' + // this is irrelevant for us at the moment, so we can leave it blank
            '       "id": "67fcf146-5626-45f3-b6b4-0a32da12f89f",' +
            '       "issued_at": "16-08-2024 11:17:28",' +
            '       "signer": {' +
            '           "id": "' + ESPOSAuditLogAuxInfo."ES Signer Id" + '"' +
            '       },' +
            '       "state": "ISSUED",' +
            '       "transmission": {' +
            '           "cancellation": "NOT_CANCELLED",' +
            '           "registration": "' + Enum::"NPR ES Inv. Registration State".Names().Get(Enum::"NPR ES Inv. Registration State".Ordinals().IndexOf(InvoiceRegistrationState.AsInteger())) + '"' +
            '       },' +
            '       "validations": []' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_client_code": "' + ESPOSAuditLogAuxInfo."POS Unit No." + '",' +
            '       "bc_signer_code": "' + ESPOSAuditLogAuxInfo."ES Signer Code" + '"' +
            '   }' +
            '}';

        sender.PopulateESPOSAuditLogAuxInfoForCreateInvoice(ESPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveInvoice', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveInvoice(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "content": {' +
            '       "client": {' +
            '           "id": "' + Format(ESPOSAuditLogAuxInfo."ES Client Id", 0, 4) + '"' +
            '       },' +
            '       "compliance": {' +
            '           "code": {' +
            '               "image": {' +
            '                   "data": "iVBORw0KGgoAAAANSUhEUgAAAC0AAAAtEAAAAABP4WEFAAACeUlEQVR4nJxXWa7kIAw0Efe/MqMMcmpz/zyk7gQweKmyIbuknfP+r4X+WncM7R1piXfuSvDobbu3w5Ytemd4saprpf7eez338Ta16ZwWgz1XFRTdn9qKvSwgk8O3d0fRh2fsa03xhfsY0x7k51lfv6elasO1tkfaXR7l9YPtqvmvP247tXBkO+6AETJ4TtZXERC+GLxwznZo8FR6XomngWGt4Mfb2gu1C/4gzSDzUfIO6FLvqfp+B/vzKTphT4alDH0NUDOck4uCoRYnT3X0HHgyzdU0oCxVBdw0lNmTpEYokMJwU6uiBo15Uum8uuWuJm8zgCrzOGic0rwR5DyuCiXNM4wzcEy9yScn4Gdqak9Y007n1ATmniuAgoUzxPOvvkqJ+VJAskhphp4om5kNLmFJkyHQzZL/mvys6OEAwB1whbfx5G4ZDVGv2JoeUJSjjsY5qO2KzP23Oltx9+Aj1hVMqwtw/uYx3h0gz1PGimp2nh96xeHqcagAT+dKSUXZVb4FyhLDquHxbbjf0g9zAwcs+zHlHB/JE3v+q9Rtqvz0/nX+qBwH6ZvLcukJINVs6GvJwurN5Z6ddeuBg8Y2U+bzKmGpyjszoPV/DpAxqowhem3H27FDKg+ykit01cPJwdcUjyYTsYOCCxAT9SsAepdOrjIbGOrciue+VD92SVCs3e0TB5lX7Ts2fASpXemVeuiQYtX2qqf26ZeKHnTgD38HEYOcfFPGcaat5dyZrK7+TPKLORRF8lrE1TCdeyqaU6kVp2rOWWfUWsPHXQHjpaFpWuWnH1vbyuIL7Hx3+qkAsC9+n+YTNYpq2e2UgUvrNQC59l8AAAD//xMGQH883VS1AAAAAElFTkSuQmCC",' +
            '                   "format": "image/png",' +
            '                   "measurements": {' +
            '                       "height": 45,' +
            '                       "unit": "px",' +
            '                       "width": 45' +
            '                   }' +
            '               },' +
            '           "type": "QR_CODE"' +
            '           },' +
            '           "tbai": "TBAI-B44752210-160824-vL2IrjAmjWpmr-238",' +
            '           "url": "https://tbai.prep.gipuzkoa.eus/qr/?id=TBAI-B44752210-160824-vL2IrjAmjWpmr-238&s=&nf=E-172380704840&i=64.97&cr=166"' +
            '       },' +
            '       "data": "",' + // this is irrelevant for us at the moment, so we can leave it blank
            '       "id": "67fcf146-5626-45f3-b6b4-0a32da12f89f",' +
            '       "issued_at": "16-08-2024 11:17:28",' +
            '       "signer": {' +
            '           "id": "' + ESPOSAuditLogAuxInfo."ES Signer Id" + '"' +
            '       },' +
            '       "state": "ISSUED",' +
            '       "transmission": {' +
            '           "cancellation": "NOT_CANCELLED",' +
            '           "registration": "' + Enum::"NPR ES Inv. Registration State".Names().Get(Enum::"NPR ES Inv. Registration State".Ordinals().IndexOf(InvoiceRegistrationState.AsInteger())) + '"' +
            '       },' +
            '       "validations": []' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_client_code": "' + ESPOSAuditLogAuxInfo."POS Unit No." + '",' +
            '       "bc_signer_code": "' + ESPOSAuditLogAuxInfo."ES Signer Code" + '"' +
            '   }' +
            '}';

        sender.PopulateESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForCancelInvoice', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCancelInvoice(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
        ResponseText :=
            '{' +
            '   "content": {' +
            '       "client": {' +
            '           "id": "' + Format(ESPOSAuditLogAuxInfo."ES Client Id", 0, 4) + '"' +
            '       },' +
            '       "compliance": {' +
            '           "code": {' +
            '               "image": {' +
            '                   "data": "iVBORw0KGgoAAAANSUhEUgAAAC0AAAAtEAAAAABP4WEFAAACeUlEQVR4nJxXWa7kIAw0Efe/MqMMcmpz/zyk7gQweKmyIbuknfP+r4X+WncM7R1piXfuSvDobbu3w5Ytemd4saprpf7eez338Ta16ZwWgz1XFRTdn9qKvSwgk8O3d0fRh2fsa03xhfsY0x7k51lfv6elasO1tkfaXR7l9YPtqvmvP247tXBkO+6AETJ4TtZXERC+GLxwznZo8FR6XomngWGt4Mfb2gu1C/4gzSDzUfIO6FLvqfp+B/vzKTphT4alDH0NUDOck4uCoRYnT3X0HHgyzdU0oCxVBdw0lNmTpEYokMJwU6uiBo15Uum8uuWuJm8zgCrzOGic0rwR5DyuCiXNM4wzcEy9yScn4Gdqak9Y007n1ATmniuAgoUzxPOvvkqJ+VJAskhphp4om5kNLmFJkyHQzZL/mvys6OEAwB1whbfx5G4ZDVGv2JoeUJSjjsY5qO2KzP23Oltx9+Aj1hVMqwtw/uYx3h0gz1PGimp2nh96xeHqcagAT+dKSUXZVb4FyhLDquHxbbjf0g9zAwcs+zHlHB/JE3v+q9Rtqvz0/nX+qBwH6ZvLcukJINVs6GvJwurN5Z6ddeuBg8Y2U+bzKmGpyjszoPV/DpAxqowhem3H27FDKg+ykit01cPJwdcUjyYTsYOCCxAT9SsAepdOrjIbGOrciue+VD92SVCs3e0TB5lX7Ts2fASpXemVeuiQYtX2qqf26ZeKHnTgD38HEYOcfFPGcaat5dyZrK7+TPKLORRF8lrE1TCdeyqaU6kVp2rOWWfUWsPHXQHjpaFpWuWnH1vbyuIL7Hx3+qkAsC9+n+YTNYpq2e2UgUvrNQC59l8AAAD//xMGQH883VS1AAAAAElFTkSuQmCC",' +
            '                   "format": "image/png",' +
            '                   "measurements": {' +
            '                       "height": 45,' +
            '                       "unit": "px",' +
            '                       "width": 45' +
            '                   }' +
            '               },' +
            '           "type": "QR_CODE"' +
            '           },' +
            '           "tbai": "TBAI-B44752210-160824-vL2IrjAmjWpmr-238",' +
            '           "url": "https://tbai.prep.gipuzkoa.eus/qr/?id=TBAI-B44752210-160824-vL2IrjAmjWpmr-238&s=&nf=E-172380704840&i=64.97&cr=166"' +
            '       },' +
            '       "data": "",' + // this is irrelevant for us at the moment, so we can leave it blank
            '       "id": "67fcf146-5626-45f3-b6b4-0a32da12f89f",' +
            '       "issued_at": "16-08-2024 11:17:28",' +
            '       "signer": {' +
            '           "id": "' + ESPOSAuditLogAuxInfo."ES Signer Id" + '"' +
            '       },' +
            '       "state": "CANCELLED",' +
            '       "transmission": {' +
            '           "cancellation": "' + Enum::"NPR ES Inv. Cancellation State".Names().Get(Enum::"NPR ES Inv. Cancellation State".Ordinals().IndexOf(InvoiceCancellationState.AsInteger())) + '",' +
            '           "registration": "' + Enum::"NPR ES Inv. Registration State".Names().Get(Enum::"NPR ES Inv. Registration State".Ordinals().IndexOf(InvoiceRegistrationState.AsInteger())) + '"' +
            '       },' +
            '       "validations": []' +
            '   },' +
            '   "metadata": {' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_client_code": "' + ESPOSAuditLogAuxInfo."POS Unit No." + '",' +
            '       "bc_signer_code": "' + ESPOSAuditLogAuxInfo."ES Signer Code" + '"' +
            '   }' +
            '}';

        sender.PopulateESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateTaxpayer', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCreateTaxpayer(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESOrganization: Record "NPR ES Organization"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '       "issuer": {' +
            '           "legal_name": "' + CompanyInformation.Name + '",' +
            '           "tax_number": "' + CompanyInformation."VAT Registration No." + '"' +
            '       },' +
            '      "territory": "' + Enum::"NPR ES Taxpayer Territory".Names().Get(Enum::"NPR ES Taxpayer Territory".Ordinals().IndexOf(ESOrganization."Taxpayer Territory".AsInteger())) + '",' +
            '      "type": "' + Enum::"NPR ES Taxpayer Type".Names().Get(Enum::"NPR ES Taxpayer Type".Ordinals().IndexOf(Enum::"NPR ES Taxpayer Type"::COMPANY.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESOrganization.Code + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESOrganization.Description + '"' +
            '   }' +
            '}';

        sender.PopulateOrganization(ESOrganization, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveTaxpayer', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveTaxpayer(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESOrganization: Record "NPR ES Organization"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '       "issuer": {' +
            '           "legal_name": "' + CompanyInformation.Name + '",' +
            '           "tax_number": "' + CompanyInformation."VAT Registration No." + '"' +
            '       },' +
            '      "territory": "' + Enum::"NPR ES Taxpayer Territory".Names().Get(Enum::"NPR ES Taxpayer Territory".Ordinals().IndexOf(ESOrganization."Taxpayer Territory".AsInteger())) + '",' +
            '      "type": "' + Enum::"NPR ES Taxpayer Type".Names().Get(Enum::"NPR ES Taxpayer Type".Ordinals().IndexOf(Enum::"NPR ES Taxpayer Type"::COMPANY.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESOrganization.Code + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESOrganization.Description + '"' +
            '   }' +
            '}';

        sender.PopulateOrganization(ESOrganization, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateSigner', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCreateSigner(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESSigner: Record "NPR ES Signer"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '       "certificate": {' +
            '           "expires_at": "12-05-2033 09:37:27",' +
            '           "serial_number": "725768D412333310645E08D79E9BEC35",' +
            '           "x509_pem": "' + PEMCertificateLbl + '"' +
            '       },' +
            '      "id": "' + Format(ESSigner.SystemId, 0, 4).ToLower() + '",' +
            '      "state": "' + Enum::"NPR ES Signer State".Names().Get(Enum::"NPR ES Signer State".Ordinals().IndexOf(Enum::"NPR ES Signer State"::ENABLED.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESSigner.Code + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESSigner.Description + '"' +
            '   }' +
            '}';

        sender.PopulateSigner(ESSigner, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForUpdateSigner', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForUpdateSigner(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESSigner: Record "NPR ES Signer"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '       "certificate": {' +
            '           "expires_at": "12-05-2033 09:37:27",' +
            '           "serial_number": "725768D412333310645E08D79E9BEC35",' +
            '           "x509_pem": "' + PEMCertificateLbl + '"' +
            '       },' +
            '      "id": "' + Format(ESSigner.SystemId, 0, 4).ToLower() + '",' +
            '      "state": "' + Enum::"NPR ES Signer State".Names().Get(Enum::"NPR ES Signer State".Ordinals().IndexOf(Enum::"NPR ES Signer State"::DISABLED.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESSigner.Code + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESSigner.Description + '"' +
            '   }' +
            '}';

        sender.PopulateSigner(ESSigner, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveSigner', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveSigner(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESSigner: Record "NPR ES Signer"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '       "certificate": {' +
            '           "expires_at": "12-05-2033 09:37:27",' +
            '           "serial_number": "725768D412333310645E08D79E9BEC35",' +
            '           "x509_pem": "' + PEMCertificateLbl + '"' +
            '       },' +
            '      "id": "' + Format(ESSigner.SystemId, 0, 4).ToLower() + '",' +
            '      "state": "' + Enum::"NPR ES Signer State".Names().Get(Enum::"NPR ES Signer State".Ordinals().IndexOf(Enum::"NPR ES Signer State"::DEFECTIVE.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESSigner.Code + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESSigner.Description + '"' +
            '   }' +
            '}';

        sender.PopulateSigner(ESSigner, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForCreateClient', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForCreateClient(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESClient: Record "NPR ES Client"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '      "id": "' + Format(ESClient.SystemId, 0, 4).ToLower() + '",' +
            '       "signer": {' +
            '           "id": "' + Format(ESClient."ES Signer Id", 0, 4).ToLower() + '"' +
            '       },' +
            '      "state": "' + Enum::"NPR ES Signer State".Names().Get(Enum::"NPR ES Signer State".Ordinals().IndexOf(Enum::"NPR ES Signer State"::ENABLED.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESClient."POS Unit No." + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESClient.Description + '"' +
            '   }' +
            '}';

        sender.PopulateClient(ESClient, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForUpdateClient', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForUpdateClient(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESClient: Record "NPR ES Client"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '      "id": "' + Format(ESClient.SystemId, 0, 4).ToLower() + '",' +
            '       "signer": {' +
            '           "id": "' + Format(ESClient."ES Signer Id", 0, 4).ToLower() + '"' +
            '       },' +
            '      "state": "' + Enum::"NPR ES Signer State".Names().Get(Enum::"NPR ES Signer State".Ordinals().IndexOf(Enum::"NPR ES Signer State"::DISABLED.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESClient."POS Unit No." + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESClient.Description + '"' +
            '   }' +
            '}';

        sender.PopulateClient(ESClient, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR ES Fiskaly Communication", 'OnBeforeSendHttpRequestForRetrieveClient', '', false, false)]
    local procedure HandleOnBeforeSendHttpRequestForRetrieveClient(sender: Codeunit "NPR ES Fiskaly Communication"; var ResponseText: Text; var ESClient: Record "NPR ES Client"; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        ResponseText :=
            '{' +
            '   "content": {' +
            '      "id": "' + Format(ESClient.SystemId, 0, 4).ToLower() + '",' +
            '       "signer": {' +
            '           "id": "' + Format(ESClient."ES Signer Id", 0, 4).ToLower() + '"' +
            '       },' +
            '      "state": "' + Enum::"NPR ES Signer State".Names().Get(Enum::"NPR ES Signer State".Ordinals().IndexOf(Enum::"NPR ES Signer State"::DISABLED.AsInteger())) + '"' +
            '   },' +
            '   "metadata": {' +
            '       "bc_code": "' + ESClient."POS Unit No." + '",' +
            '       "bc_company_name": "' + CompanyName() + '",' +
            '       "bc_description": "' + ESClient.Description + '"' +
            '   }' +
            '}';

        sender.PopulateClient(ESClient, ResponseText);
        IsHandled := true;
    end;
}
