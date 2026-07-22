codeunit 6151136 "NPR Static Retail Voucher"
{
    Access = Internal;
    TableNo = "NPR NpRv Voucher";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.25, 0.05, 0.70);
        AddContent(Rec);
        Printer.ProcessBuffer(Codeunit::"NPR Static Retail Voucher", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddContent(Voucher: Record "NPR NpRv Voucher")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        SendingLog: Record "NPR NpRv Sending Log";
        ModulePayDefault: Codeunit "NPR NpRv Module Pay.: Default";
        ModulePayPartial: Codeunit "NPR NpRv Module Pay. - Partial";
        B11FontLbl: Label 'B11', Locked = true;
        B21FontLbl: Label 'B21', Locked = true;
        B22FontLbl: Label 'B22', Locked = true;
        Code128FontLbl: Label 'CODE128', Locked = true;
        CommandFontLbl: Label 'COMMAND', Locked = true;
        PapercutLbl: Label 'PAPERCUT', Locked = true;
        CopyLbl: Label '*** COPY ***';
        CreditVoucherLbl: Label 'Credit voucher';
        ValidUntilPrefixLbl: Label 'Valid until: ';
        LegalTextLbl: Label 'Invalid without company stamp and signature.';
        StampSignatureLbl: Label 'Stamp and Signature';
    begin
        if not VoucherType.Get(Voucher."Voucher Type") then
            Clear(VoucherType);

        Voucher.CalcFields("Issue Register No.");
        if POSUnit.Get(Voucher."Issue Register No.") then
            if not POSStore.Get(POSUnit."POS Store Code") then
                Clear(POSStore);

        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        VoucherEntry.SetFilter("Entry Type", '%1|%2', VoucherEntry."Entry Type"::"Issue Voucher", VoucherEntry."Entry Type"::"Partner Issue Voucher");
        if not VoucherEntry.FindFirst() then
            Clear(VoucherEntry);

        Printer.SetFont(B11FontLbl);

        // Store header
        if POSStore.Name <> '' then begin
            Printer.SetFont(B21FontLbl);
            Printer.SetBold(true);
            Printer.AddLine(POSStore.Name, 0);
            Printer.SetBold(false);
            Printer.SetFont(B11FontLbl);
        end;
        if POSStore.Address <> '' then
            Printer.AddLine(POSStore.Address, 0);
        if (POSStore."Post Code" <> '') or (POSStore.City <> '') then
            Printer.AddLine(POSStore."Post Code" + ' ' + POSStore.City, 0);
        if POSStore."Phone No." <> '' then
            Printer.AddLine(POSStore.FieldCaption("Phone No.") + ': ' + POSStore."Phone No.", 0);
        if POSStore."E-Mail" <> '' then
            Printer.AddLine(POSStore.FieldCaption("E-Mail") + ': ' + POSStore."E-Mail", 0);
        if POSStore."VAT Registration No." <> '' then
            Printer.AddLine(POSStore.FieldCaption("VAT Registration No.") + ': ' + POSStore."VAT Registration No.", 0);

        // COPY label
        SendingLog.SetRange("Voucher No.", Voucher."No.");
        SendingLog.SetRange("Sending Type", SendingLog."Sending Type"::Print);
        if not SendingLog.IsEmpty() then begin
            Printer.SetFont(B21FontLbl);
            Printer.SetBold(true);
            Printer.AddLine(CopyLbl, 1);
            Printer.SetBold(false);
            Printer.SetFont(B11FontLbl);
        end;

        // Voucher Type
        Printer.SetFont(B22FontLbl);
        Printer.AddLine(VoucherType.Code, 1);
        Printer.SetFont(B11FontLbl);

        // No. / Amount rows
        Printer.SetFont(B21FontLbl);
        Printer.SetBold(true);
        case VoucherType."Apply Payment Module" of
            ModulePayPartial.ModuleCode():
                begin
                    Printer.AddLine(CreditVoucherLbl, 0);
                    Printer.AddLine(Voucher."No.", 2);
                end;
            ModulePayDefault.ModuleCode():
                begin
                    Printer.AddTextField(1, 0, Voucher.FieldCaption("No."));
                    Printer.AddTextField(2, 0, '');
                    Printer.AddTextField(3, 2, Voucher."No.");
                end;
        end;

        Printer.AddTextField(1, 0, VoucherEntry.FieldCaption(Amount));
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, FormatAmt(VoucherEntry.Amount));
        Printer.SetBold(false);
        Printer.SetFont(B11FontLbl);

        // Customer info
        if Voucher."Customer No." <> '' then begin
            PrintSeparator();
            Printer.SetFont(B21FontLbl);
            Printer.SetBold(true);
            if Voucher.Name <> '' then
                Printer.AddLine(Voucher.Name, 0);
            if Voucher.Address <> '' then
                Printer.AddLine(Voucher.Address, 0);
            if (Voucher."Post Code" <> '') or (Voucher.City <> '') then
                Printer.AddLine(Voucher."Post Code" + ' ' + Voucher.City, 0);
            Printer.SetBold(false);
            Printer.SetFont(B11FontLbl);
            PrintSeparator();
        end;

        // Legal footer text
        if Voucher."Ending Date" <> 0DT then
            Printer.AddLine(ValidUntilPrefixLbl + Format(DT2Date(Voucher."Ending Date"), 0, '<Day,2>/<Month,2>/<Year4>'), 1);
        Printer.AddLine(LegalTextLbl, 1);

        // Barcode (Reference No.)
        Printer.SetFont(Code128FontLbl);
        Printer.AddBarcode(Code128FontLbl, Voucher."Reference No.", 2, false, 40);
        Printer.SetFont(B11FontLbl);

        // Stamp / signature area
        Printer.SetFont(B21FontLbl);
        Printer.AddLine(StampSignatureLbl, 1);
        Printer.SetFont(B11FontLbl);

        PrintSeparator();

        // Footer info
        Printer.AddTextField(1, 0, Format(VoucherEntry."Posting Date"));
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, VoucherEntry."Document No." + ' / ' + VoucherEntry."Register No.");
        Printer.AddTextField(1, 0, Format(DT2Time(VoucherEntry.SystemCreatedAt), 0, '<Hours12>:<Minutes,2>:<Seconds,2> <AM/PM>'));
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, Voucher."Reference No.");

        Printer.SetFont(CommandFontLbl);
        Printer.AddLine(PapercutLbl, 0);
    end;

    local procedure PrintSeparator()
    begin
        Printer.SetPadChar('.');
        Printer.AddLine('', 0);
        Printer.SetPadChar('');
    end;

    local procedure FormatAmt(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Standard Format,2>'));
    end;
}
