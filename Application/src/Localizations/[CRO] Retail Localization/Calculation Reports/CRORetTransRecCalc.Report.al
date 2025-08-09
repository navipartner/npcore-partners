report 6014564 "NPR CRO Ret. Trans. Rec. Calc"
{
#if not BC17
    Extensible = false;
#endif
    UsageCategory = None;
    Caption = 'CRO Retail Transfer Receipt Price Calculation';
    DefaultLayout = Word;
    WordLayout = './src/Localizations/[CRO] Retail Localization/Calculation Reports/CROTransferReceiptPriceCalc.docx';

    dataset
    {
        dataitem(TransRecHdr; "Transfer Receipt Header")
        {
            PrintOnlyIfDetail = true;
            column(ReportPrintNo; ReportPrintNo) { }
            column(CompanyInfoName; CompanyInfo.Name) { }
            column(CompanyInfoAddress; CompanyInfo.Address) { }
            column(CompanyInfoCity; CompanyInfo.City) { }
            column(CompanyInfoRegistrationNo; CompanyInfo."Registration No.") { }
            column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.") { }
            column(CompanyInfoLocation; CompanyInfo."Location Code") { }
            column(Transfer_Receipt_Header_No; "No.") { }
            column(Transfer_Receipt_Posting_Date; Format("Posting Date", 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            column(CustNoSeries; CustNoSeriesCode) { }
            column(User_ID; UserId) { }
            column(PrintDate; Format(WorkDate(), 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            dataitem(ItemLedgerEntry; "Item Ledger Entry")
            {
                CalcFields = "Cost Amount (Actual)";
                DataItemLink = "Document No." = field("No."), "Location Code" = field("Transfer-to Code");
                DataItemTableView = sorting("Entry No.") order(ascending) where(Quantity = filter('>0'));

                column(ReceiptLine_No; LineNo) { }
                column(ReceiptLine_Description; ItemDescription) { }
                column(ReceiptLine_UOMCode; "Unit of Measure Code") { }
                column(ReceiptLine_Quantity; Quantity) { }
                column(ReceiptLine_CostAmount; RecLineCostAmount) { }
                column(ReceiptLine_CostValueExclVAT; RecLineCostValueExclVAT) { }
                column(ReceiptLine_SalesPrice; RecLineSalesPrice) { }
                column(ReceiptLine_LineValueAmountExclVAT; RecLineSalesPriceExclVAT) { }
                column(ReceiptLine_LineValueExclVAT; RecLineLineValueExclVAT) { }
                column(ReceiptLine_MarginAmount; RecLineMarginAmount) { }
                column(ReceiptLine_LineWithChargeAmountExclVAT; RecLineLineWChargeAmountExclVAT) { }
                column(ReceiptLine_VATPercentage; RecLineVATPercentage) { }
                column(ReceiptLine_VATAmount; RecLineVATAmount) { }
                column(ReceiptLine_LineWithChargeAmountInclVAT; RecLineLineWChargeAmountInclVAT) { }
                column(ReceiptLine_SalesPricePerUnit; RecLineSalesPricePerUnit) { }

                trigger OnAfterGetRecord()
                begin
                    CheckForRetailLocation();

                    Calculation();

                    CalcTotals();

                    LineNo += 1;
                end;
            }
            trigger OnPreDataItem()
            begin
                if (FilterReceiptNo <> '') then
                    TransRecHdr.SetRange("No.", FilterReceiptNo);

                if (FilterPostingDate <> 0D) then
                    TransRecHdr.SetRange("Posting Date", FilterPostingDate);
            end;
        }

        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(TotalQty; TotalQty) { }
            column(TotalPurchasePrice; TotalCostAmount) { }
            column(TotalPurchaseLineValue; TotalRecLineValue) { }
            column(TotalMargin; TotalMargin) { }
            column(TotalInvPurchaseValueExclVAT; TotalRecLineValueExclVAT) { }
            column(TotalVATAmount; TotalVATAmount) { }
            column(TotalValueWithChargeInclVAT; TotalValueWithChargeInclVAT) { }
            column(TotalSalesPricePerUnit; TotalSalesPricePerUnit) { }
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
                    Caption = 'Transfer Receipt';
                    field("Trans Rec. No."; FilterReceiptNo)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Transfer Receipt No.';
                        ToolTip = 'Specifies the value of the Transfer Receipt No. field.';
                        TableRelation = "Transfer Receipt Header"."No.";
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
        InvoiceLineNoLbl = 'R. br.', Locked = true;
        ItemDescLbl = 'Naziv robe', Locked = true;
        UnitOfMeasureLbl = 'Jedinica mjere', Locked = true;
        AccordingToInvLbl = 'Prema fakturi dobavljača¹', Locked = true;
        LineQuantityLbl = 'Količina', Locked = true;
        UnitPriceLbl = 'Cijena po jedinici mjere', Locked = true;
        LineValueLbl = 'Vrijednost robe (4x5)', Locked = true;
        LineChargeLbl = 'Zavisni troškovi²', Locked = true;
        MarginLbl = 'Razlika u cijeni', Locked = true;
        LineValueExclVATLbl = 'Prodajna vrijednost robe bez PDV-a (6+7+8)', Locked = true;
        VATLbl = 'PDV', Locked = true;
        VATPercLbl = 'Stopa', Locked = true;
        CalculatedVATLbl = 'Obračunati iznos', Locked = true;
        LineValueInclVATLbl = 'Prodajna vrijednost robe s obračunatim PDV-om (9+11)', Locked = true;
        LineValueForQuantityLbl = 'Prodajna cijena po jedinici mjere (12:4)', Locked = true;
        CommentLbl = 'Napomena', Locked = true;
        CompanyRegNoLbl = 'OIB', Locked = true;
        CompanyNameLbl = 'Obveznik', Locked = true;
        CompanyAddressLbl = 'Firma - poslovnica', Locked = true;
        CompanyAddress2Lbl = 'Sjedište', Locked = true;
        CompanyVATRegNoLbl = 'Šifra poreznog obveznika', Locked = true;
        ReportTitle = 'KALKULACIJA PRODAJNE CIJENE BROJ', Locked = true;
        ReportTitle2 = 'KL', Locked = true;
        DocumentNoLbl = 'po dokumentu', Locked = true;
        PostingDateLbl = 'od', Locked = true;
        FooterDateLbl = 'Datum', Locked = true;
        UserIDLbl = 'Sastavio', Locked = true;
        PersonResponsibleLbl = 'Odgovorna osoba', Locked = true;
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        LineNo := 0;
    end;

    trigger OnPreReport()
    begin
        SetupReportPrintOrderNo();
    end;

    var
        CompanyInfo: Record "Company Information";
        CustNoSeriesCode: Code[20];
        FilterReceiptNo: Code[20];
        ReportPrintNo: Code[20];
        FilterPostingDate: Date;
        RecLineCostAmount: Decimal;
        RecLineCostValueExclVAT: Decimal;
        RecLineLineValueExclVAT: Decimal;
        RecLineLineWChargeAmountExclVAT: Decimal;
        RecLineLineWChargeAmountInclVAT: Decimal;
        RecLineMarginAmount: Decimal;
        RecLineSalesPrice: Decimal;
        RecLineSalesPriceExclVAT: Decimal;
        RecLineSalesPricePerUnit: Decimal;
        RecLineVATAmount: Decimal;
        RecLineVATPercentage: Decimal;
        TotalCostAmount: Decimal;
        TotalMargin: Decimal;
        TotalQty: Decimal;
        TotalRecLineValue: Decimal;
        TotalRecLineValueExclVAT: Decimal;
        TotalSalesPricePerUnit: Decimal;
        TotalValueWithChargeInclVAT: Decimal;
        TotalVATAmount: Decimal;
        LineNo: Integer;
        ItemDescription: Text[100];

    local procedure CheckForRetailLocation()
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not RSRLocalizationMgt.IsRetailLocation(TransRecHdr."Transfer-to Code") then
            CurrReport.Skip();
    end;

    local procedure SetupReportPrintOrderNo()
    var
        LocalizationSetup: Record "NPR RS R Localization Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        LocalizationSetup.Get();
        case CurrReport.Preview() of
            true:
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                ReportPrintNo := NoSeriesMgt.PeekNextNo(LocalizationSetup."RS Ret. Transfer Report Ord.");
#ELSE
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Transfer Report Ord.", 0D, false);
#ENDIF
            false:
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Transfer Report Ord.", 0D, false);
#ELSE
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Transfer Report Ord.", 0D, true);
#ENDIF
        end;
    end;

    local procedure Calculation()
    var
        Item: Record Item;
        PriceListLine: Record "Price List Line";
        ValueEntry: Record "Value Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        VATBreakDown: Decimal;
    begin
        GetPriceListLine(PriceListLine);
        RecLineSalesPrice := PriceListLine."Unit Price";
        Item.Get(ItemLedgerEntry."Item No.");
        ItemDescription := Item.Description;
        if VATPostingSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
            VATBreakDown := (100 * VATPostingSetup."VAT %") / (100 + VATPostingSetup."VAT %") / 100;

        RecLineLineWChargeAmountInclVAT := RecLineSalesPrice * ItemLedgerEntry.Quantity;
        RecLineVATAmount := RecLineLineWChargeAmountInclVAT * VATBreakDown;
        RecLineVATPercentage := VATPostingSetup."VAT %";

        ValueEntry.SetLoadFields("Document Type", "Document No.", "Item Ledger Entry No.", "Location Code", "Cost Amount (Actual)", "Entry No.");
        ValueEntry.SetCurrentKey("Entry No.");
        ValueEntry.SetRange("Document Type", ItemLedgerEntry."Document Type");
        ValueEntry.SetRange("Document No.", ItemLedgerEntry."Document No.");
        ValueEntry.SetRange("Location Code", ItemLedgerEntry."Location Code");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        if not ValueEntry.FindFirst() then
            exit;

        RecLineCostValueExclVAT := ValueEntry."Cost Amount (Actual)";
        RecLineCostAmount := RecLineCostValueExclVAT / ItemLedgerEntry.Quantity;
        RecLineLineWChargeAmountExclVAT := RecLineLineWChargeAmountInclVAT - RecLineVATAmount;
        RecLineMarginAmount := RecLineLineWChargeAmountExclVAT - RecLineCostValueExclVAT;
    end;

    local procedure CalcTotals()
    begin
        TotalQty += ItemLedgerEntry.Quantity;
        TotalCostAmount += RecLineCostAmount;
        TotalRecLineValue += RecLineCostValueExclVAT;
        TotalMargin += RecLineMarginAmount;
        TotalVATAmount += RecLineVATAmount;
        TotalRecLineValueExclVAT += RecLineLineWChargeAmountExclVAT;
        TotalValueWithChargeInclVAT += RecLineLineWChargeAmountInclVAT;
        TotalSalesPricePerUnit += RecLineSalesPricePerUnit;
    end;

    local procedure GetPriceListLine(var PriceListLine: Record "Price List Line")
    var
        PriceListHeader: Record "Price List Header";
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        PriceListNotFoundErr: Label 'Price List for the Location %1 has not been found.', Comment = '%1 - Location Code';
        PriceNotFoundErr: Label 'Price for the Item %1 has not been found in Price List: %2 for Location %3', Comment = '%1 - Item No, %2 - Price List Code, %3 - Location Code';
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
    begin
        PriceListHeader.SetLoadFields(Code);
        PriceListHeader.SetRange(Status, "Price Status"::Active);

        PriceListHeader.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, TransRecHdr."Posting Date"));
        PriceListHeader.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, TransRecHdr."Posting Date"));
        PriceListHeader.SetRange("NPR Location Code", TransRecHdr."Transfer-to Code");
        if not PriceListHeader.FindFirst() then
            Error(PriceListNotFoundErr, TransRecHdr."Transfer-to Code");

        PriceListLine.SetLoadFields("Unit Price", "VAT Bus. Posting Gr. (Price)");
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset No.", ItemLedgerEntry."Item No.");
        if not PriceListLine.FindFirst() then
            Error(PriceNotFoundErr, ItemLedgerEntry."Item No.", PriceListHeader.Code, TransRecHdr."Transfer-to Code");
    end;

    internal procedure SetFilters(ReceiptNo: Code[20]; TransRecDate: Date)
    begin
        FilterReceiptNo := ReceiptNo;
        FilterPostingDate := TransRecDate;
    end;
}