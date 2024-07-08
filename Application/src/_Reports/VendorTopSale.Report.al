report 6014426 "NPR Vendor Top/Sale"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Vendor TopSale.rdlc';
    Caption = 'Top Vendor by Item Sales';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Global Dimension 1 Filter", "Date Filter";

            trigger OnAfterGetRecord()
            var
                Vendor2: Record Vendor;
                COGSLCY: Decimal;
                InventoryQty: Decimal;
                SalesLCY: Decimal;
                SalesQty: Decimal;
                Amounts: List of [Decimal];
            begin
                NPRGetVESalesLCYSalesQtyCOGSLCY(SalesLCY, SalesQty, COGSLCY);
                case ShowType of
                    ShowType::"Sales (LCY)":
                        if (SalesLCY <= 0) then
                            CurrReport.Skip();
                    ShowType::"Sales (Qty.)":
                        if (SalesQty <= 0) then
                            CurrReport.Skip();
                    ShowType::Profit:
                        if ((SalesLCY - COGSLCY) <= 0) then
                            CurrReport.Skip();
                end;

                Clear(Amounts);
                CalcVendorInventoryQty(Vendor, InventoryQty);
                Amounts.AddRange(SalesLCY, SalesQty, SalesLCY - COGSLCY, InventoryQty, COGSLCY);

                TempVendorAmount.Init();
                TempVendorAmount."Vendor No." := "No.";

                case ShowType of
                    ShowType::"Sales (LCY)":
                        TempVendorAmount."Amount (LCY)" := SortDirectionMultiplier * SalesLCY;
                    ShowType::"Sales (Qty.)":
                        TempVendorAmount."Amount (LCY)" := SortDirectionMultiplier * SalesQty;
                    ShowType::Profit:
                        TempVendorAmount."Amount (LCY)" := SortDirectionMultiplier * (SalesLCY - COGSLCY);
                end;

                TempVendorAmount.Insert();

                Vendor2.Get(Vendor."No.");
                Vendor2.CopyFilters(Vendor);
                Vendor2.SetFilter("Date Filter", '%1..%2', StartDateLastYear, EndDateLastYear);
                Vendor2.NPRGetVESalesLCYSalesQtyCOGSLCY(SalesLCY, SalesQty, COGSLCY);
                CalcVendorInventoryQty(Vendor2, InventoryQty);
                Amounts.AddRange(SalesLCY, SalesQty, SalesLCY - COGSLCY, InventoryQty, COGSLCY);

                VendorAmtsDict.Add(Vendor."No.", Amounts);

                TotalSalesLCY += VendorAmtsDict.Get(Vendor."No.").Get(1);
                TotalSalesQty += VendorAmtsDict.Get(Vendor."No.").Get(2);
                TotalProfit += VendorAmtsDict.Get(Vendor."No.").Get(3);
                TotalInventoryQty += VendorAmtsDict.Get(Vendor."No.").Get(4);
                TotalInventoryValue += VendorAmtsDict.Get(Vendor."No.").Get(5);

                TotalSalesLCYLY += VendorAmtsDict.Get(Vendor."No.").Get(6);
                TotalSalesQtyLY += VendorAmtsDict.Get(Vendor."No.").Get(7);
                TotalProfitLY += VendorAmtsDict.Get(Vendor."No.").Get(8);
                TotalInventoryQtyLY += VendorAmtsDict.Get(Vendor."No.").Get(9);
                TotalInventoryValueLY += VendorAmtsDict.Get(Vendor."No.").Get(10);

                if (NoOfRecordsToPrint = 0) or (Index < NoOfRecordsToPrint) then
                    Index := Index + 1
                else begin
                    if SortOrder = SortOrder::Ascending then
                        TempVendorAmount.FindFirst()
                    else
                        TempVendorAmount.FindLast();
                    VendorAmtsDict.Remove(TempVendorAmount."Vendor No.");
                    TempVendorAmount.Delete();
                end;
            end;

            trigger OnPreDataItem()
            begin
                TempVendorAmount.DeleteAll();
                Clear(VendorAmtsDict);
                Index := 0;
            end;
        }

        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(RankAccordingToTxt; StrSubstNo(RankAccordingToLbl, SelectStr(ShowType + 1, ShowTypeOptionsLbl))) { }
            column(Vendor_FilterText; VendorFilterText) { }
            column(Integer_Number; Number) { }
            column(Vendor_No; Vendor."No.") { }
            column(Vendor_Name; Vendor.Name) { }

            column(Vendor_SalesLCY; VendorAmtsDict.Get(Vendor."No.").Get(1)) { }
            column(Vendor_SalesQty; VendorAmtsDict.Get(Vendor."No.").Get(2)) { }
            column(Vendor_Profit; VendorAmtsDict.Get(Vendor."No.").Get(3)) { }
            column(Vendor_InventoryQty; VendorAmtsDict.Get(Vendor."No.").Get(4)) { }
            column(Vendor_InventoryValue; VendorAmtsDict.Get(Vendor."No.").Get(5)) { }

            column(Vendor_SalesLCY_LY; VendorAmtsDict.Get(Vendor."No.").Get(6)) { }
            column(Vendor_SalesQty_LY; VendorAmtsDict.Get(Vendor."No.").Get(7)) { }
            column(Vendor_Profit_LY; VendorAmtsDict.Get(Vendor."No.").Get(8)) { }
            column(Vendor_InventoryQty_LY; VendorAmtsDict.Get(Vendor."No.").Get(9)) { }
            column(Vendor_InventoryValue_LY; VendorAmtsDict.Get(Vendor."No.").Get(10)) { }

            column(Vendor_TotalSalesLCY; TotalSalesLCY) { }
            column(Vendor_TotalSalesQty; TotalSalesQty) { }
            column(Vendor_TotalProfit; TotalProfit) { }
            column(Vendor_TotalInventoryQty; TotalInventoryQty) { }
            column(Vendor_TotalInventoryValue; TotalInventoryValue) { }

            column(Vendor_Top_TotalSalesLCY; TotalTopSalesLCY) { }
            column(Vendor_Top_TotalProfit; TotalTopProfit) { }
            column(Vendor_Top_TotalInventoryQty; TotalTopInventoryQty) { }

            column(Vendor_TotalSalesLCY_LY; TotalSalesLCYLY) { }
            column(Vendor_TotalSalesQty_LY; TotalSalesQtyLY) { }
            column(Vendor_TotalProfit_LY; TotalProfitLY) { }
            column(Vendor_TotalInventoryQty_LY; TotalInventoryQtyLY) { }
            column(Vendor_TotalInventoryValue_LY; TotalInventoryValueLY) { }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempVendorAmount.FindFirst() then
                        CurrReport.Break();
                end else
                    if TempVendorAmount.Next() = 0 then
                        CurrReport.Break();

                Vendor.Get(TempVendorAmount."Vendor No.");

                TotalTopSalesLCY += VendorAmtsDict.Get(TempVendorAmount."Vendor No.").Get(1);
                TotalTopProfit += VendorAmtsDict.Get(TempVendorAmount."Vendor No.").Get(3);
                TotalTopInventoryQty += VendorAmtsDict.Get(TempVendorAmount."Vendor No.").Get(4);
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
                    Caption = 'Options';
                    field("Show Type"; ShowType)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Show';
                        OptionCaption = 'Sales (LCY),Sales (Qty.),Profit';
                        ToolTip = 'Specifies field on which to sort the vendors.';
                    }
                    field(Quantity; NoOfRecordsToPrint)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Quantity';
                        MinValue = 1;
                        ToolTip = 'Specifies the number of vendors that will be included in the report.';
                    }
                    field("Sort Order"; SortOrder)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Sort Order';
                        OptionCaption = 'Ascending,Descending';
                        ToolTip = 'Specifies the sorting order on the report. Ascending means arranging in increasing order, while Descending means arranging in decreasing order.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if NoOfRecordsToPrint = 0 then
                NoOfRecordsToPrint := 10;
        end;
    }

    labels
    {
        ReportCaptionLbl = 'Top Vendor by Item Sales';
        PageCaptionLbl = 'Page';
        NoCaptionLbl = 'No.';
        NameCaptionLbl = 'Name';
        SalesLCYCaptionLbl = 'Sales (LCY)';
        ProfitLCYCaptionLbl = 'Profit (LCY)';
        ProfitPctShareCaptionLbl = '% of Total Profit';
        ShareTotalCaptionLbl = '% of Total Sales';
        InventoryValueCaptionLbl = 'Inventory Value';
        InventoryShareCaptionLbl = '% of Total Inventory (Qty.)';
        LastYearSalesLCYCaptionLbl = 'Last year''s Sales (LCY)';
        LastYearSalesQtyCaptionLbl = 'Last year''s Sales (Qty.)';
        LastYearProfitPctCaptionLbl = 'Last year''s Profit %';
        IndexCaptionLbl = 'Index';
        TotalCaptionLbl = 'Total';
        GrandTotalCaptionLbl = 'Grand Total';
        GrandTotalPctCaptionLbl = '% of Grand Total';
        SalesQtyCaptionLbl = 'Sales (Qty.)';
        InventoryQtyCaptionLbl = 'Inventory (Qty.)';
        RankCaptionLbl = 'Rank';
        FiltersCaptionLbl = 'Filters';
    }

    trigger OnPreReport()
    var
        FormatDocument: Codeunit "Format Document";
    begin
        StartDate := Vendor.GetRangeMin("Date Filter");
        EndDate := Vendor.GetRangeMax("Date Filter");
        StartDateLastYear := CalcDate('<-1Y>', StartDate);
        EndDateLastYear := CalcDate('<-1Y>', EndDate);

        if StartDate <> NormalDate(StartDate) then
            StartDateLastYear := ClosingDate(StartDateLastYear);
        if EndDate <> NormalDate(EndDate) then
            EndDateLastYear := ClosingDate(EndDateLastYear);

        VendorFilterText := FormatDocument.GetRecordFiltersWithCaptions(Vendor);

        if SortOrder = SortOrder::Ascending then
            SortDirectionMultiplier := 1
        else
            SortDirectionMultiplier := -1;
    end;

    var
        TempVendorAmount: Record "Vendor Amount" temporary;
        EndDate: Date;
        EndDateLastYear: Date;
        StartDate: Date;
        StartDateLastYear: Date;
        TotalInventoryQty: Decimal;
        TotalInventoryQtyLY: Decimal;
        TotalInventoryValue: Decimal;
        TotalInventoryValueLY: Decimal;
        TotalProfit: Decimal;
        TotalProfitLY: Decimal;
        TotalSalesLCY: Decimal;
        TotalSalesLCYLY: Decimal;
        TotalSalesQty: Decimal;
        TotalSalesQtyLY: Decimal;
        TotalTopInventoryQty: Decimal;
        TotalTopProfit: Decimal;
        TotalTopSalesLCY: Decimal;
        VendorAmtsDict: Dictionary of [Code[20], List of [Decimal]];
        Index: Integer;
        NoOfRecordsToPrint: Integer;
        SortDirectionMultiplier: Integer;
        RankAccordingToLbl: Label 'Rank according to %1', Comment = '%1 - specifies the selected Show Type option caption.';
        ShowTypeOptionsLbl: Label 'Sales (LCY),Sales (Qty.),Profit';
        SortOrder: Option Ascending,Descending;
        ShowType: Option "Sales (LCY)","Sales (Qty.)",Profit;
        VendorFilterText: Text;

    local procedure CalcVendorInventoryQty(var Vendor2: Record Vendor; var InventoryQty: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        Clear(InventoryQty);
        ValueEntryWithVendor.SetRange(Filter_Vendor_No, Vendor2."No.");
        if Vendor2.GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, Vendor2.GetFilter("NPR Item Category Filter"));
        if Vendor2.GetFilter("Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, Vendor2.GetFilter("Global Dimension 1 Filter"));
        if Vendor2.GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, Vendor2.GetFilter("Date Filter"));
        if Vendor2.GetFilter("NPR Salesperson Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Salespers_Purch_Code, Vendor2.GetFilter("NPR Salesperson Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            InventoryQty += ValueEntryWithVendor.Sum_Item_Ledger_Entry_Quantity;
        ValueEntryWithVendor.Close();
    end;
}