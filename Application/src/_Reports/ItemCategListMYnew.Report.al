report 6014437 "NPR Item Categ. List. M/Y new"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/ItemGroupListingMYnew.rdlc';

    Caption = 'Item Category Listing M/Y';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Suite;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(StartDate; StartDate_)
            {
            }
            column(EndDate; EndDate_)
            {
            }
            column(StartDateLastYear; StartDateLastYear)
            {
            }
            column(EndDateLastYear; EndDateLastYear)
            {
            }
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(ReportName; ReportName)
            {
            }
            column(PageNo; PageNo)
            {
            }
            column(TotalSales; TotalSales)
            {
            }
            column(ShowSubGroups; ShowSubGroups_)
            {
            }
            column(EndText; Text10600010)
            {
            }
            dataitem(ItemGroup; "Item Category")
            {
                DataItemTableView = SORTING(Code) ORDER(Ascending);
                PrintOnlyIfDetail = false;
                RequestFilterHeading = 'Main Item ';
                RequestFilterFields = Code, "Parent Category";
                column(No_ItemGroup; Code)
                {
                }
                column(Level_ItemGroup; ItemGroup.Indentation)
                {
                }
                column(Description_ItemGroup; Description)
                {
                }
                column(ShowMainItemGroup; ShowMainItemGroup)
                {
                }
                dataitem(LastYearPOSSaleLine; "NPR POS Entry Sales Line")
                {
                    DataItemLink = "Item Category Code" = FIELD(Code);
                    DataItemTableView = SORTING("POS Entry No.", "Line No.");
                    column(Quantity_LastYearPOSSaleLine; Quantity)
                    {
                    }
                    column(EkspeditLastYearPOSSaleLine; EkspeditLastYear)
                    {
                    }
                    column(Amount_LastYearPOSSaleLine; "Amount Excl. VAT")
                    {
                    }
                    column(Cost_LastYearPOSSaleLine; "Unit Cost (LCY)")
                    {
                    }
                    column(LineDiscountAmount_LastYearPOSSaleLine; "Line Discount Amount Excl. VAT")
                    {
                    }
                    column(DBDKK_LastYearPOSSaleLine; LastYearDBDKK)
                    {
                    }
                    column(DBPercent_LastYearPOSSaleLine; LastYearDBPercent)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if Quantity > 0 then begin
                            ShowMainItemGroup := true;
                            LastYearDBDKK := ("Amount Excl. VAT" - LastYearPOSSaleLine."Unit Cost (LCY)");
                            TempItem.Init();
                            TempItem."No." := "Document No.";
                            TempItem."Item Category Code" := "Item Category Code";
                            if TempItem.Insert() then
                                EkspeditLastYear := 1;
                        end else
                            CurrReport.Skip();
                    end;

                    trigger OnPreDataItem()
                    begin

                        SetFilter("Entry Date", '%1..%2', StartDateLastYear, EndDateLastYear);
                        SetFilter("Salesperson Code", Salesperson.Code);
                    end;
                }
                dataitem(CurrentYearPOSSaleLine; "NPR POS Entry Sales Line")
                {
                    DataItemLink = "Item Category Code" = FIELD(Code);
                    DataItemTableView = SORTING("POS Entry No.", "Line No.");
                    column(Quantity_CurrentYearPOSSaleLine; Quantity)
                    {
                    }
                    column(EkspeditCurrentYearPOSSaleLine; EkspeditCurrentYear)
                    {
                    }
                    column(Amount_CurrentYearPOSSaleLine; "Amount Excl. VAT")
                    {
                    }
                    column(Cost_CurrentYearPOSSaleLine; "Unit Cost (LCY)")
                    {
                    }
                    column(LineDiscountAmount_CurrentYearPOSSaleLine; "Line Discount Amount Excl. VAT")
                    {
                    }
                    column(DBDKK_CurrentYearPOSSaleLine; CurrentYearDBDKK)
                    {
                    }
                    column(DBPercent_CurrentYearPOSSaleLine; CurrentYearDBPercent)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if Quantity > 0 then begin
                            ShowMainItemGroup := true;
                            CurrentYearDBDKK := ("Amount Excl. VAT" - CurrentYearPOSSaleLine."Unit Cost (LCY)");
                            TempItem2.Init();
                            TempItem2."No." := "Document No.";
                            TempItem."Item Category Code" := "Item Category Code";
                            if TempItem2.Insert() then
                                EkspeditCurrentYear := 1;
                        end else
                            CurrReport.Skip();
                    end;

                    trigger OnPreDataItem()
                    begin

                        SetFilter("Entry Date", '%1..%2', StartDate_, EndDate_);
                        SetFilter("Salesperson Code", Salesperson.Code);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    ShowMainItemGroup := false;
                end;
            }

            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
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
                    field(ShowSubGroups; ShowSubGroups_)
                    {
                        Caption = 'Show Sub Item Groups';
                        ApplicationArea = Suite;
                        ToolTip = 'Specifies the value of the Show Sub Item Groups field.';
                    }
                    field(StartDate; StartDate_)
                    {
                        Caption = 'Start Date';
                        ApplicationArea = Suite;
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field(EndDate; EndDate_)
                    {
                        Caption = 'End Date';
                        ApplicationArea = Suite;
                        ToolTip = 'Specifies the value of the End Date field.';
                    }
                    field("Salesperson.Code"; Salesperson.Code)
                    {
                        Caption = 'Salesperson Code';
                        TableRelation = "Salesperson/Purchaser";
                        ApplicationArea = Suite;
                        ToolTip = 'Specifies the value of the Salesperson Code field.';
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
        ItemGroupCaption = 'Item Category';
        DescriptionItemGroupCaption = 'Description';
        QuantityCaption = 'Qty.';
        EkspeditCaption = 'Ekspedit';
        TurnoverCaption = 'Turnover';
        CostCaption = 'Cost';
        DiscountCaption = 'Discount';
        ProfitCaption = 'DB DKK';
        ProfitPercentCaption = 'DG %';
        Period1Caption = 'Period 1';
        Period2Caption = 'Period 2';
    }

    trigger OnInitReport()
    begin
        Month := Date2DMY(Today, 2);
        Year := Date2DWY(Today, 3);
        StartDate_ := DMY2Date(1, Month, Year);

        DateComparison := true;
        ShowSubGroups_ := true;
        EndDateCalculated := false;
    end;

    trigger OnPreReport()
    begin
        if EndDate_ = 0D then begin
            EndDate_ := CalcDate('<-1D>', CalcDate('<1M>', StartDate_));
            EndDateCalculated := true;
        end;

        if DateComparison then begin
            StartDateLastYear := CalcDate('<-1Y>', StartDate_);
        end else begin
            if (Date2DWY(StartDate_, 2) = 53) then
                StartDateLastYear := DWY2Date(Date2DWY(StartDate_, 1), Date2DWY(StartDate_, 2) - 1, Date2DWY(StartDate_, 3) - 1)
            else
                StartDateLastYear := DWY2Date(Date2DWY(StartDate_, 1), Date2DWY(StartDate_, 2), Date2DWY(StartDate_, 3) - 1);
        end;

        if EndDateCalculated then
            EndDateLastYear := CalcDate('<-1D>', CalcDate('<1M>', StartDateLastYear))
        else
            EndDateLastYear := CalcDate('<-1Y>', EndDate_);
    end;

    var
        Month: Integer;
        Year: Integer;
        StartDate_: Date;
        EndDate_: Date;
        DateComparison: Boolean;
        StartDateLastYear: Date;
        EndDateLastYear: Date;
        EkspeditLastYear: Decimal;
        EkspeditCurrentYear: Decimal;
        TempItem: Record Item temporary;
        TempItem2: Record Item temporary;
        LastYearDBDKK: Decimal;
        CurrentYearDBDKK: Decimal;
        LastYearDBPercent: Decimal;
        CurrentYearDBPercent: Decimal;
        //LastYearTotalAmount: Decimal;
        //LastYearTotalCost: Decimal;
        //CurrentYearTotalAmount: Decimal;
        //CurrentYearTotalCost: Decimal;
        ReportName: Label 'Item Category Listing M/Y';
        Text10600010: Label 'Note : All figures are exclusive of VAT';
        PageNo: Label 'Page No';
        CompanyInfo: Record "Company Information";
        ShowSubGroups_: Boolean;
        EndDateCalculated: Boolean;
        TotalSales: Label 'Total Sales';
        //TotalAmountSubGroup: Decimal;
        //"---": Integer;
        //ItemGroupNo: Code[20];
        //ShowItemGroup: Boolean;
        ShowMainItemGroup: Boolean;
        Salesperson: Record "Salesperson/Purchaser";

    /* local procedure ClearTotals()
    begin
    end; */
}

