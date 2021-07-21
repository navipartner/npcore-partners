report 6014540 "NPR Items With Low Sales"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Items With Low Sales.rdlc';
    Caption = 'Items With Low Sales';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;

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
                    CurrReport.Skip();

                TempItemAmount.Init();
                TempItemAmount."Item No." := "No.";
                TempItemAmount.Amount := "Sales (LCY)";
                TempItemAmount."Amount 2" := "Sales (Qty.)";
                TempItemAmount.Insert();
                if (RankQty = 0) or (i < RankQty) then
                    i := i + 1
                else begin
                    TempItemAmount.FindLast();
                    TempItemAmount.Delete();
                end;

                ItemSalesAmt += "Sales (LCY)";
            end;

            trigger OnPreDataItem()
            begin
                if (PeriodStartDate = 0D) or (PeriodEndDate = 0D) then
                    Error(TextInputDate);

                Item.SetRange("Date Filter", PeriodStartDate, PeriodEndDate);

                DialogBox.Open(Text001);
                TempItemAmount.DeleteAll();
                i := 0;

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
                    if not TempItemAmount.FindFirst() then
                        CurrReport.Break();
                end else begin
                    if TempItemAmount.Next() = 0 then
                        CurrReport.Break();
                end;

                Item.Get(TempItemAmount."Item No.");
                Item.CalcFields("Sales (LCY)", "Sales (Qty.)");

                SalesAmounPct := Pct(Item."Sales (LCY)", ItemSalesAmt);
            end;

            trigger OnPreDataItem()
            begin
                ItemDateFilter := Item.GetFilter("Date Filter");
                DialogBox.Close();

                ItemSalesAmt := Item."Sales (LCY)";

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
                    field("Rank Qty"; RankQty)
                    {
                        Caption = 'Rank Quantity';

                        ToolTip = 'Specifies the value of the Rank Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period Start Date"; PeriodStartDate)
                    {
                        Caption = 'Start Period';

                        ToolTip = 'Specifies the value of the Start Period field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period End Date"; PeriodEndDate)
                    {
                        Caption = 'End Period';

                        ToolTip = 'Specifies the value of the End Period field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Not Sold"; ShowNotSold)
                    {
                        Caption = 'Include Items Not On Inventory Or Not Sold';

                        ToolTip = 'Specifies the value of the Include Items Not On Inventory Or Not Sold field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }

    trigger OnInitReport()
    begin
        RankQty := 10;
        PeriodStartDate := CalcDate(TxtFirstCM, Today);
        PeriodEndDate := CalcDate(TxtLastCM, Today);
    end;

    var
        TempItemAmount: Record "Item Amount" temporary;
        ShowNotSold: Boolean;
        PeriodEndDate: Date;
        PeriodStartDate: Date;
        ItemSalesAmt: Decimal;
        SalesAmounPct: Decimal;
        DialogBox: Dialog;
        i: Integer;
        RankQty: Integer;
        TxtPctTotalSales: Label '% of Total Sales';
        TxtLastCM: Label '''<CM>''';
        TxtFirstCM: Label '''<-CM>''';
        Text001: Label 'Grouping Items   #1##########';
        Item_descriptionCaptionLbl: Label 'Item description';
        TxtItemNoCaptionLbl: Label 'Item No.';
        TxtShowNotSold: Label 'Item not sold or with no inventory are included.';
        Text004: Label 'Items With Low Sales';
        PageCaptionLbl: Label 'Page';
        Text002: Label 'Period: ';
        TextInputDate: Label 'Please fill Period Start Date and Period Closing Date';
        TxtRankCaptionLbl: Label 'Rank';
        TxtSalesLCYCaptionLbl: Label 'Sales (LCY)';
        TxtSalesQuantityCaptionLbl: Label 'Sales Quantity';
        TxtTotal: Label 'Total';
        TxtTotalSales: Label 'Total Sales';
        Vendors_item_no_CaptionLbl: Label 'Vendors item no.';
        ItemDateFilter: Text;

    procedure Pct(Number1: Decimal; Number2: Decimal): Decimal
    begin
        if Number2 = 0 then
            exit(0);
        exit(Round(Number1 / Number2 * 100, 0.1));
    end;
}

