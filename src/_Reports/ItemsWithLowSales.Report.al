report 6014540 "NPR Items With Low Sales"
{
    // NPR70.00.00.00/LS/090414 CASE 175121 : Report displaying Items with low sales/profitability
    // NPR4.14/KN/20152108 CASE  221162  Expanded column and merged two cells to fit caption
    // NPR5.25/JLK /20160726 CASE 247119 Increase Description field from rdlc
    //                                   Adjusted margins for pdf layout
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.48/TJ  /20180102  CASE 340615 Removed Product Group Code from ReqFilterFields property on dataitem Item
    // NPR5.48/BHR /20190111  CASE 341976 Remove unused variables
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Items With Low Sales.rdlc';

    Caption = 'Items With Low Sales';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Inventory Posting Group", "Item Category Code", "Vendor No.";

            trigger OnAfterGetRecord()
            begin
                DialogBox.Update(1, "No.");

                CalcFields("Sales (LCY)", "Sales (Qty.)");

                if ("Sales (LCY)" = 0) and not ShowNotSold then
                    CurrReport.Skip;

                TempItemAmount.Init;
                TempItemAmount."Item No." := "No.";

                TempItemAmount.Amount := "Sales (LCY)";
                TempItemAmount."Amount 2" := "Sales (Qty.)";

                TempItemAmount.Insert;
                if (RankQty = 0) or (i < RankQty) then
                    i := i + 1
                else begin
                    TempItemAmount.FindLast;
                    TempItemAmount.Delete;
                end;

                ItemSalesAmt += "Sales (LCY)";
            end;

            trigger OnPreDataItem()
            begin
                if (PeriodStartDate = 0D) or (PeriodEndDate = 0D) then
                    Error(TextInputDate);

                Item.SetRange("Date Filter", PeriodStartDate, PeriodEndDate);

                DialogBox.Open(Text001);
                TempItemAmount.DeleteAll;
                i := 0;

                CurrReport.CreateTotals("Sales (LCY)", Item."Sales (Qty.)");
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = FILTER(1 ..));
            column(COMPANYNAME; CompanyName)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Text002___ItemDateFilter; Text002 + ItemDateFilter)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(Text004; Text004)
            {
            }
            column(txtShowNotSold; TxtShowNotSold)
            {
            }
            column(Item__Vendor_Item_No__; Item."Vendor Item No.")
            {
            }
            column(Item__Sales__LCY__; Item."Sales (LCY)")
            {
            }
            column(Item__Base_Unit_of_Measure_; Item."Base Unit of Measure")
            {
            }
            column(Item__Sales__Qty___; Item."Sales (Qty.)")
            {
            }
            column(Item_Description; Item.Description)
            {
            }
            column(Item__No__; Item."No.")
            {
            }
            column(Integer_Number; Number)
            {
            }
            column(ItemDateFilter; ItemDateFilter)
            {
            }
            column(ShowNotSold; ShowNotSold)
            {
            }
            column(Item__Sales__LCY___Control25; Item."Sales (LCY)")
            {
            }
            column(ItemSalesAmt_; ItemSalesAmt)
            {
            }
            column(SalesAmounPct_; SalesAmounPct)
            {
                DecimalPlaces = 1 : 1;
            }
            column(txtTotal; TxtTotal)
            {
            }
            column(txtTotalSales_; TxtTotalSales)
            {
            }
            column(txtPctTotalSales_; TxtPctTotalSales)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(Vendors_item_no_Caption; Vendors_item_no_CaptionLbl)
            {
            }
            column(txtSalesLCYCaption; TxtSalesLCYCaptionLbl)
            {
            }
            column(txtSalesQuantityCaption; TxtSalesQuantityCaptionLbl)
            {
            }
            column(Item_descriptionCaption; Item_descriptionCaptionLbl)
            {
            }
            column(txtItemNoCaption; TxtItemNoCaptionLbl)
            {
            }
            column(txtRankCaption; TxtRankCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempItemAmount.FindFirst then
                        CurrReport.Break;
                end else begin
                    if TempItemAmount.Next = 0 then
                        CurrReport.Break;
                end;

                Item.Get(TempItemAmount."Item No.");
                Item.CalcFields("Sales (LCY)", "Sales (Qty.)");

                SalesAmounPct := Pct(Item."Sales (LCY)", ItemSalesAmt);
            end;

            trigger OnPreDataItem()
            begin
                ItemDateFilter := Item.GetFilter("Date Filter");
                DialogBox.Close;

                ItemSalesAmt := Item."Sales (LCY)";

                CurrReport.CreateTotals(Item."Sales (LCY)", Item."Sales (Qty.)");
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
                    field(RankQty; RankQty)
                    {
                        Caption = 'Rank Quantity';
                        ApplicationArea=All;
                    }
                    field(PeriodStartDate; PeriodStartDate)
                    {
                        Caption = 'Start Period';
                        ApplicationArea=All;
                    }
                    field(PeriodEndDate; PeriodEndDate)
                    {
                        Caption = 'End Period';
                        ApplicationArea=All;
                    }
                    field(ShowNotSold; ShowNotSold)
                    {
                        Caption = 'Include Items Not On Inventory Or Not Sold';
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
    }

    trigger OnInitReport()
    begin
        RankQty := 10;
        PeriodStartDate := CalcDate(TxtFirstCM, Today);
        PeriodEndDate := CalcDate(TxtLastCM, Today);
    end;

    var
        Text001: Label 'Grouping Items   #1##########';
        Text002: Label 'Period: ';
        DialogBox: Dialog;
        TempItemAmount: Record "Item Amount" temporary;
        ItemDateFilter: Text[30];
        ItemSalesAmt: Decimal;
        SalesAmounPct: Decimal;
        i: Integer;
        Text004: Label 'Items With Low Sales';
        TxtShowNotSold: Label 'Item not sold or with no inventory are included.';
        TxtTotal: Label 'Total';
        TxtTotalSales: Label 'Total Sales';
        TxtPctTotalSales: Label '% of Total Sales';
        TxtFirstCM: Label '''<-CM>''';
        TxtLastCM: Label '''<CM>''';
        PeriodStartDate: Date;
        PeriodEndDate: Date;
        TextInputDate: Label 'Please fill Period Start Date and Period Closing Date';
        ShowNotSold: Boolean;
        RankQty: Integer;
        PageCaptionLbl: Label 'Page';
        Vendors_item_no_CaptionLbl: Label 'Vendors item no.';
        TxtSalesLCYCaptionLbl: Label 'Sales (LCY)';
        TxtSalesQuantityCaptionLbl: Label 'Sales Quantity';
        Item_descriptionCaptionLbl: Label 'Item description';
        TxtItemNoCaptionLbl: Label 'Item No.';
        TxtRankCaptionLbl: Label 'Rank';

    procedure Pct(Number1: Decimal; Number2: Decimal): Decimal
    begin
        if Number2 = 0 then
            exit(0);
        exit(Round(Number1 / Number2 * 100, 0.1));
    end;
}

