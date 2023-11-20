report 6014511 "NPR RS Vendor Open Entries"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'RS Vendor Open Entries';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRSLocal;
    WordLayout = './src/Localizations/[RS] Localization/RSVendorOpenEntries.docx';
    DefaultLayout = Word;
    WordMergeDataItem = Vendor;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";

            column(CompanyInfo_Picture; CompanyInformation.Picture) { }
            column(CompanyInfo_Name; CompanyInformation.Name) { }
            column(CompanyInfo_Address; CompanyAddress) { }
            column(CompanyInfo_RegNo; CompanyInformation."Registration No.") { }
            column(CompanyInfo_IndustrialClassification; CompanyInformation."Industrial Classification") { }
            column(CompanyInfo_VATRegNo; CompanyInformation."VAT Registration No.") { }
            column(CompanyInfo_PhoneNo; CompanyInformation."Phone No.") { }
            column(CompanyInfo_Email; CompanyInformation."E-Mail") { }
            column(Vendor_No; "No.") { }
            column(Vendor_Name; Name) { }
            column(Vendor_Address; VendorAddress) { }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            column(Vendor_RegNo; "Registration Number") { }
#endif
            column(Vendor_VATRegNo; "VAT Registration No.") { }
            column(Vendor_Phone; "Phone No.") { }
            column(Vendor_Email; "E-Mail") { }
            column(DateFilter; DateFilter) { }
            dataitem(VendorLedgEntry; "Vendor Ledger Entry")
            {
                CalcFields = Amount;
                DataItemLink = "Vendor No." = field("No.");
                DataItemTableView = sorting("Posting Date");

                column(VendLedgEntry_DocNo; "Document No.") { }
                column(VendLedgEntry_DocDate; Format("Posting Date", 11, '<Day,2>.<Month,2>.<Year4>.')) { }
                column(VendLedgEntry_Desc; Description) { }
                column(VendLedgEntry_Currency; CurrencyCode) { }
                column(VendLedgEntry_Amount; Abs(Amount)) { }
                column(VendLedgEntry_PaidAmount; PaidAmount) { }
                column(VendLedgEntry_LeftToPay; LeftForPayment) { }
                column(VendLedgEntry_TotalLeftPaym; TotalLeftForPayment) { }

                trigger OnPreDataItem()
                var
                    NotClosedAtDateFilterLbl: Label '>%1|''''', Locked = true, Comment = '%1 = Closed At Date';
                begin
                    VendorLedgEntry.SetFilter("Posting Date", StrSubstNo(DateFilterLbl, FilterStartDate, FilterEndDate));
                    VendorLedgEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
                    VendorLedgEntry.SetFilter("Closed at Date", StrSubstNo(NotClosedAtDateFilterLbl, FilterEndDate));
                end;

                trigger OnAfterGetRecord()
                var
                    VendorLedgEntry2: Record "Vendor Ledger Entry";
                    GLSetup: Record "General Ledger Setup";
                begin
                    GLSetup.Get();
                    Clear(PaidAmount);
                    Clear(LeftForPayment);
                    VendorLedgEntry2.SetRange("Closed by Entry No.", VendorLedgEntry."Entry No.");
                    VendorLedgEntry2.SetFilter("Posting Date", StrSubstNo(DateFilterLbl, FilterStartDate, FilterEndDate));
                    VendorLedgEntry2.SetRange("Document Type", "Gen. Journal Document Type"::Payment, "Gen. Journal Document Type"::"Credit Memo");
                    if VendorLedgEntry2.FindSet() then
                        repeat
                            VendorLedgEntry2.CalcFields(Amount);
                            PaidAmount += Abs(VendorLedgEntry2.Amount);
                        until VendorLedgEntry2.Next() = 0;
                    LeftForPayment := Abs(VendorLedgEntry.Amount) - PaidAmount;
                    TotalLeftForPayment += LeftForPayment;
                    CalculateTotals();
                    CurrencyCode := GLSetup.GetCurrencyCode(VendorLedgEntry."Currency Code");
                end;
            }
            dataitem(Totals; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(Totals_TotalAmountToPay; TotalAmountToPay) { }

                trigger OnAfterGetRecord()
                begin
                    if TotalAmountToPay = 0 then
                        CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                Clear(TotalAmountToPay);
                Clear(TotalLeftForPayment);
                VendorAddress := FormatAddress(Address, "Post Code", City);
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
                    field(StartDate; FilterStartDate)
                    {
                        ApplicationArea = NPRRSLocal;
                        Caption = 'Start Date';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field(EndDate; FilterEndDate)
                    {
                        ApplicationArea = NPRRSLocal;
                        Caption = 'End Date';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the End Date field.';
                    }
                }
            }
        }
    }

    labels
    {
        ReportHeading = 'IZVOD OTVORENIH STAVKI', Locked = true;
        RegNoLbl = 'Maticni broj:', Locked = true;
        PhoneLbl = 'Telefon:', Locked = true;
        EmailLbl = 'E-mail:', Locked = true;
        BankAccNoLbl = 'Tekuci racun:', Locked = true;
        VATRegNoLbl = 'PIB:', Locked = true;
        DocNoLbl = 'Broj dokumenta', Locked = true;
        DocDateLbl = 'Datum dokumenta', Locked = true;
        CurrencyLbl = 'Valuta', Locked = true;
        TotalLineAmountLbl = 'Ukupan iznos', Locked = true;
        PaidAmountLbl = 'Uplaceni deo', Locked = true;
        LeftForPaymLbl = 'Ostalo za uplatu', Locked = true;
        DescriptionLbl = 'Opis', Locked = true;
        TotalAmountLbl = 'UKUPNO DUGOVANJE', Locked = true;
        LawCaption = 'Molimo Vas da, saglasno članu 22. Zakona o računovodstvu i članu 12. Pravilnika o načinu i rokovima vršenja popisa i usklađivanja knjigovodstvenog stanja sa stvarnim stanjem, proverite stanje obaveza i potraživanja iskazano u Vašim poslovnim knjigama i da nas o tome obavestite u roku od _____ dana slanjem jednog potpisanog primerka ovog IOS.', Locked = true;
        IOSSenderCaption = 'Posiljalac izvoda', Locked = true;
        IOSConfirmationCap = 'Potvrdjujemo saglasnost otvorenih stavki', Locked = true;
        DateAndPlace = '(Mesto i datum)', Locked = true;
        RejectingCaption = 'NAPOMENA: Osporavamo iskazano stanje u CELINI - DELIMIČNO za iznos od _____________ iz sledećih razloga:', Locked = true;
        RejectingInfo = 'Osporavamo izvod otvorenih stavki', Locked = true;
        StampLbl = 'M.P.', Locked = true;
    }

    trigger OnPreReport()
    var
        DateCaptionLbl: Label 'Za period od %1 do %2 godine', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        CompanyAddress := FormatAddress(CompanyInformation.Address, CompanyInformation."Post Code", CompanyInformation.City);
        DateFilter := StrSubstNo(DateCaptionLbl, Format(FilterStartDate, 11, '<Day,2>.<Month,2>.<Year4>.'), Format(FilterEndDate, 11, '<Day,2>.<Month,2>.<Year4>.'));
    end;

    local procedure CalculateTotals()
    begin
        TotalAmountToPay := TotalLeftForPayment;
    end;

    local procedure FormatAddress(Address: Text[100]; PostCode: Code[20]; City: Text[30]): Text
    var
        AddressFormatLbl: Label '%1, %2 %3', Locked = true, Comment = '%1 = Address, %2 = Post Code, %3 = City';
    begin
        if (Address <> '') and (PostCode <> '') and (City <> '') then
            exit(StrSubstNo(AddressFormatLbl, Address, PostCode, City));
    end;

    var
        CompanyInformation: Record "Company Information";
        FilterEndDate: Date;
        FilterStartDate: Date;
        LeftForPayment: Decimal;
        PaidAmount: Decimal;
        TotalAmountToPay: Decimal;
        TotalLeftForPayment: Decimal;
        DateFilterLbl: Label '%1..%2', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        CompanyAddress: Text;
        DateFilter: Text;
        VendorAddress: Text;
        CurrencyCode: Code[10];
}