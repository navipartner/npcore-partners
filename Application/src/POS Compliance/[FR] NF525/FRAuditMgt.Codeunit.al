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
        ERROR_MISSING_SIGNATURE: Label '%1 %2 is missing a digital signature';
        ERROR_MISSING_KEY: Label 'The selected certificate does not contain the private key';
        ERROR_SIGNATURE_CHAIN: Label 'Broken signature chain for %1 entry %2';
        ERROR_SIGNATURE_VALUE: Label 'Invalid signature for %1 entry %2';
        ERROR_JET_INIT: Label 'JET has not been initialized for %1 %2. This must be done to comply with french NF525 regulations.';
        ERROR_VALIDATE_VERSION: Label 'Can only validate entries created for implementation %1';
        ERROR_VALIDATE_CERT: Label 'Can only validate entries signed with certificate thumbprint %1';
        CAPTION_OVERWRITE_CERT: Label 'Are you sure you want to overwrite the existing certificate?';
        CAPTION_CERT_SUCCESS: Label 'Certificate with thumbprint %1 was uploaded successfully';
        CAPTION_SIGNATURES_VALID: Label 'Chained signatures of %1 entries verified successfully';

    procedure HandlerCode(): Text[8]
    begin
        exit('FR_NF525');
    end;

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
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
    local procedure LoadCertificate()
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
        CryptoMgt: Codeunit "Cryptography Management";
        ConvertBase64: Codeunit "Base64 Convert";
        OutStr: OutStream;
        InStream: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        LoadCertificate();
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        ConvertBase64.FromBase64(SignatureBase64, OutStr);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        exit(CryptoMgt.VerifyData(Data, _SignatureKey, HashAlgo, InStream));
    end;

    procedure SignData(BaseValue: Text): Text
    var
        CryptoMgt: Codeunit "Cryptography Management";
        OutStr: OutStream;
        InStr: InStream;
        TempBLOB: Codeunit "Temp Blob";
        ConvertBase64: Codeunit "Base64 Convert";
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
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        FRCertificationNoSeries.Get(POSUnitNo);
        case EventType of
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
        end;
    end;

    local procedure TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; PeriodType: Code[20]; PeriodDateCalcFormula: DateFormula; var FromWorkshiftEntryOut: Integer): Boolean
    var
        POSWorkshifts: Record "NPR POS Workshift Checkpoint";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
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
        BaseValue: Text;
        PreviousSignature: Text;
        PreviousSignatureChunk: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        InStream: InStream;
        OutStream: OutStream;
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

        if IsInitialHandling then begin
            POSAuditLog."Original Signature Base Value" := POSAuditLog."Signature Base Value";
        end;
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
        TaxBreakdown: Text;
        TaxTotal: Decimal;
        POSEntry: Record "NPR POS Entry";
        FillTicketBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7', Locked = true;
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
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
        TaxBreakdown: Text;
        TaxTotal: Decimal;
        PerpetualAmount: Decimal;
        POSAuditLogAdditionalInformationLbl: Label '%1|%2|%3', Locked = true;
        FillGrandTotalBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7', Locked = true;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
            DATABASE::"NPR POS Workshift Checkpoint":
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
            DATABASE::"NPR POS Entry":
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
        ReprintNo: Integer;
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSEntryOutputLog2: Record "NPR POS Entry Output Log";
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
        TaxBreakdown: Text;
        TaxTotal: Decimal;
        FillArchiveFileBaseLbl: Label '%1,%2,%3,%4,%5,%6,%7', Locked = true;
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
        Signature: Text;
        OStream: OutStream;
        BaseValueChunk: Text;
        BaseValue: Text;
        IStream: InStream;
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
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
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
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
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
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
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

        if IsFullRMA(POSEntry) then begin
            POSAuditLog."External Description" := 'Cancellation (Ticket)'
        end else begin
            POSAuditLog."External Description" := 'Sale (Ticket)'
        end;

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignGrandTotal(var POSAuditLog: Record "NPR POS Audit Log")
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
            DATABASE::"NPR POS Workshift Checkpoint":
                begin
                    RecRef.SetTable(POSWorkshiftCheckpoint);
                    POSWorkshiftCheckpoint.Find();
                    if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then begin
                        POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_ZREPORT';
                        POSAuditLog."External Description" := 'Period Grand Total';
                        POSAuditLog."External ID" := GetNextEventNoSeries(2, POSWorkshiftCheckpoint."POS Unit No.");
                    end else
                        if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::PREPORT then begin
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
                        end;
                    POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
                end;
            DATABASE::"NPR POS Entry":
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
        if OnlyIncludeItems then begin
            exit(POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)")
        end else begin
            exit(POSEntry."Amount Incl. Tax");
        end;
    end;

    local procedure GetSalePerpetualAbsoluteAmount(POSEntryIn: Record "NPR POS Entry"): Decimal
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Perpetual: Decimal;
        POSEntry: Record "NPR POS Entry";
    begin
        //Implied only include item amounts as per audit requirements.

        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '<%1', POSEntryIn."Entry No.");

        if POSWorkshiftCheckpoint.FindLast() then begin
            Perpetual := GetWorkshiftPerpetualAbsoluteAmount(POSWorkshiftCheckpoint);
            POSEntry.SetFilter("Entry No.", '>%1&<=%2', POSWorkshiftCheckpoint."POS Entry No.", POSEntryIn."Entry No.");
        end else begin
            POSEntry.SetFilter("Entry No.", '<=%1', POSEntryIn."Entry No.");
        end;

        POSEntry.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.CalcSums("Item Sales (LCY)", "Item Returns (LCY)");
        Perpetual += (POSEntry."Item Sales (LCY)" + Abs(POSEntry."Item Returns (LCY)"));

        exit(Perpetual);
    end;

    local procedure GetSalePerpetualAmount(POSEntryIn: Record "NPR POS Entry"): Decimal
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Perpetual: Decimal;
        POSEntry: Record "NPR POS Entry";
    begin
        //Implied only include item amounts as per audit requirements.

        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '<%1', POSEntryIn."Entry No.");
        if POSWorkshiftCheckpoint.FindLast() then begin
            Perpetual := GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint);
            POSEntry.SetFilter("Entry No.", '>%1&<=%2', POSWorkshiftCheckpoint."POS Entry No.", POSEntryIn."Entry No.");
        end else begin
            POSEntry.SetFilter("Entry No.", '<=%1', POSEntryIn."Entry No.");
        end;

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

    local procedure CreatePOSAuditLogAdditionalInfoRecord(POSAuditLog: Record "NPR POS Audit Log")
    var
        POSAuditLogAdditionalInfo: Record "NPR FR POS Audit Log Add. Info";
        POSStore: Record "NPR POS Store";
        CompanyInformation: Record "Company Information";
        Licenseinformation: Codeunit "NPR License Information";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        RecRef: RecordRef;
        POSEntry: Record "NPR POS Entry";
    begin
        CompanyInformation.Get();

        POSAuditLogAdditionalInfo.Init();
        POSAuditLogAdditionalInfo."POS Audit Log Entry No." := POSAuditLog."Entry No.";
#pragma warning disable AA0139
        POSAuditLogAdditionalInfo."NPR Version" := Licenseinformation.GetRetailVersion();
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

    local procedure MonthlyPeriodType(): Code[20]
    begin
        exit('FR_NF525_MONTH');
    end;

    local procedure YearlyPeriodType(): Code[20]
    begin
        exit('FR_NF525_YEAR');
    end;

    local procedure ImplementationCode(): Text[30]
    begin
        exit(HandlerCode() + '_V5');
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
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        AddInfo: Text;
        Amount: Decimal;
        AddInfoLbl: Label '%1|%2', Locked = true;
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
        FilterPageBuilder: FilterPageBuilder;
        VATPostingSetup: Record "VAT Posting Setup";
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
        FRPeriodArchive: XMLport "NPR FR Audit Archive";
        OStream: OutStream;
        IStream: InStream;
        ArchiveBodyBlob: Codeunit "Temp BLob";
        SignedArchive: XmlDocument;
        SignedXml: Codeunit SignedXml;
        SignatureELement: XmlElement;
        ArchiveRoot: XmlElement;
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
        SignatureElement := SignedXml.GetXml();
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := HandlerCode();
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnArchiveWorkshiftPeriod', '', true, true)]
    local procedure OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
        POSUnit: Record "NPR POS Unit";
        Handled: Boolean;
    begin
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSWorkshiftCheckpoint.TestField(Type, POSWorkshiftCheckpoint.Type::PREPORT);
        POSWorkshiftCheckpoint.TestField("Period Type", MonthlyPeriodType());

        GenerateArchive(POSWorkshiftCheckpoint, TempBlob);

        OnBeforeDownloadArchive(TempBlob, Handled);
        if Handled then
            exit;

        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        FileName := 'Archive.xml';
        DownloadFromStream(InStream, 'Download Archive', '', '', FileName);
        Clear(InStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditLogInit: Record "NPR POS Audit Log";
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
                begin
                    case POSAuditLog."Action Custom Subtype" of
                        'NON_ITEM_AMOUNT':
                            SignNonItemAmount(POSAuditLog); //Diff between item amounts and everything else in a sale (prepayment, deposit, outpayment, vouchers)
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogAfterInsert', '', false, false)]
    local procedure OnHandleAuditLogAfterInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        CreatePOSAuditLogAdditionalInfoRecord(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Aux: Event Publishers", 'OnSalesReceiptFooter', '', true, true)]
    local procedure OnReceiptFooter(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text; LinePrintMgt: Codeunit "NPR RP Line Print Mgt.")
    var
        POSEntry: Record "NPR POS Entry";
        AuditLog: Record "NPR POS Audit Log";
        PrintSignature: Text;
        InStream: InStream;
        Signature: Text;
        SignatureChunk: Text;
        POSUnit: Record "NPR POS Unit";
        Licenseinformation: Codeunit "NPR License Information";
    begin
        POSEntry.SetRange("Document No.", ReceiptNo);
        if not POSEntry.FindFirst() then
            exit;
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        LinePrintMgt.SetFont(TemplateLine."Type Option");
        LinePrintMgt.SetBold(TemplateLine.Bold);
        LinePrintMgt.SetUnderLine(TemplateLine.Underline);

        AuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        AuditLog.SetRange("Action Type", AuditLog."Action Type"::RECEIPT_COPY);
        AuditLog.SetAutoCalcFields("Electronic Signature");
        if not AuditLog.FindLast() then begin
            AuditLog.SetRange("Action Type", AuditLog."Action Type"::DIRECT_SALE_END);
            if not AuditLog.FindLast() then
                exit;
        end;

        if not AuditLog."Electronic Signature".HasValue() then
            Error(ERROR_MISSING_SIGNATURE, POSEntry.TableCaption, POSEntry."Entry No.");

        AuditLog."Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(SignatureChunk);
            Signature += SignatureChunk;
        end;

        LinePrintMgt.AddTextField(1, TemplateLine.Align, Format(AuditLog."Log Timestamp", 0, 3));
        PrintSignature := CopyStr(Signature, 3, 1) + CopyStr(Signature, 7, 1) + CopyStr(Signature, 13, 1) + CopyStr(Signature, 19, 1);
        LinePrintMgt.AddTextField(1, TemplateLine.Align, PrintSignature);
        LinePrintMgt.AddTextField(1, TemplateLine.Align, 'NF525/0274-1 (B)');
        LinePrintMgt.AddTextField(1, TemplateLine.Align, Licenseinformation.GetRetailVersion());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnValidateLogRecords', '', true, true)]
    local procedure OnValidateLogRecords(var POSAuditLog: Record "NPR POS Audit Log"; var Handled: Boolean; var Error: Boolean)
    var
        BaseValue: Text;
        BaseValueChunk: Text;
        Signature: Text;
        SignatureChunk: Text;
        PreviousSignature: Text;
        PreviousSignatureChunk: Text;
        InStream: InStream;
        First: Boolean;
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSAuditLog.FindFirst() then
            exit;
        if POSAuditLog."Active POS Unit No." = '' then
            exit;
        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        Handled := true;
        Error := true;

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
        Error := false;
        Error(''); //Rollback modifications to entries done while recalculating & verifying signature.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workshift Checkpoint", 'OnAfterCreateBalancingEntry', '', false, false)]
    local procedure OnAfterCreateBalancingEntry(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpointMgt: Codeunit "NPR POS Workshift Checkpoint";
        FromWorkshiftEntry: Integer;
    begin
        if POSWorkshiftCheckpoint."POS Unit No." = '' then
            exit;
        if POSWorkshiftCheckpoint.Type <> POSWorkshiftCheckpoint.Type::ZREPORT then
            exit;
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");

        if TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint, MonthlyPeriodType(), _FRCertificationSetup."Monthly Workshift Duration", FromWorkshiftEntry) then
            POSWorkshiftCheckpointMgt.CreatePeriodCheckpoint(POSWorkshiftCheckpoint."POS Entry No.", POSUnit."No.", FromWorkshiftEntry, POSWorkshiftCheckpoint."Entry No.", MonthlyPeriodType());

        if TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint, YearlyPeriodType(), _FRCertificationSetup."Yearly Workshift Duration", FromWorkshiftEntry) then
            POSWorkshiftCheckpointMgt.CreatePeriodCheckpoint(POSWorkshiftCheckpoint."POS Entry No.", POSUnit."No.", FromWorkshiftEntry, POSWorkshiftCheckpoint."Entry No.", YearlyPeriodType());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Setup Safety Check", 'OnAfterValidateSetup', '', false, false)]
    local procedure OnBeforeLogin()
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditLog: Record "NPR POS Audit Log";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        FRAuditSetup: Record "NPR FR Audit Setup";
        FRAuditNoSeries: Record "NPR FR Audit No. Series";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSAuditProfile: Record "NPR POS Audit Profile";
        FRAuditNoSeries2: Record "NPR FR Audit No. Series";
        POSStore: Record "NPR POS Store";
        CompanyInformation: Record "Company Information";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        VATIDFilter: Text;
        NoVATIDFilterErr: Label '%1 must not be empty.';
    begin
        //Error upon POS login if any configuration is missing or clearly not set according to compliance

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not GetJETInitRecord(POSAuditLog, POSUnit."No.", false) then
            Error(ERROR_JET_INIT, POSUnit.TableCaption, POSUnit."No.");

        FRAuditSetup.Get();
        FRAuditSetup.TestField("Monthly Workshift Duration");
        FRAuditSetup.TestField("Yearly Workshift Duration");
        FRAuditSetup.TestField("Signing Certificate Thumbprint");
        FRAuditSetup.TestField("Auto Archive URL");
        FRAuditSetup.TestField("Auto Archive API Key");

        VATIDFilter := FRAuditSetup.GetItemVATIDFilter();
        if VATIDFilter = '' then
            Error(NoVATIDFilterErr, FRAuditSetup.FieldCaption("Item VAT ID Filter"));

        FRAuditNoSeries.Get(POSUnit."No.");
        FRAuditNoSeries.TestField("Reprint No. Series");
        FRAuditNoSeries.TestField("JET No. Series");
        FRAuditNoSeries.TestField("Period No. Series");
        FRAuditNoSeries.TestField("Grand Period No. Series");
        FRAuditNoSeries.TestField("Yearly Period No. Series");

        FRAuditNoSeries2.SetFilter("POS Unit No.", '<>%1', POSUnit."No.");

        FRAuditNoSeries2.SetRange("Reprint No. Series", FRAuditNoSeries."Reprint No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Reprint No. Series");
        FRAuditNoSeries2.SetRange("Reprint No. Series");

        FRAuditNoSeries2.SetRange("JET No. Series", FRAuditNoSeries."JET No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("JET No. Series");
        FRAuditNoSeries2.SetRange("JET No. Series");

        FRAuditNoSeries2.SetRange("Period No. Series", FRAuditNoSeries."Period No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Period No. Series");
        FRAuditNoSeries2.SetRange("Period No. Series");

        FRAuditNoSeries2.SetRange("Grand Period No. Series", FRAuditNoSeries."Grand Period No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Grand Period No. Series");
        FRAuditNoSeries2.SetRange("Grand Period No. Series");

        FRAuditNoSeries2.SetRange("Yearly Period No. Series", FRAuditNoSeries."Yearly Period No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Yearly Period No. Series");
        FRAuditNoSeries2.SetRange("Yearly Period No. Series");

        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile.TestField("Sale Fiscal No. Series");
        POSAuditProfile.TestField("Credit Sale Fiscal No. Series");
        POSAuditProfile.TestField("Balancing Fiscal No. Series");
        POSAuditProfile.TestField("Fill Sale Fiscal No. On", POSAuditProfile."Fill Sale Fiscal No. On"::Successful);
        POSAuditProfile.TestField("Print Receipt On Sale Cancel", false);
        POSAuditProfile.TestField("Do Not Print Receipt on Sale", false);
        POSAuditProfile.TestField("Allow Zero Amount Sales", false);
        POSAuditProfile.TestField("Require Item Return Reason", true);


        if POSEndofDayProfile.Get(POSUnit."POS End of Day Profile") then begin
            POSEndofDayProfile.TestField(POSEndofDayProfile."End of Day Type", POSEndofDayProfile."End of Day Type"::INDIVIDUAL);
        end;

        POSStore.Get(POSUnit."POS Store Code");
        POSStore.TestField("Registration No.");
        POSStore.TestField("Country/Region Code");

        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
        RecRef.GetTable(CompanyInformation);
        if RecRef.FieldExist(10802) then begin
            FieldRef := RecRef.Field(10802);
            FieldRef.TestField();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnGetDisplayVersion', '', false, false)]
    local procedure OnGetDisplayVersion(var DisplayVersion: Text)
    var
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        VersionLbl: Label 'NF525/0274-1 (B)', Locked = true;
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        DisplayVersion += ',' + VersionLbl;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnShowAdditionalInfo', '', false, false)]
    local procedure OnShowAdditionalInfo(POSAuditLog: Record "NPR POS Audit Log")
    var
        POSAuditLogAddInfo: Record "NPR FR POS Audit Log Add. Info";
    begin
        if POSAuditLog."External Implementation" <> ImplementationCode() then
            exit;

        //Open "aux. info" table for TICKET events due to legacy. 
        //Everything else is in "add. info" table that is newer and more flexible
        case POSAuditLog."External Type" of
            'TICKET',
            'JET',
            'GRANDTOTAL',
            'DUPLICATE',
            'ARCHIVE':
                begin
                    POSAuditLogAddInfo.SetRange("POS Audit Log Entry No.", POSAuditLog."Entry No.");
                    Page.RunModal(Page::"NPR FR POS Audit Log Add. Info", POSAuditLogAddInfo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workshift Checkpoint", 'OnDefineIfReceiptCopyStatisticsMustBeCalculated', '', false, false)]
    local procedure EOD_CalcReceiptCopyStatistics(AuditHandler: Code[20]; var Calculate: Boolean; var Handled: Boolean)
    begin
        if AuditHandler <> HandlerCode() then
            exit;
        Calculate := true;
        Handled := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDownloadArchive(TempBlob: Codeunit "Temp Blob"; var Handled: Boolean)
    begin
    end;
}