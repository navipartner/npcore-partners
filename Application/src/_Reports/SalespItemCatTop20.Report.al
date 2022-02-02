report 6014405 "NPR Salesp./Item Cat Top 20"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Salesperson Item Category Top 20.rdlc';
    Caption = 'Salesperson/Item Category Top';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            CalcFields = "NPR COGS (LCY)", "NPR Sales (LCY)";
            RequestFilterFields = "Code", "Date Filter", "NPR Global Dimension 1 Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(PageCaptionLbl; PageCaptionLbl)
            {
            }
            column(CompanyInfoPicture; CompanyInformation.Picture)
            {
            }
            column(ReportCaption; ReportCaptionLbl)
            {
            }
            column(SalesPersonFilters; "Salesperson/Purchaser".GetFilters)
            {
            }
            column(ItemCategoryFilters; "Item Category".GetFilters)
            {
            }
            column(sorteringstext; SortingText)
            {
            }
            column(NoCaption; NoCaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(TurnoverCaption; TurnoverCaptionLbl)
            {
            }
            column(ProfitCaption; ProfitCaptionLbl)
            {
            }
            column(CRPctCaption; CRPctCaptionLbl)
            {
            }
            column(DBCaption; DBCaptionLbl)
            {
            }
            column(ItemCategoryCaption; ItemCategoryCaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(SalesLCYCaption; SalesLCYCaptionLbl)
            {
            }
            column(PctCaption; PctCaptionLbl)
            {
            }
            column(CBCaption; CBCaptionLbl)
            {
            }
            column(Code_SalespersonPurchaser; "Salesperson/Purchaser".Code)
            {
            }
            column(Name_SalespersonPurchaser; "Salesperson/Purchaser".Name)
            {
            }
            column(SalesLCY_SalespersonPurchaser; SalesLCY)
            {
            }
            column(ProfitLCY_SalespersonPurchaser; SalesLCY - CogsLCY)
            {
            }
            column(ProfitPctSalesperson; ProfitPctSalesperson)
            {
            }
            column(db; db)
            {
            }
            column(ShowMainTotal; ShowMainTotal)
            {
            }
            column(sortSalesPerson; sortSalesPerson)
            {
            }
            column(ShowQty; ShowQty)
            {
            }
            dataitem("Item Category"; "Item Category")
            {
                CalcFields = "NPR Sales (LCY)", "NPR Consumption (Amount)";
                DataItemLink = "NPR Salesperson/Purch. Filter" = FIELD(Code), "NPR Date Filter" = FIELD("Date Filter");
                DataItemTableView = SORTING("Code");
                column(No_ItemCategory; "Item Category"."Code")
                {
                }
                column(Description_ItemCategory; "Item Category".Description)
                {
                }
                column(SaleLCY_ItemCategory; SalesLCYGP)
                {
                }
                column(SalesPct; SalesPct)
                {
                }
                column(CB_ItemCategory; SalesLCYGP - CogsLCYGP)
                {
                }
                column(dg_ItemCategory; dg)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(dg);
                    Clear(SalesPct);

                    SalesLCYGP := 0;
                    CogsLCYGP := 0;

                    AuxValueEntry.Reset();
                    AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                    AuxValueEntry.SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                    AuxValueEntry.SetRange("Item Category Code", "Item Category".Code);
                    AuxValueEntry.SetFilter("Posting Date", SPDateFilter);
                    AuxValueEntry.SetFilter("Global Dimension 1 Code", SPGlobalDim1Filter);
                    AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");

                    SalesLCYGP := AuxValueEntry."Sales Amount (Actual)";
                    CogsLCYGP := -AuxValueEntry."Cost Amount (Actual)";

                    if SalesLCYGP = 0 then
                        CurrReport.Skip();

                    if SalesLCYGP <> 0 then
                        dg := ((SalesLCYGP - CogsLCYGP) / SalesLCYGP) * 100;

                    if SalesLCY <> 0 then
                        SalesPct := (SalesLCYGP / SalesLCY * 100);
                    if sortSalesPerson then begin
                        TempItemAmount.Init();
                        TempItemAmount.Amount := -SalesLCYGP;
                        TempItemAmount."Amount 2" := CogsLCYGP;
                        TempItemAmount."Item No." := "Code";
                        TempItemAmount.Insert();

                        if (i = 0) or (i < ShowQty) then
                            i := i + 1
                        else begin
                            TempItemAmount.Find('+');
                            TempItemAmount.Delete();
                        end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    "Item Category".SetFilter("Code", SPItemCategoryFilter);
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Number_Integer; Integer.Number)
                {
                }
                column(No1_ItemCategory; "Item Category"."Code")
                {
                }
                column(Description1_ItemCategory; "Item Category".Description)
                {
                }
                column(SaleLCY1_ItemCategory; SalesLCYGPINT)
                {
                }
                column(SalesPct1; SalesPct)
                {
                }
                column(CB1_ItemCategory; SalesLCYGPINT - CogsLCYGPINT)
                {
                }
                column(dg1_ItemCategory; dg)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (not sortSalesPerson) then
                        CurrReport.Break();

                    if Number = 1 then begin
                        if not TempItemAmount.Find('-') then
                            CurrReport.Break();
                    end else
                        if TempItemAmount.Next() = 0 then
                            CurrReport.Break();

                    "Item Category".Get(TempItemAmount."Item No.");
                    SalesLCYGPINT := 0;
                    CogsLCYGPINT := 0;

                    AuxValueEntry.Reset();
                    AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                    AuxValueEntry.SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                    AuxValueEntry.SetRange("Item Category Code", TempItemAmount."Item No.");
                    AuxValueEntry.SetFilter("Posting Date", SPDateFilter);
                    AuxValueEntry.SetFilter("Global Dimension 1 Code", SPGlobalDim1Filter);
                    AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");

                    SalesLCYGP := AuxValueEntry."Sales Amount (Actual)";
                    CogsLCYGP := -AuxValueEntry."Cost Amount (Actual)";

                    Clear(dg);
                    Clear(SalesPct);
                    if SalesLCYGPINT <> 0 then
                        dg := ((SalesLCYGPINT - CogsLCYGPINT) / SalesLCYGPINT) * 100;

                    if SalesLCY <> 0 then
                        SalesPct := SalesLCYGPINT / SalesLCY * 100;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                SalesLCY := 0;
                CogsLCY := 0;

                AuxValueEntry.Reset();
                AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                AuxValueEntry.SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                CopyFilter("Date Filter", AuxValueEntry."Posting Date");
                CopyFilter("NPR Item Category Filter", AuxValueEntry."Item Category Code");
                CopyFilter("NPR Global Dimension 1 Filter", AuxValueEntry."Global Dimension 1 Code");
                AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Expected)");

                SalesLCY := AuxValueEntry."Sales Amount (Actual)";
                CogsLCY := -AuxValueEntry."Cost Amount (Actual)";

                TempItemAmount.DeleteAll();

                Clear(i);
                Clear(ProfitPctSalesperson);
                Clear(db);

                if SalesLCY <> 0 then begin
                    ProfitPctSalesperson := ((SalesLCY - CogsLCY) / SalesLCY) * 100;
                    db := SalesLCY - CogsLCY;
                end;

                if SalesLCY = 0 then
                    CurrReport.Skip();

                if sortSalesPerson then
                    SortingText := Trans0001
                else
                    SortingText := '';
            end;

            trigger OnPreDataItem()
            begin
                if sortSalesPerson then
                    SortingText := Trans0001
                else
                    SortingText := '';
                SPDateFilter := "Salesperson/Purchaser".GetFilter("Date Filter");
                SPGlobalDim1Filter := "Salesperson/Purchaser".GetFilter("Global Dimension 1 Code");
                SPItemCategoryFilter := "Salesperson/Purchaser".GetFilter("NPR Item Category Filter");
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
                    field("Show Main Total"; ShowMainTotal)
                    {
                        Caption = 'Show Only Mainfigures';
                        Visible = ShowMainTotalVisible;

                        ToolTip = 'Specifies the value of the Show Only Mainfigures field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            sortSalesPerson := false;
                            sortSalesPersonVisible := false;
                            ShowQtyVisible := false;
                            RequestOptionsPage.Update();
                        end;
                    }
                    field("sort Sales Person"; sortSalesPerson)
                    {
                        Caption = 'Sort Salespersons';
                        Visible = SortSalesPersonVisible;

                        ToolTip = 'Specifies the value of the Sort Salespersons field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if sortSalesPerson then begin
                                ShowMainTotal := false;
                                ShowMainTotalVisible := false;
                                ShowQtyVisible := true;
                            end
                            else begin
                                ShowQtyVisible := false;
                                ShowMainTotalVisible := true;
                            end;
                        end;
                    }
                    field("Show Qty"; ShowQty)
                    {
                        Caption = 'Show Quantity for Item Category';
                        Visible = ShowQtyVisible;

                        ToolTip = 'Specifies the value of the Show Quantity for Item Category field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }


    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        ShowMainTotal := false;
        ShowMainTotalVisible := true;
        sortSalesPerson := true;
        sortSalesPersonVisible := true;
        ShowQtyVisible := true;
        ShowQty := 25;
    end;

    var
        CompanyInformation: Record "Company Information";
        TempItemAmount: Record "Item Amount" temporary;
        AuxValueEntry: Record "NPR Aux. Value Entry";
        ShowMainTotal: Boolean;
        [InDataSet]
        ShowMainTotalVisible: Boolean;
        [InDataSet]
        ShowQtyVisible: Boolean;
        sortSalesPerson: Boolean;
        [InDataSet]
        sortSalesPersonVisible: Boolean;
        CogsLCY: Decimal;
        CogsLCYGP: Decimal;
        CogsLCYGPINT: Decimal;
        db: Decimal;
        dg: Decimal;
        ProfitPctSalesperson: Decimal;
        SalesLCY: Decimal;
        SalesLCYGP: Decimal;
        SalesLCYGPINT: Decimal;
        SalesPct: Decimal;
        i: Integer;
        ShowQty: Integer;
        PctCaptionLbl: Label '%';
        CBCaptionLbl: Label 'CB';
        CRPctCaptionLbl: Label 'CR%';
        DBCaptionLbl: Label 'DB';
        DescriptionCaptionLbl: Label 'Description';
        ItemCategoryCaptionLbl: Label 'Item Category';
        NameCaptionLbl: Label 'Name';
        NoCaptionLbl: Label 'No.';
        PageCaptionLbl: Label 'Page';
        ProfitCaptionLbl: Label 'Profit';
        SalesLCYCaptionLbl: Label 'Sales(LCY)';
        ReportCaptionLbl: Label 'Salesperson/Item Category Top';
        Trans0001: Label 'Sorted by turnover';
        TurnoverCaptionLbl: Label 'Turnover';
        SPDateFilter: Text;
        SPGlobalDim1Filter: Text;
        SPItemCategoryFilter: Text;
        SortingText: Text[30];
}

