codeunit 6184850 "NPR FR Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        _FRCertificationSetup: Record "NPR FR Audit Setup";

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        _SignatureKey: Codeunit "Signature Key";
#elif not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
        _SignatureKey: Record "Signature Key";
#else
        _X509Certificate2: DotNet NPRNetX509Certificate2;
        _RSACryptoServiceProvider: DotNet NPRNetRSACryptoServiceProvider;
#endif
        _Initialized: Boolean;
        _Enabled: Boolean;
        _CertificateLoaded: Boolean;
        ERROR_MISSING_KEY: Label 'The selected certificate does not contain the private key';
        ERROR_SIGNATURE_CHAIN: Label 'Broken signature chain for %1 entry %2';
        ERROR_SIGNATURE_VALUE: Label 'Invalid signature for %1 entry %2';
        ERROR_VALIDATE_VERSION: Label 'Can only validate entries created for implementation %1';
        ERROR_VALIDATE_CERT: Label 'Can only validate entries signed with certificate thumbprint %1';
        CAPTION_OVERWRITE_CERT: Label 'Are you sure you want to overwrite the existing certificate?';
        CAPTION_CERT_SUCCESS: Label 'Certificate with thumbprint %1 was uploaded successfully';
        CAPTION_SIGNATURES_VALID: Label 'Chained signatures of %1 entries verified successfully';

    #region FR Fiscal - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        FRAuditSetup: Record "NPR FR Audit Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        FRAuditSetup.ChangeCompany(CompanyName);
        if FRAuditSetup.Get() then begin
            Clear(FRAuditSetup."Signing Certificate");
            Clear(FRAuditSetup."Signing Certificate Password");
            Clear(FRAuditSetup."Signing Certificate Thumbprint");
            FRAuditSetup.Modify();
        end;
    end;
#endif

    #endregion

    procedure HandlerCode(): Text[8]
    begin
        exit('FR_NF525');
    end;

    procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not _Initialized then begin
            if not POSAuditProfile.Get(POSAuditProfileCode) then
                exit(false);
            if POSAuditProfile."Audit Handler" <> HandlerCode() then
                exit(false);
            _FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
            _FRCertificationSetup.Get();
            _Initialized := true;
            _Enabled := true;
        end;
        exit(_Enabled);
    end;

#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
    procedure LoadCertificate()
    var
        X509Certificate2: Codeunit X509Certificate2;
        InStr: InStream;
        Base64Cert: Text;
        Base64Cert2: Text;
    begin
        if not _CertificateLoaded then begin
            _FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
            _FRCertificationSetup.Get();
            _FRCertificationSetup.TestField("Signing Certificate Thumbprint");
            _FRCertificationSetup.TestField("Signing Certificate Password");
            _FRCertificationSetup."Signing Certificate".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(Base64Cert);
            Base64Cert2 := Base64Cert; //Prevent below VAR from messing up the cert
            if not X509Certificate2.VerifyCertificate(Base64Cert, _FRCertificationSetup."Signing Certificate Password", "X509 Content Type"::Cert) then
                exit;

            _SignatureKey.FromBase64String(Base64Cert2, _FRCertificationSetup."Signing Certificate Password", true);
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
        CryptoMgt.SignData(BaseValue, _SignatureKey, Enum::"Hash Algorithm"::SHA256, OutStr);
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
        _FRCertificationSetup.Get();
        if _FRCertificationSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(_FRCertificationSetup."Signing Certificate");
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, DialCaption, '', FileFilter, ExtFilter);

        if FileName = '' then
            exit;

        TempBlob.CreateInStream(IStream);
        Base64Cert := Base64Convert.ToBase64(IStream);
        Base64Cert2 := Base64Cert;

        X509Certificate2.VerifyCertificate(Base64Cert2, _FRCertificationSetup."Signing Certificate Password", Enum::"X509 Content Type"::Cert);
        if (not X509Certificate2.HasPrivateKey(Base64Cert, _FRCertificationSetup."Signing Certificate Password")) then
            Error(ERROR_MISSING_KEY);

        _FRCertificationSetup."Signing Certificate".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(Base64Cert);

        CertificateThumbprint := _FRCertificationSetup."Signing Certificate Thumbprint";
        X509Certificate2.GetCertificateThumbprint(Base64Cert, _FRCertificationSetup."Signing Certificate Password", CertificateThumbprint);
#pragma warning disable AA0139
        _FRCertificationSetup."Signing Certificate Thumbprint" := CertificateThumbprint;
#pragma warning restore AA0139
        _FRCertificationSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, _FRCertificationSetup."Signing Certificate Thumbprint");
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
            _FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
            _FRCertificationSetup.Get();
            _FRCertificationSetup.TestField("Signing Certificate Thumbprint");
            _FRCertificationSetup.TestField("Signing Certificate Password");
            _FRCertificationSetup."Signing Certificate".CreateInStream(InStream, TextEncoding::UTF8);
            InStream.Read(Base64Cert);
            TempBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(Base64Cert, OutStream);
            MemoryStream := MemoryStream.MemoryStream();
            TempBlob.CreateInStream(InStream);
            CopyStream(MemoryStream, InStream);
            _X509Certificate2 := _X509Certificate2.X509Certificate2(MemoryStream.ToArray(), _FRCertificationSetup."Signing Certificate Password");
            _RSACryptoServiceProvider := _X509Certificate2.PrivateKey;
#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
            _SignatureKey.FromBase64String(Base64Cert2, _FRCertificationSetup."Signing Certificate Password", true);
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
        exit(Convert.ToBase64String(_RSACryptoServiceProvider.SignData(Encoding.UTF8.GetBytes(BaseValue), CryptoConfig.MapNameToOID('SHA256'))));
    end;

    procedure CalculateHash(BaseValue: Text): Text
    var
        SHA256CryptoServiceProvider: DotNet NPRNetSHA256CryptoServiceProvider;
        Encoding: DotNet NPRNetEncoding;
        Convert: DotNet NPRNetConvert;
    begin
        SHA256CryptoServiceProvider := SHA256CryptoServiceProvider.SHA256CryptoServiceProvider();
        exit(Convert.ToBase64String(SHA256CryptoServiceProvider.ComputeHash(Encoding.Unicode.GetBytes(BaseValue))));
    end;

    procedure ImportCertificate()
    var
        InStream: InStream;
        OutStream: OutStream;
        NPRX509Certificate2: DotNet NPRNetX509Certificate2;
        MemoryStream: DotNet NPRNetMemoryStream;
        LocalRSACryptoServiceProvider: DotNet NPRNetRSACryptoServiceProvider;
        FileName: Text;
    begin
        _FRCertificationSetup.Get();
        if _FRCertificationSetup."Signing Certificate".HasValue() then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(_FRCertificationSetup."Signing Certificate");
        end;
        _FRCertificationSetup."Signing Certificate".CreateOutStream(OutStream, TextEncoding::UTF8);
        if not UploadIntoStream('Upload Certificate', '', 'Certificate File (*.PFX)|*.PFX', FileName, InStream) then
            exit;
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);

        NPRX509Certificate2 := NPRX509Certificate2.X509Certificate2(MemoryStream.ToArray(), _FRCertificationSetup."Signing Certificate Password");
        if (not NPRX509Certificate2.HasPrivateKey) then
            Error(ERROR_MISSING_KEY);
        LocalRSACryptoServiceProvider := NPRX509Certificate2.PrivateKey;
        _FRCertificationSetup."Signing Certificate Thumbprint" := NPRX509Certificate2.Thumbprint;
        MemoryStream.Position := 0;
        CopyStream(OutStream, MemoryStream);
        _FRCertificationSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, _FRCertificationSetup."Signing Certificate Thumbprint");
    end;
#endif

    procedure GetLastUnitEventSignature(POSUnitNo: Code[10]; var POSAuditLogOut: Record "NPR POS Audit Log"; ExternalType: Code[20]): Boolean
    begin
        POSAuditLogOut.SetAutoCalcFields("Electronic Signature");
        POSAuditLogOut.SetCurrentKey("Active POS Unit No.", "External Type");
        POSAuditLogOut.SetRange("Active POS Unit No.", POSUnitNo);
        POSAuditLogOut.SetRange("External Type", ExternalType);
        exit(POSAuditLogOut.FindLast());
    end;

    local procedure GetNextEventNoSeries(EventType: Option JET,Reprint,Period,MonthPeriod,YearPeriod; POSUnitNo: Code[10]): Code[20]
    var
        FRCertificationNoSeries: Record "NPR FR Audit No. Series";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
    begin
        FRCertificationNoSeries.Get(POSUnitNo);
        case EventType of
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            EventType::JET:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."JET No. Series", Today, false));
            EventType::Reprint:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Reprint No. Series", Today, false));
            EventType::Period:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Period No. Series", Today, false));
            EventType::MonthPeriod:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Grand Period No. Series", Today, false));
            EventType::YearPeriod:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Yearly Period No. Series", Today, false));
#ELSE
            EventType::JET:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."JET No. Series", Today, true));
            EventType::Reprint:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Reprint No. Series", Today, true));
            EventType::Period:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Period No. Series", Today, true));
            EventType::MonthPeriod:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Grand Period No. Series", Today, true));
            EventType::YearPeriod:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Yearly Period No. Series", Today, true));
#ENDIF
        end;
    end;

    internal procedure TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; PeriodType: Code[20]; PeriodDateCalcFormula: DateFormula; var FromWorkshiftEntryOut: Integer): Boolean
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        POSWorkshifts: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshifts.SetRange("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSWorkshifts.SetRange(Type, POSWorkshifts.Type::PREPORT);
        POSWorkshifts.SetRange("Period Type", PeriodType);
        POSWorkshifts.SetRange(Open, false);
        POSWorkshifts.SetFilter("POS Entry No.", '<>%1', 0);
        if not POSWorkshifts.FindLast() then begin
            //Find the first workshift created after JET was initialized in-case we have old workshifts that should not be handled.
            GetJETInitRecord(POSAuditLog, POSWorkshiftCheckpoint."POS Unit No.", true);

            POSWorkshifts.SetRange("Period Type");
            POSWorkshifts.SetRange(Type, POSWorkshifts.Type::ZREPORT);
            POSWorkshifts.SetFilter("POS Entry No.", '>=%1&<>%2', POSAuditLog."Acted on POS Entry No.", 0);
            if not POSWorkshifts.FindFirst() then
                exit(false);
        end;
        FromWorkshiftEntryOut := POSWorkshifts."Entry No.";

        POSEntry.Get(POSWorkshifts."POS Entry No.");
        exit(CalcDate(PeriodDateCalcFormula, POSEntry."Document Date") <= Today);
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
            POSAuditLog."External Implementation" := ImplementationCode();
            POSAuditLog."Certificate Implementation" := 'RSA_2048_SHA256';
            POSAuditLog."Certificate Thumbprint" := _FRCertificationSetup."Signing Certificate Thumbprint";
            POSAuditLog."Handled by External Impl." := true;
        end;

        if POSAuditLog."External Implementation" <> ImplementationCode() then //Can only validate the current version of the implementation as the rules & fields might have changed over time.
            Error(ERROR_VALIDATE_VERSION, ImplementationCode());

        if POSAuditLog."Certificate Thumbprint" <> _FRCertificationSetup."Signing Certificate Thumbprint" then
            Error(ERROR_VALIDATE_CERT, _FRCertificationSetup."Signing Certificate Thumbprint");
        POSAuditLog."Previous Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(PreviousSignatureChunk);
            PreviousSignature += PreviousSignatureChunk;
        end;

        case POSAuditLog."External Type" of
            'JET':
                BaseValue := FillJETBase(POSAuditLog, PreviousSignature);
            'TICKET':
                BaseValue := FillTicketBase(POSAuditLog, PreviousSignature);
            'GRANDTOTAL':
                BaseValue := FillGrandTotalBase(POSAuditLog, PreviousSignature);
            'DUPLICATE':
                BaseValue := FillDuplicatePrintBase(POSAuditLog, PreviousSignature);
            'ARCHIVE':
                BaseValue := FillArchiveFileBase(POSAuditLog, PreviousSignature);
        end;
        POSAuditLog."Signature Base Value".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(BaseValue);

        if IsInitialHandling then
            POSAuditLog."Original Signature Base Value" := POSAuditLog."Signature Base Value";
    end;

    local procedure FillJETBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        FillJETBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7,%8', Locked = true;
    begin
        exit(StrSubstNo(FillJETBaseLbl,
            FormatAlphanumeric(POSAuditLog."External ID"),
            POSAuditLog."External Code",
            FormatAlphanumeric(POSAuditLog."Additional Information"),
            FormatDatetime(POSAuditLog."Log Timestamp"),
            FormatAlphanumeric(POSAuditLog."Active Salesperson Code"),
            FormatAlphanumeric(POSAuditLog."Active POS Unit No."),
            Format((PreviousSignature <> ''), 0, 2),
            FormatText(PreviousSignature)));
    end;

    local procedure FillTicketBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        POSEntry: Record "NPR POS Entry";
        TaxTotal: Decimal;
        FillTicketBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7', Locked = true;
        TaxBreakdown: Text;
    begin
        POSEntry.Get(POSAuditLog."Record ID");

        TaxBreakdown := GetSaleTaxBreakdownString(POSEntry, false);
        TaxTotal := GetSaleTotalInclTax(POSEntry, false);

        exit(StrSubstNo(FillTicketBaseLbl,
            FormatAlphanumeric(TaxBreakdown),
            FormatNumeric(TaxTotal),
            FormatDatetime(POSAuditLog."Log Timestamp"),
            FormatAlphanumeric(POSAuditLog."Acted on POS Entry Fiscal No."),
            POSAuditLog."External Description",
            Format((PreviousSignature <> ''), 0, 2),
            FormatText(PreviousSignature)));
    end;

    local procedure FillGrandTotalBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
        PerpetualAmount: Decimal;
        TaxTotal: Decimal;
        FillGrandTotalBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7', Locked = true;
        POSAuditLogAdditionalInformationLbl: Label '%1|%2|%3', Locked = true;
        TaxBreakdown: Text;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
            Database::"NPR POS Workshift Checkpoint":
                begin
                    RecRef.SetTable(POSWorkshiftCheckpoint);
                    POSWorkshiftCheckpoint.Find();
                    TaxBreakdown := GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint);
                    TaxTotal := GetWorkshiftTotalInclTax(POSWorkshiftCheckpoint);
                    POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
                    PerpetualAmount := GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint);
                    POSAuditLog."Additional Information" := StrSubstNo(POSAuditLogAdditionalInformationLbl,
                        Format(TaxTotal, 0, '<Precision,2:2><Standard Format,9>'),
                        Format(GetWorkshiftPerpetualAbsoluteAmount(POSWorkshiftCheckpoint), 0, '<Precision,2:2><Standard Format,9>'),
                        Format(PerpetualAmount, 0, '<Precision,2:2><Standard Format,9>'));
                end;
            Database::"NPR POS Entry":
                begin
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find();
                    TaxBreakdown := GetSaleTaxBreakdownString(POSEntry, true);
                    TaxTotal := GetSaleTotalInclTax(POSEntry, true);
                    PerpetualAmount := GetSalePerpetualAmount(POSEntry);
                    POSAuditLog."Additional Information" := StrSubstNo(POSAuditLogAdditionalInformationLbl,
                        Format(TaxTotal, 0, '<Precision,2:2><Standard Format,9>'),
                        Format(GetSalePerpetualAbsoluteAmount(POSEntry), 0, '<Precision,2:2><Standard Format,9>'),
                        Format(PerpetualAmount, 0, '<Precision,2:2><Standard Format,9>'));
                end;
        end;

        exit(StrSubstNo(FillGrandTotalBaseLbl,
            FormatAlphanumeric(TaxBreakdown),
            FormatNumeric(TaxTotal),
            FormatNumeric(PerpetualAmount),
            FormatDatetime(POSAuditLog."Log Timestamp"),
            FormatAlphanumeric(POSEntry."Fiscal No."),
            Format((PreviousSignature <> ''), 0, 2),
            FormatText(PreviousSignature)));
    end;

    local procedure FillDuplicatePrintBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSEntryOutputLog2: Record "NPR POS Entry Output Log";
        ReprintNo: Integer;
        FillDuplicatePrintBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7,%8', Locked = true;
    begin
        POSEntryOutputLog.Get(POSAuditLog."Record ID");

        POSEntryOutputLog2.SetRange("POS Entry No.", POSAuditLog."Acted on POS Entry No.");
        POSEntryOutputLog2.SetRange("Output Method", POSEntryOutputLog2."Output Method"::Print);
        POSEntryOutputLog2.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog2."Output Type"::SalesReceipt, POSEntryOutputLog2."Output Type"::LargeSalesReceipt);
        if POSEntryOutputLog2.FindSet() then
            repeat
                ReprintNo += 1;
            until (POSEntryOutputLog2.Next() = 0) or (POSEntryOutputLog."Entry No." = POSEntryOutputLog2."Entry No.");

        POSAuditLog."Additional Information" := Format(ReprintNo);

        exit(StrSubstNo(FillDuplicatePrintBaseLbl,
            FormatAlphanumeric(POSAuditLog."External ID"),
            'Ticket',
            POSAuditLog."Additional Information",
            FormatAlphanumeric(POSAuditLog."Active Salesperson Code"),
            FormatDatetime(POSAuditLog."Log Timestamp"),
            FormatAlphanumeric(POSAuditLog."Acted on POS Entry Fiscal No."),
            Format((PreviousSignature <> ''), 0, 2),
            FormatText(PreviousSignature)));
    end;

    local procedure FillArchiveFileBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        TaxTotal: Decimal;
        FillArchiveFileBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7', Locked = true;
        TaxBreakdown: Text;
    begin
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");

        TaxBreakdown := GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint);
        TaxTotal := GetWorkshiftTotalInclTax(POSWorkshiftCheckpoint);

        exit(StrSubstNo(FillArchiveFileBaseLbl,
            FormatAlphanumeric(TaxBreakdown),
            FormatNumeric(TaxTotal),
            FormatDatetime(POSAuditLog."Log Timestamp"),
            FormatAlphanumeric(POSAuditLog."Active POS Unit No."),
            'Archive',
            Format((PreviousSignature <> ''), 0, 2),
            FormatText(PreviousSignature)));
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

    local procedure SignAuditVerifyError(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '90';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Signature verification error';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignDrawerCount(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSAuditLog."External Code" := '170';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Cash Drawer Counting';
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSAuditLog."Additional Information" := Format(POSEntry."Fiscal No.");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignPartnerModification(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '240';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Partner Data Modification';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogInit(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '260';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'JET Initialization';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignArchiveAttempt(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");
        if POSWorkshiftCheckpoint."Period Type" = YearlyPeriodType() then begin
            POSAuditLog."External Code" := '30';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            POSAuditLog."External Description" := 'Yearly Archive';
        end else begin
            POSAuditLog."External Code" := '20';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            POSAuditLog."External Description" := 'Period Archive';
        end;

        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSAuditLog."Additional Information" := Format(POSEntry."Fiscal No.");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogIn(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '80';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Log In';
        POSAuditLog."Additional Information" := Format(POSAuditLog."Active Salesperson Code");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogOut(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '40';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Log Out';
        POSAuditLog."Additional Information" := Format(POSAuditLog."Active Salesperson Code");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignItemRMA(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '190';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Ticket Voided/Item Returned';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignWorkshift(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");
        POSWorkshiftCheckpoint.TestField("POS Entry No.");
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSEntry.TestField("Salesperson Code");

        if not (POSWorkshiftCheckpoint.Type in [POSWorkshiftCheckpoint.Type::ZREPORT, POSWorkshiftCheckpoint.Type::PREPORT]) then
            exit;

        if (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::PREPORT) and (POSWorkshiftCheckpoint."Period Type" = YearlyPeriodType()) then begin
            POSAuditLog."External Code" := '60';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            POSAuditLog."External Description" := 'Year Closing';
        end else begin
            POSAuditLog."External Code" := '50';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then
                POSAuditLog."External Description" := 'Period Closing (Z-Report)'
            else
                POSAuditLog."External Description" := 'Period Closing (Month Report)';
        end;

        POSAuditLog."Additional Information" := Format(POSEntry."Fiscal No.");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    procedure SignEvent(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSAuditLogInit: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSAuditLog."Active POS Unit No." = '') then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No."; //Performing POS operation like JET init from backend, acting as the POS.
        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;
        LoadCertificate();

        //Shave off milliseconds from timestamp to prevent sql rounding on commit causing signature invalidation later.
        Evaluate(POSAuditLog."Log Timestamp", CopyStr(Format(POSAuditLog."Log Timestamp", 0, 9), 1, 19) + '.000Z', 9);

        if POSAuditLog."Action Type" <> POSAuditLog."Action Type"::LOG_INIT then
            GetJETInitRecord(POSAuditLogInit, POSUnit."No.", true); //Failsafe - first record MUST be JET INIT.

        case POSAuditLog."Action Type" of
            POSAuditLog."Action Type"::DIRECT_SALE_END:
                SignTicket(POSAuditLog); //Full sale amount is signed - but amounts other than Item & Rounding are diff'ed into custom JET event 910
            POSAuditLog."Action Type"::ARCHIVE_ATTEMPT:
                SignArchiveAttempt(POSAuditLog);
            POSAuditLog."Action Type"::RECEIPT_COPY:
                SignReprintTicket(POSAuditLog);
            POSAuditLog."Action Type"::SIGN_IN:
                SignLogIn(POSAuditLog);
            POSAuditLog."Action Type"::WORKSHIFT_END:
                SignWorkshift(POSAuditLog);
            POSAuditLog."Action Type"::DRAWER_COUNT:
                SignDrawerCount(POSAuditLog);
            POSAuditLog."Action Type"::PARTNER_MODIFICATION:
                SignPartnerModification(POSAuditLog);
            POSAuditLog."Action Type"::LOG_INIT:
                SignLogInit(POSAuditLog);
            POSAuditLog."Action Type"::AUDIT_VERIFY_ERROR:
                SignAuditVerifyError(POSAuditLog);
            POSAuditLog."Action Type"::GRANDTOTAL:
                SignGrandTotal(POSAuditLog); //Only item amount & item VAT amounts are stored and signed.
            POSAuditLog."Action Type"::ARCHIVE_CREATE:
                SignArchiveEvent(POSAuditLog);
            POSAuditLog."Action Type"::CANCEL_SALE_END:
                SignCancelSale(POSAuditLog);
            POSAuditLog."Action Type"::SIGN_OUT:
                SignLogOut(POSAuditLog); //Will not fire unless explicit logout, so not 100% reliable in a browser world.
            POSAuditLog."Action Type"::ITEM_RMA:
                SignItemRMA(POSAuditLog); //Fired for each RMA line with reference to original sale for full traceability.
            POSAuditLog."Action Type"::CUSTOM:

                case POSAuditLog."Action Custom Subtype" of
                    'NON_ITEM_AMOUNT':
                        SignNonItemAmount(POSAuditLog); //Diff between item amounts and everything else in a sale (prepayment, deposit, outpayment, vouchers)
                end;
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
            POSAuditLog."External Description" := 'Remboursement (Ticket)'
        else
            POSAuditLog."External Description" := 'Vente (Ticket)';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignGrandTotal(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
            Database::"NPR POS Workshift Checkpoint":
                begin
                    RecRef.SetTable(POSWorkshiftCheckpoint);
                    POSWorkshiftCheckpoint.Find();
                    if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then begin
                        POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_ZREPORT';
                        POSAuditLog."External Description" := 'Period Grand Total';
                        POSAuditLog."External ID" := GetNextEventNoSeries(2, POSWorkshiftCheckpoint."POS Unit No.");
                    end else
                        if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::PREPORT then
                            if POSWorkshiftCheckpoint."Period Type" = YearlyPeriodType() then begin
                                POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_YEAR';
                                POSAuditLog."External Description" := 'Yearly Grand Total';
                                POSAuditLog."External ID" := GetNextEventNoSeries(4, POSWorkshiftCheckpoint."POS Unit No.");
                            end else
                                if POSWorkshiftCheckpoint."Period Type" = MonthlyPeriodType() then begin
                                    POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_MONTH';
                                    POSAuditLog."External Description" := 'Monthly Grand Total';
                                    POSAuditLog."External ID" := GetNextEventNoSeries(3, POSWorkshiftCheckpoint."POS Unit No.");
                                end;
                    POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
                end;
            Database::"NPR POS Entry":
                begin
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find();
                    POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_TICKET';
                    POSAuditLog."External Description" := 'Ticket Grand Total';
                    POSAuditLog."External ID" := POSEntry."Fiscal No.";
                end;
        end;

        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'GRANDTOTAL';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignReprintTicket(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
    begin
        POSAuditLog."External ID" := GetNextEventNoSeries(1, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'DUPLICATE';
        POSAuditLog."External Description" := 'Ticket Reprint';

        POSEntryOutputLog.Get(POSAuditLog."Record ID");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignArchiveEvent(var POSAuditLog: Record "NPR POS Audit Log"): Text
    begin
        POSAuditLog."External ID" := '';
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'ARCHIVE';
        POSAuditLog."External Description" := 'Archive Creation';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignCancelSale(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '320';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Cancel Sale';
        POSAuditLog."Additional Information" := Format(POSAuditLog."Active Salesperson Code");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignNonItemAmount(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        POSAuditLog."External Code" := '910';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Non-item ticket sales amount';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure GetSaleTaxBreakdownString(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean) TaxBreakdown: Text
    var
        POSTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSTaxAmountLine2: Record "NPR POS Entry Tax Line";
        TempPOSTaxAmountLine: Record "NPR POS Entry Tax Line" temporary;
        VATIDFilter: Text;
    begin
        POSTaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");

        VATIDFilter := _FRCertificationSetup.GetItemVATIDFilter();
        if OnlyIncludeItems then
            POSTaxAmountLine.SetFilter("VAT Identifier", VATIDFilter);

        if POSTaxAmountLine.FindSet() then
            repeat
                //Select distinct tax % total

                TempPOSTaxAmountLine.SetRange("Tax %", POSTaxAmountLine."Tax %");
                if TempPOSTaxAmountLine.IsEmpty then begin
                    TempPOSTaxAmountLine."POS Entry No." += 1;
                    TempPOSTaxAmountLine."Tax %" := POSTaxAmountLine."Tax %";
                    TempPOSTaxAmountLine.Insert();

                    POSTaxAmountLine2.SetRange("POS Entry No.", POSEntry."Entry No.");
                    POSTaxAmountLine2.SetRange("Tax %", POSTaxAmountLine."Tax %");
                    if OnlyIncludeItems then
                        POSTaxAmountLine2.SetFilter("VAT Identifier", VATIDFilter);

                    POSTaxAmountLine2.CalcSums("Amount Including Tax");

                    if TaxBreakdown <> '' then
                        TaxBreakdown += '|';
                    TaxBreakdown += PadLeft(FormatNumeric(POSTaxAmountLine."Tax %"), 4, '0') + ':' + PadLeft(FormatNumeric(POSTaxAmountLine2."Amount Including Tax"), 4, '0');
                end;
            until POSTaxAmountLine.Next() = 0;
    end;

    local procedure GetSaleTotalInclTax(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean): Decimal
    begin
        if OnlyIncludeItems then
            exit(POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)")
        else
            exit(POSEntry."Amount Incl. Tax");
    end;

    local procedure GetSalePerpetualAbsoluteAmount(POSEntryIn: Record "NPR POS Entry"): Decimal
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Perpetual: Decimal;
    begin
        //Implied only include item amounts as per audit requirements.

        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '<%1', POSEntryIn."Entry No.");

        if POSWorkshiftCheckpoint.FindLast() then begin
            Perpetual := GetWorkshiftPerpetualAbsoluteAmount(POSWorkshiftCheckpoint);
            POSEntry.SetFilter("Entry No.", '>%1&<=%2', POSWorkshiftCheckpoint."POS Entry No.", POSEntryIn."Entry No.");
        end else
            POSEntry.SetFilter("Entry No.", '<=%1', POSEntryIn."Entry No.");

        POSEntry.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.CalcSums("Item Sales (LCY)", "Item Returns (LCY)");
        Perpetual += (POSEntry."Item Sales (LCY)" + Abs(POSEntry."Item Returns (LCY)"));

        exit(Perpetual);
    end;

    local procedure GetSalePerpetualAmount(POSEntryIn: Record "NPR POS Entry"): Decimal
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Perpetual: Decimal;
    begin
        //Implied only include item amounts as per audit requirements.

        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '<%1', POSEntryIn."Entry No.");
        if POSWorkshiftCheckpoint.FindLast() then begin
            Perpetual := GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint);
            POSEntry.SetFilter("Entry No.", '>%1&<=%2', POSWorkshiftCheckpoint."POS Entry No.", POSEntryIn."Entry No.");
        end else
            POSEntry.SetFilter("Entry No.", '<=%1', POSEntryIn."Entry No.");

        POSEntry.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.CalcSums("Item Sales (LCY)", "Item Returns (LCY)");
        Perpetual += (POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)");

        exit(Perpetual);
    end;

    local procedure GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint") TaxBreakdown: Text
    var
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        POSWorkshiftTaxCheckpoint2: Record "NPR POS Worksh. Tax Checkp.";
        TempPOSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary;
        VATIDFilter: Text;
    begin
        //Implied only include item amounts as per audit requirements.

        POSWorkshiftTaxCheckpoint.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        VATIDFilter := _FRCertificationSetup.GetItemVATIDFilter();
        POSWorkshiftTaxCheckpoint.SetFilter("VAT Identifier", VATIDFilter);
        if POSWorkshiftTaxCheckpoint.FindSet() then
            repeat
                //Select distinct tax % total

                TempPOSWorkshiftTaxCheckpoint.SetRange("Tax %", POSWorkshiftTaxCheckpoint."Tax %");
                if TempPOSWorkshiftTaxCheckpoint.IsEmpty then begin
                    TempPOSWorkshiftTaxCheckpoint."Entry No." += 1;
                    TempPOSWorkshiftTaxCheckpoint."Tax %" := POSWorkshiftTaxCheckpoint."Tax %";
                    TempPOSWorkshiftTaxCheckpoint.Insert();

                    POSWorkshiftTaxCheckpoint2.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
                    POSWorkshiftTaxCheckpoint2.SetRange("Tax %", POSWorkshiftTaxCheckpoint."Tax %");
                    POSWorkshiftTaxCheckpoint2.SetFilter("VAT Identifier", VATIDFilter);
                    POSWorkshiftTaxCheckpoint2.CalcSums("Amount Including Tax");

                    if TaxBreakdown <> '' then
                        TaxBreakdown += '|';
                    TaxBreakdown += PadLeft(FormatNumeric(POSWorkshiftTaxCheckpoint."Tax %"), 4, '0') + ':' + FormatNumeric(POSWorkshiftTaxCheckpoint2."Amount Including Tax");
                end;
            until POSWorkshiftTaxCheckpoint.Next() = 0;
    end;

    local procedure GetWorkshiftTotalInclTax(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Decimal
    begin
        //Implied only include item amounts as per audit requirements.

        exit(POSWorkshiftCheckpoint."Direct Item Sales (LCY)" + POSWorkshiftCheckpoint."Direct Item Returns (LCY)");
    end;

    local procedure GetWorkshiftPerpetualAbsoluteAmount(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Decimal
    begin
        //Implied only include item amounts as per audit requirements.

        exit(POSWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)" + Abs(POSWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)"));
    end;

    local procedure GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Decimal
    begin
        //Implied only include item amounts as per audit requirements.

        exit(POSWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)" + POSWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)");
    end;

    procedure ValidateAuditLogIntegrity(var POSAuditLog: Record "NPR POS Audit Log")
    var
        First: Boolean;
        InStream: InStream;
        BaseValue: Text;
        BaseValueChunk: Text;
        PreviousSignature: Text;
        PreviousSignatureChunk: Text;
        Signature: Text;
        SignatureChunk: Text;
    begin
        POSAuditLog.SetAutoCalcFields("Electronic Signature", "Previous Electronic Signature", "Signature Base Value");
        POSAuditLog.SetCurrentKey("Entry No.");
        POSAuditLog.SetAscending("Entry No.", true);
        POSAuditLog.LockTable();

        if POSAuditLog.FindSet() then
            repeat
                FillSignatureBaseValues(POSAuditLog, false);
                POSAuditLog.Modify();
            until POSAuditLog.Next() = 0;

        //Check signatures against fresh data strings/hash.
        //Perfoms actual data modifications on locked records that are ALWAYS rolled back at the end.
        if POSAuditLog.FindSet() then begin
            First := true;
            repeat
                Clear(PreviousSignature);
                POSAuditLog."Previous Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
                while (not InStream.EOS) do begin
                    InStream.ReadText(PreviousSignatureChunk);
                    PreviousSignature += PreviousSignatureChunk;
                end;
                Clear(InStream);

                if not First then
                    if PreviousSignature <> Signature then
                        Error(ERROR_SIGNATURE_CHAIN, POSAuditLog.TableCaption, POSAuditLog."Entry No.");

                Clear(Signature);
                POSAuditLog."Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
                while (not InStream.EOS) do begin
                    InStream.ReadText(SignatureChunk);
                    Signature += SignatureChunk;
                end;
                Clear(InStream);

                Clear(BaseValue);
                POSAuditLog."Signature Base Value".CreateInStream(InStream, TextEncoding::UTF8);
                while (not InStream.EOS) do begin
                    InStream.ReadText(BaseValueChunk);
                    BaseValue += BaseValueChunk;
                end;
                Clear(InStream);

#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
                if not VerifySignature(BaseValue, Enum::"Hash Algorithm"::SHA256, DecodeBase64URL(Signature)) then
                    Error(ERROR_SIGNATURE_VALUE, POSAuditLog.TableCaption, POSAuditLog."Entry No.");
#else
                if not VerifySignature(BaseValue, 'SHA256', DecodeBase64URL(Signature)) then
                    Error(ERROR_SIGNATURE_VALUE, POSAuditLog.TableCaption, POSAuditLog."Entry No.");
#endif

                First := false;
            until POSAuditLog.Next() = 0;
        end;

        Message(CAPTION_SIGNATURES_VALID, POSAuditLog.Count());
    end;

    procedure CreatePOSAuditLogAdditionalInfoRecord(POSAuditLog: Record "NPR POS Audit Log")
    var
        CompanyInformation: Record "Company Information";
        POSAuditLogAdditionalInfo: Record "NPR FR POS Audit Log Add. Info";
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        RecRef: RecordRef;
    begin
        CompanyInformation.Get();

        POSAuditLogAdditionalInfo.Init();
        POSAuditLogAdditionalInfo."POS Audit Log Entry No." := POSAuditLog."Entry No.";
#pragma warning disable AA0139
        POSAuditLogAdditionalInfo."NPR Version" := GetFiscalVersion();
#pragma warning restore AA0139
        RecRef.GetTable(CompanyInformation);
        if RecRef.FieldExist(10802) then
            POSAuditLogAdditionalInfo.APE := RecRef.Field(10802).Value;
        POSAuditLogAdditionalInfo."Intra-comm. VAT ID" := CompanyInformation."VAT Registration No.";
        if POSAuditLog."Acted on POS Entry No." <> 0 then begin
            POSEntry.Get(POSAuditLog."Acted on POS Entry No.");
            POSStore.Get(POSEntry."POS Store Code");
            SalespersonPurchaser.Get(POSEntry."Salesperson Code");

            POSAuditLogAdditionalInfo."Store Name" := POSStore.Name;
            POSAuditLogAdditionalInfo."Store Name 2" := POSStore."Name 2";
            POSAuditLogAdditionalInfo."Store Address" := POSStore.Address;
            POSAuditLogAdditionalInfo."Store Address 2" := POSStore."Address 2";
            POSAuditLogAdditionalInfo."Store Post Code" := POSStore."Post Code";
            POSAuditLogAdditionalInfo."Store City" := POSStore.City;
            POSAuditLogAdditionalInfo."Store Siret" := CopyStr(POSStore."Registration No.", 1, MaxStrLen(POSAuditLogAdditionalInfo."Store Siret"));
            POSAuditLogAdditionalInfo."Store Country/Region Code" := POSStore."Country/Region Code";
            POSAuditLogAdditionalInfo."Salesperson Name" := SalespersonPurchaser.Name;
        end;
        POSAuditLogAdditionalInfo.Insert();
    end;

    local procedure DecodeBase64URL(Text: Text): Text
    var
        Output: Text;
    begin
        Output := ConvertStr(Text, '_-', '/+');
        exit(PadStr(Output, (StrLen(Output) + (4 - StrLen(Output) mod 4) mod 4), '='));
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
        exit(Format(DateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Filler Character,0><Minutes,2><Seconds,2>'));
    end;

    local procedure FormatText(Text: Text): Text
    begin
        exit(ConvertStr(Text, ', ', ';_'));
    end;

    local procedure PadLeft(Text: Text; Length: Integer; PadChar: Text): Text
    var
        InputLength: Integer;
    begin
        InputLength := StrLen(Text);
        if InputLength >= Length then
            exit(Text);

        exit(PadStr('', Length - InputLength, PadChar) + Text);
    end;

    procedure MonthlyPeriodType(): Code[20]
    begin
        exit('FR_NF525_MONTH');
    end;

    procedure YearlyPeriodType(): Code[20]
    begin
        exit('FR_NF525_YEAR');
    end;

    procedure ImplementationCode(): Text[30]
    begin
        exit(CopyStr(HandlerCode() + '_' + GetFiscalVersion(), 1, 30));
    end;

    procedure GetJETInitRecord(var POSAuditLog: Record "NPR POS Audit Log"; POSUnitNo: Code[10]; WithError: Boolean): Boolean
    begin
        POSAuditLog.SetRange("Acted on POS Unit No.", POSUnitNo);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::LOG_INIT);
        POSAuditLog.SetRange("Handled by External Impl.", true);
        POSAuditLog.SetRange("External Type", 'JET');
        if WithError then begin
            POSAuditLog.FindFirst();
            exit(true);
        end else
            exit(POSAuditLog.FindFirst());
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

    procedure GetItemVATIdentifierFilter(CurrentValue: Text) NewValue: Text
    var
        VATPostingSetup: Record "VAT Posting Setup";
        FilterPageBuilder: FilterPageBuilder;
    begin
        FilterPageBuilder.AddRecord(VATPostingSetup.TableCaption, VATPostingSetup);

        if CurrentValue <> '' then begin
            VATPostingSetup.SetFilter("VAT Identifier", CurrentValue);
            FilterPageBuilder.SetView(VATPostingSetup.TableCaption, VATPostingSetup.GetView(false));
        end;

        if FilterPageBuilder.RunModal() then begin
            VATPostingSetup.Reset();
            VATPostingSetup.SetView(FilterPageBuilder.GetView(VATPostingSetup.TableCaption, false));
            exit(VATPostingSetup.GetFilter("VAT Identifier"));
        end;
    end;

    procedure Destruct()
    begin
#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
        Clear(_SignatureKey);
#else
        Clear(_X509Certificate2);
        Clear(_RSACryptoServiceProvider);
#endif
        Clear(_FRCertificationSetup);
        Clear(_Initialized);
        Clear(_Enabled);
        Clear(_CertificateLoaded);
    end;

#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
    procedure GenerateArchive(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; var TempBlob: Codeunit "Temp Blob")
    var
        SignedXml: Codeunit SignedXml;
        ArchiveBodyBlob: Codeunit "Temp Blob";
        FRPeriodArchive: XmlPort "NPR FR Audit Archive";
        IStream: InStream;
        OStream: OutStream;
        SignedArchive: XmlDocument;
        ArchiveRoot: XmlElement;
        SignatureELement: XmlElement;
        GrandPeriodNode: XmlNode;
        ReadOptions: XmlReadOptions;
        WriteOptions: XmlWriteOptions;
    begin
        LoadCertificate();

        POSWorkshiftCheckpoint.SetRecFilter();
        ArchiveBodyBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        FRPeriodArchive.SetDestination(OStream);
        FRPeriodArchive.SetTableView(POSWorkshiftCheckpoint);
        FRPeriodArchive.Export();

        ArchiveBodyBlob.CreateInStream(IStream, TextEncoding::UTF8);
        ReadOptions.PreserveWhitespace(false);
        XmlDocument.ReadFrom(IStream, ReadOptions, SignedArchive);
        SignedXml.InitializeSignedXml(SignedArchive);
        SignedXml.SetSigningKey(_SignatureKey);
        SignedXml.InitializeReference('');
        SignedXml.AddXmlDsigEnvelopedSignatureTransform();
        SignedXml.ComputeSignature();
        SignatureELement := SignedXml.GetXml();
        SignedArchive.GetRoot(ArchiveRoot);
        ArchiveRoot.GetChildElements().Get(1, GrandPeriodNode);
        GrandPeriodNode.AddAfterSelf(SignatureELement);

        Clear(OStream);
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        WriteOptions.PreserveWhitespace(true); //Keep whitespace that was signed intact.
        SignedArchive.WriteTo(WriteOptions, OStream);
    end;
#else
    procedure GenerateArchive(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; var TempBlob: Codeunit "Temp Blob")
    begin
        Error('Archiving is not supported from BC17 and BC18 before CU4 versions of npretail as the required Cryptography part of the system app is missing.');
    end;
#endif

    procedure GetFiscalVersion(): Text[21]
    begin
        //The fiscal version of NP Retail. This only changes when solution is updated to match new compliance requirements or compliance bugs are fixed.
        exit('NPRETAIL_FISCAL_V21.7');
    end;

    procedure GetComplianceVersion(): Text[30]
    begin
        //The version of the NF525 compliance ruleset that is implemented.
        exit('2.3')
    end;

    procedure GetCertificationNumber(): Text[30]
    begin
        //The number issued to NP Retail by infocert
        exit('0274-1 (B)');
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeDownloadArchive(TempBlob: Codeunit "Temp Blob"; var Handled: Boolean)
    begin
    end;
}