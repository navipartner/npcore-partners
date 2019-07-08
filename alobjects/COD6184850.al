codeunit 6184850 "FR Audit Mgt."
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.49/MMV /20190306 CASE 348167 Skip footer if no POS entry

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        FRCertificationSetup: Record "FR Audit Setup";
        X509Certificate2: DotNet npNetX509Certificate2;
        RSACryptoServiceProvider: DotNet npNetRSACryptoServiceProvider;
        Initialized: Boolean;
        ERROR_MISSING_SIGNATURE: Label '%1 %2 is missing a digital signature';
        Enabled: Boolean;
        CertificateLoaded: Boolean;
        ERROR_JET_DATA: Label 'JET for %1 %2 already contains data';
        ERROR_MOD_DESC: Label 'A description of the modification is required';
        ERROR_MISSING_KEY: Label 'The selected certificate does not contain the private key';
        ERROR_SIGNATURE_CHAIN: Label 'Broken signature chain for %1 entry %2';
        ERROR_SIGNATURE_VALUE: Label 'Invalid signature for %1 entry %2';
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
        NPRetailSetup: Record "NP Retail Setup";
        POSAuditProfile: Record "POS Audit Profile";
    begin
        if not Initialized then begin
          Initialized := true;
          if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
          if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);
          FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
          FRCertificationSetup.Get;
          Enabled := true;
        end;
        exit(Enabled);
    end;

    local procedure LoadCertificate()
    var
        InStream: InStream;
        MemoryStream: DotNet npNetMemoryStream;
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

    procedure InitializeJET()
    var
        POSUnit: Record "POS Unit";
        POSAuditLog: Record "POS Audit Log";
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
    begin
        if PAGE.RunModal(0, POSUnit) <> ACTION::LookupOK then
          exit;

        POSAuditLog.SetRange("Active POS Unit No.", POSUnit."No.");
        if not POSAuditLog.IsEmpty then
          Error(ERROR_JET_DATA, POSUnit.TableCaption, POSUnit."No.");

        if not Confirm(CAPTION_JET, false, POSUnit.TableCaption, POSUnit."No.") then
          exit;

        POSAuditLogMgt.CreateEntry(POSUnit.RecordId, POSAuditLog."Action Type"::LOG_INIT, 0, '', POSUnit."No.");
    end;

    procedure VerifySignature(Data: Text;HashAlgo: Text;SignatureBase64: Text): Boolean
    var
        CryptoConfig: DotNet npNetCryptoConfig;
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        LoadCertificate();
        exit(RSACryptoServiceProvider.VerifyData(Encoding.Unicode.GetBytes(Data), CryptoConfig.MapNameToOID(HashAlgo), Convert.FromBase64String(SignatureBase64)));
    end;

    procedure GetLastUnitEventSignature(POSUnitNo: Code[10];var POSAuditLogOut: Record "POS Audit Log";ExternalType: Code[20]): Boolean
    begin
        POSAuditLogOut.SetAutoCalcFields("Electronic Signature");
        POSAuditLogOut.SetCurrentKey("Active POS Unit No.","External Type");
        POSAuditLogOut.SetRange("Active POS Unit No.", POSUnitNo);
        POSAuditLogOut.SetRange("External Type", ExternalType);
        exit(POSAuditLogOut.FindLast);
    end;

    local procedure GetNextEventNoSeries(EventType: Option JET,Reprint,Period,GrandPeriod;POSUnitNo: Code[10]): Text
    var
        FRCertificationNoSeries: Record "FR Audit No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        FRCertificationNoSeries.Get(POSUnitNo);
        case EventType of
          EventType::JET : exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."JET No. Series",Today,true));
          EventType::Reprint : exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Reprint No. Series",Today,true));
          EventType::Period : exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Period No. Series",Today,true));
          EventType::GrandPeriod : exit(NoSeriesManagement.GetNextNo(FRCertificationNoSeries."Grand Period No. Series",Today,true));
        end;
    end;

    procedure LogPartnerModification()
    var
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        RecordID: RecordID;
        POSAuditLog: Record "POS Audit Log";
        DescriptionOut: Text[250];
        InputDialog: Page "Input Dialog";
        ID: Integer;
        POSUnit: Record "POS Unit";
    begin
        if PAGE.RunModal(0, POSUnit) <> ACTION::LookupOK then
          exit;

        repeat
          Clear(InputDialog);
          InputDialog.LookupMode := true;
          InputDialog.SetInput(1, DescriptionOut, CAPTION_PARTNER_MOD);
          if InputDialog.RunModal = ACTION::LookupOK then
            ID := InputDialog.InputText(1, DescriptionOut);
        until (DescriptionOut <> '') or (ID = 0);
        if (ID = 0) then
          exit;

        if DescriptionOut = '' then
          Error(ERROR_MOD_DESC);

        POSAuditLogMgt.CreateEntryExtended(RecordID, POSAuditLog."Action Type"::PARTNER_MODIFICATION, 0, '' , POSUnit."No.", '', DescriptionOut);
    end;

    procedure SignHash(BaseHash: Text): Text
    var
        CryptoConfig: DotNet npNetCryptoConfig;
        Convert: DotNet npNetConvert;
    begin
        exit(Convert.ToBase64String(RSACryptoServiceProvider.SignHash(Convert.FromBase64String(BaseHash), CryptoConfig.MapNameToOID('SHA1'))));
    end;

    procedure CalculateHash(BaseValue: Text): Text
    var
        SHA1CryptoServiceProvider: DotNet npNetSHA1CryptoServiceProvider;
        Encoding: DotNet npNetEncoding;
        Convert: DotNet npNetConvert;
    begin
        SHA1CryptoServiceProvider := SHA1CryptoServiceProvider.SHA1CryptoServiceProvider();
        exit(Convert.ToBase64String(SHA1CryptoServiceProvider.ComputeHash(Encoding.Unicode.GetBytes(BaseValue))));
    end;

    procedure ImportCertificate()
    var
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text;
        X509Certificate2: DotNet npNetX509Certificate2;
        MemoryStream: DotNet npNetMemoryStream;
        RSACryptoServiceProvider: DotNet npNetRSACryptoServiceProvider;
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

    local procedure "---Fill Base Values"()
    begin
    end;

    procedure FillSignatureBaseValues(var POSAuditLog: Record "POS Audit Log";IsInitialHandling: Boolean)
    var
        BaseValue: Text;
        PreviousSignature: Text;
        BaseHash: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if IsInitialHandling then begin
          if GetLastUnitEventSignature(POSAuditLog."Active POS Unit No.", PreviousEventLogRecord, POSAuditLog."External Type") then
            POSAuditLog."Previous Electronic Signature" := PreviousEventLogRecord."Electronic Signature";
          POSAuditLog."External Implementation" := HandlerCode();
          POSAuditLog."Certificate Implementation" := 'RSA_2048_SHA1';
          POSAuditLog."Certificate Thumbprint" := FRCertificationSetup."Signing Certificate Thumbprint";
          POSAuditLog."Handled by External Impl." := true;
        end;

        POSAuditLog."Previous Electronic Signature".CreateInStream(InStream);
        while (not InStream.EOS) do
          InStream.ReadText(PreviousSignature);

        case POSAuditLog."External Type" of
          'JET' : BaseValue := FillJETBase(POSAuditLog, PreviousSignature);
          'TICKET' : BaseValue := FillTicketBase(POSAuditLog, PreviousSignature);
          'GRANDTOTAL' : BaseValue := FillGrandTotalBase(POSAuditLog, PreviousSignature);
          'DUPLICATE' : BaseValue := FillDuplicatePrintBase(POSAuditLog, PreviousSignature);
          'ARCHIVE' : BaseValue := FillArchiveFileBase(POSAuditLog, PreviousSignature);
        end;

        POSAuditLog."Signature Base Value".CreateOutStream(OutStream);
        OutStream.WriteText(BaseValue);
        POSAuditLog."Signature Base Hash" := EncodeBase64URL(CalculateHash(BaseValue));

        if IsInitialHandling then begin
          POSAuditLog."Original Signature Base Hash" := POSAuditLog."Signature Base Hash";
          POSAuditLog."Original Signature Base Value" := POSAuditLog."Signature Base Value";
        end;
    end;

    local procedure FillJETBase(var POSAuditLog: Record "POS Audit Log";PreviousSignature: Text): Text
    begin
        with POSAuditLog do
          exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7,%8,%9',
            FormatAlphanumeric("External ID"),
            "External Code",
            FormatAlphanumeric("Additional Information"),
            FormatDatetime("Log Timestamp"),
            FormatAlphanumeric("Active Salesperson Code"),
            FormatAlphanumeric("Active POS Unit No."),
            '',
            Format((PreviousSignature <> ''),0,2),
            FormatText(PreviousSignature)));
        
        /*
        1� JET�ID� TAG-JET-NID� Alpha�numeric� Cf.�5.
        2� Event�code� TAG-JET-COD� Numeric� Cf.�5.
        3� Event�label/description� TAG-JET-LIB� Alpha�numeric� Cf.�5.
        4� Operation�TimeStamp� TAG-JET-HOR-GDH� Datetime� Cf.�5.
        5� Operator�code� TAG-JET-OPS-NID� Alpha�numeric� Cf.�5.
        6� Terminal/POS�code� TAG-JET-CAI-NID� Alpha�numeric� Cf.�5.
        8� Is�there�a�previous�signature�?�Y/N� TAG-JET-OEN� Alpha�numeric
        �O��/��N�
        ou�
        �0��/��1��
        9� Electronic�signature� TAG-JET-SIG� Text� Cf.�5.
        */

    end;

    local procedure FillTicketBase(var POSAuditLog: Record "POS Audit Log";PreviousSignature: Text): Text
    var
        TaxBreakdown: Text;
        TaxTotal: Decimal;
        POSEntry: Record "POS Entry";
        RecRef: RecordRef;
        Licenceinformation: Codeunit "Licence information";
    begin
        RecRef.Get(POSAuditLog."Record ID");
        RecRef.SetTable(POSEntry);
        POSEntry.Find;
        
        TaxBreakdown := GetSaleTaxBreakdownString(POSEntry);
        TaxTotal := GetSaleTaxTotal(POSEntry);
        
        with POSAuditLog do
          exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
            FormatAlphanumeric(TaxBreakdown),
            FormatNumeric(TaxTotal),
            FormatDatetime("Log Timestamp"),
            FormatAlphanumeric("Acted on POS Entry Fiscal No."),
            'Sale',
            Format((PreviousSignature <> ''),0,2),
            FormatText(PreviousSignature)));
        
        /*
        1� Tax.�Incl�amounts�brokedown�per�VAT�rate� TAG-TIK-TOT-TTC-TVA� Alpha�numeric� Cf.�5.
        2� Total�Tax.�Incl�amount�of�the�ticket� TAG-TIK-TOT-TTC� Alpha�numeric� Cf.�5.
        3� Operation�Timestamp� TAG-TIK-HOR-GDH� Datetime� Cf.�5.
        4� Document�number�(unique)� TAG-TIK-NUM� Alpha�numeric� Cf.�5.
        5� Operation�type� TAG-TIK-OPE-TYP� Alpha�numeric� Cf.�5.
        6� Is�there�a�previous�signature�?�Y/N� TAG-TIK-OEN� Alpha�numeric
        �O��/��N�
        ou�
        �0��/��1�
        7� Electronic�signature� TAG-TIK-SIG� Text� Cf.�5
        */

    end;

    local procedure FillGrandTotalBase(var POSAuditLog: Record "POS Audit Log";PreviousSignature: Text): Text
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        POSEntry: Record "POS Entry";
        TaxBreakdown: Text;
        TaxTotal: Decimal;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
          DATABASE::"POS Workshift Checkpoint" :
            begin
              RecRef.SetTable(POSWorkshiftCheckpoint);
              POSWorkshiftCheckpoint.Find;
              TaxBreakdown := GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint);
              TaxTotal := GetWorkshiftTaxTotal(POSWorkshiftCheckpoint);
              POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
              POSAuditLog."Additional Information" := Format(GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint),0,'<Precision,2:2><Standard Format,9>');
            end;
          DATABASE::"POS Entry" :
            begin
              RecRef.SetTable(POSEntry);
              POSEntry.Find;
              TaxBreakdown := GetSaleTaxBreakdownString(POSEntry);
              TaxTotal := GetSaleTaxTotal(POSEntry);
              POSAuditLog."Additional Information" := Format(GetSalePerpetualAmount(POSEntry),0,'<Precision,2:2><Standard Format,9>');
            end;
        end;

        with POSAuditLog do
          exit(StrSubstNo('%1,%2,%3,%4,%5,%6',
            FormatAlphanumeric(TaxBreakdown),
            FormatNumeric(TaxTotal),
            FormatDatetime("Log Timestamp"),
            FormatAlphanumeric(POSEntry."Fiscal No."),
            Format((PreviousSignature <> ''),0,2),
            FormatText(PreviousSignature)));
    end;

    local procedure FillDuplicatePrintBase(var POSAuditLog: Record "POS Audit Log";PreviousSignature: Text): Text
    var
        ReprintNo: Integer;
        POSEntryOutputLog: Record "POS Entry Output Log";
        POSEntryOutputLog2: Record "POS Entry Output Log";
        RecRef: RecordRef;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        RecRef.SetTable(POSEntryOutputLog);
        RecRef.Find;

        POSEntryOutputLog2.SetRange("POS Entry No.",POSAuditLog."Acted on POS Entry No.");
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
            Format((PreviousSignature <> ''),0,2),
            FormatText(PreviousSignature)));
    end;

    local procedure FillArchiveFileBase(var POSAuditLog: Record "POS Audit Log";PreviousSignature: Text): Text
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        TaxBreakdown: Text;
        TaxTotal: Decimal;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        RecRef.SetTable(POSWorkshiftCheckpoint);
        POSWorkshiftCheckpoint.Find;

        TaxBreakdown := GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint);
        TaxTotal := GetWorkshiftTaxTotal(POSWorkshiftCheckpoint);

        with POSAuditLog do
          exit(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
            FormatAlphanumeric(TaxBreakdown),
            FormatNumeric(TaxTotal),
            FormatDatetime("Log Timestamp"),
            FormatAlphanumeric("Active POS Unit No."),
            'Archive',
            Format((PreviousSignature <> ''),0,2),
            FormatText(PreviousSignature)));
    end;

    local procedure "---Sign"()
    begin
    end;

    local procedure SignRecord(var POSAuditLog: Record "POS Audit Log")
    var
        BaseHash: Text;
        Signature: Text;
        OutStream: OutStream;
    begin
        Signature := SignHash(DecodeBase64URL(POSAuditLog."Signature Base Hash"));
        POSAuditLog."Electronic Signature".CreateOutStream(OutStream);
        OutStream.WriteText(EncodeBase64URL(Signature));
    end;

    local procedure SignAuditVerify(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignDataExport(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignDataImport(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignPermissionModify(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignDrawerCount(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '170';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Cash Drawer Counting';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignDataPurge(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignPartnerModification(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignLogInit(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignComplianceModification(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignSetupModification(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
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

    local procedure SignArchiveAttempt(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        POSAuditLog."External Code" := '20';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Period Archive';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogIn(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        Licenceinformation: Codeunit "Licence information";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '80';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Log In';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignLogOut(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
    begin
        POSAuditLog."External Code" := '40';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Log Out';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignWorkshift(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        POSEntry: Record "POS Entry";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
    begin
        //WORKSHIFT_END triggers both a JET drawer count event and a period/monthly grand total event as well - for the same workshift record.

        RecRef.Get(POSAuditLog."Record ID");
        RecRef.SetTable(POSWorkshiftCheckpoint);
        POSWorkshiftCheckpoint.Find;
        POSWorkshiftCheckpoint.TestField("POS Entry No.");
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSEntry.TestField("Salesperson Code");

        //JET drawer count:
        if POSWorkshiftCheckpoint.Type <> POSWorkshiftCheckpoint.Type::PREPORT then
          POSAuditLogMgt.CreateEntry(POSWorkshiftCheckpoint.RecordId,POSAuditLog."Action Type"::DRAWER_COUNT,POSEntry."Entry No.",POSEntry."Fiscal No.",POSEntry."POS Unit No.");

        //Grand Total:
        POSAuditLogMgt.CreateEntry(POSWorkshiftCheckpoint.RecordId,POSAuditLog."Action Type"::GRANDTOTAL,POSEntry."Entry No.",POSEntry."Fiscal No.",POSEntry."POS Unit No.");

        //JET period close (this event):
        POSAuditLog."External Code" := '50';
        POSAuditLog."External ID" := GetNextEventNoSeries(0, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Type" := 'JET';
        POSAuditLog."External Description" := 'Period Closing';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignTicket(var POSAuditLog: Record "POS Audit Log")
    var
        RecRef: RecordRef;
        POSEntry: Record "POS Entry";
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
    begin
        RecRef.Get(POSAuditLog."Record ID");
        RecRef.SetTable(POSEntry);
        POSEntry.Find;

        //TICKET event also triggers a Ticket Grand Total event:
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId,POSAuditLog."Action Type"::GRANDTOTAL,POSEntry."Entry No.",POSEntry."Fiscal No.",POSEntry."POS Unit No.");

        //Continue with TICKET event:
        POSAuditLog."External ID" := POSEntry."Fiscal No.";
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'TICKET';
        POSAuditLog."External Description" := 'Sale (Ticket)';

        CreatePOSEntryRelatedInfoRecord(POSEntry); //Store/company data needs to be persistent.

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignGrandTotal(var POSAuditLog: Record "POS Audit Log")
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        POSEntry: Record "POS Entry";
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        HasPreviousSignature: Boolean;
        PreviousSignature: Text;
        InStream: InStream;
        TaxBreakdown: Text;
        TaxTotal: Decimal;
    begin
        RecRef.Get(POSAuditLog."Record ID");
        case RecRef.Number of
          DATABASE::"POS Workshift Checkpoint" :
            begin
              RecRef.SetTable(POSWorkshiftCheckpoint);
              POSWorkshiftCheckpoint.Find;
              if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then begin
                POSAuditLog."External Description" := 'Period Grand Total';
                POSAuditLog."External ID" := GetNextEventNoSeries(2, POSWorkshiftCheckpoint."POS Unit No.");
              end else if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::PREPORT then begin
                POSAuditLog."External Description" := 'Monthly Grand Total';
                POSAuditLog."External ID" := GetNextEventNoSeries(3, POSWorkshiftCheckpoint."POS Unit No.");
              end;
              POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
            end;
          DATABASE::"POS Entry" :
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

    local procedure SignReprintTicket(var POSAuditLog: Record "POS Audit Log")
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
        ReprintNo: Integer;
        POSEntryOutputLog: Record "POS Entry Output Log";
        RecRef: RecordRef;
    begin
        POSAuditLog."External ID" := GetNextEventNoSeries(1, POSAuditLog."Active POS Unit No.");
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'DUPLICATE';
        POSAuditLog."External Description" := 'Ticket Reprint';

        RecRef.Get(POSAuditLog."Record ID");
        RecRef.SetTable(POSEntryOutputLog);
        POSEntryOutputLog.Find;

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure SignArchiveFile(var POSAuditLog: Record "POS Audit Log"): Text
    var
        BaseValue: Text;
        PreviousEventLogRecord: Record "POS Audit Log";
        HasPreviousSignature: Boolean;
        InStream: InStream;
        PreviousSignature: Text;
        TaxBreakdown: Text;
        TaxTotal: Decimal;
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
    begin
        POSAuditLog."External ID" := '';
        POSAuditLog."External Code" := '';
        POSAuditLog."External Type" := 'ARCHIVE';
        POSAuditLog."External Description" := 'Archive Creation';

        FillSignatureBaseValues(POSAuditLog, true);
        SignRecord(POSAuditLog);
    end;

    local procedure "---Amount Calculation"()
    begin
    end;

    local procedure GetSaleTaxBreakdownString(POSEntry: Record "POS Entry") TaxBreakdown: Text
    var
        POSTaxAmountLine: Record "POS Tax Amount Line";
    begin
        POSTaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSTaxAmountLine.FindSet then
          repeat
            if TaxBreakdown <> '' then
              TaxBreakdown += '|';
            TaxBreakdown += PadLeft(FormatNumeric(POSTaxAmountLine."Tax %"),4,'0') + ':' + PadLeft(FormatNumeric(POSTaxAmountLine."Amount Including Tax"),4,'0');
          until POSTaxAmountLine.Next = 0;
    end;

    local procedure GetSaleTaxTotal(POSEntry: Record "POS Entry"): Decimal
    begin
        exit(POSEntry."Total Amount Incl. Tax");
    end;

    local procedure GetSalePerpetualAmount(POSEntry: Record "POS Entry"): Decimal
    var
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        Perpetual: Decimal;
        POSEntry2: Record "POS Entry";
    begin
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSEntry."POS Unit No.");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        if POSWorkshiftCheckpoint.FindLast then begin
          Perpetual += (POSWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)" + (2 * Abs(POSWorkshiftCheckpoint."Perpetual Dir. Neg. Amt. (LCY)")));
          POSEntry2.SetFilter("Entry No.", '>%1', POSWorkshiftCheckpoint."POS Entry No.");
        end;

        POSEntry2.SetRange("POS Unit No.", POSEntry."POS Unit No.");
        POSEntry2.SetRange("Entry Type", POSEntry2."Entry Type"::"Direct Sale");
        POSEntry2.CalcSums("Total Amount Incl. Tax", "Total Neg. Amount Incl. Tax");
        Perpetual += (POSEntry2."Total Amount Incl. Tax" + (2 * Abs(POSEntry2."Total Neg. Amount Incl. Tax")));

        exit(Perpetual);
    end;

    local procedure GetWorkshiftTaxBreakdownString(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint") TaxBreakdown: Text
    var
        POSWorkshiftTaxCheckpoint: Record "POS Workshift Tax Checkpoint";
    begin
        POSWorkshiftTaxCheckpoint.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        if POSWorkshiftTaxCheckpoint.FindSet then
          repeat
            if TaxBreakdown <> '' then
              TaxBreakdown += '|';
            TaxBreakdown += PadLeft(FormatNumeric(POSWorkshiftTaxCheckpoint."Tax %"),4,'0') + ':' + FormatNumeric(POSWorkshiftTaxCheckpoint."Amount Including Tax");
          until POSWorkshiftTaxCheckpoint.Next = 0;
    end;

    local procedure GetWorkshiftTaxTotal(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint"): Decimal
    begin
        exit(POSWorkshiftCheckpoint."Direct Turnover (LCY)" - POSWorkshiftCheckpoint."Rounding (LCY)");
    end;

    local procedure GetWorkshiftPerpetualAmount(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint"): Decimal
    begin
        if POSWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)" <= 0 then
          exit(POSWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)" + (2 * Abs(POSWorkshiftCheckpoint."Perpetual Dir. Neg. Amt. (LCY)" - POSWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)")))
        else
          exit(POSWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)" - POSWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)" + (2 * Abs(POSWorkshiftCheckpoint."Perpetual Dir. Neg. Amt. (LCY)")));
    end;

    local procedure "---Aux"()
    begin
    end;

    local procedure CreatePOSEntryRelatedInfoRecord(POSEntry: Record "POS Entry")
    var
        FRPOSEntryRelatedInfo: Record "FR POS Audit Log Aux. Info";
        POSStore: Record "POS Store";
        CompanyInformation: Record "Company Information";
        Licenceinformation: Codeunit "Licence information";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        RecRef: RecordRef;
    begin
        POSStore.Get(POSEntry."POS Store Code");
        SalespersonPurchaser.Get(POSEntry."Salesperson Code");
        CompanyInformation.Get;

        with FRPOSEntryRelatedInfo do begin
          Init;
          "POS Entry No." := POSEntry."Entry No.";
          "NPR Version" := Licenceinformation.GetRetailVersion();
          "Store Name" := POSStore.Name;
          "Store Name 2" := POSStore."Name 2";
          "Store Address" := POSStore.Address;
          "Store Address 2" := POSStore."Address 2";
          "Store Post Code" := POSStore."Post Code";
          "Store City" := POSStore.City;
          "Store Siret" := POSStore."Registration No.";
          "Store Country/Region Code" := POSStore."Country/Region Code";
          RecRef.GetTable(CompanyInformation);
          //APE := RecRef.FIELD(10802).VALUE;
          "Intra-comm. VAT ID" := CompanyInformation."VAT Registration No.";
          "Salesperson Name" := SalespersonPurchaser.Name;
          Insert;
        end;
    end;

    local procedure DecodeBase64URL(Text: Text): Text
    var
        Output: Text;
    begin
        Output := ConvertStr(Text,'_-','/+');
        exit(PadStr(Output, (StrLen(Output) + (4 - StrLen(Output) mod 4) mod 4), '='));
    end;

    local procedure EncodeBase64URL(Text: Text): Text
    begin
        exit(DelChr(ConvertStr(Text,'/+','_-'),'=','='));
    end;

    local procedure FormatAlphanumeric(Text: Text): Text
    begin
        //EXIT(DELCHR(Text,'=',DELCHR(Text,'=','1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')));
        //As per auditing consultant: Alphanumeric is not supposed to be a literal interpretation, so will be treated as text...
        exit(FormatText(Text));
    end;

    local procedure FormatNumeric(Decimal: Decimal): Text
    begin
        exit(DelChr(Format(Round(Decimal),0,'<Precision,2:2><Standard Format,9>'),'=','.'));
    end;

    local procedure FormatDatetime(DateTime: DateTime): Text
    begin
        exit(Format(DateTime,0,'<Year4><Month,2><Day,2><Hours24,2><Filler Character,0><Minutes,2><Seconds,2>'));
    end;

    local procedure FormatText(Text: Text): Text
    begin
        exit(ConvertStr(Text,', ',';_'));
    end;

    local procedure PadLeft(Text: Text;Length: Integer;PadChar: Text): Text
    var
        InputLength: Integer;
    begin
        InputLength := StrLen(Text);
        if InputLength >= Length then
          exit(Text);

        exit(PadStr('', Length-InputLength, PadChar) + Text);
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := HandlerCode();
        tmpRetailList.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnArchiveWorkshiftPeriod', '', true, true)]
    local procedure OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint")
    var
        POSAuditLog: Record "POS Audit Log";
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        FRPeriodArchive: XMLport "FR Audit Archive";
        OutStream: OutStream;
        TempBlob: Record TempBlob temporary;
        InStream: InStream;
        FileName: Text;
        POSEntry: Record "POS Entry";
        POSUnit: Record "POS Unit";
    begin
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
          exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
          exit;

        if not (POSWorkshiftCheckpoint.Type in [POSWorkshiftCheckpoint.Type::PREPORT]) then
          exit;

        // Sign Archive
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSAuditLogMgt.CreateEntry(POSWorkshiftCheckpoint.RecordId,POSAuditLog."Action Type"::ARCHIVE_CREATE,POSEntry."Entry No.",POSEntry."Fiscal No.",POSWorkshiftCheckpoint."POS Unit No.");

        //Export Archive
        POSWorkshiftCheckpoint.SetRecFilter;
        TempBlob.Blob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        FRPeriodArchive.SetDestination(OutStream);
        FRPeriodArchive.SetTableView(POSWorkshiftCheckpoint);
        FRPeriodArchive.Export();
        TempBlob.Blob.CreateInStream(InStream, TEXTENCODING::UTF8);
        FileName := 'Archive.xml';
        DownloadFromStream(InStream, 'Download Archive', '', '', FileName);
        Clear(InStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "POS Audit Log")
    var
        POSUnit: Record "POS Unit";
    begin
        if (POSAuditLog."Active POS Unit No." = '') then
          POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No."; //Performing POS operation like JET init from backend, acting as the POS.
        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
          exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
          exit;
        LoadCertificate();

        case POSAuditLog."Action Type" of
          POSAuditLog."Action Type"::DIRECT_SALE_END : SignTicket(POSAuditLog);
          POSAuditLog."Action Type"::ARCHIVE_ATTEMPT : SignArchiveAttempt(POSAuditLog);
          POSAuditLog."Action Type"::RECEIPT_COPY : SignReprintTicket(POSAuditLog);
          POSAuditLog."Action Type"::SIGN_IN : SignLogIn(POSAuditLog);
          POSAuditLog."Action Type"::WORKSHIFT_END : SignWorkshift(POSAuditLog);
          POSAuditLog."Action Type"::DRAWER_COUNT : SignDrawerCount(POSAuditLog);
          POSAuditLog."Action Type"::PARTNER_MODIFICATION : SignPartnerModification(POSAuditLog);
          POSAuditLog."Action Type"::LOG_INIT : SignLogInit(POSAuditLog);
          POSAuditLog."Action Type"::AUDIT_VERIFY : SignAuditVerify(POSAuditLog);
          POSAuditLog."Action Type"::GRANDTOTAL : SignGrandTotal(POSAuditLog);
          POSAuditLog."Action Type"::ARCHIVE_CREATE : SignArchiveFile(POSAuditLog);

          //POSAuditLog."Action Type"::SIGN_OUT : SignLogOut(POSAuditLog); //We do not track logouts straight away - the NAV session might stay open until timeout.

          //Events below are not performed directly on the POS so they are not handled for the certification.

          //POSAuditLog.Type::DATA_EXPORT : SignDataExport(POSAuditLog);
          //POSAuditLog.Type::DATA_IMPORT : SignDataImport(POSAuditLog);
          //POSAuditLog.Type::PERMISSION_MODIFY : SignPermissionModify(POSAuditLog);
          //POSAuditLog.Type::DATA_PURGE : SignDataPurge(POSAuditLog);
          //POSAuditLog.Type::COMPLIANCE_MODIFICATION : SignComplianceModification(POSAuditLog);
          //POSAuditLog.Type::SETUP_MODIFICATION : SignSetupModification(POSAuditLog);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014534, 'OnSalesReceiptFooter', '', true, true)]
    local procedure OnReceiptFooter(var TemplateLine: Record "RP Template Line";ReceiptNo: Text)
    var
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        Licenceinformation: Codeunit "Licence information";
        POSEntry: Record "POS Entry";
        AuditLog: Record "POS Audit Log";
        PrintSignature: Text;
        InStream: InStream;
        Signature: Text;
        POSUnit: Record "POS Unit";
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

        PrintSignature := CopyStr(Signature,3,1) + CopyStr(Signature,7,1) + CopyStr(Signature,13,1) + CopyStr(Signature,19,1);
        LinePrintMgt.AddTextField(1, TemplateLine.Align, PrintSignature);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150619, 'OnValidateLogRecords', '', true, true)]
    local procedure OnValidateLogRecords(var POSAuditLog: Record "POS Audit Log";var Handled: Boolean)
    var
        BaseValue: Text;
        Signature: Text;
        PreviousSignature: Text;
        InStream: InStream;
        First: Boolean;
        NPAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        RecordID: RecordID;
        NPAuditLog: Record "POS Audit Log";
        POSUnit: Record "POS Unit";
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
            FillSignatureBaseValues(POSAuditLog,false);
            POSAuditLog.Modify;
          until POSAuditLog.Next = 0;

        Commit;

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

            if not VerifySignature(BaseValue,'SHA1',DecodeBase64URL(Signature)) then
              Error(ERROR_SIGNATURE_VALUE, POSAuditLog.TableCaption, POSAuditLog."Entry No.");

            First := false;
          until POSAuditLog.Next = 0;
        end;

        Message(CAPTION_SIGNATURES_VALID, POSAuditLog.Count());
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150627, 'OnCheckTriggerAutoPeriodCheckpoint', '', true, true)]
    local procedure OnCheckTriggerAutoPeriodCheckpoint(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";var AutoCreatePeriod: Boolean)
    var
        POSWorkshifts: Record "POS Workshift Checkpoint";
        POSEntry: Record "POS Entry";
        POSUnit: Record "POS Unit";
    begin
        if POSWorkshiftCheckpoint."POS Unit No." = '' then
          exit;
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
          exit;
        if not IsEnabled(POSUnit."POS Audit Profile") then
          exit;

        POSWorkshifts.SetRange("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSWorkshifts.SetRange(Type, POSWorkshifts.Type::PREPORT);
        if not POSWorkshifts.FindLast then begin
          POSWorkshifts.SetRange(Type, POSWorkshifts.Type::ZREPORT);
          if not POSWorkshifts.FindLast then
            exit;
        end;

        POSEntry.Get(POSWorkshifts."POS Entry No.");

        AutoCreatePeriod := CalcDate(FRCertificationSetup."Workshift Period Duration", POSEntry."Document Date") <= Today;
    end;
}

