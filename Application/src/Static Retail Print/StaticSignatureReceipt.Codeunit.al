codeunit 6248664 "NPR Static Signature Receipt"
{
    Access = Internal;
    TableNo = "NPR POS Entry";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);

        AddReceiptInformation(Rec);

        Printer.ProcessBuffer(Codeunit::"NPR Static Signature Receipt", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    internal procedure AddReceiptInformation(POSEntry: Record "NPR POS Entry")
    var
        RetailLogo: Record "NPR Retail Logo";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        Customer: Record Customer;
        Contact: Record Contact;
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ItemVariant: Record "Item Variant";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSTicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
        EntryTaxLineAdded: Boolean;
        LogoFontLbl: Label 'Logo', Locked = true;
        ReceiptLogoLbl: Label 'RECEIPT', Locked = true;
        A11FontLbl: Label 'A11', Locked = true;
        B21FontLbl: Label 'B21', Locked = true;
        Code128FontLbl: Label 'CODE128', Locked = true;
        QRFontLbl: Label 'QR', Locked = true;
        PhoneNoLbl: Label 'Phone No.';
        VATRegistrationNoLbl: Label 'VAT Registration No.';
        EMailLbl: Label 'E-Mail: ';
        HomePageLbl: Label 'Home Page: ';
        CopyLbl: Label '*** COPY ***';
        DescritptionLbl: Label 'Description';
        QuantityLbl: Label 'Quantity';
        AmountLbl: Label 'Amount';
        LineDiscountLbl: Label 'Line Discount';
        IncludingVATLbl: Label 'Including VAT';
        TotalLbl: Label 'Total';
        CustomerSignatureLbl: Label 'Customer Signature';
    begin
        if not ShouldPrintSignatureReceipt(POSEntry) then
            exit;

        Printer.SetFont(A11FontLbl);

        // Logo section
        RetailLogo.SetRange("Register No.", POSUnit.GetCurrentPOSUnit());
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        if RetailLogo.FindFirst() then begin
            Printer.SetFont(LogoFontLbl);
            Printer.AddLine(ReceiptLogoLbl, 1);
            Printer.SetFont(A11FontLbl);
        end;

        // POS Store information
        if POSStore.Get(POSEntry."POS Store Code") then begin
            if POSStore.Name <> '' then begin
                Printer.SetBold(true);
                Printer.SetPadChar(' ');
                Printer.AddLine(POSStore.Name, 1);
                Printer.SetBold(false);
            end;

            if POSStore.Address <> '' then
                Printer.AddLine(POSStore.Address, 1);

            if POSStore."Address 2" <> '' then
                Printer.AddLine(POSStore."Address 2", 1);

            if (POSStore."Post Code" <> '') or (POSStore.City <> '') then
                Printer.AddLine(POSStore."Post Code" + ' ' + POSStore.City, 1);

            if POSStore."Phone No." <> '' then
                Printer.AddLine(PhoneNoLbl + POSStore."Phone No.", 1);

            if POSStore."VAT Registration No." <> '' then
                Printer.AddLine(VATRegistrationNoLbl + POSStore."VAT Registration No.", 1);

            if POSStore."E-Mail" <> '' then
                Printer.AddLine(EMailLbl + POSStore."E-Mail", 1);

            if POSStore."Home Page" <> '' then
                Printer.AddLine(HomePageLbl + POSStore."Home Page", 1);
        end;

        // Copy receipt label
        POSEntryOutputLog.SetRange("POS Entry No.", POSEntry."Entry No.");
        //POS Entry Output Log is inserted after printing receipt, therefore this check
        if not POSEntryOutputLog.IsEmpty() then begin
            Printer.SetFont(B21FontLbl);
            Printer.AddLine(CopyLbl, 1);
            Printer.SetFont(A11FontLbl);
        end;

        // Customer information
        if Customer.Get(POSEntry."Customer No.") then begin
            if Customer."Customer Price Group" <> '' then
                Printer.AddLine(Customer."Customer Price Group", 0);

            if Customer.Name <> '' then
                Printer.AddLine(Customer.Name, 0);

            if Customer.Address <> '' then
                Printer.AddLine(Customer.Address, 0);

            if (Customer."Post Code" <> '') or (Customer.City <> '') then
                Printer.AddLine(Customer."Post Code" + Customer.City, 0);
        end;

        // Contact information
        if Contact.Get(POSEntry."Contact No.") then begin
            if Contact.Name <> '' then
                Printer.AddLine(Contact.Name, 0);

            if Contact.Address <> '' then
                Printer.AddLine(Contact.Address, 0);

            if (Contact."Post Code" <> '') or (Contact.City <> '') then
                Printer.AddLine(Contact."Post Code" + Contact.City, 0);
        end;

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        // Bold descritpion, qty. and amount labels
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, DescritptionLbl);
        Printer.AddTextField(2, 0, QuantityLbl);
        Printer.AddTextField(3, 2, AmountLbl);
        Printer.SetBold(false);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        // Sale Lines
        POSEntrySalesLine.SetLoadFields("No.", Description, Type, "Variant Code", Quantity, "Unit Price", "Amount Incl. VAT", "Line Discount Amount Incl. VAT", "Line Discount %");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntrySalesLine.FindSet() then
            repeat
                case POSEntrySalesLine.Type of
                    POSEntrySalesLine.Type::Item:
                        begin
                            Printer.AddLine(POSEntrySalesLine.Description, 0);

                            if POSEntrySalesLine."Variant Code" <> '' then
                                if ItemVariant.Get(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code") then
                                    Printer.AddLine(ItemVariant."Description 2", 0);

                            Printer.AddTextField(1, 0, ' ' + POSEntrySalesLine."No.");
                            Printer.AddTextField(2, 0, Format(POSEntrySalesLine.Quantity) + 'x' + Format(POSEntrySalesLine."Unit Price", 0, '<Precision,2:2><Standard Format,2>'));
                            Printer.AddTextField(3, 2, Format(POSEntrySalesLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));

                            if POSEntrySalesLine."Line Discount Amount Incl. VAT" <> 0 then begin
                                Printer.AddTextField(1, 0, ' ' + LineDiscountLbl);
                                Printer.AddTextField(2, 0, Format(-POSEntrySalesLine."Line Discount Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
                                Printer.AddTextField(3, 0, '');
                            end;
                        end;
                    POSEntrySalesLine.Type::Comment:
                        Printer.AddLine(POSEntrySalesLine.Description, 0);
                    POSEntrySalesLine.Type::Customer,
                    POSEntrySalesLine.Type::"G/L Account",
                    POSEntrySalesLine.Type::Payout:
                        begin
                            Printer.AddTextField(1, 0, POSEntrySalesLine.Description);
                            Printer.AddTextField(2, 0, '');
                            Printer.AddTextField(3, 2, Format(POSEntrySalesLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
                        end;
                    POSEntrySalesLine.Type::Voucher:
                        begin
                            Printer.AddTextField(1, 0, POSEntrySalesLine.Description);
                            Printer.AddTextField(2, 0, Format(POSEntrySalesLine.Quantity) + 'x' + Format(POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                            Printer.AddTextField(3, 2, Format(POSEntrySalesLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
                        end;
                end;
            until POSEntrySalesLine.Next() = 0;

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        // Tax lines
        POSEntryTaxLine.SetLoadFields("VAT Identifier", "Tax Amount");
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryTaxLine.FindSet() then
            repeat
                if POSEntryTaxLine."Tax Amount" <> 0 then begin
                    if POSEntryTaxLine."VAT Identifier" <> '' then
                        Printer.AddTextField(1, 0, POSEntryTaxLine."VAT Identifier")
                    else
                        Printer.AddTextField(1, 0, IncludingVATLbl);
                    Printer.AddTextField(2, 0, '');
                    Printer.AddTextField(3, 2, Format(POSEntryTaxLine."Tax Amount", 0, '<Precision,2:2><Standard Format,2>'));
                    EntryTaxLineAdded := true;
                end;
            until POSEntryTaxLine.Next() = 0;

        if EntryTaxLineAdded then begin
            Printer.SetPadChar('-');
            Printer.AddLine('', 0);
        end;

        // Total line
        if GeneralLedgerSetup.Get() then;
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, TotalLbl + ' ' + GeneralLedgerSetup."LCY Code");
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, Format(POSEntry."Amount Incl. Tax", 0, '<Precision,2:2><Standard Format,2>'));
        Printer.SetBold(false);

        // Payment lines
        POSEntryPaymentLine.SetLoadFields(Description, "Payment Amount");
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryPaymentLine.FindSet() then
            repeat
                Printer.AddTextField(1, 0, POSEntryPaymentLine.Description);
                Printer.AddTextField(2, 0, '');
                Printer.AddTextField(3, 2, Format(POSEntryPaymentLine."Payment Amount", 0, '<Precision,2:2><Standard Format,2>'));
            until POSEntryPaymentLine.Next() = 0;

        //Rounding lines
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetLoadFields(Description, "Amount Incl. VAT");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Rounding);
        if POSEntrySalesLine.FindSet() then
            repeat
                Printer.AddTextField(1, 0, POSEntrySalesLine.Description);
                Printer.AddTextField(2, 0, '');
                Printer.AddTextField(3, 2, Format(POSEntrySalesLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
            until POSEntrySalesLine.Next() = 0;

        // Barcode line
        if POSUnit.Get(POSEntry."POS Unit No.") and POSReceiptProfile.Get(POSUnit."POS Receipt Profile") and POSReceiptProfile."Show Barcode as QR Code" then begin
            Printer.SetFont(QRFontLbl);
            Printer.AddBarcode(QRFontLbl, POSEntry."Document No.", 15, false, 0);
        end else begin
            Printer.SetFont(Code128FontLbl);
            Printer.AddBarcode(Code128FontLbl, POSEntry."Document No.", 3, false, 0);
        end;

        Printer.SetFont(A11FontLbl);
        Printer.AddLine('', 0);

        // Receipt footer text
        if POSUnitRcptTxtProfile.Get(POSUnit."POS Unit Receipt Text Profile") then begin
            POSTicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitRcptTxtProfile.Code);
            if POSTicketRcptText.FindSet() then
                repeat
                    Printer.AddLine(POSTicketRcptText."Receipt Text", 1);
                until POSTicketRcptText.Next() = 0;
        end;

        // Signature part
        Printer.AddLine('', 0);
        Printer.SetPadChar('_');
        Printer.AddLine('Name ', 0);
        Printer.AddLine('', 0);
        Printer.SetPadChar('_');
        Printer.AddLine('Address ', 0);
        Printer.AddLine('', 0);
        Printer.SetPadChar('_');
        Printer.AddLine('', 0);
        Printer.SetPadChar('');
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.SetPadChar('_');
        Printer.AddLine('', 0);
        Printer.AddLine(CustomerSignatureLbl, 1);
        Printer.AddLine('', 0);

        // Receipt date and time info
        Printer.AddLine(Format(POSEntry."Entry Date") + ' ' + Format(POSEntry."Ending Time") + ' - ' + POSEntry."Document No." + ' / ' + POSEntry."POS Unit No.", 1);

        // Salesperson info
        if SalespersonPurchaser.Get(POSEntry."Salesperson Code") then
            Printer.AddLine(SalespersonPurchaser.Code + ' / ' + SalespersonPurchaser.Name, 1);

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;

    local procedure ShouldPrintSignatureReceipt(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        // Check for return line
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.SetFilter(Quantity, '<%1', 0);
        if not POSEntrySalesLine.IsEmpty() then
            exit(true);

        // Check for Payout
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Payout);
        if not POSEntrySalesLine.IsEmpty() then
            exit(true);

        // Check for Customer
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Customer);
        if not POSEntrySalesLine.IsEmpty() then
            exit(true);

        // Check if any G/L Accounts are not an EFT Surcharge Account on any POS Payment Method
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetLoadFields("No.");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::"G/L Account");
        if POSEntrySalesLine.FindSet() then
            repeat
                POSPaymentMethod.SetRange("EFT Surcharge Account No.", POSEntrySalesLine."No.");
                if POSPaymentMethod.IsEmpty() then
                    exit(true);
            until POSEntrySalesLine.Next() = 0;

        exit(false);
    end;
}
