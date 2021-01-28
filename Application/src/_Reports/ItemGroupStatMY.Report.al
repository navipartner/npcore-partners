report 6014418 "NPR Item Group Stat M/Y"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Group Stat MY.rdlc';
    Caption = 'Item Group Statistic M/Y';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

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
            dataitem(MainItemGroup; "NPR Item Group")
            {
                DataItemTableView = SORTING("No.") WHERE(Level = CONST(1));
                PrintOnlyIfDetail = true;
                RequestFilterFields = "No.";
                RequestFilterHeading = 'Main Item Groups';
                column(No_MainItemGroup; "No.")
                {
                }
                column(Level_MainItemGroup; Level)
                {
                }
                column(Description_MainItemGroup; Description)
                {
                }
                column(ShowMainItemGroup; ShowMainItemGroup)
                {
                }
                dataitem(SubItemGroup; "NPR Item Group")
                {
                    DataItemLink = "Parent Item Group No." = FIELD("No.");
                    DataItemTableView = SORTING("No.");
                    PrintOnlyIfDetail = true;
                    RequestFilterFields = "No.";
                    RequestFilterHeading = 'Sub Item Groups';
                    column(No_SubItemGroup; "No.")
                    {
                    }
                    column(Level_SubItemGroup; Level)
                    {
                    }
                    column(Description_SubItemGroup; Description)
                    {
                    }
                    column(ShowItemGroup; ShowItemGroup)
                    {
                    }
                    column(ShowSubGroups; ShowSubGroups)
                    {
                    }
                    dataitem(LastYearAuditRoll_sub; "NPR Audit Roll")
                    {
                        DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
                        column(Quantity_LastYearAuditRoll_sub; Quantity)
                        {
                        }
                        column(EkspeditLastYear_sub; EkspeditLastYear)
                        {
                        }
                        column(Amount_LastYearAuditRoll_sub; Amount)
                        {
                        }
                        column(Cost_LastYearAuditRoll_sub; Cost)
                        {
                        }
                        column(LineDiscountAmount_LastYearAuditRoll_sub; "Line Discount Amount")
                        {
                        }
                        column(DBDKK_LastYearAuditRoll_sub; LastYearDBDKK)
                        {
                        }
                        column(DBPercent_LastYearAuditRoll_sub; LastYearDBPercent)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Quantity > 0 then begin
                                ShowMainItemGroup := true;
                                LastYearDBDKK := (Amount - Cost);
                                TMPItem.Init();
                                TMPItem."No." := "Sales Ticket No.";
                                TMPItem."NPR Item Group" := "Item Group";
                                if TMPItem.Insert then
                                    EkspeditLastYear := 1;
                            end else
                                CurrReport.Skip();
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Item Group", ItemGroupNo);
                            SetFilter("Sale Date", '%1..%2', StartDateLastYear, EndDateLastYear);
                            SetFilter("Salesperson Code", Salesperson.Code);
                        end;
                    }
                    dataitem(CurrentYearAuditRoll_sub; "NPR Audit Roll")
                    {
                        DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
                        column(Quantity_CurrentYearAuditRoll_sub; Quantity)
                        {
                        }
                        column(EkspeditCurrentYear_sub; EkspeditCurrentYear)
                        {
                        }
                        column(Amount_CurrentYearAuditRoll_sub; Amount)
                        {
                        }
                        column(Cost_CurrentYearAuditRoll_sub; Cost)
                        {
                        }
                        column(LineDiscountAmount_CurrentYearAuditRoll_sub; "Line Discount Amount")
                        {
                        }
                        column(DBDKK_CurrentYearAuditRoll_sub; CurrentYearDBDKK)
                        {
                        }
                        column(DBPercent_CurrentYearAuditRoll_sub; CurrentYearDBPercent)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Quantity > 0 then begin
                                ShowMainItemGroup := true;
                                CurrentYearDBDKK := (Amount - Cost);
                                TMPItem2.Init();
                                TMPItem2."No." := "Sales Ticket No.";
                                TMPItem2."NPR Item Group" := "Item Group";
                                if TMPItem2.Insert() then
                                    EkspeditCurrentYear := 1;
                            end else
                                CurrReport.Skip();
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Item Group", ItemGroupNo);
                            SetFilter("Sale Date", '%1..%2', StartDate, EndDate);
                            SetFilter("Salesperson Code", Salesperson.Code);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ("No." <> MainItemGroup."No.") and (Level = 1) then
                            CurrReport.Break();
                        ShowItemGroup := MainItemGroup."No." <> "No.";
                        ItemGroupNo := "No.";
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetCurrentKey("No.");
                        SubItemGroup.FilterGroup(10);
                        SetFilter("No.", '>=%1', MainItemGroup."No.");
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
                    field(ShowSubGroups; ShowSubGroups)
                    {
                        Caption = 'Show Sub Item Groups';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Sub Item Groups field';
                    }
                    field(StartDate; StartDate)
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Start Date field';
                    }
                    field(EndDate; EndDate)
                    {
                        Caption = 'End Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the End Date field';
                    }
                    field("Salesperson.Code"; Salesperson.Code)
                    {
                        Caption = 'Salesperson Code';
                        TableRelation = "Salesperson/Purchaser";
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                }
            }
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
        CompanyInfo: Record "Company Information";
        TMPItem: Record Item temporary;
        TMPItem2: Record Item temporary;
        Salesperson: Record "Salesperson/Purchaser";
        DateComparison: Boolean;
        EndDateCalculated: Boolean;
        ShowItemGroup: Boolean;
        ShowMainItemGroup: Boolean;
        ShowSubGroups: Boolean;
        ItemGroupNo: Code[20];
        EndDate: Date;
        EndDateLastYear: Date;
        StartDate: Date;
        StartDateLastYear: Date;
        CurrentYearDBDKK: Decimal;
        CurrentYearDBPercent: Decimal;
        EkspeditCurrentYear: Decimal;
        EkspeditLastYear: Decimal;
        LastYearDBDKK: Decimal;
        LastYearDBPercent: Decimal;
        Month: Integer;
        Year: Integer;
        ReportName: Label 'Item Group Statistics';
        PageNo: Label 'Page No';
        TotalSales: Label 'Total Sales';
}

