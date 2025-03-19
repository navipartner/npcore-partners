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
                            FillPOSSaleRecords("CRO POS Audit Log Aux Info", "POS Entry Lines", "POS Entry Tax Lines", "POS Entry Payment Lines");
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

    local procedure FillPOSSaleRecords(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntrySalesLines: Record "NPR POS Entry Sales Line" temporary; var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        PostedSalesInvoiceNo: Code[20];
        SalesOrderNo: Code[20];
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
        PostedSalesInvoices: List of [Code[20]];
        SalesOrders: List of [Code[20]];
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

        POSEntrySalesLine.SetRange("POS Entry No.", CROPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        if POSEntrySalesLine.FindSet() then
            repeat
                POSEntrySalesLines.Init();
                POSEntrySalesLines.TransferFields(POSEntrySalesLine);
                AddAmountToDecimalDictionary(TaxableAmountDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."VAT Base Amount");
                AddAmountToDecimalDictionary(TaxAmountDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT");
                AddAmountToDecimalDictionary(AmountInclTaxDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT");
                POSEntrySalesLines.Insert();
            until POSEntrySalesLine.Next() = 0;

        if CROPOSAuditLogAuxInfo."Collect in Store" then begin
            NpCsCollectMgt.FindDocumentsForDeliveredCollectInStoreDocument(CROPOSAuditLogAuxInfo."POS Entry No.", PostedSalesInvoices, SalesOrders);

            foreach SalesOrderNo in SalesOrders do begin
                SalesLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Amount Including VAT", "Unit of Measure Code", "Line Discount %", "Line Discount Amount", "VAT %", "VAT Base Amount");
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", SalesOrderNo);
                SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
                if SalesLine.FindSet() then begin
                    NextLineNo := GetNextLineNo(POSEntrySalesLines, POSEntry."Entry No.");

                    repeat
                        POSEntrySalesLines.Init();
                        POSEntrySalesLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
                        POSEntrySalesLines."Line No." := NextLineNo;
                        POSEntrySalesLines.Type := POSEntrySalesLines.Type::Item;
                        POSEntrySalesLines."No." := SalesLine."No.";
                        POSEntrySalesLines.Description := SalesLine.Description;
                        POSEntrySalesLines.Quantity := SalesLine.Quantity;
                        POSEntrySalesLines."Unit Price" := SalesLine."Unit Price";
                        POSEntrySalesLines."Amount Incl. VAT" := SalesLine."Amount Including VAT";
                        POSEntrySalesLines."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                        POSEntrySalesLines."Line Discount %" := SalesLine."Line Discount %";
                        POSEntrySalesLines."Line Discount Amount Incl. VAT" := SalesLine."Line Discount Amount";
                        AddAmountToDecimalDictionary(TaxableAmountDict, SalesLine."VAT %", SalesLine."VAT Base Amount");
                        AddAmountToDecimalDictionary(TaxAmountDict, SalesLine."VAT %", (SalesLine."Amount Including VAT" - SalesLine."VAT Base Amount"));
                        AddAmountToDecimalDictionary(AmountInclTaxDict, SalesLine."VAT %", SalesLine."Amount Including VAT");
                        POSEntrySalesLines.Insert();
                        NextLineNo += 10000
                    until SalesLine.Next() = 0;
                end;
            end;

            foreach PostedSalesInvoiceNo in PostedSalesInvoices do begin
                SalesInvoiceLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Amount Including VAT", "Unit of Measure Code", "Line Discount %", "Line Discount Amount", "VAT %", "VAT Base Amount");
                SalesInvoiceLine.SetRange("Document No.", PostedSalesInvoiceNo);
                SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
                if SalesInvoiceLine.FindSet() then begin
                    NextLineNo := GetNextLineNo(POSEntrySalesLines, POSEntry."Entry No.");

                    repeat
                        POSEntrySalesLines.Init();
                        POSEntrySalesLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
                        POSEntrySalesLines."Line No." := NextLineNo;
                        POSEntrySalesLines.Type := POSEntrySalesLines.Type::Item;
                        POSEntrySalesLines."No." := SalesInvoiceLine."No.";
                        POSEntrySalesLines.Description := SalesInvoiceLine.Description;
                        POSEntrySalesLines.Quantity := SalesInvoiceLine.Quantity;
                        POSEntrySalesLines."Unit Price" := SalesInvoiceLine."Unit Price";
                        POSEntrySalesLines."Amount Incl. VAT" := SalesInvoiceLine."Amount Including VAT";
                        POSEntrySalesLines."Unit of Measure Code" := SalesInvoiceLine."Unit of Measure Code";
                        POSEntrySalesLines."Line Discount %" := SalesInvoiceLine."Line Discount %";
                        POSEntrySalesLines."Line Discount Amount Incl. VAT" := SalesInvoiceLine."Line Discount Amount";
                        AddAmountToDecimalDictionary(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
                        AddAmountToDecimalDictionary(TaxAmountDict, SalesInvoiceLine."VAT %", (SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount"));
                        AddAmountToDecimalDictionary(AmountInclTaxDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT");
                        POSEntrySalesLines.Insert();
                        NextLineNo += 10000
                    until SalesInvoiceLine.Next() = 0;
                end;
            end;
        end;

        POSEntryPaymentLines.Init();
        POSEntryPaymentLines."POS Payment Method Code" := Format(CROPOSAuditLogAuxInfo."Payment Method");
        POSEntryPaymentLines."Amount (LCY)" := "CRO POS Audit Log Aux Info"."Total Amount";
        POSEntryPaymentLines.Insert();

        FillTaxField(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure FillSalesCrMemoRecords(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntrySalesLines: Record "NPR POS Entry Sales Line" temporary; var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        if not SalesCrMemoHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.") then
            exit;

        if SalespersonPurchaser.Get(SalesCrMemoHeader."Salesperson Code") then
            OperatorName := SalespersonPurchaser.Name;

        CustomerAddress := SalesCrMemoHeader."Sell-to Address";
        CustomerName := SalesCrMemoHeader."Sell-to Customer Name";
        CustomerPostCity := SalesCrMemoHeader."Sell-to Post Code" + ' ' + SalesCrMemoHeader."Sell-to City";

        POSEntryPaymentLines.Init();
        POSEntryPaymentLines."POS Payment Method Code" := Format(CROPOSAuditLogAuxInfo."Payment Method");
        POSEntryPaymentLines."Amount (LCY)" := "CRO POS Audit Log Aux Info"."Total Amount";
        POSEntryPaymentLines.Insert();

        SalesCrMemoLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Amount Including VAT", "Unit of Measure Code", "Line Discount %", "Line Discount Amount", "VAT %", "VAT Base Amount");
        SalesCrMemoLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if not SalesCrMemoLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            POSEntrySalesLines.Init();
            POSEntrySalesLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
            POSEntrySalesLines."Line No." := NextLineNo;
            POSEntrySalesLines.Type := POSEntrySalesLines.Type::Item;
            POSEntrySalesLines."No." := SalesCrMemoLine."No.";
            POSEntrySalesLines.Description := SalesCrMemoLine.Description;
            POSEntrySalesLines.Quantity := -SalesCrMemoLine.Quantity;
            POSEntrySalesLines."Unit Price" := -SalesCrMemoLine."Unit Price";
            POSEntrySalesLines."Amount Incl. VAT" := -SalesCrMemoLine."Amount Including VAT";
            POSEntrySalesLines."Unit of Measure Code" := SalesCrMemoLine."Unit of Measure Code";
            POSEntrySalesLines."Line Discount %" := SalesCrMemoLine."Line Discount %";
            POSEntrySalesLines."Line Discount Amount Incl. VAT" := -SalesCrMemoLine."Line Discount Amount";
            AddAmountToDecimalDictionary(TaxableAmountDict, SalesCrMemoLine."VAT %", -SalesCrMemoLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, SalesCrMemoLine."VAT %", -(SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine."VAT Base Amount"));
            AddAmountToDecimalDictionary(AmountInclTaxDict, SalesCrMemoLine."VAT %", -SalesCrMemoLine."Amount Including VAT");
            POSEntrySalesLines.Insert();
            NextLineNo += 10000;
        until SalesCrMemoLine.Next() = 0;

        FillTaxField(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure FillSalesInvoiceRecords(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntrySalesLines: Record "NPR POS Entry Sales Line" temporary; var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
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
        POSEntryPaymentLines."POS Payment Method Code" := Format(CROPOSAuditLogAuxInfo."Payment Method");
        POSEntryPaymentLines."Amount (LCY)" := "CRO POS Audit Log Aux Info"."Total Amount";
        POSEntryPaymentLines.Insert();

        SalesInvoiceLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Amount Including VAT", "Unit of Measure Code", "Line Discount %", "Line Discount Amount", "VAT %", "VAT Base Amount");
        SalesInvoiceLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceLine.SetRange("Type", SalesInvoiceLine."Type"::Item);
        if not SalesInvoiceLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            POSEntrySalesLines.Init();
            POSEntrySalesLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
            POSEntrySalesLines."Line No." := NextLineNo;
            POSEntrySalesLines.Type := POSEntrySalesLines.Type::Item;
            POSEntrySalesLines."No." := SalesInvoiceLine."No.";
            POSEntrySalesLines.Description := SalesInvoiceLine.Description;
            POSEntrySalesLines.Quantity := SalesInvoiceLine.Quantity;
            POSEntrySalesLines."Unit Price" := SalesInvoiceLine."Unit Price";
            POSEntrySalesLines."Amount Incl. VAT" := SalesInvoiceLine."Amount Including VAT";
            POSEntrySalesLines."Unit of Measure Code" := SalesInvoiceLine."Unit of Measure Code";
            POSEntrySalesLines."Line Discount %" := SalesInvoiceLine."Line Discount %";
            POSEntrySalesLines."Line Discount Amount Incl. VAT" := SalesInvoiceLine."Line Discount Amount";
            AddAmountToDecimalDictionary(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, SalesInvoiceLine."VAT %", (SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount"));
            AddAmountToDecimalDictionary(AmountInclTaxDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT");
            POSEntrySalesLines.Insert();
            NextLineNo += 10000;
        until SalesInvoiceLine.Next() = 0;

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

    local procedure GetNextLineNo(var POSEntryLines: Record "NPR POS Entry Sales Line" temporary; POSEntryNo: Integer) NextLineNo: Integer
    begin
        POSEntryLines.Reset();
        POSEntryLines.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryLines.FindLast() then
            NextLineNo := POSEntryLines."Line No." + 10000
        else
            NextLineNo := 10000;
    end;

    var
        _DocumentNo: Code[20];
        _CROAuditEntryType: Enum "NPR CRO Audit Entry Type";
        _AuditEntryNo: Integer;
        BillLbl: Label 'RAČUN %1/%2/%3', Comment = '%1 = Receipt No., %2 = POS Store Code, %3 = POS Unit No.', Locked = true;
        CompanyCity: Text;
        CompanyName: Text;
        CompanyWebsite: Text;
        CopyText: Text;
        CustomerAddress: Text;
        CustomerName: Text;
        CustomerPostCity: Text;
        OperatorName: Text;
        QRCode: Text;
        StoreDetailsLine: Text;
        AddrArray: array[2] of Text[100];
}