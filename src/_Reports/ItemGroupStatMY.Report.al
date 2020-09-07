report 6014418 "NPR Item Group Stat M/Y"
{
    // NPR5.29/TR  /20161104  CASE 247166 Report Created
    // NPR5.43/EMGO/20180628  CASE 320173 Add FILTERGROUP to SubItemGroup, to be able to sort by No in Request page.
    // NPR5.45/EMGO/20180808  CASE 320911 Changed the sorting of the SubItemGroups
    // NPR5.45/MITH/20180828  CASE 320911 Modified the layout and toggled the "PrintOnlyIfDetails" for the two Item Groups
    // NPR5.48/ZESO/20181211  CASE 336370 Added Salesperson Code filter.
    // NPR5.48/TS  /20190122  CASE 343216 Added Date Filter
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Group Stat MY.rdlc';

    Caption = 'Item Group Statistic M/Y';
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
                            SetRange("Item Group", ItemGroupNo);
                            SetFilter("Sale Date", '%1..%2', StartDateLastYear, EndDateLastYear);
                            //-NPR5.48 [336370]
                            SetFilter("Salesperson Code", Salesperson.Code);
                            //+NPR5.48 [336370]
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
                            SetRange("Item Group", ItemGroupNo);
                            SetFilter("Sale Date", '%1..%2', StartDate, EndDate);
                            //-NPR5.48 [336370]
                            SetFilter("Salesperson Code", Salesperson.Code);
                            //+NPR5.48 [336370]
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ("No." <> MainItemGroup."No.") and (Level = 1) then
                            CurrReport.Break;
                        ShowItemGroup := MainItemGroup."No." <> "No.";
                        ItemGroupNo := "No.";
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetCurrentKey("No.");
                        //-NPR5.43 [320173]
                        SubItemGroup.FilterGroup(10);
                        //+NPR5.43 [320173]
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
                        ApplicationArea=All;
                    }
                    field(StartDate; StartDate)
                    {
                        Caption = 'Start Date';
                        ApplicationArea=All;
                    }
                    field(EndDate; EndDate)
                    {
                        Caption = 'End Date';
                        ApplicationArea=All;
                    }
                    field("Salesperson.Code"; Salesperson.Code)
                    {
                        Caption = 'Salesperson Code';
                        TableRelation = "Salesperson/Purchaser";
                        ApplicationArea=All;
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
        ReportName: Label 'Item Group Statistics';
        PageNo: Label 'Page No';
        CompanyInfo: Record "Company Information";
        ShowSubGroups: Boolean;
        EndDateCalculated: Boolean;
        TotalSales: Label 'Total Sales';
        ItemGroupNo: Code[20];
        ShowItemGroup: Boolean;
        ShowMainItemGroup: Boolean;
        Salesperson: Record "Salesperson/Purchaser";

    local procedure ClearTotals()
    begin
    end;
}

