codeunit 6185032 "NPR RS Local Excel Mgt."
{
    Access = Internal;

    var
        TempExcelBuf: Record "Excel Buffer" temporary;
        _StartDate, _EndDate : Date;

    internal procedure SetDates(StartDate: Date; EndDate: Date)
    begin
        _StartDate := StartDate;
        _EndDate := EndDate;
    end;

    #region RS Local Excel Mgt. - Book of Outgoing Invoices Export

    internal procedure ExportOutgoingInvoicesExcel()
    begin
        CreateOutgoingInvExcelBuffer();
        ExportOutgoingInvExcelBuffer();
    end;

    local procedure CreateOutgoingInvExcelBuffer()
    begin
        TempExcelBuf.Reset();
        TempExcelBuf.DeleteAll();
        TempExcelBuf.NewRow();

        AddOutgoingInvHeadings();

        AddOutgoingInvDataRows();
    end;

    local procedure ExportOutgoingInvExcelBuffer()
    var
        BookOfOutgoingInvoicesLbl: Label 'Knjiga izdatih računa', Locked = true;
        ExcelFileName: Label 'Knjiga_izdatih_računa_%1_%2', Locked = true;
    begin
        TempExcelBuf.CreateNewBook(BookOfOutgoingInvoicesLbl);
        TempExcelBuf.WriteSheet(BookOfOutgoingInvoicesLbl, CompanyName, UserId);
        TempExcelBuf.CloseBook();
        TempExcelBuf.SetFriendlyFilename(StrSubstNo(ExcelFileName, FormatDate(_StartDate), FormatDate(_EndDate)));
        TempExcelBuf.OpenExcel();
    end;
    local procedure AddOutgoingInvHeadings()
    begin
        AddColumn('Red. Broj', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Datum knjizenja', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Broj racuna', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Datum izdavanja racuna (ili drugog dok.)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Naziv (ime i sediste)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('PIB ili JMBG', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Ukupna naknada sa PDV', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Oslobođen promet sa pravom na odbitak prethodnog poreza (čl.24. Zakona) i drugi osl. promet', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Oslobođen promet bez prava na odbitak prethodnog poreza (čl. 25. Zakona)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Promet u inostranstvu za koji bi postojalo pravo na prethodni porez da je promet izvršen i zemlji (tačka 8.*)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Promet u inostranstvu za koji ne bi postojalo pravo na pret. porez da je promet izvršen u zemlji (tačka 10.*)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Po stopi od 20% osnovica tačka (3.*)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Po stopi od 20% iznos PDV (tačka 5.*)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Po stopi od 10% osnovica tačka (4.*)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Po stopi od 10% iznos PDV (tačka 6.*)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Ukupan promet dobara i usluga sa pravom i bez prava na odbitak prethodnog poreza bez PDV', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Promet dobara i usluga sa pravom na odbitak prethodnog poreza bez PDV', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('POPDV Identif.', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
    end;

    local procedure AddOutgoingInvDataRows()
    var
        VATReportMapping: Record "NPR VAT Report Mapping";
        TotalAmounts: array[13] of Decimal;
        RowNo: Integer;
    begin
        RowNo := 1;

        if not VATReportMapping.FindSet() then
            exit;

        repeat
            if (VATReportMapping."Book of Out. Inv. Amount" <> VATReportMapping."Book of Out. Inv. Amount"::" ") and (VATReportMapping."Book of Out. Inv. Base" <> VATReportMapping."Book of Out. Inv. Base"::" ") then
                AddRSVATEntryOutgoingData(VATReportMapping, RowNo, TotalAmounts);
        until VATReportMapping.Next() = 0;

        AddOutgoingInvTotalsRow(TotalAmounts);
    end;

    local procedure AddRSVATEntryOutgoingData(VATReportMapping: Record "NPR VAT Report Mapping"; var RowNo: Integer; var TotalAmounts: array[13] of Decimal)
    var
        RSVATEntry: Record "NPR RS VAT Entry";
        AmtsArr: array[8] of Decimal;
    begin
        RSVATEntry.SetFilter("Document Type", '%1|%2', RSVATEntry."Document Type"::Invoice, RSVATEntry."Document Type"::"Credit Memo");
        RSVATEntry.SetRange(Type, RSVATEntry.Type::Sale);
        RSVATEntry.SetRange("Posting Date", _StartDate, _EndDate);
        RSVATEntry.SetRange("VAT Report Mapping", VATReportMapping.Code);
        if not RSVATEntry.FindSet() then
            exit;
        repeat
            TempExcelBuf.NewRow();
            FormatOutgoingInvAmounts(AmtsArr, VATReportMapping, RSVATEntry);
            AddOutgoingTotals(AmtsArr, RSVATEntry, TotalAmounts);
            AddColumn(RowNo, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(RSVATEntry."Posting Date", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Date);
            AddColumn(RSVATEntry."Document No.", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
            AddColumn(RSVATEntry."Document Date", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Date);
            AddColumn(GetBillToDetails(RSVATEntry), false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(RSVATEntry."VAT Registration No.", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(Abs(RSVATEntry.Base) + Abs(RSVATEntry.Amount), false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[1], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[2], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[3], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[4], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[5], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[6], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[7], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[8], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(TotalAmounts[12], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(TotalAmounts[13], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(VATReportMapping.Code, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
            RowNo += 1;
        until RSVATEntry.Next() = 0;
    end;

    local procedure FormatOutgoingInvAmounts(var AmtsArr: array[8] of Decimal; VATReportMapping: Record "NPR VAT Report Mapping"; RSVATEntry: Record "NPR RS VAT Entry")
    begin
        Clear(AmtsArr);

        case VATReportMapping."Book of Out. Inv. Amount" of
            VATReportMapping."Book of Out. Inv. Amount"::"8":
                AmtsArr[1] := Abs(RSVATEntry.Amount);
            VATReportMapping."Book of Out. Inv. Amount"::"9":
                AmtsArr[2] := Abs(RSVATEntry.Amount);
            VATReportMapping."Book of Out. Inv. Amount"::"10":
                AmtsArr[3] := Abs(RSVATEntry.Amount);
            VATReportMapping."Book of Out. Inv. Amount"::"11":
                AmtsArr[4] := Abs(RSVATEntry.Amount);
            VATReportMapping."Book of Out. Inv. Amount"::"12":
                AmtsArr[5] := Abs(RSVATEntry.Amount);
            VATReportMapping."Book of Out. Inv. Amount"::"13":
                AmtsArr[6] := Abs(RSVATEntry.Amount);
            VATReportMapping."Book of Out. Inv. Amount"::"14":
                AmtsArr[7] := Abs(RSVATEntry.Amount);
            VATReportMapping."Book of Out. Inv. Amount"::"15":
                AmtsArr[8] := Abs(RSVATEntry.Amount);
        end;

        case VATReportMapping."Book of Out. Inv. Base" of
            VATReportMapping."Book of Out. Inv. Base"::"8":
                AmtsArr[1] := Abs(RSVATEntry.Base);
            VATReportMapping."Book of Out. Inv. Base"::"9":
                AmtsArr[2] := Abs(RSVATEntry.Base);
            VATReportMapping."Book of Out. Inv. Base"::"10":
                AmtsArr[3] := Abs(RSVATEntry.Base);
            VATReportMapping."Book of Out. Inv. Base"::"11":
                AmtsArr[4] := Abs(RSVATEntry.Base);
            VATReportMapping."Book of Out. Inv. Base"::"12":
                AmtsArr[5] := Abs(RSVATEntry.Base);
            VATReportMapping."Book of Out. Inv. Base"::"13":
                AmtsArr[6] := Abs(RSVATEntry.Base);
            VATReportMapping."Book of Out. Inv. Base"::"14":
                AmtsArr[7] := Abs(RSVATEntry.Base);
            VATReportMapping."Book of Out. Inv. Base"::"15":
                AmtsArr[8] := Abs(RSVATEntry.Base);
        end;
    end;

    local procedure AddOutgoingTotals(AmtsArr: array[8] of Decimal; RSVATEntry: Record "NPR RS VAT Entry"; var TotalAmounts: array[13] of Decimal)
    begin
        Clear(TotalAmounts[12]);
        Clear(TotalAmounts[13]);
        TotalAmounts[12] := AmtsArr[1] + AmtsArr[2] + AmtsArr[5] + AmtsArr[7];
        TotalAmounts[13] := AmtsArr[1] + AmtsArr[5] + AmtsArr[7];

        TotalAmounts[1] += AmtsArr[1];
        TotalAmounts[2] += AmtsArr[2];
        TotalAmounts[3] += AmtsArr[3];
        TotalAmounts[4] += AmtsArr[4];
        TotalAmounts[5] += AmtsArr[5];
        TotalAmounts[6] += AmtsArr[6];
        TotalAmounts[7] += AmtsArr[7];
        TotalAmounts[8] += AmtsArr[8];
        TotalAmounts[9] += TotalAmounts[12];
        TotalAmounts[10] += TotalAmounts[13];
        TotalAmounts[11] += Abs(RSVATEntry.Base + RSVATEntry.Amount);
    end;

    local procedure AddOutgoingInvTotalsRow(TotalAmounts: array[13] of Decimal)
    begin
        TempExcelBuf.NewRow();
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn(TotalAmounts[11], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[1], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[2], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[3], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[4], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[5], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[6], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[7], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[8], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[9], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[10], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
    end;

    local procedure GetBillToDetails(RSVATEntry: Record "NPR RS VAT Entry"): Text
    var
        Customer: Record Customer;
        BillToDetailsFormatLbl: Label '%1, %2 %3 %4', Locked = true, Comment = '%1 = Customer Name, %2 = Customer Address, %3 = Customer Post Code, %4 = Customer City';
    begin
        if Customer.Get(RSVATEntry."Bill-to/Pay-to No.") and (StrLen(Customer.Address + Customer."Post Code" + Customer.City) > 0) then
            exit(StrSubstNo(BillToDetailsFormatLbl, Customer.Name, Customer.Address, Customer."Post Code", Customer.City))
        else
            exit(Customer.Name);
    end;

    #endregion RS Local Excel Mgt. - Book of Outgoing Invoices Export

    #region RS Local Excel Mgt. - Book Of Incoming Invoices Export

    internal procedure ExportIncomingInvoicesExcel()
    begin
        CreateIncomingInvExcelBuffer();
        ExportIncomingInvExcelBuffer();
    end;

    local procedure CreateIncomingInvExcelBuffer()
    begin
        TempExcelBuf.Reset();
        TempExcelBuf.DeleteAll();
        TempExcelBuf.NewRow();

        AddIncomingInvHeadings();

        AddIncomingInvDataRows();
    end;

    local procedure ExportIncomingInvExcelBuffer()
    var
        BookOfIncomingInvoicesLbl: Label 'Knjiga primljenih računa', Locked = true;
        ExcelFileName: Label 'Knjiga_primljenih_računa_%1_%2', Locked = true;
    begin
        TempExcelBuf.CreateNewBook(BookOfIncomingInvoicesLbl);
        TempExcelBuf.WriteSheet(BookOfIncomingInvoicesLbl, CompanyName, UserId);
        TempExcelBuf.CloseBook();
        TempExcelBuf.SetFriendlyFilename(StrSubstNo(ExcelFileName, FormatDate(_StartDate), FormatDate(_EndDate)));
        TempExcelBuf.OpenExcel();
    end;

    local procedure AddIncomingInvHeadings()
    begin
        AddColumn('Red. Broj', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Knjizenja isprave', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Prijema carinske isprave i placanje naknade poljop.', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Broj racuna', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Datum izdavanja racuna (ili drugog dok.)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Naziv (ime i sediste)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('PIB ili JMBG', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Ukupna naknada sa PDV (tac. 16)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Oslobodjene nabavke i nabavke od lica koja nisu obveznici PDV (tac. 15 i 18)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Naknada za uvezena dobra na koje se ne placa PDV (tac. 22)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Naknada bez PDV (na koju je obracunat PDV koji se moze odbiti)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Ukupan iznos obracunatog prethodnog PDV (tac. 17)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Iznos prethodnog PDV koji se moze odbiti', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Iznos prethodnog PDV koji se ne moze odbiti', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Vrednost bez PDV (tac. 21)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Iznos PDV (tac. 23)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Vrednost primljenih dobara i usluga (tac. 25)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('Iznos naknade od 5% (tac. 24)', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('POPDV Identif.', false, '', true, false, false, '', TempExcelBuf."Cell Type"::Text);
    end;

    local procedure AddIncomingInvDataRows()
    var
        VATReportMapping: Record "NPR VAT Report Mapping";
        TotalAmounts: array[9] of Decimal;
        RowNo: Integer;
    begin
        RowNo := 1;

        if not VATReportMapping.FindSet() then
            exit;

        repeat
            if (VATReportMapping."Book of Inc. Inv. Amount" <> VATReportMapping."Book of Inc. Inv. Amount"::" ") and (VATReportMapping."Book of Inc. Inv. Base" <> VATReportMapping."Book of Inc. Inv. Base"::" ") then
                AddRSVATEntryIncomingData(VATReportMapping, RowNo, TotalAmounts);
        until VATReportMapping.Next() = 0;

        AddIncomingInvTotalsRow(TotalAmounts);
    end;

    local procedure AddRSVATEntryIncomingData(VATReportMapping: Record "NPR VAT Report Mapping"; var RowNo: Integer; var TotalAmounts: array[9] of Decimal)
    var
        RSVATEntry: Record "NPR RS VAT Entry";
        AmtsArr: array[8] of Decimal;
        BaseValue: Decimal;
    begin
        RSVATEntry.SetFilter("Document Type", '%1|%2', RSVATEntry."Document Type"::Invoice, RSVATEntry."Document Type"::"Credit Memo");
        RSVATEntry.SetRange(Type, RSVATEntry.Type::Purchase);
        RSVATEntry.SetRange("Posting Date", _StartDate, _EndDate);
        RSVATEntry.SetRange("VAT Report Mapping", VATReportMapping.Code);
        if not RSVATEntry.FindSet() then
            exit;
        repeat
            TempExcelBuf.NewRow();
            FormatIncomingInvAmounts(AmtsArr, BaseValue, VATReportMapping, RSVATEntry);
            AddIncomingTotals(AmtsArr, BaseValue, RSVATEntry.Amount, TotalAmounts);
            AddColumn(RowNo, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(RSVATEntry."Posting Date", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Date);
            AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(RSVATEntry."Document No.", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
            AddColumn(RSVATEntry."Document Date", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Date);
            AddColumn(GetPaymentDetails(RSVATEntry), false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(RSVATEntry."VAT Registration No.", false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(BaseValue + RSVATEntry.Amount, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[1], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[2], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[3], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[4], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[5], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[6], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[7], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(AmtsArr[8], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(0.00, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(0.00, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
            AddColumn(VATReportMapping.Code, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
            RowNo += 1;
        until RSVATEntry.Next() = 0;
    end;

    local procedure AddIncomingInvTotalsRow(var TotalAmounts: array[9] of Decimal)
    begin
        TempExcelBuf.NewRow();
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[1], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[2], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[3], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[4], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[5], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[6], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[7], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[8], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(TotalAmounts[9], false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(0.00, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn(0.00, false, '', false, false, false, '', TempExcelBuf."Cell Type"::Number);
        AddColumn('', false, '', false, false, false, '', TempExcelBuf."Cell Type"::Text);
    end;

    local procedure FormatIncomingInvAmounts(var AmtsArr: array[8] of Decimal; var BaseValue: Decimal; VATReportMapping: Record "NPR VAT Report Mapping"; RSVATEntry: Record "NPR RS VAT Entry")
    begin
        Clear(AmtsArr);
        Clear(BaseValue);

        case VATReportMapping."Book of Inc. Inv. Amount" of
            VATReportMapping."Book of Inc. Inv. Amount"::"9":
                AmtsArr[1] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
            VATReportMapping."Book of Inc. Inv. Amount"::"10":
                AmtsArr[2] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
            VATReportMapping."Book of Inc. Inv. Amount"::"11":
                AmtsArr[3] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
            VATReportMapping."Book of Inc. Inv. Amount"::"12":
                AmtsArr[4] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
            VATReportMapping."Book of Inc. Inv. Amount"::"13":
                AmtsArr[5] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
            VATReportMapping."Book of Inc. Inv. Amount"::"14":
                AmtsArr[6] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
            VATReportMapping."Book of Inc. Inv. Amount"::"15":
                AmtsArr[7] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
            VATReportMapping."Book of Inc. Inv. Amount"::"16":
                AmtsArr[8] := RSVATEntry.Amount + RSVATEntry."Unrealized Amount" + RSVATEntry."Non-Deductible VAT Amount";
        end;

        if RSVATEntry.Base <> 0 then
            BaseValue := RSVATEntry.Base
        else
            BaseValue := RSVATEntry."VAT Base Full VAT";

        case VATReportMapping."Book of Inc. Inv. Base" of
            VATReportMapping."Book of Inc. Inv. Base"::"9":
                AmtsArr[1] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
            VATReportMapping."Book of Inc. Inv. Base"::"10":
                AmtsArr[2] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
            VATReportMapping."Book of Inc. Inv. Base"::"11":
                AmtsArr[3] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
            VATReportMapping."Book of Inc. Inv. Base"::"12":
                AmtsArr[4] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
            VATReportMapping."Book of Inc. Inv. Base"::"13":
                AmtsArr[5] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
            VATReportMapping."Book of Inc. Inv. Base"::"14":
                AmtsArr[6] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
            VATReportMapping."Book of Inc. Inv. Base"::"15":
                AmtsArr[7] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
            VATReportMapping."Book of Inc. Inv. Base"::"16":
                AmtsArr[8] := BaseValue + RSVATEntry."Non-Deductible VAT Base";
        end;
    end;

    local procedure AddIncomingTotals(AmtsArr: array[8] of Decimal; BaseValue: Decimal; Amount: Decimal; var TotalAmounts: array[9] of Decimal)
    begin
        TotalAmounts[1] += BaseValue + Amount;
        TotalAmounts[2] += AmtsArr[1];
        TotalAmounts[3] += AmtsArr[2];
        TotalAmounts[4] += AmtsArr[3];
        TotalAmounts[5] += AmtsArr[4];
        TotalAmounts[6] += AmtsArr[5];
        TotalAmounts[7] += AmtsArr[6];
        TotalAmounts[8] += AmtsArr[7];
        TotalAmounts[9] += AmtsArr[8];
    end;

    local procedure GetPaymentDetails(RSVATEntry: Record "NPR RS VAT Entry"): Text
    var
        Vendor: Record Vendor;
        PaymentDetailsFormatLbl: Label '%1, %2 %3 %4', Locked = true, Comment = '%1 = Vendor Name, %2 = Vendor Address, %3 = Vendor Post Code, %4 = Vendor City';
    begin
        if Vendor.Get(RSVATEntry."Bill-to/Pay-to No.") and (StrLen(Vendor.Address + Vendor."Post Code" + Vendor.City) > 0) then
            exit(StrSubstNo(PaymentDetailsFormatLbl, Vendor.Name, Vendor.Address, Vendor."Post Code", Vendor.City))
        else
            exit(Vendor.Name);
    end;

    #endregion RS Local Excel Mgt. - Book Of Incoming Invoices

    #region RS Local Excel Mgt. - Helper Procedures

    local procedure AddColumn(Value: Variant; IsFormula: Boolean; CommentText: Text; IsBold: Boolean; IsItalics: Boolean; IsUnderline: Boolean; NumFormat: Text[30]; CellType: Option)
    begin
        TempExcelBuf.AddColumn(Value, IsFormula, CommentText, IsBold, IsItalics, IsUnderline, NumFormat, CellType);
    end;

    local procedure FormatDate(InputDate: Date):Text
    begin
        exit(Format(InputDate, 0,'<Day,2>-<Month,2>-<Year4>'));
    end;

    #endregion RS Local Excel Mgt. - Helper Procedures
}