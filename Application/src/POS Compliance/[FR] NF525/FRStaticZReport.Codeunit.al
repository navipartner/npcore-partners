codeunit 6151507 "NPR FR Static Z Report"
{
    //Static print replacement for the EPSON_Z_REPORT_FR print template. The layout follows the NF525 certified Z-report.

    Access = Internal;
    TableNo = "NPR POS Workshift Checkpoint";

    var
        _Printer: Codeunit "NPR RP Line Print Mgt.";
        _CaptionWidth: Integer;

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        AddContent(Rec);

        //Printer output is configured on the standard Z report codeunit, which this report replaces on French POS units.
        _Printer.ProcessBuffer(Codeunit::"NPR Static Z Report", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    internal procedure AddContent(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSPaymBinDenomin: Record "NPR POS Paym. Bin Denomin.";
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        POSUnit: Record "NPR POS Unit";
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        RetailLogo: Record "NPR Retail Logo";
        CashDifference: Decimal;
        AmountText: Text;
        BinReference: Text;
        NewFloatCaption: Text;
        A11FontLbl: Label 'A11', Locked = true;
        CommandFontLbl: Label 'COMMAND', Locked = true;
        LogoFontLbl: Label 'Logo', Locked = true;
        ReceiptLogoLbl: Label 'RECEIPT', Locked = true;
        ZReportLbl: Label ' Z-report  (%1)', Locked = true;
        VATAndTaxLbl: Label '---- VAT and TAX ----', Locked = true;
        VouchersLbl: Label '---- Vouchers ----', Locked = true;
        SignatureLineLbl: Label '______________________________', Locked = true;
        CashDifferenceLbl: Label 'Cash Difference';
        SignatureLbl: Label 'Signature';
    begin
        InitializeLayout(A11FontLbl);

        // Logo
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        RetailLogo.SetRange("Register No.", POSWorkshiftCheckpoint."POS Unit No.");
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');
        if not RetailLogo.IsEmpty() then begin
            _Printer.SetFont(LogoFontLbl);
            _Printer.AddLine(ReceiptLogoLbl, 1);
            _Printer.SetFont(A11FontLbl);
        end;

        // Header
        //The grand total event carries the NF525 period number that identifies this report.
        POSAuditLog.SetRange("Acted on POS Entry No.", POSWorkshiftCheckpoint."POS Entry No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
        if POSAuditLog.FindLast() then begin
            _Printer.SetBold(true);
            _Printer.AddLine(StrSubstNo(ZReportLbl, POSAuditLog."External ID"), 1);
            _Printer.SetBold(false);
        end;

        //Unit no., unit name and timestamp each take their own line, as in the certified template. Concatenating them
        //overflows the 42 character width of the A11 font and the printer then cuts the timestamp off the right.
        _Printer.AddLine(POSWorkshiftCheckpoint."POS Unit No.", 0);

        POSUnit.SetLoadFields(Name);
        if POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            _Printer.AddLine(': ' + POSUnit.Name, 0);

        _Printer.AddLine(' - ' + Format(POSWorkshiftCheckpoint."Created At"), 1);
        _Printer.AddLine('', 0);

        // Turnover
        _Printer.SetBold(true);
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Turnover (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Turnover (LCY)"));
        AddAmountRow('  ' + POSWorkshiftCheckpoint.FieldCaption("Direct Turnover (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Direct Turnover (LCY)"));
        _Printer.SetBold(false);

        AddAmountRow('    ' + POSWorkshiftCheckpoint.FieldCaption("Direct Item Sales (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Direct Item Sales (LCY)"));
        AddAmountRow('    ' + POSWorkshiftCheckpoint.FieldCaption("Direct Item Returns (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"));
        AddAmountRow('    ' + POSWorkshiftCheckpoint.FieldCaption("Debtor Payment (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Debtor Payment (LCY)"));

        _Printer.SetBold(true);
        AddAmountRow('  ' + POSWorkshiftCheckpoint.FieldCaption("Credit Turnover (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Credit Turnover (LCY)"));
        _Printer.SetBold(false);

        _Printer.AddLine('', 0);
        AddSectionSeparator();

        // Net turnover
        _Printer.SetBold(true);
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Net Turnover (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Net Turnover (LCY)"));
        AddAmountRow(' ' + POSWorkshiftCheckpoint.FieldCaption("Direct Net Turnover (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Direct Net Turnover (LCY)"));
        _Printer.SetBold(false);

        _Printer.AddLine('', 0);

        if POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)" <> 0 then
            AddAmountRow('  ' + POSWorkshiftCheckpoint.FieldCaption("Credit Real. Sale Amt. (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)"));

        if POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)" <> 0 then
            AddAmountRow('  ' + POSWorkshiftCheckpoint.FieldCaption("Credit Real. Return Amt. (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)"));

        _Printer.SetBold(true);
        AddAmountRow(' ' + POSWorkshiftCheckpoint.FieldCaption("Credit Net Turnover (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Credit Net Turnover (LCY)"));
        _Printer.SetBold(false);

        AddSectionSeparator();

        // Discounts and unrealized credit amounts
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Total Discount (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Total Discount (LCY)"));

        if POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)" <> 0 then
            AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Credit Unreal. Sale Amt. (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)"));

        if POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)" <> 0 then
            AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Credit Unreal. Ret. Amt. (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)"));

        _Printer.AddLine('', 0);

        // VAT and TAX
        _Printer.AddLine(VATAndTaxLbl, 0);

        POSWorkshTaxCheckp.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax Area Code", "VAT Identifier", "Tax Calculation Type");
        POSWorkshTaxCheckp.SetLoadFields("Tax Calculation Type", "Tax %", "Tax Amount");
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        if POSWorkshTaxCheckp.FindSet() then
            repeat
                //Same split as the certified template: the calculation type takes its own line, then the rate and the
                //amount share the next one. Merging them risks the same overflow as the header did.
                _Printer.AddTextField(1, 0, Format(POSWorkshTaxCheckp."Tax Calculation Type") + ': ');
                AddAmountRow(FormatTaxPct(POSWorkshTaxCheckp."Tax %"), FormatAmt(POSWorkshTaxCheckp."Tax Amount"));
            until POSWorkshTaxCheckp.Next() = 0;

        AddSectionSeparator();
        _Printer.AddLine('', 0);

        // Payment movements
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("EFT (LCY)"), FormatAmt(POSWorkshiftCheckpoint."EFT (LCY)"));
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Local Currency (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Local Currency (LCY)"));

        if POSWorkshiftCheckpoint."GL Payment (LCY)" <> 0 then
            AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("GL Payment (LCY)"), FormatAmt(POSWorkshiftCheckpoint."GL Payment (LCY)"));

        _Printer.AddLine('', 0);

        // Vouchers
        _Printer.AddLine(VouchersLbl, 0);
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Created Credit Voucher (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Created Credit Voucher (LCY)"));
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Redeemed Credit Voucher (LCY)"), FormatAmt(POSWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)"));

        // Counters
        AddSectionSeparator();

        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Direct Sales Count"), Format(POSWorkshiftCheckpoint."Direct Sales Count"));
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Receipts Count"), Format(POSWorkshiftCheckpoint."Receipts Count"));
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Credit Sales Count"), Format(POSWorkshiftCheckpoint."Credit Sales Count"));
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Receipt Copies Count"), Format(POSWorkshiftCheckpoint."Receipt Copies Count"));
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Cash Drawer Open Count"), Format(POSWorkshiftCheckpoint."Cash Drawer Open Count"));
        AddAmountRow(POSWorkshiftCheckpoint.FieldCaption("Cancelled Sales Count"), Format(POSWorkshiftCheckpoint."Cancelled Sales Count"));

        _Printer.AddLine('', 0);

        // Bin counting
        POSPaymentBinCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        if POSPaymentBinCheckp.FindSet() then
            repeat
                _Printer.AddLine(POSPaymentBinCheckp."Payment Method No." + ' - ' + POSPaymentBinCheckp.Description, 1);

                AddAmountRow(POSPaymentBinCheckp.FieldCaption("Float Amount"), FormatAmt(POSPaymentBinCheckp."Float Amount"));

                POSPaymBinDenomin.SetRange("Bin Checkpoint Entry No.", POSPaymentBinCheckp."Entry No.");
                if POSPaymBinDenomin.FindSet() then
                    repeat
                        AddAmountRow('     ' + FormatAmt(POSPaymBinDenomin.Denomination) + ' * ' + Format(POSPaymBinDenomin.Quantity), FormatAmt(POSPaymBinDenomin.Amount));
                    until POSPaymBinDenomin.Next() = 0;

                AddAmountRow(POSPaymentBinCheckp.FieldCaption("Calculated Amount Incl. Float"), FormatAmt(POSPaymentBinCheckp."Calculated Amount Incl. Float"));
                AddAmountRow(POSPaymentBinCheckp.FieldCaption("Counted Amount Incl. Float"), FormatAmt(POSPaymentBinCheckp."Counted Amount Incl. Float"));

                //The comment takes its own full width line, so the counting difference below keeps its own caption.
                if POSPaymentBinCheckp.Comment <> '' then
                    _Printer.AddLine(POSPaymentBinCheckp.Comment, 0);

                CashDifference := POSPaymentBinCheckp."Calculated Amount Incl. Float" - POSPaymentBinCheckp."Counted Amount Incl. Float";
                if CashDifference <> 0 then
                    AddAmountRow(CashDifferenceLbl, FormatAmt(CashDifference));

                if POSPaymentBinCheckp."Transfer In Amount" <> 0 then
                    AddAmountRow(POSPaymentBinCheckp.FieldCaption("Transfer In Amount"), FormatAmt(POSPaymentBinCheckp."Transfer In Amount"));

                if POSPaymentBinCheckp."Transfer Out Amount" <> 0 then
                    AddAmountRow(POSPaymentBinCheckp.FieldCaption("Transfer Out Amount"), FormatAmt(POSPaymentBinCheckp."Transfer Out Amount"));

                //The reference and the amount are two halves of one row, so the row prints as soon as either one is filled.
                BinReference := '';
                if POSPaymentBinCheckp."Bank Deposit Bin Code" <> '' then
                    BinReference := POSPaymentBinCheckp."Bank Deposit Bin Code" + ' : ' + POSPaymentBinCheckp."Bank Deposit Reference";
                if (BinReference <> '') or (POSPaymentBinCheckp."Bank Deposit Amount" <> 0) then begin
                    AmountText := '';
                    if POSPaymentBinCheckp."Bank Deposit Amount" <> 0 then
                        AmountText := FormatAmt(POSPaymentBinCheckp."Bank Deposit Amount");
                    AddAmountRow(BinReference, AmountText);
                end;

                BinReference := '';
                if POSPaymentBinCheckp."Move to Bin Code" <> '' then
                    BinReference := POSPaymentBinCheckp."Move to Bin Code" + ' : ' + POSPaymentBinCheckp."Move to Bin Reference";
                if (BinReference <> '') or (POSPaymentBinCheckp."Move to Bin Amount" <> 0) then begin
                    AmountText := '';
                    if POSPaymentBinCheckp."Move to Bin Amount" <> 0 then
                        AmountText := FormatAmt(POSPaymentBinCheckp."Move to Bin Amount");
                    AddAmountRow(BinReference, AmountText);
                end;

                NewFloatCaption := POSPaymentBinCheckp.FieldCaption("New Float Amount");
                if POSPaymentBinCheckp."Currency Code" <> '' then
                    NewFloatCaption += ' (' + POSPaymentBinCheckp."Currency Code" + ')';
                AddAmountRow(NewFloatCaption, FormatAmt(POSPaymentBinCheckp."New Float Amount"));

                _Printer.AddLine('', 0);
            until POSPaymentBinCheckp.Next() = 0;

        // Signature
        //Only a Z-report carries the signature line. Consolidated X-reports are force-closed when the Z-report posts,
        //so the checkpoint type rather than its Open state is what tells the two apart.
        if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT then begin
            _Printer.AddLine('', 0);
            _Printer.AddLine(SignatureLineLbl, 1);
            _Printer.AddLine(SignatureLbl, 1);
        end;

        _Printer.SetFont(CommandFontLbl);
        _Printer.AddLine('PAPERCUT', 0);
    end;

    local procedure InitializeLayout(Font: Text[30])
    var
        CaptionColumnFactor: Decimal;
    begin
        //Leaves 30 characters for the caption and 11 for the amount on the 42 character A11 line. Every caption but the
        //longest one fits, and the amount column still holds a negative eight digit amount without being cut.
        CaptionColumnFactor := 0.72;

        _Printer.SetAutoLineBreak(true);
        _Printer.SetTwoColumnDistribution(CaptionColumnFactor, 1 - CaptionColumnFactor);
        _Printer.SetFont(Font);

        //NPR RP Line Print Mgt. cuts whatever does not fit the caption column, so every row has to know how wide that
        //column ends up. The rounding has to stay the same as the one the print manager applies when it pads the line.
        _CaptionWidth := Round(GetPageWidth(Font) * CaptionColumnFactor, 1, '<');
    end;

    local procedure GetPageWidth(Font: Text[30]): Integer
    var
        TempRPDeviceSettings: Record "NPR RP Device Settings" temporary;
        LinePrinter: Interface "NPR ILine Printer";
    begin
        //The same driver the buffer is processed with, initialized with its default settings, as the print manager does.
        LinePrinter := Enum::"NPR Line Printer Device"::Epson;
        LinePrinter.InitJob(TempRPDeviceSettings);
        exit(LinePrinter.GetPageWidth(Font));
    end;

    local procedure AddAmountRow(Caption: Text; AmountText: Text)
    begin
        //Captions are translated and several of them already fill the caption column in english, so a caption that does
        //not fit takes a full width line of its own. The amount then follows on the next line, right aligned in the same
        //column as every other amount, rather than being pushed out by a caption the printer would have cut.
        if StrLen(Caption) > _CaptionWidth then begin
            _Printer.AddLine(Caption, 0);
            _Printer.AddTextField(1, 0, '');
        end else
            _Printer.AddTextField(1, 0, Caption);

        _Printer.AddTextField(2, 2, AmountText);
    end;

    local procedure AddSectionSeparator()
    var
        SectionSeparatorLbl: Label '---- ---- ---- ---- ----', Locked = true;
    begin
        _Printer.AddLine(SectionSeparatorLbl, 0);
    end;

    local procedure FormatAmt(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Standard Format,2>'));
    end;

    local procedure FormatTaxPct(TaxPct: Decimal): Text
    var
        PercentLbl: Label '%', Locked = true;
    begin
        exit(Format(TaxPct, 0, '<Precision,0:5><Standard Format,2>') + PercentLbl);
    end;
}
