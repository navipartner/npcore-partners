page 6014585 "NPR Advanced Sales Stats"
{
    Caption = 'Advanced Sales Statistics Page';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = Date;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(Period)
            {
                field(PeriodType; PeriodType)
                {

                    Caption = 'Period Type';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Period';
                    ToolTip = 'Specifies the value of the Period Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        case PeriodType of
                            PeriodType::Day:
                                begin
                                    Day := Day::Day;
                                end;
                            PeriodType::Week:
                                begin
                                    Day := Day::Week;
                                end;
                            PeriodType::Month:
                                begin
                                    Day := Day::Month;
                                end;
                            PeriodType::Quarter:
                                begin
                                    Day := Day::Quarter;
                                end;
                            PeriodType::Year:
                                begin
                                    Day := Day::Year;
                                end;
                            PeriodType::Period:
                                PeriodPeriodTypeOnValidate();
                        end;

                        Calc();
                        CurrPage.Update(false);
                    end;
                }
                field(DateFilter; DateFilter)
                {

                    Caption = 'Period';
                    ToolTip = 'Specifies the value of the Period field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(DateFilterLastYear; DateFilterLastYear)
                {

                    Caption = 'Period (Last Year)';
                    ToolTip = 'Specifies the value of the Period (Last Year) field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(HideItemGroup; HideItemGroup)
                {

                    Caption = 'Hide Empty Lines';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Hide Empty Lines field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(ItemNoFilter; ItemNoFilter)
                {

                    Caption = 'Item No. Filter';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the value of the Item No. Filter field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;

                }
                field(ItemCategoryCodeFilter; ItemCategoryCodeFilter)
                {

                    Caption = 'Item Category Code';
                    TableRelation = "Item Category";
                    ToolTip = 'Specifies the value of the Item Category Code field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Control6150631)
            {
                ShowCaption = false;
                field(Dim1Filter; Dim1Filter)
                {

                    Caption = 'Dept. Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                    ToolTip = 'Specifies the value of the Dept. Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Dim2Filter; Dim2Filter)
                {

                    Caption = 'Project Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
                    ToolTip = 'Specifies the value of the Project Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(ShowLastYear; ShowLastYear)
                {

                    Caption = 'Show last year';
                    ToolTip = 'Specifies the value of the Show last year field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        PLYSaleQty := ShowLastYear;
                        PLYSale := ShowLastYear;
                        PLYProfit := ShowLastYear;
                        "PLYProfit%" := ShowLastYear;
                        CurrPage.Update(false);
                    end;
                }
                field(ShowSameWeekday; ShowSameWeekday)
                {

                    Caption = 'Show same weekday last year';
                    ToolTip = 'Specifies the value of the Show same weekday last year field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Calc();
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(UpdateControls)
            {
                Editable = false;
                field("Period Name"; Rec."Period Name")
                {

                    ToolTip = 'Specifies the value of the Period Name field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ViewPosition := ViewPosition::Period;
                    end;
                }
                field("Period Start"; Rec."Period Start")
                {

                    ToolTip = 'Specifies the value of the Period Start field';
                    ApplicationArea = NPRRetail;
                }
                field("-Sale (QTY)"; -"Sale (QTY)")
                {

                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the value of the Sale (QTY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
                        AuxItemLedgerEntries: Page "NPR Aux. Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
                        AuxItemLedgerEntries.SetTableView(AuxItemLedgerEntry);
                        AuxItemLedgerEntries.Editable(false);
                        AuxItemLedgerEntries.RunModal();
                    end;
                }
                field("-LastYear Sale (QTY)"; -"LastYear Sale (QTY)")
                {

                    Caption = '-> Last Year';
                    Visible = PLYSaleQty;
                    ToolTip = 'Specifies the value of the -> Last Year field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale (LCY)"; "Sale (LCY)")
                {

                    Caption = 'Sale(LCY)';
                    ToolTip = 'Specifies the value of the Sale(LCY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        AuxValueEntry: Record "NPR Aux. Value Entry";
                        AuxValueEntries: Page "NPR Aux. Value Entries";
                    begin

                        SetValueEntryFilter(AuxValueEntry);
                        AuxValueEntries.SetTableView(AuxValueEntry);
                        AuxValueEntries.Editable(false);
                        AuxValueEntries.RunModal();
                    end;
                }
                field("LastYear Sale (LCY)"; "LastYear Sale (LCY)")
                {

                    Caption = 'LastYear Sale (LCY)';
                    Visible = PLYSale;
                    ToolTip = 'Specifies the value of the LastYear Sale (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit (LCY)"; "Profit (LCY)")
                {

                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the value of the Profit (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit (LCY)"; "LastYear Profit (LCY)")
                {

                    Caption = 'Last Year Profit(LCY)';
                    Visible = PLYProfit;
                    ToolTip = 'Specifies the value of the Last Year Profit(LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; "Profit %")
                {

                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {

                    Caption = 'LastYear Profit %';
                    Visible = "PLYProfit%";
                    ToolTip = 'Specifies the value of the LastYear Profit % field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            group(Reports)
            {
                action("Advanced Sales Statistics")
                {
                    Caption = 'Advanced Sales Statistics';
                    Image = Statistics;

                    ToolTip = 'Executes the Advanced Sales Statistics action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalesStatisticsReport: Report "NPR Advanced Sales Stat.";
                    begin
#if BC17 or BC18
                        SalesStatisticsReport.SetFilter(ViewPosition, Day, Dim1Filter, Dim2Filter, Rec."Period Start",
                                           Rec."Period End", ItemCategoryCodeFilter, LastYearCalc,
                                           (((ViewPosition = ViewPosition::ItemGroup) and HideItemGroup) or
                                             ((ViewPosition = ViewPosition::Item) and HideItem) or
                                             ((ViewPosition = ViewPosition::Customer) and HideCustomer) or
                                             ((ViewPosition = ViewPosition::Vendor) and HideVendor) or
                                             ((ViewPosition = ViewPosition::Projectcode) and false)));
#else
                        SalesStatisticsReport.SetFilter(ViewPosition, PeriodToInteger(Day), Dim1Filter, Dim2Filter, Rec."Period Start",
                                           Rec."Period End", ItemCategoryCodeFilter, LastYearCalc,
                                           (((ViewPosition = ViewPosition::ItemGroup) and HideItemGroup) or
                                             ((ViewPosition = ViewPosition::Item) and HideItem) or
                                             ((ViewPosition = ViewPosition::Customer) and HideCustomer) or
                                             ((ViewPosition = ViewPosition::Vendor) and HideVendor) or
                                             ((ViewPosition = ViewPosition::Projectcode) and false)));
#endif
                        SalesStatisticsReport.RunModal();
                    end;
                }
            }
        }
        area(navigation)
        {
            group(RelatedInformation)
            {
                action("Salesperson Stats")
                {
                    Caption = 'Salesperson Statisticts';
                    Image = SalesPerson;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Salesperson Statisticts action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalespersonStatistics: Page "NPR Salesperson Stats Retail";
                    begin
                        SalespersonStatistics.InitForm();
                        SalespersonStatistics.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", ItemCategoryCodeFilter, LastYearCalc, ItemNoFilter);
                        SalespersonStatistics.ShowLastYear(ShowLastYear);
                        SalespersonStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        SalespersonStatistics.RunModal();
                    end;
                }
                action("Item Statistics")
                {
                    Caption = 'Item Statistics';
                    Image = Item;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Item Statistics action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemStatistics: Page "NPR Item Statistics Subpage";
                    begin
                        ItemStatistics.InitForm();
                        ItemStatistics.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", LastYearCalc, ItemCategoryCodeFilter);
                        ItemStatistics.ShowLastYear(ShowLastYear);
                        ItemStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        ItemStatistics.RunModal();
                    end;
                }
                action("Customer Statistics")
                {
                    Caption = 'Customer Statistics';
                    Image = Customer;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Customer Statistics action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        CustomerStatistics: Page "NPR Customer Stats Subpage";
                    begin
                        CustomerStatistics.InitForm();
                        CustomerStatistics.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", ItemCategoryCodeFilter, LastYearCalc);

                        CustomerStatistics.ShowLastYear(ShowLastYear);
                        CustomerStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        CustomerStatistics.RunModal();
                    end;
                }
                action("Vendor Statistics")
                {
                    Caption = 'Vendor Statistics';
                    Image = Vendor;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Vendor Statistics action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VendorStatistics: Page "NPR Vendor Statistics Subpage";
                    begin
                        VendorStatistics.InitForm();
                        VendorStatistics.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", ItemCategoryCodeFilter, LastYearCalc);

                        VendorStatistics.ShowLastYear(ShowLastYear);
                        VendorStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        VendorStatistics.RunModal();
                    end;
                }
                action("Item Category Code Statistics")
                {
                    Caption = 'Item Category Code Statistics';
                    Image = ItemLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Item Category Code Statistics action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemCategoryStatsSubpage: Page "NPR Item Cat. Code Stats";
                    begin
                        ItemCategoryStatsSubpage.InitForm();
                        ItemCategoryStatsSubpage.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", LastYearCalc, ItemCategoryCodeFilter, ItemNoFilter);
                        ItemCategoryStatsSubpage.ShowLastYear(ShowLastYear);
                        ItemCategoryStatsSubpage.ChangeEmptyFilter();
                        Sleep(10);
                        ItemCategoryStatsSubpage.RunModal()
                    end;
                }
                action("Product Group Code Statistics")
                {
                    Caption = 'Product Group Code Statistics';
                    Image = ProductionSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Product Group Code Statistics action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ProdGroupCodeStatsSubpage: Page "NPR Prod. Group Code Stats";
                    begin
                        ProdGroupCodeStatsSubpage.InitForm();
                        ProdGroupCodeStatsSubpage.SetFilter(Dim1Filter, Dim2Filter, Rec."Period Start", Rec."Period End", LastYearCalc, ItemNoFilter, ItemCategoryCodeFilter);
                        ProdGroupCodeStatsSubpage.ShowLastYear(ShowLastYear);
                        ProdGroupCodeStatsSubpage.ChangeEmptyFilter();
                        Sleep(10);
                        ProdGroupCodeStatsSubpage.RunModal()
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not (UsingPeriod) then begin
            DateFilter := CopyStr(StrSubstNo(DateFilterLbl, Rec."Period Start", Rec."Period End"), 1, 50);
            DateFilterLastYear := CopyStr(StrSubstNo(DateFilterLbl, CalcDate(LastYearCalc, Rec."Period Start"),
            CalcDate(LastYearCalc, Rec."Period End")), 1, 50);
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        Calc();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
#if BC17 or BC18
        exit(PeriodFormMan.FindDate(CopyStr(Which, 1, 3), Rec, Day));
#else
        exit(PeriodPageMan.FindDate(CopyStr(Which, 1, 3), Rec, Day));
#endif
    end;

    trigger OnInit()
    begin
        ShowSameWeekday := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
#if BC17 or BC18
        exit(PeriodFormMan.NextDate(Steps, Rec, Day));
#else
        exit(PeriodPageMan.NextDate(Steps, Rec, Day));
#endif
    end;

    trigger OnOpenPage()
    begin
        ShowLastYear := false;
        PLYSaleQty := ShowLastYear;
        PLYSale := ShowLastYear;
        PLYProfit := ShowLastYear;
        "PLYProfit%" := ShowLastYear;

        HideItem := true;
        HideItemGroup := false;
        HideCustomer := true;
        HideVendor := true;
    end;

    var
#if BC17 or BC18
        PeriodFormMan: Codeunit PeriodFormManagement;
        Day: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
#else
        PeriodPageMan: Codeunit PeriodPageManagement;
        Day: Enum "Analysis Period Type";
        IncorrectPeriodErr: Label 'Incorrect period: %1';
#endif
        "Sale (QTY)": Decimal;
        "LastYear Sale (QTY)": Decimal;
        "Sale (LCY)": Decimal;
        "LastYear Sale (LCY)": Decimal;
        "Profit (LCY)": Decimal;
        "LastYear Profit (LCY)": Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        DateFilter: Text[50];
        ItemGroupCheck: Text[250];
        ItemCheck: Text[250];
        CustomerCheck: Text[250];
        VendorCheck: Text[250];
        ViewPosition: Option Period,Salesperson,ItemGroup,Item,Customer,Vendor,Projectcode;
        HideItem: Boolean;
        HideItemGroup: Boolean;
        HideCustomer: Boolean;
        HideVendor: Boolean;
        LastYear: Boolean;
        ShowLastYear: Boolean;
        LastYearCalc: Text[30];
        ShowSameWeekday: Boolean;
        DateFilterLastYear: Text[50];
        UsingPeriod: Boolean;
        ItemNoFilter: Code[20];
        [InDataSet]
        PLYSaleQty: Boolean;
        [InDataSet]
        PLYSale: Boolean;
        [InDataSet]
        PLYProfit: Boolean;
        [InDataSet]
        "PLYProfit%": Boolean;
        PeriodType: Option Day,Week,Month,Quarter,Year,Period;
        ItemCategoryCodeFilter: Code[20];
        DateFilterLbl: Label '%1..%2', Locked = true;
        CheckValueLbl: Label '%1%2%3', Locked = true;
        CheckValue2Lbl: Label '%1%2%3%4', Locked = true;

    procedure Calc()
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        SetValueEntryFilter(AuxValueEntry);
        AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
        AuxItemLedgerEntry.CalcSums(Quantity);

        "Sale (QTY)" := AuxItemLedgerEntry.Quantity;
        "Sale (LCY)" := AuxValueEntry."Sales Amount (Actual)";
        "Profit (LCY)" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
        if "Sale (LCY)" <> 0 then
            "Profit %" := "Profit (LCY)" / "Sale (LCY)" * 100
        else
            "Profit %" := 0;

        // Calc last year
        LastYear := true;
        if ((Day = Day::Day) and ShowSameWeekday) or (Day = Day::Week) then
            LastYearCalc := '<-52W>'
        else
            LastYearCalc := '<-1Y>';

        if (Date2DMY(Rec."Period Start", 3) < 1) or (Date2DMY(Rec."Period Start", 3) > 9998) then
            LastYearCalc := '';

        SetValueEntryFilter(AuxValueEntry);
        AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
        AuxItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale (QTY)" := AuxItemLedgerEntry.Quantity;
        "LastYear Sale (LCY)" := AuxValueEntry."Sales Amount (Actual)";
        "LastYear Profit (LCY)" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
        if "LastYear Sale (LCY)" <> 0 then
            "LastYear Profit %" := "LastYear Profit (LCY)" / "LastYear Sale (LCY)" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    procedure SetItemLedgerEntryFilter(var AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry")
    begin
        AuxItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
        if not LastYear then
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Rec."Period Start", Rec."Period End")
        else
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Rec."Period Start"), CalcDate(LastYearCalc, Rec."Period End"));

        if Dim1Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code");

        if ItemNoFilter <> '' then
            AuxItemLedgerEntry.SetFilter("Item No.", ItemNoFilter)
        else
            AuxItemLedgerEntry.SetRange("Item No.");

        if ItemCategoryCodeFilter <> '' then
            AuxItemLedgerEntry.SetFilter("Item Category Code", ItemCategoryCodeFilter)
        else
            AuxItemLedgerEntry.SetRange("Item Category Code");
    end;

    procedure SetValueEntryFilter(var AuxValueEntry: Record "NPR Aux. Value Entry")
    begin
        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
        if not LastYear then
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', Rec."Period Start", Rec."Period End")
        else
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, Rec."Period Start"), CalcDate(LastYearCalc, Rec."Period End"));

        if Dim1Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 2 Code");

        if ItemCategoryCodeFilter <> '' then
            AuxValueEntry.SetFilter("Item Category Code", ItemCategoryCodeFilter)
        else
            AuxValueEntry.SetRange("Item Category Code");
    end;

    procedure GetCheckValue(): Text[250]
    begin
        case ViewPosition of
            ViewPosition::ItemGroup:
                begin
                    exit(StrSubstNo(CheckValueLbl, Dim1Filter, Dim2Filter, DateFilter));
                end;
            ViewPosition::Item,
            ViewPosition::Customer,
            ViewPosition::Vendor:
                begin
                    exit(StrSubstNo(CheckValue2Lbl, Dim1Filter, Dim2Filter, ItemCategoryCodeFilter, DateFilter));
                end;
        end;
    end;

    procedure UpdateHiddenLines(ViewPos: Integer; bForce: Boolean)
    begin
        case ViewPos of
            ViewPosition::ItemGroup:
                begin
                    if (ItemGroupCheck <> GetCheckValue()) or bForce then begin
                        ItemGroupCheck := GetCheckValue();
                    end;
                end;
            ViewPosition::Item:
                begin
                    if (ItemCheck <> GetCheckValue()) or bForce then begin
                        ItemCheck := GetCheckValue();
                    end;
                end;
            ViewPosition::Customer:
                begin
                    if (CustomerCheck <> GetCheckValue()) or bForce then begin
                        CustomerCheck := GetCheckValue();
                    end;
                end;
            ViewPosition::Vendor:
                begin
                    if (VendorCheck <> GetCheckValue()) or bForce then begin
                        VendorCheck := GetCheckValue();
                    end;
                end;
        end;
    end;

    local procedure PeriodPeriodTypeOnValidate()
    var
        tblPeriode: Record "NPR Periodes";
    begin
        if not UsingPeriod then
            UsingPeriod := true
        else
            UsingPeriod := false;

        if UsingPeriod then begin
            if PAGE.RunModal(6060102, tblPeriode) = ACTION::LookupOK then begin
                Rec."Period Start" := tblPeriode."Start Date";
                Rec."Period End" := tblPeriode."End Date";
                DateFilter := StrSubstNo(DateFilterLbl, Rec."Period Start", Rec."Period End");
                Rec.SetFilter("Period Start", DateFilter);
                DateFilterLastYear := StrSubstNo(DateFilterLbl, tblPeriode."Start Date Last Year", tblPeriode."End Date Last Year");
                Day := Day::Day;
            end;
        end else
            Rec.SetFilter("Period Start", '');
    end;

#if not BC17 and not BC18
    local procedure PeriodToInteger(Period: Enum "Analysis Period Type"): Integer
    begin
        case Period of
            Period::Day:
                exit(PeriodType::Day);
            Period::Week:
                exit(PeriodType::Week);
            Period::Month:
                exit(PeriodType::Month);
            Period::Quarter:
                exit(PeriodType::Quarter);
            Period::Year:
                exit(PeriodType::Year);
            else
                Error((StrSubstNo(IncorrectPeriodErr, Format(Period))));
        end;
    end;
#endif
}

