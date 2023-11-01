codeunit 6151548 "NPR NO Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        _NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        _SignatureKey: Codeunit "Signature Key";
#elif not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
        _SignatureKey: Record "Signature Key";
#else
        _X509Certificate2: DotNet NPRNetX509Certificate2;
        _RSACryptoServiceProvider: DotNet NPRNetRSACryptoServiceProvider;
#endif
        _Enabled: Boolean;
        _CertificateLoaded: Boolean;
        _Initialized: Boolean;
        CAPTION_OVERWRITE_CERT: Label 'Are you sure you want to overwrite the existing certificate?';
        ERROR_MISSING_KEY: Label 'The selected certificate does not contain the private key';
        CAPTION_CERT_SUCCESS: Label 'Certificate with thumbprint %1 was uploaded successfully';
        ERROR_VALIDATE_VERSION: Label 'Can only validate entries created for implementation %1';
        ERROR_VALIDATE_CERT: Label 'Can only validate entries signed with certificate thumbprint %1';

    #region NO Fiscal - POS Handling Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsNOAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddNOAuditHandler(tmpRetailList);
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
    #endregion

    #region Subscribers - POS Audit Logging
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Run Page", 'OnBeforeRunPage', '', false, false)]
    local procedure NPRPOSActionRunPage_OnBeforeRunPage(PageId: Integer; RunModal: Boolean; Sale: Codeunit "NPR POS Sale");
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSSale: Record "NPR POS Sale";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        AuditLogDesc: Label 'Price checked by %1';
    begin
        if not IsNOFiscalActive() then
            exit;

        Sale.GetCurrentSale(POSSale);
        POSAuditLogMgt.CreateEntryExtended(POSSale.RecordId, POSAuditLog."Action Type"::PRICE_CHECK, 0, '', POSSale."Register No.", StrSubstNo(AuditLogDesc, POSSale."Salesperson Code"), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POSAction: Delete POS Line", 'OnBeforeDeleteSaleLinePOS', '', false, false)]
    local procedure NPRPOSActionDeletePOSLine_OnBeforeDeleteSaleLinePOS(POSSaleLine: Codeunit "NPR POS Sale Line");
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSSaleLineRecord: Record "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        AuditLogDesc: Label 'POS Sales Line deleted';
    begin
        POSSaleLine.GetCurrentSaleLine(POSSaleLineRecord);
        POSUnit.Get(POSSaleLineRecord."Register No.");
        if not IsNOAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSAuditLogMgt.CreateEntryExtended(POSSaleLineRecord.RecordId, POSAuditLog."Action Type"::DELETE_POS_SALE_LINE, 0, '', POSSaleLineRecord."Register No.", AuditLogDesc, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POSAction: Cancel Sale B", 'OnBeforeDeletePOSSaleLine', '', false, false)]
    local procedure NPRPOSActionCancelSaleB_OnBeforeDeletePOSSaleLine(POSSaleLine: Codeunit "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale");
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        AuditLogDesc: Label 'POS Sales Line canceled';
        POSSaleLineRecord: Record "NPR POS Sale Line";
        Amount: Decimal;
    begin
        POSSaleLine.GetCurrentSaleLine(POSSaleLineRecord);
        if not POSUnit.Get(POSSaleLineRecord."Register No.") then
            exit;

        if not IsNOAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSSaleLineRecord.CalcSums("Amount Including VAT");
        Amount := POSSaleLineRecord."Amount Including VAT";
        POSAuditLogMgt.CreateEntryExtended(SalePOS.RecordId, POSAuditLog."Action Type"::CANCEL_POS_SALE_LINE, 0, '', SalePOS."Register No.", AuditLogDesc, Format(Amount));
    end;

    #endregion

    #region NO Fiscal - Audit Profile Mgt
    local procedure AddNOAuditHandler(var tmpRetailList: Record "NPR Retail List")
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
        if not IsNOAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;
        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertNOPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);

        LoadCertificate();
        //Shave off milliseconds from timestamp to prevent sql rounding on commit causing signature invalidation later.
        Evaluate(POSAuditLog."Log Timestamp", CopyStr(Format(POSAuditLog."Log Timestamp", 0, 9), 1, 19) + '.000Z', 9);

        case POSAuditLog."Action Type" of
            POSAuditLog."Action Type"::DIRECT_SALE_END:
                SignTicket(POSAuditLog);
        end;
    end;

    local procedure SignTicket(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSAuditLog."Record ID");

        //TICKET event might also trigger a "Non-item amount" custom JET event depending on sale contents:
        LogNonItemAmounts(POSEntry);

        POSAuditLog."External ID" := POSEntry."Fiscal No.";
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'TICKET';

        if IsFullRMA(POSEntry) then
            POSAuditLog."External Description" := 'Cancellation (Ticket)'
        else
            POSAuditLog."External Description" := 'Sale (Ticket)';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    procedure FillSignatureBaseValues(var POSAuditLog: Record "NPR POS Audit Log"; IsInitialHandling: Boolean)
    var
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        InStream: InStream;
        OutStream: OutStream;
        BaseValue: Text;
        PreviousSignature: Text;
        PreviousSignatureChunk: Text;
    begin
        if IsInitialHandling then begin
            if GetLastUnitEventSignature(POSAuditLog."Active POS Unit No.", PreviousEventLogRecord, POSAuditLog."External Type") then
                POSAuditLog."Previous Electronic Signature" := PreviousEventLogRecord."Electronic Signature";
            POSAuditLog."External Implementation" := HandlerCode();
            POSAuditLog."Certificate Implementation" := 'RSA-SHA1-1024';
            POSAuditLog."Certificate Thumbprint" := _NOFiscalizationSetup."Signing Certificate Thumbprint";
            POSAuditLog."Handled by External Impl." := true;
        end;

        if POSAuditLog."External Implementation" <> HandlerCode() then //Can only validate the current version of the implementation as the rules & fields might have changed over time.
            Error(ERROR_VALIDATE_VERSION, HandlerCode());

        if POSAuditLog."Certificate Thumbprint" <> _NOFiscalizationSetup."Signing Certificate Thumbprint" then
            Error(ERROR_VALIDATE_CERT, _NOFiscalizationSetup."Signing Certificate Thumbprint");
        POSAuditLog."Previous Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(PreviousSignatureChunk);
            PreviousSignature += PreviousSignatureChunk;
        end;

        case POSAuditLog."External Type" of
            'TICKET':
                BaseValue := FillTicketBase(POSAuditLog, PreviousSignature);
        end;
        POSAuditLog."Signature Base Value".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(BaseValue);

        if IsInitialHandling then
            POSAuditLog."Original Signature Base Value" := POSAuditLog."Signature Base Value";
    end;

    local procedure FillTicketBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        POSEntry: Record "NPR POS Entry";
        TaxTotalExclTax: Decimal;
        TaxTotalInclTax: Decimal;
        FillTicketBaseLbl: Label '%1;%2;%3;%4;%5', Locked = true;
    begin
        POSEntry.Get(POSAuditLog."Record ID");

        TaxTotalExclTax := GetSaleTotalExclTax(POSEntry, false);
        TaxTotalInclTax := GetSaleTotalInclTax(POSEntry, false);

        exit(StrSubstNo(FillTicketBaseLbl,
            FormatText(PreviousSignature),
            FormatDatetime(POSAuditLog."Log Timestamp"),
            FormatAlphanumeric(POSAuditLog."Acted on POS Entry Fiscal No."),
            FormatNumeric(TaxTotalInclTax),
            FormatNumeric(TaxTotalExclTax)));
    end;

    procedure GetLastUnitEventSignature(POSUnitNo: Code[10]; var POSAuditLogOut: Record "NPR POS Audit Log"; ExternalType: Code[20]): Boolean
    begin
        POSAuditLogOut.SetAutoCalcFields("Electronic Signature");
        POSAuditLogOut.SetCurrentKey("Active POS Unit No.", "External Type");
        POSAuditLogOut.SetRange("Active POS Unit No.", POSUnitNo);
        POSAuditLogOut.SetRange("External Type", ExternalType);
        exit(POSAuditLogOut.FindLast());
    end;

    local procedure LogNonItemAmounts(POSEntry: Record "NPR POS Entry")
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        Amount: Decimal;
        AddInfoLbl: Label '%1|%2', Locked = true;
        AddInfo: Text;
    begin
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetFilter(Type, '<>%1&<>%2&<>%3', POSSalesLine.Type::Item, POSSalesLine.Type::Rounding, POSSalesLine.Type::Comment);
        if POSSalesLine.IsEmpty then
            exit;

        Amount := GetSaleTotalInclTax(POSEntry, false) - GetSaleTotalInclTax(POSEntry, true);
        AddInfo := StrSubstNo(AddInfoLbl, POSEntry."Fiscal No.", Format(Amount, 0, '<Precision,2:2><Standard Format,9>'));

        POSAuditLogMgt.CreateEntryCustom(POSEntry.RecordId, 'NON_ITEM_AMOUNT', POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", 'Sale amount not from items', AddInfo);
    end;

    local procedure SignRecord(var POSAuditLog: Record "NPR POS Audit Log")
    var
        IStream: InStream;
        OStream: OutStream;
        BaseValue: Text;
        BaseValueChunk: Text;
        Signature: Text;
    begin
        POSAuditLog."Signature Base Value".CreateInStream(IStream, TextEncoding::UTF8);
        while (not IStream.EOS) do begin
            IStream.ReadText(BaseValueChunk);
            BaseValue += BaseValueChunk;
        end;

        Signature := SignData(BaseValue);
        POSAuditLog."Electronic Signature".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(EncodeBase64URL(Signature));
    end;

    local procedure EncodeBase64URL(Text: Text): Text
    begin
        exit(DelChr(ConvertStr(Text, '/+', '_-'), '=', '='));
    end;

    local procedure FormatAlphanumeric(Text: Text): Text
    begin
        //As per auditing consultant: Alphanumeric is not supposed to be a literal interpretation, so will be treated as text...
        exit(FormatText(Text));
    end;

    local procedure FormatNumeric(Decimal: Decimal): Text
    begin
        exit(DelChr(Format(Round(Decimal), 0, '<Precision,2:2><Standard Format,9>'), '=', '.'));
    end;

    local procedure FormatDatetime(DateTime: DateTime): Text
    begin
        exit(Format(DateTime, 0, '<Year4>-<Month,2>-<Day,2>;<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure FormatText(Text: Text): Text
    begin
        exit(ConvertStr(Text, ', ', ';_'));
    end;

    local procedure GetSaleTotalInclTax(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean): Decimal
    begin
        if OnlyIncludeItems then
            exit(POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)")
        else
            exit(POSEntry."Amount Incl. Tax");
    end;

    local procedure GetSaleTotalExclTax(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean): Decimal
    begin
        if OnlyIncludeItems then
            exit(POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)")
        else
            exit(POSEntry."Amount Excl. Tax");
    end;

    local procedure IsFullRMA(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSRMALine: Record "NPR POS RMA Line";
    begin
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        if not POSSalesLine.FindSet() then
            exit(false);

        repeat
            POSRMALine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSRMALine.SetRange("Return Line No.", POSSalesLine."Line No.");
            if POSRMALine.IsEmpty then
                exit(false);
        until POSSalesLine.Next() = 0;

        exit(true);
    end;

    local procedure InsertNOPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        NOPOSAuditLogAuxInfo: Record "NPR NO POS Audit Log Aux. Info";
    begin
        NOPOSAuditLogAuxInfo.Init();
        NOPOSAuditLogAuxInfo."Audit Entry Type" := NOPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        NOPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        NOPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        NOPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        NOPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        NOPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        NOPOSAuditLogAuxInfo.Insert();
    end;

    #endregion

    #region NO Fiscal - Procedures/Helper Functions

#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
    local procedure LoadCertificate()
    var
        X509Certificate2: Codeunit X509Certificate2;
        InStr: InStream;
        Base64Cert: Text;
        Base64Cert2: Text;
    begin
        if not _CertificateLoaded then begin
            _NOFiscalizationSetup.SetAutoCalcFields("Signing Certificate");
            _NOFiscalizationSetup.Get();
            _NOFiscalizationSetup.TestField("Signing Certificate Thumbprint");
            _NOFiscalizationSetup.TestField("Signing Certificate Password");
            _NOFiscalizationSetup."Signing Certificate".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(Base64Cert);
            Base64Cert2 := Base64Cert; //Prevent below VAR from messing up the cert
            if not X509Certificate2.VerifyCertificate(Base64Cert, _NOFiscalizationSetup."Signing Certificate Password", "X509 Content Type"::Cert) then
                exit;

            _SignatureKey.FromBase64String(Base64Cert2, _NOFiscalizationSetup."Signing Certificate Password", true);
            _CertificateLoaded := true;
        end;
    end;

    procedure VerifySignature(Data: Text; HashAlgo: Enum "Hash Algorithm"; SignatureBase64: Text): Boolean
    var
        ConvertBase64: Codeunit "Base64 Convert";
        CryptoMgt: Codeunit "Cryptography Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStr: OutStream;
    begin
        LoadCertificate();
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        ConvertBase64.FromBase64(SignatureBase64, OutStr);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        exit(CryptoMgt.VerifyData(Data, _SignatureKey, HashAlgo, InStream));
    end;

    procedure SignData(BaseValue: Text): Text
    var
        ConvertBase64: Codeunit "Base64 Convert";
        CryptoMgt: Codeunit "Cryptography Management";
        TempBLOB: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        TempBLOB.CreateOutStream(OutStr, TextEncoding::UTF8);
        CryptoMgt.SignData(BaseValue, _SignatureKey, Enum::"Hash Algorithm"::SHA1, OutStr);
        TempBLOB.CreateInStream(InStr, TextEncoding::UTF8);
        exit(ConvertBase64.ToBase64(InStr));
    end;

    procedure CalculateHash(BaseValue: Text): Text
    var
        CryptoMgt: Codeunit "Cryptography Management";
    begin
        exit(CryptoMgt.GenerateHashAsBase64String(BaseValue, 2));
    end;

    procedure ImportCertificate()
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        X509Certificate2: Codeunit X509Certificate2;
        IStream: InStream;
        DialCaption: Label 'Upload Certificate';
        ExtFilter: Label 'pfx';
        FileFilter: Label 'Certificate File (*.PFX)|*.PFX';
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        CertificateThumbprint: Text;
        FileName: Text;
    begin
        _NOFiscalizationSetup.Get();
        if _NOFiscalizationSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(_NOFiscalizationSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaption, '', FileFilter, ExtFilter);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, _NOFiscalizationSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, _NOFiscalizationSetup."Signing Certificate Password")) then
            Error(ERROR_MISSING_KEY);

        _NOFiscalizationSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        CertificateThumbprint := _NOFiscalizationSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, _NOFiscalizationSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        _NOFiscalizationSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        _NOFiscalizationSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, _NOFiscalizationSetup."Signing Certificate Thumbprint");
    end;
#else
    local procedure LoadCertificate()
    var
        InStream: InStream;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        MemoryStream: DotNet NPRNetMemoryStream;
        Base64Convert: Codeunit "Base64 Convert";
        Base64Cert: Text;
    begin
        if not _CertificateLoaded then begin
            _NOFiscalizationSetup.SetAutoCalcFields("Signing Certificate");
            _NOFiscalizationSetup.Get();
            _NOFiscalizationSetup.TestField("Signing Certificate Thumbprint");
            _NOFiscalizationSetup.TestField("Signing Certificate Password");
            _NOFiscalizationSetup."Signing Certificate".CreateInStream(InStream, TextEncoding::UTF8);
            InStream.ReadText(Base64Cert);
            TempBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(Base64Cert, OutStream);
            MemoryStream := MemoryStream.MemoryStream();
            TempBlob.CreateInStream(InStream);
            CopyStream(MemoryStream, InStream);
            _X509Certificate2 := _X509Certificate2.X509Certificate2(MemoryStream.ToArray(), _NOFiscalizationSetup."Signing Certificate Password");
            _RSACryptoServiceProvider := _X509Certificate2.PrivateKey;
#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
            _SignatureKey.FromBase64String(Base64Cert2, _NOFiscalizationSetup."Signing Certificate Password", true);
#endif
            _CertificateLoaded := true;
        end;
    end;

    procedure VerifySignature(Data: Text; HashAlgo: Text; SignatureBase64: Text): Boolean
    var
        CryptoConfig: DotNet NPRNetCryptoConfig;
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
    begin
        LoadCertificate();
        exit(_RSACryptoServiceProvider.VerifyData(Encoding.UTF8.GetBytes(Data), CryptoConfig.MapNameToOID(HashAlgo), Convert.FromBase64String(SignatureBase64)));
    end;

    procedure SignData(BaseValue: Text): Text
    var
        CryptoConfig: DotNet NPRNetCryptoConfig;
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet Encoding;
    begin
        exit(Convert.ToBase64String(_RSACryptoServiceProvider.SignData(Encoding.UTF8.GetBytes(BaseValue), CryptoConfig.MapNameToOID('SHA1'))));
    end;

    procedure CalculateHash(BaseValue: Text): Text
    var
        SHA1: DotNet SHA1;
        Encoding: DotNet NPRNetEncoding;
        Convert: DotNet NPRNetConvert;
    begin
        SHA1.Initialize();
        exit(Convert.ToBase64String(SHA1.ComputeHash(Encoding.Unicode.GetBytes(BaseValue))));
    end;

    procedure ImportCertificate()
    var
        IStream: InStream;
        OStream: OutStream;
        Base64Cert: Text;
        Base64Cert2: Text;
        X509Certificate2: Codeunit X509Certificate2;
        Base64Convert: Codeunit "Base64 Convert";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        DialCaption: Label 'Upload Certificate';
        FileFilter: Label 'Certificate File (*.PFX)|*.PFX';
        ExtFilter: Label 'pfx';
        FileName: Text;
        CertificateThumbprint: Text;
    begin
        _NOFiscalizationSetup.Get();
        if _NOFiscalizationSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(_NOFiscalizationSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaption, '', FileFilter, ExtFilter);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, _NOFiscalizationSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, _NOFiscalizationSetup."Signing Certificate Password")) then
            Error(ERROR_MISSING_KEY);

        _NOFiscalizationSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        CertificateThumbprint := _NOFiscalizationSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, _NOFiscalizationSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        _NOFiscalizationSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        _NOFiscalizationSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, _NOFiscalizationSetup."Signing Certificate Thumbprint");
    end;
#endif

    internal procedure IsNOFiscalActive(): Boolean
    var
        NOFiscalSetup: Record "NPR NO Fiscalization Setup";
    begin
        if NOFiscalSetup.Get() then
            exit(NOFiscalSetup."Enable NO Fiscal");
    end;

    local procedure IsNOAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);
        if _Initialized then
            exit(_Enabled);
        _Initialized := true;
        _Enabled := true;
        exit(true);
    end;

    local procedure HandlerCode(): Text[20]
    var
        HandlerCodeTxt: Label 'NO_LOVDATA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        NOFiscalisationSetup: Page "NPR NO Fiscalization Setup";
    begin
        NOFiscalisationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        NOPOSAuditLogAuxInfo: Record "NPR NO POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - NO POS Audit Log Aux. Info table caption';
    begin
        if not IsNOFiscalActive() then
            exit;

        NOPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not NOPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, NOPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        NOPOSAuditLogAuxInfo: Record "NPR NO POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - NO POS Audit Log Aux. Info table caption';
    begin
        if not IsNOAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        NOPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not NOPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", NOPOSAuditLogAuxInfo.TableCaption());
    end;

    #endregion
}