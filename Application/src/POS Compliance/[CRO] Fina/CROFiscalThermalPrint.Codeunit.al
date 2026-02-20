codeunit 6151584 "NPR CRO Fiscal Thermal Print"
{
    Access = Internal;

    var
        PaidLbl: Label 'PLAĆENO:', Locked = true;
        ToPayLbl: Label 'ZA PLATITI €', Locked = true;
        ItemLbl: Label 'Artikal', Locked = true;
        AmountLbl: Label 'Iznos €', Locked = true;
        PriceLbl: Label 'Cijena', Locked = true;
        QuantityUOMLbl: Label 'Količina JM', Locked = true;
        DiscountLbl: Label 'Popust', Locked = true;
        VATRegNoLbl: Label 'OIB: %1', Locked = true;
        VATLbl: Label 'PDV', Locked = true;
        VATBaseLbl: Label 'Osnovica', Locked = true;
        VATPercLbl: Label 'Porez', Locked = true;
        CustomerLbl: Label 'Kupac:', Locked = true;

    #region CRO Fiscal Thermal Print - Receipt Print
    internal procedure PrintReceipt(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        Printer: Codeunit "NPR RP Line Print";
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);

        case CROPOSAuditLogAuxInfo."Audit Entry Type" of
            "NPR CRO Audit Entry Type"::"POS Entry":
                AddPOSReceiptInformation(Printer, CROPOSAuditLogAuxInfo);
            "NPR CRO Audit Entry Type"::"Sales Invoice":
                AddSalesInvoiceReceiptInformation(Printer, CROPOSAuditLogAuxInfo);
            "NPR CRO Audit Entry Type"::"Sales Credit Memo":
                AddSalesCrMemoReceiptInformation(Printer, CROPOSAuditLogAuxInfo);
        end;

        TempPrinterDeviceSettings.Init();
        TempPrinterDeviceSettings.Name := 'ENCODING';
        TempPrinterDeviceSettings.Value := 'PC852';
        TempPrinterDeviceSettings.Insert();

        Papercut(Printer);

        Commit(); // Required for mPOS printing (RunModal flow)
        Printer.ProcessBuffer(Codeunit::"NPR CRO Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);

        CROPOSAuditLogAuxInfo."Receipt Printed" := true;
        CROPOSAuditLogAuxInfo.Modify();
    end;

    local procedure AddPOSReceiptInformation(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(CROPOSAuditLogAuxInfo."POS Entry No.");

        AddHeaderSection(Printer, CROPOSAuditLogAuxInfo);

        if CROPOSAuditLogAuxInfo."Collect in Store" then
            AddCollectInStorePOSSaleContentSection(Printer, CROPOSAuditLogAuxInfo, POSEntry)
        else begin
            AddPOSEntrySalesLinesInformation(Printer, CROPOSAuditLogAuxInfo."POS Entry No.");
            AddPOSTotalInformation(Printer, POSEntry);
            AddPOSTaxInformation(Printer, CROPOSAuditLogAuxInfo."POS Entry No.");
            AddPaymentMethodInformation(Printer, CROPOSAuditLogAuxInfo);
            AddPOSPaymentInformation(Printer, CROPOSAuditLogAuxInfo."POS Entry No.");
        end;

        AddLoyaltyInformation(Printer, CROPOSAuditLogAuxInfo);

        AddFooterSection(Printer, CROPOSAuditLogAuxInfo);
    end;

    local procedure AddSalesInvoiceReceiptInformation(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    begin
        AddHeaderSection(Printer, CROPOSAuditLogAuxInfo);

        AddSalesInvoiceContentSection(Printer, CROPOSAuditLogAuxInfo);

        AddLoyaltyInformation(Printer, CROPOSAuditLogAuxInfo);

        AddFooterSection(Printer, CROPOSAuditLogAuxInfo);
    end;

    local procedure AddSalesCrMemoReceiptInformation(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    begin
        AddHeaderSection(Printer, CROPOSAuditLogAuxInfo);

        AddSalesCreditMemoContentSection(Printer, CROPOSAuditLogAuxInfo);

        AddLoyaltyInformation(Printer, CROPOSAuditLogAuxInfo);

        AddFooterSection(Printer, CROPOSAuditLogAuxInfo);
    end;
    #endregion

    #region CRO Fiscal Thermal Print - POS Sections Printing
    local procedure AddCollectInStorePOSSaleContentSection(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; POSEntry: Record "NPR POS Entry")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        PostedSalesInvoiceNo: Code[20];
        SalesOrderNo: Code[20];
        DictKey: Decimal;
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        PostedSalesInvoices: List of [Code[20]];
        SalesOrders: List of [Code[20]];
        DictKeysList: List of [Decimal];
    begin
        AddPOSEntrySalesLinesInformation(Printer, CROPOSAuditLogAuxInfo."POS Entry No.");
        AddPOSTotalInformation(Printer, POSEntry);
        AddPOSTaxInformation(Printer, CROPOSAuditLogAuxInfo."POS Entry No.");

        NpCsCollectMgt.FindDocumentsForDeliveredCollectInStoreDocument(CROPOSAuditLogAuxInfo."POS Entry No.", PostedSalesInvoices, SalesOrders);

        foreach SalesOrderNo in SalesOrders do begin
            SalesLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "VAT %", "Amount Including VAT", "VAT Base Amount", "Line Discount Amount");
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange("Document No.", SalesOrderNo);
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.FindSet() then begin
                SalesHeader.SetLoadFields("Prices Including VAT", "Currency Code");
                SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo);

                repeat
                    PrintLine(Printer, SalesLine."No." + ' ' + SalesLine.Description, 0, false);
                    Printer.AddTextField(1, 0, FormatDecimal(SalesLine.Quantity) + ' ' + SalesLine."Unit of Measure Code");
                    Printer.AddTextField(2, 2, FormatDecimal(GetUnitPriceInclVAT(SalesHeader."Prices Including VAT", SalesLine."Unit Price", SalesLine."VAT %", SalesHeader."Currency Code")));
                    Printer.AddTextField(3, 2, FormatDecimal(SalesLine."Amount Including VAT"));

                    if SalesLine."Line Discount Amount" <> 0 then begin
                        Printer.AddTextField(1, 0, DiscountLbl);
                        Printer.AddTextField(2, 2, FormatDecimal(-SalesLine."Line Discount Amount"));
                        Printer.AddTextField(3, 0, '');
                    end;

                    AddAmountToDecimalDict(TaxableAmountDict, SalesLine."VAT %", SalesLine."VAT Base Amount");
                    AddAmountToDecimalDict(TaxAmountDict, SalesLine."VAT %", SalesLine."Amount Including VAT" - SalesLine."VAT Base Amount");
                    AddAmountToDecimalDict(AmountInclTaxDict, SalesLine."VAT %", SalesLine."Amount Including VAT");
                until SalesLine.Next() = 0
            end;
        end;

        foreach PostedSalesInvoiceNo in PostedSalesInvoices do begin
            SalesInvoiceLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "VAT %", "Amount Including VAT", "VAT Base Amount", "Line Discount Amount");
            SalesInvoiceLine.SetRange("Document No.", PostedSalesInvoiceNo);
            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
            if SalesInvoiceLine.FindSet() then begin
                SalesInvoiceHeader.SetLoadFields("Prices Including VAT", "Currency Code");
                SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");

                repeat
                    PrintLine(Printer, SalesInvoiceLine."No." + ' ' + SalesInvoiceLine.Description, 0, false);
                    Printer.AddTextField(1, 0, FormatDecimal(SalesInvoiceLine.Quantity) + ' ' + SalesInvoiceLine."Unit of Measure Code");
                    Printer.AddTextField(2, 2, FormatDecimal(GetUnitPriceInclVAT(SalesInvoiceHeader."Prices Including VAT", SalesInvoiceLine."Unit Price", SalesInvoiceLine."VAT %", SalesInvoiceHeader."Currency Code")));
                    Printer.AddTextField(3, 2, FormatDecimal(SalesInvoiceLine."Amount Including VAT"));

                    if SalesInvoiceLine."Line Discount Amount" <> 0 then begin
                        Printer.AddTextField(1, 0, DiscountLbl);
                        Printer.AddTextField(2, 2, FormatDecimal(-SalesInvoiceLine."Line Discount Amount"));
                        Printer.AddTextField(3, 0, '');
                    end;

                    AddAmountToDecimalDict(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
                    AddAmountToDecimalDict(TaxAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount");
                    AddAmountToDecimalDict(AmountInclTaxDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT");
                until SalesInvoiceLine.Next() = 0;
            end;
        end;

        PrintFullLine(Printer);

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ToPayLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, FormatDecimal(CROPOSAuditLogAuxInfo."Total Amount"));
        Printer.SetBold(false);

        PrintDottedLine(Printer);
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, VATPercLbl);
        Printer.AddTextField(2, 2, VATBaseLbl);
        Printer.AddTextField(3, 2, VATLbl);
        Printer.SetBold(false);
        PrintDottedLine(Printer);

        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do begin
            Printer.AddTextField(1, 0, Format(Round(DictKey, 0.1)) + '%');
            Printer.AddTextField(2, 2, FormatDecimal(TaxableAmountDict.Get(DictKey)));
            Printer.AddTextField(3, 2, FormatDecimal(TaxAmountDict.Get(DictKey)));
        end;

        PrintFullLine(Printer);

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, PaidLbl);
        Printer.AddTextField(2, 0, Format(CROPOSAuditLogAuxInfo."Payment Method"));
        Printer.AddTextField(3, 2, FormatDecimal(CROPOSAuditLogAuxInfo."Total Amount"));
        Printer.SetBold(false);
    end;

    local procedure AddPOSEntrySalesLinesInformation(var Printer: Codeunit "NPR RP Line Print"; POSEntryNo: Integer)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        PrintDottedLine(Printer);
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ItemLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 0, '');

        Printer.AddTextField(1, 0, QuantityUOMLbl);
        Printer.AddTextField(2, 2, PriceLbl);
        Printer.AddTextField(3, 2, AmountLbl);
        Printer.SetBold(false);
        PrintDottedLine(Printer);

        POSEntrySalesLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Amount Incl. VAT", "Line Discount Amount Incl. VAT");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        if POSEntrySalesLine.FindSet() then
            repeat
                PrintLine(Printer, POSEntrySalesLine."No." + ' ' + POSEntrySalesLine.Description, 0, false);
                Printer.AddTextField(1, 0, FormatDecimal(POSEntrySalesLine.Quantity) + ' ' + POSEntrySalesLine."Unit of Measure Code");
                Printer.AddTextField(2, 2, FormatDecimal(Abs(POSEntrySalesLine."Unit Price")));
                Printer.AddTextField(3, 2, FormatDecimal(POSEntrySalesLine."Amount Incl. VAT"));

                if POSEntrySalesLine."Line Discount Amount Incl. VAT" <> 0 then begin
                    Printer.AddTextField(1, 0, DiscountLbl);
                    Printer.AddTextField(2, 2, FormatDecimal(-POSEntrySalesLine."Line Discount Amount Incl. VAT"));
                    Printer.AddTextField(3, 0, '');
                end;
            until POSEntrySalesLine.Next() = 0;

        PrintFullLine(Printer);
    end;

    local procedure AddPOSTotalInformation(var Printer: Codeunit "NPR RP Line Print"; POSEntry: Record "NPR POS Entry")
    begin
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ToPayLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, FormatDecimal(POSEntry."Amount Incl. Tax"));

        if POSEntry."Discount Amount Incl. VAT" <> 0 then begin
            Printer.AddTextField(1, 0, DiscountLbl);
            Printer.AddTextField(2, 0, '');
            Printer.AddTextField(3, 2, FormatDecimal(POSEntry."Discount Amount Incl. VAT"));
        end;

        Printer.SetBold(false);
    end;

    local procedure AddPOSTaxInformation(var Printer: Codeunit "NPR RP Line Print"; POSEntryNo: Integer)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        PrintDottedLine(Printer);
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, VATPercLbl);
        Printer.AddTextField(2, 2, VATBaseLbl);
        Printer.AddTextField(3, 2, VATLbl);
        Printer.SetBold(false);
        PrintDottedLine(Printer);

        POSEntryTaxLine.SetLoadFields("Tax %", "Tax Base Amount", "Tax Amount");
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryTaxLine.FindSet() then
            repeat
                Printer.AddTextField(1, 0, FormatDecimal(Abs(POSEntryTaxLine."Tax %")) + '%');
                Printer.AddTextField(2, 2, FormatDecimal(Abs(POSEntryTaxLine."Tax Base Amount")));
                Printer.AddTextField(3, 2, FormatDecimal(Abs(POSEntryTaxLine."Tax Amount")));
            until POSEntryTaxLine.Next() = 0;
    end;

    local procedure AddPOSPaymentInformation(var Printer: Codeunit "NPR RP Line Print"; POSEntryNo: Integer)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLine.SetLoadFields(Description, Amount);
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryPaymentLine.FindSet() then
            repeat
                PrintLine(Printer, POSEntryPaymentLine.Description, 0, false);
                Printer.AddTextField(1, 0, '');
                Printer.AddTextField(2, 0, '');
                Printer.AddTextField(3, 2, FormatDecimal(POSEntryPaymentLine.Amount));
            until POSEntryPaymentLine.Next() = 0;

        PrintFullLine(Printer);
    end;
    #endregion

    #region CRO Fiscal Thermal Print - Sales Invoice Sections Printing
    local procedure AddSalesInvoiceContentSection(var Printer: Codeunit "NPR RP Line Print"; CROPOSAudLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PaymentMethod: Record "Payment Method";
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        DictKey: Decimal;
        TotalLineDiscount: Decimal;
    begin
        SalesInvoiceHeader.Get(CROPOSAudLogAuxInfo."Source Document No.");
        SalesInvoiceHeader.CalcFields("Amount Including VAT");

        PrintDottedLine(Printer);
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ItemLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 0, '');

        Printer.AddTextField(1, 0, QuantityUOMLbl);
        Printer.AddTextField(2, 2, PriceLbl);
        Printer.AddTextField(3, 2, AmountLbl);
        Printer.SetBold(false);
        PrintDottedLine(Printer);

        SalesInvoiceLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "VAT %", "Amount Including VAT", "VAT Base Amount", "Line Discount Amount");
        SalesInvoiceLine.SetRange("Document No.", CROPOSAudLogAuxInfo."Source Document No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                PrintLine(Printer, SalesInvoiceLine."No." + ' ' + SalesInvoiceLine.Description, 0, false);
                Printer.AddTextField(1, 0, FormatDecimal(SalesInvoiceLine.Quantity) + ' ' + SalesInvoiceLine."Unit of Measure Code");
                Printer.AddTextField(2, 2, FormatDecimal(Abs(GetUnitPriceInclVAT(SalesInvoiceHeader."Prices Including VAT", SalesInvoiceLine."Unit Price", SalesInvoiceLine."VAT %", SalesInvoiceHeader."Currency Code"))));
                Printer.AddTextField(3, 2, FormatDecimal(SalesInvoiceLine."Amount Including VAT"));

                if SalesInvoiceLine."Line Discount Amount" <> 0 then begin
                    Printer.AddTextField(1, 0, DiscountLbl);
                    Printer.AddTextField(2, 2, FormatDecimal(-SalesInvoiceLine."Line Discount Amount"));
                    Printer.AddTextField(3, 0, '');
                    TotalLineDiscount += SalesInvoiceLine."Line Discount Amount";
                end;

                AddAmountToDecimalDict(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
                AddAmountToDecimalDict(TaxAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount");
            until SalesInvoiceLine.Next() = 0;

        PrintFullLine(Printer);

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ToPayLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, FormatDecimal(SalesInvoiceHeader."Amount Including VAT"));

        if TotalLineDiscount <> 0 then begin
            Printer.AddTextField(1, 0, DiscountLbl);
            Printer.AddTextField(2, 0, '');
            Printer.AddTextField(3, 2, FormatDecimal(TotalLineDiscount));
        end;

        Printer.SetBold(false);

        PrintDottedLine(Printer);
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, VATPercLbl);
        Printer.AddTextField(2, 2, VATBaseLbl);
        Printer.AddTextField(3, 2, VATLbl);
        Printer.SetBold(false);
        PrintDottedLine(Printer);

        foreach DictKey in TaxableAmountDict.Keys() do begin
            Printer.AddTextField(1, 0, Format(Round(DictKey, 0.1)) + '%');
            Printer.AddTextField(2, 2, FormatDecimal(TaxableAmountDict.Get(DictKey)));
            Printer.AddTextField(3, 2, FormatDecimal(TaxAmountDict.Get(DictKey)));
        end;

        AddPaymentMethodInformation(Printer, CROPOSAudLogAuxInfo);

        if PaymentMethod.Get(SalesInvoiceHeader."Payment Method Code") then begin
            PrintLine(Printer, PaymentMethod.Description, 0, false);
            Printer.AddTextField(1, 0, '');
            Printer.AddTextField(2, 0, '');
            Printer.AddTextField(3, 2, FormatDecimal(SalesInvoiceHeader."Amount Including VAT"));

            PrintFullLine(Printer);
        end;
    end;
    #endregion

    #region CRO Fiscal Thermal Print - Sales Credit Memo Sections Printing
    local procedure AddSalesCreditMemoContentSection(var Printer: Codeunit "NPR RP Line Print"; CROPOSAudLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        DictKey: Decimal;
        TotalLineDiscount: Decimal;
    begin
        SalesCrMemoHeader.Get(CROPOSAudLogAuxInfo."Source Document No.");
        SalesCrMemoHeader.CalcFields("Amount Including VAT");

        PrintDottedLine(Printer);
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ItemLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 0, '');

        Printer.AddTextField(1, 0, QuantityUOMLbl);
        Printer.AddTextField(2, 2, PriceLbl);
        Printer.AddTextField(3, 2, AmountLbl);
        Printer.SetBold(false);
        PrintDottedLine(Printer);

        SalesCrMemoLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "VAT %", "Amount Including VAT", "VAT Base Amount", "Line Discount Amount");
        SalesCrMemoLine.SetRange("Document No.", CROPOSAudLogAuxInfo."Source Document No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if SalesCrMemoLine.FindSet() then
            repeat
                PrintLine(Printer, SalesCrMemoLine."No." + ' ' + SalesCrMemoLine.Description, 0, false);
                Printer.AddTextField(1, 0, FormatDecimal(-SalesCrMemoLine.Quantity) + ' ' + SalesCrMemoLine."Unit of Measure Code");
                Printer.AddTextField(2, 2, FormatDecimal(Abs(GetUnitPriceInclVAT(SalesCrMemoHeader."Prices Including VAT", SalesCrMemoLine."Unit Price", SalesCrMemoLine."VAT %", SalesCrMemoHeader."Currency Code"))));
                Printer.AddTextField(3, 2, FormatDecimal(-SalesCrMemoLine."Amount Including VAT"));

                if SalesCrMemoLine."Line Discount Amount" <> 0 then begin
                    Printer.AddTextField(1, 0, DiscountLbl);
                    Printer.AddTextField(2, 2, FormatDecimal(-SalesCrMemoLine."Line Discount Amount"));
                    Printer.AddTextField(3, 0, '');
                    TotalLineDiscount += SalesCrMemoLine."Line Discount Amount";
                end;

                AddAmountToDecimalDict(TaxableAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."VAT Base Amount");
                AddAmountToDecimalDict(TaxAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine."VAT Base Amount");
            until SalesCrMemoLine.Next() = 0;

        PrintFullLine(Printer);

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ToPayLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, FormatDecimal(SalesCrMemoHeader."Amount Including VAT"));

        if TotalLineDiscount <> 0 then begin
            Printer.AddTextField(1, 0, DiscountLbl);
            Printer.AddTextField(2, 0, '');
            Printer.AddTextField(3, 2, FormatDecimal(TotalLineDiscount));
        end;


        Printer.SetBold(false);
        PrintDottedLine(Printer);

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, VATPercLbl);
        Printer.AddTextField(2, 2, VATBaseLbl);
        Printer.AddTextField(3, 2, VATLbl);

        Printer.SetBold(false);
        PrintDottedLine(Printer);

        foreach DictKey in TaxableAmountDict.Keys() do begin
            Printer.AddTextField(1, 0, Format(Round(DictKey, 0.1)) + '%');
            Printer.AddTextField(2, 2, FormatDecimal(TaxableAmountDict.Get(DictKey)));
            Printer.AddTextField(3, 2, FormatDecimal(TaxAmountDict.Get(DictKey)));
        end;

        AddPaymentMethodInformation(Printer, CROPOSAudLogAuxInfo);
    end;
    #endregion

    #region CRO Fiscal Thermal Print - Base Section Printing

    local procedure AddHeaderSection(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CompanyInformation: Record "Company Information";
        RetailLogo: Record "NPR Retail Logo";
        POSStore: Record "NPR POS Store";
        Customer: Record Customer;
        FiscalBillCopyLbl: Label 'OVO JE KOPIJA FISKALNOG RACUNA', Locked = true;
        FiscalBillNoLbl: Label 'Račun %1/%2/%3', Locked = true;
        InternalBillNoLbl: Label 'Interni broj računa: %1', Locked = true;
        FiscalBillDateTimeLbl: Label 'Vrijeme izdavanja: %1 %2', Locked = true;
        AddressLine: Text;
    begin
        // Logo section
        RetailLogo.SetRange("Register No.", CROPOSAuditLogAuxInfo."POS Unit No.");
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        if RetailLogo.FindFirst() then
            PrintLogo(Printer, RetailLogo.Keyword);

        // Company information section
        CompanyInformation.Get();
        PrintLine(Printer, CompanyInformation.Name, 0, true);
        AddressLine := FormatAddress(CompanyInformation.Address, CompanyInformation."Post Code", CompanyInformation.City);
        if AddressLine <> '' then
            PrintLine(Printer, AddressLine, 0, false);
        Clear(AddressLine);

        // POS Store information section
        POSStore.Get(CROPOSAuditLogAuxInfo."POS Store Code");
        PrintLine(Printer, POSStore.Name, 0, false);
        AddressLine := FormatAddress(POSStore.Address, POSStore."Post Code", POSStore.City);
        if AddressLine <> '' then
            PrintLine(Printer, AddressLine, 0, false);
        Clear(AddressLine);

        CROFiscalizationSetup.Get();
        PrintLine(Printer, StrSubstNo(VATRegNoLbl, CROFiscalizationSetup."Certificate Subject OIB"), 0, false);
        PrintFullLine(Printer);

        // Fiscal bill copy section
        if CROPOSAuditLogAuxInfo."Receipt Printed" then begin
            PrintLine(Printer, FiscalBillCopyLbl, 0, true);
            PrintFullLine(Printer);
        end;

        // Bill information section
        PrintLine(Printer, StrSubstNo(FiscalBillNoLbl, CROPOSAuditLogAuxInfo."Bill No.", CROPOSAuditLogAuxInfo."POS Store Code", CROPOSAuditLogAuxInfo."POS Unit No."), 0, true);
        PrintLine(Printer, StrSubstNo(InternalBillNoLbl, CROPOSAuditLogAuxInfo."Source Document No."), 0, true);
        PrintLine(Printer, StrSubstNo(FiscalBillDateTimeLbl, FormatDate(CROPOSAuditLogAuxInfo."Entry Date"), FormatTime(CROPOSAuditLogAuxInfo."Log Timestamp")), 0, true);
        AddSalespersonName(Printer, CROPOSAuditLogAuxInfo);
        PrintFullLine(Printer);

        // Customer information section
        if CROPOSAuditLogAuxInfo."Customer No." <> '' then begin
            if Customer.Get(CROPOSAuditLogAuxInfo."Customer No.") then begin
                PrintNewLine(Printer);
                PrintLine(Printer, CustomerLbl, 0, true);
                PrintLine(Printer, Customer.Name, 0, false);
                AddressLine := FormatAddress(Customer.Address, Customer."Post Code", Customer.City);
                if AddressLine <> '' then
                    PrintLine(Printer, AddressLine, 0, false);
                Clear(AddressLine);

                if Customer."VAT Registration No." <> '' then
                    PrintLine(Printer, StrSubstNo(VATRegNoLbl, Customer."VAT Registration No."), 0, false);
            end
        end;
    end;

    local procedure AddSalespersonName(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        POSEntry: Record "NPR POS Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonNameLbl: Label 'Izdao: %1', Comment = '%1 = Salesperson Name', Locked = true;
    begin
        case CROPOSAuditLogAuxInfo."Audit Entry Type" of
            "NPR CRO Audit Entry Type"::"POS Entry":
                begin
                    POSEntry.Get(CROPOSAuditLogAuxInfo."POS Entry No.");
                    if SalespersonPurchaser.Get(POSEntry."Salesperson Code") then
                        PrintLine(Printer, StrSubstNo(SalespersonNameLbl, SalespersonPurchaser.Name), 0, true);
                end;
            "NPR CRO Audit Entry Type"::"Sales Invoice":
                begin
                    SalesInvoiceHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.");
                    if SalespersonPurchaser.Get(SalesInvoiceHeader."Salesperson Code") then
                        PrintLine(Printer, StrSubstNo(SalespersonNameLbl, SalespersonPurchaser.Name), 0, true);
                end;
            "NPR CRO Audit Entry Type"::"Sales Credit Memo":
                begin
                    SalesCrMemoHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.");
                    if SalespersonPurchaser.Get(SalesCrMemoHeader."Salesperson Code") then
                        PrintLine(Printer, StrSubstNo(SalespersonNameLbl, SalespersonPurchaser.Name), 0, true);
                end;
        end;
    end;

    local procedure AddFooterSection(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        JIRCodeLbl: Label 'JIR:', Locked = true;
        ZKICodeLbl: Label 'ZKI:', Locked = true;
    begin
        PrintLine(Printer, ZKICodeLbl + ' ' + CROPOSAuditLogAuxInfo."ZKI Code", 0, false);
        PrintLine(Printer, JIRCodeLbl + ' ' + CROPOSAuditLogAuxInfo."JIR Code", 0, false);

        PrintFullLine(Printer);

        PrintQRCode(Printer, CROPOSAuditLogAuxInfo."Verification URL");
    end;

    local procedure AddPaymentMethodInformation(var Printer: Codeunit "NPR RP Line Print"; CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    begin
        PrintFullLine(Printer);
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, PaidLbl);
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, Format(CROPOSAuditLogAuxInfo."Payment Method"));
        Printer.SetBold(false);
        PrintFullLine(Printer);
    end;

    local procedure AddLoyaltyInformation(var Printer: Codeunit "NPR RP Line Print"; CROPOSAudLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        MMMembersPointsEntry: Record "NPR MM Members. Points Entry";
        MMMembership: Record "NPR MM Membership";
        MMMembershipRole: Record "NPR MM Membership Role";
        MMMember: Record "NPR MM Member";
        MembershipHeadlineLbl: Label 'LOYALTY', Locked = true;
        PointsBeforeSaleLbl: Label 'Stanje bodova prije:', Locked = true;
        PointsUsedForSaleLbl: Label 'Iskorišteni bodovi:', Locked = true;
        GainedPointsOnSaleLbl: Label 'Dobiveni bodovi:', Locked = true;
        TotalMembershipPointsLbl: Label 'Novo stanje bodova:', Locked = true;
        PointsBeforeSale: Decimal;
        UsedPoints: Decimal;
        GainedPointsOnSale: Decimal;
        TotalPoints: Decimal;
    begin
        if CROPOSAudLogAuxInfo."Customer No." = '' then
            exit;

        MMMembership.SetRange("Customer No.", CROPOSAudLogAuxInfo."Customer No.");
        MMMembership.SetLoadFields("Entry No.", "Remaining Points");
        MMMembership.SetAutoCalcFields("Remaining Points");
        if not MMMembership.FindFirst() then
            exit;

        MMMembersPointsEntry.SetCurrentKey("Membership Entry No.", "Entry Type", "Posting Date");
        MMMembersPointsEntry.SetRange("Membership Entry No.", MMMembership."Entry No.");
        if CROPOSAudLogAuxInfo."Total Amount" > 0 then
            MMMembersPointsEntry.SetRange("Entry Type", MMMembersPointsEntry."Entry Type"::SALE)
        else
            MMMembersPointsEntry.SetRange("Entry Type", MMMembersPointsEntry."Entry Type"::REFUND);
        MMMembersPointsEntry.SetRange("Posting Date", CROPOSAudLogAuxInfo."Entry Date");
        MMMembersPointsEntry.SetRange("Document No.", CROPOSAudLogAuxInfo."Source Document No.");
        MMMembersPointsEntry.SetRange("Point Constraint", MMMembersPointsEntry."Point Constraint"::INCLUDE);
        MMMembersPointsEntry.CalcSums(Points);

        if Round(MMMembersPointsEntry.Points, 0.01) <> 0 then
            GainedPointsOnSale := MMMembersPointsEntry.Points;

        MMMembersPointsEntry.Reset();
        MMMembersPointsEntry.SetCurrentKey("Membership Entry No.", "Entry Type", "Posting Date");
        MMMembersPointsEntry.SetRange("Membership Entry No.", MMMembership."Entry No.");
        MMMembersPointsEntry.SetRange("Entry Type", MMMembersPointsEntry."Entry Type"::POINT_WITHDRAW);
        MMMembersPointsEntry.SetRange("Posting Date", CROPOSAudLogAuxInfo."Entry Date");
        MMMembersPointsEntry.SetRange("Document No.", CROPOSAudLogAuxInfo."Source Document No.");
        MMMembersPointsEntry.SetRange("Point Constraint", MMMembersPointsEntry."Point Constraint"::INCLUDE);
        MMMembersPointsEntry.CalcSums(Points);

        if Round(MMMembersPointsEntry.Points, 0.01) <> 0 then
            UsedPoints := Abs(MMMembersPointsEntry.Points);

        MMMembersPointsEntry.Reset();
        MMMembersPointsEntry.SetCurrentKey("Membership Entry No.", "Entry Type", "Posting Date");
        MMMembersPointsEntry.SetRange("Membership Entry No.", MMMembership."Entry No.");
        MMMembersPointsEntry.SetFilter("Posting Date", '<%1', CROPOSAudLogAuxInfo."Entry Date");
        MMMembersPointsEntry.SetRange("Point Constraint", MMMembersPointsEntry."Point Constraint"::INCLUDE);
        MMMembersPointsEntry.CalcSums(Points);

        if Round(MMMembersPointsEntry.Points, 0.01) <> 0 then
            PointsBeforeSale := MMMembersPointsEntry.Points;

        TotalPoints := MMMembership."Remaining Points";

        if (TotalPoints = 0) and (UsedPoints = 0) and (PointsBeforeSale = 0) and (GainedPointsOnSale = 0) then
            exit;

        PrintNewLine(Printer);

        MMMembershipRole.SetRange("Membership Entry No.", MMMembership."Entry No.");
        MMMembershipRole.SetRange("Member Role", MMMembershipRole."Member Role"::ADMIN);
        if MMMembershipRole.IsEmpty() then
            MMMembershipRole.SetRange("Member Role");
        if MMMembershipRole.FindFirst() then begin
            if MMMember.Get(MMMembershipRole."Member Entry No.") then begin
                PrintLine(Printer, MembershipHeadlineLbl, 0, true);
                PrintLine(Printer, MMMember."E-Mail Address", 0, true);
                PrintNewLine(Printer);
            end;
        end;

        Printer.SetBold(true);

        PrintLine(Printer, PointsBeforeSaleLbl, 0, true);
        Printer.AddTextField(1, 0, '');
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, Format(Round(PointsBeforeSale, 0.01)));

        PrintLine(Printer, PointsUsedForSaleLbl, 0, true);
        Printer.AddTextField(1, 0, '');
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, Format(Round(UsedPoints, 0.01)));

        PrintLine(Printer, GainedPointsOnSaleLbl, 0, true);
        Printer.AddTextField(1, 0, '');
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, Format(Round(GainedPointsOnSale, 0.01)));

        PrintLine(Printer, TotalMembershipPointsLbl, 0, true);
        Printer.AddTextField(1, 0, '');
        Printer.AddTextField(2, 0, '');
        Printer.AddTextField(3, 2, Format(Round(TotalPoints, 0.01)));

        Printer.SetBold(false);

        PrintFullLine(Printer);
    end;
    #endregion

    #region CRO Fiscal Thermal Print - Printing Procedures
    local procedure PrintLogo(var Printer: Codeunit "NPR RP Line Print"; Value: Text)
    var
        LogoFontLbl: Label 'Logo', Locked = true;
    begin
        Printer.SetFont(CopyStr(LogoFontLbl, 1, 30));
        Printer.AddLine(Value, 0);
    end;

    local procedure PrintLine(var Printer: Codeunit "NPR RP Line Print"; Value: Text; Alignment: Integer; Bold: Boolean)
    var
        A11FontLbl: Label 'A11', Locked = true;
    begin
        Printer.SetBold(Bold);
        Printer.SetFont(A11FontLbl);
        Printer.AddLine(Value, Alignment);

        if Bold then
            Printer.SetBold(false);
    end;

    local procedure PrintQRCode(var Printer: Codeunit "NPR RP Line Print"; Value: Text)
    var
        QRFontLbl: Label 'QR', Locked = true;
    begin
        Printer.SetFont(QRFontLbl);
        Printer.AddBarcode(QRFontLbl, Value, 5, true, 0);
    end;

    local procedure PrintDottedLine(var Printer: Codeunit "NPR RP Line Print")
    begin
        Printer.SetPadChar('-');
        Printer.AddLine('', 0);
    end;

    local procedure PrintFullLine(var Printer: Codeunit "NPR RP Line Print")
    begin
        Printer.SetPadChar('_');
        Printer.AddLine('', 0);
    end;

    local procedure PrintNewLine(var Printer: Codeunit "NPR RP Line Print")
    begin
        Printer.NewLine();
    end;

    local procedure Papercut(var Printer: Codeunit "NPR RP Line Print")
    begin
        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;
    #endregion

    #region CRO Fiscal Thermal Print - Formatting
    local procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'));
    end;

    local procedure FormatDate(Value: Date): Text
    begin
        exit(Format(Value, 0, '<Day,2>.<Month,2>.<Year4>.'));
    end;

    local procedure FormatTime(Value: Time): Text
    begin
        exit(Format(Value, 0, '<Hours24>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure FormatAddress(Address: Text; PostCode: Text; City: Text) AddressLine: Text
    begin
        if Address <> '' then
            AddressLine := Address;
        if PostCode <> '' then begin
            if AddressLine <> '' then
                AddressLine += ', ';
            AddressLine += PostCode;
        end;
        if City <> '' then begin
            if AddressLine <> '' then
                AddressLine += ' ';
            AddressLine += City;
        end;
    end;
    #endregion

    #region CRO Fiscal Thermal Print - Helper Procedures
    local procedure AddAmountToDecimalDict(var DecimalDict: Dictionary of [Decimal, Decimal]; DictKey: Decimal; DictValue: Decimal)
    var
        BaseAmount: Decimal;
    begin
        if DecimalDict.Add(DictKey, DictValue) then
            exit;
        BaseAmount := DecimalDict.Get(DictKey) + DictValue;
        DecimalDict.Set(DictKey, BaseAmount);
    end;

    local procedure GetUnitPriceInclVAT(PricesInclVAT: Boolean; UnitPrice: Decimal; VATPercentage: Decimal; CurrencyCode: Code[20]): Decimal
    var
        Currency: Record Currency;
    begin
        if PricesInclVAT then
            exit(UnitPrice);

        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else
            if not Currency.Get(CurrencyCode) then
                Currency.InitRoundingPrecision();
        exit(Round(UnitPrice * (1 + VATPercentage / 100), Currency."Amount Rounding Precision"));
    end;
    #endregion
}