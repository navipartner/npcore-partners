codeunit 6151229 "NPR Static Z Report"
{
    Access = Internal;
    TableNo = "NPR POS Workshift Checkpoint";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetTwoColumnDistribution(0.7, 0.3);
        AddContent(Rec);
        Printer.ProcessBuffer(Codeunit::"NPR Static Z Report", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddContent(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        POSPaymBinDenomin: Record "NPR POS Paym. Bin Denomin.";
        POSBalancingLine: Record "NPR POS Balancing Line";
        TotalPayIn: Decimal;
        TotalPayOut: Decimal;
        IssuedGiftVoucher: Decimal;
        RedeemedGiftVoucher: Decimal;
        IssuedCreditVoucher: Decimal;
        RedeemedCreditVoucher: Decimal;
        CashDiff: Decimal;
        NewFloatLabel: Text;
        AmountWithCurrency: Text;
        BalancingReportLbl: Label 'Balancing Report';
        BalancedByLbl: Label 'Balanced by :  ';
        PayInLbl: Label 'Pay In';
        PayOutLbl: Label 'Pay Out';
        MovementsLbl: Label 'Movements';
        GiftVoucherCreditVoucherLbl: Label 'Giftvoucher/CreditVoucher';
        IssuedGiftVoucherLbl: Label 'Issued Giftvoucher';
        RedeemedGiftVoucherLbl: Label 'Redeemed Giftvoucher';
        IssuedCreditVoucherLbl: Label 'Issued CreditVoucher';
        RedeemedCreditVoucherLbl: Label 'Redeemed CreditVoucher';
        GiftVoucherTotalLbl: Label 'GiftVoucher Total';
        CreditVoucherTotalLbl: Label 'CreditVoucher Total';
        CashDifferenceLbl: Label 'Cash Difference';
        CommentPrefixLbl: Label 'Comment:';
        TransferredToBinLbl: Label 'Transferred to bin:';
        SignatureLineLbl: Label '______________________________';
        SignatureLbl: Label 'Signature';
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");

        // Header
        Printer.SetFont('B21');
        Printer.SetBold(true);
        Printer.AddLine(BalancingReportLbl, 1);
        Printer.SetBold(false);
        Printer.SetFont('A11');
        Printer.SetBold(true);
        Printer.AddLine(POSWorkshiftCheckpoint."POS Unit No." + ': ' + POSUnit.Name, 1);
        Printer.SetBold(false);
        Printer.AddLine(Format(POSWorkshiftCheckpoint."Created At"), 1);
        if SalespersonPurchaser.Get(POSWorkshiftCheckpoint."Salesperson Code") then
            Printer.AddLine(BalancedByLbl + SalespersonPurchaser.Name, 1);
        Printer.AddLine('', 0);

        // Sales
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Turnover (LCY)"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Turnover (LCY)"));
        Printer.SetBold(false);
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Direct Item Sales (LCY)"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Direct Item Sales (LCY)"));
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Direct Item Sales Quantity"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Direct Item Sales Quantity"));
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Direct Item Returns (LCY)"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"));
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Direct Item Returns Quantity"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Direct Item Returns Quantity"));
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Debtor Payment (LCY)"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Debtor Payment (LCY)"));
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Credit Turnover (LCY)"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Credit Turnover (LCY)"));
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Credit Sales Count"));
        Printer.AddTextField(2, 2, Format(POSWorkshiftCheckpoint."Credit Sales Count"));

        // Pay-In / Pay-Out
        POSEntrySalesLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Payout);
        POSEntrySalesLine.SetFilter("Amount Incl. VAT (LCY)", '>0');
        POSEntrySalesLine.CalcSums("Amount Incl. VAT (LCY)");
        TotalPayIn := POSEntrySalesLine."Amount Incl. VAT (LCY)";

        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Payout);
        POSEntrySalesLine.SetFilter("Amount Incl. VAT (LCY)", '<0');
        POSEntrySalesLine.CalcSums("Amount Incl. VAT (LCY)");
        TotalPayOut := POSEntrySalesLine."Amount Incl. VAT (LCY)";

        PrintSeparator();
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, PayInLbl);
        Printer.AddTextField(2, 2, FormatAmt(TotalPayIn));
        Printer.SetBold(false);
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetLoadFields("POS Period Register No.", Type, "No.", Description, "Amount Incl. VAT (LCY)");
        POSEntrySalesLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Payout);
        POSEntrySalesLine.SetFilter("Amount Incl. VAT (LCY)", '>0');
        if POSEntrySalesLine.FindSet() then
            repeat
                Printer.AddTextField(1, 0, POSEntrySalesLine."No." + ': ' + POSEntrySalesLine.Description);
                Printer.AddTextField(2, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT (LCY)"));
            until POSEntrySalesLine.Next() = 0;

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, PayOutLbl);
        Printer.AddTextField(2, 2, FormatAmt(TotalPayOut));
        Printer.SetBold(false);
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetLoadFields("POS Period Register No.", Type, "No.", Description, "Amount Incl. VAT (LCY)");
        POSEntrySalesLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Payout);
        POSEntrySalesLine.SetFilter("Amount Incl. VAT (LCY)", '<0');
        if POSEntrySalesLine.FindSet() then
            repeat
                Printer.AddTextField(1, 0, POSEntrySalesLine."No." + ': ' + POSEntrySalesLine.Description);
                Printer.AddTextField(2, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT (LCY)"));
            until POSEntrySalesLine.Next() = 0;

        // Movements
        PrintSeparator();
        Printer.SetBold(true);
        Printer.AddLine(MovementsLbl, 0);
        Printer.SetBold(false);
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("Local Currency (LCY)"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."Local Currency (LCY)"));
        Printer.AddTextField(1, 0, POSWorkshiftCheckpoint.FieldCaption("EFT (LCY)"));
        Printer.AddTextField(2, 2, FormatAmt(POSWorkshiftCheckpoint."EFT (LCY)"));

        // Giftvoucher / CreditVoucher
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Voucher);
        POSEntrySalesLine.SetRange("Voucher Category", POSEntrySalesLine."Voucher Category"::"Gift Voucher");
        POSEntrySalesLine.CalcSums("Amount Incl. VAT (LCY)");
        IssuedGiftVoucher := POSEntrySalesLine."Amount Incl. VAT (LCY)";

        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Voucher);
        POSEntrySalesLine.SetRange("Voucher Category", POSEntrySalesLine."Voucher Category"::"Credit Voucher");
        POSEntrySalesLine.CalcSums("Amount Incl. VAT (LCY)");
        IssuedCreditVoucher := POSEntrySalesLine."Amount Incl. VAT (LCY)";

        POSEntryPaymentLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntryPaymentLine.SetRange("Voucher Category", POSEntryPaymentLine."Voucher Category"::"Gift Voucher");
        POSEntryPaymentLine.CalcSums("Amount (LCY)");
        RedeemedGiftVoucher := POSEntryPaymentLine."Amount (LCY)";

        POSEntryPaymentLine.Reset();
        POSEntryPaymentLine.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        POSEntryPaymentLine.SetRange("Voucher Category", POSEntryPaymentLine."Voucher Category"::"Credit Voucher");
        POSEntryPaymentLine.CalcSums("Amount (LCY)");
        RedeemedCreditVoucher := POSEntryPaymentLine."Amount (LCY)";

        PrintSeparator();
        Printer.SetBold(true);
        Printer.AddLine(GiftVoucherCreditVoucherLbl, 0);
        Printer.SetBold(false);
        Printer.AddTextField(1, 0, IssuedGiftVoucherLbl);
        Printer.AddTextField(2, 2, FormatAmt(IssuedGiftVoucher));
        Printer.AddTextField(1, 0, RedeemedGiftVoucherLbl);
        Printer.AddTextField(2, 2, FormatAmt(RedeemedGiftVoucher));
        Printer.AddTextField(1, 0, IssuedCreditVoucherLbl);
        Printer.AddTextField(2, 2, FormatAmt(IssuedCreditVoucher));
        Printer.AddTextField(1, 0, RedeemedCreditVoucherLbl);
        Printer.AddTextField(2, 2, FormatAmt(RedeemedCreditVoucher));
        Printer.AddTextField(1, 0, GiftVoucherTotalLbl);
        Printer.AddTextField(2, 2, FormatAmt(IssuedGiftVoucher - RedeemedGiftVoucher));
        Printer.AddTextField(1, 0, CreditVoucherTotalLbl);
        Printer.AddTextField(2, 2, FormatAmt(IssuedCreditVoucher - RedeemedCreditVoucher));

        // Bin Counting
        PrintSeparator();

        POSPaymentBinCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
        if POSPaymentBinCheckp.FindSet() then
            repeat
                Printer.SetBold(true);
                Printer.AddLine(POSPaymentBinCheckp.Description, 1);
                Printer.SetBold(false);

                if POSPaymentBinCheckp."Float Amount" <> 0 then begin
                    Printer.SetBold(true);
                    Printer.AddTextField(1, 0, POSPaymentBinCheckp.FieldCaption("Float Amount"));
                    Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."Float Amount"));
                    Printer.SetBold(false);
                end;

                POSPaymBinDenomin.SetRange("Bin Checkpoint Entry No.", POSPaymentBinCheckp."Entry No.");
                if POSPaymBinDenomin.FindSet() then
                    repeat
                        Printer.AddTextField(1, 0, FormatAmt(POSPaymBinDenomin.Denomination) + ' * ' + Format(POSPaymBinDenomin.Quantity));
                        Printer.AddTextField(2, 2, FormatAmt(POSPaymBinDenomin.Amount));
                    until POSPaymBinDenomin.Next() = 0;

                if POSPaymentBinCheckp."Counted Amount Incl. Float" <> 0 then begin
                    Printer.AddTextField(1, 0, POSPaymentBinCheckp.FieldCaption("Counted Amount Incl. Float"));
                    Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."Counted Amount Incl. Float"));
                end;

                CashDiff := POSPaymentBinCheckp."Calculated Amount Incl. Float" - POSPaymentBinCheckp."Counted Amount Incl. Float";
                if CashDiff <> 0 then begin
                    Printer.SetBold(true);
                    Printer.AddTextField(1, 0, CashDifferenceLbl);
                    Printer.SetBold(false);
                    Printer.AddTextField(2, 2, FormatAmt(CashDiff));
                end;

                if POSPaymentBinCheckp.Comment <> '' then
                    Printer.AddLine(CommentPrefixLbl + ' ' + POSPaymentBinCheckp.Comment, 0);

                if POSPaymentBinCheckp."Transfer In Amount" <> 0 then begin
                    Printer.AddTextField(1, 0, POSPaymentBinCheckp.FieldCaption("Transfer In Amount"));
                    Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."Transfer In Amount"));
                end;

                if POSPaymentBinCheckp."Transfer Out Amount" <> 0 then begin
                    Printer.AddTextField(1, 0, POSPaymentBinCheckp.FieldCaption("Transfer Out Amount"));
                    Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."Transfer Out Amount"));
                end;

                if POSPaymentBinCheckp."Bank Deposit Bin Code" <> '' then begin
                    Printer.AddTextField(1, 0, POSPaymentBinCheckp."Bank Deposit Bin Code" + ' : ' + POSPaymentBinCheckp."Bank Deposit Reference");
                    if POSPaymentBinCheckp."Bank Deposit Amount" <> 0 then
                        Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."Bank Deposit Amount"));
                end;

                if POSPaymentBinCheckp."Move to Bin Code" <> '' then begin
                    Printer.AddTextField(1, 0, POSPaymentBinCheckp."Move to Bin Code" + ' : ' + POSPaymentBinCheckp."Move to Bin Reference");
                    if POSPaymentBinCheckp."Move to Bin Amount" <> 0 then
                        Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."Move to Bin Amount"));
                end;

                if POSPaymentBinCheckp."New Float Amount" <> 0 then begin
                    NewFloatLabel := POSPaymentBinCheckp.FieldCaption("New Float Amount");
                    if POSPaymentBinCheckp."Currency Code" <> '' then
                        NewFloatLabel += ' (' + POSPaymentBinCheckp."Currency Code" + ')';
                    Printer.AddTextField(1, 0, NewFloatLabel);
                    Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."New Float Amount"));
                end;

                PrintSeparator();
            until POSPaymentBinCheckp.Next() = 0;

        // Balancing Lines
        POSBalancingLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSBalancingLine.SetFilter("Move-To Bin Code", '<>%1', '');
        if POSBalancingLine.FindSet() then
            repeat
                AmountWithCurrency := FormatAmt(POSBalancingLine."Move-To Bin Amount");
                if POSBalancingLine."Currency Code" <> '' then
                    AmountWithCurrency += ' ' + POSBalancingLine."Currency Code";
                Printer.AddTextField(1, 0, TransferredToBinLbl + ' ' + POSBalancingLine."Move-To Bin Code");
                Printer.AddTextField(2, 2, AmountWithCurrency);
            until POSBalancingLine.Next() = 0;

        // Signature
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.AddLine(SignatureLineLbl, 1);
        Printer.AddLine(SignatureLbl, 1);
        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;

    local procedure PrintSeparator()
    begin
        Printer.SetPadChar('-');
        Printer.AddLine('', 0);
        Printer.SetPadChar('');
    end;

    local procedure FormatAmt(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Standard Format,2>'));
    end;
}
