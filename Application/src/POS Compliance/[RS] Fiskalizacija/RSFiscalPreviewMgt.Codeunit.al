codeunit 6059930 "NPR RS Fiscal Preview Mgt."
{
    Access = Internal;

    #region HTML Fiscal Preview
    internal procedure SetContentOfFiscalBillPrivew(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; PaymentMethodCode: Code[10]; Copy: Boolean): Text
    var
        HtmlContent: Text;
    begin
        if AddCurrentReceipt(AuditEntryNo, AuditEntryType, PaymentMethodCode, Copy, HtmlContent) then
            exit(HtmlContent);
        AddHtmlReceiptCopyIfExists(AuditEntryNo, AuditEntryType, Copy, HtmlContent);
        AddHtmlReceiptOriginal(AuditEntryNo, AuditEntryType, Copy, HtmlContent);
        AddEndingTags(HtmlContent);
        exit(HtmlContent);
    end;
    #endregion

    #region HTML Fiscal Generator
    local procedure SetParametersFromRecord(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; Copy: Boolean; var JournalText: Text; var QRVerifyURL: Text; var RSInvoiceType: Enum "NPR RS Invoice Type"; var RSTransactionType: Enum "NPR RS Transaction Type"; var DiscountAmount: Decimal; POSEntryNo: Integer)
    var
        RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
    begin
        case Copy of
            true:
                begin
                    RSPOSAuditLogAuxCopy.SetRange("Audit Entry Type", AuditEntryType);
                    RSPOSAuditLogAuxCopy.SetRange("Audit Entry No.", AuditEntryNo);
                    RSPOSAuditLogAuxCopy.FindLast();
                    JournalText := RSPOSAuditLogAuxCopy.Journal;
                    QRVerifyURL := RSPOSAuditLogAuxCopy."Verification URL";
                    RSInvoiceType := RSPOSAuditLogAuxCopy."RS Invoice Type";
                    RSTransactionType := RSPOSAuditLogAuxCopy."RS Transaction Type";
                    DiscountAmount := RSPOSAuditLogAuxCopy."Discount Amount";
                    POSEntryNo := RSPOSAuditLogAuxCopy."POS Entry No.";
                end;
            false:
                begin
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", AuditEntryType);
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", AuditEntryNo);
                    RSPOSAuditLogAuxInfo.FindLast();
                    JournalText := RSPOSAuditLogAuxInfo.Journal;
                    QRVerifyURL := RSPOSAuditLogAuxInfo."Verification URL";
                    RSInvoiceType := RSPOSAuditLogAuxInfo."RS Invoice Type";
                    RSTransactionType := RSPOSAuditLogAuxInfo."RS Transaction Type";
                    DiscountAmount := RSPOSAuditLogAuxInfo."Discount Amount";
                    POSEntryNo := RSPOSAuditLogAuxInfo."POS Entry No.";
                end;
        end;
    end;

    local procedure AddHtmlReceiptCopyIfExists(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; Copy: Boolean; var HtmlContent: Text)
    var
        RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
#if not BC17
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        Base64QRCodeImage: Text;
#endif
    begin
        if Copy then
            exit;
        RSPOSAuditLogAuxCopy.SetRange("Audit Entry Type", AuditEntryType);
        RSPOSAuditLogAuxCopy.SetRange("Audit Entry No.", AuditEntryNo);
        if not RSPOSAuditLogAuxCopy.FindLast() then
            exit;
        if StrLen(RSPOSAuditLogAuxCopy.Journal) = 0 then
            exit;
#if not BC17
        Base64QRCodeImage := BarcodeFontProviderMgt.GenerateQRCodeAZ(RSPOSAuditLogAuxCopy."Verification URL", 'M', 'UTF8', true, true, 2);

        HtmlContent += DoubleNewLineHtml + NonFiscalText + NewLineHtml + RSPOSAuditLogAuxCopy.Journal.Replace(EndingLineHtmlTags, NewLineHtml).Replace(NonFiscalText + NewLineHtml, '') +
                           PreBase64ImageTag + Base64QRCodeImage + AfterBase64ImageTag + NewLineHtml;
#else
        HtmlContent += DoubleNewLineHtml + NonFiscalText + NewLineHtml + RSPOSAuditLogAuxCopy.Journal.Replace(EndingLineHtmlTags, NewLineHtml).Replace(NonFiscalText + NewLineHtml, '') + NewLineHtml;
#endif
        if (RSPOSAuditLogAuxCopy."RS Invoice Type" in [RSPOSAuditLogAuxCopy."RS Invoice Type"::COPY]) and
            (RSPOSAuditLogAuxCopy."RS Transaction Type" in [RSPOSAuditLogAuxCopy."RS Transaction Type"::REFUND]) and
            (RSAuditMgt.POSCheckIfPaymentMethodCashAndDirectSale(RSPOSAuditLogAuxCopy."POS Entry No.") or not (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"])) or
            (RSAuditMgt.DocumentCheckIfPaymentMethodCash(RSPOSAuditLogAuxCopy."Payment Method Code") and not (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"])) then
            HtmlContent += DoubleNewLineHtml + PrintLineLbl + NewLineHtml + CustomerSignaturePrintLbl + NewLineHtml;
        HtmlContent += NonFiscalText;
    end;

    local procedure AddHtmlReceiptOriginal(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; Copy: Boolean; var HtmlContent: Text)
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
#if not BC17
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        Base64QRCodeImage: Text;
#endif
    begin
        if not Copy then
            exit;
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", AuditEntryType);
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", AuditEntryNo);
        if not RSPOSAuditLogAuxInfo.FindLast() then
            exit;
        if StrLen(RSPOSAuditLogAuxInfo.Journal) = 0 then
            exit;
#if not BC17
        Base64QRCodeImage := BarcodeFontProviderMgt.GenerateQRCodeAZ(RSPOSAuditLogAuxInfo."Verification URL", 'M', 'UTF8', true, true, 2);
        HtmlContent += DoubleNewLineHtml + NewLineHtml + RSPOSAuditLogAuxInfo.Journal.Replace(EndingLineHtmlTags, NewLineHtml).Replace(EndOfFiscalText + NewLineHtml, '') +
                        PreBase64ImageTag + Base64QRCodeImage + AfterBase64ImageTag + NewLineHtml;
#else
        HtmlContent += DoubleNewLineHtml + NewLineHtml + RSPOSAuditLogAuxInfo.Journal.Replace(EndingLineHtmlTags, NewLineHtml).Replace(EndOfFiscalText + NewLineHtml, '') + NewLineHtml;
#endif
        HtmlContent += EndOfFiscalText;
    end;

    local procedure AddCurrentReceipt(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; PaymentMethodCode: Code[10]; Copy: Boolean; var HtmlContent: Text): Boolean
    var
#if not BC17
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        Base64QRCodeImage: Text;
#endif
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        DiscountAmount: Decimal;
        RSInvoiceType: Enum "NPR RS Invoice Type";
        RSTransactionType: Enum "NPR RS Transaction Type";
        POSEntryNo: Integer;
        FiscalBillNotSentLbl: Label 'Fiscal Bill has not been sent to Tax authority.';
        JournalText: Text;
        QRVerifyURL: Text;
    begin
        SetParametersFromRecord(AuditEntryNo, AuditEntryType, Copy, JournalText, QRVerifyURL, RSInvoiceType, RSTransactionType, DiscountAmount, POSEntryNo);
        HtmlContent := OpeningHtmlTagForFiscal;
        if JournalText = '' then begin
            HtmlContent := FiscalBillNotSentLbl;
            AddEndingTags(HtmlContent);
            exit(true);
        end;
#if not BC17
        Base64QRCodeImage := BarcodeFontProviderMgt.GenerateQRCodeAZ(QRVerifyURL, 'M', 'UTF8', true, true, 2);
#endif
        case RSInvoiceType in [RSInvoiceType::COPY] of
            true:
                HtmlContent += NonFiscalText + NewLineHtml + JournalText.Replace(EndingLineHtmlTags, NewLineHtml).Replace(NonFiscalText + NewLineHtml, '');
            false:
                HtmlContent += JournalText.Replace(EndingLineHtmlTags, NewLineHtml).Replace(EndOfFiscalText + NewLineHtml, '');
        end;
#if not BC17
        HtmlContent += PreBase64ImageTag + Base64QRCodeImage + AfterBase64ImageTag + NewLineHtml;
#else
        HtmlContent += NewLineHtml;
#endif
        case RSInvoiceType in [RSInvoiceType::COPY] of
            true:
                begin
                    if (RSTransactionType in [RSTransactionType::REFUND]) and (RSAuditMgt.POSCheckIfPaymentMethodCashAndDirectSale(POSEntryNo) or not (AuditEntryType in [AuditEntryType::"POS Entry"])) and
                        (RSAuditMgt.DocumentCheckIfPaymentMethodCash(PaymentMethodCode) and not (AuditEntryType in [AuditEntryType::"POS Entry"])) then
                        HtmlContent += NewLineHtml + PrintLineLbl + NewLineHtml + CustomerSignaturePrintLbl + NewLineHtml;
                    HtmlContent += NonFiscalText;
                end;
            false:
                HtmlContent += EndOfFiscalText;
        end;
        if DiscountAmount <> 0 then
            HtmlContent += DoubleNewLineHtml + PrintLineLbl + NewLineHtml + HasDiscountHeadlineLbl + NewLineHtml + TotalDiscountAmountLbl + Format(Round(DiscountAmount)) + NewLineHtml + PrintLineLbl;
    end;

    local procedure AddEndingTags(var HtmlContent: Text)
    var
        EndingHtmlTags: Label '</pre></html>', Locked = true;
    begin
        HtmlContent += EndingHtmlTags;
    end;
    #endregion

    var
#if not BC17
        AfterBase64ImageTag: Label '" width="250" height="250">', Locked = true;
        PreBase64ImageTag: Label '<img src="data:image/gif;base64,', Locked = true;
#endif
        CustomerSignaturePrintLbl: Label '              Потпис купца              ', Locked = true;
        DoubleNewLineHtml: Label '<br/><br/>', Locked = true;
        EndingLineHtmlTags: Label '\r\n', Locked = true;
        EndOfFiscalText: Label '======== КРАЈ ФИСКАЛНОГ РАЧУНА =========', Locked = true;
        HasDiscountHeadlineLbl: Label 'ОСТВАРИЛИ СТЕ ПОПУСТ', Locked = true;
        NewLineHtml: Label '<br/>', Locked = true;
        NonFiscalText: Label '======== ОВО НИЈЕ ФИСКАЛНИ РАЧУН =======', Locked = true;
        OpeningHtmlTagForFiscal: Label '<html><pre style="font-family:monospace;text-align: center;">', Locked = true;
        PrintLineLbl: Label '________________________________________', Locked = true;
        TotalDiscountAmountLbl: Label 'Износ попуста: ', Locked = true;
}