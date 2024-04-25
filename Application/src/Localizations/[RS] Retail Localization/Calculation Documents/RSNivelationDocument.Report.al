report 6014523 "NPR RS Nivelation Document"
{
#if not BC17
    Extensible = false;
#endif
    UsageCategory = None;
    Caption = ' RS Nivelation Document';
    DefaultLayout = Word;
    WordLayout = './src/Localizations/[RS] Retail Localization/Calculation Documents/RSNivelation.docx';
    dataset
    {
        dataitem(RSPostedNivelationHdr; "NPR RS Posted Nivelation Hdr")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Posting Date";
            dataitem(CompanyInfo; "Company Information")
            {
                MaxIteration = 1;
                column(CompanyInfoName; CompanyInfo.Name) { }
                column(CompanyInfoAddress; CompanyInfo.Address) { }
                column(CompanyInfoCity; CompanyInfo.City) { }
                column(CompanyInfoRegistrationNo; CompanyInfo."Registration No.") { }
                column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.") { }
            }
            column(Header_No; "No.") { }
            column(Posting_Date; Format("Posting Date", 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            column(PrintDate; Format(WorkDate(), 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            column(CustomerName; CustomerName) { }
            column(CustomerAddress; CustomerAddress) { }
            column(CustomerCity; CustomerCity) { }
            column(HeaderText; HeaderText) { }
            dataitem(NivelationLines; "NPR RS Posted Nivelation Lines")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Line No.") order(ascending);
                column(ItemNo; "Item No.") { }
                column(Nivelation_Description; "Item Description") { }
                column(Nivelation_LocationCode; "Location Code") { }
                column(Nivelation_Quantity; Quantity) { }
                column(Nivelation_UOMC; "UOM Code") { }
                column(Nivelation_OldPrice; "Old Price") { }
                column(Nivelation_OldValue; "Old Value") { }
                column(Nivelation_NewPrice; "New Price") { }
                column(Nivelation_NewValue; "New Value") { }
                column(Nivelation_PriceDifference; "Price Difference") { }
                column(Nivelation_ValueDifference; "Value Difference") { }

                trigger OnAfterGetRecord()
                begin
                    if CheckIfNotRetailLocation() then
                        CurrReport.Skip();
                    CalcTotals();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FindCustomerDetails();
                HeaderText := DocumentNoLbl + ' ' + "No." + ' ' + PostingDateLbl + ' ' + Format("Posting Date");
            end;
        }

        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(TotalOldValue; TotalOldValue) { }
            column(TotalNewValue; TotalNewValue) { }
            column(TotalPriceDifference; TotalPriceDifference) { }
        }
    }
    labels
    {
        NoLbl = 'Бр. артикла', Locked = true;
        ItemDescLbl = 'Назив артикла', Locked = true;
        CodeLocationLbl = 'Локација', Locked = true;
        QuantityLbl = 'Кол', Locked = true;
        UnitOfMeasureCodeLbl = 'Јединица мере', Locked = true;
        OldPriceLbl = 'Стара цена', Locked = true;
        OldValueLbl = 'Стара вредност', Locked = true;
        NewPriceLbl = 'Нова цена', Locked = true;
        NewValueLbl = 'Нова вредност', Locked = true;
        PriceDifferenceLbl = 'Разлика у цени', Locked = true;
        ValueDifferenceLbl = 'Разлика у вредности', Locked = true;
        NivelationLbl = 'Нивелација', Locked = true;
        CompanyRegNoLbl = 'ПИБ', Locked = true;
        CompanyNameLbl = 'Обвезник', Locked = true;
        CompanyAddressLbl = 'Фирма-радње', Locked = true;
        CompanyOfficeAddressLbl = 'Седиште', Locked = true;
        CompanyVATRegNoLbl = 'Шифра пореског обвезника', Locked = true;
        ReportTitle = 'НИВЕЛАЦИЈА ПРОДАЈНЕ ЦЕНЕ ', Locked = true;
        FooterDateLbl = 'Датум', Locked = true;
        CreatedByUserIDLbl = 'Саставио', Locked = true;
        PersonResponsibleLbl = 'Одговорно лице', Locked = true;
        SumLbl = 'Укупно', Locked = true;
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
    end;

    var
        TotalNewValue: Decimal;
        TotalOldValue: Decimal;
        TotalPriceDifference: Decimal;
        DocumentNoLbl: Label 'по документу', Locked = true;
        PostingDateLbl: Label 'од', Locked = true;
        CustomerAddress: Text;
        CustomerCity: Text;
        CustomerName: Text;
        HeaderText: Text;

    local procedure CheckIfNotRetailLocation(): Boolean
    var
        Location: Record Location;
    begin
        if not Location.Get(NivelationLines."Location Code") then
            exit(true);
        if not Location."NPR Retail Location" then
            exit(true);
        exit(false);
    end;

    local procedure CalcTotals()
    begin
        TotalOldValue += NivelationLines."Old Value";
        TotalNewValue += NivelationLines."New Value";
        TotalPriceDifference += NivelationLines."Price Difference";
    end;

    local procedure FindCustomerDetails()
    var
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        SalesCreditMemo: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if (RSPostedNivelationHdr.Type = "NPR RS Nivelation Type"::"Price Change") then
            exit;
        case (RSPostedNivelationHdr."Source Type") of
            "NPR RS Nivelation Source Type"::"Posted Sales Invoice":
                if SalesInvoiceHeader.Get(RSPostedNivelationHdr."Referring Document Code") then begin
                    CustomerName := SalesInvoiceHeader."Sell-to Customer Name";
                    CustomerAddress := SalesInvoiceHeader."Sell-to Address";
                    CustomerCity := SalesInvoiceHeader."Sell-to City";
                end;
            "NPR RS Nivelation Source Type"::"POS Entry":
                if POSEntry.Get(RSPostedNivelationHdr."Referring Document Code") then
                    if Customer.Get(POSEntry."Customer No.") then begin
                        CustomerName := Customer.Name;
                        CustomerAddress := Customer.Address;
                        CustomerCity := Customer.City;
                    end;
            "NPR RS Nivelation Source Type"::"Posted Sales Credit Memo":
                if SalesCreditMemo.Get(RSPostedNivelationHdr."Referring Document Code") then begin
                    CustomerName := SalesCreditMemo."Sell-to Customer Name";
                    CustomerAddress := SalesCreditMemo."Sell-to Address";
                    CustomerCity := SalesCreditMemo."Sell-to City";
                end
        end;
    end;
}