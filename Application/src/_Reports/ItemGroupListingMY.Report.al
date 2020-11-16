report 6014437 "NPR Item Group Listing M/Y"
{
    // NPR5.50/ZESO/20190417  CASE 341710 Report Created
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Group Listing MY.rdlc';

    Caption = 'Item Group Listing M/Y';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(StartDate; StartDate)
            {
            }
            column(EndDate; EndDate)
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
            dataitem(ItemGroup; "NPR Item Group")
            {
                DataItemTableView = SORTING("No.");
                PrintOnlyIfDetail = false;
                RequestFilterFields = "No.";
                RequestFilterHeading = 'Main Item Groups';
                column(No_ItemGroup; "No.")
                {
                }
                column(Level_ItemGroup; Level)
                {
                }
                column(Description_ItemGroup; Description)
                {
                }
                column(ShowMainItemGroup; ShowMainItemGroup)
                {
                }
                dataitem(LastYearAuditRoll; "NPR Audit Roll")
                {
                    DataItemLink = "Item Group" = FIELD("No.");
                    DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
                    column(Quantity_LastYearAuditRoll; Quantity)
                    {
                    }
                    column(EkspeditLastYear; EkspeditLastYear)
                    {
                    }
                    column(Amount_LastYearAuditRoll; Amount)
                    {
                    }
                    column(Cost_LastYearAuditRoll; Cost)
                    {
                    }
                    column(LineDiscountAmount_LastYearAuditRoll; "Line Discount Amount")
                    {
                    }
                    column(DBDKK_LastYearAuditRoll; LastYearDBDKK)
                    {
                    }
                    column(DBPercent_LastYearAuditRoll; LastYearDBPercent)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if Quantity > 0 then begin
                            ShowMainItemGroup := true;
                            LastYearDBDKK := (Amount - Cost);
                            TMPItem.Init;
                            TMPItem."No." := "Sales Ticket No.";
                            TMPItem."NPR Item Group" := "Item Group";
                            if TMPItem.Insert then
                                EkspeditLastYear := 1;
                        end else
                            CurrReport.Skip;
                    end;

                    trigger OnPreDataItem()
                    begin

                        SetFilter("Sale Date", '%1..%2', StartDateLastYear, EndDateLastYear);
                        SetFilter("Salesperson Code", Salesperson.Code);
                    end;
                }
                dataitem(CurrentYearAuditRoll; "NPR Audit Roll")
                {
                    DataItemLink = "Item Group" = FIELD("No.");
                    DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
                    column(Quantity_CurrentYearAuditRoll; Quantity)
                    {
                    }
                    column(EkspeditCurrentYear; EkspeditCurrentYear)
                    {
                    }
                    column(Amount_CurrentYearAuditRoll; Amount)
                    {
                    }
                    column(Cost_CurrentYearAuditRoll; Cost)
                    {
                    }
                    column(LineDiscountAmount_CurrentYearAuditRoll; "Line Discount Amount")
                    {
                    }
                    column(DBDKK_CurrentYearAuditRoll; CurrentYearDBDKK)
                    {
                    }
                    column(DBPercent_CurrentYearAuditRoll; CurrentYearDBPercent)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if Quantity > 0 then begin
                            ShowMainItemGroup := true;
                            CurrentYearDBDKK := (Amount - Cost);
                            TMPItem2.Init;
                            TMPItem2."No." := "Sales Ticket No.";
                            TMPItem2."NPR Item Group" := "Item Group";
                            if TMPItem2.Insert then
                                EkspeditCurrentYear := 1;
                        end else
                            CurrReport.Skip;
                    end;

                    trigger OnPreDataItem()
                    begin

                        SetFilter("Sale Date", '%1..%2', StartDate, EndDate);
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
                CompanyInfo.Get;
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
                    field(ShowSubGroups; ShowSubGroups)
                    {
                        Caption = 'Show Sub Item Groups';
                        ApplicationArea = All;
                    }
                    field(StartDate; StartDate)
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                    }
                    field(EndDate; EndDate)
                    {
                        Caption = 'End Date';
                        ApplicationArea = All;
                    }
                    field("Salesperson.Code"; Salesperson.Code)
                    {
                        Caption = 'Salesperson Code';
                        TableRelation = "Salesperson/Purchaser";
                        ApplicationArea = All;
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
        ItemGroupCaption = 'Item Group';
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
        StartDate := DMY2Date(1, Month, Year);

        DateComparison := true;
        ShowSubGroups := true;
        EndDateCalculated := false;
    end;

    trigger OnPreReport()
    begin
        if EndDate = 0D then begin
            EndDate := CalcDate('<-1D>', CalcDate('<1M>', StartDate));
            EndDateCalculated := true;
        end;

        if DateComparison then begin
            StartDateLastYear := CalcDate('<-1Y>', StartDate);
        end else begin
            if (Date2DWY(StartDate, 2) = 53) then
                StartDateLastYear := DWY2Date(Date2DWY(StartDate, 1), Date2DWY(StartDate, 2) - 1, Date2DWY(StartDate, 3) - 1)
            else
                StartDateLastYear := DWY2Date(Date2DWY(StartDate, 1), Date2DWY(StartDate, 2), Date2DWY(StartDate, 3) - 1);
        end;

        if EndDateCalculated then
            EndDateLastYear := CalcDate('<-1D>', CalcDate('<1M>', StartDateLastYear))
        else
            EndDateLastYear := CalcDate('<-1Y>', EndDate);
    end;

    var
        Month: Integer;
        Year: Integer;
        StartDate: Date;
        EndDate: Date;
        DateComparison: Boolean;
        StartDateLastYear: Date;
        EndDateLastYear: Date;
        EkspeditLastYear: Decimal;
        EkspeditCurrentYear: Decimal;
        TMPItem: Record Item temporary;
        TMPItem2: Record Item temporary;
        LastYearDBDKK: Decimal;
        CurrentYearDBDKK: Decimal;
        LastYearDBPercent: Decimal;
        CurrentYearDBPercent: Decimal;
        LastYearTotalAmount: Decimal;
        LastYearTotalCost: Decimal;
        CurrentYearTotalAmount: Decimal;
        CurrentYearTotalCost: Decimal;
        ReportName: Label 'Item Group Statistics';
        PageNo: Label 'Page No';
        CompanyInfo: Record "Company Information";
        ShowSubGroups: Boolean;
        EndDateCalculated: Boolean;
        TotalSales: Label 'Total Sales';
        TotalAmountSubGroup: Decimal;
        "---": Integer;
        ItemGroupNo: Code[20];
        ShowItemGroup: Boolean;
        ShowMainItemGroup: Boolean;
        Salesperson: Record "Salesperson/Purchaser";

    local procedure ClearTotals()
    begin
    end;
}

