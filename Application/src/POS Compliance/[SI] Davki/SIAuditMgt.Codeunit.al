codeunit 6151546 "NPR SI Audit Mgt."
{
    Access = Internal;

    var
        SIFiscalSetup: Record "NPR SI Fiscalization Setup";
        Enabled: Boolean;
        Initialized: Boolean;
        CAPTION_CERT_SUCCESS: Label 'Certificate with thumbprint %1 was uploaded successfully';
        CAPTION_OVERWRITE_CERT: Label 'Are you sure you want to overwrite the existing certificate?';
        ERROR_MISSING_KEY: Label 'The selected certificate does not contain the private key';

    #region SI Fiscal - POS Handling Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsSIAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddSIAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSStore(var Rec: Record "NPR POS Store"; var xRec: Record "NPR POS Store"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSStoreIfAlreadyUsed(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSUnit(var Rec: Record "NPR POS Unit"; var xRec: Record "NPR POS Unit"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSUnitIfAlreadyUsed(xRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        CheckAreDataSetAndAccordingToCompliance(FrontEnd);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale");
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        SIFiscalThermalPrint: Codeunit "NPR SI Fiscal Thermal Print";
        SITaxCommunicationMgt: Codeunit "NPR SI Tax Communication Mgt.";
        IsHandled: Boolean;
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;
        if not IsSIAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        Sender.GetLastSalePOSEntry(POSEntry);

        if not SIPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;

        InsertPreNumberedInvoiceBookToAudit(SalePOS, SIPOSAuditLogAuxInfo);

        if SIPOSAuditLogAuxInfo."Return Receipt No." = '' then
            SITaxCommunicationMgt.CreateNormalSale(SIPOSAuditLogAuxInfo, false, false)
        else
            SITaxCommunicationMgt.CreateNormalSale(SIPOSAuditLogAuxInfo, true, false);

        Commit();
        OnBeforePrintFiscalReceipt(IsHandled);
        if IsHandled then
            exit;
        SIFiscalThermalPrint.PrintReceipt(SIPOSAuditLogAuxInfo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure OnBeforeHendleReverse(var SalesTicketNo: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
    begin
        if not IsSIFiscalActive() then
            exit;

        SIPOSAuditLogAuxInfo.SetLoadFields("Receipt No.", "POS Entry No.");
        POSEntry.SetLoadFields("Entry No.", "Document No.");

        SIPOSAuditLogAuxInfo.SetRange("Receipt No.", SalesTicketNo);
        if not SIPOSAuditLogAuxInfo.FindFirst() then
            exit;
        POSEntry.SetRange("Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        if not POSEntry.FindFirst() then
            exit;
        SalesTicketNo := POSEntry."Document No.";
    end;

    #endregion

    #region SI Fiscal - Aux and Mapping Tables Cleanup

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalespersonPurchaser_OnAfterDeleteEvent(var Rec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        SIAuxSalespPurch: Record "NPR SI Aux Salesperson/Purch.";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsSIFiscalActive() then
            exit;
        if SIAuxSalespPurch.Get(Rec.SystemId) then
            SIAuxSalespPurch.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnAfterDeleteEvent', '', false, false)]
    local procedure POSStore_OnAfterDeleteEvent(var Rec: Record "NPR POS Store"; RunTrigger: Boolean)
    var
        SIPOSStoreMapping: Record "NPR SI POS Store Mapping";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsSIFiscalActive() then
            exit;
        if SIPOSStoreMapping.Get(Rec.Code) then
            SIPOSStoreMapping.Delete();
    end;

    #endregion

    #region SI Fiscal - Audit Profile Mgt
    local procedure AddSIAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    local procedure HandleOnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsSIAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertSIPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure CheckAreDataSetAndAccordingToCompliance(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        SIAuxSalespPurch: Record "NPR SI Aux Salesperson/Purch.";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        MissingTaxNumberErr: Label 'Salesperson Tax Number must have a value in Salesperson/Purchaser. It cannot be zero or empty.';
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsSIAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSSetup.GetSalespersonRecord(SalespersonPurchaser);
        SIAuxSalespPurch.ReadSIAuxSalespersonFields(SalespersonPurchaser);
        if SIAuxSalespPurch."NPR SI Salesperson Tax Number" = 0 then
            Error(MissingTaxNumberErr);
    end;

    local procedure InsertSIPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        POSRMALine: Record "NPR POS RMA Line";
        SIAuxSalespPurch: Record "NPR SI Aux Salesperson/Purch.";
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        POSEntry.CalcFields("Payment Amount");
        SIPOSAuditLogAuxInfo.Init();
        SIPOSAuditLogAuxInfo."Audit Entry Type" := SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        SIPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        SIPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        SIPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        SIPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        SIPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        SIPOSAuditLogAuxInfo."Log Timestamp" := POSEntry."Ending Time";
        SIPOSAuditLogAuxInfo."Total Amount" := POSEntry."Amount Incl. Tax";
        SIPOSAuditLogAuxInfo."Payment Amount" := POSEntry."Payment Amount";
        SIPOSAuditLogAuxInfo."Returns Amount" := POSEntry."Item Returns (LCY)";

        case POSEntry."Return Sales Quantity" of
            0:
                SIPOSAuditLogAuxInfo."Transaction Type" := "NPR SI Transaction Type"::Sale;
            else begin
                POSRMALine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if POSRMALine.FindSet() then
                    SIPOSAuditLogAuxInfo."Return Receipt No." := POSRMALine."Sales Ticket No.";
                SIPOSAuditLogAuxInfo."Transaction Type" := "NPR SI Transaction Type"::Return;
            end;
        end;

        SalespersonPurchaser.Get(POSEntry."Salesperson Code");
        SIAuxSalespPurch.ReadSIAuxSalespersonFields(SalespersonPurchaser);
        SIAuxSalespPurch.TestField("NPR SI Salesperson Tax Number");
        SIPOSAuditLogAuxInfo."Cashier ID" := SIAuxSalespPurch."NPR SI Salesperson Tax Number";

        SIPOSAuditLogAuxInfo.Insert(true);
        CalculateAndSignZOI(SIPOSAuditLogAuxInfo);
    end;

    local procedure InsertPreNumberedInvoiceBookToAudit(SalePOS: Record "NPR POS Sale"; var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SIPOSSale: Record "NPR SI POS Sale";
    begin
        if not SIPOSSale.Get(SalePOS.SystemId) then
            exit;

        SIPOSAuditLogAuxInfo."Sales Book Invoice No." := SIPOSSale."SI Set Number";
        SIPOSAuditLogAuxInfo."Sales Book Serial No." := SIPOSSale."SI Serial Number";
        SIPOSAuditLogAuxInfo.Modify();
    end;

    #endregion

    #region SI Fiscal - Procedures/Helper Functions
    internal procedure IsSIFiscalActive(): Boolean
    begin
        if not SIFiscalSetup.Get() then begin
            SIFiscalSetup.Init();
            SIFiscalSetup.Insert();
        end;
        exit(SIFiscalSetup."Enable SI Fiscal");
    end;

    local procedure IsSIAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);
        if Initialized then
            exit(Enabled);
        Initialized := true;
        Enabled := true;
        exit(true);
    end;

    internal procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'SI_DAVKI', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        SIFiscalizationSetup: Page "NPR SI Fiscalization Setup";
    begin
        SIFiscalizationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - SI POS Audit Log Aux. Info table caption';
    begin
        if not IsSIFiscalActive() then
            exit;

        SIPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not SIPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, SIPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - SI POS Audit Log Aux. Info table caption';
    begin
        if not IsSIAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        SIPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not SIPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", SIPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure CalculateAndSignZOI(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        BaseValue: Text;
        ResponseText: Text;
    begin
        FormatBaseZOIValue(BaseValue, SIPOSAuditLogAuxInfo);
        if not SignZOICode(BaseValue, ResponseText) then
            exit;
#pragma warning disable AA0139
        SIPOSAuditLogAuxInfo."ZOI Code" := ResponseText;
#pragma warning restore AA0139
        SIPOSAuditLogAuxInfo.Modify();
    end;

    local procedure FormatBaseZOIValue(var BaseValue: Text; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        CompanyInformation: Record "Company Information";
        BaseValueFormatLbl: Label '%1%2%3%4%5%6%7', Locked = true;
    begin
        CompanyInformation.Get();
        BaseValue := StrSubstNo(BaseValueFormatLbl, CompanyInformation."VAT Registration No.", Format(SIPOSAuditLogAuxInfo."Entry Date", 8, '<Day,2><Month,2><Year4>'), Format(SIPOSAuditLogAuxInfo."Log Timestamp", 6, '<Hours,2><Minutes,2><Seconds,2>'), SIPOSAuditLogAuxInfo."Receipt No.", SIPOSAuditLogAuxInfo."POS Store Code", SIPOSAuditLogAuxInfo."POS Unit No.", Format(SIPOSAuditLogAuxInfo."Total Amount"));
        BaseValue := DelChr(BaseValue, '=', ' :.-,');
    end;

    local procedure FormatCertificateSubjectInfo(var X509Certificate2: Codeunit X509Certificate2; Base64Cert: Text): Text
    var
        StartPosition: Integer;
        CertificateSubject: Text;
    begin
        X509Certificate2.GetCertificateSubject(Base64Cert, SIFiscalSetup."Signing Certificate Password", CertificateSubject);
        StartPosition := StrPos(CertificateSubject, 'OU=');
        CertificateSubject := CopyStr(CertificateSubject, StartPosition, 11);
        CertificateSubject := DelChr(CertificateSubject, '=', 'OU=');
        exit(CertificateSubject);
    end;

    #endregion

    #region SI Fiscal - XML Signing

    internal procedure SignAndSendXML(MethodType: Text; BaseValue: Text; var ResponseText: Text): Boolean
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        InStr: InStream;
        RequestMessageLbl: Label '{"certificateBase64": "%1","certificatePass": "%2","methodType": "%3", "URLToSend": "%4", "contentToSign": "%5"}', Locked = true;
        SignAndSendXMLAzureFunctionURLLbl: Label 'https://slocompilance.azurewebsites.net/api/SignAndSend?code=75lf3yGMPXq7962epcp5E90V-N6EXp1mWN9qnArngVilAzFuCNEAtQ==', Locked = true;
        CertBase64: Text;
        Url: Text;
        XMLDocText: Text;
    begin
        SIFiscalSetup.SetAutoCalcFields("Signing Certificate");
        SIFiscalSetup.Get();

        SIFiscalSetup.TestField("Signing Certificate");
        SIFiscalSetup.TestField("Signing Certificate Password");

        SIFiscalSetup."Signing Certificate".CreateInStream(InStr);
        InStr.ReadText(CertBase64);
        XMLDocText := StrSubstNo(RequestMessageLbl, CertBase64, SIFiscalSetup."Signing Certificate Password", MethodType, SIFiscalSetup."Environment URL", BaseValue);
        Content.WriteFrom(XMLDocText);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        Url := SignAndSendXMLAzureFunctionURLLbl;

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            exit(true)
    end;

    internal procedure SignZOICode(BaseValue: Text; var ResponseText: Text): Boolean
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        InStr: InStream;
        RequestMessageLbl: Label '{"certificateBase64": "%1","certificatePass": "%2","baseValue": "%3"}', Locked = true;
        SignZOIAzureFunctionURLLbl: Label 'https://slocompilance.azurewebsites.net/api/GenerateZOI?code=Ba73k6IpW1PvLrPj7M2-6Mz69NmvuQizlg3wVS-3UXf-AzFu5xuXGQ==', Locked = true;
        CertBase64: Text;
        Url: Text;
        XMLDocText: Text;
        IsHandled: Boolean;
    begin
        SIFiscalSetup.SetAutoCalcFields("Signing Certificate");
        SIFiscalSetup.Get();

        SIFiscalSetup.TestField("Signing Certificate");
        SIFiscalSetup.TestField("Signing Certificate Password");

        SIFiscalSetup."Signing Certificate".CreateInStream(InStr);
        InStr.ReadText(CertBase64);
        XMLDocText := StrSubstNo(RequestMessageLbl, CertBase64, SIFiscalSetup."Signing Certificate Password", BaseValue);
        Content.WriteFrom(XMLDocText);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        Url := SignZOIAzureFunctionURLLbl;

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        OnBeforeSendHttpRequestForSignZOICode(ResponseText, IsHandled);
        if IsHandled then
            exit(true);
        if SendHttpRequest(RequestMessage, ResponseText, false) then
            exit(true)
    end;

    internal procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;

    internal procedure SendHttpRequest(var RequestMessage: HttpRequestMessage; var ResponseText: Text; SkipErrorMessage: Boolean): Boolean
    var
        IsResponseSuccess: Boolean;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ErrorText: Text;
    begin
        Clear(ResponseMessage);
        IsResponseSuccess := Client.Send(RequestMessage, ResponseMessage);
        if (not IsResponseSuccess) then
            if SkipErrorMessage then
                exit(IsResponseSuccess)
            else
                Error(GetLastErrorText);

        IsResponseSuccess := ResponseMessage.IsSuccessStatusCode();
        if (not IsResponseSuccess) and (not SkipErrorMessage) and GuiAllowed then begin
            ErrorText := Format(ResponseMessage.HttpStatusCode(), 0, 9) + ': ' + ResponseMessage.ReasonPhrase;
            if ResponseMessage.Content.ReadAs(ResponseText) then
                ErrorText += ':\' + ResponseText;
            Error(CopyStr(ErrorText, 1, 1000));
        end;
        ResponseMessage.Content.ReadAs(ResponseText);

        exit(IsResponseSuccess);
    end;

    #endregion

    #region SI Fiscal - Certificate Handling

#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
    procedure ImportCertificate()
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        X509Certificate2: Codeunit X509Certificate2;
        IStream: InStream;
        DialCaption: Label 'Upload Certificate';
        ExtFilter: Label 'p12', Locked = true;
        FileFilter: Label 'Certificate File (*.P12)|*.P12', Locked = true;
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        CertificateThumbprint: Text;
        FileName: Text;
    begin
        SIFiscalSetup.Get();
        if SIFiscalSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(SIFiscalSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaption, '', FileFilter, ExtFilter);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream, TextEncoding::UTF16);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, SIFiscalSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, SIFiscalSetup."Signing Certificate Password")) then
            Error(ERROR_MISSING_KEY);

        SIFiscalSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        SIFiscalSetup."Certificate Subject Ident." := CopyStr(FormatCertificateSubjectInfo(X509Certificate2, Base64Cert), 1, MaxStrLen(SIFiscalSetup."Certificate Subject Ident."));

        CertificateThumbprint := SIFiscalSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, SIFiscalSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        SIFiscalSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        SIFiscalSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, SIFiscalSetup."Signing Certificate Thumbprint");
    end;
#else
    procedure ImportCertificate()
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        X509Certificate2: Codeunit X509Certificate2;
        IStream: InStream;
        DialCaption: Label 'Upload Certificate';
        ExtFilter: Label 'pfx', Locked = true;
        FileFilter: Label 'Certificate File (*.PFX)|*.PFX', Locked = true;
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        CertificateThumbprint: Text;
        FileName: Text;
    begin
        SIFiscalSetup.Get();
        if SIFiscalSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(SIFiscalSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaption, '', FileFilter, ExtFilter);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, SIFiscalSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, SIFiscalSetup."Signing Certificate Password")) then
            Error(ERROR_MISSING_KEY);

        SIFiscalSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        SIFiscalSetup."Certificate Subject Ident." := CopyStr(FormatCertificateSubjectInfo(X509Certificate2, Base64Cert), 1, MaxStrLen(SIFiscalSetup."Certificate Subject Ident."));

        CertificateThumbprint := SIFiscalSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, SIFiscalSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        SIFiscalSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        SIFiscalSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, SIFiscalSetup."Signing Certificate Thumbprint");
    end;
#endif
    #endregion

    [IntegrationEvent(true, false)]
    local procedure OnBeforePrintFiscalReceipt(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForSignZOICode(var ResponseText: Text; var IsHandled: Boolean)
    begin
    end;
}