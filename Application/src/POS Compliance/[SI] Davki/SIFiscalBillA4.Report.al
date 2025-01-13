report 6014556 "NPR SI Fiscal Bill A4"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    Caption = 'SI Fiscal Bill A4';
    DefaultLayout = Word;
    WordLayout = './src/_Reports/layouts/SIFiscalBillA4.docx';
    UsageCategory = None;

    dataset
    {
        dataitem("SI POS Audit Log Aux Info"; "NPR SI POS Audit Log Aux. Info")
        {
            column(CompanyName; CompanyName) { }
            column(CompanyAddress; AddrArray[1]) { }
            column(CompanyContact; AddrArray[2]) { }
            column(CompanyWebsite; CompanyWebsite) { }
            column(CompanyCity; CompanyCity) { }
            column(LogTimeStamp; Format("Log Timestamp", 8, '<Hours24>:<Minutes,2>:<Seconds,2>')) { }
            column(EntryDate; Format("Entry Date", 0, '<Day,2>/<Month,2>/<Year4>')) { }
            column(EORCode; "EOR Code") { }
            column(Bill; StrSubstNo(BillLbl, "POS Store Code", "POS Unit No.", "Receipt No.")) { }
            column(ZOICode; "ZOI Code") { }
            column(OperatorName; OperatorName) { }
            column(QRCode; QRCode) { }
            column(TotalAmount; "Total Amount") { }
            column(CustomerPostCity; CustomerPostCity) { }
            column(CustomerName; CustomerName) { }
            column(CustomerAddress; CustomerAddress) { }
            column(CustomerVATNo; "Customer VAT Number") { }
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

                trigger OnPreDataItem()
                begin
                    case "SI POS Audit Log Aux Info"."Audit Entry Type" of
                        "SI POS Audit Log Aux Info"."Audit Entry Type"::"POS Entry":
                            FillPOSEntryRecords();
                        "SI POS Audit Log Aux Info"."Audit Entry Type"::"Sales Cr. Memo Header":
                            FillSalesCrMemoRecords();
                        "SI POS Audit Log Aux Info"."Audit Entry Type"::"Sales Invoice Header":
                            FillSalesInvoiceRecords();
                    end;
                end;
            }
            dataitem("POS Entry Comment Lines"; "NPR POS Entry Sales Line")
            {
                UseTemporary = true;

                column(Description; Description) { }

                trigger OnPreDataItem()
                begin
                    case "SI POS Audit Log Aux Info"."Audit Entry Type" of
                        "SI POS Audit Log Aux Info"."Audit Entry Type"::"POS Entry":
                            FillPOSEntryCommentLines();
                        "SI POS Audit Log Aux Info"."Audit Entry Type"::"Sales Cr. Memo Header":
                            FillSalesCrMemoCommentLines();
                        "SI POS Audit Log Aux Info"."Audit Entry Type"::"Sales Invoice Header":
                            FillSalesInvoiceCommentLines();
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
                column(POSStore; Code) { }

                trigger OnAfterGetRecord()
                begin
                    CreatePOSStoreInfo();
                end;
            }
            trigger OnPreDataItem()
            begin
                "SI POS Audit Log Aux Info".SetRange("Audit Entry Type", _SIAuditEntryType);
                "SI POS Audit Log Aux Info".SetRange("Audit Entry No.", _AuditEntryNo);
                "SI POS Audit Log Aux Info".SetRange("Source Document No.", _DocumentNo);
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

                IsPrintedCopy();
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
                    field("Audit Entry Type"; _SIAuditEntryType)
                    {
                        ApplicationArea = NPRSIFiscal;
                        Caption = 'Audit Entry Type';
                        ToolTip = 'Specifies the value of the Audit Entry Type field.';
                    }
                    field("Audit Entry No."; _AuditEntryNo)
                    {
                        ApplicationArea = NPRSIFiscal;
                        Caption = 'Audit Entry No.';
                        ToolTip = 'Specifies the value of the Audit Entry No. field.';
                    }
                    field("Document No."; _DocumentNo)
                    {
                        ApplicationArea = NPRSIFiscal;
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
        BarcodeLbl = 'ČRTNA KODA', Locked = true;
        PriceLbl = 'CENA', Locked = true;
        DiscountLbl = 'POPUST', Locked = true;
        DescriptionLbl = 'OPIS', Locked = true;
        QtyLbl = 'KOL', Locked = true;
        PercLbl = '%', Locked = true;
        UoMLbl = 'EM', Locked = true;
        VATLbl = 'DDV', Locked = true;
        TotalLbl = 'SKUPAJ', Locked = true;
        TotalVATlLbl = 'SKUPAJ DDV', Locked = true;
        ToPayLbl = 'ZA PLAČILO (Z DDV):', Locked = true;
        PaymentMethodLbl = 'NAČIN PLAČILA', Locked = true;
        TaxLbl = 'DAVEK', Locked = true;
        TaxRateLbl = 'STOPNJA%', Locked = true;
        TaxBaseLbl = 'OSNOVA', Locked = true;
        TaxAmountLbl = 'ZNESKA', Locked = true;
        OperatorLbl = 'BLAGAJNIK:', Locked = true;
        EORLbl = 'EOR:', Locked = true;
        ZOILbl = 'ZOI:', Locked = true;
        CurrencyLbl = 'Vse cene so v EUR', Locked = true;
        RefundPolicyLbl = 'Reklamacijo upoštevamo samo z računom v 8 dneh od nakupa!', Locked = true;
    }

    internal procedure SetFilters(SIAuditEntryType: Enum "NPR SI Audit Entry Type"; AuditEntryNo: Integer; DocumentNo: Code[20])
    begin
        _SIAuditEntryType := SIAuditEntryType;
        _AuditEntryNo := AuditEntryNo;
        _DocumentNo := DocumentNo;
    end;

    local procedure FillPOSEntryRecords()
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
        POSEntry.Get("SI POS Audit Log Aux Info"."POS Entry No.");
        SalespersonPurchaser.SetLoadFields(Name);
        SalespersonPurchaser.Get(POSEntry."Salesperson Code");
        OperatorName := SalespersonPurchaser.Name;

        if Customer.Get(POSEntry."Customer No.") then begin
            CustomerAddress := Customer.Address;
            CustomerName := Customer.Name;
            CustomerPostCity := Customer."Post Code" + ' ' + Customer.City;
        end;
        POSEntryPaymentLine.SetRange("POS Entry No.", "SI POS Audit Log Aux Info"."POS Entry No.");
        POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
        POSEntryPaymentLine.FindSet();
        repeat
            "POS Entry Payment Lines".Init();
            "POS Entry Payment Lines".TransferFields(POSEntryPaymentLine);
            "POS Entry Payment Lines".Insert();
        until POSEntryPaymentLine.Next() = 0;

        POSEntrySalesLine.SetRange("POS Entry No.", "SI POS Audit Log Aux Info"."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        if not POSEntrySalesLine.FindSet() then
            exit;
        NextLineNo := 10000;
        repeat
            "POS Entry Lines".Init();
            "POS Entry Lines".TransferFields(POSEntrySalesLine);
            "POS Entry Lines"."POS Entry No." := "SI POS Audit Log Aux Info"."POS Entry No.";
            "POS Entry Lines"."Line No." := NextLineNo;
            NextLineNo += 10000;
            AddAmountToDecimalDictionary(TaxableAmountDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT");
            AddAmountToDecimalDictionary(AmountInclTaxDict, POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT");
            "POS Entry Lines".Insert();
        until POSEntrySalesLine.Next() = 0;

        FillTaxField(AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure FillSalesCrMemoRecords()
    var
        SalesCreditMemo: Record "Sales Cr.Memo Header";
        SalesCreditMemoLine: Record "Sales Cr.Memo Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        if not SalesCreditMemo.Get("SI POS Audit Log Aux Info"."Source Document No.") then
            exit;

        if SalespersonPurchaser.Get(SalesCreditMemo."Salesperson Code") then
            OperatorName := SalespersonPurchaser.Name;

        CustomerAddress := SalesCreditMemo."Sell-to Address";
        CustomerName := SalesCreditMemo."Sell-to Customer Name";
        CustomerPostCity := SalesCreditMemo."Sell-to Post Code" + ' ' + SalesCreditMemo."Sell-to City";

        "POS Entry Payment Lines".Init();
        "POS Entry Payment Lines"."POS Payment Method Code" := SalesCreditMemo."Payment Method Code";
        "POS Entry Payment Lines"."Amount (LCY)" := "SI POS Audit Log Aux Info"."Total Amount";
        "POS Entry Payment Lines".Insert();

        SalesCreditMemoLine.SetRange("Document No.", "SI POS Audit Log Aux Info"."Source Document No.");
        SalesCreditMemoLine.SetRange(Type, SalesCreditMemoLine.Type::Item);
        if not SalesCreditMemoLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            "POS Entry Lines".Init();
            "POS Entry Lines".Type := "POS Entry Lines".Type::Item;
            "POS Entry Lines"."POS Entry No." := "SI POS Audit Log Aux Info"."POS Entry No.";
            "POS Entry Lines"."Line No." := NextLineNo;
            NextLineNo += 10000;
            "POS Entry Lines".Description := SalesCreditMemoLine.Description;
            "POS Entry Lines".Quantity := -SalesCreditMemoLine.Quantity;
            "POS Entry Lines"."Unit Price" := -SalesCreditMemoLine."Unit Price";
            "POS Entry Lines"."Amount Incl. VAT" := -SalesCreditMemoLine."Amount Including VAT";
            "POS Entry Lines"."Unit of Measure Code" := SalesCreditMemoLine."Unit of Measure Code";
            "POS Entry Lines"."Line Discount %" := SalesCreditMemoLine."Line Discount %";
            "POS Entry Lines"."Line Discount Amount Incl. VAT" := -SalesCreditMemoLine."Line Discount Amount";
            "POS Entry Lines"."No." := SalesCreditMemoLine."No.";
            AddAmountToDecimalDictionary(TaxableAmountDict, SalesCreditMemoLine."VAT %", -SalesCreditMemoLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, SalesCreditMemoLine."VAT %", -(SalesCreditMemoLine."Amount Including VAT" - SalesCreditMemoLine.Amount));
            AddAmountToDecimalDictionary(AmountInclTaxDict, SalesCreditMemoLine."VAT %", -SalesCreditMemoLine."Amount Including VAT");
            "POS Entry Lines".Insert();
        until SalesCreditMemoLine.Next() = 0;

        FillTaxField(AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure FillSalesInvoiceRecords()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        NextLineNo: Integer;
    begin
        if not SalesInvoiceHeader.Get("SI POS Audit Log Aux Info"."Source Document No.") then
            exit;

        if SalespersonPurchaser.Get(SalesInvoiceHeader."Salesperson Code") then
            OperatorName := SalespersonPurchaser.Name;

        CustomerAddress := SalesInvoiceHeader."Sell-to Address";
        CustomerName := SalesInvoiceHeader."Sell-to Customer Name";
        CustomerPostCity := SalesInvoiceHeader."Sell-to Post Code" + ' ' + SalesInvoiceHeader."Sell-to City";

        "POS Entry Payment Lines".Init();
        "POS Entry Payment Lines"."POS Payment Method Code" := SalesInvoiceHeader."Payment Method Code";
        "POS Entry Payment Lines"."Amount (LCY)" := "SI POS Audit Log Aux Info"."Total Amount";
        "POS Entry Payment Lines".Insert();

        SalesInvoiceLine.SetRange("Document No.", "SI POS Audit Log Aux Info"."Source Document No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if not SalesInvoiceLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            "POS Entry Lines".Init();
            "POS Entry Lines".TransferFields(SalesInvoiceLine);
            "POS Entry Lines"."No." := SalesInvoiceLine."No.";
            "POS Entry Lines".Description := SalesInvoiceLine.Description;
            "POS Entry Lines".Type := "POS Entry Lines".Type::Item;
            "POS Entry Lines"."POS Entry No." := "SI POS Audit Log Aux Info"."POS Entry No.";
            "POS Entry Lines"."Line No." := NextLineNo;
            NextLineNo += 10000;
            AddAmountToDecimalDictionary(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
            AddAmountToDecimalDictionary(TaxAmountDict, SalesInvoiceLine."VAT %", (SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount));
            AddAmountToDecimalDictionary(AmountInclTaxDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT");
            "POS Entry Lines".Insert();
        until SalesInvoiceLine.Next() = 0;

        FillTaxField(AmountInclTaxDict, TaxableAmountDict, TaxAmountDict);
    end;

    local procedure FillPOSEntryCommentLines()
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        NextLineNo: Integer;
    begin
        POSEntrySalesLine.SetLoadFields(Description);
        POSEntrySalesLine.SetRange("Document No.", "SI POS Audit Log Aux Info"."Source Document No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Comment);
        if not POSEntrySalesLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            "POS Entry Comment Lines".Init();
            "POS Entry Comment Lines".TransferFields(POSEntrySalesLine);
            "POS Entry Comment Lines"."Line No." := NextLineNo;
            "POS Entry Comment Lines".Insert();
            NextLineNo += 10000;
        until POSEntrySalesLine.Next() = 0;
    end;

    local procedure FillSalesInvoiceCommentLines()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        NextLineNo: Integer;
    begin
        SalesInvoiceLine.SetLoadFields(Description);
        SalesInvoiceLine.SetRange("Document No.", "SI POS Audit Log Aux Info"."Source Document No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::" ");
        if not SalesInvoiceLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            "POS Entry Comment Lines".Init();
            "POS Entry Comment Lines".Description := SalesInvoiceLine.Description;
            "POS Entry Comment Lines"."Line No." := NextLineNo;
            "POS Entry Comment Lines".Insert();
            NextLineNo += 10000;
        until SalesInvoiceLine.Next() = 0;
    end;

    local procedure FillSalesCrMemoCommentLines()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        NextLineNo: Integer;
    begin
        SalesCrMemoLine.SetLoadFields(Description);
        SalesCrMemoLine.SetRange("Document No.", "SI POS Audit Log Aux Info"."Source Document No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::" ");
        if not SalesCrMemoLine.FindSet() then
            exit;

        NextLineNo := 10000;
        repeat
            "POS Entry Comment Lines".Init();
            "POS Entry Comment Lines".Description := SalesCrMemoLine.Description;
            "POS Entry Comment Lines"."Line No." := NextLineNo;
            "POS Entry Comment Lines".Insert();
            NextLineNo += 10000;
        until SalesCrMemoLine.Next() = 0;
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
        BarcodeString := "SI POS Audit Log Aux Info"."Validation Code";
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
        MessageLbl: Label 'THIS IS A COPY %1 OF A RECEIPT', Comment = '%1 = Receipt Copy No.';
    begin
        if CurrReport.Preview() then
            exit;

        if "SI POS Audit Log Aux Info"."Receipt Printed" then begin
            "SI POS Audit Log Aux Info"."Copies Printed" += 1;
            CopyText := StrSubstNo(MessageLbl, "SI POS Audit Log Aux Info"."Copies Printed");
        end
        else begin
            "SI POS Audit Log Aux Info"."Receipt Printed" := true;
            "SI POS Audit Log Aux Info".Modify(true);
        end;
    end;

    local procedure FillTaxField(AmountInclTaxDict: Dictionary of [Decimal, Decimal]; TaxableAmountDict: Dictionary of [Decimal, Decimal]; TaxAmountDict: Dictionary of [Decimal, Decimal])
    var
        TaxKey: Decimal;
    begin
        foreach TaxKey in TaxableAmountDict.Keys() do begin
            "POS Entry Tax Lines".Init();
            "POS Entry Tax Lines"."Tax %" := TaxKey;
            "POS Entry Tax Lines"."Tax Base Amount" := TaxableAmountDict.Get(TaxKey);
            "POS Entry Tax Lines"."Tax Amount" := TaxAmountDict.Get(TaxKey);
            "POS Entry Tax Lines"."Amount Including Tax" := AmountInclTaxDict.Get(TaxKey);
            "POS Entry Tax Lines".Insert();
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

    procedure CreateCompanyInformationArray(var FormattedAddrArray: array[2] of Text; CompanyInfo: Record "Company Information")
    var
        DSLbl: Label 'DŠ: ', Locked = true;
        PhoneLbl: Label ' Tel: ', Locked = true;
    begin
        Clear(FormattedAddrArray);

        if CompanyInfo.City <> '' then
            FormattedAddrArray[1] := CompanyInfo.City;

        if CompanyInfo."Post Code" <> '' then
            if FormattedAddrArray[1] <> '' then
                FormattedAddrArray[1] += ' - ' + CompanyInfo."Post Code"
            else
                FormattedAddrArray[1] := CompanyInfo."Post Code";

        if CompanyInfo.Address <> '' then
            if FormattedAddrArray[1] <> '' then
                FormattedAddrArray[1] += ', ' + CompanyInfo.Address
            else
                FormattedAddrArray[1] := CompanyInfo.Address;

        if CompanyInfo."VAT Registration No." <> '' then
            FormattedAddrArray[2] := DSLbl + CompanyInfo."VAT Registration No.";

        if CompanyInfo."Phone No." <> '' then
            if FormattedAddrArray[2] <> '' then
                FormattedAddrArray[2] += PhoneLbl + CompanyInfo."Phone No."
            else
                FormattedAddrArray[2] := PhoneLbl + CompanyInfo."Phone No.";
    end;

    var
        _DocumentNo: Code[20];
        _SIAuditEntryType: Enum "NPR SI Audit Entry Type";
        _AuditEntryNo: Integer;
        BillLbl: Label 'RAČUN %1/%2/%3', Comment = '%1 = POS Store Code, %2 = POS Unit No., %3 = Receipt No.', Locked = true;
        CompanyName: Text;
        CompanyWebsite: Text;
        CopyText: Text;
        CompanyCity: Text;
        CustomerAddress: Text;
        CustomerName: Text;
        CustomerPostCity: Text;
        OperatorName: Text;
        QRCode: Text;
        StoreDetailsLine: Text;
        AddrArray: array[2] of Text[100];
}
