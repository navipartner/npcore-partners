report 6014443 "NPR Period Discount Stat."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Period Discount Statistics.rdlc';
    Caption = 'Period Discount Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Period Discount"; "NPR Period Discount")
        {
            column(GetFilter; GetFilters)
            {
            }
            column(CompanyName; CompanyName)
            {
            }
            column(Today; Format(Today, 0, 1))
            {
            }
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            column(Code_PeriodDiscount; Code)
            {
            }
            column(Description_PeriodDiscount; Description + '                   ' + DistributionItem)
            {
            }
            column(PeriodLength_PeriodDiscount; PeriodLbl + Format("Starting Date") + '..' + Format("Ending Date"))
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            dataitem("Period Discount Line"; "NPR Period Discount Line")
            {
                DataItemLink = Code = FIELD(Code);
                DataItemTableView = SORTING(Code, "Item No.", "Variant Code");
                RequestFilterFields = "Vendor No.";
                column(ItemNo_PeriodDiscountLine; "Item No.")
                {
                }
                column(Description_PeriodDiscountLine; Description)
                {
                }
                column(Unitprice_PeriodDiscountLine; "Unit Price")
                {
                }
                column(CampaignUnitprice_PeriodDiscountLine; "Campaign Unit Price")
                {
                }
                column(Turnover_PeriodDiscountLine; Turnover)
                {
                }
                column(Quantitysold_PeriodDiscountLine; "Quantity Sold")
                {
                }
                column(ProfitPerUnit; ProfitPerUnit)
                {
                }
                column(ProfitPerUnitPercent; ProfitPerUnitPercent)
                {
                }
                column(CampaignProfitPercent; CampaignProfitPercent)
                {
                }
                column(UnitCost_Item; Item."Unit Cost")
                {
                }
                column(NetChange_Item; Item."Net Change")
                {
                }
                column(ItemVendorName; Vendor.Name)
                {
                }
                column(PercentDisplay; PercentDisplay)
                {
                }
                dataitem("Retail Comment"; "NPR Retail Comment")
                {
                    DataItemLink = "No." = FIELD(Code), "No. 2" = FIELD("Item No.");
                    DataItemTableView = SORTING("Table ID", "No.", "No. 2", Option, "Option 2", Integer, "Integer 2", "Line No.") WHERE("Table ID" = CONST(6014414));
                    column(No_RetailComment; "No.")
                    {
                    }
                    column(No2_RetailComment; "No. 2")
                    {
                    }
                    column(Comment_RetailComment; Comment)
                    {
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(ProfitPerUnit);
                    Clear(ProfitPerUnitPercent);
                    Clear(CampaignProfitPercent);
                    Clear(Item);

                    if ("Quantity Sold" = 0) and OnlyItemWithSales then
                        CurrReport.Skip();

                    if "Distribution Item" then
                        DistributionItem := 'F'
                    else
                        DistributionItem := '';

                    if ("Campaign Unit Price" <> 0) then
                        CampaignProfitPercent := Round(("Campaign Unit Price" - "Campaign Unit Cost") / "Campaign Unit Price" * 100, 0.1)
                    else
                        CampaignProfitPercent := 0;

                    Item.SetRange("No.", "Item No.");
                    Item.SetFilter("Date Filter", '%1..%2', 0D, "Period Discount"."Ending Date");
                    if Item.FindFirst() then
                        Item.CalcFields("Net Change");

                    if (Turnover <> 0) and ("Quantity Sold" <> 0) then begin
                        ProfitPerUnit := (Turnover / "Quantity Sold") - Item."Unit Cost";
                        SumProfitPerUnit += ProfitPerUnit;
                        SumTurnover += Turnover;
                        ProfitPerUnitPercent := Round(ProfitPerUnit / Turnover * 100, 0.1);
                    end else
                        ProfitPerUnitPercent := 0;

                    if Vendor.Get(Item."Vendor No.") then;
                end;
            }
            dataitem(SumOfTotal; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(TotalProfitPerUnit; TotalProfitPerUnit)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if SumTurnover <> 0 then
                        TotalProfitPerUnit := Round(SumProfitPerUnit / SumTurnover * 100, 0.1);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(TotalProfitPerUnit);
                Clear(SumProfitPerUnit);
                Clear(SumTurnover);
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
                group(Options)
                {
                    Caption = 'Options';
                    field("Only Item With Sales"; OnlyItemWithSales)
                    {
                        Caption = 'Only Items With Sale';

                        ToolTip = 'Specifies the value of the Only Items With Sale field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        ReportTitleLbl = 'Period Discount Statistics';
        PageLbl = 'Page';
        NoLbl = 'No.';
        DescriptionLbl = 'Description';
        CostPriceLbl = 'Cost Price';
        SalesPriceLbl = 'Sales Price Incl. VAT';
        PeriodSalesPriceLbl = 'Period Sales Price Incl. VAT';
        QuantitySoldLbl = 'Quantity Sold';
        SalesLCYLbl = 'Sales (LCY)';
        TheoreticalmarginLbl = 'Theoretical Margin%';
        UsuageOldStockLbl = 'Usage Old Stock';
        StockPerEndDateLbl = 'Stock pr. enddate';
        RealizedMarginLbl = 'Realized Margin';
        AmountLbl = 'Amount';
        TotalCampaignLbl = 'Campaign Total';
        FiltersLbl = 'Filters';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        PercentDisplay := '%';
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        Vendor: Record Vendor;
        OnlyItemWithSales: Boolean;
        CampaignProfitPercent: Decimal;
        ProfitPerUnit: Decimal;
        ProfitPerUnitPercent: Decimal;
        SumProfitPerUnit: Decimal;
        SumTurnover: Decimal;
        TotalProfitPerUnit: Decimal;
        CurrReportPageNoCaptionLbl: Label 'Page';
        PeriodLbl: Label 'Period: ';
        PercentDisplay: Text[1];
        DistributionItem: Text[30];
}

