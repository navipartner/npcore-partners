codeunit 6184890 "NPR FR Audit Subscribers"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    var
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := FRAuditMgt.HandlerCode();
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnArchiveWorkshiftPeriod', '', true, true)]
    local procedure OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSUnit: Record "NPR POS Unit";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        TempBlob: Codeunit "Temp Blob";
        Handled: Boolean;
        InStream: InStream;
        FileName: Text;
    begin
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            exit;
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSWorkshiftCheckpoint.TestField(Type, POSWorkshiftCheckpoint.Type::PREPORT);
        POSWorkshiftCheckpoint.TestField("Period Type", FRAuditMgt.MonthlyPeriodType());

        FRAuditMgt.GenerateArchive(POSWorkshiftCheckpoint, TempBlob);

        FRAuditMgt.OnBeforeDownloadArchive(TempBlob, Handled);
        if Handled then
            exit;

        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        FileName := 'Archive.xml';
        DownloadFromStream(InStream, 'Download Archive', '', '', FileName);
        Clear(InStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        FRAuditMgt.SignEvent(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogAfterInsert', '', false, false)]
    local procedure OnHandleAuditLogAfterInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        FRAuditMgt.CreatePOSAuditLogAdditionalInfoRecord(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Aux: Event Publishers", 'OnSalesReceiptFooter', '', true, true)]
    local procedure OnReceiptFooter(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text; LinePrintMgt: Codeunit "NPR RP Line Print Mgt.")
    var
        AuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        InStream: InStream;
        MissingSignatureErr: Label '%1 %2 is missing a digital signature';
        PrintSignature: Text;
        Signature: Text;
        SignatureChunk: Text;
    begin
        POSEntry.SetRange("Document No.", ReceiptNo);
        if not POSEntry.FindFirst() then
            exit;
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
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
            Error(MissingSignatureErr, POSEntry.TableCaption, POSEntry."Entry No.");

        AuditLog."Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(SignatureChunk);
            Signature += SignatureChunk;
        end;

        LinePrintMgt.AddTextField(1, TemplateLine.Align, Format(AuditLog."Log Timestamp", 0, 3));
        PrintSignature := CopyStr(Signature, 3, 1) + CopyStr(Signature, 7, 1) + CopyStr(Signature, 13, 1) + CopyStr(Signature, 19, 1);
        LinePrintMgt.AddTextField(1, TemplateLine.Align, PrintSignature);
        LinePrintMgt.AddTextField(1, TemplateLine.Align, 'NF525/0274-1 (B)');
        LinePrintMgt.AddTextField(1, TemplateLine.Align, FRAuditMgt.GetFiscalVersion());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnValidateLogRecords', '', true, true)]
    local procedure OnValidateLogRecords(var POSAuditLog: Record "NPR POS Audit Log"; var Handled: Boolean; var Error: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        if not POSAuditLog.FindFirst() then
            exit;
        if POSAuditLog."Active POS Unit No." = '' then
            exit;
        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        Handled := true;
        Error := true;

        FRAuditMgt.ValidateAuditLogIntegrity(POSAuditLog);

        Error := false;
        Error(''); //Rollback modifications to entries done while recalculating & verifying signature.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workshift Checkpoint", 'OnAfterCreateBalancingEntry', '', false, false)]
    local procedure OnAfterCreateBalancingEntry(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        FRAuditSetup: Record "NPR FR Audit Setup";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        POSWorkshiftCheckpointMgt: Codeunit "NPR POS Workshift Checkpoint";
        FromWorkshiftEntry: Integer;
    begin
        if POSWorkshiftCheckpoint."POS Unit No." = '' then
            exit;
        if POSWorkshiftCheckpoint.Type <> POSWorkshiftCheckpoint.Type::ZREPORT then
            exit;
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            exit;
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        FRAuditSetup.Get();

        if FRAuditMgt.TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint, FRAuditMgt.MonthlyPeriodType(), FRAuditSetup."Monthly Workshift Duration", FromWorkshiftEntry) then
            POSWorkshiftCheckpointMgt.CreatePeriodCheckpoint(POSWorkshiftCheckpoint."POS Entry No.", POSUnit."No.", FromWorkshiftEntry, POSWorkshiftCheckpoint."Entry No.", FRAuditMgt.MonthlyPeriodType());

        if FRAuditMgt.TriggerWorkshiftCheckpoint(POSWorkshiftCheckpoint, FRAuditMgt.YearlyPeriodType(), FRAuditSetup."Yearly Workshift Duration", FromWorkshiftEntry) then
            POSWorkshiftCheckpointMgt.CreatePeriodCheckpoint(POSWorkshiftCheckpoint."POS Entry No.", POSUnit."No.", FromWorkshiftEntry, POSWorkshiftCheckpoint."Entry No.", FRAuditMgt.YearlyPeriodType());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Setup Safety Check", 'OnAfterValidateSetup', '', false, false)]
    local procedure OnBeforeLogin()
    var
        FRSetupCheck: Codeunit "NPR FR Setup Check";
    begin
        FRSetupCheck.RunCheck();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnGetDisplayVersion', '', false, false)]
    local procedure OnGetDisplayVersion(var DisplayVersion: Text)
    var
        POSUnit: Record "NPR POS Unit";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        DisplayVersion := StrSubstNo('%1, NF525/%2', FRAuditMgt.GetFiscalVersion(), FRAuditMgt.GetCertificationNumber());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnShowAdditionalInfo', '', false, false)]
    local procedure OnShowAdditionalInfo(POSAuditLog: Record "NPR POS Audit Log")
    var
        POSAuditLogAddInfo: Record "NPR FR POS Audit Log Add. Info";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        if POSAuditLog."External Implementation" <> FRAuditMgt.ImplementationCode() then
            exit;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retail Report Select. Mgt.", 'OnBeforeRunReportSelectionType', '', false, false)]
    local procedure OnBeforeRunReportSelectionType(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSUnit: Record "NPR POS Unit";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        POSEntryOutputLogMgt: Codeunit "NPR POS Entry Output Log Mgt.";
    begin
        if RecRef.Number <> Database::"NPR POS Entry" then
            exit;
        RecRef.SetTable(POSEntry);
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;
        POSEntryOutputLog.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryOutputLog.IsEmpty() then
            exit;
        POSEntryOutputLogMgt.LogOutput(RecRef, ReportSelectionRetail);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retail Report Select. Mgt.", 'OnBeforeLogOutput', '', false, false)]
    local procedure BeforeLogOutput(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef; var Handled: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSUnit: Record "NPR POS Unit";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        if RecRef.Number <> Database::"NPR POS Entry" then
            exit;
        RecRef.SetTable(POSEntry);
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;
        POSEntryOutputLog.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryOutputLog.Count() <= 1 then
            exit;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Aux - Misc. Library", 'OnAfterGetReceiptPrintCount', '', false, false)]
    local procedure OnAfterGetReceiptPrintCount(RecRef: RecordRef; var ProcessingValue: Text[2048]; IncludeFirstPrint: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSEntryOutputLog2: Record "NPR POS Entry Output Log";
        POSUnit: Record "NPR POS Unit";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        EntryNo: Integer;
    begin
        case RecRef.Number of
            Database::"NPR POS Entry Output Log":
                begin
                    RecRef.SetTable(POSEntryOutputLog);
                    POSEntryOutputLog.Find();
                    EntryNo := POSEntryOutputLog."POS Entry No.";
                end;
            Database::"NPR POS Entry":
                begin
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find();
                    EntryNo := POSEntry."Entry No.";
                end;
        end;

        if not POSEntry.Get(EntryNo) then
            exit;
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSEntryOutputLog2.SetRange("POS Entry No.", EntryNo);
        POSEntryOutputLog2.SetRange("Output Method", POSEntryOutputLog2."Output Method"::Print);
        POSEntryOutputLog2.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog2."Output Type"::SalesReceipt, POSEntryOutputLog2."Output Type"::LargeSalesReceipt);

        if IncludeFirstPrint then
            ProcessingValue := Format(POSEntryOutputLog2.Count())
        else
            ProcessingValue := Format(POSEntryOutputLog2.Count() - 1);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCompanyInformation(var Rec: Record "Company Information"; var xRec: Record "Company Information"; RunTrigger: Boolean)
    var
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary() then
            exit;

        // Log JET Event 128 for VAT Registration Number changes
        FRAuditMgt.LogVATRegistrationChange(Rec, xRec);

        // Log JET Event 410 for other company data changes
        FRAuditMgt.LogCompanyDataChange(Rec, xRec);
    end;
}