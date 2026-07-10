codeunit 6151255 "NPR DE Audit Facade"
{
    Access = Public;
    Permissions = tabledata "NPR DE POS Audit Log Aux. Info" = r;

    /// <summary>
    /// Loads the DE Fiskaly audit data for a POS entry into a buffer that can be used for custom receipt printing.
    /// </summary>
    /// <param name="POSEntry">The POS entry to load the audit data for.</param>
    /// <param name="TempDEAuditBuffer">Return buffer, cleared and filled with a single row when audit data exists.</param>
    /// <returns>True if audit data exists for the POS entry; otherwise false.</returns>
    procedure GetAuditData(POSEntry: Record "NPR POS Entry"; var TempDEAuditBuffer: Record "NPR DE Audit Buffer" temporary): Boolean
    begin
        exit(GetAuditData(POSEntry."Entry No.", TempDEAuditBuffer));
    end;

    /// <summary>
    /// Loads the DE Fiskaly audit data for a POS entry into a buffer that can be used for custom receipt printing.
    /// </summary>
    /// <param name="POSEntryNo">The entry number of the POS entry to load the audit data for.</param>
    /// <param name="TempDEAuditBuffer">Return buffer, cleared and filled with a single row when audit data exists.</param>
    /// <returns>True if audit data exists for the POS entry; otherwise false.</returns>
    procedure GetAuditData(POSEntryNo: Integer; var TempDEAuditBuffer: Record "NPR DE Audit Buffer" temporary): Boolean
    var
        DEPOSAuditLogAuxInfo: Record "NPR DE POS Audit Log Aux. Info";
    begin
        TempDEAuditBuffer.Reset();
        TempDEAuditBuffer.DeleteAll();

        if not DEPOSAuditLogAuxInfo.Get(POSEntryNo) then
            exit(false);

        FillBuffer(DEPOSAuditLogAuxInfo, TempDEAuditBuffer);
        exit(true);
    end;

    /// <summary>
    /// Loads the DE Fiskaly audit data for a filtered set of POS entries into a buffer that can be used for custom receipt printing.
    /// The caller applies the wanted filters on <paramref name="POSEntry"/> before calling. The buffer is keyed by "POS Entry No.",
    /// so iterating it returns POS-entry-number order regardless of the sorting applied on <paramref name="POSEntry"/>.
    /// POS entries without audit data are skipped.
    /// </summary>
    /// <param name="POSEntry">The filtered set of POS entries to load audit data for.</param>
    /// <param name="TempDEAuditBuffer">Return buffer, cleared and filled with one row per POS entry that has audit data.</param>
    /// <returns>The number of buffer rows filled.</returns>
    procedure GetAuditDataSet(var POSEntry: Record "NPR POS Entry"; var TempDEAuditBuffer: Record "NPR DE Audit Buffer" temporary) RowsFilled: Integer
    var
        DEPOSAuditLogAuxInfo: Record "NPR DE POS Audit Log Aux. Info";
    begin
        TempDEAuditBuffer.Reset();
        TempDEAuditBuffer.DeleteAll();

        if POSEntry.FindSet() then
            repeat
                if DEPOSAuditLogAuxInfo.Get(POSEntry."Entry No.") then begin
                    FillBuffer(DEPOSAuditLogAuxInfo, TempDEAuditBuffer);
                    RowsFilled += 1;
                end;
            until POSEntry.Next() = 0;
    end;

    local procedure FillBuffer(var DEPOSAuditLogAuxInfo: Record "NPR DE POS Audit Log Aux. Info"; var TempDEAuditBuffer: Record "NPR DE Audit Buffer" temporary)
    var
        SignatureInStream: InStream;
        PublicKeyInStream: InStream;
        SignatureText: Text;
        PublicKeyText: Text;
    begin
        DEPOSAuditLogAuxInfo.CalcFields(Signature, "Public Key");
        if DEPOSAuditLogAuxInfo.Signature.HasValue() then begin
            DEPOSAuditLogAuxInfo.Signature.CreateInStream(SignatureInStream, TextEncoding::UTF8);
            SignatureInStream.ReadText(SignatureText);
        end;
        if DEPOSAuditLogAuxInfo."Public Key".HasValue() then begin
            DEPOSAuditLogAuxInfo."Public Key".CreateInStream(PublicKeyInStream, TextEncoding::UTF8);
            PublicKeyInStream.ReadText(PublicKeyText);
        end;

        TempDEAuditBuffer.Init();
        TempDEAuditBuffer."POS Entry No." := DEPOSAuditLogAuxInfo."POS Entry No.";
        TempDEAuditBuffer.SetQRData(DEPOSAuditLogAuxInfo.GetQRData());
        TempDEAuditBuffer."Transaction Number" := DEPOSAuditLogAuxInfo."Transaction Number";
        TempDEAuditBuffer."Start Time" := DEPOSAuditLogAuxInfo."Start Time";
        TempDEAuditBuffer."Finish Time" := DEPOSAuditLogAuxInfo."Finish Time";
        TempDEAuditBuffer."Time Format" := DEPOSAuditLogAuxInfo."Time Format";
        TempDEAuditBuffer."Signature Count" := DEPOSAuditLogAuxInfo."Signature Count";
        TempDEAuditBuffer.Signature := CopyStr(SignatureText, 1, MaxStrLen(TempDEAuditBuffer.Signature));
        TempDEAuditBuffer."Signature Algorithm" := DEPOSAuditLogAuxInfo."Signature Algorithm";
        TempDEAuditBuffer."Public Key" := CopyStr(PublicKeyText, 1, MaxStrLen(TempDEAuditBuffer."Public Key"));
        TempDEAuditBuffer."TSS Serial Number" := DEPOSAuditLogAuxInfo."TSS Serial Number";
        TempDEAuditBuffer."Client Serial Number" := DEPOSAuditLogAuxInfo."Serial Number";
        TempDEAuditBuffer."Is Cancellation" := DEPOSAuditLogAuxInfo."Fiskaly Transaction Type" = DEPOSAuditLogAuxInfo."Fiskaly Transaction Type"::CANCELLATION;
        TempDEAuditBuffer."Fiscalization Failed" := DEPOSAuditLogAuxInfo.IsFiscalizationFailed();
        TempDEAuditBuffer.Insert();
    end;
}
