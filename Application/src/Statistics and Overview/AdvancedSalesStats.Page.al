page 6014585 "NPR Advanced Sales Stats"
{
    // //-NPR3.0b v.Simon Sch¢bel
    //    Oversættelser
    // 001, NPK, MIM, 25-07-07: Tilf¢jet update af subforme.
    // NPR7.000.000,TS-26.10.12 : There were codes that were written on the Activate Trigger of the Subforms.
    // NPR4.13/BHR/20150715 CASE 217113 Add "report Advanced Sales Statistics" 6014490
    // 
    // NPR4.21/RMT /20151028  CASE 226010 - corrections to filtering of subpages
    // NPR4.21/TS  /20151028  CASE 226010 - corrections to filtering of subpages
    // NPR5.29/MHA /20160106  CASE 257163 Enabled Lazy Load by setting PageType = List and removed Group around Repeater
    // NPR5.31/TS  /20170308  CASE 267858 Added new Filters and commented some codes
    // NPR5.40/THRO/20180326  CASE 308387 Removed unused function CopyLines
    // NPR5.44/ZESO/20182906 CASE 312575 Added filter Item Category Code
    // NPR5.48/TJ  /20181115 CASE 330832 Increased Length of variable ItemCategoryCodeFilter from 10 to 20
    // NPR5.50/ZESO/20190430 CASE 353384 Removed Product Group Code filter
    // NPR5.51/ZESO/20190620 CASE 358271 Flow Item Group Filter to Item Group Statistics
    // NPR5.51/YAHA/20190822 CASE 365732 Flow Item Category Filter to Item Statistics
    // NPR5.55/BHR /20200724 CASE 361515 Comment Key not used in AL

    Caption = 'Advanced Sales Statistics';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = Date;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(Period)
            {
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = All;
                    Caption = 'Period Type';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Period';
                    ToolTip = 'Specifies the value of the Period Type field';

                    trigger OnValidate()
                    begin

                        if PeriodType = PeriodType::Period then
                            PeriodPeriodTypeOnValidate;

                        if PeriodType = PeriodType::Year then
                            YearPeriodTypeOnValidate;

                        if PeriodType = PeriodType::Quarter then
                            QuarterPeriodTypeOnValidate;

                        if PeriodType = PeriodType::Month then
                            MonthPeriodTypeOnValidate;

                        if PeriodType = PeriodType::Week then
                            WeekPeriodTypeOnValidate;

                        if PeriodType = PeriodType::Day then
                            DayPeriodTypeOnValidate;

                        CurrPage.Update;
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Period';
                    ToolTip = 'Specifies the value of the Period field';
                }
                field(DateFilterLastYear; DateFilterLastYear)
                {
                    ApplicationArea = All;
                    Caption = 'Period (Last Year)';
                    ToolTip = 'Specifies the value of the Period (Last Year) field';
                }
                field(HideItemGroup; HideItemGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Hide Empty Lines';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Hide Empty Lines field';

                    trigger OnValidate()
                    begin
                        //HideLines()
                        //IF HideItemGroup THEN BEGIN
                        //-NPR4.21
                        //CurrPage.ItemGroupStatisticsSubpage.PAGE.ChangeEmptyFilter;
                        //CurrPage.ItemStatisticsSubpage.PAGE.ChangeEmptyFilter;
                        //CurrPage."CustomerStatistics Subpage".PAGE.ChangeEmptyFilter;
                        //CurrPage.VendorStatisticsSubpage.PAGE.ChangeEmptyFilter;
                        //CurrPage.SalespersonStatisticsSubpage.PAGE.ChangeEmptyFilter;
                        //CurrPage.UPDATE(TRUE);
                        //END;
                        //HideLines;
                        //+NPR4.21
                        CurrPage.Update(false);
                    end;
                }
                field(ItemNoFilter; ItemNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item No. Filter';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the value of the Item No. Filter field';

                    trigger OnValidate()
                    begin
                        //-NPR4.21
                        //CurrForm.SubSalesperson.FORM.SetFilter( Dim1Filter, Dim2Filter, "Period Start", "Period End", ItemGroupFilter, LastYearCalc,
                        //ItemNoFilter);
                        //CurrPage.SalespersonStatisticsSubpage.PAGE.SetFilter( Dim1Filter, Dim2Filter, "Period Start", "Period End", ItemGroupFilter, LastYearCalc,ItemNoFilter);
                        //+NPR4.21
                        //-NPR5.31
                        //UpdateSubformFilters;
                        //+NPR5.31
                    end;
                }
                field(ItemGroupFilter; ItemGroupFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Group Filter';
                    TableRelation = "NPR Item Group" WHERE(Blocked = CONST(false));
                    ToolTip = 'Specifies the value of the Item Group Filter field';
                }
                field(ItemCategoryCodeFilter; ItemCategoryCodeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Category Code';
                    TableRelation = "Item Category";
                    ToolTip = 'Specifies the value of the Item Category Code field';
                }
            }
            group(Control6150631)
            {
                ShowCaption = false;
                field(Dim1Filter; Dim1Filter)
                {
                    ApplicationArea = All;
                    Caption = 'Dept. Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                    ToolTip = 'Specifies the value of the Dept. Code field';

                    trigger OnValidate()
                    begin
                        //-NPR5.31
                        //UpdateSubformFilters;
                        //+NPR5.31
                        //UpdateHiddenLines( ViewPosition, TRUE );
                        CurrPage.Update;
                        //CurrForm.UPDATE;
                    end;
                }
                field(Dim2Filter; Dim2Filter)
                {
                    ApplicationArea = All;
                    Caption = 'Project Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
                    ToolTip = 'Specifies the value of the Project Code field';

                    trigger OnValidate()
                    begin
                        //-NPR5.31
                        //UpdateSubformFilters;
                        //+NPR5.31
                        //UpdateHiddenLines( ViewPosition, TRUE );
                        //CurrForm.UPDATE;
                        CurrPage.Update;
                    end;
                }
                field(ShowLastYear; ShowLastYear)
                {
                    ApplicationArea = All;
                    Caption = 'Show last year';
                    ToolTip = 'Specifies the value of the Show last year field';

                    trigger OnValidate()
                    begin

                        // Periode
                        //CurrForm."Periode LastYear Sale (Qty.)".VISIBLE( ShowLastYear );
                        //CurrForm."Periode LastYear Sale (£)".VISIBLE( ShowLastYear );
                        //CurrForm."Periode LastYear Profit (£)".VISIBLE( ShowLastYear );
                        //CurrForm."Periode LastYear Profit %".VISIBLE( ShowLastYear );
                        PLYSaleQty := ShowLastYear;
                        PLYSale := ShowLastYear;
                        PLYProfit := ShowLastYear;
                        "PLYProfit%" := ShowLastYear;
                        //-NPR4.21
                        // Varegruppe
                        //CurrForm.SubItemGroup.FORM.ShowLastYear( ShowLastYear );
                        //CurrPage.ItemGroupStatisticsSubpage.PAGE.ShowLastYear(ShowLastYear);

                        // Sælger
                        //CurrForm.SubSalesperson.FORM.ShowLastYear( ShowLastYear );
                        //CurrPage.SalespersonStatisticsSubpage.PAGE.ShowLastYear( ShowLastYear );
                        // Vare
                        //CurrForm.SubItem.FORM.ShowLastYear( ShowLastYear );
                        //CurrPage.ItemStatisticsSubpage.PAGE.ShowLastYear( ShowLastYear );
                        // Debitor
                        //CurrForm.SubCustomer.FORM.ShowLastYear( ShowLastYear );
                        //CurrPage."CustomerStatistics Subpage".PAGE.ShowLastYear( ShowLastYear );
                        // Kreditor
                        //CurrForm.SubVendor.FORM.ShowLastYear( ShowLastYear );
                        //CurrPage.VendorStatisticsSubpage.PAGE.ShowLastYear( ShowLastYear );
                        //+NPR4.21
                    end;
                }
                field(ShowSameWeekday; ShowSameWeekday)
                {
                    ApplicationArea = All;
                    Caption = 'Show same weekday last year';
                    ToolTip = 'Specifies the value of the Show same weekday last year field';

                    trigger OnValidate()
                    begin
                        Calc();
                    end;
                }
            }
            repeater(UpdateControls)
            {
                Editable = false;
                field("Period Name"; "Period Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Name field';

                    trigger OnValidate()
                    begin
                        ViewPosition := ViewPosition::Period;
                    end;
                }
                field("Period Start"; "Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Start field';
                }
                field("-""Sale (QTY)"""; -"Sale (QTY)")
                {
                    ApplicationArea = All;
                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the value of the Sale (QTY) field';

                    trigger OnDrillDown()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        ItemLedgerEntryForm: Page "Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter(ItemLedgerEntry);
                        ItemLedgerEntryForm.SetTableView(ItemLedgerEntry);
                        ItemLedgerEntryForm.Editable(false);
                        ItemLedgerEntryForm.RunModal;
                    end;
                }
                field("-""LastYear Sale (QTY)"""; -"LastYear Sale (QTY)")
                {
                    ApplicationArea = All;
                    Caption = '-> Last Year';
                    Visible = PLYSaleQty;
                    ToolTip = 'Specifies the value of the -> Last Year field';
                }
                field("Sale (LCY)"; "Sale (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Sale(LCY)';
                    ToolTip = 'Specifies the value of the Sale(LCY) field';

                    trigger OnDrillDown()
                    var
                        ValueEntry: Record "Value Entry";
                        ValueEntryForm: Page "Value Entries";
                    begin

                        SetValueEntryFilter(ValueEntry);
                        ValueEntryForm.SetTableView(ValueEntry);
                        ValueEntryForm.Editable(false);
                        ValueEntryForm.RunModal;
                    end;
                }
                field("LastYear Sale (LCY)"; "LastYear Sale (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'LastYear Sale (LCY)';
                    Visible = PLYSale;
                    ToolTip = 'Specifies the value of the LastYear Sale (LCY) field';
                }
                field("Profit (LCY)"; "Profit (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the value of the Profit (LCY) field';
                }
                field("LastYear Profit (LCY)"; "LastYear Profit (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Last Year Profit(LCY)';
                    Visible = PLYProfit;
                    ToolTip = 'Specifies the value of the Last Year Profit(LCY) field';
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {
                    ApplicationArea = All;
                    Caption = 'LastYear Profit %';
                    Visible = "PLYProfit%";
                    ToolTip = 'Specifies the value of the LastYear Profit % field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Advanced Sales Statistics action';

                    trigger OnAction()
                    var
                        SalesStatisticsReport: Report "NPR Advanced Sales Stat.";
                    begin
                        //-NPR4.13

                        SalesStatisticsReport.setFilter(ViewPosition, Day, Dim1Filter, Dim2Filter, "Period Start",
                                           "Period End", ItemGroupFilter, LastYearCalc,
                                           (((ViewPosition = ViewPosition::ItemGroup) and HideItemGroup) or
                                             ((ViewPosition = ViewPosition::Item) and HideItem) or
                                             ((ViewPosition = ViewPosition::Customer) and HideCustomer) or
                                             ((ViewPosition = ViewPosition::Vendor) and HideVendor) or
                                             ((ViewPosition = ViewPosition::Projectcode) and false)));
                        SalesStatisticsReport.RunModal;

                        //+NPR4.13
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Salesperson Statisticts action';

                    trigger OnAction()
                    var
                        SalespersonStatistics: Page "NPR Salesperson Stats Retail";
                    begin
                        //-NPR4.21
                        SalespersonStatistics.InitForm;
                        SalespersonStatistics.SetFilter(Dim1Filter, Dim2Filter, "Period Start", "Period End", ItemGroupFilter, LastYearCalc,
                                                                             ItemNoFilter);
                        SalespersonStatistics.ShowLastYear(ShowLastYear);
                        SalespersonStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        SalespersonStatistics.RunModal;
                        //+NPR4.21
                    end;
                }
                action("Item Group")
                {
                    Caption = 'Item Group';
                    Image = ItemGroup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Group action';

                    trigger OnAction()
                    var
                        ItemGroupStatistic: Page "NPR Item Group Stats Subpage";
                    begin
                        //-NPR4.21
                        ItemGroupStatistic.InitForm;
                        ItemGroupStatistic.SetFilter(Dim1Filter, Dim2Filter, "Period Start", "Period End", LastYearCalc);
                        //ItemGroupFilter :=

                        //-NPR5.51 [358271]
                        //ItemGroupStatistic.GetItemGroupCode;
                        ItemGroupStatistic.GetItemGroupCode(ItemGroupFilter);
                        //-NPR5.51 [358271]
                        ItemGroupStatistic.ShowLastYear(ShowLastYear);
                        ItemGroupStatistic.ChangeEmptyFilter;
                        Sleep(10);
                        ItemGroupStatistic.RunModal
                        //+NPR4.21
                    end;
                }
                action("Item Statistics")
                {
                    Caption = 'Item Statistics';
                    Image = Item;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Statistics action';

                    trigger OnAction()
                    var
                        ItemStatistics: Page "NPR Item Statistics Subpage";
                    begin
                        //-NPR4.21
                        ItemStatistics.InitForm;
                        //-NPR5.51 [365732]
                        //ItemStatistics.SetFilter( Dim1Filter, Dim2Filter, "Period Start", "Period End", ItemGroupFilter, LastYearCalc);
                        ItemStatistics.SetFilter(Dim1Filter, Dim2Filter, "Period Start", "Period End", ItemGroupFilter, LastYearCalc, ItemCategoryCodeFilter);
                        //+NPR5.51 [365732]
                        ItemStatistics.ShowLastYear(ShowLastYear);
                        ItemStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        ItemStatistics.RunModal;
                        //+NPR4.21
                    end;
                }
                action("Customer Statistics")
                {
                    Caption = 'Customer Statistics';
                    Image = Customer;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer Statistics action';

                    trigger OnAction()
                    var
                        CustomerStatistics: Page "NPR Customer Stats Subpage";
                    begin
                        //-NPR4.21
                        CustomerStatistics.InitForm;
                        CustomerStatistics.SetFilter(Dim1Filter, Dim2Filter, "Period Start", "Period End", ItemGroupFilter, LastYearCalc);

                        CustomerStatistics.ShowLastYear(ShowLastYear);
                        CustomerStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        CustomerStatistics.RunModal;
                        //+NPR4.21
                    end;
                }
                action("Vendor Statistics")
                {
                    Caption = 'Vendor Statistics';
                    Image = Vendor;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor Statistics action';

                    trigger OnAction()
                    var
                        VendorStatistics: Page "NPR Vendor Statistics Subpage";
                    begin
                        //-NPR4.21
                        VendorStatistics.InitForm;
                        VendorStatistics.SetFilter(Dim1Filter, Dim2Filter, "Period Start", "Period End", ItemGroupFilter, LastYearCalc);

                        VendorStatistics.ShowLastYear(ShowLastYear);
                        VendorStatistics.ChangeEmptyFilter();
                        Sleep(10);
                        VendorStatistics.RunModal;
                        //+NPR4.21
                    end;
                }
                action("Item Category Code Statistics")
                {
                    Caption = 'Item Category Code Statistics';
                    Image = ItemLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Category Code Statistics action';

                    trigger OnAction()
                    var
                        ItemCategoryStatsSubpage: Page "NPR Item Cat. Code Stats";
                    begin

                        //-NPR5.31
                        ItemCategoryStatsSubpage.InitForm;
                        ItemCategoryStatsSubpage.SetFilter(Dim1Filter, Dim2Filter, "Period Start", "Period End", LastYearCalc, ItemCategoryCodeFilter, ItemNoFilter);
                        ItemCategoryStatsSubpage.ShowLastYear(ShowLastYear);
                        ItemCategoryStatsSubpage.ChangeEmptyFilter;
                        Sleep(10);
                        ItemCategoryStatsSubpage.RunModal
                        //+NPR5.31
                    end;
                }
                action("Product Group Code Statistics")
                {
                    Caption = 'Product Group Code Statistics';
                    Image = ProductionSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Product Group Code Statistics action';

                    trigger OnAction()
                    var
                        ProdGroupCodeStatsSubpage: Page "NPR Prod. Group Code Stats";
                    begin

                        //-NPR5.31
                        ProdGroupCodeStatsSubpage.InitForm;
                        ProdGroupCodeStatsSubpage.SetFilter(Dim1Filter, Dim2Filter, "Period Start", "Period End", LastYearCalc, ProductGroupCodeFilter, ItemNoFilter, ItemCategoryCodeFilter);
                        ProdGroupCodeStatsSubpage.ShowLastYear(ShowLastYear);
                        ProdGroupCodeStatsSubpage.ChangeEmptyFilter;
                        Sleep(10);
                        ProdGroupCodeStatsSubpage.RunModal
                        //+NPR5.31
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin

        if not (UsingPeriod) then begin
            DateFilter := CopyStr(StrSubstNo('%1..%2', "Period Start", "Period End"), 1, 50);
            DateFilterLastYear := CopyStr(StrSubstNo('%1..%2', CalcDate(LastYearCalc, "Period Start"),
            CalcDate(LastYearCalc, "Period End")), 1, 50);
        end;
        //-NPR5.31
        //  UpdateSubformFilters;
        //END ELSE
        //  UpdateSubformFilters;
        //+NPR5.31
    end;

    trigger OnAfterGetRecord()
    begin
        Calc;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(PeriodFormMan.FindDate(Which, Rec, Day));
    end;

    trigger OnInit()
    begin
        ShowSameWeekday := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin

        exit(PeriodFormMan.NextDate(Steps, Rec, Day));
    end;

    trigger OnOpenPage()
    begin
        //HideItemGroup:=FALSE;
        ShowLastYear := false;


        PLYSaleQty := ShowLastYear;
        PLYSale := ShowLastYear;
        PLYProfit := ShowLastYear;
        "PLYProfit%" := ShowLastYear;
        //-NPR4.21
        // Varegruppe
        //CurrForm.SubItemGroup.FORM.ShowLastYear( ShowLastYear );
        //CurrPage.ItemGroupStatisticsSubpage.PAGE.ShowLastYear(ShowLastYear);

        // Sælger
        //CurrForm.SubSalesperson.FORM.ShowLastYear( ShowLastYear );
        //CurrPage.SalespersonStatisticsSubpage.PAGE.ShowLastYear( ShowLastYear );
        // Vare
        //CurrForm.SubItem.FORM.ShowLastYear( ShowLastYear );
        //CurrPage.ItemStatisticsSubpage.PAGE.ShowLastYear( ShowLastYear );
        // Debitor
        //CurrForm.SubCustomer.FORM.ShowLastYear( ShowLastYear );
        //CurrPage."CustomerStatistics Subpage".PAGE.ShowLastYear( ShowLastYear );
        // Kreditor
        //CurrForm.SubVendor.FORM.ShowLastYear( ShowLastYear );
        //CurrPage.VendorStatisticsSubpage.PAGE.ShowLastYear( ShowLastYear );
        //+NPR4.21

        HideItem := true;
        HideItemGroup := false;
        HideCustomer := true;
        HideVendor := true;
        HideProjectcode := true;
        HideSalesperson := true;
        //-NPR4.21
        //CurrForm.SubItemGroup.FORM.InitForm;
        //CurrForm.SubSalesperson.FORM.InitForm;
        //CurrForm.SubItem.FORM.InitForm;
        //CurrForm.SubCustomer.FORM.InitForm;
        //CurrForm.SubVendor.FORM.InitForm;
        //CurrPage.ItemGroupStatisticsSubpage.PAGE.InitForm;
        //CurrPage.SalespersonStatisticsSubpage.PAGE.InitForm;
        //CurrPage.ItemStatisticsSubpage.PAGE.InitForm;
        //CurrPage."CustomerStatistics Subpage".PAGE.InitForm;
        //CurrPage.VendorStatisticsSubpage.PAGE.InitForm;
        //CurrForm.SubProject.FORM.initForm;
        //+NPR4.21
    end;

    var
        PeriodFormMan: Codeunit PeriodFormManagement;
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
        ItemGroupFilter: Code[20];
        DateFilter: Text[50];
        ItemGroupCheck: Text[250];
        ItemCheck: Text[250];
        CustomerCheck: Text[250];
        VendorCheck: Text[250];
        Day: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        ViewPosition: Option Period,Salesperson,ItemGroup,Item,Customer,Vendor,Projectcode;
        HideItem: Boolean;
        HideItemGroup: Boolean;
        HideCustomer: Boolean;
        HideVendor: Boolean;
        HideProjectcode: Boolean;
        HideSalesperson: Boolean;
        LastYear: Boolean;
        ShowLastYear: Boolean;
        LastYearCalc: Text[30];
        ShowSameWeekday: Boolean;
        DateFilterLastYear: Text[50];
        UsingPeriod: Boolean;
        Switch: Option Off,On;
        ItemNoFilter: Code[20];
        FilterNoSales: Boolean;
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
        ProductGroupCodeFilter: Code[10];

    procedure Calc()
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //Calc()
        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "Sale (QTY)" := ItemLedgerEntry.Quantity;
        "Sale (LCY)" := ValueEntry."Sales Amount (Actual)";
        "Profit (LCY)" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
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

        if (Date2DMY("Period Start", 3) < 1) or (Date2DMY("Period Start", 3) > 9998) then
            LastYearCalc := '';

        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale (QTY)" := ItemLedgerEntry.Quantity;
        "LastYear Sale (LCY)" := ValueEntry."Sales Amount (Actual)";
        "LastYear Profit (LCY)" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        if "LastYear Sale (LCY)" <> 0 then
            "LastYear Profit %" := "LastYear Profit (LCY)" / "LastYear Sale (LCY)" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
        //-NPR5.31
        //UpdateSubformFilters;
        //+NPR5.31
    end;

    procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', "Period Start", "Period End")
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, "Period Start"), CalcDate(LastYearCalc, "Period End")
          );


        if ItemGroupFilter <> '' then
            ItemLedgerEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ItemLedgerEntry.SetRange("NPR Item Group No.");

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");
        //-NPR5.31
        if ItemNoFilter <> '' then
            ItemLedgerEntry.SetFilter("Item No.", ItemNoFilter)
        else
            ItemLedgerEntry.SetRange("Item No.");
        //+NPR5.31



        //-NPR5.44 [312575]
        if ItemCategoryCodeFilter <> '' then
            ItemLedgerEntry.SetFilter("Item Category Code", ItemCategoryCodeFilter)
        else
            ItemLedgerEntry.SetRange("Item Category Code");
        //+NPR5.44 [312575]
    end;

    procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        //SetValueEntryFilter
        //-NPR5.55 [361515]
        //ValueEntry.SETCURRENTKEY( "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        //+NPR5.55 [361515]
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', "Period Start", "Period End")
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(LastYearCalc, "Period Start"), CalcDate(LastYearCalc, "Period End"));

        if ItemGroupFilter <> '' then
            ValueEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ValueEntry.SetRange("NPR Item Group No.");

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ValueEntry.SetRange("Global Dimension 2 Code");


        //-NPR5.44 [312575]
        if ItemCategoryCodeFilter <> '' then
            ValueEntry.SetFilter("NPR Item Category Code", ItemCategoryCodeFilter)
        else
            ValueEntry.SetRange("NPR Item Category Code");
        //+NPR5.44 [312575]
    end;

    procedure GetCheckValue(): Text[250]
    begin
        //GetCheckValue()
        case ViewPosition of
            ViewPosition::ItemGroup:
                begin
                    exit(StrSubstNo('%1%2%3', Dim1Filter, Dim2Filter, DateFilter));
                end;
            ViewPosition::Item,
            ViewPosition::Customer,
            ViewPosition::Vendor:
                begin
                    exit(StrSubstNo('%1%2%3%4', Dim1Filter, Dim2Filter, ItemGroupFilter, DateFilter));
                end;
        end;
    end;

    procedure UpdateHiddenLines(ViewPos: Integer; bForce: Boolean)
    begin
        //UpdateHiddenLines()

        case ViewPos of
            ViewPosition::ItemGroup:
                begin
                    if (ItemGroupCheck <> GetCheckValue) or bForce then begin
                        // CurrForm.SubItemGroup.FORM.UpdateHidden;
                        //-NPR4.21
                        //CurrPage.ItemGroupStatisticsSubpage.PAGE.UpdateHidden;
                        //+NPR4.21
                        ItemGroupCheck := GetCheckValue;
                    end;
                end;
            ViewPosition::Item:
                begin
                    if (ItemCheck <> GetCheckValue) or bForce then begin
                        //CurrForm.SubItem.FORM.UpdateHidden;
                        //-NPR4.21
                        //CurrPage.ItemStatisticsSubpage.PAGE.UpdateHidden;
                        //+NPR4.21
                        ItemCheck := GetCheckValue;
                    end;
                end;
            ViewPosition::Customer:
                begin
                    if (CustomerCheck <> GetCheckValue) or bForce then begin
                        //CurrForm.SubCustomer.FORM.UpdateHidden;
                        //-NPR4.21
                        //CurrPage."CustomerStatistics Subpage".PAGE.UpdateHidden;
                        //+NPR4.21
                        CustomerCheck := GetCheckValue;
                    end;
                end;
            ViewPosition::Vendor:
                begin
                    if (VendorCheck <> GetCheckValue) or bForce then begin
                        //CurrForm.SubVendor.FORM.UpdateHidden;
                        //-NPR4.21
                        //CurrPage.VendorStatisticsSubpage.PAGE.UpdateHidden;
                        //+NPR4.21
                        VendorCheck := GetCheckValue;
                    end;
                end;
        end;
    end;

    local procedure PeriodPeriodTypeOnPush()
    begin
        //-NPR5.31
        //UpdateSubForm;
        //+NPR5.31
    end;

    local procedure DayPeriodTypeOnValidate()
    begin

        Day := PeriodType;
        Calc();
        //DayPeriodTypeOnPush;
    end;

    local procedure WeekPeriodTypeOnValidate()
    begin
        Day := PeriodType;
        Calc();
        //WeekPeriodTypeOnPush;
    end;

    local procedure MonthPeriodTypeOnValidate()
    begin
        Day := PeriodType;
        Calc();
        //MonthPeriodTypeOnPush;
    end;

    local procedure QuarterPeriodTypeOnValidate()
    begin
        Day := PeriodType;
        Calc();
        //QuarterPeriodTypeOnPush;
    end;

    local procedure YearPeriodTypeOnValidate()
    begin
        Day := PeriodType;
        Calc();
        //YearPeriodTypeOnPush;
    end;

    local procedure PeriodPeriodTypeOnValidate()
    var
        tblPeriode: Record "NPR Periodes";
    begin
        //Day:=PeriodType;
        if not UsingPeriod then
            UsingPeriod := true
        else
            UsingPeriod := false;

        if UsingPeriod then begin
            //IF FORM.RUNMODAL(6060102,tblPeriode) = ACTION::LookupOK THEN BEGIN
            if PAGE.RunModal(6060102, tblPeriode) = ACTION::LookupOK then begin
                "Period Start" := tblPeriode."Start Date";
                "Period End" := tblPeriode."End Date";
                DateFilter := StrSubstNo('%1..%2', "Period Start", "Period End");
                SetFilter("Period Start", DateFilter);
                DateFilterLastYear := StrSubstNo('%1..%2', tblPeriode."Start Date Last Year", tblPeriode."End Date Last Year");
                Day := Day::Day;
            end;
        end else
            SetFilter("Period Start", '');
        //-NPR5.31
        //UpdateSubformFilters;
        //+NPR5.31
        Calc();
        PeriodPeriodTypeOnPush;
    end;
}

