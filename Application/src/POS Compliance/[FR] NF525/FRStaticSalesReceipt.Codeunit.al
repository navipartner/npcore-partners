codeunit 6151496 "NPR FR Static Sales Receipt"
{
    //Static print replacement for the EPSON_RECEIPT_FR print template. The layout follows the NF525 certified receipt.

    Access = Internal;
    TableNo = "NPR POS Entry";

    var
        _Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        _Printer.SetAutoLineBreak(true);
        _Printer.SetTwoColumnDistribution(0.5, 0.5);
        _Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);
        _Printer.SetFourColumnDistribution(0.25, 0.25, 0.25, 0.25);

        AddReceiptInformation(Rec);

        //Printer output is configured on the standard sales receipt codeunit, which this receipt replaces on French POS units.
        _Printer.ProcessBuffer(Codeunit::"NPR Static Sales Receipt", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    internal procedure AddReceiptInformation(POSEntry: Record "NPR POS Entry")
    var
        Contact: Record Contact;
        Customer: Record Customer;
        FRPOSAuditLogAddInfo: Record "NPR FR POS Audit Log Add. Info";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemVariant: Record "Item Variant";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSStore: Record "NPR POS Store";
        POSTicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        POSUnit: Record "NPR POS Unit";
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
        RetailLogo: Record "NPR Retail Logo";
        SaleAuditLogFound: Boolean;
        CopyNumber: Integer;
        BusinessIdentification: Text;
        A11FontLbl: Label 'A11', Locked = true;
        Code128FontLbl: Label 'CODE128', Locked = true;
        CommandFontLbl: Label 'COMMAND', Locked = true;
        LogoFontLbl: Label 'Logo', Locked = true;
        ReceiptLogoLbl: Label 'RECEIPT', Locked = true;
        IntraCommVATLbl: Label 'Intra-comm. TVA: ', Locked = true;
        APELbl: Label 'APE:', Locked = true;
        SiretLbl: Label 'Siret:', Locked = true;
        PhoneNoLbl: Label 'Numéro de téléphone ', Locked = true;
        EMailLbl: Label 'Adresse électronique ', Locked = true;
        CopyPrintedLbl: Label 'Copie imprimée', Locked = true;
        CopyNumberLbl: Label 'Numéro de copie:', Locked = true;
        FiscalReceiptNoLbl: Label 'Numéro de reçu fiscal ', Locked = true;
        VATIdentifierLbl: Label 'TVA: ', Locked = true;
        LineDiscountLbl: Label 'Rabais: ', Locked = true;
        NoOfLinesLbl: Label 'nombre de lignes: ', Locked = true;
        VATCodeLbl: Label 'Code', Locked = true;
        AmountExclVATLbl: Label 'HT', Locked = true;
        VATAmountLbl: Label 'TVA', Locked = true;
        AmountInclVATLbl: Label 'TTC', Locked = true;
        TotalDiscountLbl: Label 'Remise totale ', Locked = true;
        TotalExclVATLbl: Label 'Total Sans TVA', Locked = true;
        TotalInclVATLbl: Label 'Total %1 Avec TVA', Locked = true;
        ExchangeRateLbl: Label 'Taux: ', Locked = true;
        SalespersonLbl: Label 'Vendeur: ', Locked = true;
    begin
        _Printer.SetFont(A11FontLbl);

        // Logo
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        RetailLogo.SetRange("Register No.", POSEntry."POS Unit No.");
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');
        if not RetailLogo.IsEmpty() then begin
            _Printer.SetFont(LogoFontLbl);
            _Printer.AddLine(ReceiptLogoLbl, 1);
            _Printer.SetFont(A11FontLbl);
        end;

        // Sale audit log, printed further down as the store identification and the external description
        POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        POSAuditLog.SetFilter("Action Type", '=%1|=%2', POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END);
        SaleAuditLogFound := POSAuditLog.FindLast();

        // Store information
        //NF525 requires the store identification as it was when the sale was signed, so it comes from the audit log snapshot.
        if SaleAuditLogFound then
            if FRPOSAuditLogAddInfo.Get(POSAuditLog."Entry No.") then begin
                if FRPOSAuditLogAddInfo."Store Name" <> '' then
                    _Printer.AddLine(FRPOSAuditLogAddInfo."Store Name", 1);

                if FRPOSAuditLogAddInfo."Store Name 2" <> '' then
                    _Printer.AddLine(FRPOSAuditLogAddInfo."Store Name 2", 1);

                if FRPOSAuditLogAddInfo."Store Address" <> '' then
                    _Printer.AddLine(FRPOSAuditLogAddInfo."Store Address", 1);

                if FRPOSAuditLogAddInfo."Store Address 2" <> '' then
                    _Printer.AddLine(FRPOSAuditLogAddInfo."Store Address 2", 1);

                if (FRPOSAuditLogAddInfo."Store Post Code" <> '') or (FRPOSAuditLogAddInfo."Store City" <> '') then
                    _Printer.AddLine(FRPOSAuditLogAddInfo."Store Post Code" + ' ' + FRPOSAuditLogAddInfo."Store City", 1);

                if FRPOSAuditLogAddInfo."Store Country/Region Code" <> '' then
                    _Printer.AddLine(FRPOSAuditLogAddInfo."Store Country/Region Code", 1);

                if FRPOSAuditLogAddInfo."Intra-comm. VAT ID" <> '' then
                    _Printer.AddLine(IntraCommVATLbl + FRPOSAuditLogAddInfo."Intra-comm. VAT ID", 1);

                //The separator belongs to the Siret half, so an APE code without a Siret does not print a dangling ' - '.
                BusinessIdentification := '';
                if FRPOSAuditLogAddInfo.APE <> '' then
                    BusinessIdentification := APELbl + FRPOSAuditLogAddInfo.APE;
                if FRPOSAuditLogAddInfo."Store Siret" <> '' then begin
                    if BusinessIdentification <> '' then
                        BusinessIdentification += ' - ';
                    BusinessIdentification += SiretLbl + FRPOSAuditLogAddInfo."Store Siret";
                end;
                if BusinessIdentification <> '' then
                    _Printer.AddLine(BusinessIdentification, 1);

                _Printer.AddLine('', 0);
            end;

        POSStore.SetLoadFields("Phone No.", "E-Mail", "Home Page");
        if POSStore.Get(POSEntry."POS Store Code") then begin
            if POSStore."Phone No." <> '' then
                _Printer.AddLine(PhoneNoLbl + POSStore."Phone No.", 1);

            if POSStore."E-Mail" <> '' then
                _Printer.AddLine(EMailLbl + POSStore."E-Mail", 1);

            if POSStore."Home Page" <> '' then
                _Printer.AddLine(POSStore."Home Page", 1);
        end;

        // Copy information
        //The certified template marks the print as a copy on any prior output row, and numbers it from the prints alone.
        POSEntryOutputLog.SetRange("POS Entry No.", POSEntry."Entry No.");
        if not POSEntryOutputLog.IsEmpty() then begin
            _Printer.AddLine(CopyPrintedLbl, 0);

            POSEntryOutputLog.SetRange("Output Method", POSEntryOutputLog."Output Method"::Print);
            POSEntryOutputLog.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog."Output Type"::SalesReceipt, POSEntryOutputLog."Output Type"::LargeSalesReceipt);
            CopyNumber := POSEntryOutputLog.Count() - 1;
            if CopyNumber > 0 then
                _Printer.AddLine(CopyNumberLbl + Format(CopyNumber), 0);
        end;

        // Fiscal receipt information
        _Printer.AddLine('', 0);

        _Printer.SetBold(true);
        if SaleAuditLogFound and (POSAuditLog."External Description" <> '') then
            _Printer.AddLine(POSAuditLog."External Description", 0);
        _Printer.AddLine(FiscalReceiptNoLbl + POSEntry."Fiscal No.", 0);
        _Printer.SetBold(false);

        // Customer information
        Customer.SetLoadFields("Customer Price Group", Name, Address, "Post Code", City);
        if Customer.Get(POSEntry."Customer No.") then begin
            if Customer."Customer Price Group" <> '' then
                _Printer.AddLine(Customer."Customer Price Group", 0);

            if Customer.Name <> '' then
                _Printer.AddLine(Customer.Name, 0);

            if Customer.Address <> '' then
                _Printer.AddLine(Customer.Address, 0);

            if (Customer."Post Code" <> '') or (Customer.City <> '') then
                _Printer.AddLine(Customer."Post Code" + ' ' + Customer.City, 0);
        end;

        // Contact information
        Contact.SetLoadFields(Name, Address, "Post Code", City);
        if Contact.Get(POSEntry."Contact No.") then begin
            if Contact.Name <> '' then
                _Printer.AddLine(Contact.Name, 0);

            if Contact.Address <> '' then
                _Printer.AddLine(Contact.Address, 0);

            if (Contact."Post Code" <> '') or (Contact.City <> '') then
                _Printer.AddLine(Contact."Post Code" + ' ' + Contact.City, 0);
        end;

        // Sales lines
        AddSeparator();

        ItemVariant.SetLoadFields(Description);
        POSEntrySalesLine.SetLoadFields("No.", Description, Type, "Variant Code", Quantity, "Unit Price", "Amount Incl. VAT", "Line Discount Amount Incl. VAT", "Line Discount %", "VAT Identifier");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntrySalesLine.FindSet() then
            repeat
                case POSEntrySalesLine.Type of
                    POSEntrySalesLine.Type::Item:
                        begin
                            _Printer.AddLine(POSEntrySalesLine.Description, 0);

                            if POSEntrySalesLine."Variant Code" <> '' then
                                if ItemVariant.Get(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code") then
                                    if ItemVariant.Description <> '' then
                                        _Printer.AddLine(ItemVariant.Description, 0);

                            _Printer.AddTextField(1, 0, VATIdentifierLbl + POSEntrySalesLine."VAT Identifier");
                            _Printer.AddTextField(2, 0, '  ' + FormatQty(POSEntrySalesLine.Quantity) + 'x' + FormatAmt(POSEntrySalesLine."Unit Price"));
                            _Printer.AddTextField(3, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT"));

                            if POSEntrySalesLine."Line Discount Amount Incl. VAT" <> 0 then
                                _Printer.AddLine(LineDiscountLbl + FormatAmt(POSEntrySalesLine."Line Discount Amount Incl. VAT") + ' - ' + FormatAmt(POSEntrySalesLine."Line Discount %") + '% ', 0);
                        end;
                    POSEntrySalesLine.Type::"G/L Account",
                    POSEntrySalesLine.Type::Customer,
                    POSEntrySalesLine.Type::Payout:
                        begin
                            _Printer.AddTextField(1, 0, POSEntrySalesLine.Description);
                            _Printer.AddTextField(2, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT"));
                        end;
                    POSEntrySalesLine.Type::Comment:
                        _Printer.AddLine(POSEntrySalesLine.Description, 0);
                    POSEntrySalesLine.Type::Voucher:
                        begin
                            _Printer.AddLine(POSEntrySalesLine.Description, 0);

                            _Printer.AddTextField(1, 0, VATIdentifierLbl + POSEntrySalesLine."VAT Identifier");
                            _Printer.AddTextField(2, 0, '  ' + FormatQty(POSEntrySalesLine.Quantity) + 'x' + FormatAmt(Divide(POSEntrySalesLine."Amount Incl. VAT", POSEntrySalesLine.Quantity)));
                            _Printer.AddTextField(3, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT"));
                        end;
                end;

                _Printer.AddLine('', 0);
            until POSEntrySalesLine.Next() = 0;

        _Printer.SetBold(true);
        _Printer.AddLine(NoOfLinesLbl + Format(POSEntry."No. of Sales Lines"), 1);
        _Printer.SetBold(false);

        // Tax lines
        AddSeparator();

        _Printer.SetBold(true);
        _Printer.AddTextField(1, 0, VATCodeLbl);
        _Printer.AddTextField(2, 2, AmountExclVATLbl);
        _Printer.AddTextField(3, 2, VATAmountLbl);
        _Printer.AddTextField(4, 2, AmountInclVATLbl);
        _Printer.SetBold(false);

        POSEntryTaxLine.SetLoadFields("VAT Identifier", "Tax Base Amount", "Tax Amount", "Amount Including Tax");
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryTaxLine.FindSet() then
            repeat
                _Printer.AddTextField(1, 0, POSEntryTaxLine."VAT Identifier");
                _Printer.AddTextField(2, 2, FormatAmt(POSEntryTaxLine."Tax Base Amount"));
                _Printer.AddTextField(3, 2, FormatAmt(POSEntryTaxLine."Tax Amount"));
                _Printer.AddTextField(4, 2, FormatAmt(POSEntryTaxLine."Amount Including Tax"));
            until POSEntryTaxLine.Next() = 0;

        // Totals
        AddSeparator();

        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetLoadFields("Line Dsc. Amt. Incl. VAT (LCY)");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.CalcSums("Line Dsc. Amt. Incl. VAT (LCY)");
        _Printer.AddTextField(1, 0, TotalDiscountLbl);
        _Printer.AddTextField(2, 2, FormatAmt(POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)"));

        _Printer.AddTextField(1, 0, TotalExclVATLbl);
        _Printer.AddTextField(2, 2, FormatAmt(POSEntry."Amount Excl. Tax"));

        if GeneralLedgerSetup.Get() then;
        _Printer.SetBold(true);
        _Printer.AddTextField(1, 0, StrSubstNo(TotalInclVATLbl, GeneralLedgerSetup."LCY Code"));
        _Printer.AddTextField(2, 2, FormatAmt(POSEntry."Amount Incl. Tax"));
        _Printer.SetBold(false);

        // Payment lines
        AddSeparator();

        POSEntryPaymentLine.SetLoadFields(Description, Amount, "Amount (Sales Currency)");
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryPaymentLine.FindSet() then
            repeat
                _Printer.AddTextField(1, 0, POSEntryPaymentLine.Description);
                _Printer.AddTextField(2, 0, ExchangeRateLbl + FormatAmt(Divide(POSEntryPaymentLine."Amount (Sales Currency)", POSEntryPaymentLine.Amount)));
                _Printer.AddTextField(3, 2, FormatAmt(POSEntryPaymentLine.Amount));
            until POSEntryPaymentLine.Next() = 0;

        // Rounding lines
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetLoadFields(Description, "Amount Incl. VAT");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Rounding);
        if POSEntrySalesLine.FindSet() then
            repeat
                _Printer.AddTextField(1, 0, POSEntrySalesLine.Description);
                _Printer.AddTextField(2, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT"));
            until POSEntrySalesLine.Next() = 0;

        // Barcode
        _Printer.AddLine('', 0);

        _Printer.SetFont(Code128FontLbl);
        _Printer.AddBarcode(Code128FontLbl, POSEntry."Document No.", 3, false, 0);
        _Printer.SetFont(A11FontLbl);

        // Receipt footer text
        POSUnit.SetLoadFields("POS Unit Receipt Text Profile");
        if POSUnit.Get(POSEntry."POS Unit No.") then
            if POSUnitRcptTxtProfile.Get(POSUnit."POS Unit Receipt Text Profile") then begin
                POSTicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitRcptTxtProfile.Code);
                if POSTicketRcptText.FindSet() then
                    repeat
                        _Printer.AddLine(POSTicketRcptText."Receipt Text", 1);
                    until POSTicketRcptText.Next() = 0;
            end;

        _Printer.AddLine('', 0);
        _Printer.AddLine(POSEntry."Document No." + '/' + POSEntry."POS Unit No.", 1);
        _Printer.AddLine(SalespersonLbl + POSEntry."Salesperson Code", 0);

        AddNF525Footer(POSEntry, _Printer, 1);

        _Printer.SetFont(CommandFontLbl);
        _Printer.AddLine('PAPERCUT', 0);
    end;

    /// <summary>
    /// Adds the NF525 mandated closing block: audit log timestamp, signature extract, certification reference and fiscal version.
    /// Shared with the EPSON_RECEIPT_FR print template, which reaches it through the receipt footer event.
    /// </summary>
    internal procedure AddNF525Footer(POSEntry: Record "NPR POS Entry"; LinePrintMgt: Codeunit "NPR RP Line Print Mgt."; Align: Integer)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        InStream: InStream;
        Signature: Text;
        SignatureChunk: Text;
        CertificationReferenceLbl: Label 'NF525/%1', Locked = true;
        MissingSignatureErr: Label '%1 %2 is missing a digital signature', Comment = '%1 = POS Entry table caption, %2 = POS Entry no.';
    begin
        POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::RECEIPT_COPY);
        POSAuditLog.SetAutoCalcFields("Electronic Signature");
        if not POSAuditLog.FindLast() then begin
            POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
            if not POSAuditLog.FindLast() then
                exit;
        end;

        if not POSAuditLog."Electronic Signature".HasValue() then
            Error(MissingSignatureErr, POSEntry.TableCaption, POSEntry."Entry No.");

        POSAuditLog."Electronic Signature".CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(SignatureChunk);
            Signature += SignatureChunk;
        end;

        LinePrintMgt.AddTextField(1, Align, Format(POSAuditLog."Log Timestamp", 0, 3));
        LinePrintMgt.AddTextField(1, Align, CopyStr(Signature, 3, 1) + CopyStr(Signature, 7, 1) + CopyStr(Signature, 13, 1) + CopyStr(Signature, 19, 1));
        LinePrintMgt.AddTextField(1, Align, StrSubstNo(CertificationReferenceLbl, FRAuditMgt.GetCertificationNumber()));
        LinePrintMgt.AddTextField(1, Align, FRAuditMgt.GetFiscalVersion());
    end;

    local procedure AddSeparator()
    begin
        _Printer.SetPadChar('-');
        _Printer.AddLine('', 0);
    end;

    local procedure Divide(Numerator: Decimal; Denominator: Decimal): Decimal
    begin
        //Mirrors the print template field operator, which falls back to the numerator instead of failing on a zero divisor.
        if Denominator = 0 then
            exit(Numerator);
        exit(Numerator / Denominator);
    end;

    local procedure FormatAmt(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Standard Format,2>'));
    end;

    local procedure FormatQty(Quantity: Decimal): Text
    begin
        exit(Format(Quantity, 0, '<Precision,0:5><Standard Format,0>'));
    end;
}
