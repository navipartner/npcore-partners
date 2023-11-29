codeunit 6184590 "NPR SI Archive Mgt."
{
    Access = Internal;

    var
        DateFilterLbl: Label '%1..%2', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        StandardVATAmounts: array[4] of Text;

    #region SI Fiscalization - Archiving

    local procedure FormatDecimalField(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,,>'))
    end;

    local procedure InitVATAmounts()
    begin
        StandardVATAmounts[1] := '5,00';
        StandardVATAmounts[2] := '8,00';
        StandardVATAmounts[3] := '9,50';
        StandardVATAmounts[4] := '22,00';
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

    local procedure GetPaymentAmounts(POSEntry: Record "NPR POS Entry"; var OtherPaymentAmount: Decimal; var CardPaymentAmount: Decimal; var CashPaymentAmount: Decimal)
    var
        POSEntryPaymentLines: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSEntryPaymentLines.SetRange("POS Entry No.", POSEntry."Entry No.");
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

    local procedure GetTaxAmounts(var POSEntry: Record "NPR POS Entry"; var TaxNineAmount: Decimal; var TaxEightAmount: Decimal; var TaxFiveAmount: Decimal; var TaxTwTwoAmount: Decimal; var TaxNineAmountBase: Decimal; var TaxEightAmountBase: Decimal; var TaxFiveAmountBase: Decimal; var TaxTwTwoAmountBase: Decimal)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if not POSEntryTaxLine.FindSet() then
            exit;
        InitVATAmounts();
        repeat
            case FormatDecimalField(POSEntryTaxLine."Tax %") of
                StandardVATAmounts[1]:
                    begin
                        TaxFiveAmount += POSEntryTaxLine."Tax Amount";
                        TaxFiveAmountBase += POSEntryTaxLine."Tax Base Amount";
                    end;
                StandardVATAmounts[2]:
                    begin
                        TaxEightAmount += POSEntryTaxLine."Tax Amount";
                        TaxEightAmountBase += POSEntryTaxLine."Tax Base Amount";
                    end;
                StandardVATAmounts[3]:
                    begin
                        TaxNineAmount += POSEntryTaxLine."Tax Amount";
                        TaxNineAmountBase += POSEntryTaxLine."Tax Base Amount";
                    end;
                StandardVATAmounts[4]:
                    begin
                        TaxTwTwoAmount += POSEntryTaxLine."Tax Amount";
                        TaxTwTwoAmountBase += POSEntryTaxLine."Tax Base Amount";
                    end;
            end;
        until POSEntryTaxLine.Next() = 0;
    end;

    internal procedure GenerateInvoiceArchive(StartDate: Date; EndDate: Date)
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
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
        FileNameLbl: Label 'IZPIS RAČUNI GLAVE.txt', Locked = true;
        FixedCharLbl: Label 'C', Locked = true;
        OStream: OutStream;
        CRLF: Text;
        FileContent: Text;
        Filename: Text;
    begin
        CompanyInformation.Get();
        CRLF[1] := 13;
        CRLF[2] := 10;
        FileContent := ArchiveHeaderLbl + CRLF;
        SIPOSAuditLogAuxInfo.SetFilter("Entry Date", DateFilterLbl, StartDate, EndDate);
        if not SIPOSAuditLogAuxInfo.FindSet() then
            exit;
        repeat
            ClearValues(OtherPaymentAmount, CardPaymentAmount, CashPaymentAmount, TaxNineAmount, TaxEightAmount, TaxFiveAmount, TaxTwTwoAmount, TaxNineAmountBase, TaxEightAmountBase, TaxFiveAmountBase, TaxTwTwoAmountBase);
            AppendTextField(FileContent, PadRightSpace(Format(CompanyInformation."VAT Registration No."), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."Entry Date", 8, '<Year4><Month,2><Day,2>'), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."Log Timestamp", 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>'), 10));
            AppendTextField(FileContent, PadRightSpace(FixedCharLbl, 9));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Store Code"), 10));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Unit No."), 10));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."Receipt No."), 11));
            POSEntry.SetCurrentKey("Entry No.");
            POSEntry.SetRange("Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
            if not POSEntry.FindFirst() then
                exit;
            if Customer.Get(POSEntry."Customer No.") then begin
                AppendTextField(FileContent, PadRightSpace(Format(CopyStr(Customer.Name + ', ' + Customer.City, 1, 52)), 52));
                AppendTextField(FileContent, PadRightSpace(Format(Customer."VAT Registration No."), 22))
            end
            else begin
                AppendTextField(FileContent, PadRightSpace('', 52));
                AppendTextField(FileContent, PadRightSpace('', 22));
            end;

            GetPaymentAmounts(POSEntry, OtherPaymentAmount, CardPaymentAmount, CashPaymentAmount);

            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SIPOSAuditLogAuxInfo."Total Amount"), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SIPOSAuditLogAuxInfo."Returns Amount"), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(SIPOSAuditLogAuxInfo."Payment Amount"), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(CashPaymentAmount), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(CardPaymentAmount), 11));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(OtherPaymentAmount), 13));
            AppendTextField(FileContent, PadLeftSpace('', 12));

            GetTaxAmounts(POSEntry, TaxNineAmount, TaxEightAmount, TaxFiveAmount, TaxTwTwoAmount, TaxNineAmountBase, TaxEightAmountBase, TaxFiveAmountBase, TaxTwTwoAmountBase);

            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxNineAmountBase), 18));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxNineAmount), 14));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxTwTwoAmountBase), 17));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxTwTwoAmount), 13));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxFiveAmountBase), 16));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxFiveAmount), 12));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxEightAmountBase), 20));
            AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(TaxEightAmount), 12));
            AppendTextField(FileContent, PadLeftSpace(' ', 18));
            AppendTextField(FileContent, PadLeftSpace(' ', 12));
            AppendTextField(FileContent, PadLeftSpace(' ', 12));
            AppendTextField(FileContent, PadLeftSpace(' ', 11));
            AppendTextField(FileContent, PadLeftSpace(' ', 11));
            AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."Cashier ID"), 13));
            AppendTextField(FileContent, PadRightSpace(' ', 13));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."ZOI Code"), 34));
            AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."EOR Code"), 38));

            if SIPOSAuditLogAuxInfo."Subsequent Submit" then
                AppendTextField(FileContent, PadRightSpace('1', 10))
            else
                AppendTextField(FileContent, PadRightSpace(' ', 10));

            AppendTextField(FileContent, PadLeftSpace(' ', 16));
            AppendTextField(FileContent, PadLeftSpace(' ', 16));
            AppendTextField(FileContent, PadLeftSpace(' ', 17));
            AppendTextField(FileContent, PadLeftSpace(' ', 15));
            AppendTextField(FileContent, PadLeftSpace(' ', 14));
            AppendTextField(FileContent, PadLeftSpace(' ', 15));
            AppendTextField(FileContent, PadLeftSpace(' ', 15));
            AppendTextField(FileContent, PadLeftSpace(' ', 15));
            AppendTextField(FileContent, PadLeftSpace(' ', 15));
            AppendTextField(FileContent, PadLeftSpace(' ', 15));
            AppendTextField(FileContent, PadLeftSpace(' ', 14));
            AppendTextField(FileContent, PadLeftSpace(' ', 12));

            FileContent += CRLF;
        until SIPOSAuditLogAuxInfo.Next() = 0;
        TempBlob.CreateOutStream(OStream);
        OStream.WriteText(FileContent);

        Filename := FileNameLbl;
        FileMgt.BLOBExport(TempBlob, Filename, true);
    end;

    internal procedure GenerateInvoiceItemArchive(StartDate: Date; EndDate: Date)
    var
        CompanyInformation: Record "Company Information";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        ArchiveHeadingLbl: Label '"Dav st  ";"Rac dat ";"Rac cas ";"Racst pp";"Racst en";"Racst zap";"Dav st zav";"Post id   ";"Post opis                                         ";"Post kol";"Post em";"Post em cena";"Post vrednost";"Post 9,5% DDV";"Post 22% DDV";"Post 5% DDV";"Post 8% pav";"Post davki ostalo";"Post oprosc";"Post dob76a";"Post neobd";"Post poseb";"Sprem nep st";"Post opombe";', Locked = true;
        FileNameLbl: Label 'IZPIS RAČUNI POSTAVKE.txt', Locked = true;
        POSEntrySalesLineType: Option Comment,"G/L Account",Item,Customer,Voucher,Payout,Rounding;
        OStream: OutStream;
        CRLF: Text;
        FileContent: Text;
        Filename: Text;
    begin
        CompanyInformation.Get();
        CRLF[1] := 13;
        CRLF[2] := 10;
        FileContent := ArchiveHeadingLbl + CRLF;
        SIPOSAuditLogAuxInfo.SetFilter("Entry Date", DateFilterLbl, StartDate, EndDate);
        if not SIPOSAuditLogAuxInfo.FindSet() then
            exit;
        InitVATAmounts();
        repeat
            POSEntrySalesLine.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLineType::Item);
            if POSEntrySalesLine.FindSet() then
                repeat
                    AppendTextField(FileContent, PadRightSpace(Format(CompanyInformation."VAT Registration No."), 10));
                    AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."Entry Date", 8, '<Year4><Month,2><Day,2>'), 10));
                    AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."Log Timestamp", 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>'), 10));
                    AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Store Code"), 10));
                    AppendTextField(FileContent, PadRightSpace(Format(SIPOSAuditLogAuxInfo."POS Unit No."), 10));
                    AppendTextField(FileContent, PadLeftSpace(Format(SIPOSAuditLogAuxInfo."Receipt No."), 11));
                    AppendTextField(FileContent, PadLeftSpace(' ', 12));
                    AppendTextField(FileContent, PadRightSpace(Format(POSEntrySalesLine."No."), 12));
                    AppendTextField(FileContent, PadRightSpace(CopyStr(POSEntrySalesLine.Description, 1, 52), 52));
                    AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine.Quantity), 10));
                    AppendTextField(FileContent, PadRightSpace(Format(POSEntrySalesLine."Unit of Measure Code"), 9));
                    AppendTextField(FileContent, FormatDecimalField(POSEntrySalesLine."Unit Price" - POSEntrySalesLine."Line Discount Amount Incl. VAT").PadLeft(14, ' '));
                    AppendTextField(FileContent, FormatDecimalField(POSEntrySalesLine."Line Amount").PadLeft(15, ' '));
                    case FormatDecimalField(POSEntrySalesLine."VAT %") of
                        StandardVATAmounts[1]:
                            begin
                                AppendTextField(FileContent, PadLeftSpace(' ', 15));
                                AppendTextField(FileContent, PadLeftSpace(' ', 14));
                                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT"), 13));
                                AppendTextField(FileContent, PadLeftSpace(' ', 13));
                            end;
                        StandardVATAmounts[2]:
                            begin
                                AppendTextField(FileContent, PadLeftSpace(' ', 15));
                                AppendTextField(FileContent, PadLeftSpace(' ', 14));
                                AppendTextField(FileContent, PadLeftSpace(' ', 13));
                                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT"), 13));
                            end;
                        StandardVATAmounts[3]:
                            begin
                                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT"), 15));
                                AppendTextField(FileContent, PadLeftSpace(' ', 14));
                                AppendTextField(FileContent, PadLeftSpace(' ', 13));
                                AppendTextField(FileContent, PadLeftSpace(' ', 13));
                            end;
                        StandardVATAmounts[4]:
                            begin
                                AppendTextField(FileContent, PadLeftSpace(' ', 15));
                                AppendTextField(FileContent, PadLeftSpace(FormatDecimalField(POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT"), 14));
                                AppendTextField(FileContent, PadLeftSpace(' ', 13));
                                AppendTextField(FileContent, PadLeftSpace(' ', 13));
                            end;
                        else begin
                            AppendTextField(FileContent, PadLeftSpace(' ', 15));
                            AppendTextField(FileContent, PadLeftSpace(' ', 14));
                            AppendTextField(FileContent, PadLeftSpace(' ', 13));
                            AppendTextField(FileContent, PadLeftSpace(' ', 13));
                        end;
                    end;

                    AppendTextField(FileContent, PadLeftSpace(' ', 19));
                    AppendTextField(FileContent, PadLeftSpace(' ', 13));
                    AppendTextField(FileContent, PadLeftSpace(' ', 13));
                    AppendTextField(FileContent, PadLeftSpace(' ', 12));
                    AppendTextField(FileContent, PadLeftSpace(' ', 12));
                    AppendTextField(FileContent, PadLeftSpace(' ', 14));
                    AppendTextField(FileContent, PadLeftSpace(' ', 13));
                    FileContent += CRLF;
                until POSEntrySalesLine.Next() = 0;
        until SIPOSAuditLogAuxInfo.Next() = 0;
        TempBlob.CreateOutStream(OStream);
        OStream.WriteText(FileContent);

        Filename := FileNameLbl;
        FileMgt.BLOBExport(TempBlob, Filename, true);
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

    #endregion
}