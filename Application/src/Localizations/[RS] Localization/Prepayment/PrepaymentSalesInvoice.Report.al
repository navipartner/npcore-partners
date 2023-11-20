report 6014505 "NPR Prepayment Sales Invoice"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'Prepayment Sales Invoice';
    UsageCategory = None;
    WordLayout = './src/Localizations/[RS] Localization/Prepayment/PrepaymentSalesInvoice.docx';
    DefaultLayout = Word;
    dataset
    {
        dataitem(SalesInvHeader; "Sales Invoice Header")
        {
            column(DateOfPrinting; DateAndPlaceOfPrintText) { }
            column(CompanyInfo_Picture; CompanyInformation.Picture) { }
            column(CompanyInfo_No; CompanyInformation."Primary Key") { }
            column(CompanyInfo_Name; CompanyInformation.Name) { }
            column(CompanyInfo_Address; CompanyAddress) { }
            column(CompanyInfo_RegNo; CompanyInformation."Registration No.") { }
            column(CompanyInfo_IndustrialClassification; CompanyInformation."Industrial Classification") { }
            column(CompanyInfo_VATRegNo; CompanyInformation."VAT Registration No.") { }
            column(CompanyInfo_PhoneNo; CompanyInformation."Phone No.") { }
            column(CompanyInfo_Email; CompanyInformation."E-Mail") { }
            column(CompanyInfo_BankAccNo; CompanyInformation."Bank Account No.") { }
            column(SalesInvHeader_No; "No.") { }
            column(SalesInvHeader_OrderDate; Format("Order Date", 10, '<Day,2>/<Month,2>/<Year4>')) { }
            column(SalesInvHeader_TotalAmountInclVAT; "Amount Including VAT") { }
            column(SalesInvHeader_PrepaymentNo; "Prepayment Order No.") { }
            column(SalesInvHeader_Salesperson; SalespersonName) { }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = field("Sell-to Customer No.");

                column(Customer_No; "No.") { }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
                column(Customer_RegNo; "Registration Number") { }
#endif
                column(Customer_VATRegNo; "VAT Registration No.") { }
                column(Customer_Name; Name) { }
                column(Customer_Address; CustomerAddress) { }

                trigger OnAfterGetRecord()
                begin
                    CustomerAddress := FormatAddress(Customer.Address, Customer."Post Code", Customer.City);
                end;
            }
            dataitem(SalesInvLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = where(Quantity = filter('>0'));
                column(SalesInvLine_LineNo; LineNo) { }
                column(SalesInvLine_Desc; Description) { }
                column(SalesInvLine_Qty; Quantity) { }
                column(SalesInvLine_UOM; "Unit of Measure") { }
                column(SalesInvLine_UnitPriceExclVAT; "Unit Price") { }
                column(SalesInvLine_UnitPriceInclVAT; "Amount Including VAT" / Quantity) { }
                column(SalesInvLine_VATPerc; "VAT %") { }
                column(SalesInvLine_AmountInclVAT; "Amount Including VAT") { }

                trigger OnAfterGetRecord()
                begin
                    case "VAT %" of
                        10:
                            Calculate10VAT();
                        20:
                            Calculate20VAT();
                    end;
                    LineNo += 1;
                end;
            }
            trigger OnPreDataItem()
            begin
                if (FilterSalesInvNo <> '') or (FilterSalesInvDate <> 0D) then begin
                    SetRange("No.", FilterSalesInvNo);
                    SetRange("Order Date", FilterSalesInvDate);
                end
            end;

            trigger OnAfterGetRecord()
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
            begin
                if SalespersonPurchaser.Get("Salesperson Code") then
                    SalespersonName := SalespersonPurchaser.Name;
            end;
        }

        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(TotalAmountInclVAT20; TotalAmountIncl20VAT) { }
            column(TotalBaseVAT20; TotalBase20VAT) { }
            column(TotalVAT20Amount; TotalVAT20Amount) { }
            column(TotalAmountInclVAT10; TotalAmountIncl10VAT) { }
            column(TotalBaseVAT10; TotalBase10VAT) { }
            column(TotalVAT10Amount; TotalVAT10Amount) { }
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
                    field("Sales Inv. No."; FilterSalesInvNo)
                    {
                        ApplicationArea = NPRRSLocal;
                        Caption = 'Sales Invoice No.';
                        ToolTip = 'Specifies the value of the Sales Invoice No. field.';
                    }
                    field("Order Date"; FilterSalesInvDate)
                    {
                        ApplicationArea = NPRRSLocal;
                        Caption = 'Order Date';
                        ToolTip = 'Specifies the value of the Order Date field.';
                    }
                }
            }
        }
    }

    labels
    {
        SalesInvHdrNoLbl = 'Avans prodaja', Locked = true;
        SalesInvHdrDateLbl = 'Datum prometa:', Locked = true;
        ReportNoLbl = 'Avansni racun broj', Locked = true;
        RegNoLbl = 'Maticni broj:', Locked = true;
        VATRegNoLbl = 'PIB:', Locked = true;
        IndustrialInfoNoLbl = 'Sifra delatnosti:', Locked = true;
        PhoneNoLbl = 'Telefon/Fax:', Locked = true;
        AddressLbl = 'Adresa:', Locked = true;
        EmailLbl = 'E-mail:', Locked = true;
        BankAccountNoLbl = 'Tekuci racun:', Locked = true;
        SalesInvLineNoLbl = 'R. br.', Locked = true;
        SalesInvLineDescLbl = 'Opis', Locked = true;
        SalesInvLineUOMLbl = 'JM', Locked = true;
        SalesInvLineQtyLbl = 'Kol', Locked = true;
        SalesInvLineAmountExclVATLbl = 'Cena bez PDV', Locked = true;
        SalesInvLineAmountInclVATLbl = 'Cena sa PDV', Locked = true;
        SalesInvLineAmountLbl = 'Iznos', Locked = true;
        TotalAmountLbl = 'Vrednost', Locked = true;
        SalesInvHdrTotalAmountLbl = 'UKUPNO', Locked = true;
        SalesInvLineUnitPriceLbl = 'Jedinicna cena', Locked = true;
        SalesInvLineDiscPercLbl = 'Popust', Locked = true;
        CustomerNoLbl = 'Kupac:', Locked = true;
        VATSectionDescLbl = 'Sadrzani porez', Locked = true;
        VATSectionVATBaseLbl = 'Poreska osnovica', Locked = true;
        VATSectionVATPercLbl = 'Stopa', Locked = true;
        VATSectionVATAmountLbl = 'PDV', Locked = true;
        VATSection20VATCaption = 'Opsta stopa', Locked = true;
        VATSection10VATCaption = 'Posebna stopa', Locked = true;
        VAT10Caption = '10.00', Locked = true;
        VAT20Caption = '20.00', Locked = true;
        SalespersonCaption = 'Fakturisao', Locked = true;
    }

    trigger OnPreReport()
    var
        DateAndPlaceOfPrintLbl: Label 'Mesto i datum izdavanja: %1, %2', Locked = true, Comment = '%1 = City, %2 = Work Date';
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        CompanyAddress := FormatAddress(CompanyInformation.Address, CompanyInformation."Post Code", CompanyInformation.City);
        DateAndPlaceOfPrintText := StrSubstNo(DateAndPlaceOfPrintLbl, CompanyInformation.City, Format(WorkDate(), 10, '<Day,2>/<Month,2>/<Year4>'));
        LineNo := 0;
    end;

    local procedure Calculate10VAT()
    begin
        TotalBase10VAT += SalesInvLine."VAT Base Amount";
        TotalVAT10Amount += SalesInvLine."Amount Including VAT" - SalesInvLine."VAT Base Amount";
        TotalAmountIncl10VAT += SalesInvLine."Amount Including VAT";
    end;

    local procedure Calculate20VAT()
    begin
        TotalBase20VAT += SalesInvLine."VAT Base Amount";
        TotalVAT20Amount += SalesInvLine."Amount Including VAT" - SalesInvLine."VAT Base Amount";
        TotalAmountIncl20VAT += SalesInvLine."Amount Including VAT";
    end;

    local procedure FormatAddress(Address: Text[100]; PostCode: Code[20]; City: Text[30]): Text
    var
        AddressFormatLbl: Label '%1, %2 %3', Locked = true, Comment = '%1 = Address, %2 = Post Code, %3 = City';
    begin
        if (Address <> '') and (PostCode <> '') and (City <> '') then
            exit(StrSubstNo(AddressFormatLbl, Address, PostCode, City));
    end;

    internal procedure SetFilters(SalesInvNo: Code[20]; SalesInvOrderDate: Date)
    begin
        FilterSalesInvNo := SalesInvNo;
        FilterSalesInvDate := SalesInvOrderDate;
    end;

    var
        CompanyInformation: Record "Company Information";
        FilterSalesInvNo: Code[20];
        FilterSalesInvDate: Date;
        TotalAmountIncl10VAT: Decimal;
        TotalAmountIncl20VAT: Decimal;
        TotalBase10VAT: Decimal;
        TotalBase20VAT: Decimal;
        TotalVAT10Amount: Decimal;
        TotalVAT20Amount: Decimal;
        LineNo: Integer;
        CompanyAddress: Text;
        CustomerAddress: Text;
        DateAndPlaceOfPrintText: Text;
        SalespersonName: Text[50];
}