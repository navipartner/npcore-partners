report 6014431 "NPR S.Person Trn by Item Cat."
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Person Trn. by Item Cat..rdlc';
    Caption = 'Salesperson Turnover per Item Category';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Item Category"; "Item Category")
        {
            CalcFields = "NPR Consumption (Amount)", "NPR Sales (Qty.)", "NPR Sales (LCY)";
            RequestFilterFields = "Code", "Description", "NPR Date Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CompanyInfoPicture; CompanyInformation.Picture)
            {
            }
            column(DateFilter; GetFilter("NPR Date Filter"))
            {
            }
            column(SortSalesPerson; SortSalesPerson)
            {
            }
            column(No; "Code")
            {
            }
            column(Description; Description)
            {
            }
            column(SalesQty; "NPR Sales (Qty.)")
            {
                AutoFormatType = 1;
            }
            column(SaleLCY; "NPR Sales (LCY)")
            {
                AutoFormatType = 1;
            }
            column(db; "NPR Sales (LCY)" - "NPR Consumption (Amount)")
            {
                AutoFormatType = 1;
            }
            column(dg; Dg)
            {
                AutoFormatType = 1;
            }
            column(PercentTotalSale; PercentTotalSale)
            {
                AutoFormatType = 1;
            }
            column(TotalSale; TotalSale)
            {
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                CalcFields = "NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR COGS (LCY)";
                DataItemLink = "NPR Item Category Filter" = FIELD("Code"), "Date Filter" = FIELD("NPR Date Filter");
                column(SalesPersonCode; Code)
                {
                }
                column(SalesPersonName; Name)
                {
                }
                column(SalesPersonSalesQty; "NPR Sales (Qty.)")
                {
                    AutoFormatType = 1;
                }
                column(SalesPersonSalesLcy; "NPR Sales (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(SalesPersonPercentItemCategorySale; PercentItemCategorySale)
                {
                }
                column(SalesPersonDb; "NPR Sales (LCY)" - "NPR COGS (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(SalesPersonDg; Dg)
                {
                    AutoFormatType = 1;
                }

                trigger OnAfterGetRecord()
                begin
                    if "NPR Sales (Qty.)" = 0 then
                        CurrReport.Skip();

                    Clear(Dg);
                    if "NPR Sales (LCY)" <> 0 then
                        Dg := (("NPR Sales (LCY)" - "NPR COGS (LCY)") / "NPR Sales (LCY)") * 100;

                    if SortSalesPerson then begin
                        TempVendorAmount.Init();
                        TempVendorAmount."Vendor No." := Code;

                        case SortOrder of
                            SortOrder::Highest:
                                Multpl := -1;
                            SortOrder::Lowest:
                                Multpl := 1;
                        end;

                        case SortBy of
                            SortBy::Quantity:
                                TempVendorAmount."Amount (LCY)" := Multpl * "NPR Sales (Qty.)";
                            SortBy::Turnover:
                                TempVendorAmount."Amount (LCY)" := Multpl * "NPR Sales (LCY)";
                            SortBy::DB:
                                TempVendorAmount."Amount (LCY)" := Multpl * ("NPR Sales (LCY)" - "NPR COGS (LCY)");
                        end;
                        TempVendorAmount.Insert();
                    end;

                    Clear(PercentItemCategorySale);
                    if "Item Category"."NPR Sales (LCY)" <> 0 then
                        PercentItemCategorySale := '(' + Format(("NPR Sales (LCY)" / "Item Category"."NPR Sales (LCY)" * 100), -4) + '%)';
                end;

                trigger OnPreDataItem()
                begin
                    TempVendorAmount.DeleteAll();
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(IntNumber; Integer.Number)
                {
                }
                column(IntCode; "Salesperson/Purchaser".Code)
                {
                }
                column(IntName; "Salesperson/Purchaser".Name)
                {
                }
                column(IntQty; "Salesperson/Purchaser"."NPR Sales (Qty.)")
                {
                    AutoFormatType = 1;
                }
                column(IntLCY; "Salesperson/Purchaser"."NPR Sales (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(IntPcttekst; PercentItemCategorySale)
                {
                }
                column(IntDb; "Salesperson/Purchaser"."NPR Sales (LCY)" - "Salesperson/Purchaser"."NPR COGS (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(IntDg; Dg)
                {
                    AutoFormatType = 1;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        if not TempVendorAmount.Find('-') then
                            CurrReport.Break();
                    end else
                        if TempVendorAmount.Next() = 0 then
                            CurrReport.Break();

                    "Salesperson/Purchaser".Get(TempVendorAmount."Vendor No.");
                    "Salesperson/Purchaser".CalcFields("NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR COGS (LCY)");

                    Clear(Dg);
                    if "Salesperson/Purchaser"."NPR Sales (LCY)" <> 0 then
                        Dg := (("Salesperson/Purchaser"."NPR Sales (LCY)" - "Salesperson/Purchaser"."NPR COGS (LCY)") / "Salesperson/Purchaser"."NPR Sales (LCY)") * 100;

                    Clear(PercentItemCategorySale);
                    if "Item Category"."NPR Sales (LCY)" <> 0 then
                        PercentItemCategorySale := '(' + Format(("Salesperson/Purchaser"."NPR Sales (LCY)" / "Item Category"."NPR Sales (LCY)" * 100), -4) + '%)';
                end;

                trigger OnPreDataItem()
                begin
                    if (not SortSalesPerson) then
                        CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not ShowItemsCatWithoutSale then begin
                    if "NPR Sales (Qty.)" = 0 then
                        CurrReport.Skip();
                end;

                Clear(Dg);
                if "NPR Sales (LCY)" <> 0 then
                    Dg := (("NPR Sales (LCY)" - "NPR Consumption (Amount)") / "NPR Sales (LCY)") * 100;

                Clear(PercentTotalSale);
                if TotalSale <> 0 then
                    PercentTotalSale := ("NPR Sales (LCY)" / TotalSale) * 100;
            end;

            trigger OnPreDataItem()
            begin
                CopyFilter("NPR Date Filter", AuxValueEntry."Posting Date");
                AuxValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type", "Variance Type", "Item Charge No.", "Location Code", "Variant Code");
                AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                AuxValueEntry.SetFilter(AuxValueEntry."Item Category Code", '<>%1', '');
                AuxValueEntry.CalcSums("Sales Amount (Actual)");
                TotalSale := AuxValueEntry."Sales Amount (Actual)";
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
                group(Setting)
                {
                    Caption = 'Setting';
                    field("Show ItemCategory with no sales"; ShowItemsCatWithoutSale)
                    {

                        Caption = 'Show Item Category With No Sales';
                        ToolTip = 'Specifies the value of the Show Item Category With No Sales field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sort salespersons"; SortSalesPerson)
                    {

                        Caption = 'Sort Salespersons';
                        ToolTip = 'Specifies the value of the Sort Salespersons field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sort By"; SortBy)
                    {

                        Enabled = sortSalesPerson;
                        Caption = 'Sort By';
                        OptionCaption = 'Quantity,Turnover,DB';
                        ToolTip = 'Specifies the value of the SortBy field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Sort; SortOrder)
                    {

                        Editable = sortSalesPerson;
                        Caption = 'Sort';
                        OptionCaption = 'Highest,Lowest';
                        ToolTip = 'Specifies the value of the Sort field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        Name = 'ConstValue';
        NoCap = 'Item Category';
        SalesPersonCap = 'Sales person';
        DescCap = 'Description';
        qtyCap = 'Qty';
        SalesLcyCap = 'Turnover';
        PartPctCap = 'Part %';
        DbCap = 'Margin';
        DgCap = 'Cover-age. (%)';
        TotalSalesCap = '% total sales';
        ReportCap = 'Sales person turnover per Item Category';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        ShowItemsCatWithoutSale := false;
        SortSalesPerson := false;
        SortOrder := SortOrder::Highest;
        SortBy := SortBy::Quantity;
    end;

    var
        CompanyInformation: Record "Company Information";
        AuxValueEntry: Record "NPR Aux. Value Entry";
        TempVendorAmount: Record "Vendor Amount" temporary;
        ShowItemsCatWithoutSale: Boolean;
        [InDataSet]
        SortSalesPerson: Boolean;
        Dg: Decimal;
        PercentTotalSale: Decimal;
        TotalSale: Decimal;
        Multpl: Integer;
        SortOrder: Option Highest,Lowest;
        SortBy: Option Quantity,Turnover,DB;
        PercentItemCategorySale: Text[30];
}

