report 6014509 "NPR RS Customer Open Entries"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'RS Customer Open Entries';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRSLocal;
    WordLayout = './src/Localizations/[RS] Localization/RSCustomerOpenEntries.docx';
    DefaultLayout = Word;
    WordMergeDataItem = Customer;

    dataset
    {
        dataitem(Customer; Customer)
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
            column(CompanyInfo_BankAccNo; CompanyInformation."Bank Account No.") { }
            column(Customer_Name; Name) { }
            column(Customer_Address; CustomerAddress) { }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            column(Customer_RegNo; "Registration Number") { }
#endif
            column(Customer_VATRegNo; "VAT Registration No.") { }
            column(Customer_Phone; "Phone No.") { }
            column(DateFilter; DateFilter) { }
            dataitem(CustLedgEntry; "Cust. Ledger Entry")
            {
                CalcFields = Amount;
                DataItemLink = "Customer No." = field("No.");
                DataItemTableView = sorting("Posting Date");

                column(CustLedgEntry_DocType; "Document Type") { }
                column(CustLedgEntry_DocNo; "Document No.") { }
                column(CustLedgEntry_DocDate; Format("Posting Date", 11, '<Day,2>.<Month,2>.<Year4>.')) { }
                column(CustLedgEntry_Currency; CurrencyCode) { }
                column(CustLedgEntry_Desc; Description) { }
                column(CustLedgEntry_TotalAmount; Amount) { }
                column(CustLedgEntry_PaidAmt; PaidAmount) { }
                column(CustLedgEntry_LeftForPaym; LeftForPayment) { }
                column(CustLedgEntry_TotalLeftForPaym; TotalLeftForPayment) { }

                trigger OnPreDataItem()
                var
                    NotClosedAtDateFilterLbl: Label '>%1|''''', Locked = true, Comment = '%1 = Closed At Date';
                begin
                    CustLedgEntry.SetFilter("Posting Date", StrSubstNo(DateFilterLbl, FilterStartDate, FilterEndDate));
                    CustLedgEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
                    CustLedgEntry.SetFilter("Closed at Date", StrSubstNo(NotClosedAtDateFilterLbl, FilterEndDate));
                end;

                trigger OnAfterGetRecord()
                var
                    CustLedgEntry2: Record "Cust. Ledger Entry";
                    GLSetup: Record "General Ledger Setup";
                begin
                    GLSetup.Get();
                    Clear(PaidAmount);
                    Clear(LeftForPayment);
                    CustLedgEntry2.SetRange("Closed by Entry No.", CustLedgEntry."Entry No.");
                    CustLedgEntry2.SetFilter("Posting Date", StrSubstNo(DateFilterLbl, FilterStartDate, FilterEndDate));
                    CustLedgEntry2.SetRange("Document Type", "Gen. Journal Document Type"::Payment, "Gen. Journal Document Type"::"Credit Memo");
                    if CustLedgEntry2.FindSet() then
                        repeat
                            CustLedgEntry2.CalcFields(Amount);
                            PaidAmount += Abs(CustLedgEntry2.Amount);
                        until CustLedgEntry2.Next() = 0;
                    LeftForPayment := CustLedgEntry.Amount - PaidAmount;
                    TotalLeftForPayment += LeftForPayment;
                    CalculateTotals();
                    CurrencyCode := GLSetup.GetCurrencyCode(CustLedgEntry."Currency Code");
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
                CustomerAddress := FormatAddress(Address, "Post Code", City);
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
        DateCaptionLbl: Label 'Za period od %1 do %2 godine', Locked = true, Comment = '%1 = Start Year, %2 = End Year';
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        CompanyAddress := FormatAddress(CompanyInformation.Address, CompanyInformation."Post Code", CompanyInformation.City);
        DateFilter := StrSubstNo(DateCaptionLbl, Format(FilterStartDate, 11, '<Day,2>.<Month,2>.<Year4>.'), Format(FilterEndDate, 11, '<Day,2>.<Month,2>.<Year4>.'));
    end;

    local procedure FormatAddress(Address: Text[100]; PostCode: Code[20]; City: Text[30]): Text
    var
        AddressFormatLbl: Label '%1, %2 %3', Locked = true, Comment = '%1 = Address, %2 = Post Code, %3 = City';
    begin
        if (Address <> '') and (PostCode <> '') and (City <> '') then
            exit(StrSubstNo(AddressFormatLbl, Address, PostCode, City));
    end;

    local procedure CalculateTotals()
    begin
        TotalAmountToPay := TotalLeftForPayment;
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
        CustomerAddress: Text;
        DateFilter: Text;
        CurrencyCode: Code[10];
}