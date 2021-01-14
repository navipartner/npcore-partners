codeunit 6184850 "NPR FR Audit Mgt."
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.49/MMV /20190306 CASE 348167 Skip footer if no POS entry
    // NPR5.51/MMV /20190611 CASE 356076 French regulation, 2nd audit.
    // NPR5.55/MMV /20200626 CASE 408900 French regulation, 3rd audit.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        FRCertificationSetup: Record "NPR FR Audit Setup";
        X509Certificate2: DotNet NPRNetX509Certificate2;
        RSACryptoServiceProvider: DotNet NPRNetRSACryptoServiceProvider;
        Initialized: Boolean;
        ERROR_MISSING_SIGNATURE: Label '%1 %2 is missing a digital signature';
        Enabled: Boolean;
        CertificateLoaded: Boolean;
        ERROR_MISSING_KEY: Label 'The selected certificate does not contain the private key';
        ERROR_SIGNATURE_CHAIN: Label 'Broken signature chain for %1 entry %2';
        ERROR_SIGNATURE_VALUE: Label 'Invalid signature for %1 entry %2';
        ERROR_JET_INIT: Label 'JET has not been initialized for %1 %2. This must be done to comply with french NF525 regulations.';
        ERROR_VALIDATE_VERSION: Label 'Can only validate entries created for implementation %1';
        ERROR_VALIDATE_CERT: Label 'Can only validate entries signed with certificate thumbprint %1';
        CAPTION_JET: Label 'Initialize JET for %1 %2 ?';
        CAPTION_PARTNER_MOD: Label 'Modification description';
        CAPTION_OVERWRITE_CERT: Label 'Are you sure you want to overwrite the existing certificate?';
        CAPTION_CERT_SUCCESS: Label 'Certificate with thumbprint %1 was uploaded successfully';
        CAPTION_SIGNATURES_VALID: Label 'Chained signatures of %1 entries verified successfully';

    local procedure HandlerCode(): Text
    begin
        exit('FR_NF525');
    end;

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not Initialized then begin
            //-NPR5.51 [356076]
            //  Initialized := TRUE;
            //+NPR5.51 [356076]
            if not POSAuditProfile.Get(POSAuditProfileCode) then
                exit(false);
            if POSAuditProfile."Audit Handler" <> HandlerCode() then
                exit(false);
            FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
            FRCertificationSetup.Get;
            //-NPR5.51 [356076]
            Initialized := true;
            //+NPR5.51 [356076]
            Enabled := true;
        end;
        exit(Enabled);
    end;

    local procedure LoadCertificate()
    var
        InStream: InStream;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        if not CertificateLoaded then begin
            FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
            FRCertificationSetup.Get;
            FRCertificationSetup.TestField("Signing Certificate Thumbprint");
            FRCertificationSetup.TestField("Signing Certificate Password");

            FRCertificationSetup."Signing Certificate".CreateInStream(InStream);
            MemoryStream := MemoryStream.MemoryStream();
            CopyStream(MemoryStream, InStream);
            X509Certificate2 := X509Certificate2.X509Certificate2(MemoryStream.ToArray(), FRCertificationSetup."Signing Certificate Password");
            RSACryptoServiceProvider := X509Certificate2.PrivateKey;
            CertificateLoaded := true;
        end;
    end;

    procedure VerifySignature(Data: Text; HashAlgo: Text; SignatureBase64: Text): Boolean
    var
        CryptoConfig: DotNet NPRNetCryptoConfig;
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
    begin
        LoadCertificate();
        exit(RSACryptoServiceProvider.VerifyData(Encoding.Unicode.GetBytes(Data), CryptoConfig.MapNameToOID(HashAlgo), Convert.FromBase64String(SignatureBase64)));
    end;

    procedure GetLastUnitEventSignature(POSUnitNo: Code[10]; var POSAuditLogOut: Record "NPR POS Audit Log"; ExternalType: Code[20]): Boolean
    begin
        POSAuditLogOut.SetAutoCalcFields("Electronic Signature");
        POSAuditLogOut.SetCurrentKey("Active POS Unit No.", "External Type");
        POSAuditLogOut.SetRange("Active POS Unit No.", POSUnitNo);
        POSAuditLogOut.SetRange("External Type", ExternalType);
        exit(POSAuditLogOut.FindLast);
    end;

    local procedure GetNextEventNoSeries(EventType: Option JET,Reprint,Period,MonthPeriod,YearPeriod; POSUnitNo: Code[10]): Text
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
            //-NPR5.51 [356076]
            EventType::YearPeriod:
                exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Yearly Period No. Series", Today, true));
        //+NPR5.51 [356076]
        end;
    end;

    procedure SignHash(BaseHash: Text): Text
    var
        CryptoConfig: DotNet NPRNetCryptoConfig;
        Convert: DotNet NPRNetConvert;
    begin
        exit(Convert.ToBase64String(RSACryptoServiceProvider.SignHash(Convert.FromBase64String(BaseHash), CryptoConfig.MapNameToOID('SHA1'))));
    end;

    procedure CalculateHash(BaseValue: Text): Text
    var
        SHA1CryptoServiceProvider: DotNet NPRNetSHA1CryptoServiceProvider;
        Encoding: DotNet NPRNetEncoding;
        Convert: DotNet NPRNetConvert;
    begin
        SHA1CryptoServiceProvider := SHA1CryptoServiceProvider.SHA1CryptoServiceProvider();
        exit(Convert.ToBase64String(SHA1CryptoServiceProvider.ComputeHash(Encoding.Unicode.GetBytes(BaseValue))));
    end;

    procedure ImportCertificate()
    var
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text;
        X509Certificate2: DotNet NPRNetX509Certificate2;
        MemoryStream: DotNet NPRNetMemoryStream;
        RSACryptoServiceProvider: DotNet NPRNetRSACryptoServiceProvider;
    begin
        FRCertificationSetup.Get;
        if FRCertificationSetup."Signing Certificate".HasValue then begin
            if not Confirm(CAPTION_OVERWRITE_CERT) then
                exit;
            Clear(FRCertificationSetup."Signing Certificate");
        end;

        FRCertificationSetup."Signing Certificate".CreateOutStream(OutStream);
        if not UploadIntoStream('Upload Certificate', '', 'Certificate File (*.PFX)|*.PFX', FileName, InStream) then
            exit;

        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);

        X509Certificate2 := X509Certificate2.X509Certificate2(MemoryStream.ToArray(), FRCertificationSetup."Signing Certificate Password");
        if (not X509Certificate2.HasPrivateKey) then
            Error(ERROR_MISSING_KEY);
        RSACryptoServiceProvider := X509Certificate2.PrivateKey;

        FRCertificationSetup."Signing Certificate Thumbprint" := X509Certificate2.Thumbprint;

        MemoryStream.Position := 0;
        CopyStream(OutStream, MemoryStream);

        FRCertificationSetup.Modify(true);

        Message(CAPTION_CERT_SUCCESS, FRCertificationSetup."Signing Certificate Thumbprint");
    end;

    local procedure TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; PeriodType: Code[20]; PeriodDateCalcFormula: DateFormula; var FromWorkshiftEntryOut: Integer): Boolean
    var
        POSWorkshifts: Record "NPR POS Workshift Checkpoint";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        //-NPR5.51 [356076]
        POSWorkshifts.SetRange("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSWorkshifts.SetRange(Type, POSWorkshifts.Type::PREPORT);
        POSWorkshifts.SetRange("Period Type", PeriodType);
        //-NPR5.55 [408900]
        POSWorkshifts.SetRange(Open, false);
        POSWorkshifts.SetFilter("POS Entry No.", '<>%1', 0);
        //+NPR5.55 [408900]
        if not POSWorkshifts.FindLast then begin
            //Find the first workshift created after JET was initialized in-case we have old workshifts that should not be handled.
            GetJETInitRecord(POSAuditLog, POSWorkshiftCheckpoint."POS Unit No.", true);

            POSWorkshifts.SetRange("Period Type");
            POSWorkshifts.SetRange(Type, POSWorkshifts.Type::ZREPORT);
            //-NPR5.55 [408900]
            POSWorkshifts.SetFilter("POS Entry No.", '>=%1&<>%2', POSAuditLog."Acted on POS Entry No.", 0);
            //+NPR5.55 [408900]
            if not POSWorkshifts.FindFirst then
                exit(false);
        end;
        FromWorkshiftEntryOut := POSWorkshifts."Entry No.";

        //-NPR5.55 [408900]
        POSEntry.Get(POSWorkshifts."POS Entry No.");
        exit(CalcDate(PeriodDateCalcFormula, POSEntry."Document Date") <= Today);
        //+NPR5.55 [408900]
        //+NPR5.51 [356076]
    end;

    local procedure "---Fill Base Values"()
    begin
    end;

    procedure FillSignatureBaseValues(var POSAuditLog: Record "NPR POS Audit Log"; IsInitialHandling: Boolean)
    var
        BaseValue: Text;
        PreviousSignature: Text;
        BaseHash: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if IsInitialHandling then begin
            if GetLastUnitEventSignature(POSAuditLog."Active POS Unit No.", PreviousEventLogRecord, POSAuditLog."External Type") then
                POSAuditLog."Previous Electronic Signature" := PreviousEventLogRecord."Electronic Signature";
            //-NPR5.51 [356076]
            POSAuditLog."External Implementation" := ImplementationCode();
            //+NPR5.51 [356076]
            POSAuditLog."Certificate Implementation" := 'RSA_2048_SHA1';
            POSAuditLog."Certificate Thumbprint" := FRCertificationSetup."Signing Certificate Thumbprint";
            POSAuditLog."Handled by External Impl." := true;
        end;

        //-NPR5.51 [356076]
        if POSAuditLog."External Implementation" <> ImplementationCode() then //Can only validate the current version of the implementation as the rules & fields might have changed over time.
            Error(ERROR_VALIDATE_VERSION, ImplementationCode);

        if POSAuditLog."Certificate Thumbprint" <> FRCertificationSetup."Signing Certificate Thumbprint" then
            Error(ERROR_VALIDATE_CERT, FRCertificationSetup."Signing Certificate Thumbprint");
        //+NPR5.51 [356076]

        POSAuditLog."Previous Electronic Signature".CreateInStream(InStream);
        while (not InStream.EOS) do
            InStream.ReadText(PreviousSignature);

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

        POSAuditLog."Signature Base Value".CreateOutStream(OutStream);
        OutStream.WriteText(BaseValue);
        POSAuditLog."Signature Base Hash" := EncodeBase64URL(CalculateHash(BaseValue));

        if IsInitialHandling then begin
            POSAuditLog."Original Signature Base Hash" := POSAuditLog."Signature Base Hash";
            POSAuditLog."Original Signature Base Value" := POSAuditLog."Signature Base Value";
        end;
    end;

    local procedure FillJETBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    begin
        with POSAuditLog do
            //-NPR5.51 [356076]
            //  EXIT(STRSUBSTNO('%1,%2,%3,%4,%5,%6,%7,%8,%9',
            exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7,%8',
              //+NPR5.51 [356076]
              FormatAlphanumeric("External ID"),
              "External Code",
              FormatAlphanumeric("Additional Information"),
              FormatDatetime("Log Timestamp"),
              FormatAlphanumeric("Active Salesperson Code"),
              FormatAlphanumeric("Active POS Unit No."),
              //-NPR5.51 [356076]
              //    '',
              //+NPR5.51 [356076]
              Format((PreviousSignature <> ''), 0, 2),
              FormatText(PreviousSignature)));
    end;

    local procedure FillTicketBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        TaxBreakdown: Text;
        TaxTotal: Decimal;
        POSEntry: Record "NPR POS Entry";
        Licenceinformation: Codeunit "NPR License Information";
    begin
        POSEntry.Get(POSAuditLog."Record ID");

        //-NPR5.51 [356076]
        TaxBreakdown := GetSaleTaxBreakdownString(POSEntry, false);
        TaxTotal := GetSaleTotalInclTax(POSEntry, false);
        //+NPR5.51 [356076]

        with POSAuditLog do
            exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
              FormatAlphanumeric(TaxBreakdown),
              FormatNumeric(TaxTotal),
              FormatDatetime("Log Timestamp"),
              FormatAlphanumeric("Acted on POS Entry Fiscal No."),
              //-NPR5.51 [356076]
              POSAuditLog."External Description",
              //+NPR5.51 [356076]
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
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
            DATABASE::"NPR POS Workshift Checkpoint":
                begin
                    RecRef.SetTable(POSWorkshiftCheckpoint);
                    POSWorkshiftCheckpoint.Find;
                    //-NPR5.51 [356076]
                    TaxBreakdown := GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint);
                    TaxTotal := GetWorkshiftTotalInclTax(POSWorkshiftCheckpoint);
                    //+NPR5.51 [356076]
                    POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
                    //-NPR5.51 [356076]
                    PerpetualAmount := GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint);
                    POSAuditLog."Additional Information" := StrSubstNo('%1|%2|%3',
                        Format(TaxTotal, 0, '<Precision,2:2><Standard Format,9>'),
                        Format(GetWorkshiftPerpetualAbsoluteAmount(POSWorkshiftCheckpoint), 0, '<Precision,2:2><Standard Format,9>'),
                        Format(PerpetualAmount, 0, '<Precision,2:2><Standard Format,9>'));
                    //+NPR5.51 [356076]
                end;
            DATABASE::"NPR POS Entry":
                begin
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find;
                    //-NPR5.51 [356076]
                    TaxBreakdown := GetSaleTaxBreakdownString(POSEntry, true);
                    TaxTotal := GetSaleTotalInclTax(POSEntry, true);
                    PerpetualAmount := GetSalePerpetualAmount(POSEntry);
                    POSAuditLog."Additional Information" := StrSubstNo('%1|%2|%3',
                        Format(TaxTotal, 0, '<Precision,2:2><Standard Format,9>'),
                        Format(GetSalePerpetualAbsoluteAmount(POSEntry), 0, '<Precision,2:2><Standard Format,9>'),
                        Format(PerpetualAmount, 0, '<Precision,2:2><Standard Format,9>'));
                    //+NPR5.51 [356076]
                end;
        end;

        with POSAuditLog do
            //-NPR5.51 [356076]
            exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
              //+NPR5.51 [356076]
              FormatAlphanumeric(TaxBreakdown),
              FormatNumeric(TaxTotal),
              //-NPR5.51 [356076]
              FormatNumeric(PerpetualAmount),
              //+NPR5.51 [356076]
              FormatDatetime("Log Timestamp"),
              FormatAlphanumeric(POSEntry."Fiscal No."),
              Format((PreviousSignature <> ''), 0, 2),
              FormatText(PreviousSignature)));
    end;

    local procedure FillDuplicatePrintBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        ReprintNo: Integer;
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSEntryOutputLog2: Record "NPR POS Entry Output Log";
    begin
        POSEntryOutputLog.Get(POSAuditLog."Record ID");

        POSEntryOutputLog2.SetRange("POS Entry No.", POSAuditLog."Acted on POS Entry No.");
        POSEntryOutputLog2.SetRange("Output Method", POSEntryOutputLog2."Output Method"::Print);
        POSEntryOutputLog2.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog2."Output Type"::SalesReceipt, POSEntryOutputLog2."Output Type"::LargeSalesReceipt);
        if POSEntryOutputLog2.FindSet then
            repeat
                ReprintNo += 1;
            until (POSEntryOutputLog2.Next = 0) or (POSEntryOutputLog."Entry No." = POSEntryOutputLog2."Entry No.");

        POSAuditLog."Additional Information" := Format(ReprintNo);

        with POSAuditLog do
            exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7,%8',
              FormatAlphanumeric("External ID"),
              'Ticket',
              POSAuditLog."Additional Information",
              FormatAlphanumeric("Active Salesperson Code"),
              FormatDatetime("Log Timestamp"),
              FormatAlphanumeric(POSAuditLog."Acted on POS Entry Fiscal No."),
              Format((PreviousSignature <> ''), 0, 2),
              FormatText(PreviousSignature)));
    end;

    local procedure FillArchiveFileBase(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text): Text
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        TaxBreakdown: Text;
        TaxTotal: Decimal;
    begin
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");

        //-NPR5.51 [356076]
        TaxBreakdown := GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint);
        TaxTotal := GetWorkshiftTotalInclTax(POSWorkshiftCheckpoint);
        //+NPR5.51 [356076]

        with POSAuditLog do
            exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
              FormatAlphanumeric(TaxBreakdown),
              FormatNumeric(TaxTotal),
              FormatDatetime("Log Timestamp"),
              FormatAlphanumeric("Active POS Unit No."),
              'Archive',
              Format((PreviousSignature <> ''), 0, 2),
              FormatText(PreviousSignature)));
    end;

    local procedure "---Sign"()
    begin
    end;

    local procedure SignRecord(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseHash: Text;
        Signature: Text;
        OutStream: OutStream;
    begin
        Signature := SignHash(DecodeBase64URL(POSAuditLog."Signature Base Hash"));
        POSAuditLog."Electronic Signature".CreateOutStream(OutStream);
        OutStream.WriteText(EncodeBase64URL(Signature));
    end;

    local procedure SignAuditVerify(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '90';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Signature verification';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignDataExport(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSAuditLog."External Code" := '110';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Data Export';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignDataImport(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSAuditLog."External Code" := '140';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Data Export';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignPermissionModify(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSAuditLog."External Code" := '130';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'User permission modification';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignDrawerCount(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
    begin
        POSAuditLog."External Code" := '170';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Cash Drawer Counting';
        //-NPR5.51 [356076]
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSAuditLog."Additional Information" := Format(POSEntry."Fiscal No.");
        //+NPR5.51 [356076]

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignDataPurge(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSAuditLog."External Code" := '200';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Data Purge';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignPartnerModification(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '240';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Partner Data Modification';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogInit(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSAuditLog."External Code" := '260';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'JET Initialization';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignComplianceModification(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '270';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Compliance Data Modification';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignSetupModification(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSAuditLog."External Code" := '300';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'POS Setup Data Modification';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignArchiveAttempt(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
    begin
        //-NPR5.51 [356076]
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");
        if POSWorkshiftCheckpoint."Period Type" = YearlyPeriodType() then begin
            POSAuditLog."External Code" := '30';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            POSAuditLog."External Description" := 'Yearly Archive';
        end else begin
            //+NPR5.51 [356076]
            POSAuditLog."External Code" := '20';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            POSAuditLog."External Description" := 'Period Archive';
        end;

        //-NPR5.51 [356076]
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSAuditLog."Additional Information" := Format(POSEntry."Fiscal No.");
        //+NPR5.51 [356076]

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogIn(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        Licenceinformation: Codeunit "NPR License Information";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '80';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Log In';
        //-NPR5.51 [356076]
        POSAuditLog."Additional Information" := Format(POSAuditLog."Active Salesperson Code");
        //+NPR5.51 [356076]

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogOut(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '40';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Log Out';
        //-NPR5.51 [356076]
        POSAuditLog."Additional Information" := Format(POSAuditLog."Active Salesperson Code");
        //+NPR5.51 [356076]

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignItemRMA(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        //-NPR5.51 [356076]
        POSAuditLog."External Code" := '190';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Ticket Voided/Item Returned';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
        //+NPR5.51 [356076]
    end;

    local procedure SignWorkshift(var POSAuditLog: Record "NPR POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSWorkshiftCheckpoint.Get(POSAuditLog."Record ID");
        POSWorkshiftCheckpoint.TestField("POS Entry No.");
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSEntry.TestField("Salesperson Code");

        //-NPR5.51 [356076]
        if not (POSWorkshiftCheckpoint.Type in [POSWorkshiftCheckpoint.Type::ZREPORT, POSWorkshiftCheckpoint.Type::PREPORT]) then
            exit;
        //+NPR5.51 [356076]

        //-NPR5.51 [356076]
        if (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::PREPORT) and (POSWorkshiftCheckpoint."Period Type" = YearlyPeriodType()) then begin
            POSAuditLog."External Code" := '60';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            POSAuditLog."External Description" := 'Year Closing';
        end else begin
            //+NPR5.51 [356076]
            POSAuditLog."External Code" := '50';
            POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
            POSAuditLog."External Type" := 'JET';
            //-NPR5.51 [356076]
            if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then
                POSAuditLog."External Description" := 'Period Closing (Z-Report)'
            else
                POSAuditLog."External Description" := 'Period Closing (Month Report)';
            //+NPR5.51 [356076]
        end;

        //-NPR5.51 [356076]
        POSAuditLog."Additional Information" := Format(POSEntry."Fiscal No.");
        //+NPR5.51 [356076]

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignTicket(var POSAuditLog: Record "NPR POS Audit Log")
    var
        RecRef: RecordRef;
        POSEntry: Record "NPR POS Entry";
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
    begin
        POSEntry.Get(POSAuditLog."Record ID");

        //-NPR5.51 [356076]
        //TICKET event might also trigger a "Non-item amount" custom JET event depending on sale contents:
        LogNonItemAmounts(POSEntry);
        //+NPR5.51 [356076]

        POSAuditLog."External ID" := POSEntry."Fiscal No.";
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'TICKET';

        //-NPR5.51 [356076]
        if IsFullRMA(POSEntry) then begin
            POSAuditLog."External Description" := 'Cancellation (Ticket)'
        end else begin
            POSAuditLog."External Description" := 'Sale (Ticket)'
        end;
        //+NPR5.51 [356076]

        CreatePOSEntryRelatedInfoRecord(POSEntry); //Store/company data needs to be persistent.

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignGrandTotal(var POSAuditLog: Record "NPR POS Audit Log")
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
        TaxBreakdown: Text;
        TaxTotal: Decimal;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
            DATABASE::"NPR POS Workshift Checkpoint":
                begin
                    RecRef.SetTable(POSWorkshiftCheckpoint);
                    POSWorkshiftCheckpoint.Find;
                    if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then begin
                        POSAuditLog."External Description" := 'Period Grand Total';
                        POSAuditLog."External ID" := GetNextEventNoSeries(2, POSWorkshiftCheckpoint."POS Unit No.");
                    end else
                        if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::PREPORT then begin
                            //-NPR5.51 [356076]
                            if POSWorkshiftCheckpoint."Period Type" = YearlyPeriodType then begin
                                POSAuditLog."External Description" := 'Yearly Grand Total';
                                POSAuditLog."External ID" := GetNextEventNoSeries(4, POSWorkshiftCheckpoint."POS Unit No.");
                            end else
                                if POSWorkshiftCheckpoint."Period Type" = MonthlyPeriodType() then begin
                                    //+NPR5.51 [356076]
                                    POSAuditLog."External Description" := 'Monthly Grand Total';
                                    POSAuditLog."External ID" := GetNextEventNoSeries(3, POSWorkshiftCheckpoint."POS Unit No.");
                                end;
                        end;
                    POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
                end;
            DATABASE::"NPR POS Entry":
                begin
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find;
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
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
        ReprintNo: Integer;
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        RecRef: RecordRef;
    begin
        POSAuditLog."External ID" := GetNextEventNoSeries(1, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'DUPLICATE';
        POSAuditLog."External Description" := 'Ticket Reprint';

        POSEntryOutputLog.Get(POSAuditLog."Record ID");

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignArchiveFile(var POSAuditLog: Record "NPR POS Audit Log"): Text
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "NPR POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
        TaxBreakdown: Text;
        TaxTotal: Decimal;
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
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
        //-NPR5.51 [356076]
        POSAuditLog."External Code" := '320';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Cancel Sale';
        //-NPR5.51 [356076]
        POSAuditLog."Additional Information" := Format(POSAuditLog."Active Salesperson Code");
        //+NPR5.51 [356076]

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
        //+NPR5.51 [356076]
    end;

    local procedure SignNonItemAmount(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        //-NPR5.51 [356076]
        POSAuditLog."External Code" := '910';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Non-item ticket sales amount';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
        //+NPR5.51 [356076]
    end;

    local procedure "---Amount Calculation"()
    begin
    end;

    local procedure GetSaleTaxBreakdownString(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean) TaxBreakdown: Text
    var
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
        POSTaxAmountLine2: Record "NPR POS Tax Amount Line";
        tmpPOSTaxAmountLine: Record "NPR POS Tax Amount Line" temporary;
    begin
        //-NPR5.51 [356076]
        POSTaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if OnlyIncludeItems then begin
            POSTaxAmountLine.SetFilter("VAT Identifier", FRCertificationSetup."Item VAT Identifier Filter");
        end;

        if POSTaxAmountLine.FindSet then
            repeat
                //Select distinct tax % total

                tmpPOSTaxAmountLine.SetRange("Tax %", POSTaxAmountLine."Tax %");
                if tmpPOSTaxAmountLine.IsEmpty then begin
                    tmpPOSTaxAmountLine."POS Entry No." += 1;
                    tmpPOSTaxAmountLine."Tax %" := POSTaxAmountLine."Tax %";
                    tmpPOSTaxAmountLine.Insert;

                    POSTaxAmountLine2.SetRange("POS Entry No.", POSEntry."Entry No.");
                    POSTaxAmountLine2.SetRange("Tax %", POSTaxAmountLine."Tax %");
                    if OnlyIncludeItems then begin
                        POSTaxAmountLine2.SetFilter("VAT Identifier", FRCertificationSetup."Item VAT Identifier Filter");
                    end;
                    POSTaxAmountLine2.CalcSums("Amount Including Tax");

                    if TaxBreakdown <> '' then
                        TaxBreakdown += '|';
                    TaxBreakdown += PadLeft(FormatNumeric(POSTaxAmountLine."Tax %"), 4, '0') + ':' + PadLeft(FormatNumeric(POSTaxAmountLine2."Amount Including Tax"), 4, '0');
                end;
            until POSTaxAmountLine.Next = 0;
        //+NPR5.51 [356076]
    end;

    local procedure GetSaleTotalInclTax(POSEntry: Record "NPR POS Entry"; OnlyIncludeItems: Boolean): Decimal
    begin
        //-NPR5.51 [356076]
        if OnlyIncludeItems then begin
            exit(POSEntry."Item Sales (LCY)" + POSEntry."Item Returns (LCY)")
        end else begin
            exit(POSEntry."Amount Incl. Tax");
        end;
        //+NPR5.51 [356076]
    end;

    local procedure GetSalePerpetualAbsoluteAmount(POSEntryIn: Record "NPR POS Entry"): Decimal
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Perpetual: Decimal;
        POSEntry: Record "NPR POS Entry";
    begin
        //Implied only include item amounts as per audit requirements.

        //-NPR5.51 [356076]
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '<%1', POSEntryIn."Entry No.");

        if POSWorkshiftCheckpoint.FindLast then begin
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
        //+NPR5.51 [356076]
    end;

    local procedure GetSalePerpetualAmount(POSEntryIn: Record "NPR POS Entry"): Decimal
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Perpetual: Decimal;
        POSEntry: Record "NPR POS Entry";
    begin
        //Implied only include item amounts as per audit requirements.

        //-NPR5.51 [356076]
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntryIn."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '<%1', POSEntryIn."Entry No.");
        if POSWorkshiftCheckpoint.FindLast then begin
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
        //+NPR5.51 [356076]
    end;

    local procedure GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint") TaxBreakdown: Text
    var
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        POSWorkshiftTaxCheckpoint2: Record "NPR POS Worksh. Tax Checkp.";
        tmpPOSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary;
    begin
        //Implied only include item amounts as per audit requirements.

        //-NPR5.51 [356076]
        POSWorkshiftTaxCheckpoint.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        POSWorkshiftTaxCheckpoint.SetFilter("VAT Identifier", FRCertificationSetup."Item VAT Identifier Filter");
        if POSWorkshiftTaxCheckpoint.FindSet then
            repeat
                //Select distinct tax % total

                tmpPOSWorkshiftTaxCheckpoint.SetRange("Tax %", POSWorkshiftTaxCheckpoint."Tax %");
                if tmpPOSWorkshiftTaxCheckpoint.IsEmpty then begin
                    tmpPOSWorkshiftTaxCheckpoint."Entry No." += 1;
                    tmpPOSWorkshiftTaxCheckpoint."Tax %" := POSWorkshiftTaxCheckpoint."Tax %";
                    tmpPOSWorkshiftTaxCheckpoint.Insert;

                    POSWorkshiftTaxCheckpoint2.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
                    POSWorkshiftTaxCheckpoint2.SetRange("Tax %", POSWorkshiftTaxCheckpoint."Tax %");
                    POSWorkshiftTaxCheckpoint2.SetFilter("VAT Identifier", FRCertificationSetup."Item VAT Identifier Filter");
                    POSWorkshiftTaxCheckpoint2.CalcSums("Amount Including Tax");

                    if TaxBreakdown <> '' then
                        TaxBreakdown += '|';
                    TaxBreakdown += PadLeft(FormatNumeric(POSWorkshiftTaxCheckpoint."Tax %"), 4, '0') + ':' + FormatNumeric(POSWorkshiftTaxCheckpoint2."Amount Including Tax");
                end;
            until POSWorkshiftTaxCheckpoint.Next = 0;
        //+NPR5.51 [356076]
    end;

    local procedure GetWorkshiftTotalInclTax(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Decimal
    begin
        //-NPR5.51 [356076]
        //Implied only include item amounts as per audit requirements.

        exit(POSWorkshiftCheckpoint."Direct Item Sales (LCY)" + POSWorkshiftCheckpoint."Direct Item Returns (LCY)");
        //+NPR5.51 [356076]
    end;

    local procedure GetWorkshiftPerpetualAbsoluteAmount(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Decimal
    begin
        //-NPR5.51 [356076]
        //Implied only include item amounts as per audit requirements.

        exit(POSWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)" + Abs(POSWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)"));
        //+NPR5.51 [356076]
    end;

    local procedure GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Decimal
    begin
        //-NPR5.51 [356076]
        //Implied only include item amounts as per audit requirements.

        exit(POSWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)" + POSWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)");
        //+NPR5.51 [356076]
    end;

    local procedure "---Aux"()
    begin
    end;

    local procedure CreatePOSEntryRelatedInfoRecord(POSEntry: Record "NPR POS Entry")
    var
        FRPOSEntryRelatedInfo: Record "NPR FR POS Audit Log Aux. Info";
        POSStore: Record "NPR POS Store";
        CompanyInformation: Record "Company Information";
        Licenseinformation: Codeunit "NPR License Information";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        RecRef: RecordRef;
    begin
        POSStore.Get(POSEntry."POS Store Code");
        SalespersonPurchaser.Get(POSEntry."Salesperson Code");
        CompanyInformation.Get;

        with FRPOSEntryRelatedInfo do begin
            Init;
            "POS Entry No." := POSEntry."Entry No.";
            "NPR Version" := CopyStr(Licenseinformation.GetRetailVersion(), 1, MaxStrLen("NPR Version"));
            "Store Name" := POSStore.Name;
            "Store Name 2" := POSStore."Name 2";
            "Store Address" := POSStore.Address;
            "Store Address 2" := POSStore."Address 2";
            "Store Post Code" := POSStore."Post Code";
            "Store City" := POSStore.City;
            "Store Siret" := POSStore."Registration No.";
            "Store Country/Region Code" := POSStore."Country/Region Code";
            RecRef.GetTable(CompanyInformation);
            //-NPR5.51 [356076]
            if RecRef.FieldExist(10802) then
                APE := RecRef.Field(10802).Value;
            //+NPR5.51 [356076]
            "Intra-comm. VAT ID" := CompanyInformation."VAT Registration No.";
            "Salesperson Name" := SalespersonPurchaser.Name;
            Insert;
        end;
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
        //EXIT(DELCHR(Text,'=',DELCHR(Text,'=','1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')));
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

    local procedure MonthlyPeriodType(): Text
    begin
        //-NPR5.51 [356076]
        exit('FR_NF525_MONTH');
        //+NPR5.51 [356076]
    end;

    local procedure YearlyPeriodType(): Text
    begin
        //-NPR5.51 [356076]
        exit('FR_NF525_YEAR');
        //+NPR5.51 [356076]
    end;

    local procedure ImplementationCode(): Text
    begin
        //-NPR5.51 [356076]
        exit(HandlerCode + '_V3');
        //+NPR5.51 [356076]
    end;

    procedure GetJETInitRecord(var POSAuditLog: Record "NPR POS Audit Log"; POSUnitNo: Code[10]; WithError: Boolean): Boolean
    begin
        //-NPR5.51 [356076]
        POSAuditLog.SetRange("Acted on POS Unit No.", POSUnitNo);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::LOG_INIT);
        POSAuditLog.SetRange("Handled by External Impl.", true);
        POSAuditLog.SetRange("External Type", 'JET');
        if WithError then begin
            POSAuditLog.FindFirst();
            exit(true);
        end else
            exit(POSAuditLog.FindFirst());
        //+NPR5.51 [356076]
    end;

    local procedure LogNonItemAmounts(POSEntry: Record "NPR POS Entry")
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSSalesLine: Record "NPR POS Sales Line";
        AddInfo: Text;
        Amount: Decimal;
    begin
        //-NPR5.51 [356076]
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetFilter(Type, '<>%1&<>%2&<>%3', POSSalesLine.Type::Item, POSSalesLine.Type::Rounding, POSSalesLine.Type::Comment);
        if POSSalesLine.IsEmpty then
            exit;

        Amount := GetSaleTotalInclTax(POSEntry, false) - GetSaleTotalInclTax(POSEntry, true);
        AddInfo := StrSubstNo('%1|%2', POSEntry."Fiscal No.", Format(Amount, 0, '<Precision,2:2><Standard Format,9>'));

        POSAuditLogMgt.CreateEntryCustom(POSEntry.RecordId, 'NON_ITEM_AMOUNT', POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", 'Sale amount not from items', AddInfo);
        //+NPR5.51 [356076]
    end;

    local procedure IsFullRMA(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSRMALine: Record "NPR POS RMA Line";
    begin
        //-NPR5.51 [356076]
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        if not POSSalesLine.FindSet then
            exit(false);

        repeat
            POSRMALine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSRMALine.SetRange("Return Line No.", POSSalesLine."Line No.");
            if POSRMALine.IsEmpty then
                exit(false);
        until POSSalesLine.Next = 0;

        exit(true);
        //+NPR5.51 [356076]
    end;

    procedure GetItemVATIdentifierFilter(CurrentValue: Text) NewValue: Text
    var
        FilterPageBuilder: FilterPageBuilder;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        //-NPR5.51 [356076]
        FilterPageBuilder.AddRecord(VATPostingSetup.TableCaption, VATPostingSetup);

        if CurrentValue <> '' then begin
            VATPostingSetup.SetFilter("VAT Identifier", CurrentValue);
            FilterPageBuilder.SetView(VATPostingSetup.TableCaption, VATPostingSetup.GetView(false));
        end;

        if FilterPageBuilder.RunModal() then begin
            VATPostingSetup.Reset;
            VATPostingSetup.SetView(FilterPageBuilder.GetView(VATPostingSetup.TableCaption, false));
            exit(VATPostingSetup.GetFilter("VAT Identifier"));
        end;
        //+NPR5.51 [356076]
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := HandlerCode();
        tmpRetailList.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnArchiveWorkshiftPeriod', '', true, true)]
    local procedure OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        FRPeriodArchive: XMLport "NPR FR Audit Archive";
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        //-NPR5.51 [356076]
        POSWorkshiftCheckpoint.TestField(Type, POSWorkshiftCheckpoint.Type::PREPORT);
        //+NPR5.51 [356076]

        //Export Archive
        POSWorkshiftCheckpoint.SetRecFilter;
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        FRPeriodArchive.SetDestination(OutStream);
        FRPeriodArchive.SetTableView(POSWorkshiftCheckpoint);
        FRPeriodArchive.Export();
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        FileName := 'Archive.xml';
        DownloadFromStream(InStream, 'Download Archive', '', '', FileName);
        Clear(InStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnHandleAuditLogBeforeInsert', '', true, true)]
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

        //-NPR5.55 [408900]
        //Shave off milliseconds from timestamp to prevent sql rounding on commit causing signature invalidation later.
        Evaluate(POSAuditLog."Log Timestamp", CopyStr(Format(POSAuditLog."Log Timestamp", 0, 9), 1, 19) + '.000Z', 9);
        //+NPR5.55 [408900]

        //-NPR5.51 [356076]
        if POSAuditLog."Action Type" <> POSAuditLog."Action Type"::LOG_INIT then
            GetJETInitRecord(POSAuditLogInit, POSUnit."No.", true); //Failsafe - first record MUST be JET INIT.
        //+NPR5.51 [356076]

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
            POSAuditLog."Action Type"::AUDIT_VERIFY:
                SignAuditVerify(POSAuditLog);
            POSAuditLog."Action Type"::GRANDTOTAL:
                SignGrandTotal(POSAuditLog); //Only item amount & item VAT amounts are stored and signed.
            POSAuditLog."Action Type"::ARCHIVE_CREATE:
                SignArchiveFile(POSAuditLog);
            //-NPR5.51 [356076]
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
        //+NPR5.51 [356076]

        //Events below are not performed directly on the POS so they are not handled for compliance.

        //POSAuditLog.Type::DATA_EXPORT : SignDataExport(POSAuditLog);
        //POSAuditLog.Type::DATA_IMPORT : SignDataImport(POSAuditLog);
        //POSAuditLog.Type::PERMISSION_MODIFY : SignPermissionModify(POSAuditLog);
        //POSAuditLog.Type::DATA_PURGE : SignDataPurge(POSAuditLog);
        //POSAuditLog.Type::COMPLIANCE_MODIFICATION : SignComplianceModification(POSAuditLog);
        //POSAuditLog.Type::SETUP_MODIFICATION : SignSetupModification(POSAuditLog);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014534, 'OnSalesReceiptFooter', '', true, true)]
    local procedure OnReceiptFooter(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text)
    var
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        Licenceinformation: Codeunit "NPR License Information";
        POSEntry: Record "NPR POS Entry";
        AuditLog: Record "NPR POS Audit Log";
        PrintSignature: Text;
        InStream: InStream;
        Signature: Text;
        POSUnit: Record "NPR POS Unit";
    begin
        POSEntry.SetRange("Document No.", ReceiptNo);
        //-NPR5.49 [348167]
        //POSEntry.FINDFIRST;
        if not POSEntry.FindFirst then
            exit;
        //+NPR5.49 [348167]
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        LinePrintMgt.SetFont(TemplateLine."Type Option");
        LinePrintMgt.SetBold(TemplateLine.Bold);
        LinePrintMgt.SetUnderLine(TemplateLine.Underline);

        AuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        AuditLog.SetRange("Action Type", AuditLog."Action Type"::DIRECT_SALE_END);
        AuditLog.SetAutoCalcFields("Electronic Signature");
        if not AuditLog.FindLast then
            exit;

        if not AuditLog."Electronic Signature".HasValue then
            Error(ERROR_MISSING_SIGNATURE, POSEntry.TableCaption, POSEntry."Entry No.");

        AuditLog."Electronic Signature".CreateInStream(InStream);
        while (not InStream.EOS) do begin
            InStream.ReadText(Signature);
        end;

        PrintSignature := CopyStr(Signature, 3, 1) + CopyStr(Signature, 7, 1) + CopyStr(Signature, 13, 1) + CopyStr(Signature, 19, 1);
        LinePrintMgt.AddTextField(1, TemplateLine.Align, PrintSignature);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnValidateLogRecords', '', true, true)]
    local procedure OnValidateLogRecords(var POSAuditLog: Record "NPR POS Audit Log"; var Handled: Boolean)
    var
        BaseValue: Text;
        Signature: Text;
        PreviousSignature: Text;
        InStream: InStream;
        First: Boolean;
        NPAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        RecordID: RecordID;
        NPAuditLog: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSAuditLog.FindFirst then
            exit;
        if POSAuditLog."Active POS Unit No." = '' then
            exit;
        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        Handled := true;

        POSAuditLog.SetAutoCalcFields("Electronic Signature", "Previous Electronic Signature", "Signature Base Value");
        POSAuditLog.SetCurrentKey("Entry No.");
        POSAuditLog.SetAscending("Entry No.", true);

        //Refresh all the stored data strings/hashes.
        if POSAuditLog.FindSet then
            repeat
                FillSignatureBaseValues(POSAuditLog, false);
                POSAuditLog.Modify;
            until POSAuditLog.Next = 0;

        //-NPR5.51 [356076]
        //COMMIT;
        //+NPR5.51 [356076]

        //Check signatures against fresh data strings/hash
        if POSAuditLog.FindSet then begin
            First := true;
            repeat
                Clear(PreviousSignature);
                POSAuditLog."Previous Electronic Signature".CreateInStream(InStream);
                while (not InStream.EOS) do
                    InStream.ReadText(PreviousSignature);
                Clear(InStream);

                if not First then
                    if PreviousSignature <> Signature then
                        Error(ERROR_SIGNATURE_CHAIN, POSAuditLog.TableCaption, POSAuditLog."Entry No.");

                Clear(Signature);
                POSAuditLog."Electronic Signature".CreateInStream(InStream);
                while (not InStream.EOS) do
                    InStream.ReadText(Signature);
                Clear(InStream);

                Clear(BaseValue);
                POSAuditLog."Signature Base Value".CreateInStream(InStream);
                while (not InStream.EOS) do
                    InStream.ReadText(BaseValue);
                Clear(InStream);

                if not VerifySignature(BaseValue, 'SHA1', DecodeBase64URL(Signature)) then
                    Error(ERROR_SIGNATURE_VALUE, POSAuditLog.TableCaption, POSAuditLog."Entry No.");

                First := false;
            until POSAuditLog.Next = 0;
        end;

        Message(CAPTION_SIGNATURES_VALID, POSAuditLog.Count());
        //-NPR5.51 [356076]
        Error(''); //Rollback modifications to entries done while recalculating & verifying signature.
        //+NPR5.51 [356076]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150627, 'OnBeforePostWorkshift', '', false, false)]
    local procedure OnBeforePostWorkshift(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpointMgt: Codeunit "NPR POS Workshift Checkpoint";
        FromWorkshiftEntry: Integer;
    begin
        //-NPR5.51 [356076]
        if POSWorkshiftCheckpoint."POS Unit No." = '' then
            exit;
        if POSWorkshiftCheckpoint.Type <> POSWorkshiftCheckpoint.Type::ZREPORT then
            exit;
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");

        //-NPR5.55 [408900]
        if TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint, MonthlyPeriodType(), FRCertificationSetup."Monthly Workshift Duration", FromWorkshiftEntry) then
            //+NPR5.55 [408900]
            POSWorkshiftCheckpointMgt.CreatePeriodCheckpoint(POSWorkshiftCheckpoint."POS Entry No.", POSUnit."No.", FromWorkshiftEntry, POSWorkshiftCheckpoint."Entry No.", MonthlyPeriodType());

        //-NPR5.55 [408900]
        if TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint, YearlyPeriodType(), FRCertificationSetup."Yearly Workshift Duration", FromWorkshiftEntry) then
            //+NPR5.55 [408900]
            POSWorkshiftCheckpointMgt.CreatePeriodCheckpoint(POSWorkshiftCheckpoint."POS Entry No.", POSUnit."No.", FromWorkshiftEntry, POSWorkshiftCheckpoint."Entry No.", YearlyPeriodType());
        //+NPR5.51 [356076]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeLogin(SaleHeader: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditLog: Record "NPR POS Audit Log";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        FRAuditSetup: Record "NPR FR Audit Setup";
        FRAuditNoSeries: Record "NPR FR Audit No. Series";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSAuditProfile: Record "NPR POS Audit Profile";
        Register: Record "NPR Register";
        FRAuditNoSeries2: Record "NPR FR Audit No. Series";
        POSStore: Record "NPR POS Store";
        CompanyInformation: Record "Company Information";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.51 [356076]
        //Error upon POS login if any configuration is missing or clearly not set according to compliance

        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSSetup.GetRegisterRecord(Register);
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not GetJETInitRecord(POSAuditLog, POSUnit."No.", false) then
            Error(ERROR_JET_INIT, POSUnit.TableCaption, POSUnit."No.");

        FRAuditSetup.Get;
        FRAuditSetup.TestField("Monthly Workshift Duration");
        FRAuditSetup.TestField("Yearly Workshift Duration");
        FRAuditSetup.TestField("Certification Category");
        FRAuditSetup.TestField("Certification No.");
        FRAuditSetup.TestField("Signing Certificate Thumbprint");
        FRAuditSetup.TestField("Auto Archive URL");
        FRAuditSetup.TestField("Auto Archive API Key");
        FRAuditSetup.TestField("Item VAT Identifier Filter");

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

        Register.TestField("Balancing every", Register."Balancing every"::Day);

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
        //+NPR5.51 [356076]
    end;
}

