codeunit 6184590 "NPR SI Archive Mgt."
{
    Access = Internal;

    var
        _CRLF: Text;
        DateFilterLbl: Label '%1..%2', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        _StandardVATAmounts: array[4] of Text;

    #region SI Fiscalization Archiving - Invoice Archive

    internal procedure GenerateInvoiceArchive(StartDate: Date; EndDate: Date)
    var
        CompanyInformation: Record "Company Information";
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        CardPaymentAmount: Decimal;
        CashPaymentAmount: Decimal;
        OtherPaymentAmount: Decimal;
        TaxEightAmount: Decimal;
        TaxEightAmountBase: Decimal;
        TaxFiveAmount: Decimal;
        TaxFiveAmountBase: Decimal;
        TaxNineAmount: Decimal;
        TaxNineAmountBase: Decimal;
        TaxTwTwoAmount: Decimal;
        TaxTwTwoAmountBase: Decimal;
        ArchiveHeaderLbl: Label '"Dav st  ";"Rac dat ";"Rac cas ";"Rac nac";"Racst pp";"Racst en";"Racst zap";"Kupec                                             ";"Kupec id            ";"Rac vred ";"Rac povr ";"Rac plac ";"Plac got ";"Plac kart";"Plac ostalo";"Dav st zav";"Rac 9,5% DDV osn";"Rac 9,5% DDV";"Rac 22% DDV osn";"Rac 22% DDV";"Rac 5% DDV osn";"Rac 5% DDV";"Rac 8% DDV pav osn";"Rac 8% pav";"Rac davki ostalo";"Rac oprosc";"Rac dob76a";"Rac neobd";"Rac poseb";"Oper oznaka";"Oper dav st";"Zoi                             ";"Eor                                 ";"Eor nakn";"Sprem racst pp";"Sprem racst en";"Sprem racst zap";"Sprem rac dat";"Sprem vkr st";"Sprem vkr set";"Sprem vkr ser";"Sprem vkr dat";"Sprem nep dat";"Sprem nep cas";"Sprem nep st";"Rac opombe";', Locked = true;
        FileNameLbl: Label 'IZPIS_RAČUNI_GLAVE_%1-%2.txt', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        FixedCharLbl: Label 'C', Locked = true;
        OStream: OutStream;
        FileContent: Text;
        Filename: Text;
    begin
        CompanyInformation.Get();

        InitNewLine();
        FileContent := ArchiveHeaderLbl + _CRLF;

        SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
        SIPOSAuditLogAuxInfo.SetFilter("Entry Date", DateFilterLbl, StartDate, EndDate);
        if not SIPOSAuditLogAuxInfo.FindSet() then
            exit;
        repeat
            ClearValues(OtherPaymentAmount, CardPaymentAmount, CashPaymentAmount, TaxNineAmount, TaxEightAmount, TaxFiveAmount, TaxTwTwoAmount, TaxNineAmountBase, TaxEightAmountBase, TaxFiveAmountBase, TaxTwTwoAmountBase);
            AppendTextField(FileContent, PadRightSpace(Format(CompanyInformation."VAT Registration No."), 10));
            AppendTextField(FileContent, PadRightSpace(FormatDate(SIPOSAuditLogAuxInfo."Entry Date"), 10));
            AppendTextField(FileContent, PadRightSpace(FormatTime(SIPOSAuditLogAuxInfo."Log Timestamp"), 10));
            AppendTextField(FileContent, PadRightSpace(FixedCharLbl, 9));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Store Code"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Unit No."), 10));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."Receipt No."), 11));

            AppendCustomerInfo(FileContent, SIPOSAuditLogAuxInfo);

            GetPaymentAmounts(SIPOSAuditLogAuxInfo, OtherPaymentAmount, CardPaymentAmount, CashPaymentAmount);

            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SIPOSAuditLogAuxInfo."Total Amount"), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SIPOSAuditLogAuxInfo."Returns Amount"), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SIPOSAuditLogAuxInfo."Payment Amount"), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(CashPaymentAmount), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(CardPaymentAmount), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(OtherPaymentAmount), 13));
            AppendEmptyText(FileContent, 12);

            GetTaxAmounts(SIPOSAuditLogAuxInfo, TaxNineAmount, TaxEightAmount, TaxFiveAmount, TaxTwTwoAmount, TaxNineAmountBase, TaxEightAmountBase, TaxFiveAmountBase, TaxTwTwoAmountBase);

            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxNineAmountBase), 18));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxNineAmount), 14));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxTwTwoAmountBase), 17));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxTwTwoAmount), 13));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxFiveAmountBase), 16));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxFiveAmount), 12));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxEightAmountBase), 20));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxEightAmount), 12));
            AppendEmptyText(FileContent, 18);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 11);
            AppendEmptyText(FileContent, 11);
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."Cashier ID"), 13));
            AppendEmptyText(FileContent, 13);
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."ZOI Code"), 34));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."EOR Code"), 38));

            if SIPOSAuditLogAuxInfo."Subsequent Submit" then
                AppendTextField(FileContent, PadRightSpace('1', 10))
            else
                AppendEmptyText(FileContent, 10);

            AppendEmptyText(FileContent, 16);
            AppendEmptyText(FileContent, 16);
            AppendEmptyText(FileContent, 17);
            AppendEmptyText(FileContent, 15);
            AppendEmptyText(FileContent, 14);
            AppendEmptyText(FileContent, 15);
            AppendEmptyText(FileContent, 15);
            AppendEmptyText(FileContent, 15);
            AppendEmptyText(FileContent, 15);
            AppendEmptyText(FileContent, 15);
            AppendEmptyText(FileContent, 14);
            AppendEmptyText(FileContent, 12);

            FileContent += _CRLF;
        until SIPOSAuditLogAuxInfo.Next() = 0;
        TempBlob.CreateOutStream(OStream);
        OStream.WriteText(FileContent);

        Filename := StrSubstNo(FileNameLbl, FormatDate(StartDate), FormatDate(EndDate));
        FileMgt.BLOBExport(TempBlob, Filename, true);
    end;

    local procedure AppendCustomerInfo(var FileContent: Text; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        POSEntry: Record "NPR POS Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case SIPOSAuditLogAuxInfo."Audit Entry Type" of
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                begin
                    if not POSEntry.Get(SIPOSAuditLogAuxInfo."POS Entry No.") then begin
                        AppendEmptyText(FileContent, 52);
                        AppendEmptyText(FileContent, 22);
                        exit;
                    end;

                    AppendCustomerInfo(FileContent, POSEntry."Customer No.");
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                begin
                    if not SalesInvoiceHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.") then begin
                        AppendEmptyText(FileContent, 52);
                        AppendEmptyText(FileContent, 22);
                        exit;
                    end;

                    AppendCustomerInfo(FileContent, SalesInvoiceHeader."Sell-to Customer No.");
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                begin
                    if not SalesCrMemoHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.") then begin
                        AppendEmptyText(FileContent, 52);
                        AppendEmptyText(FileContent, 22);
                        exit;
                    end;

                    AppendCustomerInfo(FileContent, SalesCrMemoHeader."Sell-to Customer No.");
                end;
        end;
    end;

    local procedure AppendCustomerInfo(var FileContent: Text; CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then begin
            AppendEmptyText(FileContent, 52);
            AppendEmptyText(FileContent, 22);
            exit;
        end;

        if not Customer.Get(CustomerNo) then begin
            AppendEmptyText(FileContent, 52);
            AppendEmptyText(FileContent, 22);
            exit;
        end;

        AppendTextField(FileContent, PadRightSpace(Format(CopyStr(Customer.Name + ', ' + Customer.City, 1, 52)), 52));
        AppendTextField(FileContent, PadRightSpace(Format(Customer."VAT Registration No."), 22))
    end;

    #endregion SI Fiscalization Archiving - Invoice Archive

    #region SI Fiscalization Archiving - Item Archive

    internal procedure GenerateInvoiceItemArchive(StartDate: Date; EndDate: Date)
    var
        CompanyInformation: Record "Company Information";
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        ArchiveHeadingLbl: Label '"Dav st  ";"Rac dat ";"Rac cas ";"Racst pp";"Racst en";"Racst zap";"Dav st zav";"Post id   ";"Post opis                                         ";"Post kol";"Post em";"Post em cena";"Post vrednost";"Post 9,5% DDV";"Post 22% DDV";"Post 5% DDV";"Post 8% pav";"Post davki ostalo";"Post oprosc";"Post dob76a";"Post neobd";"Post poseb";"Sprem nep st";"Post opombe";', Locked = true;
        FileNameLbl: Label 'IZPIS_RAČUNI_POSTAVKE_%1-%2.txt', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        OStream: OutStream;
        FileContent: Text;
        Filename: Text;
    begin
        CompanyInformation.Get();
        InitNewLine();

        FileContent := ArchiveHeadingLbl + _CRLF;

        SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
        SIPOSAuditLogAuxInfo.SetFilter("Entry Date", DateFilterLbl, StartDate, EndDate);
        if not SIPOSAuditLogAuxInfo.FindSet() then
            exit;

        InitVATAmounts();

        repeat
            case SIPOSAuditLogAuxInfo."Audit Entry Type" of
                SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                    AppendPOSEntrySalesLineItemSale(FileContent, SIPOSAuditLogAuxInfo, CompanyInformation);
                SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                    AppendSalesInvoiceLineItemSale(FileContent, SIPOSAuditLogAuxInfo, CompanyInformation);
                SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                    AppendSalesCrMemoLineItemSale(FileContent, SIPOSAuditLogAuxInfo, CompanyInformation);
            end;
        until SIPOSAuditLogAuxInfo.Next() = 0;

        TempBlob.CreateOutStream(OStream);
        OStream.WriteText(FileContent);

        Filename := StrSubstNo(FileNameLbl, FormatDate(StartDate), FormatDate(EndDate));
        FileMgt.BLOBExport(TempBlob, Filename, true);
    end;

    local procedure AppendPOSEntrySalesLineItemSale(var FileContent: Text; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; CompanyInformation: Record "Company Information")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        TypeFilterLbl: Label '%1|%2', Locked = true, Comment = '%1 = Type Filter Value 1, %2 = Type Filter Value 2';
    begin
        POSEntrySalesLine.SetLoadFields("No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Line Discount Amount Incl. VAT", "Line Amount", "Amount Incl. VAT", "Amount Excl. VAT", "VAT %");
        POSEntrySalesLine.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, TypeFilterLbl, POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);

        if not POSEntrySalesLine.FindSet() then
            exit;
        repeat
            AppendTextField(FileContent, PadRightSpace(Format(CompanyInformation."VAT Registration No."), 10));
            AppendTextField(FileContent, PadRightSpace(FormatDate(SIPOSAuditLogAuxInfo."Entry Date"), 10));
            AppendTextField(FileContent, PadRightSpace(FormatTime(SIPOSAuditLogAuxInfo."Log Timestamp"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Store Code"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Unit No."), 10));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."Receipt No."), 11));
            AppendEmptyText(FileContent, 12);
            AppendTextField(FileContent, PadRightSpace(Format(POSEntrySalesLine."No."), 12));
            AppendTextField(FileContent, PadRightSpace(CopyStr(POSEntrySalesLine.Description, 1, 52), 52));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine.Quantity), 10));
            AppendTextField(FileContent, PadRightSpace(Format(POSEntrySalesLine."Unit of Measure Code"), 9));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine."Unit Price" - (POSEntrySalesLine."Line Discount Amount Incl. VAT" / POSEntrySalesLine.Quantity)), 14));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine."Line Amount"), 15));

            AppendVATAmountForItemSaleLine(FileContent, POSEntrySalesLine."VAT %", POSEntrySalesLine."Amount Incl. VAT", POSEntrySalesLine."Amount Excl. VAT", false);

            AppendEmptyText(FileContent, 19);
            AppendEmptyText(FileContent, 13);
            AppendEmptyText(FileContent, 13);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 14);
            AppendEmptyText(FileContent, 13);
            FileContent += _CRLF;
        until POSEntrySalesLine.Next() = 0;
    end;

    local procedure AppendSalesInvoiceLineItemSale(var FileContent: Text; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; CompanyInformation: Record "Company Information")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetLoadFields("No.", "Document No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Line Discount Amount", "Line Amount", "Amount Including VAT", "VAT %");
        SalesInvoiceLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if not SalesInvoiceLine.FindSet() then
            exit;
        repeat
            AppendTextField(FileContent, PadRightSpace(Format(CompanyInformation."VAT Registration No."), 10));
            AppendTextField(FileContent, PadRightSpace(FormatDate(SIPOSAuditLogAuxInfo."Entry Date"), 10));
            AppendTextField(FileContent, PadRightSpace(FormatTime(SIPOSAuditLogAuxInfo."Log Timestamp"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Store Code"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Unit No."), 10));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."Receipt No."), 11));
            AppendEmptyText(FileContent, 12);
            AppendTextField(FileContent, PadRightSpace(Format(SalesInvoiceLine."No."), 12));
            AppendTextField(FileContent, PadRightSpace(CopyStr(SalesInvoiceLine.Description, 1, 52), 52));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesInvoiceLine.Quantity), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SalesInvoiceLine."Unit of Measure Code"), 9));

            if SalesInvoiceLine.Quantity <> 0 then
                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesInvoiceLine."Unit Price" - (SalesInvoiceLine."Line Discount Amount" / SalesInvoiceLine.Quantity)), 14))
            else
                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesInvoiceLine."Unit Price"), 14));

            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesInvoiceLine."Line Amount"), 15));

            AppendVATAmountForItemSaleLine(FileContent, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT", SalesInvoiceLine.GetLineAmountExclVAT(), false);

            AppendEmptyText(FileContent, 19);
            AppendEmptyText(FileContent, 13);
            AppendEmptyText(FileContent, 13);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 14);
            AppendEmptyText(FileContent, 13);
            FileContent += _CRLF;
        until SalesInvoiceLine.Next() = 0;
    end;

    local procedure AppendSalesCrMemoLineItemSale(var FileContent: Text; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; CompanyInformation: Record "Company Information")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetLoadFields("No.", "Document No.", Description, Quantity, "Unit of Measure Code", "Unit Price", "Line Discount Amount", "Line Amount", "Amount Including VAT", "VAT %");
        SalesCrMemoLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if not SalesCrMemoLine.FindSet() then
            exit;
        repeat
            AppendTextField(FileContent, PadRightSpace(Format(CompanyInformation."VAT Registration No."), 10));
            AppendTextField(FileContent, PadRightSpace(FormatDate(SIPOSAuditLogAuxInfo."Entry Date"), 10));
            AppendTextField(FileContent, PadRightSpace(FormatTime(SIPOSAuditLogAuxInfo."Log Timestamp"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Store Code"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Unit No."), 10));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."Receipt No."), 11));
            AppendEmptyText(FileContent, 12);
            AppendTextField(FileContent, PadRightSpace(Format(SalesCrMemoLine."No."), 12));
            AppendTextField(FileContent, PadRightSpace(CopyStr(SalesCrMemoLine.Description, 1, 52), 52));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesCrMemoLine.Quantity), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SalesCrMemoLine."Unit of Measure Code"), 9));

            if SalesCrMemoLine.Quantity <> 0 then
                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesCrMemoLine."Unit Price" - (SalesCrMemoLine."Line Discount Amount" / SalesCrMemoLine.Quantity)), 14))
            else
                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesCrMemoLine."Unit Price"), 14));

            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SalesCrMemoLine."Line Amount"), 15));

            AppendVATAmountForItemSaleLine(FileContent, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT", SalesCrMemoLine.GetLineAmountExclVAT(), true);

            AppendEmptyText(FileContent, 19);
            AppendEmptyText(FileContent, 13);
            AppendEmptyText(FileContent, 13);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 12);
            AppendEmptyText(FileContent, 14);
            AppendEmptyText(FileContent, 13);
            FileContent += _CRLF;
        until SalesCrMemoLine.Next() = 0;
    end;

    local procedure AppendVATAmountForItemSaleLine(var FileContent: Text; VATPercentage: Decimal; AmountInclVAT: Decimal; AmountExclVAT: Decimal; Negative: Boolean)
    begin
        case FormatDecimalField(VATPercentage) of
            _StandardVATAmounts[1]:
                begin
                    AppendEmptyText(FileContent, 15);
                    AppendEmptyText(FileContent, 14);
                    if Negative then
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField((-(Abs(AmountInclVAT) - Abs(AmountExclVAT)))), 13))
                    else
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(AmountInclVAT - AmountExclVAT), 13));
                    AppendEmptyText(FileContent, 13);
                end;
            _StandardVATAmounts[2]:
                begin
                    AppendEmptyText(FileContent, 15);
                    AppendEmptyText(FileContent, 14);
                    AppendEmptyText(FileContent, 13);
                    if Negative then
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField((-(Abs(AmountInclVAT) - Abs(AmountExclVAT)))), 13))
                    else
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(AmountInclVAT - AmountExclVAT), 13));
                end;
            _StandardVATAmounts[3]:
                begin
                    if Negative then
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField((-(Abs(AmountInclVAT) - Abs(AmountExclVAT)))), 15))
                    else
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(AmountInclVAT - AmountExclVAT), 15));
                    AppendEmptyText(FileContent, 14);
                    AppendEmptyText(FileContent, 13);
                    AppendEmptyText(FileContent, 13);
                end;
            _StandardVATAmounts[4]:
                begin
                    AppendEmptyText(FileContent, 15);
                    if Negative then
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField((-(Abs(AmountInclVAT) - Abs(AmountExclVAT)))), 14))
                    else
                        AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(AmountInclVAT - AmountExclVAT), 14));
                    AppendEmptyText(FileContent, 13);
                    AppendEmptyText(FileContent, 13);
                end;
            else begin
                AppendEmptyText(FileContent, 15);
                AppendEmptyText(FileContent, 14);
                AppendEmptyText(FileContent, 13);
                AppendEmptyText(FileContent, 13);
            end;
        end;
    end;

    #endregion SI Fiscalization Archiving - Item Archive

    #region SI Fiscalization Archiving - Helper Procedures

    local procedure InitNewLine()
    begin
        _CRLF[1] := 13;
        _CRLF[2] := 10;
    end;

    local procedure InitVATAmounts()
    begin
        _StandardVATAmounts[1] := '5,00';
        _StandardVATAmounts[2] := '8,00';
        _StandardVATAmounts[3] := '9,50';
        _StandardVATAmounts[4] := '22,00';
    end;

    local procedure ClearValues(var OtherPaymentAmount: Decimal; var CardPaymentAmount: Decimal; var CashPaymentAmount: Decimal; var TaxNineAmount: Decimal; var TaxEightAmount: Decimal; var TaxFiveAmount: Decimal; var TaxTwTwoAmount: Decimal; var TaxNineAmountBase: Decimal; var TaxEightAmountBase: Decimal; var TaxFiveAmountBase: Decimal; var TaxTwTwoAmountBase: Decimal)
    begin
        Clear(OtherPaymentAmount);
        Clear(CardPaymentAmount);
        Clear(CashPaymentAmount);
        Clear(TaxNineAmount);
        Clear(TaxNineAmountBase);
        Clear(TaxFiveAmount);
        Clear(TaxFiveAmountBase);
        Clear(TaxEightAmount);
        Clear(TaxEightAmountBase);
        Clear(TaxTwTwoAmount);
        Clear(TaxTwTwoAmountBase);
    end;

    local procedure GetPaymentAmounts(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var OtherPaymentAmount: Decimal; var CardPaymentAmount: Decimal; var CashPaymentAmount: Decimal)
    var
        POSEntryPaymentLines: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case SIPOSAuditLogAuxInfo."Audit Entry Type" of
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                begin
                    POSEntryPaymentLines.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
                    POSEntryPaymentLines.SetFilter("Amount (LCY)", '>0');
                    if POSEntryPaymentLines.FindSet() then
                        repeat
                            POSPaymentMethod.Get(POSEntryPaymentLines."POS Payment Method Code");
                            case POSPaymentMethod."Processing Type" of
                                "NPR Payment Processing Type"::CASH:
                                    CashPaymentAmount += POSEntryPaymentLines."Amount (LCY)";
                                "NPR Payment Processing Type"::EFT:
                                    CardPaymentAmount += POSEntryPaymentLines."Amount (LCY)";
                                else
                                    OtherPaymentAmount += POSEntryPaymentLines."Amount (LCY)";
                            end;
                        until POSEntryPaymentLines.Next() = 0;
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                begin
                    if not SalesInvoiceHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.") then
                        exit;

                    SalesInvoiceHeader.CalcFields("Amount Including VAT");
                    OtherPaymentAmount += SalesInvoiceHeader."Amount Including VAT";
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                begin
                    if not SalesCrMemoHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.") then
                        exit;

                    SalesCrMemoHeader.CalcFields("Amount Including VAT");
                    OtherPaymentAmount += SalesCrMemoHeader."Amount Including VAT";
                end;
        end;
    end;

    local procedure GetTaxAmounts(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var TaxNineAmount: Decimal; var TaxEightAmount: Decimal; var TaxFiveAmount: Decimal; var TaxTwTwoAmount: Decimal; var TaxNineAmountBase: Decimal; var TaxEightAmountBase: Decimal; var TaxFiveAmountBase: Decimal; var TaxTwTwoAmountBase: Decimal)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        InitVATAmounts();

        case SIPOSAuditLogAuxInfo."Audit Entry Type" of
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                begin
                    POSEntryTaxLine.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
                    if not POSEntryTaxLine.FindSet() then
                        exit;
                    repeat
                        CalculateTaxAmountBasedOnPercentage(POSEntryTaxLine."Tax %", POSEntryTaxLine."Tax Base Amount", POSEntryTaxLine."Tax Amount", 0,
                                                            TaxNineAmount, TaxEightAmount, TaxFiveAmount, TaxTwTwoAmount, TaxNineAmountBase, TaxEightAmountBase, TaxFiveAmountBase, TaxTwTwoAmountBase);
                    until POSEntryTaxLine.Next() = 0;
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                begin
                    SalesInvoiceLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
                    if not SalesInvoiceLine.FindSet() then
                        exit;
                    repeat
                        CalculateTaxAmountBasedOnPercentage(SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount", SalesInvoiceLine."Amount Including VAT", SalesInvoiceLine.GetLineAmountExclVAT(),
                                                            TaxNineAmount, TaxEightAmount, TaxFiveAmount, TaxTwTwoAmount, TaxNineAmountBase, TaxEightAmountBase, TaxFiveAmountBase, TaxTwTwoAmountBase);
                    until SalesInvoiceLine.Next() = 0;
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                begin
                    SalesCrMemoLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
                    if not SalesCrMemoLine.FindSet() then
                        exit;
                    repeat
                        CalculateTaxAmountBasedOnPercentage(SalesCrMemoLine."VAT %", SalesCrMemoLine."VAT Base Amount", SalesCrMemoLine."Amount Including VAT", SalesCrMemoLine.GetLineAmountExclVAT(),
                                                            TaxNineAmount, TaxEightAmount, TaxFiveAmount, TaxTwTwoAmount, TaxNineAmountBase, TaxEightAmountBase, TaxFiveAmountBase, TaxTwTwoAmountBase);
                    until SalesCrMemoLine.Next() = 0;
                end;
        end;
    end;

    local procedure CalculateTaxAmountBasedOnPercentage(VATPerc: Decimal; VATBaseAmount: Decimal; AmountInclVAT: Decimal; AmountExclVAT: Decimal;
                                                        var TaxNineAmount: Decimal; var TaxEightAmount: Decimal; var TaxFiveAmount: Decimal; var TaxTwTwoAmount: Decimal;
                                                        var TaxNineAmountBase: Decimal; var TaxEightAmountBase: Decimal; var TaxFiveAmountBase: Decimal; var TaxTwTwoAmountBase: Decimal)
    begin
        case FormatDecimalField(VATPerc) of
            _StandardVATAmounts[1]:
                begin
                    TaxFiveAmount += AmountInclVAT - AmountExclVAT;
                    TaxFiveAmountBase += VATBaseAmount;
                end;
            _StandardVATAmounts[2]:
                begin
                    TaxEightAmount += AmountInclVAT - AmountExclVAT;
                    TaxEightAmountBase += VATBaseAmount;
                end;
            _StandardVATAmounts[3]:
                begin
                    TaxNineAmount += AmountInclVAT - AmountExclVAT;
                    TaxNineAmountBase += VATBaseAmount;
                end;
            _StandardVATAmounts[4]:
                begin
                    TaxTwTwoAmount += AmountInclVAT - AmountExclVAT;
                    TaxTwTwoAmountBase += VATBaseAmount;
                end;
        end;
    end;

    #endregion SI Fiscalization Archiving - Helper Procedures

    #region SI Fiscalization Archiving - Formatting

    local procedure FormatDecimalField(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,,>'))
    end;

    local procedure FormatDate(DateValue: Date): Text
    begin
        exit(Format(DateValue, 8, '<Year4><Month,2><Day,2>'));
    end;

    local procedure FormatTime(TimeValue: Time): Text
    begin
        exit(Format(TimeValue, 8, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure PadLeftSpace(Value: Text; Count: Integer): Text
    begin
        exit(Value.PadLeft(Count, ' '));
    end;

    local procedure PadRightSpace(Value: Text; Count: Integer): Text
    begin
        exit(Value.PadRight(Count, ' '));
    end;

    local procedure AppendTextField(var Destination: Text; FieldValue: Text)
    var
        SemicolonSeparatorLbl: Label ';', Locked = true;
    begin
        Destination += FieldValue + SemicolonSeparatorLbl;
    end;

    local procedure AppendEmptyText(var FileContent: Text; Length: Integer)
    begin
        AppendTextField(FileContent, PadRightSpace('', Length));
    end;

    #endregion SI Fiscalization Archiving - Formatting
}