report 6014483 "NPR RS Ret. Purch. Price Calc."
{
#if not BC17
    Extensible = false;
#endif
    UsageCategory = None;
    Caption = 'Retail Purchase Price Calculation';
    DefaultLayout = Word;
    WordLayout = './src/Localizations/[RS] Retail Localization/Calculation Documents/RetailPriceCalculation.docx';
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
                if (FilterInvoiceNo <> '') or (FilterPostingDate <> 0D) then begin
                    PurchInvHeader.SetRange("No.", FilterInvoiceNo);
                    PurchInvHeader.SetRange("Posting Date", FilterPostingDate);
                end;
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
        InvoiceLineNoLbl = 'Р. бр.', Locked = true;
        ItemDescLbl = 'Назив робе', Locked = true;
        UnitOfMeasureLbl = 'Јединица мере', Locked = true;
        AccordingToInvLbl = 'По фактури добављача¹', Locked = true;
        LineQuantityLbl = 'количина', Locked = true;
        UnitPriceLbl = 'цена по јединици мере', Locked = true;
        LineValueLbl = 'вредност робе (4х5)', Locked = true;
        LineChargeLbl = 'Зависни трошкови²', Locked = true;
        MarginLbl = 'Разлика у цени', Locked = true;
        LineValueExclVATLbl = 'Продајна вредност робе без ПДВ (6+7+8)', Locked = true;
        VATLbl = 'ПДВ', Locked = true;
        VATPercLbl = 'Стопа', Locked = true;
        CalculatedVATLbl = 'Обрачунати износ', Locked = true;
        LineValueInclVATLbl = 'Продајна вредност робе са обрачунатим ПДВ (9+11)', Locked = true;
        LineValueForQuantityLbl = 'Продајна цена по јединици мере (12:4)', Locked = true;
        CommentLbl = 'Напомена', Locked = true;
        CompanyRegNoLbl = 'ПИБ', Locked = true;
        CompanyNameLbl = 'Обвезник', Locked = true;
        CompanyAddressLbl = 'Фирма-радње', Locked = true;
        CompanyAddress2Lbl = 'Седиште', Locked = true;
        CompanyVATRegNoLbl = 'Шифра пореског обвезника', Locked = true;
        ReportTitle = 'КАЛКУЛАЦИЈА ПРОДАЈНЕ ЦЕНЕ БРОЈ', Locked = true;
        ReportTitle2 = 'КЛ', Locked = true;
        DocumentNoLbl = 'по документу', Locked = true;
        PostingDateLbl = 'од', Locked = true;
        FooterDateLbl = 'Датум', Locked = true;
        UserIDLbl = 'Саставио', Locked = true;
        PersonResponsibleLbl = 'Одговорно лице', Locked = true;
        Superscript1InformationLbl = '1 предузетници - обвезници ПДВ, уносе набавну вредност робе без обрачунатог ПДВ у фактури добављача а предузетници који нису обвезници ПДВ као набавну вредност робе уносе бруто износ из фактуре добављача са обрачунатим ПДВ. ', Locked = true;
        Superscript2InformationLbl = '2 предузетници - обвезници ПДВ, уносе вредност зависних трошкова без обрачунатог ПДВ из фактуре, а предузетници ПДВ као вредност зависних трошкова уносе бруто износ са обрачунатим ПДВ', Locked = true;
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
        ReportPrintNo: Code[20];
        InvLineItemChargeAssigned: Decimal;
        InvLineLineWChargeAmountExclVAT: Decimal;
        InvLineLineWChargeAmountInclVAT: Decimal;
        InvLineMarginAmount: Decimal;
        InvLineSalesPrice: Decimal;
        InvLineTotalPurchasePriceExclVAT: Decimal;
        InvLineSalesPricePerUnit: Decimal;
        InvLineVATAmount: Decimal;
        InvLineVATPercentage: Decimal;
        InvLinePurchasePrice: Decimal;
        TotalQty: Decimal;
        TotalPurchasePrice: Decimal;
        TotalPurchaseLineValue: Decimal;
        TotalItemChargeAssigned: Decimal;
        TotalMargin: Decimal;
        TotalVATAmount: Decimal;
        TotalInvPurchaseValueExclVAT: Decimal;
        TotalValueWithChargeInclVAT: Decimal;
        TotalSalesPricePerUnit: Decimal;
        PurchaseHeaderCodeFilter: Decimal;
        LineNo: Integer;
        FilterInvoiceNo: Code[20];
        FilterPostingDate: Date;

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
        if not ValueEntry.FindSet() then
            exit;
        ValueEntry.CalcSums("Cost Amount (Actual)");

        ItemLedgerEntry.SetCurrentKey("Entry No.");
        ItemLedgerEntry.SetLoadFields("Entry No.", "Item No.", "Cost Amount (Actual)");
        ItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
        ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
        ItemLedgerEntry.SetRange("Item No.", ValueEntry."Item No.");
        if not ItemLedgerEntry.FindFirst() then
            exit;
        ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
        if ItemLedgerEntry."Cost Amount (Actual)" <> Abs(ValueEntry."Cost Amount (Actual)") then
            LineItemChargeAmount := ItemLedgerEntry."Cost Amount (Actual)" - Abs(ValueEntry."Cost Amount (Actual)");
    end;

    local procedure SetupReportPrintOrderNo()
    var
        LocalizationSetup: Record "NPR RS R Localization Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        LocalizationSetup.Get();
        case CurrReport.Preview() of
            true:
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Purch. Report Ord.", 0D, false);
            false:
                ReportPrintNo := NoSeriesMgt.GetNextNo(LocalizationSetup."RS Ret. Purch. Report Ord.", 0D, true);
        end;
    end;

    local procedure Calculation()
    var
        Item: Record Item;
        PriceListLine: Record "Price List Line";
        VATPostingSetup: Record "VAT Posting Setup";
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        VATBreakDown: Decimal;
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