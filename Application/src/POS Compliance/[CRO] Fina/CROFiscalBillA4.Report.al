report 6014554 "NPR CRO Fiscal Bill A4"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'CRO Fiscal Bill A4';
    DefaultLayout = Word;
    WordLayout = './src/_Reports/layouts/CROFiscalBillA4.docx';
    UsageCategory = None;

    dataset
    {
        dataitem(CompanyInformation; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            MaxIteration = 1;
            column(CRO_Company_Picture; Picture) { }
            column(CRO_Company_Name; Name) { }
            column(CRO_Company_Address; FormatAddress(Address, "Post Code", City)) { }
            column(CRO_Company_InformationBlock; CompanyInformationBlock) { }
            column(CRO_Company_VATRegNo; "VAT Registration No.") { }
            column(CRO_Company_PhoneNo; "Phone No.") { }
            column(CRO_Company_HomePage; "Home Page") { }
            column(CRO_Company_Email; "E-Mail") { }

            trigger OnAfterGetRecord()
            begin
                CompanyInformationBlock := GetCompanyInformation();
            end;
        }
        dataitem(CROPOSAuditLogAuxInfo; "NPR CRO POS Aud. Log Aux. Info")
        {
            column(CRO_Bill_DateTime; StrSubstNo(DateTimeFormatLbl, FormatDate("Entry Date"), FormatTime(("Log Timestamp")))) { }
            column(CRO_BillNo; StrSubstNo(BillLbl, "Bill No.", "POS Store Code", "POS Unit No.")) { }
            column(CRO_ZKICode; "ZKI Code") { }
            column(CRO_JIRCode; "JIR Code") { }
            column(CRO_TotalAmount; "Total Amount") { }
            column(CRO_QRCode; QRCode) { }
            column(CRO_CopyText; CopyText) { }

            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = field("Customer No.");

                column(CRO_Customer_InformationBlock; CustomerInformationBlock) { }
                trigger OnAfterGetRecord()
                begin
                    CustomerInformationBlock := GetCustomerInformation(Customer);
                end;
            }
            dataitem(POSStore; "NPR POS Store")
            {
                DataItemLink = "Code" = field("POS Store Code");

                column(CRO_POSStore_Name; Name) { }
                column(CRO_POSStore_Address; FormatAddress(Address, "Post Code", City)) { }
            }
            dataitem(POSEntrySalesLines; "NPR POS Entry Sales Line")
            {
                UseTemporary = true;

                column(CRO_ItemDescription; Description) { }
                column(CRO_Quantity; Quantity) { }
                column(CRO_UnitPrice; "Unit Price") { }
                column(CRO_UOM; "Unit of Measure Code") { }
                column(CRO_DiscountPerc; FormatDecimalAmount("Line Discount %")) { }
                column(CRO_DiscountAmount; FormatDecimalAmount("Line Discount Amount Incl. VAT")) { }
                column(CRO_AmountIncludingVAT; "Amount Incl. VAT") { }
                column(CRO_ItemNo; "No.") { }
                column(CRO_SalespersonName; SalespersonName) { }

                trigger OnPreDataItem()
                begin
                    case CROPOSAuditLogAuxInfo."Audit Entry Type" of
                        CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                            InsertPOSEntrySaleLines(CROPOSAuditLogAuxInfo, POSEntrySalesLines, POSEntryTaxLines, POSEntryPaymentLines);
                        CROPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Credit Memo":
                            InsertSalesCrMemoLines(CROPOSAuditLogAuxInfo, POSEntrySalesLines, POSEntryTaxLines, POSEntryPaymentLines);
                        CROPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice":
                            InsertSalesInvoiceLines(CROPOSAuditLogAuxInfo, POSEntrySalesLines, POSEntryTaxLines, POSEntryPaymentLines);
                    end;
                end;
            }
            dataitem(POSEntryTaxLines; "NPR POS Entry Tax Line")
            {
                UseTemporary = true;
                column(CRO_VATPerc; "Tax %") { }
                column(CRO_VATBaseAmount; "Tax Base Amount") { }
                column(CRO_VATAmount; "Tax Amount") { }
                column(CRO_AmountInclVAT; "Amount Including Tax") { }
            }
            dataitem(POSEntryPaymentLines; "NPR POS Entry Payment Line")
            {
                UseTemporary = true;
                column(CRO_Payment_Description; GetPaymentLineDescription(Description)) { }
                column(CRO_Amount; "Amount (LCY)") { }
            }
            dataitem(CROTotals; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));

                column(CRO_TotalVATAmount; TotalVATAmount) { }
            }

            trigger OnPreDataItem()
            begin
                CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", _CROAuditEntryType);
                CROPOSAuditLogAuxInfo.SetRange("Audit Entry No.", _AuditEntryNo);
                CROPOSAuditLogAuxInfo.SetRange("Source Document No.", _DocumentNo);
            end;

            trigger OnAfterGetRecord()
            begin
                Clear(TotalVATAmount);
                Clear(SalespersonName);
                Clear(CopyText);
                Clear(QRCode);
                Clear(CustomerInformationBlock);
#if not (BC17 or BC18)
                GenerateQRCode();
#endif
                SetCopyText();
            end;
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
        ItemNoLbl = 'Šifra', Locked = true;
        ItemNameLbl = 'Naziv', Locked = true;
        QtyLbl = 'KOL', Locked = true;
        UoMLbl = 'JMJ', Locked = true;
        PriceLbl = 'Cijena', Locked = true;
        PercLbl = '%', Locked = true;
        DiscountLbl = 'Popust', Locked = true;
        TotalLbl = 'Ukupno', Locked = true;
        VATLbl = 'PDV', Locked = true;
        ToPayLbl = 'ZA PLATITI (S PDV-om):', Locked = true;
        PaymentMethodLbl = 'Način plaćanja', Locked = true;
        TaxLbl = 'Porez', Locked = true;
        TaxRateLbl = 'Stopa %', Locked = true;
        TaxBaseLbl = 'Osnovica', Locked = true;
        TaxAmountLbl = 'Iznos', Locked = true;
        ZKILbl = 'ZKI:', Locked = true;
        JIRLbl = 'JIR:', Locked = true;
        CurrencyLbl = 'Sve cijene su u EUR', Locked = true;
    }
    internal procedure SetFilters(CROAuditEntryType: Enum "NPR CRO Audit Entry Type"; AuditEntryNo: Integer; DocumentNo: Code[20])
    begin
        _CROAuditEntryType := CROAuditEntryType;
        _AuditEntryNo := AuditEntryNo;
        _DocumentNo := DocumentNo;
    end;

    #region Sale Information Creation
    local procedure InsertPOSEntrySaleLines(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntrySalesLines: Record "NPR POS Entry Sales Line" temporary; var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
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
        if SalespersonPurchaser.Get(POSEntry."Salesperson Code") then
            if SalespersonPurchaser.Name <> '' then
                SalespersonName := StrSubstNo(SalespersonLbl, SalespersonPurchaser.Name)
            else
                SalespersonName := StrSubstNo(SalespersonLbl, SalespersonPurchaser.Code);

        POSEntrySalesLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Unit of Measure Code", "Line Discount %", "Line Discount Amount Incl. VAT", "Amount Incl. VAT", "Amount Excl. VAT", "VAT %", "VAT Base Amount");
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

        POSEntryPaymentLine.SetLoadFields(Description, "Amount (LCY)");
        POSEntryPaymentLine.SetRange("POS Entry No.", CROPOSAuditLogAuxInfo."POS Entry No.");
        if POSEntryPaymentLine.FindSet() then begin
            NextLineNo := GetNextLineNo(POSEntryPaymentLines, CROPOSAuditLogAuxInfo."POS Entry No.");

            repeat
                POSEntryPaymentLines.Init();
                POSEntryPaymentLines."Line No." := NextLineNo;
                POSEntryPaymentLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
                POSEntryPaymentLines.Description := POSEntryPaymentLine.Description;
                POSEntryPaymentLines."Amount (LCY)" := POSEntryPaymentLine."Amount (LCY)";
                POSEntryPaymentLines.Insert();
                NextLineNo += 10000
            until POSEntryPaymentLine.Next() = 0;
        end;

        InsertTaxLines(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure InsertSalesInvoiceLines(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntrySalesLines: Record "NPR POS Entry Sales Line" temporary; var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        SalesInvoiceHeader.SetLoadFields("Salesperson Code", "Payment Method Code");
        if not SalesInvoiceHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.") then
            exit;

        SalespersonPurchaser.SetLoadFields(Name);
        if not SalespersonPurchaser.Get(CROPOSAuditLogAuxInfo."Salesperson Code") then
            SalespersonPurchaser.Get(SalesInvoiceHeader."Salesperson Code");
        if SalespersonPurchaser.Code <> '' then
            if SalespersonPurchaser.Name <> '' then
                SalespersonName := StrSubstNo(SalespersonLbl, SalespersonPurchaser.Name)
            else
                SalespersonName := StrSubstNo(SalespersonLbl, SalespersonPurchaser.Code);

        SalesInvoiceLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Amount Including VAT", "Unit of Measure Code", "Line Discount %", "Line Discount Amount", "VAT %", "VAT Base Amount");
        SalesInvoiceLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceLine.SetRange("Type", SalesInvoiceLine."Type"::Item);
        if not SalesInvoiceLine.FindSet() then
            exit;

        POSEntryPaymentLines.Init();
        POSEntryPaymentLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
        POSEntryPaymentLines."Line No." := 10000;
        POSEntryPaymentLines.Description := CopyStr(GetPaymentMethodDescription(SalesInvoiceHeader."Payment Method Code"), 1, MaxStrLen(POSEntryPaymentLines.Description));
        POSEntryPaymentLines."Amount (LCY)" := CROPOSAuditLogAuxInfo."Total Amount";
        POSEntryPaymentLines.Insert();

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

        InsertTaxLines(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure InsertSalesCrMemoLines(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var POSEntrySalesLines: Record "NPR POS Entry Sales Line" temporary; var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line" temporary)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        SalesCrMemoHeader.SetLoadFields("Salesperson Code", "Payment Method Code");
        if not SalesCrMemoHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.") then
            exit;

        SalespersonPurchaser.SetLoadFields(Name);
        if not SalespersonPurchaser.Get(CROPOSAuditLogAuxInfo."Salesperson Code") then
            SalespersonPurchaser.Get(SalesCrMemoHeader."Salesperson Code");
        if SalespersonPurchaser.Code <> '' then
            if SalespersonPurchaser.Name <> '' then
                SalespersonName := StrSubstNo(SalespersonLbl, SalespersonPurchaser.Name)
            else
                SalespersonName := StrSubstNo(SalespersonLbl, SalespersonPurchaser.Code);

        SalesCrMemoLine.SetLoadFields("No.", Description, Quantity, "Unit Price", "Amount Including VAT", "Unit of Measure Code", "Line Discount %", "Line Discount Amount", "VAT %", "VAT Base Amount");
        SalesCrMemoLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if not SalesCrMemoLine.FindSet() then
            exit;

        POSEntryPaymentLines.Init();
        POSEntryPaymentLines."POS Entry No." := CROPOSAuditLogAuxInfo."POS Entry No.";
        POSEntryPaymentLines."Line No." := 10000;
        POSEntryPaymentLines.Description := CopyStr(GetPaymentMethodDescription(SalesCrMemoHeader."Payment Method Code"), 1, MaxStrLen(POSEntryPaymentLines.Description));
        POSEntryPaymentLines."Amount (LCY)" := CROPOSAuditLogAuxInfo."Total Amount";
        POSEntryPaymentLines.Insert();

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

        InsertTaxLines(POSEntryTaxLines, AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure InsertTaxLines(var POSEntryTaxLines: Record "NPR POS Entry Tax Line" temporary; AmountInclTaxDict: Dictionary of [Decimal, Decimal]; TaxableAmountDict: Dictionary of [Decimal, Decimal]; TaxAmountDict: Dictionary of [Decimal, Decimal])
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

            TotalVATAmount += POSEntryTaxLines."Tax Amount";
        end;
    end;
    #endregion Sale Information Creation

    #region Formatting Procedures
    local procedure FormatDate(Value: Date): Text
    begin
        exit(Format(Value, 0, '<Day,2>.<Month,2>.<Year4>.'));
    end;

    local procedure FormatTime(Value: Time): Text
    begin
        exit(Format(Value, 0, '<Hours24>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure FormatAddress(Address: Text; PostCode: Text; City: Text) AddressLine: Text
    var
        PostCity: Text;
    begin
        AddressLine := '';

        AppendPart(AddressLine, Address, ', ');

        PostCity := '';
        AppendPart(PostCity, PostCode, ' ');
        AppendPart(PostCity, City, ' ');
        PostCity := PostCity.TrimEnd(' ');

        AppendPart(AddressLine, PostCity, ', ');
    end;

    local procedure AppendPart(var Target: Text; Value: Text; Separator: Text)
    begin
        if Value = '' then
            exit;

        if Target <> '' then
            Target += Separator;

        Target += Value;
    end;

    local procedure FormatDecimalAmount(Amount: Decimal): Text
    begin
        if Amount = 0 then
            exit('')
        else
            exit(Format(Amount, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'));
    end;

    #endregion Formatting Procedures

    #region Helper Procedures
    local procedure SetCopyText()
    var
        MessageLbl: Label 'OVO JE KOPIJA FISKALNOG RACUNA', Locked = true;
    begin
        if CROPOSAuditLogAuxInfo."Receipt Printed" then
            CopyText := MessageLbl;

        if not CurrReport.Preview() then
            if not CROPOSAuditLogAuxInfo."Receipt Printed" then begin
                CROPOSAuditLogAuxInfo."Receipt Printed" := true;
                CROPOSAuditLogAuxInfo.Modify();
            end;
    end;

    local procedure GetCustomerInformation(Customer: Record Customer) ReturnText: Text
    begin
        if Customer.Name <> '' then
            AppendNewLineText(ReturnText, Customer.Name);

        AppendNewLineText(ReturnText, FormatAddress(Customer.Address, Customer."Post Code", Customer.City));

        if Customer."VAT Registration No." <> '' then
            AppendNewLineText(ReturnText, StrSubstNo(VATRegNoLbl, Customer."VAT Registration No."));
    end;

    local procedure GetCompanyInformation() ReturnText: Text
    begin
        AppendNewLineText(ReturnText, FormatAddress(CompanyInformation.Address, CompanyInformation."Post Code", CompanyInformation.City));
        if CompanyInformation."VAT Registration No." <> '' then
            AppendNewLineText(ReturnText, StrSubstNo(VATRegNoLbl, CompanyInformation."VAT Registration No."));
        if CompanyInformation."Phone No." <> '' then
            AppendNewLineText(ReturnText, StrSubstNo(PhoneNoLbl, CompanyInformation."Phone No."));
        if CompanyInformation."E-Mail" <> '' then
            AppendNewLineText(ReturnText, CompanyInformation."E-Mail");
    end;

    local procedure GetPaymentMethodDescription(PaymentMethodCode: Code[10]): Text
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.SetLoadFields(Description);
        if PaymentMethod.Get(PaymentMethodCode) then
            exit(PaymentMethod.Description);
    end;

    local procedure GetPaymentLineDescription(Description: Text) Result: Text
    begin
        Result := Format(CROPOSAuditLogAuxInfo."Payment Method");
        if Description <> '' then
            Result += ' ' + Description;
    end;

    local procedure AppendNewLineText(var ReturnText: Text; TextToAppend: Text)
    var
        NewLine: Text;
    begin
        NewLine := PrintNewLine();
        if ReturnText <> '' then
            ReturnText += NewLine;
        ReturnText += TextToAppend;
    end;

    local procedure PrintNewLine(): Text
    var
        NewLineToReturn: Text;
    begin
        NewLineToReturn[1] := 13;
        NewLineToReturn[2] := 10;
        exit(NewLineToReturn);
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

    local procedure GetNextLineNo(var POSEntryPaymentLine: Record "NPR POS Entry Payment Line" temporary; POSEntryNo: Integer) NextLineNo: Integer
    begin
        POSEntryPaymentLine.Reset();
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryPaymentLine.FindLast() then
            NextLineNo := POSEntryPaymentLine."Line No." + 10000
        else
            NextLineNo := 10000;
    end;
#if not (BC17 or BC18)
    local procedure GenerateQRCode()
    var
        BarcodeSymbology2D: Enum "Barcode Symbology 2D";
        BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
        BarcodeString: Text;
    begin
        if (CROPOSAuditLogAuxInfo."ZKI Code" = '') or (CROPOSAuditLogAuxInfo."JIR Code" = '') then
            exit;

        BarcodeString := CROPOSAuditLogAuxInfo."Verification URL";
        if BarcodeString = '' then
            exit;

        BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
        BarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
        QRCode := BarcodeFontProvider2D.EncodeFont(BarcodeString, BarcodeSymbology2D);
    end;
#endif
    local procedure AddAmountToDecimalDictionary(var DecimalDictionary: Dictionary of [Decimal, Decimal]; DictKey: Decimal; DictValue: Decimal)
    var
        BaseAmount: Decimal;
    begin
        if DecimalDictionary.Add(DictKey, DictValue) then
            exit;
        BaseAmount := DecimalDictionary.Get(DictKey) + DictValue;
        DecimalDictionary.Set(DictKey, BaseAmount);
    end;

    #endregion Helper Procedures

    var
        _DocumentNo: Code[20];
        _CROAuditEntryType: Enum "NPR CRO Audit Entry Type";
        _AuditEntryNo: Integer;
        DateTimeFormatLbl: Label '%1 %2', Comment = '%1 = Date, %2 = Time', Locked = true;

        VATRegNoLbl: Label 'OIB: %1', Comment = '%1 = VAT Registration No.', Locked = true;
        PhoneNoLbl: Label 'Tel.: %1', Comment = '%1 = Phone No.', Locked = true;
        SalespersonLbl: Label 'Izdao: %1', Comment = '%1 = Salesperson Name or Code', Locked = true;
        BillLbl: Label 'RAČUN %1/%2/%3', Comment = '%1 = Receipt No., %2 = POS Store Code, %3 = POS Unit No.', Locked = true;
        CompanyInformationBlock: Text;
        CustomerInformationBlock: Text;
        SalespersonName: Text;
        CopyText: Text;
        QRCode: Text;
        TotalVATAmount: Decimal;
}