﻿report 6014419 "NPR Vendor Sales Stat"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Vendor Sales Stat.rdlc';
    Caption = 'Vendor Sales Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(Name_CompanyInfo; CompanyInfo.Name)
            {
            }
            column(No_Vendor; "No.")
            {
            }
            column(Name_Vendor; Name)
            {
            }
            column(PurchaseQty_Vendor; PurchaseQty)
            {
            }
            column(PurchasesLCY_Vendor; PurchaseLCY)
            {
            }
            column(Stock_VendorAllYear; VendorAllYearStock)
            {
            }
            column(PurchasesLCY_VendorAllYear; VendorAllYear."Purchases (LCY)")
            {
            }
            column(SalesLCY_VendorAllYear; VendorAllYearSalesLCY)
            {
            }
            column(CoverageAllYear; CoverageAllYear)
            {
            }
            column(CoverRateAllYear; CoverRateAllYear)
            {
            }
            column(VendorCap; VendorCap)
            {
            }
            column(QtyCap; QtyCap)
            {
            }
            column(CostPriceCap; CostPriceCap)
            {
            }
            column(SalesPriceInclVatCap; SalesPriceInclVatCap)
            {
            }
            column(SalesPriceExVatCap; SalesPriceExVatCap)
            {
            }
            column(CoverageCap; CoverageCap)
            {
            }
            column(CoverRateCap; CoverRateCap)
            {
            }
            column(SalesPctCap; SalesPctCap)
            {
            }
            column(SalesPriceCap; SalesPriceCap)
            {
            }
            column(IPctCap; IPctCap)
            {
            }
            column(ZeroIPctCap; ZeroIPctCap)
            {
            }
            column(Text000; Text000)
            {
            }
            column(Text001; Text001)
            {
            }
            column(Text002; Text002)
            {
            }
            column(Text003; Text003)
            {
            }
            column(Text004; Text004)
            {
            }
            column(Text005; Text005)
            {
            }
            column(Text006; Text006)
            {
            }
            column(DateFilter; StrSubstNo(Text002, StartDate, EndDate))
            {
            }
            dataitem(AuxItemLedgerEntryPurchase; "Item Ledger Entry")
            {
                CalcFields = "Cost Amount (Actual)";
                DataItemLink = "Source No." = FIELD("No."), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Code"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Code"), "Posting Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Entry No.") WHERE("Entry Type" = CONST(Purchase));

                trigger OnAfterGetRecord()
                begin
                    PurchaseQty += Quantity;
                    PurchaseLCY += "Cost Amount (Actual)";
                end;

                trigger OnPreDataItem()
                begin
                    PurchaseQty := 0;
                    PurchaseLCY := 0;
                end;
            }
            dataitem(AuxItemLedgerEntrySale; "Item Ledger Entry")
            {
                CalcFields = "Sales Amount (Actual)";
                DataItemLink = "Source No." = FIELD("No."), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Code"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Code"), "Posting Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Entry No.") WHERE("Entry Type" = CONST(Sale));

                trigger OnAfterGetRecord()
                begin
                    SalesQty += Quantity;
                    SalesLCY += "Sales Amount (Actual)";
                end;

                trigger OnPostDataItem()
                begin
                    _Coverage := CalcCoverage(PurchaseLCY, SalesLCY);
                    CoverageRate := CalcCoverageRate(_Coverage, SalesLCY);
                    if (PurchaseLCY <> 0) and (SalesLCY <> 0) then
                        SalesPct := (PurchaseLCY / SalesLCY) * 100;
                end;

                trigger OnPreDataItem()
                begin
                    SalesQty := 0;
                    SalesLCY := 0;
                    _Coverage := 0;
                    CoverageRate := 0;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                MaxIteration = 1;
                column(SalesQty_Vendor; -1 * SalesQty)
                {
                }
                column(SalesInclVat; SalesLCY)
                {
                }
                column(SalesExVat; SalesExVat)
                {
                }
                column(Coverage; _Coverage)
                {
                }
                column(CoverRate; CoverageRate)
                {
                }
                column(SalesPct; SalesPct)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                Clear(VendorAllYear);
                VendorAllYear.SetRange("No.", "No.");
                VendorAllYear.SetFilter("Date Filter", '%1..%2', DMY2Date(1, 1, Year), Today);
                if VendorAllYear.FindSet() then begin
                    VendorAllYear.CalcFields("Purchases (LCY)");
                    VendorAllYear.NPRGetVESalesLCYSalesQtyCOGSLCY(VendorAllYearSalesLCY, VendorAllYearSalesQty, VendorAllYearCOGSLCY);
                    VendorAllYear.NPRGetVEStock(VendorAllYearStock);
                    CoverageAllYear := CalcCoverage(VendorAllYear."Purchases (LCY)", VendorAllYearSalesLCY);
                    CoverRateAllYear := CalcCoverageRate(CoverageAllYear, VendorAllYearSalesLCY);
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                field("Start Date"; StartDate)
                {
                    Caption = 'Start Date';

                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date"; EndDate)
                {
                    Caption = 'End Date';

                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Vendor Sales Stat.';
        Footer_Caption = 'ˆNAVIPARTNER K¢benhavn 2002';
        Total_Caption = 'Total';
    }

    trigger OnInitReport()
    begin
        Month := Date2DMY(Today, 2);
        Year := Date2DWY(Today, 3);
        StartDate := DMY2Date(1, Month, Year);
        CompanyInfo.Get();
    end;

    trigger OnPreReport()
    begin
        if EndDate = 0D then begin
            EndDate := CalcDate('<-1D>', CalcDate('<1M>', StartDate));
        end;
    end;

    var
        CompanyInfo: Record "Company Information";
        VendorAllYear: Record Vendor;
        Month: Integer;
        Year: Integer;
        StartDate: Date;
        EndDate: Date;
        PurchaseQty: Decimal;
        PurchaseLCY: Decimal;
        SalesQty: Decimal;
        SalesLCY: Decimal;
        SalesExVat: Decimal;
        SalesPct: Decimal;
        _Coverage: Decimal;
        CoverageRate: Decimal;
        Text000: Label 'Year up until date';
        Text001: Label 'Inventory';
        Text002: Label 'Date %1..%2';
        Text003: Label 'Item sales';
        Text004: Label 'Item purchases';
        Text005: Label 'Stock';
        Text006: Label 'Total';
        VendorCap: Label 'Vendor';
        QtyCap: Label 'Qty';
        CostPriceCap: Label 'Cost Price';
        SalesPriceInclVatCap: Label 'Sales Price Incl. VAT';
        SalesPriceExVatCap: Label 'Sales Price Ex. VAT';
        CoverageCap: Label 'CM';
        CoverRateCap: Label 'CR %';
        SalesPriceCap: Label 'Sales Price';
        SalesPctCap: Label 'Sales in % of purch.';
        IPctCap: Label 'in %';
        ZeroIPctCap: Label 'Zero point in %';
        CoverageAllYear: Decimal;
        VendorAllYearSalesLCY: Decimal;
        VendorAllYearSalesQty: Decimal;
        VendorAllYearCOGSLCY: Decimal;
        VendorAllYearStock: Decimal;
        CoverRateAllYear: Decimal;

    local procedure CalcCoverage(PurchasePrice: Decimal; SalesPrice: Decimal): Decimal
    begin
        exit(SalesPrice - PurchasePrice);
    end;

    local procedure CalcCoverageRate(Coverage: Decimal; SalesPrice: Decimal): Decimal
    begin
        if SalesPrice <> 0 then
            exit((Coverage / SalesPrice) * 100);
        exit(0);
    end;
}

