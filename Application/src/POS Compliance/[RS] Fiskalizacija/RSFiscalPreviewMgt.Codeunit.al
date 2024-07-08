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
    local procedure SetParametersFromRecord(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; Copy: Boolean; var JournalText: Text; var QRVerifyURL: Text; var RSInvoiceType: Enum "NPR RS Invoice Type"; var RSTransactionType: Enum "NPR RS Transaction Type"; var DiscountAmount: Decimal; var POSEntryNo: Integer; var SourceDocumentNo: Code[20])
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
                    JournalText := RSPOSAuditLogAuxCopy.GetTextFromJournal();
                    QRVerifyURL := RSPOSAuditLogAuxCopy."Verification URL";
                    RSInvoiceType := RSPOSAuditLogAuxCopy."RS Invoice Type";
                    RSTransactionType := RSPOSAuditLogAuxCopy."RS Transaction Type";
                    DiscountAmount := RSPOSAuditLogAuxCopy."Discount Amount";
                    POSEntryNo := RSPOSAuditLogAuxCopy."POS Entry No.";
                    SourceDocumentNo := RSPOSAuditLogAuxCopy."Source Document No.";
                end;
            false:
                begin
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", AuditEntryType);
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", AuditEntryNo);
                    RSPOSAuditLogAuxInfo.FindLast();
                    JournalText := RSPOSAuditLogAuxInfo.GetTextFromJournal();
                    QRVerifyURL := RSPOSAuditLogAuxInfo."Verification URL";
                    RSInvoiceType := RSPOSAuditLogAuxInfo."RS Invoice Type";
                    RSTransactionType := RSPOSAuditLogAuxInfo."RS Transaction Type";
                    DiscountAmount := RSPOSAuditLogAuxInfo."Discount Amount";
                    POSEntryNo := RSPOSAuditLogAuxInfo."POS Entry No.";
                    SourceDocumentNo := RSPOSAuditLogAuxInfo."Source Document No.";
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
        IsHandled: Boolean;
#endif
        TempHtmlContent: Text;
    begin
        if Copy then
            exit;
        RSPOSAuditLogAuxCopy.SetRange("Audit Entry Type", AuditEntryType);
        RSPOSAuditLogAuxCopy.SetRange("Audit Entry No.", AuditEntryNo);
        if not RSPOSAuditLogAuxCopy.FindLast() then
            exit;
        if StrLen(RSPOSAuditLogAuxCopy.GetTextFromJournal()) = 0 then
            exit;
#if not BC17
        IsHandled := false;
        OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptCopyIfExists(Base64QRCodeImage, IsHandled);
        if not IsHandled then
            Base64QRCodeImage := BarcodeFontProviderMgt.GenerateQRCodeAZ(RSPOSAuditLogAuxCopy."Verification URL", 'M', 'UTF8', true, true, 2);

        TempHtmlContent += DoubleNewLineHtml + NewLineHtml + RSPOSAuditLogAuxCopy.GetTextFromJournal().Replace(EndingLineHtmlTags, NewLineHtml).Replace(NonFiscalText + NewLineHtml, '');
        if TempHtmlContent.Substring(StrLen(TempHtmlContent) - 100).Contains(NotFiscalBillVersion1Lbl) then
            TempHtmlContent := TempHtmlContent.Substring(1, StrLen(TempHtmlContent) - 45);
        TempHtmlContent += PreBase64ImageTag + Base64QRCodeImage + AfterBase64ImageTag + NewLineHtml;
#else
        TempHtmlContent += DoubleNewLineHtml + NewLineHtml + RSPOSAuditLogAuxCopy.GetTextFromJournal().Replace(EndingLineHtmlTags, NewLineHtml).Replace(NonFiscalText + NewLineHtml, '') + NewLineHtml;
         if TempHtmlContent.Substring(StrLen(TempHtmlContent) - 100).Contains(NotFiscalBillVersion1Lbl) then
            TempHtmlContent := TempHtmlContent.Substring(1, StrLen(TempHtmlContent) - 45);
#endif
        if (RSPOSAuditLogAuxCopy."RS Invoice Type" in [RSPOSAuditLogAuxCopy."RS Invoice Type"::COPY]) and
            (RSPOSAuditLogAuxCopy."RS Transaction Type" in [RSPOSAuditLogAuxCopy."RS Transaction Type"::REFUND]) and
            ((RSAuditMgt.POSCheckIfPaymentMethodCashAndDirectSale(RSPOSAuditLogAuxCopy."POS Entry No.") and (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"])) or
            (RSAuditMgt.DocumentCheckIfPaymentMethodCash(RSPOSAuditLogAuxCopy."Payment Method Code") and not (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"]))) then
            TempHtmlContent += DoubleNewLineHtml + PrintLineLbl + NewLineHtml + CustomerSignaturePrintLbl + NewLineHtml;
        TempHtmlContent += NonFiscalText;
        TempHtmlContent := TempHtmlContent.Replace(NotFiscalBillVersion1Lbl, NonFiscalText1);
        TempHtmlContent := TempHtmlContent.Replace(NotFiscalBillVersion2Lbl, NonFiscalText2);
        RemoveUnnecessaryFieldsFromJournal(TempHtmlContent, RSPOSAuditLogAuxCopy."RS Invoice Type", RSPOSAuditLogAuxCopy."RS Transaction Type");
        DeleteProformaPaymentAmounts(TempHtmlContent, RSPOSAuditLogAuxCopy."RS Invoice Type");
        AddReturnPaymentIfExist(TempHtmlContent, RSPOSAuditLogAuxCopy."POS Entry No.", RSPOSAuditLogAuxCopy."RS Transaction Type");
        HtmlContent += TempHtmlContent;
    end;

    local procedure AddHtmlReceiptOriginal(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; Copy: Boolean; var HtmlContent: Text)
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
#if not BC17
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        Base64QRCodeImage: Text;
        IsHandled: Boolean;
#endif
    begin
        if not Copy then
            exit;
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", AuditEntryType);
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", AuditEntryNo);
        if not RSPOSAuditLogAuxInfo.FindLast() then
            exit;
        if StrLen(RSPOSAuditLogAuxInfo.GetTextFromJournal()) = 0 then
            exit;
#if not BC17
        IsHandled := false;
        OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptOriginal(Base64QRCodeImage, IsHandled);
        if not IsHandled then
            Base64QRCodeImage := BarcodeFontProviderMgt.GenerateQRCodeAZ(RSPOSAuditLogAuxInfo."Verification URL", 'M', 'UTF8', true, true, 2);
        HtmlContent += DoubleNewLineHtml + NewLineHtml + RSPOSAuditLogAuxInfo.GetTextFromJournal().Replace(EndingLineHtmlTags, NewLineHtml).Replace(EndOfFiscalText + NewLineHtml, '') +
                        PreBase64ImageTag + Base64QRCodeImage + AfterBase64ImageTag + NewLineHtml;
#else
        HtmlContent += DoubleNewLineHtml + NewLineHtml + RSPOSAuditLogAuxInfo.GetTextFromJournal().Replace(EndingLineHtmlTags, NewLineHtml).Replace(EndOfFiscalText + NewLineHtml, '') + NewLineHtml;
#endif
        HtmlContent += EndOfFiscalText;
        RemoveUnnecessaryFieldsFromJournal(HtmlContent, RSPOSAuditLogAuxInfo."RS Invoice Type", RSPOSAuditLogAuxInfo."RS Transaction Type");
        DeleteProformaPaymentAmounts(HtmlContent, RSPOSAuditLogAuxInfo."RS Invoice Type");
        AddReturnPaymentIfExist(HtmlContent, RSPOSAuditLogAuxInfo."POS Entry No.", RSPOSAuditLogAuxInfo."RS Transaction Type");
    end;

    local procedure AddCurrentReceipt(AuditEntryNo: Integer; AuditEntryType: Enum "NPR RS Audit Entry Type"; PaymentMethodCode: Code[10]; Copy: Boolean; var HtmlContent: Text): Boolean
    var
#if not BC17
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
        Base64QRCodeImage: Text;
        IsHandled: Boolean;
#endif
        SourceDocumentNo: Code[20];
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        DiscountAmount: Decimal;
        RSInvoiceType: Enum "NPR RS Invoice Type";
        RSTransactionType: Enum "NPR RS Transaction Type";
        POSEntryNo: Integer;
        FiscalBillNotSentLbl: Label 'Fiscal Bill has not been sent to Tax authority.';
        JournalText: Text;
        QRVerifyURL: Text;
    begin
        SetParametersFromRecord(AuditEntryNo, AuditEntryType, Copy, JournalText, QRVerifyURL, RSInvoiceType, RSTransactionType, DiscountAmount, POSEntryNo, SourceDocumentNo);
        HtmlContent := OpeningHtmlTagForFiscal;
        if JournalText = '' then begin
            HtmlContent := FiscalBillNotSentLbl;
            AddEndingTags(HtmlContent);
            exit(true);
        end;
#if not BC17
        IsHandled := false;
        OnBeforeGEnerateQRCodeAZOnAddCurrentReceipt(Base64QRCodeImage, IsHandled);
        if not IsHandled then
            Base64QRCodeImage := BarcodeFontProviderMgt.GenerateQRCodeAZ(QRVerifyURL, 'M', 'UTF8', true, true, 2);
#endif
        case RSInvoiceType in [RSInvoiceType::COPY] of
            true:
                HtmlContent += NewLineHtml + JournalText.Replace(EndingLineHtmlTags, NewLineHtml).Replace(NonFiscalText + NewLineHtml, '');
            false:
                HtmlContent += JournalText.Replace(EndingLineHtmlTags, NewLineHtml).Replace(EndOfFiscalText + NewLineHtml, '');
        end;
        if HtmlContent.Substring(StrLen(HtmlContent) - 100).Contains(NotFiscalBillVersion1Lbl) then
            HtmlContent := HtmlContent.Substring(1, StrLen(HtmlContent) - 45);
#if not BC17
        HtmlContent += PreBase64ImageTag + Base64QRCodeImage + AfterBase64ImageTag + NewLineHtml;
#else
        HtmlContent += NewLineHtml;
#endif
        case RSInvoiceType in [RSInvoiceType::COPY] of
            true:
                begin
                    if ((RSTransactionType in [RSTransactionType::REFUND]) and ((RSAuditMgt.POSCheckIfPaymentMethodCashAndDirectSale(POSEntryNo) and (AuditEntryType in [AuditEntryType::"POS Entry"])) and
                        (RSAuditMgt.DocumentCheckIfPaymentMethodCash(PaymentMethodCode) and not (AuditEntryType in [AuditEntryType::"POS Entry"])))) then
                        HtmlContent += NewLineHtml + PrintLineLbl + NewLineHtml + CustomerSignaturePrintLbl + NewLineHtml;
                    HtmlContent += NonFiscalText;
                end;
            false:
                if (RSInvoiceType in [RSInvoiceType::PROFORMA, RSInvoiceType::TRAINING]) then
                    HtmlContent += NonFiscalText
                else
                    HtmlContent += EndOfFiscalText;
        end;
        AddAdvancePaymentInfo(HtmlContent, RSInvoiceType, RSTransactionType, AuditEntryType, SourceDocumentNo);
        HtmlContent := HtmlContent.Replace(NotFiscalBillVersion1Lbl, NonFiscalText1);
        HtmlContent := HtmlContent.Replace(NotFiscalBillVersion2Lbl, NonFiscalText2);

        if (DiscountAmount <> 0) and not (RSTransactionType in [RSTransactionType::REFUND]) then
            HtmlContent += DoubleNewLineHtml + PrintLineLbl + NewLineHtml + HasDiscountHeadlineLbl + NewLineHtml + TotalDiscountAmountLbl + Format(Round(DiscountAmount)) + NewLineHtml + PrintLineLbl;

        RemoveUnnecessaryFieldsFromJournal(HtmlContent, RSInvoiceType, RSTransactionType);
        DeleteProformaPaymentAmounts(HtmlContent, RSInvoiceType);
        AddReturnPaymentIfExist(HtmlContent, POSEntryNo, RSTransactionType);
    end;

    local procedure AddEndingTags(var HtmlContent: Text)
    var
        EndingHtmlTags: Label '</pre></html>', Locked = true;
    begin
        HtmlContent += EndingHtmlTags;
    end;

    local procedure AddAdvancePaymentInfo(var HtmlContent: Text; RSInvoiceType: Enum "NPR RS Invoice Type"; RSTransactionType: Enum "NPR RS Transaction Type"; AuditEntryType: Enum "NPR RS Audit Entry Type"; SourceDocumentNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RSPOSAuditLogAuxInfoReference: Record "NPR RS POS Audit Log Aux. Info";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PreSmallBegin: Label '<pre style="font-size: 9px;text-align: center;margin-bottom: -35px;">  ', Locked = true;
        PreEnd: Label '</pre>', Locked = true;
        TempHtmlText: Text;
    begin
        if (RSInvoiceType in [RSInvoiceType::ADVANCE]) and
        (RSTransactionType in [RSTransactionType::SALE]) and
        (AuditEntryType in [AuditEntryType::"Sales Invoice Header"]) then begin
            SalesInvoiceHeader.Get(SourceDocumentNo);
            SalesInvoiceHeader2.SetRange("Order No.", SalesInvoiceHeader."Prepayment Order No.");
            if SalesInvoiceHeader2.FindLast() then begin
                SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader2."No.");
                repeat
                    if StrLen(SalesInvoiceLine.Description) > 0 then
                        HtmlContent += NewLineHtml + PreSmallBegin + '*' + SalesInvoiceLine.Description + ' ' + Format(SalesInvoiceLine."Amount Including VAT") + PreEnd + NewLineHtml;
                until SalesInvoiceLine.Next() = 0;
            end;
            SalesHeader.SetRange("No.", SalesInvoiceHeader."Prepayment Order No.");
            if SalesHeader.FindLast() then begin
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                repeat
                    if StrLen(SalesLine.Description) > 0 then
                        HtmlContent += NewLineHtml + PreSmallBegin + '*' + SalesLine.Description + ' ' + Format(SalesLine."Amount Including VAT") + PreEnd + NewLineHtml;
                until SalesLine.Next() = 0;
            end;
        end;
        if (RSInvoiceType in [RSInvoiceType::NORMAL]) and
        (RSTransactionType in [RSTransactionType::SALE]) and
        (AuditEntryType in [AuditEntryType::"Sales Invoice Header"]) then begin
            SalesInvoiceHeader.Get(SourceDocumentNo);
            SalesInvoiceHeader.CalcFields("Amount Including VAT");
            RSPOSAuditLogAuxInfoReference.SetRange("RS Invoice Type", RSPOSAuditLogAuxInfoReference."RS Invoice Type"::ADVANCE);
            RSPOSAuditLogAuxInfoReference.SetRange("RS Transaction Type", RSPOSAuditLogAuxInfoReference."RS Transaction Type"::SALE);
            RSPOSAuditLogAuxInfoReference.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
            if not RSPOSAuditLogAuxInfoReference.FindLast() then
                exit;
            HtmlContent += NewLineHtml + PreSmallBegin + '*' + LastAdvancePaymentBillCaption + ' ' + RSPOSAuditLogAuxInfoReference."Invoice Number" + ' ' + RSPOSAuditLogAuxInfoReference."SDC DateTime".Split('T').Get(1) + PreEnd + NewLineHtml;

            TempHtmlText := HtmlContent.Split(DottedLineLbl + NewLineHtml).Get(1);
            TempHtmlText += DottedLineLbl;
            TempHtmlText += HtmlContent.Split(DottedLineLbl).Get(2).Substring(1, 50);
            SalesCrMemoHeader.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
            SalesCrMemoHeader.FindLast();
            SalesCrMemoHeader.CalcFields("Amount Including VAT", Amount);
            TempHtmlText += Create40LengthText(PaidWithPrepaymentLbl, Format(SalesCrMemoHeader."Amount Including VAT", 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')) + NewLineHtml;
            TempHtmlText += Create40LengthText(VATonPrepaymentLbl, Format(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')) + NewLineHtml;
            TempHtmlText += Create40LengthText(HtmlContent.Split(DottedLineLbl).Get(2).Substring(51, 45).Split(':').Get(1) + ':', Format(SalesInvoiceHeader."Amount Including VAT" - SalesCrMemoHeader."Amount Including VAT", 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')) + NewLineHtml;
            TempHtmlText += Create40LengthText(LeftToPayForPrepaymentLbl, '0,00') + NewLineHtml;
            TempHtmlText += HtmlContent.Split(DottedLineLbl + NewLineHtml + 'Укупан износ:').Get(2).Substring(78);
            HtmlContent := TempHtmlText;
        end;
    end;

    local procedure Create40LengthText(CaptionText: Text; AmountText: Text) ResultText: Text[40]
    var
        i: Integer;
        SpacesToAdd: Integer;
    begin
        SpacesToAdd := 40 - StrLen(CaptionText) - StrLen(AmountText);
        ResultText := CopyStr(CaptionText, 1, MaxStrLen(ResultText));
        for i := 1 to SpacesToAdd do begin
            ResultText += ' ';
        end;
        ResultText += AmountText;
    end;

    local procedure RemoveUnnecessaryFieldsFromJournal(var HtmlContent: Text; RSInvoiceType: Enum "NPR RS Invoice Type"; RSTransactionType: Enum "NPR RS Transaction Type")
    var
        ESIRVremeLbl: Label 'ЕСИР време:', Locked = true;
        OpcionoPoljeKupcaLbl: Label 'Опционо поље купца:', Locked = true;
        TempHtmlText: Text;
    begin
        if not ((RSInvoiceType in [RSInvoiceType::ADVANCE]) and
        (RSTransactionType in [RSTransactionType::SALE])) then
            if HtmlContent.Contains(ESIRVremeLbl) then begin
                TempHtmlText := HtmlContent.Split(ESIRVremeLbl).Get(1);
                TempHtmlText += HtmlContent.Split(ESIRVremeLbl).Get(2).Substring(35);
                HtmlContent := TempHtmlText;
            end;

        if not ((RSInvoiceType in [RSInvoiceType::NORMAL]) and
        (RSTransactionType in [RSTransactionType::SALE])) then
            if HtmlContent.Contains(OpcionoPoljeKupcaLbl) then begin
                TempHtmlText := HtmlContent.Split(OpcionoPoljeKupcaLbl).Get(1);
                TempHtmlText += HtmlContent.Split(OpcionoPoljeKupcaLbl).Get(2).Substring(27);
                HtmlContent := TempHtmlText;
            end;
    end;

    local procedure AddReturnPaymentIfExist(var HtmlContent: Text; POSEntryNo: Integer; RSTransactionType: Enum "NPR RS Transaction Type")
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        SplitHtmlTextList: List of [Text];
        TempHtmlText: Text;
        i: Integer;
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntryPaymentLine.SetFilter(Amount, '<%1', 0);

        SplitHtmlTextList := HtmlContent.Split(EqualSignFiscalLbl);
        for i := 1 to SplitHtmlTextList.Count() do begin
            case i of
                2:
                    begin
                        if RSTransactionType in [RSTransactionType::REFUND] then begin
                            TempHtmlText += SplitHtmlTextList.Get(i).Substring(1, Strlen(SplitHtmlTextList.Get(i)));
                            TempHtmlText += Create40LengthText(ReturnOnSaleLbl, Format(0.00, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')) + NewLineHtml;
                        end else
                            if POSEntryPaymentLine.FindFirst() then begin
                                TempHtmlText += SplitHtmlTextList.Get(i).Substring(1, Strlen(SplitHtmlTextList.Get(i)) - 45);
                                TempHtmlText += Create40LengthText(ReturnOnSaleLbl, Format(-POSEntryPaymentLine.Amount, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')) + NewLineHtml
                            end else begin
                                TempHtmlText += SplitHtmlTextList.Get(i).Substring(1, Strlen(SplitHtmlTextList.Get(i)));
                                TempHtmlText += Create40LengthText(ReturnOnSaleLbl, Format(0.00, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')) + NewLineHtml;
                            end;
                        TempHtmlText += EqualSignFiscalLbl;
                    end;
                SplitHtmlTextList.Count():
                    TempHtmlText += SplitHtmlTextList.Get(i);
                else
                    TempHtmlText += SplitHtmlTextList.Get(i) + EqualSignFiscalLbl;
            end;

        end;
        HtmlContent := TempHtmlText;
    end;

    local procedure DeleteProformaPaymentAmounts(var HtmlContent: Text; RSInvoiceType: Enum "NPR RS Invoice Type")
    var
        SplitHtmlTextList: List of [Text];
        TempHtmlText: Text;
        i: Integer;
    begin
        if not (RSInvoiceType in [RSInvoiceType::PROFORMA]) then
            exit;

        SplitHtmlTextList := HtmlContent.Split(EqualSignFiscalLbl);
        for i := 1 to SplitHtmlTextList.Count() do begin
            case i of
                2:
                    begin
                        TempHtmlText += SplitHtmlTextList.Get(i).Substring(1, Strlen(SplitHtmlTextList.Get(i)) - 45);
                        TempHtmlText += Create40LengthText(SplitHtmlTextList.Get(i).Substring(Strlen(SplitHtmlTextList.Get(i)) - 44).Split(':').Get(1) + ':', Format(0.00, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')) + NewLineHtml;
                        TempHtmlText += EqualSignFiscalLbl;
                    end;
                SplitHtmlTextList.Count():
                    TempHtmlText += SplitHtmlTextList.Get(i);
                else
                    TempHtmlText += SplitHtmlTextList.Get(i) + EqualSignFiscalLbl;
            end;

        end;
        HtmlContent := TempHtmlText;
    end;
    #endregion

#if not BC17
    #region Mock Response for Automated Tests
    [IntegrationEvent(false, false)]
    local procedure OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptCopyIfExists(var Base64QRCodeImage: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGEnerateQRCodeAZOnAddHtmlReceiptOriginal(var Base64QRCodeImage: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGEnerateQRCodeAZOnAddCurrentReceipt(var Base64QRCodeImage: Text; var IsHandled: Boolean)
    begin
    end;
    #endregion
#endif

    var
#if not BC17
        AfterBase64ImageTag: Label '" width="250" height="250">', Locked = true;
        PreBase64ImageTag: Label '<img src="data:image/gif;base64,', Locked = true;
#endif
        CustomerSignaturePrintLbl: Label '              Потпис купца              ', Locked = true;
        DoubleNewLineHtml: Label '<br/><br/>', Locked = true;
        EndingLineHtmlTags: Label '\r\n', Locked = true;
        EndOfFiscalText: Label '======== КРАЈ ФИСКАЛНОГ РАЧУНА =========', Locked = true;
        EqualSignFiscalLbl: Label '========================================', Locked = true;
        LastAdvancePaymentBillCaption: Label 'Последњи авансни рачун', Locked = true;
        PaidWithPrepaymentLbl: Label 'Плаћено авансом:', Locked = true;
        ReturnOnSaleLbl: Label 'Повраћај:', Locked = true;
        VATonPrepaymentLbl: Label 'ПДВ на аванс:', Locked = true;
        LeftToPayForPrepaymentLbl: Label 'Преостало за плаћање:', Locked = true;
        HasDiscountHeadlineLbl: Label 'ОСТВАРИЛИ СТЕ ПОПУСТ', Locked = true;
        NewLineHtml: Label '<br/>', Locked = true;
        NonFiscalText: Label '<pre style="margin: 0;padding: 0;margin-bottom: -30px;">======= ОВО НИЈЕ ФИСКАЛНИ РАЧУН =======</pre>', Locked = true;
        NonFiscalText1: Label '<pre style="margin: 0;padding: 0;margin-bottom: -15px;">======== ОВО НИЈЕ ФИСКАЛНИ РАЧУН ========</pre>', Locked = true;
        NonFiscalText2: Label '<pre style="margin: 0;padding: 0;margin-bottom: -15px;font-size: 19px;">   ОВО НИЈЕ ФИСКАЛНИ РАЧУН   </pre>', Locked = true;
        OpeningHtmlTagForFiscal: Label '<html><pre style="font-family:monospace;text-align: center;">', Locked = true;
        PrintLineLbl: Label '________________________________________', Locked = true;
        DottedLineLbl: Label '----------------------------------------', Locked = true;
        TotalDiscountAmountLbl: Label 'Износ попуста: ', Locked = true;
        NotFiscalBillVersion1Lbl: Label '======== ОВО НИЈЕ ФИСКАЛНИ РАЧУН =======', Locked = true;
        NotFiscalBillVersion2Lbl: Label '        ОВО НИЈЕ ФИСКАЛНИ РАЧУН         ', Locked = true;
}