codeunit 6151231 "NPR Static Sales Doc Confirm."
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
        Printer.SetThreeColumnDistribution(0.45, 0.35, 0.20);
        AddContent(Rec);
        Printer.ProcessBuffer(Codeunit::"NPR Static Sales Doc Confirm.", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddContent(POSEntry: Record "NPR POS Entry")
    var
        RetailLogo: Record "NPR Retail Logo";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        Customer: Record Customer;
        Contact: Record Contact;
        SalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        LastSalesDocType: Enum "NPR POS Sales Document Type";
        LastSalesDocNo: Code[20];
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ItemVariant: Record "Item Variant";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSTicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
        EntryTaxLineAdded: Boolean;
        LogoFontLbl: Label 'Logo', Locked = true;
        ReceiptLogoLbl: Label 'RECEIPT', Locked = true;
        A11FontLbl: Label 'A11', Locked = true;
        B22FontLbl: Label 'B22', Locked = true;
        Code128FontLbl: Label 'CODE128', Locked = true;
        QRFontLbl: Label 'QR', Locked = true;
        CopyLbl: Label '*** COPY ***';
        DocumentConfirmationLbl: Label 'DOCUMENT CONFIRMATION';
        IncludingVATLbl: Label 'Including VAT';
        QuantityLbl: Label 'Quantity';
        UnitPriceLbl: Label 'Unit Price';
        AmountLbl: Label 'Amount';
        TotalLbl: Label 'Total';
        YourReferenceLbl: Label 'Your Ref.';
        SellToContactLbl: Label 'Contact';
    begin
        Printer.SetFont(A11FontLbl);

        // Logo
        RetailLogo.SetRange("Register No.", POSEntry."POS Unit No.");
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
            if POSStore."Name 2" <> '' then
                Printer.AddLine(POSStore."Name 2", 1);
            if POSStore.Address <> '' then
                Printer.AddLine(POSStore.Address, 1);
            if POSStore."Address 2" <> '' then
                Printer.AddLine(POSStore."Address 2", 1);
            if (POSStore."Post Code" <> '') or (POSStore.City <> '') then
                Printer.AddLine(POSStore."Post Code" + ' ' + POSStore.City, 1);
            if POSStore."Phone No." <> '' then
                Printer.AddLine(POSStore.FieldCaption("Phone No.") + ': ' + POSStore."Phone No.", 1);
            if POSStore."VAT Registration No." <> '' then
                Printer.AddLine(POSStore.FieldCaption("VAT Registration No.") + ': ' + POSStore."VAT Registration No.", 1);
            if POSStore."E-Mail" <> '' then
                Printer.AddLine(POSStore.FieldCaption("E-Mail") + ': ' + POSStore."E-Mail", 1);
            if POSStore."Home Page" <> '' then
                Printer.AddLine(POSStore.FieldCaption("Home Page") + ': ' + POSStore."Home Page", 1);
        end;

        // Copy label
        POSEntryOutputLog.SetRange("POS Entry No.", POSEntry."Entry No.");
        if not POSEntryOutputLog.IsEmpty() then begin
            Printer.SetFont(B22FontLbl);
            Printer.AddLine(CopyLbl, 1);
            Printer.SetFont(A11FontLbl);
        end;

        Printer.AddLine('', 0);

        // Document confirmation header
        Printer.SetFont(B22FontLbl);
        Printer.AddLine(DocumentConfirmationLbl, 1);
        Printer.SetFont(A11FontLbl);

        PrintSeparator();

        // Customer information
        if Customer.Get(POSEntry."Customer No.") then begin
            if Customer.Name <> '' then
                Printer.AddLine(Customer.Name, 0);
            if Customer.Address <> '' then
                Printer.AddLine(Customer.Address, 0);
            if (Customer."Post Code" <> '') or (Customer.City <> '') then
                Printer.AddLine(Customer."Post Code" + ' ' + Customer.City, 0);
        end;

        // Contact information
        if Contact.Get(POSEntry."Contact No.") then begin
            if Contact.Name <> '' then
                Printer.AddLine(Contact.Name, 0);
            if Contact.Address <> '' then
                Printer.AddLine(Contact.Address, 0);
            if (Contact."Post Code" <> '') or (Contact.City <> '') then
                Printer.AddLine(Contact."Post Code" + ' ' + Contact.City, 0);
        end;

        Printer.AddLine('', 0);

        // ERP document references
        SalesDocLink.SetCurrentKey("Sales Document Type", "Sales Document No");
        SalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        if SalesDocLink.FindSet() then
            repeat
                if (SalesDocLink."Sales Document Type" <> LastSalesDocType) or (SalesDocLink."Sales Document No" <> LastSalesDocNo) then begin
                    LastSalesDocType := SalesDocLink."Sales Document Type";
                    LastSalesDocNo := SalesDocLink."Sales Document No";
                    case SalesDocLink."Sales Document Type" of
                        SalesDocLink."Sales Document Type"::QUOTE,
                        SalesDocLink."Sales Document Type"::ORDER,
                        SalesDocLink."Sales Document Type"::INVOICE,
                        SalesDocLink."Sales Document Type"::CREDIT_MEMO,
                        SalesDocLink."Sales Document Type"::BLANKET_ORDER,
                        SalesDocLink."Sales Document Type"::RETURN_ORDER:
                            if SalesHeader.Get(Enum::"Sales Document Type".FromInteger(SalesDocLink."Sales Document Type".AsInteger()), SalesDocLink."Sales Document No") then begin
                                Printer.AddLine(Format(SalesHeader."Document Type") + ': ' + SalesHeader."No.", 0);
                                if SalesHeader."Your Reference" <> '' then
                                    Printer.AddLine(YourReferenceLbl + ': ' + SalesHeader."Your Reference", 0);
                                if SalesHeader."Sell-to Contact" <> '' then
                                    Printer.AddLine(SellToContactLbl + ': ' + SalesHeader."Sell-to Contact", 0);
                            end;
                        SalesDocLink."Sales Document Type"::POSTED_INVOICE:
                            if SalesInvoiceHeader.Get(SalesDocLink."Sales Document No") then begin
                                Printer.AddLine(Format(SalesDocLink."Sales Document Type") + ': ' + SalesInvoiceHeader."No.", 0);
                                if SalesInvoiceHeader."Your Reference" <> '' then
                                    Printer.AddLine(YourReferenceLbl + ': ' + SalesInvoiceHeader."Your Reference", 0);
                                if SalesInvoiceHeader."Sell-to Contact" <> '' then
                                    Printer.AddLine(SellToContactLbl + ': ' + SalesInvoiceHeader."Sell-to Contact", 0);
                            end;
                        SalesDocLink."Sales Document Type"::SHIPMENT:
                            if SalesShipmentHeader.Get(SalesDocLink."Sales Document No") then begin
                                Printer.AddLine(Format(SalesDocLink."Sales Document Type") + ': ' + SalesShipmentHeader."No.", 0);
                                if SalesShipmentHeader."Your Reference" <> '' then
                                    Printer.AddLine(YourReferenceLbl + ': ' + SalesShipmentHeader."Your Reference", 0);
                                if SalesShipmentHeader."Sell-to Contact" <> '' then
                                    Printer.AddLine(SellToContactLbl + ': ' + SalesShipmentHeader."Sell-to Contact", 0);
                            end;
                        SalesDocLink."Sales Document Type"::RETURN_RECEIPT:
                            if ReturnReceiptHeader.Get(SalesDocLink."Sales Document No") then begin
                                Printer.AddLine(Format(SalesDocLink."Sales Document Type") + ': ' + ReturnReceiptHeader."No.", 0);
                                if ReturnReceiptHeader."Your Reference" <> '' then
                                    Printer.AddLine(YourReferenceLbl + ': ' + ReturnReceiptHeader."Your Reference", 0);
                            end;
                        SalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO:
                            if SalesCrMemoHeader.Get(SalesDocLink."Sales Document No") then begin
                                Printer.AddLine(Format(SalesDocLink."Sales Document Type") + ': ' + SalesCrMemoHeader."No.", 0);
                                if SalesCrMemoHeader."Your Reference" <> '' then
                                    Printer.AddLine(YourReferenceLbl + ': ' + SalesCrMemoHeader."Your Reference", 0);
                            end;
                    end;
                end;
            until SalesDocLink.Next() = 0;

        Printer.AddLine('', 0);

        // Column headers
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, QuantityLbl);
        Printer.AddTextField(2, 0, UnitPriceLbl);
        Printer.AddTextField(3, 2, AmountLbl);
        Printer.SetBold(false);

        PrintSeparator();

        // Sales lines
        POSEntrySalesLine.SetLoadFields("No.", Description, Type, "Variant Code", Quantity, "Amount Incl. VAT");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("Exclude from Posting", false);
        if POSEntrySalesLine.FindSet() then
            repeat
                case POSEntrySalesLine.Type of
                    POSEntrySalesLine.Type::Item:
                        begin
                            Printer.AddLine(POSEntrySalesLine.Description, 0);
                            if POSEntrySalesLine."Variant Code" <> '' then
                                if ItemVariant.Get(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code") then
                                    Printer.AddLine(ItemVariant."Description 2", 0);
                            Printer.AddTextField(1, 0, Format(POSEntrySalesLine.Quantity) + 'x');
                            if POSEntrySalesLine.Quantity <> 0 then
                                Printer.AddTextField(2, 0, FormatAmt(POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity))
                            else
                                Printer.AddTextField(2, 0, '');
                            Printer.AddTextField(3, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT"));
                        end;
                    POSEntrySalesLine.Type::Comment:
                        Printer.AddLine(POSEntrySalesLine.Description, 0);
                    POSEntrySalesLine.Type::"G/L Account",
                    POSEntrySalesLine.Type::Customer,
                    POSEntrySalesLine.Type::Payout:
                        begin
                            Printer.AddTextField(1, 0, POSEntrySalesLine.Description);
                            Printer.AddTextField(2, 0, '');
                            Printer.AddTextField(3, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT"));
                        end;
                    POSEntrySalesLine.Type::Voucher:
                        begin
                            Printer.AddLine(POSEntrySalesLine.Description, 0);
                            Printer.AddTextField(1, 0, Format(POSEntrySalesLine.Quantity) + 'x');
                            if POSEntrySalesLine.Quantity <> 0 then
                                Printer.AddTextField(2, 0, FormatAmt(POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity))
                            else
                                Printer.AddTextField(2, 0, '');
                            Printer.AddTextField(3, 2, FormatAmt(POSEntrySalesLine."Amount Incl. VAT"));
                        end;
                end;
            until POSEntrySalesLine.Next() = 0;

        PrintSeparator();

        // Tax lines
        EntryTaxLineAdded := false;
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
                    Printer.AddTextField(3, 2, FormatAmt(POSEntryTaxLine."Tax Amount"));
                    EntryTaxLineAdded := true;
                end;
            until POSEntryTaxLine.Next() = 0;

        if EntryTaxLineAdded then
            PrintSeparator();

        // Total line
        if GeneralLedgerSetup.Get() then;
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, TotalLbl + ' ' + GeneralLedgerSetup."LCY Code");
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, FormatAmt(POSEntry."Amount Incl. Tax"));
        Printer.SetBold(false);

        Printer.AddLine('', 0);

        // Barcode
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

        Printer.AddLine('', 0);

        Printer.AddLine(Format(POSEntry."Entry Date") + ' ' + Format(POSEntry."Ending Time") + ' - ' + POSEntry."Document No." + ' / ' + POSEntry."POS Unit No.", 1);

        if SalespersonPurchaser.Get(POSEntry."Salesperson Code") then
            Printer.AddLine(SalespersonPurchaser.Code + ' / ' + SalespersonPurchaser.Name, 1);

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
