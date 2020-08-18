report 6014443 "Period Discount Statistics"
{
    // NPR5.27/JLK /20161020  Report upgraded from NAV 2009
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.38/NPKNAV/20180126  CASE 299276 Transport NPR5.38 - 26 January 2018
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.54/YAHA/20200324  CASE 394872 Removed Company Picture
    // NPR5.55/YAHA/20200610  CASE 394884 Header layout modification
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Period Discount Statistics.rdlc';

    Caption = 'Period Discount Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Period Discount";"Period Discount")
        {
            column(GetFilter;GetFilters)
            {
            }
            column(CompanyName;CompanyName)
            {
            }
            column(Today;Format(Today,0,1))
            {
            }
            column(Picture_CompanyInformation;CompanyInformation.Picture)
            {
            }
            column(Code_PeriodDiscount;Code)
            {
            }
            column(Description_PeriodDiscount;Description +  '                   ' + DistributionItem)
            {
            }
            column(PeriodLength_PeriodDiscount;PeriodLbl + Format("Starting Date") + '..' + Format("Ending Date"))
            {
            }
            column(CurrReportPageNoCaption;CurrReportPageNoCaptionLbl)
            {
            }
            dataitem("Period Discount Line";"Period Discount Line")
            {
                DataItemLink = Code=FIELD(Code);
                DataItemTableView = SORTING(Code,"Item No.","Variant Code");
                RequestFilterFields = "Vendor No.";
                column(ItemNo_PeriodDiscountLine;"Item No.")
                {
                }
                column(Description_PeriodDiscountLine;Description)
                {
                }
                column(Unitprice_PeriodDiscountLine;"Unit Price")
                {
                }
                column(CampaignUnitprice_PeriodDiscountLine;"Campaign Unit Price")
                {
                }
                column(Turnover_PeriodDiscountLine;Turnover)
                {
                }
                column(Quantitysold_PeriodDiscountLine;"Quantity Sold")
                {
                }
                column(ProfitPerUnit;ProfitPerUnit)
                {
                }
                column(ProfitPerUnitPercent;ProfitPerUnitPercent)
                {
                }
                column(CampaignProfitPercent;CampaignProfitPercent)
                {
                }
                column(UnitCost_Item;Item."Unit Cost")
                {
                }
                column(NetChange_Item;Item."Net Change")
                {
                }
                column(ItemVendorName;Vendor.Name)
                {
                }
                column(PercentDisplay;PercentDisplay)
                {
                }
                dataitem("Retail Comment";"Retail Comment")
                {
                    DataItemLink = "No."=FIELD(Code),"No. 2"=FIELD("Item No.");
                    DataItemTableView = SORTING("Table ID","No.","No. 2",Option,"Option 2",Integer,"Integer 2","Line No.") WHERE("Table ID"=CONST(6014414));
                    column(No_RetailComment;"No.")
                    {
                    }
                    column(No2_RetailComment;"No. 2")
                    {
                    }
                    column(Comment_RetailComment;Comment)
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
                      CurrReport.Skip;

                    if "Distribution Item" then
                      DistributionItem := 'F'
                    else
                      DistributionItem := '';

                    if ("Campaign Unit Price" <> 0) then
                      CampaignProfitPercent := Round(("Campaign Unit Price"-"Campaign Unit Cost")/"Campaign Unit Price" * 100,0.1)
                    else
                      CampaignProfitPercent := 0;

                    Item.SetRange("No.", "Item No.");
                    Item.SetFilter("Date Filter", '%1..%2',0D,"Period Discount"."Ending Date");
                    if Item.FindFirst then
                      Item.CalcFields("Net Change");

                    if (Turnover <> 0) and ("Quantity Sold" <> 0) then begin
                     ProfitPerUnit := (Turnover/"Quantity Sold") - Item."Unit Cost";
                     SumProfitPerUnit += ProfitPerUnit;
                     SumTurnover += Turnover;
                     ProfitPerUnitPercent := Round(ProfitPerUnit/Turnover*100,0.1);
                    end else
                      ProfitPerUnitPercent :=0;

                    //-NPR5.38 [288276]
                    if Vendor.Get(Item."Vendor No.") then;
                    //+NPR5.38 [288276]
                end;
            }
            dataitem(SumOfTotal;"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                column(TotalProfitPerUnit;TotalProfitPerUnit)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if SumTurnover <> 0 then
                      TotalProfitPerUnit := Round(SumProfitPerUnit/SumTurnover*100,0.1);
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

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(OnlyItemWithSales;OnlyItemWithSales)
                    {
                        Caption = 'Only Items With Sale';
                    }
                }
            }
        }

        actions
        {
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
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);

        PercentDisplay := '%';
    end;

    var
        CompanyInformation: Record "Company Information";
        PercentDisplay: Text[1];
        PeriodLbl: Label 'Period: ';
        OnlyItemWithSales: Boolean;
        DistributionItem: Text[30];
        CampaignProfitPercent: Decimal;
        ProfitPerUnit: Decimal;
        SumProfitPerUnit: Decimal;
        ProfitPerUnitPercent: Decimal;
        Item: Record Item;
        SumTurnover: Decimal;
        TotalProfitPerUnit: Decimal;
        Vendor: Record Vendor;
        CurrReportPageNoCaptionLbl: Label 'Page';
}

