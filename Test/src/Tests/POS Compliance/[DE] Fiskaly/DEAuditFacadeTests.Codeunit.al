codeunit 85499 "NPR DE Audit Facade Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetAuditData_UnfiscalizedEntry_ReturnsRowMarkedFailed()
    var
        TempDEAuditBuffer: Record "NPR DE Audit Buffer" temporary;
        DEAuditFacade: Codeunit "NPR DE Audit Facade";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] A receipt printed right after a sale whose Fiskaly call failed has no QR data yet
        // [GIVEN] A POS entry with DE audit data but no QR data
        POSEntryNo := CreatePOSEntryWithAuditData('', NewDocumentNo());

        // [WHEN] Loading the audit data for the receipt
        _Assert.IsTrue(DEAuditFacade.GetAuditData(POSEntryNo, TempDEAuditBuffer), 'Audit data should be found for the POS entry.');

        // [THEN] The row is returned, has no QR data and is marked as failed
        _Assert.AreEqual(1, TempDEAuditBuffer.Count(), 'Buffer should hold exactly one row.');
        TempDEAuditBuffer.FindFirst();
        _Assert.AreEqual(POSEntryNo, TempDEAuditBuffer."POS Entry No.", 'Buffer row should belong to the POS entry.');
        _Assert.IsFalse(TempDEAuditBuffer."QR Data".HasValue(), 'QR Data should be empty.');
        _Assert.AreEqual('', TempDEAuditBuffer.GetQRData(), 'GetQRData should return an empty text.');
        _Assert.IsTrue(TempDEAuditBuffer."Fiscalization Failed", 'Fiscalization Failed should be set.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetAuditData_FiscalizedEntry_ReturnsQRData()
    var
        TempDEAuditBuffer: Record "NPR DE Audit Buffer" temporary;
        DEAuditFacade: Codeunit "NPR DE Audit Facade";
        POSEntryNo: Integer;
        QRData: Text;
    begin
        // [GIVEN] A fiscalized POS entry with QR data
        QRData := 'V0;CLIENT;Kassenbeleg-V1;Beleg^10.00_0.00_0.00_0.00_0.00^10.00:Bar;1;2;2026-10-01T10:00:00.000Z;2026-10-01T10:00:01.000Z;ecdsa-plain-SHA256;unixTime;SIG;PUBKEY';
        POSEntryNo := CreatePOSEntryWithAuditData(QRData, NewDocumentNo());

        // [WHEN] Loading the audit data for the receipt
        _Assert.IsTrue(DEAuditFacade.GetAuditData(POSEntryNo, TempDEAuditBuffer), 'Audit data should be found for the POS entry.');

        // [THEN] The QR data is returned and the row is not marked as failed
        TempDEAuditBuffer.FindFirst();
        _Assert.AreEqual(QRData, TempDEAuditBuffer.GetQRData(), 'GetQRData should return the stored QR data.');
        _Assert.IsFalse(TempDEAuditBuffer."Fiscalization Failed", 'Fiscalization Failed should not be set.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetAuditDataSet_MixedEntries_ReturnsAllRows()
    var
        POSEntry: Record "NPR POS Entry";
        TempDEAuditBuffer: Record "NPR DE Audit Buffer" temporary;
        DEAuditFacade: Codeunit "NPR DE Audit Facade";
        FiscalizedEntryNo: Integer;
        UnfiscalizedEntryNo: Integer;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Two POS entries in one document range, one fiscalized and one without QR data
        DocumentNo := NewDocumentNo();
        FiscalizedEntryNo := CreatePOSEntryWithAuditData('QR', DocumentNo);
        UnfiscalizedEntryNo := CreatePOSEntryWithAuditData('', DocumentNo);

        // [WHEN] Loading the audit data for both entries
        POSEntry.SetRange("Document No.", DocumentNo);
        _Assert.AreEqual(2, DEAuditFacade.GetAuditDataSet(POSEntry, TempDEAuditBuffer), 'Both entries should be loaded.');

        // [THEN] Only the entry without QR data is marked as failed
        TempDEAuditBuffer.Get(FiscalizedEntryNo);
        _Assert.IsFalse(TempDEAuditBuffer."Fiscalization Failed", 'The fiscalized entry should not be marked as failed.');
        TempDEAuditBuffer.Get(UnfiscalizedEntryNo);
        _Assert.IsTrue(TempDEAuditBuffer."Fiscalization Failed", 'The entry without QR data should be marked as failed.');
    end;

    local procedure NewDocumentNo(): Code[20]
    begin
        exit(CopyStr(Format(CreateGuid(), 0, 3), 1, 20));
    end;

    local procedure CreatePOSEntryWithAuditData(QRData: Text; DocumentNo: Code[20]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        DEPOSAuditLogAuxInfo: Record "NPR DE POS Audit Log Aux. Info";
        OutStr: OutStream;
    begin
        POSEntry.Init();
        POSEntry."Entry No." := 0;
        POSEntry."Document No." := DocumentNo;
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry.Insert();

        DEPOSAuditLogAuxInfo.Init();
        DEPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        DEPOSAuditLogAuxInfo."Fiskaly Transaction Type" := DEPOSAuditLogAuxInfo."Fiskaly Transaction Type"::RECEIPT;
        if QRData = '' then begin
            DEPOSAuditLogAuxInfo."Fiscalization Status" := DEPOSAuditLogAuxInfo."Fiscalization Status"::"Not Fiscalized";
            DEPOSAuditLogAuxInfo."Has Error" := true;
        end else begin
            DEPOSAuditLogAuxInfo."Fiscalization Status" := DEPOSAuditLogAuxInfo."Fiscalization Status"::Fiscalized;
            DEPOSAuditLogAuxInfo."QR Data".CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(QRData);
        end;
        DEPOSAuditLogAuxInfo.Insert(true);
        exit(POSEntry."Entry No.");
    end;
}
