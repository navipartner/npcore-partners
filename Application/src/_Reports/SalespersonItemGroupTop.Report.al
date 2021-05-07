report 6014405 "NPR Salesperson/Item Group Top"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/SalespersonItem Group Top.rdlc';
    Caption = 'Salesperson/Item Group Top';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
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
            column(ItemGroupFilters; "Item Category".GetFilters)
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
            column(ItemGroupCaption; ItemGroupCaptionLbl)
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
                column(No_ItemGroup; "Item Category"."Code")
                {
                }
                column(Description_ItemGroup; "Item Category".Description)
                {
                }
                column(SaleLCY_ItemGroup; SalesLCYGP)
                {
                }
                column(SalesPct; SalesPct)
                {
                }
                column(CB_ItemGroup; SalesLCYGP - CogsLCYGP)
                {
                }
                column(dg_ItemGroup; dg)
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
                        ItemAmount.Init();
                        ItemAmount.Amount := -SalesLCYGP;
                        ItemAmount."Amount 2" := CogsLCYGP;
                        ItemAmount."Item No." := "Code";
                        ItemAmount.Insert();

                        if (i = 0) or (i < ShowQty) then
                            i := i + 1
                        else begin
                            ItemAmount.Find('+');
                            ItemAmount.Delete();
                        end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    "Item Category".SetFilter("Code", SPItemGroupFilter);
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Number_Integer; Integer.Number)
                {
                }
                column(No1_ItemGroup; "Item Category"."Code")
                {
                }
                column(Description1_ItemGroup; "Item Category".Description)
                {
                }
                column(SaleLCY1_ItemGroup; SalesLCYGPINT)
                {
                }
                column(SalesPct1; SalesPct)
                {
                }
                column(CB1_ItemGroup; SalesLCYGPINT - CogsLCYGPINT)
                {
                }
                column(dg1_ItemGroup; dg)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (not sortSalesPerson) then
                        CurrReport.Break();

                    if Number = 1 then begin
                        if not ItemAmount.Find('-') then
                            CurrReport.Break();
                    end else
                        if ItemAmount.Next() = 0 then
                            CurrReport.Break();

                    "Item Category".Get(ItemAmount."Item No.");
                    SalesLCYGPINT := 0;
                    CogsLCYGPINT := 0;

                    AuxValueEntry.Reset();
                    AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                    AuxValueEntry.SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                    AuxValueEntry.SetRange("Item Category Code", ItemAmount."Item No.");
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

                ItemAmount.DeleteAll();

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
                SPItemGroupFilter := "Salesperson/Purchaser".GetFilter("NPR Item Category Filter");
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
                    field(ShowMainTotal; ShowMainTotal)
                    {
                        Caption = 'Show Only Mainfigures';
                        Visible = ShowMainTotalVisible;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Only Mainfigures field';

                        trigger OnValidate()
                        begin
                            sortSalesPerson := false;
                            sortSalesPersonVisible := false;
                            ShowQtyVisible := false;
                            RequestOptionsPage.Update();
                        end;
                    }
                    field(sortSalesPerson; sortSalesPerson)
                    {
                        Caption = 'Sort Salespersons';
                        Visible = SortSalesPersonVisible;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sort Salespersons field';

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
                    field(ShowQty; ShowQty)
                    {
                        Caption = 'Show Amounts';
                        Visible = ShowQtyVisible;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Amounts field';
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
        ItemAmount: Record "Item Amount" temporary;
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
        ItemGroupCaptionLbl: Label 'Itemgroup';
        NameCaptionLbl: Label 'Name';
        NoCaptionLbl: Label 'No.';
        PageCaptionLbl: Label 'Page';
        ProfitCaptionLbl: Label 'Profit';
        SalesLCYCaptionLbl: Label 'Sales(LCY)';
        ReportCaptionLbl: Label 'Salesperson/Item Group Top';
        Trans0001: Label 'Sorted by turnover';
        TurnoverCaptionLbl: Label 'Turnover';
        SPDateFilter: Text;
        SPGlobalDim1Filter: Text;
        SPItemGroupFilter: Text;
        SortingText: Text[30];
}

