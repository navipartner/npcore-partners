report 6014563 "NPR CRO Ret. Purch. Price Calc"
{
#if not BC17
    Extensible = false;
#endif
    UsageCategory = None;
    Caption = 'CRO Retail Purchase Price Calculation';
    DefaultLayout = Word;
    WordLayout = './src/Localizations/[CRO] Retail Localization/Calculation Reports/CRORetailPriceCalculation.docx';
    dataset
    {
        dataitem(PurchInvHeader; "Purch. Inv. Header")
        {
            PrintOnlyIfDetail = true;
            column(ReportPrintNo; ReportPrintNo) { }
            column(CompanyInfoName; CompanyInfo.Name) { }
            column(CompanyInfoAddress; CompanyInfo.Address) { }
            column(CompanyInfoCity; CompanyInfo.City) { }
            column(CompanyInfoRegistrationNo; CompanyInfo."Registration No.") { }
            column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.") { }
            column(CompanyInfoLocation; CompanyInfo."Location Code") { }
            column(Sales_Invoice_Header_No; "No.") { }
            column(Sales_Invoice_Posting_Date; Format("Posting Date", 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            column(CustNoSeries; CustNoSeriesCode) { }
            column(User_ID; "User ID") { }
            column(PrintDate; Format(WorkDate(), 11, '<Day,2>.<Month,2>.<Year4>.')) { }
            column(PurchaseInvHeaderNo; PurchaseHeaderCodeFilter) { }
            dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Line No.") order(ascending);
                column(InvLine_Type; Type) { }
                column(InvLine_No; LineNo) { }
                column(InvLine_Description; Description) { }
                column(InvLine_UOMCode; "Unit of Measure Code") { }
                column(InvLine_Quantity; Quantity) { }
                column(InvLine_SalesPrice; InvLineSalesPrice) { }
                column(InvLine_PurchasePrice; InvLinePurchasePrice) { }
                column(InvLine_LinePurchasePriceExclVAT; InvLineTotalPurchasePriceExclVAT) { }
                column(InvLine_LineValueExclVAT; CalculateLineAmountLCY()) { }
                column(InvLine_ItemChargeAssigned; InvLineItemChargeAssigned) { }
                column(InvLine_MarginAmount; InvLineMarginAmount) { }
                column(InvLine_LineWithChargeAmountExclVAT; InvLineLineWChargeAmountExclVAT) { }
                column(InvLine_VATPercentage; InvLineVATPercentage) { }
                column(InvLine_VATAmount; InvLineVATAmount) { }
                column(InvLine_LineWithChargeAmountInclVAT; InvLineLineWChargeAmountInclVAT) { }
                column(InvLine_SalesPricePerUnit; InvLineSalesPricePerUnit) { }

                trigger OnAfterGetRecord()
                begin
                    CheckForRetailLocation();
                    if "Purch. Inv. Line".Type <> "Sales Line Type"::Item then
                        CurrReport.Skip();

                    Calculation();
                    CalcTotals();
                    LineNo += 1;
                end;
            }
            trigger OnPreDataItem()
            begin
                if (FilterInvoiceNo <> '') then
                    PurchInvHeader.SetRange("No.", FilterInvoiceNo);

                if (FilterPostingDate <> 0D) then
                    PurchInvHeader.SetRange("Posting Date", FilterPostingDate);
            end;
        }

        dataitem(Totals; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(TotalQty; TotalQty) { }
            column(TotalPurchasePrice; TotalPurchasePrice) { }
            column(TotalPurchaseLineValue; TotalPurchaseLineValue) { }
            column(TotalItemChargeAssigned; TotalItemChargeAssigned) { }
            column(TotalMargin; TotalMargin) { }
            column(TotalInvPurchaseValueExclVAT; TotalInvPurchaseValueExclVAT) { }
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
                    Caption = 'Purchase Invoice';
                    field("Purch Inv. No."; FilterInvoiceNo)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Purchase Invoice No.';
                        ToolTip = 'Specifies the value of the Purchase Invoice No. field.';
                        TableRelation = "Transfer Receipt Header"."No.";
                    }
                    field("Purch Inv. Date"; FilterPostingDate)
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
        FilterInvoiceNo: Code[20];
        ReportPrintNo: Code[20];
        FilterPostingDate: Date;
        InvLineItemChargeAssigned: Decimal;
        InvLineLineWChargeAmountExclVAT: Decimal;
        InvLineLineWChargeAmountInclVAT: Decimal;
        InvLineMarginAmount: Decimal;
        InvLinePurchasePrice: Decimal;
        InvLineSalesPrice: Decimal;
        InvLineSalesPricePerUnit: Decimal;
        InvLineTotalPurchasePriceExclVAT: Decimal;
        InvLineVATAmount: Decimal;
        InvLineVATPercentage: Decimal;
        PurchaseHeaderCodeFilter: Decimal;
        TotalInvPurchaseValueExclVAT: Decimal;
        TotalItemChargeAssigned: Decimal;
        TotalMargin: Decimal;
        TotalPurchaseLineValue: Decimal;
        TotalPurchasePrice: Decimal;
        TotalQty: Decimal;
        TotalSalesPricePerUnit: Decimal;
        TotalValueWithChargeInclVAT: Decimal;
        TotalVATAmount: Decimal;
        LineNo: Integer;

    local procedure CheckForRetailLocation()
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not RSRLocalizationMgt.IsRetailLocation("Purch. Inv. Line"."Location Code") then
            CurrReport.Skip();
    end;

    local procedure CalculateItemCharge(var LineItemChargeAmount: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Document No.", "Document Line No.", "Document Type");
        ValueEntry.SetLoadFields("Item No.", "Document No.", "Location Code", "Document Line No.", "Item Ledger Entry No.", "Cost Amount (Actual)");
        ValueEntry.SetRange("Item No.", "Purch. Inv. Line"."No.");
        ValueEntry.SetRange("Document No.", "Purch. Inv. Line"."Document No.");
        ValueEntry.SetRange("Location Code", "Purch. Inv. Line"."Location Code");
        ValueEntry.SetRange("Document Line No.", "Purch. Inv. Line"."Line No.");
        ValueEntry.CalcSums("Cost Amount (Actual)");

        ItemLedgerEntry.SetCurrentKey("Entry No.");
        ItemLedgerEntry.SetLoadFields("Entry No.", "Item No.", "Cost Amount (Actual)");
        ItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
        ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
        ItemLedgerEntry.SetRange("Item No.", ValueEntry."Item No.");
        ItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
        if not ItemLedgerEntry.FindFirst() then
            exit;
        if ItemLedgerEntry."Cost Amount (Actual)" <> Abs(ValueEntry."Cost Amount (Actual)") then
            LineItemChargeAmount := ItemLedgerEntry."Cost Amount (Actual)" - Abs(ValueEntry."Cost Amount (Actual)");
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
                ReportPrintNo := NoSeriesMgt.PeekNextNo(LocalizationSetup."RS Ret. Purch. Report Ord.");
#ELSE
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Purch. Report Ord.", 0D, false);
#ENDIF
            false:
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Purch. Report Ord.", 0D, false);
#ELSE
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Purch. Report Ord.", 0D, true);
#ENDIF
        end;
    end;

    local procedure Calculation()
    var
        Item: Record Item;
        PriceListLine: Record "Price List Line";
        VATPostingSetup: Record "VAT Posting Setup";
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        VATBreakDown: Decimal;
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
    begin
        PriceListLine.SetRange("Price Type", "Price Type"::Sale);
        PriceListLine.SetRange(Status, "Price Status"::Active);
        PriceListLine.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, PurchInvHeader."Posting Date"));
        PriceListLine.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, PurchInvHeader."Posting Date"));
        PriceListLine.SetRange("Asset No.", "Purch. Inv. Line"."No.");
        if not PriceListLine.FindFirst() then
            exit;
        InvLineSalesPrice := PriceListLine."Unit Price";
        Item.Get("Purch. Inv. Line"."No.");
        if VATPostingSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
            VATBreakDown := (100 * VATPostingSetup."VAT %") / (100 + VATPostingSetup."VAT %") / 100;

        InvLinePurchasePrice := CalculateLineAmountLCY() / "Purch. Inv. Line".Quantity;
        InvLineLineWChargeAmountInclVAT := InvLineSalesPrice * "Purch. Inv. Line".Quantity;
        InvLineVATAmount := InvLineLineWChargeAmountInclVAT * VATBreakDown;
        InvLineVATPercentage := VATPostingSetup."VAT %";
        InvLineLineWChargeAmountExclVAT := InvLineLineWChargeAmountInclVAT - (InvLineLineWChargeAmountInclVAT * VATBreakDown);
        CalculateItemCharge(InvLineItemChargeAssigned);
        InvLineMarginAmount := InvLineLineWChargeAmountExclVAT - (CalculateLineAmountLCY() + InvLineItemChargeAssigned);
    end;

    local procedure CalcTotals()
    begin
        TotalQty += "Purch. Inv. Line".Quantity;
        TotalPurchasePrice += InvLinePurchasePrice;
        TotalPurchaseLineValue += CalculateLineAmountLCY();
        TotalItemChargeAssigned += InvLineItemChargeAssigned;
        TotalMargin += InvLineMarginAmount;
        TotalVATAmount += InvLineVATAmount;
        TotalInvPurchaseValueExclVAT += InvLineLineWChargeAmountExclVAT;
        TotalValueWithChargeInclVAT += InvLineLineWChargeAmountInclVAT;
        TotalSalesPricePerUnit += InvLineSalesPricePerUnit;
    end;

    local procedure CalculateLineAmountLCY(): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PurchInvHeader."Currency Code" <> '' then
            exit(CurrExchRate.ExchangeAmtFCYToLCY(PurchInvHeader."Posting Date", PurchInvHeader."Currency Code", "Purch. Inv. Line".Amount, PurchInvHeader."Currency Factor"))
        else
            exit("Purch. Inv. Line".Amount);
    end;

    internal procedure SetFilters(PurchInvNo: Code[20]; PurchInvDate: Date)
    begin
        FilterInvoiceNo := PurchInvNo;
        FilterPostingDate := PurchInvDate;
    end;
}