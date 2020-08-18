report 6014419 "Vendor Sales Stat"
{
    // NPR5.29/TR  /20161118  CASE 247166 Report Created
    // NPR5.33/JLK /20170619  CASE 280879 Changed SalesQty and PurchaseQty to Decimal
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.53/ANPA/20191227  CASE 370940 Changed caption on request page
    // NPR5.55/ANPA/20200608  CASE 402935 Changed layout to match layout of report 6014417
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Vendor Sales Stat.rdlc';

    Caption = 'Vendor Sales Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor;Vendor)
        {
            CalcFields = Stock,"Purchases (LCY)","Sales (LCY)";
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(Name_CompanyInfo;CompanyInfo.Name)
            {
            }
            column(No_Vendor;"No.")
            {
            }
            column(Name_Vendor;Name)
            {
            }
            column(PurchaseQty_Vendor;PurchaseQty)
            {
            }
            column(PurchasesLCY_Vendor;PurchaseLCY)
            {
            }
            column(Stock_VendorAllYear;VendorAllYear.Stock)
            {
            }
            column(PurchasesLCY_VendorAllYear;VendorAllYear."Purchases (LCY)")
            {
            }
            column(SalesLCY_VendorAllYear;VendorAllYear."Sales (LCY)")
            {
            }
            column(CoverageAllYear;CoverageAllYear)
            {
            }
            column(CoverRateAllYear;CoverRateAllYear)
            {
            }
            column(VendorCap;VendorCap)
            {
            }
            column(QtyCap;QtyCap)
            {
            }
            column(CostPriceCap;CostPriceCap)
            {
            }
            column(SalesPriceInclVatCap;SalesPriceInclVatCap)
            {
            }
            column(SalesPriceExVatCap;SalesPriceExVatCap)
            {
            }
            column(CoverageCap;CoverageCap)
            {
            }
            column(CoverRateCap;CoverRateCap)
            {
            }
            column(SalesPctCap;SalesPctCap)
            {
            }
            column(SalesPriceCap;SalesPriceCap)
            {
            }
            column(IPctCap;IPctCap)
            {
            }
            column(ZeroIPctCap;ZeroIPctCap)
            {
            }
            column(Text000;Text000)
            {
            }
            column(Text001;Text001)
            {
            }
            column(Text002;Text002)
            {
            }
            column(Text003;Text003)
            {
            }
            column(Text004;Text004)
            {
            }
            column(Text005;Text005)
            {
            }
            column(Text006;Text006)
            {
            }
            column(DateFilter;StrSubstNo(Text002,StartDate,EndDate))
            {
            }
            dataitem(ItemLedgerEntryPurchase;"Item Ledger Entry")
            {
                CalcFields = "Cost Amount (Actual)";
                DataItemLink = "Vendor No."=FIELD("No."),"Global Dimension 1 Code"=FIELD("Global Dimension 1 Code"),"Global Dimension 2 Code"=FIELD("Global Dimension 2 Code"),"Posting Date"=FIELD("Date Filter");
                DataItemTableView = SORTING("Entry No.") WHERE("Entry Type"=CONST(Purchase));

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
            dataitem(ItemLedgerEntrySale;"Item Ledger Entry")
            {
                CalcFields = "Sales Amount (Actual)";
                DataItemLink = "Vendor No."=FIELD("No."),"Global Dimension 1 Code"=FIELD("Global Dimension 1 Code"),"Global Dimension 2 Code"=FIELD("Global Dimension 2 Code"),"Posting Date"=FIELD("Date Filter");
                DataItemTableView = SORTING("Entry No.") WHERE("Entry Type"=CONST(Sale));

                trigger OnAfterGetRecord()
                begin
                    SalesQty += Quantity;
                    SalesLCY += "Sales Amount (Actual)";
                end;

                trigger OnPostDataItem()
                begin
                    Coverage := CalcCoverage(PurchaseLCY,SalesLCY);
                    CoverageRate := CalcCoverageRate(Coverage,SalesLCY);
                    if (PurchaseLCY <> 0) and (SalesLCY <> 0) then
                      SalesPct := (PurchaseLCY/SalesLCY)*100;
                end;

                trigger OnPreDataItem()
                begin
                    SalesQty := 0;
                    SalesLCY := 0;
                    Coverage := 0;
                    CoverageRate := 0;
                end;
            }
            dataitem("Integer";"Integer")
            {
                MaxIteration = 1;
                column(SalesQty_Vendor;-1*SalesQty)
                {
                }
                column(SalesInclVat;SalesLCY)
                {
                }
                column(SalesExVat;SalesExVat)
                {
                }
                column(Coverage;Coverage)
                {
                }
                column(CoverRate;CoverageRate)
                {
                }
                column(SalesPct;SalesPct)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                Clear(VendorAllYear);
                VendorAllYear.SetRange("No.","No.");
                VendorAllYear.SetFilter("Date Filter",'%1..%2',DMY2Date(1,1,Year),Today);
                if VendorAllYear.FindSet then begin
                  VendorAllYear.CalcFields(Stock,"Purchases (LCY)","Sales (LCY)");
                  CoverageAllYear := CalcCoverage(VendorAllYear."Purchases (LCY)",VendorAllYear."Sales (LCY)");
                  CoverRateAllYear := CalcCoverageRate(CoverageAllYear,VendorAllYear."Sales (LCY)");
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetFilter("Date Filter",'%1..%2',StartDate,EndDate);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Start Date";StartDate)
                {
                    Caption = 'Start Date';
                }
                field("End Date";EndDate)
                {
                    Caption = 'End Date';
                }
            }
        }

        actions
        {
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
        Month := Date2DMY(Today,2);
        Year := Date2DWY(Today, 3);
        StartDate := DMY2Date(1,Month,Year);
        CompanyInfo.Get;
    end;

    trigger OnPreReport()
    begin
        if EndDate = 0D then begin
          EndDate := CalcDate('<-1D>',CalcDate('<1M>',StartDate));
        end;
    end;

    var
        CompanyInfo: Record "Company Information";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorAllYear: Record Vendor;
        Month: Integer;
        Year: Integer;
        StartDate: Date;
        EndDate: Date;
        "---": Integer;
        PurchaseQty: Decimal;
        PurchaseLCY: Decimal;
        SalesQty: Decimal;
        SalesLCY: Decimal;
        SalesExVat: Decimal;
        SalesPct: Decimal;
        Coverage: Decimal;
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
        CoverRateAllYear: Decimal;

    local procedure CalcCoverage(PurchasePrice: Decimal;SalesPrice: Decimal): Decimal
    begin
        exit(SalesPrice-PurchasePrice);
    end;

    local procedure CalcCoverageRate(Coverage: Decimal;SalesPrice: Decimal): Decimal
    begin
        if SalesPrice <> 0 then
          exit((Coverage/SalesPrice)*100);
        exit(0);
    end;
}

