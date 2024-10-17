codeunit 6150981 "NPR RS Fiscal Thermal Print"
{
    Access = Internal;

    var
        RSFiscalisationSetup: Record "NPR RS Fiscalisation Setup";
        RSFiscalisationSetupInitilized: Boolean;

    #region PRINT FISCAL RECEIPT
    internal procedure PrintReceipt(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    begin
        PrintThermalReceipt(RSPOSAuditLogAuxInfo)
    end;

    internal procedure PrintReceipt(RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy")
    begin
        PrintThermalReceipt(RSPOSAuditLogAuxCopy)
    end;
    #endregion

    #region Journal Text To Thermal Printer Parsers
    local procedure PrintThermalReceipt(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        RetailLogo: Record "NPR Retail Logo";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        i, j : Integer;
        PrintRawInputText: Text;
        PrintText: Text;
        PrintTextList: List of [Text];
    begin
        PrintRawInputText := RSPOSAuditLogAuxInfo.GetTextFromJournal();
        if StrLen(PrintRawInputText) = 0 then
            exit;

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);
        PrintTextList := PrintRawInputText.Split('\r\n');

        RetailLogo.SetRange("Register No.", RSPOSAuditLogAuxInfo."POS Unit No.");
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');

        if RetailLogo.FindFirst() then
            PrintThermalLine(Printer, RetailLogo.Keyword, 'LOGO', false, 'LEFT', true, false);

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        for i := 1 to PrintTextList.Count() do begin
            PrintTextList.Get(i, PrintText);
            if i = (PrintTextList.Count() - 1) then
                PrintThermalLine(Printer, RSPOSAuditLogAuxInfo."Verification URL", 'QR', false, 'CENTER', true, false);
            if PrintText.Contains('========================================') then
                j += 1;
            if j = 2 then begin
                if (RSPOSAuditLogAuxInfo."Audit Entry Type" in [RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header"]) and (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) and (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE]) then
                    AddAdvancePaymentSection(Printer, RSPOSAuditLogAuxInfo);
                AddRefundSection(Printer, RSPOSAuditLogAuxInfo);
                j += 1;
            end;
            if not ShouldSkipPrintLine(PrintText, RSPOSAuditLogAuxInfo) then
                PrintThermalLine(Printer, PrintText, 'A11', true, 'CENTER', true, false);
        end;

        if RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE] then
            PrintInvoiceNumberBarcode(Printer, RSPOSAuditLogAuxInfo);

        GetRSFiscalisationSetup();
        if RSFiscalisationSetup."Receipt Cut Per Section" then
            PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);

        PrintDiscountNonFiscal(RSPOSAuditLogAuxInfo);
        PrintMembershipPointsNonFiscal(RSPOSAuditLogAuxInfo);
        PrintNonFiscalCopyForNormalRefund(RSPOSAuditLogAuxInfo);

        if not RSFiscalisationSetup."Receipt Cut Per Section" then begin
            Clear(Printer);
            PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);
            Printer.ProcessBuffer(Codeunit::"NPR RS Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
        end;
    end;

    local procedure PrintThermalReceipt(RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        RetailLogo: Record "NPR Retail Logo";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        i, j : Integer;
        PrintRawInputText: Text;
        PrintText: Text;
        PrintTextList: List of [Text];
        CustomerSignaturePrintLbl: Label '              Потпис купца              ', Locked = true;
    begin
        PrintRawInputText := RSPOSAuditLogAuxCopy.GetTextFromJournal();
        if StrLen(PrintRawInputText) = 0 then
            exit;

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);
        PrintTextList := PrintRawInputText.Split('\r\n');

        RetailLogo.SetRange("Register No.", RSPOSAuditLogAuxInfo."POS Unit No.");
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');

        if RetailLogo.FindFirst() then
            PrintThermalLine(Printer, RetailLogo.Keyword, 'LOGO', false, 'LEFT', true, false);

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        for i := 1 to PrintTextList.Count() do begin
            PrintTextList.Get(i, PrintText);
            if i = (PrintTextList.Count() - 1) then begin
                PrintThermalLine(Printer, RSPOSAuditLogAuxCopy."Verification URL", 'QR', false, 'CENTER', true, false);
                if (RSPOSAuditLogAuxCopy."RS Invoice Type" in [RSPOSAuditLogAuxCopy."RS Invoice Type"::COPY]) and
                (RSPOSAuditLogAuxCopy."RS Transaction Type" in [RSPOSAuditLogAuxCopy."RS Transaction Type"::REFUND]) then
                    if (RSAuditMgt.POSCheckIfPaymentMethodCashAndDirectSale(RSPOSAuditLogAuxCopy."POS Entry No.") or not (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"])) or
                        (RSAuditMgt.DocumentCheckIfPaymentMethodCash(RSPOSAuditLogAuxCopy."Payment Method Code") and not (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"])) then begin
                        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
                        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
                        PrintThermalLine(Printer, CustomerSignaturePrintLbl, 'A11', true, 'CENTER', true, false);
                    end;
            end;
            if PrintText.Contains('========================================') then
                j += 1;
            if j = 2 then begin
                RSPOSAuditLogAuxInfo.SetCurrentKey("Audit Entry Type", "Audit Entry No.");
                if RSPOSAuditLogAuxInfo.Get(RSPOSAuditLogAuxCopy."Audit Entry Type", RSPOSAuditLogAuxCopy."Audit Entry No.") then
                    if (RSPOSAuditLogAuxInfo."Audit Entry Type" in [RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header"]) and (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) and (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE]) then
                        AddAdvancePaymentSection(Printer, RSPOSAuditLogAuxInfo);
                AddRefundSection(Printer, RSPOSAuditLogAuxInfo);
            end;
            if not ShouldSkipPrintLine(PrintText, RSPOSAuditLogAuxCopy) then
                PrintThermalLine(Printer, PrintText, 'A11', true, 'CENTER', true, false);
        end;

        if RSPOSAuditLogAuxCopy."RS Transaction Type" in [RSPOSAuditLogAuxCopy."RS Transaction Type"::SALE] then
            PrintInvoiceNumberBarcode(Printer, RSPOSAuditLogAuxCopy);

        GetRSFiscalisationSetup();
        if RSFiscalisationSetup."Receipt Cut Per Section" then
            PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    #endregion

    #region Additional Non-Fiscal (Slip) Printing
    local procedure PrintDiscountNonFiscal(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        HasDiscountHeadlineLbl: Label 'ОСТВАРИЛИ СТЕ ПОПУСТ', Locked = true;
        TotalDiscountAmountLbl: Label 'Износ попуста: ', Locked = true;
    begin
        if not (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE])
            and not (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) then
            exit;
        if RSPOSAuditLogAuxInfo."Discount Amount" = 0 then
            exit;
        Printer.SetAutoLineBreak(false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, HasDiscountHeadlineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, TotalDiscountAmountLbl + Format(Round(RSPOSAuditLogAuxInfo."Discount Amount", 0.01)), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        GetRSFiscalisationSetup();
        if RSFiscalisationSetup."Receipt Cut Per Section" then
            PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintMembershipPointsNonFiscal(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        MMMembersPointsEntry: Record "NPR MM Members. Points Entry";
        POSEntry: Record "NPR POS Entry";
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        MembershipHeadlineLbl: Label 'LOYALTY', Locked = true;
        TotalMembershipPointsLbl: Label 'Укупно поена: ', Locked = true;
    begin
        if not (RSPOSAuditLogAuxInfo."Audit Entry Type" in [RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry"]) then
            exit;
        if not (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE])
            and not (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) then
            exit;

        POSEntry.Get(RSPOSAuditLogAuxInfo."POS Entry No.");
        MMMembersPointsEntry.SetCurrentKey("Entry No.");
        MMMembersPointsEntry.SetRange("Customer No.", POSEntry."Customer No.");
        MMMembersPointsEntry.SetRange("Posting Date", POSEntry."Posting Date");
        if not MMMembersPointsEntry.FindLast() then
            exit;
        if Round(MMMembersPointsEntry.Points, 0.01) = 0 then
            exit;

        Printer.SetAutoLineBreak(false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, MembershipHeadlineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, TotalMembershipPointsLbl + Format(Round(MMMembersPointsEntry.Points, 0.01)), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        GetRSFiscalisationSetup();
        if RSFiscalisationSetup."Receipt Cut Per Section" then
            PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintNonFiscalCopyForNormalRefund(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy";
    begin
        RSPOSAuditLogAuxInfo.CalcFields("Fiscal Bill Copies");
        if RSPOSAuditLogAuxInfo."Fiscal Bill Copies" and (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND])
            and (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) then begin
            RSPOSAuditLogAuxCopy.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type");
            RSPOSAuditLogAuxCopy.SetRange("Audit Entry No.", RSPOSAuditLogAuxInfo."Audit Entry No.");
            RSPOSAuditLogAuxCopy.FindLast();
            PrintThermalReceipt(RSPOSAuditLogAuxCopy);
        end;
    end;
    #endregion

    #region Additional Section Printing
    local procedure AddRefundSection(Printer: Codeunit "NPR RP Line Print Mgt."; RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        RefundAmountLbl: Label 'Повраћај: ', Locked = true;
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", RSPOSAuditLogAuxInfo."POS Entry No.");
        POSEntryPaymentLine.SetFilter(Amount, '<%1', 0);
        if POSEntryPaymentLine.FindFirst() and not (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) and not (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND]) then
            PrintThermalLine(Printer, Create40LengthText(RefundAmountLbl, Format(-POSEntryPaymentLine.Amount, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')), 'A11', true, 'CENTER', true, false)
        else
            PrintThermalLine(Printer, Create40LengthText(RefundAmountLbl, '0,00'), 'A11', true, 'CENTER', true, false)
    end;

    local procedure AddAdvancePaymentSection(Printer: Codeunit "NPR RP Line Print Mgt."; RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        RSPOSAuditLogAuxInfoReference: Record "NPR RS POS Audit Log Aux. Info";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LeftToPayForPrepaymentLbl: Label 'Преостало за плаћање:', Locked = true;
        PaidWithPrepaymentLbl: Label 'Плаћено авансом:', Locked = true;
        VATonPrepaymentLbl: Label 'ПДВ на аванс:', Locked = true;
    begin
        SalesInvoiceHeader.Get(RSPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        RSPOSAuditLogAuxInfoReference.SetRange("RS Invoice Type", RSPOSAuditLogAuxInfoReference."RS Invoice Type"::ADVANCE);
        RSPOSAuditLogAuxInfoReference.SetRange("RS Transaction Type", RSPOSAuditLogAuxInfoReference."RS Transaction Type"::SALE);
        RSPOSAuditLogAuxInfoReference.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
        if not RSPOSAuditLogAuxInfoReference.FindLast() then
            exit;
        SalesCrMemoHeader.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
        SalesCrMemoHeader.FindLast();
        SalesCrMemoHeader.CalcFields("Amount Including VAT", Amount);
        PrintThermalLine(Printer, Create40LengthText(PaidWithPrepaymentLbl, Format(SalesCrMemoHeader."Amount Including VAT", 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, Create40LengthText(VATonPrepaymentLbl, Format(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount, 12, '<Precision,2:2><Integer Thousand><Decimals><Comma,,>')), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, Create40LengthText(LeftToPayForPrepaymentLbl, '0,00'), 'A11', true, 'CENTER', true, false);
    end;

    #endregion

    #region Barcode printing

    local procedure PrintInvoiceNumberBarcode(var Printer: Codeunit "NPR RP Line Print Mgt."; RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    begin
        PrintThermalLine(Printer, StrSubstNo(ShortInvoiceNumberFormatLbl, RSPOSAuditLogAuxInfo."Signed By", RSPOSAuditLogAuxInfo."Total Counter"), 'CODE128', false, 'CENTER', true, false);
    end;

    local procedure PrintInvoiceNumberBarcode(var Printer: Codeunit "NPR RP Line Print Mgt."; RSPOSAuditLogAuxInfoCopy: Record "NPR RS POS Audit Log Aux. Copy")
    begin
        PrintThermalLine(Printer, StrSubstNo(ShortInvoiceNumberFormatLbl, RSPOSAuditLogAuxInfoCopy."Signed By", RSPOSAuditLogAuxInfoCopy."Total Counter"), 'CODE128', false, 'CENTER', true, false);
    end;

    #endregion

    #region Helper Procedures
    local procedure ShouldSkipPrintLine(PrintText: Text; RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info"): Boolean
    var
        PrintCustIdentification: Boolean;
    begin
        case true of
            PrintText.Contains('ИД купца'):
                begin
                    PrintCustIdentification := (RSPOSAuditLogAuxInfo."Customer Identification" = '0') or (RSPOSAuditLogAuxInfo."Customer Identification" = '10:');
                    exit(PrintCustIdentification);
                end;
            PrintText.Contains('ЕСИР време'):
                if RSPOSAuditLogAuxInfo."Prepayment Order No." <> '' then
                    exit(false)
                else
                    exit(true);
            else
                exit(false);
        end;
    end;

    local procedure ShouldSkipPrintLine(PrintText: Text; RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy"): Boolean
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
    begin
        case true of
            PrintText.Contains('ИД купца'):
                exit(RSPOSAuditLogAuxCopy."Customer Identification" = '0');
            PrintText.Contains('ЕСИР време'):
                begin
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxCopy."Audit Entry Type");
                    RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", RSPOSAuditLogAuxCopy."Audit Entry No.");
                    RSPOSAuditLogAuxInfo.FindFirst();
                    if RSPOSAuditLogAuxInfo."Prepayment Order No." <> '' then
                        exit(false)
                    else
                        exit(true);
                end;
            else
                exit(false);
        end;
    end;

    local procedure Create40LengthText(CaptionText: Text; AmountText: Text) ResultText: Text[40]
    var
        i: Integer;
        SpacesToAdd: Integer;
    begin
        SpacesToAdd := 40 - StrLen(CaptionText) - StrLen(AmountText);
        ResultText := CopyStr(CaptionText, 1, MaxStrLen(ResultText));
        for i := 1 to SpacesToAdd do
            ResultText += ' ';
        ResultText += AmountText;
    end;

    local procedure GetRSFiscalisationSetup()
    begin
        if RSFiscalisationSetupInitilized then
            exit;

        RSFiscalisationSetup.Get();
        RSFiscalisationSetupInitilized := true;
    end;
    #endregion

    #region Thermal Printer Processing
    local procedure PrintThermalLine(var Printer: Codeunit "NPR RP Line Print Mgt."; Value: Text; Font: Text; Bold: Boolean; Alignment: Text; CR: Boolean; Underline: Boolean)
    begin
        case true of
            (Font in ['A11', 'B21', 'Control']):
                begin
                    Printer.SetFont(CopyStr(Font, 1, 30));
                    Printer.SetBold(Bold);
                    Printer.SetUnderLine(Underline);

                    case Alignment of
                        'LEFT':
                            Printer.AddTextField(1, 0, Value);
                        'CENTER':
                            Printer.AddTextField(2, 1, Value);
                        'RIGHT':
                            Printer.AddTextField(3, 2, Value);
                    end;
                end;
            (Font in ['QR']):
                Printer.AddBarcode(CopyStr(Font, 1, 30), Value, 5, true, 5);
            (Font in ['COMMAND']):
                begin
                    Printer.SetFont('COMMAND');
                    Printer.AddLine('PAPERCUT', 0);
                end;
            (Font in ['LOGO']):
                begin
                    Printer.SetFont('Logo');
                    Printer.AddLine(Value, 0);
                end;
            (Font in ['CODE128']):
                Printer.AddBarcode(CopyStr(Font, 1, 30), Value, 2, true, 40);
        end;
        if CR then
            Printer.NewLine();
    end;
    #endregion

    var
        ShortInvoiceNumberFormatLbl: Label '%1-%2', Locked = true, Comment = '%1 = Signed by, %2 = Transaction Counter';
        ThermalPrintLineLbl: Label '________________________________________', Locked = true;
}