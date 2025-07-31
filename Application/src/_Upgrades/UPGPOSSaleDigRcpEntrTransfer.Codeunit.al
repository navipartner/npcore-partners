codeunit 6248501 "NPR UPG POSSalDigRcpEntrTransf"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradePOSSaleDigitalReceiptEntry();
    end;

    local procedure UpgradePOSSaleDigitalReceiptEntry()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POSSalDigRcpEntrTransf', 'UpgradePOSSaleDigitalReceiptEntryTransfer');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradePOSSaleDigitalReceiptEntryTransfer')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePOSSaleDigitalReceiptEntryTransfer();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradePOSSaleDigitalReceiptEntryTransfer'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSSaleDigitalReceiptEntryTransfer()
    var
#IF (BC17 OR BC18 OR BC19 OR BC20)
        POSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry";
#ENDIF
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20)
        if not POSSaleDigitalReceiptEntry.FindSet() then
            exit;
        repeat
            InsertPOSSaleDigitalReceiptEntry(POSSaleDigitalReceiptEntry);
        until POSSaleDigitalReceiptEntry.Next() = 0;
#ELSE
        DataTransferPOSSaleDigitalReceiptEntry();
#ENDIF
    end;

#IF (BC17 OR BC18 OR BC19 OR BC20)
    local procedure InsertPOSSaleDigitalReceiptEntry(POSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry")
    var
        NewPOSSaleDigReceiptEntry: Record "NPR POSSale Dig. Receipt Entry";
    begin
        Clear(NewPOSSaleDigReceiptEntry);
        NewPOSSaleDigReceiptEntry.Init();
        NewPOSSaleDigReceiptEntry.Id := POSSaleDigitalReceiptEntry.Id;
        NewPOSSaleDigReceiptEntry.PDFLink := POSSaleDigitalReceiptEntry.PDFLink;
        NewPOSSaleDigReceiptEntry."POS Unit No." := POSSaleDigitalReceiptEntry."POS Unit No.";
        NewPOSSaleDigReceiptEntry."Sales Ticket No." := POSSaleDigitalReceiptEntry."Sales Ticket No.";
        NewPOSSaleDigReceiptEntry."POS Entry No." := POSSaleDigitalReceiptEntry."POS Entry No.";
        NewPOSSaleDigReceiptEntry."QR Code Link" := POSSaleDigitalReceiptEntry."QR Code Link";
        NewPOSSaleDigReceiptEntry.Insert();
    end;
#ELSE
    local procedure DataTransferPOSSaleDigitalReceiptEntry()
    var
        POSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry";
        NewPOSSaleDigReceiptEntry: Record "NPR POSSale Dig. Receipt Entry";
        DTransfer: DataTransfer;
    begin
        DTransfer.SetTables(Database::"NPR POSSaleDigitalReceiptEntry", Database::"NPR POSSale Dig. Receipt Entry");
        DTransfer.AddFieldValue(POSSaleDigitalReceiptEntry.FieldNo(Id), NewPOSSaleDigReceiptEntry.FieldNo(Id));
        DTransfer.AddFieldValue(POSSaleDigitalReceiptEntry.FieldNo(PDFLink), NewPOSSaleDigReceiptEntry.FieldNo(PDFLink));
        DTransfer.AddFieldValue(POSSaleDigitalReceiptEntry.FieldNo("POS Unit No."), NewPOSSaleDigReceiptEntry.FieldNo("POS Unit No."));
        DTransfer.AddFieldValue(POSSaleDigitalReceiptEntry.FieldNo("Sales Ticket No."), NewPOSSaleDigReceiptEntry.FieldNo("Sales Ticket No."));
        DTransfer.AddFieldValue(POSSaleDigitalReceiptEntry.FieldNo("POS Entry No."), NewPOSSaleDigReceiptEntry.FieldNo("POS Entry No."));
        DTransfer.AddFieldValue(POSSaleDigitalReceiptEntry.FieldNo("QR Code Link"), NewPOSSaleDigReceiptEntry.FieldNo("QR Code Link"));
        DTransfer.CopyRows();
    end;
#ENDIF

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POSSalDigRcpEntrTransf");
    end;
}
