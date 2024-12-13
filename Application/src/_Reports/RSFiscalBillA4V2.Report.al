report 6014445 "NPR RS Fiscal Bill A4 V2"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    UsageCategory = None;
    DefaultLayout = Word;
    WordLayout = './src/_Reports/layouts/RSFiscallBillA4V2.docx';
    Caption = 'NPR RS Fiscal Bill V2';

    dataset
    {
        dataitem("NPR RS POS Audit Log Aux. Info"; "NPR RS POS Audit Log Aux. Info")
        {
            DataItemTableView = sorting("Audit Entry No.");
            dataitem(FiscalDetails; Integer)
            {
                DataItemTableView = sorting(Number);
                MaxIteration = 1;
                column(CompanyInformationBlock; CompanyInformationBlock)
                {
                }
                column(FiscalBeginingText; FiscalBeginingText)
                {
                }
                column(FiscalBillMainPart; FiscalBillMainPart)
                {
                }
                column(FiscalBillUntilItemsCaptionBlock; FiscalBillUntilItemsCaptionBlock)
                {
                }
                column(FiscalEndingText; FiscalEndingText)
                {
                }
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
                if StrLen("NPR RS POS Audit Log Aux. Info".GetTextFromJournal()) = 0 then
                    Error(RSAuditNotFiscalisedErrLbl, "NPR RS POS Audit Log Aux. Info"."Audit Entry No.");
                ParseJournalTextToFields("NPR RS POS Audit Log Aux. Info".GetTextFromJournal());
#if not BC17
                QRCode := GenerateQRCode("NPR RS POS Audit Log Aux. Info");
#endif
                NewLine := PrintNewLine();
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
        ItemsLblCaption = 'Артикли', Locked = true;
    }

    local procedure ParseJournalTextToFields(JournalText: Text)
    var
        PrintTextList: List of [Text];
        NewLine: Text;
        PrintText: Text;
    begin
        NewLine := PrintNewLine();
        PrintTextList := JournalText.Split('\r\n');
        PrintTextList.Get(1, FiscalBeginingText);
        PrintTextList.Get(PrintTextList.Count() - 1, FiscalEndingText);
        CompanyInformationBlock := GetCompanyInformationFromJournalText(PrintTextList);

        foreach PrintText in PrintTextList do
            case true of
                PrintText.Contains('Артикли'):
                    begin
                        FiscalBillUntilItemsCaptionBlock := GetBlockUntilItemsCaption(PrintTextList, PrintTextList.IndexOf(PrintText));
                        FiscalBillMainPart := GetBlockAfterItemsCaptionUnitlQRCode(PrintTextList, PrintTextList.IndexOf(PrintText));
                    end;
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
        ReturnText += PrintText.Get(6);
        exit(ReturnText);
    end;

    local procedure GetBlockUntilItemsCaption(PrintTextList: List of [Text]; EndingIndex: Integer): Text
    var
        i: Integer;
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        for i := 7 to EndingIndex - 1 do
            if PrintTextList.IndexOf(PrintTextList.Get(i)) = EndingIndex - 1 then
                ReturnText += PrintTextList.Get(i)
            else
                ReturnText += PrintTextList.Get(i) + NewLine;
        exit(ReturnText);
    end;

    local procedure GetBlockAfterItemsCaptionUnitlQRCode(PrintText: List of [Text]; StartingIndex: Integer): Text
    var
        Regex: Codeunit "NPR RegEx";
        i: Integer;
        NewLine: Text;
        ReturnText: Text;
    begin
        NewLine := PrintNewLine();
        for i := StartingIndex + 1 to PrintText.Count - 2 do
            if Regex.IsMatch(PrintText.Get(i), RegexPatternForItemsBlock) then
                ReturnText += '.' + PrintText.Get(i).Remove(1, 1) + NewLine
            else
                ReturnText += PrintText.Get(i) + NewLine;
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

    local procedure PrintNewLine(): Text
    var
        NewLineToReturn: Text;
    begin
        NewLineToReturn[1] := 13;
        NewLineToReturn[2] := 10;
        exit(NewLineToReturn);
    end;

    internal procedure SetFilters(_RSAuditEntryType: Enum "NPR RS Audit Entry Type"; _POSEntryNo: Integer; _DocumentNo: Code[20]; _DocumentType: Enum "Sales Document Type")
    begin
        RSAuditEntryType := _RSAuditEntryType;
        POSEntryNo := _POSEntryNo;
        DocumentNo := _DocumentNo;
        DocumentType := _DocumentType;
    end;

    var
        DocumentNo: Code[20];
        RSAuditEntryType: Enum "NPR RS Audit Entry Type";
        DocumentType: Enum "Sales Document Type";
        POSEntryNo: Integer;
        DiscountAmountLblCaption: Label 'Износ попуста: ', Locked = true;
        DiscountLblCaption: Label 'ОСТВАРИЛИ СТЕ ПОПУСТ', Locked = true;
        DiscountLineLbl: Label '------------------------------------------', Locked = true;
        RegexPatternForItemsBlock: Label '^\s*[0-9\s.,]+$', Locked = true;
        CompanyInformationBlock: Text;
        DiscountAmount: Text;
        FiscalBeginingText: Text;
        FiscalBillMainPart: Text;
        FiscalBillUntilItemsCaptionBlock: Text;
        FiscalEndingText: Text;
        QRCode: Text;
}