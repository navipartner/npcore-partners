report 6014453 "NPR RS Fiscal Bill A4 v1"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    Caption = 'RS Fiscal Bill A4';
    DefaultLayout = Word;
    WordLayout = './src/_Reports/layouts/RSFiscallBillA4v1.docx';
    UsageCategory = None;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            MaxIteration = 1;
            column(Picture; Picture)
            {
            }
            column(Name; Name)
            {
            }
            column(Address; Address)
            {
            }
            column(Address_2; "Address 2")
            {
            }
            column(Phone_No_; "Phone No.")
            {
            }
            column(E_Mail; "E-Mail")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if ("Company Information"."E-Mail" <> '') then
                    "E-Mail" := CopyStr(CompanyEmailCaptionLbl + "E-Mail", 1, MaxStrLen("E-Mail"));
                if ("Company Information"."Phone No." <> '') then
                    "Phone No." := CopyStr(CompanyPhoneCaptionLbl + "Phone No.", 1, MaxStrLen("Phone No."));
            end;
        }
        dataitem("NPR RS POS Audit Log Aux. Info"; "NPR RS POS Audit Log Aux. Info")
        {
            DataItemTableView = sorting("Audit Entry No.");
            dataitem(FiscalDetails; Integer)
            {
                DataItemTableView = sorting(Number);
                MaxIteration = 1;
                column(FiscalBegginingText; FiscalBegginingText)
                {
                }
                column(CompanyInformationBlock; CompanyInformationBlock)
                {
                }
                column(ESIRBlock; ESIRBlock)
                {
                }
                column(ItemsBlock; ItemsBlock)
                {
                }
                column(ItemDescriptionText; ItemDescriptionText)
                {
                }
                column(ItemPriceText; ItemPriceText)
                {
                }
                column(ItemQtyText; ItemQtyText)
                {
                }
                column(ItemLinePriceText; ItemLinePriceText)
                {
                }
                column(TotalsBlock; TotalsBlock)
                {
                }
                column(VATBlock; VATBlock)
                {
                }
                column(VATTotalsBlockCaption; VATTotalsBlockCaption)
                {
                }
                column(VATTotalsBlockNumber; VATTotalsBlockNumber)
                {
                }
                column(PFRBlock; PFRBlock)
                {
                }
                column(FiscalEndingText; FiscalEndingText)
                {
                }
#if BC17
                column(Barcode; TempBlobBuffer."Buffer 1")
                {
                }
#else
                column(Barcode; Barcode)
                {
                }
#endif
                column(QRCode; QRCode)
                {
                }
                column(DiscountAmount; DiscountAmount)
                {
                }
            }
            trigger OnPreDataItem()
            begin
                "NPR RS POS Audit Log Aux. Info".SetRange("Audit Entry Type", RSAuditEntryType);
                "NPR RS POS Audit Log Aux. Info".SetRange("POS Entry No.", POSEntryNo);
                "NPR RS POS Audit Log Aux. Info".SetRange("Source Document No.", DocumentNo);
                "NPR RS POS Audit Log Aux. Info".SetRange("Source Document Type", DocumentType);
            end;

            trigger OnAfterGetRecord()
            var
                RSAuditNotFiscalisedErrLbl: Label 'RS Audit Log %1 has not been fiscalised.', Comment = '%1 = Audit Entry No';
                NewLine: Text;
            begin
                NewLine := PrintNewLine();
                if StrLen("NPR RS POS Audit Log Aux. Info".GetTextFromJournal()) = 0 then
                    Error(RSAuditNotFiscalisedErrLbl, "NPR RS POS Audit Log Aux. Info"."Audit Entry No.");
                ParseJournalTextToFields("NPR RS POS Audit Log Aux. Info".GetTextFromJournal());
#if not BC17
                QRCode := GenerateQRCode("NPR RS POS Audit Log Aux. Info");
#endif
                if "NPR RS POS Audit Log Aux. Info"."Audit Entry Type" in ["NPR RS POS Audit Log Aux. Info"."Audit Entry Type"::"POS Entry"] then
                    Barcode := GenerateBarcode(Format("NPR RS POS Audit Log Aux. Info"."POS Entry No."))
                else
                    Barcode := GenerateBarcode("NPR RS POS Audit Log Aux. Info"."Source Document No.");
                if ("Discount Amount" <> 0) then
                    DiscountAmount := DiscountLineLbl + NewLine + DiscountLblCaption + NewLine + DiscountAmountLblCaption +
                    Format("Discount Amount", 0, '<Precision,2><sign><Integer Thousand><Decimals,3><Comma,,>') + NewLine + DiscountLineLbl;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Filters';
                    field(AuditEntryType; RSAuditEntryType)
                    {
                        ApplicationArea = NPRRSFiscal;
                        Caption = 'Audit Entry Type';
                        ToolTip = 'Specifies the value of the Audit Entry Type field.';
                    }
                    field("Document Type"; DocumentType)
                    {
                        ApplicationArea = NPRRSFiscal;
                        Caption = 'Document Type';
                        Editable = RSAuditEntryType = RSAuditEntryType::"Sales Header";
                        ToolTip = 'Specifies the value of the Document Type field.';
                    }
                    field("POS Entry No"; POSEntryNo)
                    {
                        ApplicationArea = NPRRSFiscal;
                        Caption = 'POS Entry No.';
                        Editable = RSAuditEntryType = RSAuditEntryType::"POS Entry";
                        TableRelation = "NPR POS Entry"."Entry No.";
                        ToolTip = 'Specifies the value of the POS Entry No. field.';
                    }
                    field("Document No"; DocumentNo)
                    {
                        ApplicationArea = NPRRSFiscal;
                        Caption = 'Document No.';
                        Editable = RSAuditEntryType <> RSAuditEntryType::"POS Entry";
                        ToolTip = 'Specifies the value of the Document No. field.';
                    }
                }
            }
        }
    }

    labels
    {
        DescriptionCaptionLbl = 'Назив', Locked = true;
        UnitPriceCaptionLbl = 'Цена', Locked = true;
        QtyCaptionLbl = 'Кол.', Locked = true;
        TotalAmountCaptionLbl = 'Укупно', Locked = true;
        TinCaptionLbl = 'ПИБ:', Locked = true;
        BusinessCaptionLbl = 'Назив предузећа:', Locked = true;
        LocationNameCaptionLbl = 'Назив радње:', Locked = true;
        AddressNameCaptionLbl = 'Адреса:', Locked = true;
        DistrictCaptionLbl = 'Општина:', Locked = true;
        InvoicedByCaptionLbl = 'Invoiced By';
        PickedUpByCaptionLbl = 'Picked Up By';
    }

    local procedure ParseJournalTextToFields(JournalText: Text)
    var
        PrintTextList: List of [Text];
        VATTotalsText: List of [Text];
        NewLine: Text;
        PrintText: Text;
    begin
        NewLine := PrintNewLine();
        PrintTextList := JournalText.Split('\r\n');
        PrintTextList.Get(1, FiscalBegginingText);
        FiscalBegginingText := AppendingDoubleLineLbl + FiscalBegginingText + AppendingDoubleLineLbl;
        PrintTextList.Get(PrintTextList.Count() - 1, FiscalEndingText);
        FiscalEndingText := AppendingDoubleLineLbl + FiscalEndingText + AppendingDoubleLineLbl;
        CompanyInformationBlock := GetCompanyInformationFromJournalText(PrintTextList);

        foreach PrintText in PrintTextList do
            case true of
                PrintText.Contains('Артикли'):
                    begin
                        ESIRBlock := GetESIRBlockFromJournalText(PrintTextList, PrintTextList.IndexOf(PrintText));
                        ItemsBlock := GetItemCaptionBlockFromJournalText(PrintText, PrintTextList);
                    end;
                PrintText.Contains('Укупан износ пореза'):
                    begin
                        VATTotalsText := PrintText.Split(':');
                        VATTotalsText.Get(1, VATTotalsBlockCaption);
                        VATTotalsText.Get(2, VATTotalsBlockNumber);
                    end;
                PrintText.Contains('Назив'):
                    begin
                        ItemDescriptionText := GetItemsDescriptionBlockFromJournalText(PrintTextList, PrintTextList.IndexOf(PrintText));
                        ItemPriceText := GetItemsPriceFromJournalText(PrintTextList, PrintTextList.IndexOf(PrintText), 1);
                        ItemQtyText := GetItemQtyTextFromJournalText(PrintTextList, PrintTextList.IndexOf(PrintText));
                        ItemLinePriceText := GetItemsPriceFromJournalText(PrintTextList, PrintTextList.IndexOf(PrintText), 2);
                    end;
                PrintText.Contains('Ознака'):
                    begin
                        TotalsBlock := GetTotalsBlockFromJournalLineText(PrintTextList, PrintTextList.IndexOf(PrintText));
                        VATBlock := GetVATBlockFromJournalLine(PrintTextList, PrintTextList.IndexOf(PrintText));
                    end;
                PrintText.Contains('ПФР време'):
                    PFRBlock := GetPFRBlockFromJournalLine(PrintTextList, PrintTextList.IndexOf(PrintText));
            end;
    end;

    local procedure GetCompanyInformationFromJournalText(PrintText: List of [Text]): Text
    var
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        ReturnText += PrintText.Get(2) + NewLine;
        ReturnText += PrintText.Get(3) + NewLine;
        ReturnText += PrintText.Get(4) + NewLine;
        ReturnText += PrintText.Get(5) + NewLine;
        ReturnText += PrintText.Get(6) + NewLine;
        exit(ReturnText);
    end;

    local procedure GetESIRBlockFromJournalText(PrintTextList: List of [Text]; EndIndex: Integer): Text
    var
        i: Integer;
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        for i := PrintTextList.IndexOf(PrintTextList.Get(6)) + 1 to EndIndex - 2 do
            ReturnText += PrintTextList.Get(i) + NewLine;
        exit(ReturnText);
    end;

    local procedure GetItemCaptionBlockFromJournalText(StartingText: Text; PrintTextList: List of [Text]): Text
    var
        EndingText: Text;
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        EndingText := AppendingSingleLine + PrintTextList.Get(PrintTextList.IndexOf(StartingText) - 1) + AppendingSingleLine;
        ReturnText := EndingText + NewLine + StartingText;
        exit(ReturnText);
    end;

    local procedure GetItemsDescriptionBlockFromJournalText(PrintTextList: List of [Text]; StartIndex: Integer): Text
    var
        Regex: Codeunit "NPR RegEx";
        i: Integer;
        NewLine: Text;
        NextTempText: Text;
        ReturnText: Text;
        TempText: Text;
    begin
        NewLine := PrintNewLine();
        for i := StartIndex + 1 to PrintTextList.Count - 1 do begin
            if Regex.IsMatch(TempText, RegexLineWithLettersPatternLbl) or (TempText = '') then
                TempText += PrintTextList.Get(i);
            NextTempText := PrintTextList.Get(i + 1);
            if NextTempText.Contains(DottedLineLbl) then
                break;
            if Regex.IsMatch(NextTempText, RegexLineWithLettersPatternLbl) and Regex.IsMatch(TempText, RegexLineWithOnlyNumberPatternLbl) then
                TempText := '';
            if Regex.IsMatch(NextTempText, RegexLineWithOnlyNumberPatternLbl) then begin
                ReturnText += TempText + NewLine;
                TempText := '';
                NextTempText := '';
            end;
        end;
        exit(ReturnText);
    end;

    local procedure GetItemsPriceFromJournalText(PrintTextList: List of [Text]; StartIndex: Integer; ElementPosition: Integer): Text
    var
        Regex: Codeunit "NPR RegEx";
        i: Integer;
        ReturnText: List of [Text];
        TempTextList: List of [Text];
        ItemsLinePriceText: Text;
        ItemsPriceText: Text;
        NewLine: Text;
        NextTempText: Text;
        TempText: Text;
        ResultText: text;
    begin
        NewLine := PrintNewLine();
        for i := StartIndex + 1 to PrintTextList.Count - 1 do begin
            TempText := PrintTextList.Get(i);
            NextTempText := PrintTextList.Get(i + 1);
            if Regex.IsMatch(TempText, RegexLineWithOnlyNumberPatternLbl) then begin
                TempText := TempText.Trim();
                TempTextList := TempText.Split(' ');
                ItemsPriceText += TempTextList.Get(1) + NewLine;
                ItemsLinePriceText += TempTextList.Get(TempTextList.Count) + NewLine;
            end;
            if NextTempText.Contains(DottedLineLbl) then
                break;
        end;
        ReturnText.Add(ItemsPriceText);
        ReturnText.Add(ItemsLinePriceText);

        if ReturnText.Count() = 0 then
            exit;

        if ReturnText.Get(ElementPosition, ResultText) then
            exit(ResultText);
    end;

    local procedure GetItemQtyTextFromJournalText(PrintTextList: List of [Text]; StartIndex: Integer): Text
    var
        Regex: Codeunit "NPR RegEx";
        i: Integer;
        NewLine: Text;
        NextTempText: Text;
        ReturnText: Text;
        TempText: Text;
        SingleMatchText: Text;
    begin
        NewLine := PrintNewLine();
        for i := StartIndex + 1 to PrintTextList.Count - 1 do begin
            TempText := PrintTextList.Get(i);
            NextTempText := PrintTextList.Get(i + 1);
            if Regex.IsMatch(TempText, RegexLineWithOnlyNumberPatternLbl) then begin
                TempText := TempText.Trim();
                Regex.GetSingleMatchValue(TempText, RegexItemQtyPatternLbl, SingleMatchText);
                ReturnText += SingleMatchText + NewLine;
            end;
            if NextTempText.Contains(DottedLineLbl) then
                break;
        end;
        exit(ReturnText);
    end;

    local procedure GetTotalsBlockFromJournalLineText(PrintTextList: List of [Text]; EndingIndex: Integer): Text
    var
        i: Integer;
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        for i := PrintTextList.IndexOf(DottedLineLbl) + 1 to EndingIndex - 2 do begin
            if PrintTextList.Get(i).Contains(AppendingDoubleLineLbl) then
                break;
            ReturnText += PrintTextList.Get(i) + NewLine;
        end;
        exit(ReturnText);
    end;

    local procedure GetVATBlockFromJournalLine(PrintTextList: List of [Text]; StartIndex: Integer): Text
    var
        ReturnTextList: List of [Text];
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        while (true) do begin
            if PrintTextList.Get(StartIndex).Contains('Укупан износ пореза') then
                break;
            ReturnTextList.Add(PrintTextList.Get(StartIndex) + NewLine);
            StartIndex += 1;
        end;
        for StartIndex := 1 to ReturnTextList.Count - 1 do
            ReturnText += ReturnTextList.Get(StartIndex);
        exit(ReturnText);
    end;

    local procedure GetPFRBlockFromJournalLine(PrintTextList: List of [Text]; StartingIndex: Integer): Text
    var
        i: Integer;
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        for i := StartingIndex to PrintTextList.LastIndexOf(ItemsLineLbl) - 1 do
            ReturnText += PrintTextList.Get(i) + NewLine;
        exit(ReturnText);
    end;

#if not BC17  
    local procedure GenerateQRCode(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"): Text
    var
        BarcodeFontProviderMgt: Codeunit "NPR Barcode Font Provider Mgt.";
    begin
        if RSPOSAuditLogAuxInfo."Verification QR Code".HasValue() then
            exit(BarcodeFontProviderMgt.GenerateQRCodeAZ(RSPOSAuditLogAuxInfo."Verification URL", 'M', 'UTF8', true, true, 2))
        else
            exit(RSPOSAuditLogAuxInfo.GetQRFromJournal());
    end;
#endif

    local procedure GenerateBarcode(BarcodeNo: Text): Text
    var
#if BC17
        BarcodeImageLibrary: Codeunit "NPR Barcode Image Library";
#else
        BarcodeSymbology: Enum "Barcode Symbology";
        BarcodeFontProvider: Interface "Barcode Font Provider";
        ReturnBarcode: Text;
#endif
    begin
#if BC17
        BarcodeImageLibrary.GenerateBarcode(BarcodeNo, TempBlob);
        TempBlobBuffer.GetFromTempBlob(TempBlob, 1);
        exit;
#else
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
        BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
        BarcodeFontProvider.ValidateInput(BarcodeNo, BarcodeSymbology);
        ReturnBarcode := BarcodeFontProvider.EncodeFont(BarcodeNo, BarcodeSymbology);
        exit(ReturnBarcode);
#endif
    end;

    local procedure PrintNewLine(): Text
    var
        NewLineToReturn: Text;
    begin
        NewLineToReturn[1] := 13;
        NewLineToReturn[2] := 10;
        exit(NewLineToReturn);
    end;

    internal procedure SetFilters(_RSAuditEntryType: Enum "NPR RS Audit Entry Type"; _POSEntryNo: Integer;
                                                _DocumentNo: Code[20];
                                                _DocumentType: Enum "Sales Document Type")
    begin
        RSAuditEntryType := _RSAuditEntryType;
        POSEntryNo := _POSEntryNo;
        DocumentNo := _DocumentNo;
        DocumentType := _DocumentType;
    end;

    var
#if BC17
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
#endif
        DocumentNo: Code[20];
        RSAuditEntryType: Enum "NPR RS Audit Entry Type";
        DocumentType: Enum "Sales Document Type";
        POSEntryNo: Integer;
        AppendingDoubleLineLbl: Label '===========', Locked = true;
        AppendingSingleLine: Label '-------------------------', Locked = true;
        CompanyEmailCaptionLbl: Label 'E-Mail:', Locked = true;
        CompanyPhoneCaptionLbl: Label 'Phone:', Locked = true;
        DiscountAmountLblCaption: Label 'Износ попуста: ', Locked = true;
        DiscountLblCaption: Label 'ОСТВАРИЛИ СТЕ ПОПУСТ', Locked = true;
        DiscountLineLbl: Label '------------------------------------------', Locked = true;
        DottedLineLbl: Label '----------------------------------------', Locked = true;
        ItemsLineLbl: Label '========================================', Locked = true;
        RegexItemQtyPatternLbl: Label '(?<![\d.,])\d+(?![\d.,])', Locked = true;
        RegexLineWithLettersPatternLbl: Label '[A-Za-z]', Locked = true;
        RegexLineWithOnlyNumberPatternLbl: Label '^[^a-zA-Z]*$', Locked = true;
        Barcode: Text;
        CompanyInformationBlock: Text;
        DiscountAmount: Text;
        ESIRBlock: Text;
        FiscalBegginingText: Text;
        FiscalEndingText: Text;
        ItemDescriptionText: Text;
        ItemLinePriceText: Text;
        ItemPriceText: Text;
        ItemQtyText: Text;
        ItemsBlock: Text;
        PFRBlock: Text;
        QRCode: Text;
        TotalsBlock: Text;
        VATBlock: Text;
        VATTotalsBlockCaption: Text;
        VATTotalsBlockNumber: Text;
}