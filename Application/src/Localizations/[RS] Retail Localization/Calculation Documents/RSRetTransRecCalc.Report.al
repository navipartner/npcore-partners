report 6014484 "NPR RS Ret. Trans. Rec. Calc."
{
#if not BC17
    Extensible = false;
#endif
    UsageCategory = None;
    Caption = 'Retail Transfer Receipt Price Calculation';
    DefaultLayout = Word;
    WordLayout = './src/Localizations/[RS] Retail Localization/Calculation Documents/TransferReceiptPriceCalc.docx';

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
                if (FilterReceiptNo <> '') or (FilterPostingDate <> 0D) then begin
                    TransRecHdr.SetRange("No.", FilterReceiptNo);
                    TransRecHdr.SetRange("Posting Date", FilterPostingDate);
                end;
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
        VATPostingSetup: Record "VAT Posting Setup";
        ValueEntry: Record "Value Entry";
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
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        PriceNotFoundErr: Label 'Price for the Item %1 has not been found in Price List: %2 for Location %3', Comment = '%1 - Item No, %2 - Price List Code, %3 - Location Code';
        PriceListNotFoundErr: Label 'Price List for the Location %1 has not been found.', Comment = '%1 - Location Code';
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