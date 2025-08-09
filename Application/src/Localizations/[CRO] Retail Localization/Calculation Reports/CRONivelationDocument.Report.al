report 6014565 "NPR CRO Nivelation Document"
{
#if not BC17
    Extensible = false;
#endif
    UsageCategory = None;
    Caption = 'CRO Nivelation Document';
    DefaultLayout = Word;
    WordLayout = './src/Localizations/[CRO] Retail Localization/Calculation Reports/CRONivelation.docx';
    dataset
    {
        dataitem(RSPostedNivelationHdr; "NPR RS Posted Nivelation Hdr")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Posting Date";
            column(CompanyInfoName; CompanyInfo.Name) { }
            column(CompanyInfoAddress; CompanyInfo.Address) { }
            column(CompanyInfoCity; CompanyInfo.City) { }
            column(CompanyInfoRegistrationNo; CompanyInfo."Registration No.") { }
            column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.") { }
            column(CompanyInfoLocation; CompanyInfo."Location Code") { }
            column(Header_No; "No.") { }
            column(Posting_Date; Format("Posting Date", 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            column(PrintDate; Format(WorkDate(), 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            column(CustomerName; CustomerName) { }
            column(CustomerAddress; CustomerAddress) { }
            column(CustomerCity; CustomerCity) { }
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
                    CalcTotals();
                end;
            }

            trigger OnPreDataItem()
            begin
                if (FilterNo <> '') then
                    RSPostedNivelationHdr.SetRange("No.", FilterNo);

                if (FilterPostingDate <> 0D) then
                    RSPostedNivelationHdr.SetRange("Posting Date", FilterPostingDate);
            end;

            trigger OnAfterGetRecord()
            begin
                GetCustomerDetails();
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

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Posted Nivelation Document';
                    field("Trans Rec. No."; FilterNo)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Posted Nivelation Header No.';
                        ToolTip = 'Specifies the value of the osted Nivelation Header No. field.';
                        TableRelation = "NPR RS Posted Nivelation Hdr"."No.";
                    }
                    field("Trans Rec. Date"; FilterPostingDate)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the value of the Posting Date field.';
                    }
                }
            }
        }
    }
    labels
    {
        NoLbl = 'Br. artikla', Locked = true;
        ItemDescLbl = 'Naziv artikla', Locked = true;
        CodeLocationLbl = 'Lokacija', Locked = true;
        QuantityLbl = 'Kol.', Locked = true;
        UnitOfMeasureCodeLbl = 'Jedinica mjere', Locked = true;
        OldPriceLbl = 'Stara cijena', Locked = true;
        OldValueLbl = 'Stara vrijednost', Locked = true;
        NewPriceLbl = 'Nova cijena', Locked = true;
        NewValueLbl = 'Nova vrijednost', Locked = true;
        PriceDifferenceLbl = 'Razlika u cijeni', Locked = true;
        ValueDifferenceLbl = 'Razlika u vrijednosti', Locked = true;
        NivelationLbl = 'Nivelacija', Locked = true;
        CompanyRegNoLbl = 'OIB', Locked = true;
        CompanyNameLbl = 'Obveznik', Locked = true;
        CompanyAddressLbl = 'Firma - poslovnica', Locked = true;
        CompanyOfficeAddressLbl = 'Sjedište', Locked = true;
        CompanyVATRegNoLbl = 'Šifra poreznog obveznika', Locked = true;
        ReportTitle = 'NIVELACIJA PRODAJNE CIJENE', Locked = true;
        FooterDateLbl = 'Datum', Locked = true;
        CreatedByUserIDLbl = 'Sastavio', Locked = true;
        PersonResponsibleLbl = 'Odgovorna osoba', Locked = true;
        SumLbl = 'Ukupno', Locked = true;
        DocumentNoLbl = 'po dokumentu', Locked = true;
        PostingDateLbl = 'od', Locked = true;
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        TotalNewValue: Decimal;
        TotalOldValue: Decimal;
        TotalPriceDifference: Decimal;
        CustomerAddress: Text;
        CustomerCity: Text;
        FilterNo: Code[20];
        FilterPostingDate: Date;
        CustomerName: Text;


    internal procedure SetFilters(HeaderNo: Code[20]; PostingDate: Date)
    begin
        FilterNo := HeaderNo;
        FilterPostingDate := PostingDate;
    end;

    local procedure CalcTotals()
    begin
        TotalOldValue += NivelationLines."Old Value";
        TotalNewValue += NivelationLines."New Value";
        TotalPriceDifference += NivelationLines."Price Difference";
    end;

    local procedure GetCustomerDetails()
    begin
        case RSPostedNivelationHdr."Source Type" of
            RSPostedNivelationHdr."Source Type"::"Posted Sales Invoice":
                GetSalesInvoiceCustomerDetails(RSPostedNivelationHdr."Referring Document Code");
            RSPostedNivelationHdr."Source Type"::"POS Entry":
                GetPOSEntryCustomerDetails(RSPostedNivelationHdr."Referring Document Code");
            RSPostedNivelationHdr."Source Type"::"Posted Sales Credit Memo":
                GetSalesCrMemoCustomerDetails(RSPostedNivelationHdr."Referring Document Code");
        end;
    end;

    local procedure GetSalesInvoiceCustomerDetails(DocumentNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.Get(DocumentNo) then
            SetCustomerDetails(SalesInvoiceHeader."Sell-to Customer No.");
    end;

    local procedure GetPOSEntryCustomerDetails(DocumentNo: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Document No.", DocumentNo);
        POSEntry.SetFilter("Customer No.", '<>%1', '');
        if POSEntry.FindFirst() then
            SetCustomerDetails(POSEntry."Customer No.");
    end;

    local procedure GetSalesCrMemoCustomerDetails(DocumentNo: Code[20])
    var
        SalesCreditMemo: Record "Sales Cr.Memo Header";
    begin
        if SalesCreditMemo.Get(DocumentNo) then
            SetCustomerDetails(SalesCreditMemo."Sell-to Customer No.");
    end;

    local procedure SetCustomerDetails(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
        CustomerName := Customer.Name;
        CustomerAddress := Customer.Address;
        CustomerCity := Customer.City;
    end;
}