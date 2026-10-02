codeunit 85490 "NPR DK Signature Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryDKFiscal: Codeunit "NPR Library DK Fiscal";
        _ExpectedConfirmQuestions: List of [Text];
        _ConfirmReplies: List of [Boolean];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEndSignatureVerifiesWithSHA512()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        // [SCENARIO] Skattestyrelsen only accepts RSA-SHA512-3072 signatures (digital-signature guide v1.5.2, section 1).

        // [GIVEN] DK fiscalization with a 3072-bit RSA signing certificate
        // [WHEN] A sale end is logged
        SignSaleEnd(POSAuditLog);

        // [THEN] The signature verifies against the signed data with SHA512
        _Assert.IsTrue(
            DKAuditMgt.VerifySignature(ReadBlob(POSAuditLog, POSAuditLog.FieldNo("Signature Base Value")), Enum::"Hash Algorithm"::SHA512, GetStandardBase64Signature(POSAuditLog)),
            'The sale end signature must be an RSA signature over a SHA512 hash.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleEndRecordsSigningAlgorithm()
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        // [SCENARIO] The audit log records the algorithm and key size the signature was made with.

        // [GIVEN] DK fiscalization with a 3072-bit RSA signing certificate
        // [WHEN] A sale end is logged
        SignSaleEnd(POSAuditLog);

        // [THEN] The entry is marked as RSA-SHA512-3072
        _Assert.AreEqual('RSA-SHA512-3072', POSAuditLog."Certificate Implementation", 'The audit log must record the RSA-SHA512-3072 signing algorithm.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Signing3072BitRSACertificateIsAccepted()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        POSUnit: Record "NPR POS Unit";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        // [SCENARIO] A certificate with a 3072-bit RSA key can be used for signing.

        // [GIVEN] DK fiscalization without a signing certificate
        _LibraryDKFiscal.CreateDKAuditSetupWithoutCertificate(POSUnit);

        // [WHEN] A certificate with a 3072-bit RSA key is uploaded
        _Assert.IsTrue(DKAuditMgt.SetSigningCertificate(_LibraryDKFiscal.GetRSA3072TestCert()), 'The 3072-bit certificate must be accepted.');

        // [THEN] The certificate is stored with its thumbprint
        DKFiscalizationSetup.Get();
        _Assert.AreEqual(_LibraryDKFiscal.GetRSA3072TestCertThumbprint(), DKFiscalizationSetup."Signing Certificate Thumbprint", 'The uploaded certificate thumbprint must be stored.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Signing2048BitRSACertificateIsStoredAfterConfirmation()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        POSUnit: Record "NPR POS Unit";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        // [SCENARIO] Existing customers can re-upload their 2048-bit certificate after being warned that Skattestyrelsen requires 3072 bits.

        Initialize();

        // [GIVEN] DK fiscalization without a signing certificate
        _LibraryDKFiscal.CreateDKAuditSetupWithoutCertificate(POSUnit);

        // [WHEN] A certificate with a 2048-bit RSA key is uploaded and the user confirms the warning naming the key size
        EnqueueConfirm('2048-bit RSA key', true);
        _Assert.IsTrue(DKAuditMgt.SetSigningCertificate(_LibraryDKFiscal.GetRSA2048TestCert()), 'The certificate must be stored when the user confirms.');

        // [THEN] The warning was shown once, and the certificate is stored
        AssertAllConfirmsRaised();
        DKFiscalizationSetup.Get();
        _Assert.AreEqual(_LibraryDKFiscal.GetRSA2048TestCertThumbprint(), DKFiscalizationSetup."Signing Certificate Thumbprint", 'The confirmed certificate must be stored.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Signing2048BitRSACertificateDeclinedKeepsCurrentCertificate()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        POSUnit: Record "NPR POS Unit";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        // [SCENARIO] Declining the key-size warning leaves the current certificate in place.

        Initialize();

        // [GIVEN] DK fiscalization with a 3072-bit RSA signing certificate
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);

        // [WHEN] A certificate with a 2048-bit RSA key is uploaded and the user declines the warning naming the key size
        EnqueueConfirm('2048-bit RSA key', false);
        _Assert.IsFalse(DKAuditMgt.SetSigningCertificate(_LibraryDKFiscal.GetRSA2048TestCert()), 'The certificate must not be stored when the user declines.');

        // [THEN] The warning was shown once, and the 3072-bit certificate is still the signing certificate
        AssertAllConfirmsRaised();
        DKFiscalizationSetup.Get();
        _Assert.AreEqual(_LibraryDKFiscal.GetRSA3072TestCertThumbprint(), DKFiscalizationSetup."Signing Certificate Thumbprint", 'The current certificate must be kept.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SigningNonRSACertificateIsRejected()
    var
        POSUnit: Record "NPR POS Unit";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        // [SCENARIO] Skattestyrelsen requires an RSA key, so a certificate with another key type cannot be uploaded.

        // [GIVEN] DK fiscalization without a signing certificate
        _LibraryDKFiscal.CreateDKAuditSetupWithoutCertificate(POSUnit);

        // [WHEN] A certificate with an EC key is uploaded
        asserterror DKAuditMgt.SetSigningCertificate(_LibraryDKFiscal.GetECTestCert());

        // [THEN] The upload is refused because the certificate has no readable RSA key
        _Assert.ExpectedError('does not have a readable RSA key');
        _Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistingRSA2048CertificateKeepsSigning()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
    begin
        // [SCENARIO] Customers whose 2048-bit certificate was uploaded before the key-size check can keep selling.

        // [GIVEN] DK fiscalization with a 2048-bit RSA certificate that was stored before upload validation existed
        _LibraryDKFiscal.CreateDKAuditSetupWithoutCertificate(POSUnit);
        _LibraryDKFiscal.StoreExistingRSA2048SigningCertificate();

        // [WHEN] A sale end is logged
        LogSaleEnd(POSUnit, POSAuditLog);

        // [THEN] The sale is signed with SHA512 and the audit log records the 2048-bit key that was used
        _Assert.AreEqual('RSA-SHA512-2048', POSAuditLog."Certificate Implementation", 'The audit log must record the actual key size of the existing certificate.');
        _Assert.IsTrue(
            DKAuditMgt.VerifySignature(ReadBlob(POSAuditLog, POSAuditLog.FieldNo("Signature Base Value")), Enum::"Hash Algorithm"::SHA512, GetStandardBase64Signature(POSAuditLog)),
            'A sale signed with an existing 2048-bit certificate must be an RSA signature over a SHA512 hash.');
    end;

    local procedure SignSaleEnd(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        LogSaleEnd(POSUnit, POSAuditLog);
    end;

    local procedure LogSaleEnd(POSUnit: Record "NPR POS Unit"; var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSSession: Codeunit "NPR POS Session";
    begin
        // An earlier POS test codeunit can leave its POS session open, and the audit log would then read that session's sale.
        POSSession.ClearAll();
        Clear(POSSession);

        // No library helper creates a finished fiscal POS entry without running a full POS sale.
        POSEntry.Init();
        POSEntry."POS Store Code" := POSUnit."POS Store Code";
        POSEntry."POS Unit No." := POSUnit."No.";
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry."Entry Date" := WorkDate();
        POSEntry."Starting Time" := 120000T;
        POSEntry."Fiscal No." := 'DKSIGN-1';
        POSEntry."Amount Incl. Tax" := 125;
        POSEntry."Amount Excl. Tax" := 100;
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry.Insert();

        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId(),POSAuditLog."Action Type"::DIRECT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSUnit."No.", '', '');

        POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        POSAuditLog.FindFirst();
    end;

    local procedure GetStandardBase64Signature(POSAuditLog: Record "NPR POS Audit Log") Signature: Text
    begin
        // The signature is stored as base64url without padding (tracked separately in COM-1675), so convert it back to standard base64.
        Signature := ConvertStr(ReadBlob(POSAuditLog, POSAuditLog.FieldNo("Electronic Signature")), '_-', '/+');
        while StrLen(Signature) mod 4 <> 0 do
            Signature += '=';
    end;

    local procedure ReadBlob(POSAuditLog: Record "NPR POS Audit Log"; FieldNo: Integer) Content: Text
    var
        RecRef: RecordRef;
        BlobFieldRef: FieldRef;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        Chunk: Text;
    begin
        RecRef.GetTable(POSAuditLog);
        BlobFieldRef := RecRef.Field(FieldNo);
        BlobFieldRef.CalcField();
        TempBlob.FromFieldRef(BlobFieldRef);
        _Assert.IsTrue(TempBlob.HasValue(), StrSubstNo('%1 must have a value.', BlobFieldRef.Caption()));
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        while not InStr.EOS() do begin
            InStr.ReadText(Chunk);
            Content += Chunk;
        end;
    end;

    local procedure Initialize()
    begin
        Clear(_ExpectedConfirmQuestions);
        Clear(_ConfirmReplies);
    end;

    local procedure EnqueueConfirm(ExpectedQuestion: Text; Reply: Boolean)
    begin
        _ExpectedConfirmQuestions.Add(ExpectedQuestion);
        _ConfirmReplies.Add(Reply);
    end;

    local procedure AssertAllConfirmsRaised()
    begin
        _Assert.AreEqual(0, _ExpectedConfirmQuestions.Count(), 'Not every expected confirmation was raised.');
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _Assert.AreNotEqual(0, _ExpectedConfirmQuestions.Count(), StrSubstNo('Unexpected confirmation: ''%1''.', Question));
        _Assert.ExpectedConfirm(_ExpectedConfirmQuestions.Get(1), Question);
        Reply := _ConfirmReplies.Get(1);
        _ExpectedConfirmQuestions.RemoveAt(1);
        _ConfirmReplies.RemoveAt(1);
    end;
}
