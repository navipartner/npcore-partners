report 6014507 "NPR Prepayment Sales Cr. Memo"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'Prepayment Sales Credit Memo';
    UsageCategory = None;
    WordLayout = './src/Localizations/[RS] Localization/Prepayment/PrepaymentSalesCrMemo.docx';
    DefaultLayout = Word;
    dataset
    {
        dataitem(SalesCrMemoHdr; "Sales Cr.Memo Header")
        {
            column(DateOfPrinting; DateAndPlaceOfPrintText) { }
            column(CompanyInfo_Picture; CompanyInformation.Picture) { }
            column(CompanyInfo_No; CompanyInformation."Primary Key") { }
            column(CompanyInfo_Name; CompanyName) { }
            column(CompanyInfo_Address; CompanyAddress) { }
            column(CompanyInfo_RegNo; CompanyInformation."Registration No.") { }
            column(CompanyInfo_IndustrialClassification; CompanyInformation."Industrial Classification") { }
            column(CompanyInfo_VATRegNo; CompanyInformation."VAT Registration No.") { }
            column(CompanyInfo_PhoneNo; CompanyInformation."Phone No.") { }
            column(CompanyInfo_Email; CompanyInformation."E-Mail") { }
            column(CompanyInfo_BankAccNo; CompanyInformation."Bank Account No.") { }
            column(SalesCrMemoHdr_No; "No.") { }
            column(SalesCrMemoHdr_TotalAmountInclVAT; "Amount Including VAT") { }
            column(SalesCrMemoHdr_PrepaymentNo; "Prepayment Order No.") { }
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
            dataitem(SalesCrMemoLine; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = where(Quantity = filter('>0'));
                column(SalesCrMemoLine_LineNo; LineNo) { }
                column(SalesCrMemoLine_Desc; Description) { }
                column(SalesCrMemoLine_Qty; Quantity) { }
                column(SalesCrMemoLine_UOM; "Unit of Measure") { }
                column(SalesCrMemoLine_UnitPriceExclVAT; "Unit Price") { }
                column(SalesCrMemoLine_AmountExclVAT; "Line Amount") { }
                column(SalesCrMemoLine_VATPerc; "VAT %") { }
                column(SalesCrMemoLine_VATAmount; "Amount Including VAT" - GetLineAmountExclVAT()) { }

                trigger OnAfterGetRecord()
                begin
                    if "VAT %" <> 20 then
                        exit;
                    Calculate20VAT();
                    LineNo += 1;
                end;
            }
            trigger OnPreDataItem()
            begin
                if (FilterSalesCrMemoNo <> '') or (FilterSalesCrMemoDate <> 0D) then begin
                    SetRange("No.", FilterSalesCrMemoNo);
                    SetRange("Posting Date", FilterSalesCrMemoDate);
                end
            end;

            trigger OnAfterGetRecord()
            var
                DateAndPlaceOfPrintLbl: Label 'Mesto i datum izdavanja: %1, %2', Locked = true, Comment = '%1 = City, %2 = Posting Date';
            begin
                DateAndPlaceOfPrintText := StrSubstNo(DateAndPlaceOfPrintLbl, CompanyInformation.City, Format(SalesCrMemoHdr."Posting Date", 10, '<Day,2>/<Month,2>/<Year4>'));
            end;
        }
        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(TotalAmountInclVAT20; TotalAmountIncl20VAT) { }
            column(TotalBaseVAT20; TotalBase20VAT) { }
            column(TotalVAT20Amount; TotalVAT20Amount) { }
            column(TotalAmountExcl20VAT; TotalAmountExcl20VAT) { }
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
                    field("Sales Inv. No."; FilterSalesCrMemoNo)
                    {
                        ApplicationArea = NPRRSLocal;
                        Caption = 'Sales Credit Memo No.';
                        ToolTip = 'Specifies the value of the Sales Credit Memo No. field.';
                    }
                    field("Posting Date"; FilterSalesCrMemoDate)
                    {
                        ApplicationArea = NPRRSLocal;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the value of the Posting Date field.';
                    }
                }
            }
        }
    }

    labels
    {
        SalesCrMemoHdrNoLbl = 'Osnovni avansi', Locked = true;
        SalesCrMemoHdrDateLbl = 'Datum izdavanja:', Locked = true;
        ReportNoLbl = 'Broj knjiznog odobrenja', Locked = true;
        RegNoLbl = 'Maticni broj:', Locked = true;
        VATRegNoLbl = 'PIB:', Locked = true;
        IndustrialInfoNoLbl = 'Sifra delatnosti:', Locked = true;
        PhoneNoLbl = 'Telefon/Fax:', Locked = true;
        AddressLbl = 'Adresa:', Locked = true;
        EmailLbl = 'E-mail:', Locked = true;
        BankAccountNoLbl = 'Tekuci racun:', Locked = true;
        SalesCrMemoLineNoLbl = 'R. br.', Locked = true;
        SalesCrMemoLineDescLbl = 'Opis', Locked = true;
        SalesCrMemoLineUOMLbl = 'JM', Locked = true;
        SalesCrMemoLineQtyLbl = 'Kol', Locked = true;
        SalesCrMemoLineAmtExclVATLbl = 'Umanjenje osnovice', Locked = true;
        SalesCrMemoLineVATPercLbl = 'PDV stopa', Locked = true;
        SalesCrMemoLineVATAmountLbl = 'Umanjenje PDV', Locked = true;
        TotalVAT20Lbl = 'Zbir stavki sa stopom 20%', Locked = true;
        TotalVAT20BaseLbl = 'Ukupno osnovica - stopa 20%', Locked = true;
        TotalVATAmountLbl = 'Ukupno PDV - Stopa 20%', Locked = true;
        TotalAmountLbl = 'Ukupan iznos', Locked = true;
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        CompanyAddress := FormatAddress(CompanyInformation.Address, CompanyInformation."Post Code", CompanyInformation.City);
        LineNo := 0;
    end;

    local procedure Calculate20VAT()
    begin
        TotalBase20VAT += SalesCrMemoLine."VAT Base Amount";
        TotalVAT20Amount += SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine."VAT Base Amount";
        TotalAmountIncl20VAT += SalesCrMemoLine."Amount Including VAT";
        TotalAmountExcl20VAT += SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.GetLineAmountExclVAT();
    end;

    local procedure FormatAddress(Address: Text[100]; PostCode: Code[20]; City: Text[30]): Text
    var
        AddressFormatLbl: Label '%1, %2 %3', Locked = true, Comment = '%1 = Address, %2 = Post Code, %3 = City';
    begin
        if (Address <> '') and (PostCode <> '') and (City <> '') then
            exit(StrSubstNo(AddressFormatLbl, Address, PostCode, City));
    end;

    internal procedure SetFilters(SalesCrMemoNo: Code[20]; SalesCrMemoPostingDate: Date)
    begin
        FilterSalesCrMemoNo := SalesCrMemoNo;
        FilterSalesCrMemoDate := SalesCrMemoPostingDate;
    end;

    var
        CompanyInformation: Record "Company Information";
        FilterSalesCrMemoNo: Code[20];
        FilterSalesCrMemoDate: Date;
        TotalAmountExcl20VAT: Decimal;
        TotalAmountIncl20VAT: Decimal;
        TotalBase20VAT: Decimal;
        TotalVAT20Amount: Decimal;
        LineNo: Integer;
        CompanyAddress: Text;
        CustomerAddress: Text;
        DateAndPlaceOfPrintText: Text;
}