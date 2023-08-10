report 6014464 "NPR Book Of Outgoing Invoices"
{
    Caption = 'Book of Outgoing Invoices';
    UsageCategory = None;
#IF NOT BC17
    Extensible = false;
#ENDIF
    WordLayout = './src/Localizations/[RS] Localization/InvoiceBooks/BookOfOutgoingInvoices.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(VATReportMapping; "NPR VAT Report Mapping")
        {
            DataItemTableView = sorting(Code);
            PrintOnlyIfDetail = true;
            RequestFilterFields = Code;
            RequestFilterHeading = 'POPDV Identificator';

            column(Company_Name; _CompanyInformation.Name) { }
            column(Company_VATRegistrationNo; _CompanyInformation."VAT Registration No.") { }
            column(Company_Address; _CompanyAddress) { }
            column(Global_PeriodFilterTxtLbl; StrSubstNo(_PeriodFilterTxtLbl, Format(_StartDate, 0, 1), Format(_EndDate, 0, 1))) { }
            column(VATReportMapping_Code; Code) { }

            dataitem(RSVATEntry; "NPR RS VAT Entry")
            {
                DataItemLink = "VAT Report Mapping" = field(Code);
                DataItemLinkReference = VATReportMapping;
                DataItemTableView = sorting("Entry No.") where("Document Type" = const(Invoice), Type = const(Sale));

                column(RSVATEntry_OrdinalNo; _OrdinalNo) { }
                column(RSVATEntry_VATReportMapping; "VAT Report Mapping") { }
                column(RSVATEntry_DocumentNo; "Document No.") { }
                column(RSVATEntry_DocumentDate; Format("Document Date", 0, 1)) { }
                column(RSVATEntry_PostingDate; Format("Posting Date", 0, 1)) { }
                column(RSVATEntry_VATRegistrationNo; "VAT Registration No.") { }
                column(RSVATEntry_BillTo; "Bill-to/Pay-to No.") { }
                column(RSVATEntry_BillToDetails; _BillToDetails) { }

                column(RSVATEntry_Amount; Abs(Amount)) { }
                column(RSVATEntry_Base; Abs(Base)) { }
                column(RSVATEntry_TotalVATFee; Abs(Base + Amount)) { }
                column(RSVATEntry_TotalSupplyOfGoodsColumn16; _TotalSupplyOfGoodsColumn16) { }
                column(RSVATEntry_TotalSupplyOfGoodsColumn17; _TotalSupplyOfGoodsColumn17) { }

                column(AmtsArr_8; _AmountsArray[1]) { }
                column(AmtsArr_9; _AmountsArray[2]) { }
                column(AmtsArr_10; _AmountsArray[3]) { }
                column(AmtsArr_11; _AmountsArray[4]) { }
                column(AmtsArr_12; _AmountsArray[5]) { }
                column(AmtsArr_13; _AmountsArray[6]) { }
                column(AmtsArr_14; _AmountsArray[7]) { }
                column(AmtsArr_15; _AmountsArray[8]) { }

                trigger OnPreDataItem()
                begin
                    if (_StartDate <> 0D) and (_EndDate <> 0D) then
                        SetRange("Posting Date", _StartDate, _EndDate);
                end;

                trigger OnAfterGetRecord()
                var
                    Customer: Record Customer;
                begin
                    Clear(_BillToDetails);
                    Clear(_TotalSupplyOfGoodsColumn16);
                    Clear(_TotalSupplyOfGoodsColumn17);
                    if Customer.Get("Bill-to/Pay-to No.") and (StrLen(Customer.Address + Customer."Post Code" + Customer.City) > 0) then
                        _BillToDetails := Customer.Name + ', ' + Customer.Address + ' ' + Customer."Post Code" + ' ' + Customer.City
                    else
                        _BillToDetails := Customer.Name;

                    FormatArr(_AmountsArray, VATReportMapping, RSVATEntry);

                    // 8 + 9 + 12 + 14
                    _TotalSupplyOfGoodsColumn16 := _AmountsArray[1] + _AmountsArray[2] + _AmountsArray[5] + _AmountsArray[7];
                    // 8 + 12 + 14
                    _TotalSupplyOfGoodsColumn17 := _AmountsArray[1] + _AmountsArray[5] + _AmountsArray[7];

                    _TotalColumn8 += _AmountsArray[1];
                    _TotalColumn9 += _AmountsArray[2];
                    _TotalColumn10 += _AmountsArray[3];
                    _TotalColumn11 += _AmountsArray[4];
                    _TotalColumn12 += _AmountsArray[5];
                    _TotalColumn13 += _AmountsArray[6];
                    _TotalColumn14 += _AmountsArray[7];
                    _TotalColumn15 += _AmountsArray[8];
                    _TotalColumn16 += _TotalSupplyOfGoodsColumn16;
                    _TotalColumn17 += _TotalSupplyOfGoodsColumn17;
                    _GlobalTotalVATFee += Abs(Base + Amount);

                    _OrdinalNo := _GlobalIndex;
                    _GlobalIndex += 1;
                end;

            }
            trigger OnAfterGetRecord()
            begin
                if ("Book of Out. Inv. Amount" = "Book of Out. Inv. Amount"::" ") and ("Book of Out. Inv. Base" = "Book of Out. Inv. Base"::" ") then
                    CurrReport.Skip();
            end;
        }
        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(Totals_VATFee; _GlobalTotalVATFee) { }
            column(Totals_Column8; _TotalColumn8) { }
            column(Totals_Column9; _TotalColumn9) { }
            column(Totals_Column10; _TotalColumn10) { }
            column(Totals_Column11; _TotalColumn11) { }
            column(Totals_Column12; _TotalColumn12) { }
            column(Totals_Column13; _TotalColumn13) { }
            column(Totals_Column14; _TotalColumn14) { }
            column(Totals_Column15; _TotalColumn15) { }
            column(Totals_Column16; _TotalColumn16) { }
            column(Totals_Column17; _TotalColumn17) { }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field("Start Date"; _StartDate)
                    {
                        ToolTip = 'Specifies the value of the Start Date field.';
                        Caption = 'Start Date';
                        ApplicationArea = NPRRSLocal;

                        trigger OnValidate()
                        begin
                            if (_StartDate <> 0D) and (_EndDate <> 0D) then
                                if _StartDate > _EndDate then
                                    Error(_StartDateHigherLbl);
                        end;
                    }
                    field("End Date"; _EndDate)
                    {
                        ToolTip = 'Specifies the value of the End Date field.';
                        Caption = 'End Date';
                        ApplicationArea = NPRRSLocal;

                        trigger OnValidate()
                        begin
                            if (_StartDate <> 0D) and (_EndDate <> 0D) then
                                if _StartDate > _EndDate then
                                    Error(_StartDateHigherLbl);
                        end;
                    }
                }
            }
        }
    }

    labels
    {
        ReportCaptionLbl = 'Knjiga izdatih računa', Locked = true;
        CompanyNameCaptionLbl = 'Firma:', Locked = true;
        CompanyAddressCaptionLbl = 'Sedište:', Locked = true;
        VATRegistrationNoCaptionLbl = 'PIB:', Locked = true;
        DatePeriodCaptionLbl = 'Za period:', Locked = true;
        Column1CaptionLbl = 'Red. Broj', Locked = true;
        Column2CaptionLbl = 'Datum knjiženja', Locked = true;
        Column3CaptionLbl = 'Broj računa', Locked = true;
        Column4CaptionLbl = 'Datum izdavanja računa (ili drugog dokumenta)', Locked = true;
        Column5CaptionLbl = 'Naziv (ime i sedište)', Locked = true;
        Column6CaptionLbl = 'PIB ili JMBG', Locked = true;
        Column56CaptionLbl = 'KUPAC', Locked = true;
        Column3456CaptionLbl = 'RAČUN ILI DRUGI DOKUMENT', Locked = true;
        Column7CaptionLbl = 'ukupna naknada sa PDV', Locked = true;
        Column8CaptionLbl = 'Oslobođen promet sa pravom na odbitak prethodnog poreza (čl. 24. Zakona) i drugi osl. promet', Locked = true;
        Column9CaptionLbl = 'Oslobođen promet bez prava na odbitak prethodnog poreza (čl. 25. Zakona)', Locked = true;
        Column10CaptionLbl = 'za koji bi postojalo pravo na prethodni porez da je promet izvršen i zemlji (tačka 8.*)', Locked = true;
        Column11CaptionLbl = 'za koji ne bi postojalo pravo na pret. porez da je promet izvršen u zemlji (tačka 10.*)', Locked = true;
        Column1011CaptionLbl = 'PROMET U INOSTRANSTVU', Locked = true;
        Column891011CaptionLbl = 'OSLOBOĐEN PROMET', Locked = true;
        Column12CaptionLbl = 'Osnovica tačka (3.*)', Locked = true;
        Column13CaptionLbl = 'Iznos PDV (tačka 5.*)', Locked = true;
        Column14CaptionLbl = 'Osnovica (tačka 4.*)', Locked = true;
        Column15CaptionLbl = 'Iznos PDV (tačka 6.*)', Locked = true;
        Column1213CaptionLbl = 'PO STOPI OD 20%', Locked = true;
        Column1415CaptionLbl = 'PO STOPI OD 10%', Locked = true;
        Column12131415CaptionLbl = 'OPOREZIV PROMET', Locked = true;
        Column16CaptionLbl = 'Ukupan promet dobara i usluga sa pravom i bez prava na odbitak prethodnog poreza bez PDV (8+9+12+14)', Locked = true;
        Column17CaptionLbl = 'Promet dobara i usluga sa pravom na odbitak prethodnog poreza bez PDV (8+12+14)', Locked = true;
        TotalCaptionLbl = 'SUMA:', Locked = true;
        POPPDVIndentificatiorCaptionLbl = 'POPDV Identif.', Locked = true;
    }

    trigger OnPreReport()
    begin
        if (_StartDate <> 0D) and (_EndDate = 0D) then
            Error(_BothDateFieldsRequiredLbl);
        if (_StartDate = 0D) and (_EndDate <> 0D) then
            Error(_BothDateFieldsRequiredLbl);

        _CompanyInformation.Get();
        _GlobalIndex := 1;
        _CompanyAddress := _CompanyInformation.Address + ' ' + _CompanyInformation."Post Code" + ' ' + _CompanyInformation.City;
    end;

    local procedure FormatArr(var AmtsArr: array[8] of Decimal; VATReportMapping: Record "NPR VAT Report Mapping"; RSVATEntry: Record "NPR RS VAT Entry")
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

    internal procedure SetDates(StartDate: Date; EndDate: Date)
    begin
        _StartDate := StartDate;
        _EndDate := EndDate;
    end;

    var
        _CompanyInformation: Record "Company Information";
        _StartDate, _EndDate : Date;
        _AmountsArray: array[8] of Decimal;
        _TotalSupplyOfGoodsColumn17, _TotalSupplyOfGoodsColumn16, _GlobalTotalVATFee, _TotalColumn8, _TotalColumn9, _TotalColumn10, _TotalColumn11, _TotalColumn12, _TotalColumn13, _TotalColumn14, _TotalColumn15, _TotalColumn16, _TotalColumn17 : Decimal;
        _GlobalIndex, _OrdinalNo : Integer;
        _BillToDetails, _CompanyAddress : Text;
        _BothDateFieldsRequiredLbl: Label 'Both date fields must to be populated.';
        _PeriodFilterTxtLbl: Label '%1-%2', Comment = '%1 - Specifies StartDate value, %2 - Specifies EndDate value';
        _StartDateHigherLbl: Label 'Start Date cannot be higher than End Date';
}