report 6014465 "NPR Book Of Incoming Invoices"
{
    Caption = 'Book of Incoming Invoices';
    UsageCategory = None;
#IF NOT BC17
    Extensible = false;
#ENDIF
    WordLayout = './src/Localizations/[RS] Localization/InvoiceBooks/BookOfIncomingInvoices.docx';
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
                DataItemTableView = sorting("Entry No.") where("Document Type" = filter(Invoice | "Credit Memo"), Type = const(Purchase));

                column(RSVATEntry_OrdinalNo; _OrdinalNo) { }
                column(RSVATEntry_VATReportMapping; "VAT Report Mapping") { }
                column(RSVATEntry_DocumentNo; "Document No.") { }
                column(RSVATEntry_DocumentDate; Format("Document Date", 0, 1)) { }
                column(RSVATEntry_PostingDate; Format("Posting Date", 0, 1)) { }
                column(RSVATEntry_VATRegistrationNo; "VAT Registration No.") { }
                column(RSVATEntry_PayTo; "Bill-to/Pay-to No.") { }
                column(RSVATEntry_PayToDetails; _PayToDetails) { }

                column(RSVATEntry_Amount; Abs(Amount)) { }
                column(RSVATEntry_Base; Abs(Base)) { }
                column(RSVATEntry_TotalVATFee; _BaseVal + Amount) { }

                column(AmtsArr_9; _AmountsArray[1]) { }
                column(AmtsArr_10; _AmountsArray[2]) { }
                column(AmtsArr_11; _AmountsArray[3]) { }
                column(AmtsArr_12; _AmountsArray[4]) { }
                column(AmtsArr_13; _AmountsArray[5]) { }
                column(AmtsArr_14; _AmountsArray[6]) { }
                column(AmtsArr_15; _AmountsArray[7]) { }
                column(AmtsArr_16; _AmountsArray[8]) { }

                // Related to Agriculture fee and will not be used, added just to print default values on the report
                column(AmtsArr_17; 0.00) { }
                column(AmtsArr_18; 0.00) { }

                trigger OnPreDataItem()
                begin
                    if (_StartDate <> 0D) and (_EndDate <> 0D) then
                        SetRange("Posting Date", _StartDate, _EndDate);
                end;

                trigger OnAfterGetRecord()
                var
                    Vendor: Record Vendor;
                begin
                    Clear(_BaseVal);
                    Clear(_PaytoDetails);
                    if Vendor.Get("Bill-to/Pay-to No.") and (StrLen(Vendor.Address + Vendor."Post Code" + Vendor.City) > 0) then
                        _PaytoDetails := Vendor.Name + ', ' + Vendor.Address + ' ' + Vendor."Post Code" + ' ' + Vendor.City
                    else
                        _PaytoDetails := Vendor.Name;

                    FormatArr(_AmountsArray, VATReportMapping, RSVATEntry);

                    if Base <> 0 then
                        _BaseVal := Base
                    else
                        _BaseVal := "VAT Base Full VAT";

                    _TotalColumn8 += _BaseVal + Amount;
                    _TotalColumn9 += _AmountsArray[1];
                    _TotalColumn10 += _AmountsArray[2];
                    _TotalColumn11 += _AmountsArray[3];
                    _TotalColumn12 += _AmountsArray[4];
                    _TotalColumn13 += _AmountsArray[5];
                    _TotalColumn14 += _AmountsArray[6];
                    _TotalColumn15 += _AmountsArray[7];
                    _TotalColumn16 += _AmountsArray[8];

                    _OrdinalNo := _GlobalIndex;
                    _GlobalIndex += 1;
                end;

            }
            trigger OnAfterGetRecord()
            begin
                if ("Book of Inc. Inv. Amount" = "Book of Inc. Inv. Amount"::" ") and ("Book of Inc. Inv. Base" = "Book of Inc. Inv. Base"::" ") then
                    CurrReport.Skip();
            end;
        }
        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(Totals_Column8; _TotalColumn8) { }
            column(Totals_Column9; _TotalColumn9) { }
            column(Totals_Column10; _TotalColumn10) { }
            column(Totals_Column11; _TotalColumn11) { }
            column(Totals_Column12; _TotalColumn12) { }
            column(Totals_Column13; _TotalColumn13) { }
            column(Totals_Column14; _TotalColumn14) { }
            column(Totals_Column15; _TotalColumn15) { }
            column(Totals_Column16; _TotalColumn16) { }
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
        ReportCaptionLbl = 'Knjiga primljenih računa', Locked = true;
        CompanyNameCaptionLbl = 'Firma:', Locked = true;
        CompanyAddressCaptionLbl = 'Sedište:', Locked = true;
        VATRegistrationNoCaptionLbl = 'PIB:', Locked = true;
        DatePeriodCaptionLbl = 'Za period:', Locked = true;
        Column1CaptionLbl = 'Red. Broj', Locked = true;
        Column2CaptionLbl = 'Knjiženja isprave', Locked = true;
        Column3CaptionLbl = 'Prijema carinske isprave i plaćanja naknade poljop.', Locked = true;
        Column23CaptionLbl = 'DATUM', Locked = true;
        Column4CaptionLbl = 'Broj računa', Locked = true;
        Column5CaptionLbl = 'Datum izdavanja računa (ili drugog dok.)', Locked = true;
        Column6CaptionLbl = 'Naziv (ime i sedište)', Locked = true;
        Column7CaptionLbl = 'PIB ili JMBG', Locked = true;
        Column67CaptionLbl = 'DOBAVLJAČ', Locked = true;
        Column67891011CaptionLbl = 'RAČUN ILI DRUGI DOKUMENT', Locked = true;
        Column8CaptionLbl = 'Ukupna naknada sa PDV (tač. 16)', Locked = true;
        Column9CaptionLbl = 'Oslobođene nabavke i nabavke od lica koja nisu obveznici PDV (tač. 15 i 18)', Locked = true;
        Column10CaptionLbl = 'Naknada za uvezena dobra na koja se ne plaća PDV (tač. 22)', Locked = true;
        Column11CaptionLbl = 'Naknada bez PDV (na koju je obračunat PDV koji se može odbiti)', Locked = true;
        Column12CaptionLbl = 'Ukupan iznos obračunatog prethodnog PDV (tač. 17)', Locked = true;
        Column13CaptionLbl = 'Iznos prethodnog PDV koji se može odbiti', Locked = true;
        Column14CaptionLbl = 'Iznos prethodnog PDV koji se ne može odbiti', Locked = true;
        Column15CaptionLbl = 'Vrednost bez PDV (tač. 21)', Locked = true;
        Column16CaptionLbl = 'Iznos PDV (tač. 23)', Locked = true;
        Column1516CaptionLbl = 'UVOZ', Locked = true;
        Column17CaptionLbl = 'Vrednost primljenih dobara i usluga (tač. 25)', Locked = true;
        Column18CaptionLbl = 'Iznos naknade od 5% (tač. 24)', Locked = true;
        Column1718CaptionLbl = 'NAKNADA POLJOPRIVREDNIKU', Locked = true;
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
    var
        BaseVal: Decimal;
    begin
        Clear(AmtsArr);

        case VATReportMapping."Book of Inc. Inv. Amount" of
            VATReportMapping."Book of Inc. Inv. Amount"::"9":
                AmtsArr[1] := RSVATEntry.Amount;
            VATReportMapping."Book of Inc. Inv. Amount"::"10":
                AmtsArr[2] := RSVATEntry.Amount;
            VATReportMapping."Book of Inc. Inv. Amount"::"11":
                AmtsArr[3] := RSVATEntry.Amount;
            VATReportMapping."Book of Inc. Inv. Amount"::"12":
                AmtsArr[4] := RSVATEntry.Amount;
            VATReportMapping."Book of Inc. Inv. Amount"::"13":
                AmtsArr[5] := RSVATEntry.Amount;
            VATReportMapping."Book of Inc. Inv. Amount"::"14":
                AmtsArr[6] := RSVATEntry.Amount;
            VATReportMapping."Book of Inc. Inv. Amount"::"15":
                AmtsArr[7] := RSVATEntry.Amount;
            VATReportMapping."Book of Inc. Inv. Base"::"16":
                AmtsArr[8] := RSVATEntry.Base;
        end;

        if RSVATEntry.Base <> 0 then
            BaseVal := RSVATEntry.Base
        else
            BaseVal := RSVATEntry."VAT Base Full VAT";

        case VATReportMapping."Book of Inc. Inv. Base" of
            VATReportMapping."Book of Inc. Inv. Base"::"9":
                AmtsArr[1] := BaseVal;
            VATReportMapping."Book of Inc. Inv. Base"::"10":
                AmtsArr[2] := BaseVal;
            VATReportMapping."Book of Inc. Inv. Base"::"11":
                AmtsArr[3] := BaseVal;
            VATReportMapping."Book of Inc. Inv. Base"::"12":
                AmtsArr[4] := BaseVal;
            VATReportMapping."Book of Inc. Inv. Base"::"13":
                AmtsArr[5] := BaseVal;
            VATReportMapping."Book of Inc. Inv. Base"::"14":
                AmtsArr[6] := BaseVal;
            VATReportMapping."Book of Inc. Inv. Base"::"15":
                AmtsArr[7] := BaseVal;
            VATReportMapping."Book of Inc. Inv. Base"::"16":
                AmtsArr[8] := BaseVal;
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
        _TotalColumn8, _TotalColumn9, _TotalColumn10, _TotalColumn11, _TotalColumn12, _TotalColumn13, _TotalColumn14, _TotalColumn15, _TotalColumn16, _BaseVal : Decimal;
        _GlobalIndex, _OrdinalNo : Integer;
        _PaytoDetails, _CompanyAddress : Text;
        _BothDateFieldsRequiredLbl: Label 'Both date fields must to be populated.';
        _PeriodFilterTxtLbl: Label '%1-%2', Comment = '%1 - Specifies StartDate value, %2 - Specifies EndDate value';
        _StartDateHigherLbl: Label 'Start Date cannot be higher than End Date';
}