report 6014554 "NPR CRO Fiscal Bill A4"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    Caption = 'CRO Fiscal Bill A4';
    DefaultLayout = Word;
    WordLayout = './src/_Reports/layouts/CROFiscalBillA4.docx';
    UsageCategory = None;

    dataset
    {
        dataitem("CRO POS Audit Log Aux Info"; "NPR CRO POS Aud. Log Aux. Info")
        {
            column(CompanyName; CompanyName) { }
            column(CompanyAddress; AddrArray[1]) { }
            column(CompanyContact; AddrArray[2]) { }
            column(CompanyWebsite; CompanyWebsite) { }
            column(CompanyCity; CompanyCity) { }
            column(LogTimeStamp; Format("Log Timestamp", 8, '<Hours24>:<Minutes,2>:<Seconds,2>')) { }
            column(EntryDate; Format("Entry Date", 0, '<Day,2>/<Month,2>/<Year4>')) { }
            column(JIRCode; "JIR Code") { }
            column(Bill; StrSubstNo(BillLbl, "Bill No.", "POS Store Code", "POS Unit No.")) { }
            column(ZKICode; "ZKI Code") { }
            column(OperatorName; OperatorName) { }
            column(QRCode; QRCode) { }
            column(TotalAmount; "Total Amount") { }
            column(CustomerPostCity; CustomerPostCity) { }
            column(CustomerName; CustomerName) { }
            column(CustomerAddress; CustomerAddress) { }
            column(CopyText; CopyText) { }
            dataitem("POS Entry Lines"; "NPR POS Entry Sales Line")
            {
                UseTemporary = true;

                column(ItemDescription; Description) { }
                column(Quantity; Quantity) { }
                column(UnitPrice; "Unit Price") { }
                column(UOM; "Unit of Measure Code") { }
                column(DiscountPerc; "Line Discount %") { }
                column(DiscountAmount; "Line Discount Amount Incl. VAT") { }
                column(AmountIncludingVAT; "Amount Incl. VAT") { }
                column(ItemNo; "No.") { }

                trigger OnPreDataItem()
                begin
                    case "CRO POS Audit Log Aux Info"."Audit Entry Type" of
                        "CRO POS Audit Log Aux Info"."Audit Entry Type"::"POS Entry":
                            FillPOSEntryRecords("CRO POS Audit Log Aux Info", "POS Entry Lines", "POS Entry Tax Lines", "POS Entry Payment Lines");
                        "CRO POS Audit Log Aux Info"."Audit Entry Type"::"Sales Credit Memo":
                            FillSalesCrMemoRecords("CRO POS Audit Log Aux Info", "POS Entry Lines", "POS Entry Tax Lines", "POS Entry Payment Lines");
                        "CRO POS Audit Log Aux Info"."Audit Entry Type"::"Sales Invoice":
                            FillSalesInvoiceRecords("CRO POS Audit Log Aux Info", "POS Entry Lines", "POS Entry Tax Lines", "POS Entry Payment Lines");
                    end;
                end;
            }
            dataitem("POS Entry Tax Lines"; "NPR POS Entry Tax Line")
            {
                UseTemporary = true;
                column(VATPerc; "Tax %") { }
                column(VATBaseAmount; "Tax Base Amount") { }
                column(VATAmount; "Tax Amount") { }
                column(AmountInclVAT; "Amount Including Tax") { }
            }
            dataitem("POS Store"; "NPR POS Store")
            {
                DataItemLink = "Code" = field("POS Store Code");

                column(StoreDetailsLine; StoreDetailsLine) { }
                column(POSStoreName; Name) { }
                column(POSStoreAddress; Address) { }
                column(POSStorePostCode; "Post Code") { }
                column(POSStoreCity; City) { }
                column(POSStoreCode; Code) { }

                trigger OnAfterGetRecord()
                begin
                    CreatePOSStoreInfo();
                end;
            }
            trigger OnPreDataItem()
            begin
                "CRO POS Audit Log Aux Info".SetRange("Audit Entry Type", _CROAuditEntryType);
                "CRO POS Audit Log Aux Info".SetRange("Audit Entry No.", _AuditEntryNo);
                "CRO POS Audit Log Aux Info".SetRange("Source Document No.", _DocumentNo);
            end;

            trigger OnAfterGetRecord()
            var
                CompanyInfo: Record "Company Information";
            begin
#IF NOT (BC17 or BC18)
                GenerateQRCode();
#ENDIF

                if CompanyInfo.Get() then begin
                    CreateCompanyInformationArray(AddrArray, CompanyInfo);
                    CompanyWebsite := CompanyInfo."Home Page";
                    CompanyName := CompanyInfo.Name;
                    CompanyCity := CompanyInfo.City;
                end;

            end;
        }
        dataitem("POS Entry Payment Lines"; "NPR POS Entry Payment Line")
        {
            UseTemporary = true;
            column(POSPaymentMethod; "POS Payment Method Code") { }
            column(Amount; "Amount (LCY)") { }
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Audit Entry Type"; _CROAuditEntryType)
                    {
                        ApplicationArea = NPRCROFiscal;
                        Caption = 'Audit Entry Type';
                        ToolTip = 'Specifies the value of the Audit Entry Type field.';
                    }
                    field("Audit Entry No."; _AuditEntryNo)
                    {
                        ApplicationArea = NPRCROFiscal;
                        Caption = 'Audit Entry No.';
                        ToolTip = 'Specifies the value of the Audit Entry No. field.';
                    }
                    field("Document No."; _DocumentNo)
                    {
                        ApplicationArea = NPRCROFiscal;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the value of the Document No. field.';
                    }
                }
            }
        }
    }
    labels
    {
        ItemNameLbl = 'NAZIV', Locked = true;
        ItemCodeLbl = 'OZNAKA', Locked = true;
        BarcodeLbl = 'BARKOD', Locked = true;
        PriceLbl = 'CIJENA', Locked = true;
        DiscountLbl = 'POPUST', Locked = true;
        DescriptionLbl = 'OPIS', Locked = true;
        QtyLbl = 'KOL', Locked = true;
        PercLbl = '%', Locked = true;
        UoMLbl = 'JEDINICA MJERE', Locked = true;
        VATLbl = 'PDV', Locked = true;
        TotalLbl = 'UKUPNO', Locked = true;
        TotaVATlLbl = 'UKUPNO PDV', Locked = true;
        ToPayLbl = 'ZA PLATITI (S PDV-om):', Locked = true;
        PaymentMethodLbl = 'NAČIN PLAČANJA', Locked = true;
        TaxLbl = 'POREZ', Locked = true;
        TaxRateLbl = 'STOPA %', Locked = true;
        TaxBaseLbl = 'OSNOVA', Locked = true;
        TaxAmountLbl = 'IZNOS', Locked = true;
        OperatorLbl = 'BLAGAJNIK:', Locked = true;
        JIRLbl = 'JIR:', Locked = true;
        ZKILbl = 'ZKI:', Locked = true;
        CurrencyLbl = 'Sve cijene su u EUR', Locked = true;
        RefundPolicyLbl = 'Reklamacije prihvaćamo samo uz račun unutar 8 dana od kupnje!', Locked = true;
    }

    trigger OnPreReport()
    begin
        IsPrintedCopy();
    end;

    internal procedure SetFilters(CROAuditEntryType: Enum "NPR CRO Audit Entry Type"; AuditEntryNo: Integer; DocumentNo: Code[20])
    begin
        _CROAuditEntryType := CROAuditEntryType;
        _AuditEntryNo := AuditEntryNo;
        _DocumentNo := DocumentNo;
    end;

    local procedure FillPOSEntryRecords(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntryLines: Record "NPR POS Entry Sales Line" temporary;
    var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        POSEntry.SetLoadFields("Customer No.", "Salesperson Code");
        POSEntry.Get(CROPOSAuditLogAuxInfo."POS Entry No.");
        SalespersonPurchaser.SetLoadFields(Name);
        SalespersonPurchaser.Get(POSEntry."Salesperson Code");
        OperatorName := SalespersonPurchaser.Name;

        if Customer.Get(POSEntry."Customer No.") then begin
            CustomerAddress := Customer.Address;
            CustomerName := Customer.Name;
            CustomerPostCity := Customer."Post Code" + ' ' + Customer.City;
        end;
        POSEntryPaymentLine.SetRange("POS Entry No.", CROPOSAuditLogAuxInfo."POS Entry No.");
        POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
        POSEntryPaymentLine.FindSet();
        repeat
            POSEntryPaymentLines.Init();
            POSEntryPaymentLines.TransferFields(POSEntryPaymentLine);
            POSEntryPaymentLines.Insert();
        until POSEntryPaymentLine.Next() = 0;

        POSEntrySalesLine.SetRange("POS Entry No.", CROPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        if not POSEntrySalesLine.FindSet() then
            exit;
        NextLineNo := 10000;
        repeat
            POSEntryLines.Init();
            POSEntryLines.TransferFields(POSEntrySalesLine);

            POSEntryLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
            POSEntryLines."Line No." := NextLineNo;
            NextLineNo += 10000;
            AddAmountToDecimalDictionary(TaxableAmountDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT");
            AddAmountToDecimalDictionary(AmountInclTaxDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT");
            POSEntryLines.Insert();
        until POSEntrySalesLine.Next() = 0;

        FillTaxField(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure FillSalesCrMemoRecords(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntryLines: Record "NPR POS Entry Sales Line" temporary;
    var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        SalesCreditMemo: Record "Sales Cr.Memo Header";
        SalesCreditMemoLine: Record "Sales Cr.Memo Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        if not SalesCreditMemo.Get(CROPOSAuditLogAuxInfo."Source Document No.") then
            exit;

        if SalespersonPurchaser.Get(SalesCreditMemo."Salesperson Code") then
            OperatorName := SalespersonPurchaser.Name;

        CustomerAddress := SalesCreditMemo."Sell-to Address";
        CustomerName := SalesCreditMemo."Sell-to Customer Name";
        CustomerPostCity := SalesCreditMemo."Sell-to Post Code" + ' ' + SalesCreditMemo."Sell-to City";

        POSEntryPaymentLines.Init();
        POSEntryPaymentLines."POS Payment Method Code" := SalesCreditMemo."Payment Method Code";
        POSEntryPaymentLines."Amount (LCY)" := "CRO POS Audit Log Aux Info"."Total Amount";
        POSEntryPaymentLines.Insert();

        SalesCreditMemoLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesCreditMemoLine.SetRange(Type, SalesCreditMemoLine.Type::Item);
        if not SalesCreditMemoLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            POSEntryLines.Init();
            POSEntryLines.Type := POSEntryLines.Type::Item;
            POSEntryLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
            POSEntryLines."Line No." := NextLineNo;
            NextLineNo += 10000;
            POSEntryLines.Description := SalesCreditMemoLine.Description;
            POSEntryLines.Quantity := -SalesCreditMemoLine.Quantity;
            POSEntryLines."Unit Price" := -SalesCreditMemoLine."Unit Price";
            POSEntryLines."Amount Incl. VAT" := -SalesCreditMemoLine."Amount Including VAT";
            POSEntryLines."Unit of Measure Code" := SalesCreditMemoLine."Unit of Measure Code";
            POSEntryLines."Line Discount %" := SalesCreditMemoLine."Line Discount %";
            POSEntryLines."Line Discount Amount Incl. VAT" := -SalesCreditMemoLine."Line Discount Amount";
            POSEntryLines."No." := SalesCreditMemoLine."No.";
            AddAmountToDecimalDictionary(TaxableAmountDict, SalesCreditMemoLine."VAT %", -SalesCreditMemoLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, SalesCreditMemoLine."VAT %", -(SalesCreditMemoLine."Amount Including VAT" - SalesCreditMemoLine.Amount));
            AddAmountToDecimalDictionary(AmountInclTaxDict, SalesCreditMemoLine."VAT %", -SalesCreditMemoLine."Amount Including VAT");
            POSEntryLines.Insert();
        until SalesCreditMemoLine.Next() = 0;

        FillTaxField(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure FillSalesInvoiceRecords(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntryLines: Record "NPR POS Entry Sales Line" temporary;
    var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoicesLine: Record "Sales Invoice Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        if not SalesInvoiceHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.") then
            exit;

        if SalespersonPurchaser.Get(SalesInvoiceHeader."Salesperson Code") then
            OperatorName := SalespersonPurchaser.Name;

        CustomerAddress := SalesInvoiceHeader."Sell-to Address";
        CustomerName := SalesInvoiceHeader."Sell-to Customer Name";
        CustomerPostCity := SalesInvoiceHeader."Sell-to Post Code" + ' ' + SalesInvoiceHeader."Sell-to City";

        POSEntryPaymentLines.Init();
        POSEntryPaymentLines."POS Payment Method Code" := SalesInvoiceHeader."Payment Method Code";
        POSEntryPaymentLines."Amount (LCY)" := "CRO POS Audit Log Aux Info"."Total Amount";
        POSEntryPaymentLines.Insert();

        SalesInvoicesLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoicesLine.SetRange("Type", SalesInvoicesLine."Type"::Item);
        if not SalesInvoicesLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            POSEntryLines.Init();
            POSEntryLines.TransferFields(SalesInvoicesLine);
            POSEntryLines."Line Discount %" := SalesInvoicesLine."Line Discount %";
            POSEntryLines."No." := SalesInvoicesLine."No.";
            POSEntryLines.Description := SalesInvoicesLine.Description;
            POSEntryLines.Type := POSEntryLines.Type::Item;
            POSEntryLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
            POSEntryLines."Line No." := NextLineNo;
            NextLineNo += 10000;
            AddAmountToDecimalDictionary(TaxableAmountDict, SalesInvoicesLine."VAT %", SalesInvoicesLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, SalesInvoicesLine."VAT %", (SalesInvoicesLine."Amount Including VAT" - SalesInvoicesLine.Amount));
            AddAmountToDecimalDictionary(AmountInclTaxDict, SalesInvoicesLine."VAT %", SalesInvoicesLine."Amount Including VAT");
            POSEntryLines.Insert();
        until SalesInvoicesLine.Next() = 0;

        FillTaxField(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;
#IF NOT (BC17 or BC18)
    local procedure GenerateQRCode()
    var
        BarcodeSymbology2D: Enum "Barcode Symbology 2D";
        BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
        BarcodeString: Text;
    begin
        BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
        BarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
        BarcodeString := "CRO POS Audit Log Aux Info"."Verification URL";
        QRCode := BarcodeFontProvider2D.EncodeFont(BarcodeString, BarcodeSymbology2D);
    end;
#ENDIF

    local procedure AddAmountToDecimalDictionary(var DecimalDictionary: Dictionary of [Decimal, Decimal]; DictKey: Decimal; DictValue: Decimal)
    var
        BaseAmount: Decimal;
    begin
        if DecimalDictionary.Add(DictKey, DictValue) then
            exit;
        BaseAmount := DecimalDictionary.Get(DictKey) + DictValue;
        DecimalDictionary.Set(DictKey, BaseAmount);
    end;

    local procedure IsPrintedCopy()
    var
        MessageLbl: Label 'OVO JE KOPIJA FISKALNOG RACUNA', Locked = true;
    begin
        if CurrReport.Preview() then begin
            if "CRO POS Audit Log Aux Info"."Receipt Printed" then
                CopyText := MessageLbl
            else
                "CRO POS Audit Log Aux Info"."Receipt Printed" := true;
        end
    end;

    local procedure FillTaxField(var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; AmountInclTaxDict: Dictionary of [Decimal, Decimal]; TaxableAmountDict: Dictionary of [Decimal, Decimal]; TaxAmountDict: Dictionary of [Decimal, Decimal])
    var
        TaxKey: Decimal;
    begin
        foreach TaxKey in TaxableAmountDict.Keys() do begin
            POSEntryTaxLines.Init();
            POSEntryTaxLines."Tax %" := TaxKey;
            POSEntryTaxLines."Tax Base Amount" := TaxableAmountDict.Get(TaxKey);
            POSEntryTaxLines."Tax Amount" := TaxAmountDict.Get(TaxKey);
            POSEntryTaxLines."Amount Including Tax" := AmountInclTaxDict.Get(TaxKey);
            POSEntryTaxLines.Insert();
        end;
    end;

    local procedure CreatePOSStoreInfo()
    begin
        if "POS Store".Name <> '' then
            StoreDetailsLine := "POS Store".Name;

        if "POS Store".Address <> '' then begin
            if StoreDetailsLine <> '' then
                StoreDetailsLine += ', ';
            StoreDetailsLine += "POS Store".Address;
        end;

        if "POS Store"."Post Code" <> '' then begin
            if StoreDetailsLine <> '' then
                StoreDetailsLine += ', ';
            StoreDetailsLine += "POS Store"."Post Code";
        end;

        if "POS Store".City <> '' then begin
            if StoreDetailsLine <> '' then
                StoreDetailsLine += ' ';
            StoreDetailsLine += "POS Store".City;
        end;
    end;

    local procedure CreateCompanyInformationArray(var FormattedAddrArray: array[2] of Text; CompanyInfo: Record "Company Information")
    var
        CROFiscalSetup: Record "NPR CRO Fiscalization Setup";
        OIBLbl: Label 'OIB: ', Locked = true;
        PhoneLbl: Label ' Tel: ', Locked = true;
    begin
        CROFiscalSetup.Get();
        Clear(FormattedAddrArray);

        if CompanyInfo.City <> '' then
            FormattedAddrArray[1] := CompanyInfo.City;

        if CompanyInfo."Post Code" <> '' then
            if FormattedAddrArray[1] <> '' then
                FormattedAddrArray[1] += ' - ' + CompanyInfo."Post Code"
            else
                FormattedAddrArray[1] := CompanyInfo."Post Code";

        if CROFiscalSetup."Certificate Subject OIB" <> '' then
            FormattedAddrArray[2] := OIBLbl + CROFiscalSetup."Certificate Subject OIB";

        if CompanyInfo."Phone No." <> '' then
            if FormattedAddrArray[2] <> '' then
                FormattedAddrArray[2] += PhoneLbl + CompanyInfo."Phone No."
            else
                FormattedAddrArray[2] := PhoneLbl + CompanyInfo."Phone No.";
    end;

    var
        _DocumentNo: Code[20];
        _CROAuditEntryType: Enum "NPR CRO Audit Entry Type";
        _AuditEntryNo: Integer;
        BillLbl: Label 'RAČUN %1/%2/%3', Comment = '%1 = Receipt No., %2 = POS Store Code, %3 = POS Unit No.', Locked = true;
        CompanyName: Text;
        CompanyWebsite: Text;
        CompanyCity: Text;
        CopyText: Text;
        CustomerAddress: Text;
        CustomerName: Text;
        CustomerPostCity: Text;
        OperatorName: Text;
        QRCode: Text;
        StoreDetailsLine: Text;
        AddrArray: array[2] of Text[100];
}