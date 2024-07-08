report 6014431 "NPR S.Person Trn by Item Cat."
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Person Trn. by Item Cat.rdlc';
    Caption = 'Salesperson Turnover per Item Category';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(SalespersonPurchaser; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting("Code");
            RequestFilterFields = "Code";
            PrintOnlyIfDetail = true;

            column(Salesperson_Code; "Code") { }
            column(Salesperson_Name; "Name") { }
            column(Request_Page_Filters; RequestPageFilters) { }
            column(Company_Name; CompanyName()) { }
            column(NumberOfLevels; NumberOfLevels) { }

            dataitem("Item Category"; "Item Category")
            {
                DataItemTableView = sorting("Code");
                RequestFilterFields = "NPR Date Filter";
                column(ItemCategory_Code; "Code") { }
                column(ItemCategory_Description; Description) { }
                column(ItemCategory_ParentCategory; "Parent Category") { }
                column(ItemCategory_Has_Children; "Has Children") { }
                column(ItemCategory_Presentation_Order; "Presentation Order") { }
                column(ItemCategory_Indentation; Indentation) { }

                column(ItemCategory_SalesQty; ItemCategorySalesQty) { }
                column(ItemCategory_COGSLCY; ItemCategoryCOGSLCY) { }
                column(ItemCategory_SalesLCY; ItemCategorySalesLCY) { }

                trigger OnAfterGetRecord()
                begin
                    GetAmounts("Item Category".Code, SalespersonPurchaser.Code, ItemCategorySalesQty, ItemCategoryCOGSLCY, ItemCategorySalesLCY);
                end;
            }

            dataitem(ItemCategory2; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));

                column(ItemCategory2_Code; UncategorizedCategoryCodeLbl) { }
                column(ItemCategory2_Description; UncategorizedCategoryDescLbl) { }

                column(ItemCategory2_SalesQty; ItemCategory2SalesQty) { }
                column(ItemCategory2_COGSLCY; ItemCategory2COGSLCY) { }
                column(ItemCategory2_SalesLCY; ItemCategory2SalesLCY) { }

                trigger OnAfterGetRecord()
                begin
                    GetAmounts('', SalespersonPurchaser.Code, ItemCategory2SalesQty, ItemCategory2COGSLCY, ItemCategory2SalesLCY);
                end;
            }
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
                    field("Number of Levels"; NumberOfLevels)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Number of Levels';
                        MinValue = 1;
                        ToolTip = 'Specifies how many levels of item categories are displayed on the report. Adjust this field to control the level of detail in the report.';
                    }
                }
            }
        }
    }

    labels
    {
        ReportCaptionLbl = 'Salesperson Turnover per Item Category';
        SalesPersonCaptionLbl = 'Salesperson';
        MarginCaptionLbl = 'Margin';
        PartPctCaptionLbl = 'Part %';
        PageCaptionLbl = 'Page';
        NoCaptionLbl = 'No.';
        DescCaptionLbl = 'Description';
        SaleQtyCaptionLbl = 'Sales (Qty.)';
        TurnoverExclVatCaptionLbl = 'Turnover Excl. VAT';
        ProfitPctCaptionLbl = 'Profit %';
        FiltersCaptionLbl = 'Filters:';
    }

    trigger OnInitReport()
    begin
        NumberOfLevels := 2;
    end;

    trigger OnPreReport()
    begin
        RequestPageFilters := CreateRequestPageFiltersTxt();
    end;

    var
        NumberOfLevels: Integer;
        RequestPageFilters: Text;
        UncategorizedCategoryCodeLbl: Label '-';
        UncategorizedCategoryDescLbl: Label 'Without category';
        ItemCategorySalesQty, ItemCategoryCOGSLCY, ItemCategory2SalesLCY, ItemCategory2SalesQty, ItemCategory2COGSLCY, ItemCategorySalesLCY : Decimal;

    local procedure CreateRequestPageFiltersTxt(): Text
    var
        RequestPageFiltersTxt: Text;
    begin
        if (RequestPageFiltersTxt <> '') and ("Item Category".GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + "Item Category".GetFilters()
        else
            RequestPageFiltersTxt += "Item Category".GetFilters();

        if (RequestPageFiltersTxt <> '') and (SalespersonPurchaser.GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + SalespersonPurchaser.GetFilters()
        else
            RequestPageFiltersTxt += SalespersonPurchaser.GetFilters();

        exit(RequestPageFiltersTxt);
    end;

    local procedure GetAmounts(ItemCategoryCode: Code[20]; SalespersonCode: Code[20]; var SalesQty: Decimal; var COGSLCY: Decimal; var SalesLCY: Decimal)
    var
        SPersonTurnItemCat: Query "NPR SPerson Turn. Item Cat.";
    begin
        SPersonTurnItemCat.SetRange(Item_Category_Code, ItemCategoryCode);
        SPersonTurnItemCat.SetRange(Salespers_Purch_Code, SalespersonCode);

        if "Item Category".GetFilter("NPR Date Filter") <> '' then
            SPersonTurnItemCat.SetFilter(Filter_DateTime, "Item Category".GetFilter("NPR Date Filter"));

        Clear(SalesQty);
        Clear(SalesLCY);
        Clear(COGSLCY);

        SPersonTurnItemCat.Open();
        while SPersonTurnItemCat.Read() do begin
            SalesQty += -SPersonTurnItemCat.Sum_Invoiced_Quantity;
            SalesLCY += SPersonTurnItemCat.Sum_Sales_Amount_Actual;
            COGSLCY += -SPersonTurnItemCat.Sum_Cost_Amount_Actual;
        end;
        SPersonTurnItemCat.Close();
    end;
}